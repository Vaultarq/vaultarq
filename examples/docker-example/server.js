/**
 * Vaultarq Docker Example
 * @author Dedan Okware <softengdedan@gmail.com>
 */
const express = require('express');
const vaultarq = require('@vaultarq/node').default;

const app = express();
const port = process.env.PORT || 3000;

// Setup route to display loaded secrets (only keys, not values for security)
app.get('/', async (req, res) => {
  const html = `
    <!DOCTYPE html>
    <html>
    <head>
      <title>Vaultarq Docker Example</title>
      <style>
        body { font-family: Arial, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px; }
        h1 { color: #333; }
        .secret-key { background: #f4f4f4; padding: 8px 12px; margin: 5px 0; border-radius: 4px; }
        .success { color: green; }
        .error { color: red; }
        pre { background: #f8f8f8; padding: 15px; border-radius: 5px; overflow: auto; }
      </style>
    </head>
    <body>
      <h1>Vaultarq Docker Example</h1>
      
      <h2>Environment Details</h2>
      <pre>
Node version: ${process.version}
Hostname: ${process.env.HOSTNAME || 'unknown'}
      </pre>
      
      <h2>Available Secret Keys</h2>
      <div id="secrets">
        ${Object.keys(process.env)
          .filter(key => !key.startsWith('npm_') && 
                        !key.startsWith('PATH') && 
                        !key.startsWith('NODE') && 
                        key !== 'HOME' && 
                        key !== 'HOSTNAME')
          .map(key => `<div class="secret-key">${key}</div>`)
          .join('') || '<p class="error">No secrets found. Have you added any with vaultarq push?</p>'}
      </div>
      
      <h3>Instructions</h3>
      <p>To add secrets, run:</p>
      <pre>./vaultarq-docker.sh push API_KEY=my-secret-key</pre>
      <p>Then refresh this page to see them loaded.</p>
    </body>
    </html>
  `;
  
  res.send(html);
});

// Start the application
async function startServer() {
  console.log('Starting server...');
  
  try {
    // Attempt to load secrets from Vaultarq
    console.log('Loading secrets from Vaultarq...');
    
    const loaded = await vaultarq.load({
      binPath: process.env.VAULTARQ_BIN_PATH || 'vaultarq',
      throwIfNotFound: false,
    });
    
    if (loaded) {
      console.log('✅ Secrets loaded successfully');
    } else {
      console.log('⚠️ No secrets loaded. Vaultarq may not be configured properly.');
    }
    
    // Start the server
    app.listen(port, () => {
      console.log(`Server running at http://localhost:${port}`);
    });
  } catch (error) {
    console.error('Error starting server:', error);
    process.exit(1);
  }
}

startServer(); 