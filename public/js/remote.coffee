$(document).ready ->
  button_play_pause = $('#button_play_pause')

  server = io.connect window.server_url

  $(button_play_pause).on 'click', (event)->
    server.emit 'remote_play'
