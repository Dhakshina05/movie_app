const functions = require("firebase-functions");
const express = require("express");

const app= express();
app.get("/", (req, res)=>{
 res.send("Hello from Firebase Node.js + Express!");
});

exports.app = functions.http.onRequest(app);