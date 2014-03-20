fs = require 'fs'
r_readdir = require('recursive-readdir')
express = require('express')
app = express()
server = require('http').createServer(app)
io = require('socket.io').listen(server)
music_dir = './public/music'

app.locals.server_url = 'http://localhost:3000'

# setup
app.set 'view engine', 'ejs'

# route
app.use express.static(__dirname + '/public')

app.get '/', (req, res)->
  res.redirect '/remote'

app.get '/player', (req, res)->
  res.render 'player'

app.get '/remote', (req, res)->
  res.render 'remote'


# socket.io
io.sockets.on 'connection', (jb)->
  console.log "socket.io connected"

  jb.on 'disconnect', ->
    console.log "socket.id disconnected"

  jb.on 'remote_play', ->
    console.log 'REMOTE: I resume play'

  jb.on 'remote_pause', ->
    console.log 'REMOTE: I pause the play'

  jb.on 'remote_mute', ->
    console.log 'REMOTE: I mute the volume'

  jb.on 'remote_forward', ->
    console.log 'REMOTE: I load next track'

  jb.on 'remote_backward', ->
    console.log 'REMOTE: I load previous track'

  jb.on 'remote_vol_up', ->
    console.log 'REMOTE: I increase volume'

  jb.on 'remote_vol_down', ->
    console.log 'REMOTE: I decrease volume'




create_playlist = ->
  console.log "Playlist being created."
  r_readdir music_dir, (err, files)->
    filtered_files = []
    filtered_files.push(encodeURIComponent('http://localhot:8080/'+f.substr(music_dir.length))) for f in files when f.substr(-5) isnt '.flac'
    app.locals.music_files = filtered_files
    console.log "Playlist now has #{filtered_files.length} items."

# start server
server.listen 3000, ->
  console.log "Listening on port #{server.address().port}"
  create_playlist()
  true
