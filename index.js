const express = require('express')

// Global constants
const port = process.env.PORT || 8080;

// The APP!
const app = express()
app.get('/', (req, res) => {
  let message = 'Welcome to 2022!'
  message += `<br>Hey, just a note... Your User Agent is "${req.get('User-Agent')}"`
  res.send(message)
})

app.listen(port, () => {
  console.log(`App listening on port ${port}`)
})