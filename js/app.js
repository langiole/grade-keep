var createError = require('http-errors');
var express = require('express');
var path = require('path')

var indexRouter = require('./routes/index');
var usersRouter = require('./routes/users');

var app = express();

// README - init cloud-firestore
var admin = require("firebase-admin");
var serviceAccount = require("./grade-keep-firebase-adminsdk-oovcw-4be84ecee7.json");
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://grade-keep.firebaseio.com"
});
var db = admin.firestore();

admin.auth().getUserByEmail("jordan@charloe.com")
  .then(function(userRecord) {
    // See the UserRecord reference doc for the contents of userRecord.
    console.log("Successfully fetched user data:\n", userRecord.toJSON());
  })
  .catch(function(error) {
    console.log("Error fetching user data:", error);
  });


// default page
app.use('/', indexRouter);

// users page
app.use('/users', usersRouter);

app.use(function(req, res, next) {
  res.send("Error: page not found")
});

module.exports = app;
