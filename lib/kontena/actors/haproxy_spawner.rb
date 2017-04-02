
module Kontena::Actors
  class HaproxySpawner < Concurrent::Actor::RestartingContext
    include Kontena::Logging

    ##
    # @param [String] config_file
    def initialize(haproxy_bin = '/usr/sbin/haproxy', config_file = '/etc/haproxy/haproxy.cfg')
      @current_pid = nil
      @haproxy_cmd = [haproxy_bin, '-f', config_file, '-db']
      @validate_cmd = [haproxy_bin, '-c -f', config_file]
    end

    def on_message(msg)
      case msg.action
      when :update
        update_haproxy
      else
        pass
      end
    end

    def update_haproxy
      if validate_config
        if current_pid
          reload_haproxy
        else
          start_haproxy
        end
      end
    end

    def start_haproxy
      info 'Starting HAProxy process'
      @current_pid = Process.spawn(@haproxy_cmd.join(' '))
    end

    def validate_config
      system(@validate_cmd) == 0
    end

    def reload_haproxy
      info 'Reloading HAProxy'
      reload_cmd = @haproxy_cmd + ['-sf', @current_pid.to_s]
      pid = Process.spawn(reload_cmd.join(' '))
      Process.wait(@current_pid)
      @current_pid = pid
    end

    def on_event(event)
      info "on event: #{event}"
    end

    private

    def current_pid
      @current_pid
    end
  end
end
