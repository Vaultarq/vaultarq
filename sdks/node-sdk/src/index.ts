import { exec } from 'child_process';
import { promisify } from 'util';

const execAsync = promisify(exec);

/**
 * Configuration options for Vaultarq
 */
export interface VaultarqOptions {
  /**
   * Path to the vaultarq executable.
   * Defaults to 'vaultarq' (assumes it's in PATH)
   */
  binPath?: string;
  
  /**
   * Whether to throw an error if vaultarq is not found
   * Defaults to false (fails silently)
   */
  throwIfNotFound?: boolean;
  
  /**
   * Environment name to load
   * If not specified, uses the currently linked environment
   */
  environment?: string;
  
  /**
   * Format to export secrets in
   * Defaults to 'bash'
   */
  format?: 'bash' | 'dotenv' | 'json';
}

/**
 * Vaultarq Node.js SDK
 * 
 * Provides functionality to load secrets from Vaultarq into process.env
 */
class Vaultarq {
  private defaultOptions: VaultarqOptions = {
    binPath: 'vaultarq',
    throwIfNotFound: false,
    format: 'bash'
  };

  /**
   * Loads all secrets from Vaultarq into process.env
   * 
   * @param options Configuration options
   * @returns Promise resolving to true if secrets were loaded, false otherwise
   */
  async load(options: VaultarqOptions = {}): Promise<boolean> {
    const opts = { ...this.defaultOptions, ...options };
    
    try {
      // Build the command
      let command = `${opts.binPath} export --${opts.format}`;
      
      if (opts.environment) {
        // If environment is specified, temporarily switch using link
        const envCmd = await this.runCommand(`${opts.binPath} link ${opts.environment}`);
        if (!envCmd.success) {
          throw new Error(`Failed to switch to environment: ${opts.environment}`);
        }
      }
      
      // Run the export command
      const result = await this.runCommand(command);
      
      if (!result.success) {
        return false;
      }
      
      // Parse and inject environment variables
      const lines = result.stdout.split('\n').filter(line => line.trim());
      
      for (const line of lines) {
        if (line.startsWith('export ')) {
          // Parse 'export KEY="VALUE"' format
          const match = line.match(/^export\s+([A-Za-z0-9_]+)="(.*)"$/);
          if (match) {
            const [, key, value] = match;
            process.env[key] = value;
          }
        } else {
          // Parse 'KEY=VALUE' format (dotenv)
          const match = line.match(/^([A-Za-z0-9_]+)=(.*)$/);
          if (match) {
            const [, key, value] = match;
            // Remove surrounding quotes if they exist
            const cleanValue = value.replace(/^"(.*)"$/, '$1');
            process.env[key] = cleanValue;
          }
        }
      }
      
      return true;
    } catch (error) {
      if (opts.throwIfNotFound) {
        throw error;
      }
      return false;
    }
  }

  /**
   * Checks if Vaultarq is installed and accessible
   * 
   * @param binPath Path to the vaultarq executable
   * @returns Promise resolving to true if vaultarq is available
   */
  async isAvailable(binPath: string = this.defaultOptions.binPath || 'vaultarq'): Promise<boolean> {
    try {
      const result = await this.runCommand(`${binPath} --version || ${binPath}`);
      return result.success;
    } catch (error) {
      return false;
    }
  }

  /**
   * Runs a shell command and returns the result
   * 
   * @param command Command to execute
   * @returns Object containing success status and command output
   */
  private async runCommand(command: string): Promise<{ success: boolean; stdout: string; stderr: string }> {
    try {
      const { stdout, stderr } = await execAsync(command);
      return {
        success: true,
        stdout: stdout.trim(),
        stderr: stderr.trim()
      };
    } catch (error: any) {
      return {
        success: false,
        stdout: error?.stdout?.trim() || '',
        stderr: error?.stderr?.trim() || error?.message || 'Unknown error'
      };
    }
  }
}

// Export the singleton instance
export default new Vaultarq();

// Also export the class for users who need multiple instances
export { Vaultarq }; 