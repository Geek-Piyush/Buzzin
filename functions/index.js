const { onDocumentCreated } = require("firebase-functions/v2/firestore");

const admin = require("firebase-admin");

admin.initializeApp();

// Cloud Firestore triggers ref: https://firebase.google.com/docs/functions/firestore-events
exports.myFunction = onDocumentCreated("/chat/{messageId}", async (event) => {
  // Return this function's promise, so this ensures the firebase function
  // will keep running, until the notification is scheduled.
  return admin.messaging().send({
    // Sending a notification message.
    notification: {
      title: event.data.data()["username"],
      body: event.data.data()["text"],
    },
    data: {
      // Data payload to be sent to the device.
      click_action: "FLUTTER_NOTIFICATION_CLICK",
    },
    topic: "chat",
  });
});
