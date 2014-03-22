$(document).ready ->
  class Player

    constructor: ->
      @player = $('#player')
      @server = io.connect window.server_url

      # load firt file
      console.log 'Loading first song into jukebox'
      $(@player).attr 'src', window.music_files[0]

      @socket_events()


    socket_events: ->
#      @server.on 'connect', =>
#        @on_connect()
#
#      @server.on 'disconnect', =>
#        @on_disconnect()

      @server.on 'player_play', =>
        console.log 'PLAYER: I start playing'
        @player[0].play()

      @server.on 'player_pause', =>
        console.log 'PLAYER: I pause playing'
        @player[0].pause()

  p = new Player()