$(document).ready ->

  class Remote

    constructor: ->
      @server = io.connect window.server_url
      @button_play_pause = $('#button_play_pause')
      @button_step_backward = $('#button_step_backward')
      @button_step_forward = $('#button_step_forward')
      @button_volume_down = $('#button_volume_down')
      @button_mute = $('#button_mute')
      @button_volume_up = $('#button_volume_up')
      @progress_playtime = $('#progress_playtime')
      @alert_socket_connect = $('#alert_socket_connect')
      @alert_socket_disconnect = $('#alert_socket_disconnect')

      @jq_events()
      @socket_events()


    disable_interface: (disabled = true)->
      $(b).prop 'disabled', disabled for b in [
        @button_play_pause,
        @button_step_backward,
        @button_step_forward,
        @button_volume_down,
        @button_mute,
        @button_volume_up
      ]

    jq_events: ->
      @button_play_pause.on 'click', (event)=>
        # TODO get better conditions
        if $(event.currentTarget).hasClass 'btn-warning'
          @play()
          return true

        if $(event.currentTarget).hasClass 'btn-primary'
          @pause()
          return true

      @button_mute.on 'click', (event)=>
        # TODO get better conditions
        if $(event.currentTarget).hasClass 'btn-warning'
          @unmute()
          return true

        if $(event.currentTarget).hasClass 'btn-primary'
          @mute()
          return true

      @button_volume_up.on 'click', (event)=>
        @change_mute_button_to_mute()
        @server.emit 'remote_vol_up'

      @button_volume_down.on 'click', (event)=>
        @server.emit 'remote_vol_down'

    socket_events: ->
      @server.on 'connect', =>
        @server.emit 'iam', 'remote'
        @alert_socket_disconnect.addClass 'hidden'
        @alert_socket_connect.removeClass 'hidden'
        @disable_interface(false)

      @server.on 'disconnect', =>
        @alert_socket_connect.addClass 'hidden'
        @alert_socket_disconnect.removeClass 'hidden'
        @disable_interface()


    play: ->
      # emit player action
      @server.emit 'remote_play'
      # change button
      @button_play_pause
        .removeClass 'btn-warning'
        .addClass 'btn-primary'
        .find 'span.glyphicon'
        .removeClass 'glyphicon-play'
        .addClass 'glyphicon-pause'
        .end()
        .find 'span.inner_text'
        .html 'Pause'

    pause: ->
      # emit player action
      @server.emit 'remote_pause'
      # change button
      @button_play_pause
        .removeClass 'btn-primary'
        .addClass 'btn-warning'
        .find 'span.glyphicon'
        .removeClass 'glyphicon-pause'
        .addClass 'glyphicon-play'
        .end()
        .find 'span.inner_text'
        .html 'Play'

    change_mute_button_to_mute: ->
      @button_mute
        .removeClass 'btn-warning'
        .addClass 'btn-primary'
        .find 'span.glyphicon'
        .removeClass 'glyphicon-music'
        .addClass 'glyphicon-volume-off'
        .end()
        .find 'span.inner_text'
        .html 'Mute'

    mute: ->
      # emit player action
      @server.emit 'remote_mute'
      # change button
      @button_mute
        .removeClass 'btn-primary'
        .addClass 'btn-warning'
        .find 'span.glyphicon'
        .removeClass 'glyphicon-volume-off'
        .addClass 'glyphicon-music'
        .end()
        .find 'span.inner_text'
        .html 'Unmute'

    unmute: ->
      # emit player action
      @server.emit 'remote_unmute'
      # change button
      @change_mute_button_to_mute()

  r = new Remote()