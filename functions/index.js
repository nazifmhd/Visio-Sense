/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */


// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

const functions = require("firebase-functions");
const nodemailer = require("nodemailer");

// Configure your Gmail account
const gmailEmail = "visiosense123@gmail.com";
const gmailPassword = "xnvajwayxyruacah";

// Set up Nodemailer transport
const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: gmailEmail,
    pass: gmailPassword,
  },
});

exports.sendOtpEmail = functions.https.onCall((data, context) => {
  const email = data.email;
  const otp = data.otp;

  const mailOptions = {
    from: gmailEmail,
    to: email,
    subject: "Password Reset OTP",
    text: `Your OTP code is ${otp}`,
  };

  return transporter.sendMail(mailOptions, (error, info) => {
    if (error) {
      console.log("Error sending email:", error);
      return {success: false, error: error.toString()};
    } else {
      console.log("Email sent:", info.response);
      return {success: true};
    }
  });
});
