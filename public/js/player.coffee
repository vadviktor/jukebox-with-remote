$(document).ready ->
  class Player

    constructor: ->
      @player = $('#player')
      @server = io.connect window.server_url

      # load firt file
      console.log 'Loading first song into jukebox'
      $(@player).attr 'src', window.music_files[0]

      @socket_events()
      @jb_events()

    setIntervalWithContext: (code,delay,context)->
      setInterval ->
        code.call context
      , delay

    volume_up: ->
      new_vol = ((@player[0].volume*100)+5)/100
      @player[0].volume = if new_vol <= 1 then new_vol else 1
      @riport_current_volume(@player[0].volume)

    volume_down: ->
      new_vol = ((@player[0].volume*100)-5)/100
      @player[0].volume = if new_vol >= 0 then new_vol else 0
      @riport_current_volume(@player[0].volume)

    volume_mute: ->
      @volume_state = @player[0].volume
      @player[0].volume = 0
      @riport_current_volume(@player[0].volume)

    volume_unmute: ->
      @player[0].volume = @volume_state ?= 0.1
      @riport_current_volume(@player[0].volume)

    riport_current_volume: (vol)->
      @server.emit 'player_riport_volume', {volume: (vol*100).toFixed()}

    stop_playtime_riporter: ->
      clearInterval(@current_playtime_riporter)
      @current_playtime_riporter = null

    socket_events: ->
      @server.on 'connect', =>
        @server.emit 'iam', 'player'

      @server.on 'play', =>
        console.log 'PLAYER: I start playing'
        @player[0].play()
        @current_playtime_riporter = @setIntervalWithContext ->
          @server.emit 'player_riport_playtime', {
            duration: @player[0].duration,
            currentTime: @player[0].currentTime
          }
        , 1000, @

      @server.on 'pause', =>
        console.log 'PLAYER: I pause playing'
        @player[0].pause()
        @stop_playtime_riporter()

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

    jb_events: ->
      @player.on 'ended', (event)=>
        @stop_playtime_riporter()

  p = new Player()