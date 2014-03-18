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
      @enable_interface()

    on_disconnect: ->
      @alert_socket_connect.addClass 'hidden'
      @alert_socket_disconnect.removeClass 'hidden'
      @disable_interface()

    disable_interface: ->
      @button_play_pause.addClass 'disabled'
      @button_step_backward.addClass 'disabled'
      @button_step_forward.addClass 'disabled'
      @button_volume_down.addClass 'disabled'
      @button_mute.addClass 'disabled'
      @button_volume_up.addClass 'disabled'

    enable_interface: ->
      @button_play_pause.removeClass 'disabled'
      @button_step_backward.removeClass 'disabled'
      @button_step_forward.removeClass 'disabled'
      @button_volume_down.removeClass 'disabled'
      @button_mute.removeClass 'disabled'
      @button_volume_up.removeClass 'disabled'

    jq_events: ->
      @button_play_pause.on 'click', (event)=>
        @play() if $(event.currentTarget).hasClass 'btn-warning'

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


  remote = new Remote()