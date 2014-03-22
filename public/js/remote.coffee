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

    on_connect: ->
      @alert_socket_disconnect.addClass 'hidden'
      @alert_socket_connect.removeClass 'hidden'
      @disable_interface(false)

    on_disconnect: ->
      @alert_socket_connect.addClass 'hidden'
      @alert_socket_disconnect.removeClass 'hidden'
      @disable_interface()

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
        #todo get better conditions
        if $(event.currentTarget).hasClass 'btn-warning'
          @play()
          return true

        if $(event.currentTarget).hasClass 'btn-primary'
          @pause()
          return true

    socket_events: ->
      @server.on 'connect', =>
        @on_connect()

      @server.on 'disconnect', =>
        @on_disconnect()


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
      # change progress bar
      # todo

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

  r = new Remote()