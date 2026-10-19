const admin = require('firebase-admin');
const path = require('path');

const serviceAccountPath = path.resolve(__dirname, '..', 'serviceAccountKey.json');
const serviceAccount = require(serviceAccountPath);

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  projectId: 'clickbitedelivery',
});

async function check() {
  try {
    const db = admin.firestore();
    const collections = await db.listCollections();
    console.log('Collections in default database:', collections.map(c => c.id));
  } catch (err) {
    console.error('Check error:', err.message, 'Code:', err.code);
  }
}

check();
