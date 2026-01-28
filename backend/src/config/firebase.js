

// Check if we are in a production environment (ENVIRONMENT variable set to 'production' or similar)
// OR if the service account details are provided directly via env vars
if (process.env.FIREBASE_SERVICE_ACCOUNT) {
  let serviceAccount;
  try {
    // Try Option 1: Base64 decode
    serviceAccount = JSON.parse(Buffer.from(process.env.FIREBASE_SERVICE_ACCOUNT, 'base64').toString('utf8'));
  } catch (e) {
    // Try Option 2: Raw JSON string
    try {
      serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);
    } catch (parseError) {
      console.error("FIREBASE_SERVICE_ACCOUNT is neither valid Base64 nor valid JSON");
      throw parseError;
    }
  }

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
