// Example application using Vaultarq Node.js SDK
const vaultarq = require('@vaultarq/node').default;

async function main() {
  console.log('Checking if Vaultarq is installed...');
  const isAvailable = await vaultarq.isAvailable();
  
  if (!isAvailable) {
    console.log('❌ Vaultarq is not installed or not in PATH');
    console.log('Please install Vaultarq and try again:');
    console.log('curl -fsSL https://raw.githubusercontent.com/Vaultarq/vaultarq/main/install.sh | bash');
    process.exit(1);
  }
  
  console.log('✅ Vaultarq is installed');
  console.log('Loading secrets into process.env...');
  
  try {
    const success = await vaultarq.load();
    
    if (success) {
      console.log('✅ Secrets loaded successfully');
      
      // Print all environment variables loaded from Vaultarq
      console.log('\nLoaded environment variables:');
      const keys = Object.keys(process.env).sort();
      
      let foundSecrets = false;
      
      for (const key of keys) {
        // Skip system environment variables for cleaner output
        if (key.startsWith('npm_') || key.startsWith('PATH') || key === 'SHELL' || key === 'HOME') {
          continue;
        }
        
        console.log(`${key}=${process.env[key]}`);
        foundSecrets = true;
      }
      
      if (!foundSecrets) {
        console.log('No secrets found in Vaultarq vault.');
        console.log('Try adding some with: vaultarq push API_KEY=my-secret-key');
      } else {
        console.log('\nExample use:');
        console.log('-----------------------------');
        console.log('In your application, you can now access these variables using:');
        console.log('process.env.API_KEY, process.env.DB_PASSWORD, etc.');
      }
    } else {
      console.log('❌ Failed to load secrets');
      console.log('Make sure Vaultarq is properly initialized:');
      console.log('vaultarq init');
    }
  } catch (error) {
    console.error('❌ Error loading secrets:', error.message);
  }
}

main().catch(console.error); 