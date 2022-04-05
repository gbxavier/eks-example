const express = require('express')
const app = express()
const port = 3000

app.get('/', (req, res) => {
  let message = 'Welcome to 2022. '
  message += `Hey, just a note... Your User Agent is "${req.get('User-Agent')}"`
  res.send(message)
})

app.listen(port, () => {
  console.log(`App listening on port ${port}`)
})