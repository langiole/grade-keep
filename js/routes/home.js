var express = require("express");
var router = express.Router();

// display home page
router.get("/", function(req, res, next) {
  res.sendFile("views/home.html", {root: "."} );
});

module.exports = router;
