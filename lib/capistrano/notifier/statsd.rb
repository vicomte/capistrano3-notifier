require 'capistrano/notifier/helpers/statsd'
include Capistrano::Notifier::Helpers::StatsD

namespace :deploy do
  namespace :notify do
    desc "Notify StatsD of deploy."
    task :statsd do
      on roles(:app) do |host|
        execute statsd_notifier_command
      end
    end
  end
end

after "deploy:updated", "deploy:notify:statsd"
