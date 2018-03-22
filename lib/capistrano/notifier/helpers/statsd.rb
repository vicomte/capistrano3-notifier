module Capistrano
  module Notifier
    module Helpers
      module StatsD
        def application
          fetch :application
        end

        def stage
          fetch :stage
        end

        def notifier_statsd_options
          @notifier_statsd_options ||= fetch :notifier_statsd_options
        end

        def statsd_defaults
          { host: "127.0.0.1", port: "8125", with: :counter }
        end

        def statsd_host
          statsd_options[:host]
        end

        def statsd_options
          @statsd_options ||= if notifier_statsd_options
                                statsd_defaults.merge notifier_statsd_options
                              else
                                statsd_defaults
                              end
        end

        def statsd_packet
          "#{statsd_pattern}:#{statsd_with}".gsub('|', '\\|')
        end

        def statsd_pattern
          statsd_options.fetch(:pattern){ statsd_default_pattern }
        end

        def statsd_default_pattern
          if stage
            "#{application}.#{stage}.deploy"
          else
            "#{application}.deploy"
          end
        end

        def statsd_port
          statsd_options[:port]
        end

        def statsd_with
          case statsd_options[:with]
          when :counter
            "1|c"
          when :gauge
            "1|g"
          end
        end

        def statsd_notifier_command
          "echo -n #{statsd_packet} | nc -w 1 -u #{statsd_host} #{statsd_port}"
        end
      end
    end
  end
end
