var express = require("express");
var router = express.Router();

// display home page
router.get("/", function(req, res, next) {
  res.sendFile("views/index.html", {root: "."} );
});


module.exports = router;
