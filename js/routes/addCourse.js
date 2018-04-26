var express = require("express");
var router = express.Router();

// display home page
router.get("/", function(req, res, next) {
  res.sendFile("views/addCourse.html", {root: "."} );
});

// add course
router.post("/", function(req, res, next) {
    var data = req.body
    console.log(data)

    for (var key in data) {
        console.log(data[key]);
    }


    res.send("ok")
});

module.exports = router;