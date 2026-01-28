const admin = require('firebase-admin');

const admin = require('firebase-admin');

// Check if we are in a production environment (ENVIRONMENT variable set to 'production' or similar)
// OR if the service account details are provided directly via env vars
if (process.env.FIREBASE_SERVICE_ACCOUNT) {
  // Option 1: Load from a base64 encoded environment variable
  const serviceAccount = JSON.parse(Buffer.from(process.env.FIREBASE_SERVICE_ACCOUNT, 'base64').toString('utf8'));

  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
} else {
  // Option 2: Fallback to local file for development
  try {
    const serviceAccount = require('../../serviceAccountKey.json');
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
    });
  } catch (error) {
    console.error("Failed to load serviceAccountKey.json locally. Ensure it exists or set FIREBASE_SERVICE_ACCOUNT env var in production.");
    // We don't crash here so the server can start, but auth methods will fail.
  }
}

module.exports = admin;
