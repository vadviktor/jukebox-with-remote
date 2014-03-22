$(document).ready ->
  class Player

    constructor: ->
      @player = $('#player')
      @server = io.connect window.server_url

      # load firt file
      console.log 'Loading first song into jukebox'
      $(@player).attr 'src', window.music_files[0]

      @socket_events()

    volume_up: ->
      new_vol = ((@player[0].volume*100)+5)/100
      @player[0].volume = if new_vol <= 1 then new_vol else 1

    volume_down: ->
      new_vol = ((@player[0].volume*100)-5)/100
      @player[0].volume = if new_vol >= 0 then new_vol else 0

    volume_mute: ->
      @volume_state = @player[0].volume
      @player[0].volume = 0

    volume_unmute: ->
      @player[0].volume = @volume_state ?= 0.1

    socket_events: ->
      @server.on 'connect', =>
        @server.emit 'iam', 'player'

      @server.on 'play', =>
        console.log 'PLAYER: I start playing'
        @player[0].play()

      @server.on 'pause', =>
        console.log 'PLAYER: I pause playing'
        @player[0].pause()

      @server.on 'vol_up', =>
        console.log 'PLAYER: I increase volume'
        @volume_up()

      @server.on 'vol_down', =>
        console.log 'PLAYER: I decrease volume'
        @volume_down()

      @server.on 'mute', =>
        console.log 'PLAYER: I mute volume'
        @volume_mute()

      @server.on 'unmute', =>
        console.log 'PLAYER: I unmute volume'
        @volume_unmute()


  p = new Player()