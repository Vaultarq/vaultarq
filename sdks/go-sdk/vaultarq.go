// Package vaultarq provides a Go SDK for the Vaultarq secrets manager.
//
// It allows for seamless integration with Go applications by automatically
// loading secrets from a Vaultarq vault and injecting them into the environment.
package vaultarq

import (
	"bufio"
	"errors"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"strings"
)

// Config represents configuration options for loading secrets.
type Config struct {
	// BinPath is the path to the Vaultarq executable.
	// Defaults to 'vaultarq' (assumes it's in PATH).
	BinPath string

	// ThrowIfNotFound determines whether to throw an error if Vaultarq is not found.
	// Defaults to false (fails silently).
	ThrowIfNotFound bool

	// Environment specifies which environment to load secrets from.
	// If not specified, uses the currently linked environment.
	Environment string

	// Format specifies the format to export secrets in.
	// Defaults to "bash".
	Format string
}

// DefaultConfig returns a new Config with default values.
func DefaultConfig() *Config {
	return &Config{
		BinPath:         "vaultarq",
		ThrowIfNotFound: false,
		Format:          "bash",
	}
}

// IsAvailable checks if Vaultarq is installed and accessible.
func IsAvailable() bool {
	return IsAvailableWithPath("vaultarq")
}

// IsAvailableWithPath checks if Vaultarq is installed and accessible at the specified path.
func IsAvailableWithPath(binPath string) bool {
	// If a full path is provided, check if it exists
	if filepath.IsAbs(binPath) {
		if _, err := os.Stat(binPath); os.IsNotExist(err) {
			return false
		}
	} else {
		// Otherwise check if it's in PATH
		_, err := exec.LookPath(binPath)
		if err != nil {
			return false
		}
	}

	// Try running the command
	cmd := exec.Command(binPath)
	err := cmd.Run()
	return err == nil
}

// Load loads secrets from Vaultarq into environment variables using default configuration.
func Load() error {
	return LoadWithConfig(DefaultConfig())
}

// LoadWithConfig loads secrets from Vaultarq into environment variables using custom configuration.
func LoadWithConfig(config *Config) error {
	// Check if Vaultarq is available
	if !IsAvailableWithPath(config.BinPath) {
		if config.ThrowIfNotFound {
			return errors.New("vaultarq not found")
		}
		return nil
	}

	// Switch environment if needed
	if config.Environment != "" {
		cmd := exec.Command(config.BinPath, "link", config.Environment)
		output, err := cmd.CombinedOutput()
		if err != nil {
			return fmt.Errorf("failed to switch environment: %s - %s", err, string(output))
		}
	}

	// Get secrets
	format := config.Format
	if format == "" {
		format = "bash"
	}
	cmd := exec.Command(config.BinPath, "export", "--"+format)
	output, err := cmd.CombinedOutput()
	if err != nil {
		return fmt.Errorf("failed to export secrets: %s - %s", err, string(output))
	}

	// Parse and set environment variables
	scanner := bufio.NewScanner(strings.NewReader(string(output)))
	for scanner.Scan() {
		line := scanner.Text()
		if line == "" {
			continue
		}

		if strings.HasPrefix(line, "export ") {
			// Parse bash format: export KEY="VALUE"
			re := regexp.MustCompile(`^export\s+([A-Za-z0-9_]+)="(.*)"$`)
			matches := re.FindStringSubmatch(line)
			if len(matches) == 3 {
				key := matches[1]
				value := matches[2]
				os.Setenv(key, value)
			}
		} else {
			// Parse dotenv format: KEY=VALUE
			re := regexp.MustCompile(`^([A-Za-z0-9_]+)=(.*)$`)
			matches := re.FindStringSubmatch(line)
			if len(matches) == 3 {
				key := matches[1]
				value := matches[2]
				// Remove surrounding quotes if they exist
				if strings.HasPrefix(value, `"`) && strings.HasSuffix(value, `"`) {
					value = value[1 : len(value)-1]
				}
				os.Setenv(key, value)
			}
		}
	}

	return nil
} 