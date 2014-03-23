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

      @button_step_forward.on 'click', (event)=>
        @server.emit 'remote_forward'

      @button_step_backward.on 'click', (event)=>
        @server.emit 'remote_backward'

    socket_events: ->
      @server.on 'connect', =>
        @server.emit 'iam', 'remote'
        @alert_socket_disconnect.addClass 'hidden'
        @alert_socket_connect.removeClass 'hidden'
        @disable_interface(false)

      @server.on 'player_full_status', (data)=>
        if data.is_paused then @change_play_button_to_play() else @change_play_button_to_pause()
        if data.volume is 0 then @change_mute_button_to_unmute() else @change_mute_button_to_mute()
        @update_volume_progressbar data.volume
        @update_playtime_progressbar data.currentTime, data.duration
        $('#currently_playing').html decodeURIComponent(data.src)

      @server.on 'disconnect', =>
        @alert_socket_connect.addClass 'hidden'
        @alert_socket_disconnect.removeClass 'hidden'
        @disable_interface()

      @server.on 'player_riport_volume', (data)=>
        @update_volume_progressbar data.volume

      @server.on 'player_riport_playtime', (data)=>
        @update_playtime_progressbar data.currentTime, data.duration

    update_playtime_progressbar: (current, duration)->
      unless duration is null
        playtime_percent = ((current / duration) * 100).toFixed()
        played = @seconds2time current.toFixed()
        remaining = @seconds2time duration.toFixed() - current.toFixed() # TODO CPU can be saved
      else
        playtime_percent = played = remaining = 0

      @progress_playtime_current
        .attr 'aria-valuenow', playtime_percent
        .css 'width', "#{playtime_percent}%"
        .html "#{played}"
      @progress_playtime_remaining
        .attr 'aria-valuenow', 100 - playtime_percent
        .css 'width', "#{100 - playtime_percent}%"
        .html "-#{remaining}"

    update_volume_progressbar: (vol)->
      @progress_volume
        .find '.progress-bar'
        .attr 'aria-valuenow', vol
        .css 'width', "#{vol}%"
        .html "#{vol}%"

    change_play_button_to_play: ->
      @button_play_pause
        .removeClass 'btn-primary'
        .addClass 'btn-warning'
        .find 'span.glyphicon'
        .removeClass 'glyphicon-pause'
        .addClass 'glyphicon-play'

    change_play_button_to_pause: ->
      @button_play_pause
        .removeClass 'btn-warning'
        .addClass 'btn-primary'
        .find 'span.glyphicon'
        .removeClass 'glyphicon-play'
        .addClass 'glyphicon-pause'

    play: ->
      # emit player action
      @server.emit 'remote_play'
      # change button
      @change_play_button_to_pause()

    pause: ->
      # emit player action
      @server.emit 'remote_pause'
      # change button
      @change_play_button_to_play()

    change_mute_button_to_mute: ->
      @button_mute
        .removeClass 'btn-warning'
        .addClass 'btn-primary'
        .find 'span.glyphicon'
        .removeClass 'glyphicon-music'
        .addClass 'glyphicon-volume-off'

    change_mute_button_to_unmute: ->
      @button_mute
        .removeClass 'btn-primary'
        .addClass 'btn-warning'
        .find 'span.glyphicon'
        .removeClass 'glyphicon-volume-off'
        .addClass 'glyphicon-music'

    mute: ->
      # emit player action
      @server.emit 'remote_mute'
      # change button
      @change_mute_button_to_unmute()

    unmute: ->
      # emit player action
      @server.emit 'remote_unmute'
      # change button
      @change_mute_button_to_mute()

  r = new Remote()