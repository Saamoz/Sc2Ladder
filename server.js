const express = require('express');

const app = express();


app.use(express.static('./dist/sc2ladder.json'));
app.get('/*', function(req, res) {
  res.sendFile('index.html', {root: 'dist/sc2ladder/'}
);
});
app.listen(process.env.PORT || 8080);
