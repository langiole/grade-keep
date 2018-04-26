var express = require("express");
var router = express.Router();

// display home page
router.get("/", function(req, res, next) {
  res.sendFile("views/index.html", {root: "."} );
});

router.post('/', function(req, res) {
  res.sendFile("views/home.html", {root: "."} );
  // res.send("got this "  + JSON.stringify(req.body));
});

module.exports = router;
