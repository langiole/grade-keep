var createError   = require("http-errors");
var express       = require("express");
var admin         = require("firebase-admin");
var bodyParser    = require('body-parser');

var app = express();

app.use(bodyParser.json());

var indexRouter = require("./routes/index");
var homeRouter = require("./routes/home");
var addCourseRouter = require("./routes/addCourse")


// README - init cloud-firestore
var serviceAccount = require("./grade-keep-firebase-adminsdk-oovcw-4be84ecee7.json");
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://grade-keep.firebaseio.com"
});
var db = admin.firestore();

// TEST TO SEE IF USER EXISTS
admin.auth().getUserByEmail("jordan@charloe.com")
  .then(function(userRecord) {
    // See the UserRecord reference doc for the contents of userRecord.
    console.log("Successfully fetched user data:\n", userRecord.toJSON());
  })
  .catch(function(error) {
    console.log("Error fetching user data:", error);
  });


// index page
app.use('/index', indexRouter);

// home page
app.use('/home', homeRouter);

// add course page
app.use('/addCourse', addCourseRouter)

app.use(function(req, res, next) {
  res.send("Error: page not found");
});

module.exports = app;
