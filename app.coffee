fs = require 'fs'
r_readdir = require('recursive-readdir-filter')
express = require('express')
app = express()
server = require('http').createServer(app)
io = require('socket.io').listen(server)
settings = JSON.parse fs.readFileSync('settings.json', encoding="ascii")

# setup
app.set 'view engine', 'ejs'
app.locals.server_url = "http://#{settings.host_ip}:#{settings.host_port}"

# route
app.use express.static(__dirname + '/public')

app.get '/', (req, res)->
  res.redirect '/remote'

app.get '/player', (req, res)->
  res.render 'player'

app.get '/remote', (req, res)->
  res.render 'remote'


# socket.io

io.sockets.on 'connection', (socket)->
  console.log "socket.io connected"

  socket.on 'disconnect', ->
    console.log "socket.id disconnected"

  socket.on 'remote_play', ->
    console.log 'REMOTE: I resume play'
    socket.broadcast.emit 'player_play'

  socket.on 'remote_pause', ->
    console.log 'REMOTE: I pause the play'
    socket.broadcast.emit 'player_pause'

  socket.on 'remote_mute', ->
    console.log 'REMOTE: I mute the volume'

  socket.on 'remote_forward', ->
    console.log 'REMOTE: I load next track'

  socket.on 'remote_backward', ->
    console.log 'REMOTE: I load previous track'

  socket.on 'remote_vol_up', ->
    console.log 'REMOTE: I increase volume'

  socket.on 'remote_vol_down', ->
    console.log 'REMOTE: I decrease volume'




create_playlist = ->
  console.log "Playlist being created."
  options =
    filterDir: (stats)->
      stats.name.substr(0,1) isnt '.'
    filterFile: (stats)->
      stats.name.substr(0,1) isnt '.' and stats.name.match(/\.(mp3|webm|ogg|aac|opus|mp4|wav)$/)

  r_readdir settings.music_dir, options, (err, files)->
    filtered_files = []
    for f in files
      do (f)->
        relative_url = "music/#{f.substr(settings.music_dir.length+1)}"
        filtered_files.push encodeURIComponent(relative_url)

    app.locals.music_files = filtered_files
    console.log "Playlist now has #{filtered_files.length} items."

# start server
server.listen settings.host_port, ->
  console.log "Listening on port #{server.address().port}"
  create_playlist()
  true
