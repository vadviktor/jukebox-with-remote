$(document).ready ->
  class Jukebox

    constructor: ->
      @jukebox = $('#jukebox')
      @server = io.connect window.server_url

      # load firt file
      console.log 'Loading first song into jukebox'
      $(@jukebox).attr('src', window.music_files[0])


  jb = new Jukebox()