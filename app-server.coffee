express = require('express')
app = express()
http = require('http').Server(app)
io = require('socket.io')(http)
_ = require('lodash')

connections = []
title = 'Untitled Presentation'
audience = []
speaker = {}

app.use(express.static('./public'))
app.use(express.static('./node_modules/bootstrap/dist'))

io.on('connection', (socket)->

  socket.once('disconnect', ()->
    member = _.findWhere(audience, {id: @id})

    if member
      audience.splice(audience.indexOf(member), 1)
      io.emit('audience', audience)
      console.log('left: %s ( %s audience members )', member.name, audience.length)

    connections.splice(connections.indexOf(socket), 1)
    socket.disconnect()
    console.log('Disconnected: %s sockets remaining', connections.length)
  );

  socket.on('join', (payload)->
    newMember = {
      id: @id
      name:payload.name
      type:'member'
    }
    @emit('joined', newMember)
    audience.push(newMember)
    io.emit('audience', audience)
    console.log('Audience joined %s', payload.name)
  )

  socket.on('start', (payload)->
    speaker.name = payload.name
    speaker.id = @id
    speaker.type = 'speaker'
    @emit('joined', speaker)
    io.emit('start', {title:title, speaker:speaker})
    console.log('Presentation started: "%s" by %sd', title, speaker.name)
  )

  socket.emit('welcome',{
    title:title
    audience:audience
    speaker:speaker.name
  });

  connections.push(socket)
  console.log("Connected: %s sockets connected", connections.length)
)

http.listen(3000, (err)->
  if(err)
    console.log(err)
  else
    console.log('Server listening at port 3000')
)