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
      @progress_playtime_current = $('#progress_playtime_current')
      @progress_playtime_remaining = $('#progress_playtime_remaining')
      @progress_volume = $('#progress_volume')
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

    seconds2time: (seconds)->
      hours = Math.floor(seconds / 3600)
      minutes = Math.floor((seconds - (hours * 3600)) / 60)
      seconds = seconds - (hours * 3600) - (minutes * 60)
      time = "";

      time = "#{hours}:" if hours isnt 0

      if minutes isnt 0 or time isnt ""
        minutes =  if minutes < 10 and time isnt "" then "0#{minutes}" else String(minutes)
        time += "#{minutes}:"

      if time is ""
        time = "#{seconds}s"
      else
        time += if seconds < 10 then "0#{seconds}" else String(seconds)

      time

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

      @server.on 'player_riport_volume', (data)=>
        @progress_volume
          .find('.progress-bar')
          .attr('aria-valuenow', data.volume)
          .css('width', "#{data.volume}%")
          .html("#{data.volume}%")

      @server.on 'player_riport_playtime', (data)=>
        playtime_percent = ((data.currentTime / data.duration) * 100).toFixed()
        played = @seconds2time data.currentTime.toFixed()
        remaining = @seconds2time data.duration.toFixed() - data.currentTime.toFixed() # TODO CPU can be saved
        @progress_playtime_current
          .attr('aria-valuenow', playtime_percent)
          .css('width', "#{playtime_percent}%")
          .html("#{played}")
        @progress_playtime_remaining
          .attr('aria-valuenow', 100 - playtime_percent)
          .css('width', "#{100 - playtime_percent}%")
          .html("-#{remaining}")

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