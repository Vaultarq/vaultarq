#!/usr/bin/env node

/**
 * Vaultarq encryption helper
 * Uses AES-256-GCM for encryption and Argon2 for key derivation
 */

const crypto = require('crypto');
const readline = require('readline');
const argon2 = require('argon2');

// Configuration
const ARGON2_MEMORY_COST = 65536; // 64MB
const ARGON2_TIME_COST = 3;       // Iterations
const ARGON2_PARALLELISM = 1;     // Parallelism factor
const ARGON2_OUTPUT_LENGTH = 32;  // 32 bytes = 256 bits for AES-256

/**
 * Derives an encryption key from a password using Argon2id
 * @param {string} password - User-provided master password
 * @param {Buffer} salt - Random salt for key derivation
 * @returns {Promise<Buffer>} - Derived key
 */
async function deriveKey(password, salt) {
  try {
    return await argon2.hash(password, {
      type: argon2.argon2id,
      memoryCost: ARGON2_MEMORY_COST,
      timeCost: ARGON2_TIME_COST,
      parallelism: ARGON2_PARALLELISM,
      hashLength: ARGON2_OUTPUT_LENGTH,
      raw: true,
      salt
    });
  } catch (error) {
    console.error('Error deriving key:', error.message);
    process.exit(1);
  }
}

/**
 * Encrypts data using AES-256-GCM
 * @param {string} data - Plain text data to encrypt
 * @param {string} password - User-provided master password
 * @returns {Promise<string>} - Encrypted data in format: salt:iv:authTag:encrypted
 */
async function encrypt(data, password) {
  // Generate a random salt for key derivation
  const salt = crypto.randomBytes(16);
  
  // Derive encryption key from password using Argon2id
  const key = await deriveKey(password, salt);
  
  // Generate a random initialization vector
  const iv = crypto.randomBytes(12);
  
  // Create cipher with AES-256-GCM
  const cipher = crypto.createCipheriv('aes-256-gcm', key, iv);
  
  // Encrypt the data
  let encrypted = cipher.update(data, 'utf8', 'base64');
  encrypted += cipher.final('base64');
  
  // Get the authentication tag
  const authTag = cipher.getAuthTag().toString('base64');
  
  // Format: salt:iv:authTag:encrypted
  return `${salt.toString('base64')}:${iv.toString('base64')}:${authTag}:${encrypted}`;
}

// Main function
async function main() {
  if (process.argv.length < 3) {
    console.error('Usage: encrypt.js <password>');
    process.exit(1);
  }

  const password = process.argv[2];
  
  // Read data from stdin
  let data = '';
  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
    terminal: false
  });
  
  for await (const line of rl) {
    data += line + '\n';
  }
  
  // Remove the last newline
  data = data.trim();
  
  try {
    const encrypted = await encrypt(data, password);
    console.log(encrypted);
  } catch (error) {
    console.error('Encryption error:', error.message);
    process.exit(1);
  }
}

// Execute main if called directly
if (require.main === module) {
  main().catch(error => {
    console.error('Error:', error.message);
    process.exit(1);
  });
} 