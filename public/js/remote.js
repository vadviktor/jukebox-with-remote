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

      Remote.prototype.on_connect = function() {
        this.alert_socket_disconnect.addClass('hidden');
        this.alert_socket_connect.removeClass('hidden');
        return this.disable_interface(false);
      };

      Remote.prototype.on_disconnect = function() {
        this.alert_socket_connect.addClass('hidden');
        this.alert_socket_disconnect.removeClass('hidden');
        return this.disable_interface();
      };

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
        return this.button_play_pause.on('click', (function(_this) {
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
      };

      Remote.prototype.socket_events = function() {
        this.server.on('connect', (function(_this) {
          return function() {
            return _this.on_connect();
          };
        })(this));
        return this.server.on('disconnect', (function(_this) {
          return function() {
            return _this.on_disconnect();
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

      return Remote;

    })();
    return r = new Remote();
  });

}).call(this);

//# sourceMappingURL=remote.map
