$(document).ready ->
  class Player

    constructor: ->
      @server = io.connect window.server_url
      # audio player element
      @player = $('#player')[0]
      # music files array key
      @currently_playing_id = 0

      @socket_events()
      @jb_events()

      # load first file
      console.log 'Loading first song into jukebox'
      @player.src = window.music_files[@currently_playing_id]


    setIntervalWithContext: (code,delay,context)->
      setInterval ->
        code.call context
      , delay

    volume_up: ->
      new_vol = ((@player.volume*100)+5)/100
      @player.volume = if new_vol <= 1 then new_vol else 1
      @riport_current_volume(@player.volume)

    volume_down: ->
      new_vol = ((@player.volume*100)-5)/100
      @player.volume = if new_vol >= 0 then new_vol else 0
      @riport_current_volume(@player.volume)

    volume_mute: ->
      @volume_state = @player.volume
      @player.volume = 0
      @riport_current_volume(@player.volume)

    volume_unmute: ->
      @player.volume = @volume_state ?= 0.1
      @riport_current_volume(@player.volume)

    riport_current_volume: (vol)->
      @server.emit 'player_riport_volume', {volume: (vol*100).toFixed()}

    stop_playtime_riporter: ->
      clearInterval(@current_playtime_riporter)
      @current_playtime_riporter = null

    start_playtime_riporter: ->
      @current_playtime_riporter = @setIntervalWithContext ->
        @server.emit 'player_riport_playtime', {
          duration: @player.duration,
          currentTime: @player.currentTime
        }
      , 1000, @

    socket_events: ->
      @server.on 'connect', =>
        @server.emit 'iam', 'player'

      @server.on 'full_status', =>
        @server.emit 'player_full_status', {
          duration: @player.duration,
          currentTime: @player.currentTime,
          volume: (@player.volume*100).toFixed(),
          is_paused: @player.paused,
          src: @player.src
        }

      @server.on 'play', =>
        console.log 'PLAYER: I start playing'
        @player.play()
        @start_playtime_riporter()

      @server.on 'pause', =>
        console.log 'PLAYER: I pause playing'
        @player.pause()
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

      @server.on 'forward', =>
        console.log 'PLAYER: I select next file'
        # check if being played
        is_paused = @player.paused
        # stop play if playing
        @player.pause() unless is_paused
        @stop_playtime_riporter()
        # load new file
#        @player.src = window.music_files[++@currently_playing_id]
        @player.src = window.music_files[Math.floor(Math.random()*window.music_files.length)] # random for now
        # play if was playing
        @player.play() unless is_paused
        @start_playtime_riporter()

      @server.on 'backward', =>
        console.log 'PLAYER: I select previous file'
        # check if being played
        is_paused = @player.paused
        # stop play if playing
        @player.pause() unless is_paused
        @stop_playtime_riporter()
        # load new file
#        @player.src = window.music_files[--@currently_playing_id]
        @player.src = window.music_files[Math.floor(Math.random()*window.music_files.length)] # random for now
        # play if was playing
        @player.play() unless is_paused
        @start_playtime_riporter()

    jb_events: ->
      $(@player).on 'ended', (event)=>
        @stop_playtime_riporter()
        @player.src = window.music_files[Math.floor(Math.random()*window.music_files.length)] # random for now
        @player.play()
        @start_playtime_riporter()

  p = new Player()