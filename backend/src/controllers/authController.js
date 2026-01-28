const admin = require('../config/firebase');

exports.verifyGoogleToken = async (req, res) => {
    const { idToken, role } = req.body;

    if (!idToken) {
        return res.status(400).json({ error: 'ID Token is required' });
    }

    try {
        // Verify the ID token using Firebase Admin SDK
        const decodedToken = await admin.auth().verifyIdToken(idToken);
        const uid = decodedToken.uid;
        const email = decodedToken.email;

        console.log(`[Auth] Verifying token for user: ${email} with role: ${role}`);

        // In a real app, you would save/update the user in Firestore here
        // const userRef = admin.firestore().collection('users').doc(uid);
        // await userRef.set({ email, role, lastLogin: new Date() }, { merge: true });

        return res.status(200).json({
            message: 'Authentication successful',
            user: { uid, email, role },
            token: 'session_token_from_backend' // You might want to issue your own JWT here
        });

    } catch (error) {
        console.error('Error verifying Firebase token:', error);
        return res.status(401).json({ error: 'Unauthorized', details: error.message });
    }
};
