#!/usr/bin/env node

/**
 * Vaultarq decryption helper
 * Uses AES-256-GCM for decryption and Argon2id for key derivation
 */

const crypto = require('crypto');
const fs = require('fs');
const argon2 = require('argon2');

// Configuration
const ARGON2_MEMORY_COST = 65536; // 64MB
const ARGON2_TIME_COST = 3;       // Iterations
const ARGON2_PARALLELISM = 1;     // Parallelism factor
const ARGON2_OUTPUT_LENGTH = 32;  // 32 bytes = 256 bits for AES-256

/**
 * Derives an encryption key from a password using Argon2id
 * @param {string} password - User-provided master password
 * @param {Buffer} salt - Salt used during encryption
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
 * Decrypts data using AES-256-GCM
 * @param {string} encryptedData - Encrypted data in format: salt:iv:authTag:encrypted
 * @param {string} password - User-provided master password
 * @returns {Promise<string>} - Decrypted data as UTF-8 string
 */
async function decrypt(encryptedData, password) {
  // Split the encrypted data into components
  const [saltBase64, ivBase64, authTagBase64, encryptedBase64] = encryptedData.split(':');
  
  if (!saltBase64 || !ivBase64 || !authTagBase64 || !encryptedBase64) {
    throw new Error('Invalid encrypted data format');
  }
  
  // Convert from base64
  const salt = Buffer.from(saltBase64, 'base64');
  const iv = Buffer.from(ivBase64, 'base64');
  const authTag = Buffer.from(authTagBase64, 'base64');
  const encrypted = Buffer.from(encryptedBase64, 'base64');
  
  // Derive the key using the same salt
  const key = await deriveKey(password, salt);
  
  // Create decipher
  const decipher = crypto.createDecipheriv('aes-256-gcm', key, iv);
  decipher.setAuthTag(authTag);
  
  // Decrypt the data
  try {
    let decrypted = decipher.update(encrypted);
    decrypted = Buffer.concat([decrypted, decipher.final()]);
    return decrypted.toString('utf8');
  } catch (error) {
    throw new Error('Decryption failed. Incorrect password or tampered data.');
  }
}

// Main function
async function main() {
  if (process.argv.length < 3) {
    console.error('Usage: decrypt.js <password>');
    process.exit(1);
  }

  const password = process.argv[2];
  
  // Read encrypted data from stdin
  let encryptedData = '';
  for await (const chunk of process.stdin) {
    encryptedData += chunk;
  }
  encryptedData = encryptedData.trim();
  
  try {
    const decrypted = await decrypt(encryptedData, password);
    console.log(decrypted);
  } catch (error) {
    console.error('Decryption error:', error.message);
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