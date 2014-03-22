// Generated by CoffeeScript 1.7.1
(function() {
  $(document).ready(function() {
    var Remote, r;
    Remote = (function() {
      function Remote() {
        this.server = io.connect(window.server_url);
        this.button_play_pause = $('#button_play_pause');
        this.button_step_backward = $('#button_step_backward');
        this.button_step_forward = $('#button_step_forward');
        this.button_volume_down = $('#button_volume_down');
        this.button_mute = $('#button_mute');
        this.button_volume_up = $('#button_volume_up');
        this.progress_playtime = $('#progress_playtime');
        this.alert_socket_connect = $('#alert_socket_connect');
        this.alert_socket_disconnect = $('#alert_socket_disconnect');
        this.jq_events();
        this.socket_events();
      }

      Remote.prototype.disable_interface = function(disabled) {
        var b, _i, _len, _ref, _results;
        if (disabled == null) {
          disabled = true;
        }
        _ref = [this.button_play_pause, this.button_step_backward, this.button_step_forward, this.button_volume_down, this.button_mute, this.button_volume_up];
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          b = _ref[_i];
          _results.push($(b).prop('disabled', disabled));
        }
        return _results;
      };

      Remote.prototype.jq_events = function() {
        this.button_play_pause.on('click', (function(_this) {
          return function(event) {
            if ($(event.currentTarget).hasClass('btn-warning')) {
              _this.play();
              return true;
            }
            if ($(event.currentTarget).hasClass('btn-primary')) {
              _this.pause();
              return true;
            }
          };
        })(this));
        this.button_mute.on('click', (function(_this) {
          return function(event) {
            if ($(event.currentTarget).hasClass('btn-warning')) {
              _this.unmute();
              return true;
            }
            if ($(event.currentTarget).hasClass('btn-primary')) {
              _this.mute();
              return true;
            }
          };
        })(this));
        this.button_volume_up.on('click', (function(_this) {
          return function(event) {
            _this.change_mute_button_to_mute();
            return _this.server.emit('remote_vol_up');
          };
        })(this));
        return this.button_volume_down.on('click', (function(_this) {
          return function(event) {
            return _this.server.emit('remote_vol_down');
          };
        })(this));
      };

      Remote.prototype.socket_events = function() {
        this.server.on('connect', (function(_this) {
          return function() {
            _this.server.emit('iam', 'remote');
            _this.alert_socket_disconnect.addClass('hidden');
            _this.alert_socket_connect.removeClass('hidden');
            return _this.disable_interface(false);
          };
        })(this));
        return this.server.on('disconnect', (function(_this) {
          return function() {
            _this.alert_socket_connect.addClass('hidden');
            _this.alert_socket_disconnect.removeClass('hidden');
            return _this.disable_interface();
          };
        })(this));
      };

      Remote.prototype.play = function() {
        this.server.emit('remote_play');
        return this.button_play_pause.removeClass('btn-warning').addClass('btn-primary').find('span.glyphicon').removeClass('glyphicon-play').addClass('glyphicon-pause').end().find('span.inner_text').html('Pause');
      };

      Remote.prototype.pause = function() {
        this.server.emit('remote_pause');
        return this.button_play_pause.removeClass('btn-primary').addClass('btn-warning').find('span.glyphicon').removeClass('glyphicon-pause').addClass('glyphicon-play').end().find('span.inner_text').html('Play');
      };

      Remote.prototype.change_mute_button_to_mute = function() {
        return this.button_mute.removeClass('btn-warning').addClass('btn-primary').find('span.glyphicon').removeClass('glyphicon-music').addClass('glyphicon-volume-off').end().find('span.inner_text').html('Mute');
      };

      Remote.prototype.mute = function() {
        this.server.emit('remote_mute');
        return this.button_mute.removeClass('btn-primary').addClass('btn-warning').find('span.glyphicon').removeClass('glyphicon-volume-off').addClass('glyphicon-music').end().find('span.inner_text').html('Unmute');
      };

      Remote.prototype.unmute = function() {
        this.server.emit('remote_unmute');
        return this.change_mute_button_to_mute();
      };

      return Remote;

    })();
    return r = new Remote();
  });

}).call(this);

//# sourceMappingURL=remote.map
