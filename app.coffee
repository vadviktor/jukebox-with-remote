fs = require 'fs'
r_readdir = require('recursive-readdir-filter')
express = require('express')
app = express()
server = require('http').createServer(app)
io = require('socket.io').listen(server)
settings = JSON.parse fs.readFileSync('settings.json', encoding="ascii")

logthis = (msg)->
  console.log "[>>> #{msg} <<<]"


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
player = ''
remote = ''

io.sockets.on 'connection', (socket)->
  logthis "socket.io connected"

  socket.on 'disconnect', ->
    player = '' if socket.id is player
    remote = '' if socket.id is remote
    logthis "#{socket.id} disconnected"
#    logthis "player is #{player}"
#    logthis "remote is #{remote}"

  socket.on 'iam', (me)->
    player = socket.id if me is 'player'
    remote = socket.id if me is 'remote'
    logthis "#{me} has just connected (#{socket.id})"
#    logthis "player is #{player}"
#    logthis "remote is #{remote}"

  socket.on 'remote_play', ->
    io.sockets.socket(player).emit 'play'
    logthis 'REMOTE: I resume play'

  socket.on 'remote_pause', ->
    io.sockets.socket(player).emit 'pause'
    logthis 'REMOTE: I pause the play'

  socket.on 'remote_mute', ->
    io.sockets.socket(player).emit 'mute'
    logthis 'REMOTE: I mute the volume'

  socket.on 'remote_unmute', ->
    io.sockets.socket(player).emit 'unmute'
    logthis 'REMOTE: I unmute the volume'

  socket.on 'remote_forward', ->
    io.sockets.socket(player).emit 'forward'
    logthis 'REMOTE: I load next track'

  socket.on 'remote_backward', ->
    io.sockets.socket(player).emit 'backward'
    logthis 'REMOTE: I load previous track'

  socket.on 'remote_vol_up', ->
    io.sockets.socket(player).emit 'vol_up'
    logthis 'REMOTE: I increase volume'

  socket.on 'remote_vol_down', ->
    io.sockets.socket(player).emit 'vol_down'
    logthis 'REMOTE: I decrease volume'



create_playlist = ->
  logthis "Playlist being created."
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
    logthis "Playlist now has #{filtered_files.length} items."

# start server
server.listen settings.host_port, ->
  logthis "Listening on port #{server.address().port}"
  create_playlist()
  true
