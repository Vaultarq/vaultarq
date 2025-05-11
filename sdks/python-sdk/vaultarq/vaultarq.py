"""
Core implementation of the Vaultarq Python SDK.
"""

import os
import re
import subprocess
import shutil
from typing import Dict, List, Optional, Union, Any, Tuple, Dict, Callable


def _run_command(command: List[str], silent: bool = True) -> Tuple[bool, str, str]:
    """
    Run a shell command and return the result.
    
    Args:
        command: The command to execute as a list of strings
        silent: Whether to suppress stderr output
        
    Returns:
        A tuple of (success, stdout, stderr)
    """
    try:
        result = subprocess.run(
            command,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            check=False
        )
        return (
            result.returncode == 0,
            result.stdout.strip(),
            result.stderr.strip()
        )
    except Exception as e:
        return False, "", str(e)


def is_available(bin_path: str = "vaultarq") -> bool:
    """
    Check if Vaultarq is installed and accessible.
    
    Args:
        bin_path: Path to the vaultarq executable
        
    Returns:
        True if vaultarq is available, False otherwise
    """
    # If a full path is provided, check if it exists
    if os.path.sep in bin_path:
        if not os.path.isfile(bin_path) or not os.access(bin_path, os.X_OK):
            return False
    
    # Otherwise check if it's in PATH
    elif shutil.which(bin_path) is None:
        return False
    
    # Try running the command
    success, _, _ = _run_command([bin_path])
    return success


def load_env(
    bin_path: str = "vaultarq",
    throw_if_not_found: bool = False,
    environment: Optional[str] = None,
    format: str = "bash",
) -> bool:
    """
    Load secrets from Vaultarq into os.environ.
    
    Args:
        bin_path: Path to the vaultarq executable
        throw_if_not_found: Whether to throw an error if vaultarq is not found
        environment: Environment to load secrets from
        format: Format to export secrets in ('bash', 'dotenv', or 'json')
        
    Returns:
        True if secrets were loaded successfully, False otherwise
        
    Raises:
        FileNotFoundError: If vaultarq is not found and throw_if_not_found is True
        RuntimeError: If there was an error running vaultarq
    """
    # Validate format
    if format not in ("bash", "dotenv", "json"):
        raise ValueError(f"Invalid format: {format}. Must be 'bash', 'dotenv', or 'json'")
    
    # Check if vaultarq is available
    if not is_available(bin_path):
        if throw_if_not_found:
            raise FileNotFoundError(f"Vaultarq executable not found at: {bin_path}")
        return False
    
    # Switch environment if needed
    if environment:
        success, _, stderr = _run_command([bin_path, "link", environment])
        if not success:
            if throw_if_not_found:
                raise RuntimeError(f"Failed to switch environment: {stderr}")
            return False
    
    # Get secrets
    command = [bin_path, "export", f"--{format}"]
    success, stdout, stderr = _run_command(command)
    
    if not success:
        if throw_if_not_found:
            raise RuntimeError(f"Failed to export secrets: {stderr}")
        return False
    
    # Parse and set environment variables
    if not stdout:
        return True  # No secrets found
    
    for line in stdout.splitlines():
        line = line.strip()
        if not line:
            continue
            
        if line.startswith("export "):
            # Parse bash format: export KEY="VALUE"
            match = re.match(r'^export\s+([A-Za-z0-9_]+)="(.*)"$', line)
            if match:
                key, value = match.groups()
                os.environ[key] = value
        else:
            # Parse dotenv format: KEY=VALUE
            match = re.match(r'^([A-Za-z0-9_]+)=(.*)$', line)
            if match:
                key, value = match.groups()
                # Remove surrounding quotes if they exist
                value = re.sub(r'^"(.*)"$', r'\1', value)
                os.environ[key] = value
    
    return True 