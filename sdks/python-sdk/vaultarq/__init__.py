"""
Vaultarq - Python SDK for the developer-first, invisible secrets manager.

This SDK provides functions to load secrets from a Vaultarq vault 
into your application's environment variables.
"""

from .vaultarq import load_env, is_available

__version__ = "0.1.0"
__all__ = ["load_env", "is_available"] 