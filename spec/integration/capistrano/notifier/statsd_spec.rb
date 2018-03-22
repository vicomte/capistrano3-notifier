require 'spec_helper'
require 'capistrano/setup'
require 'capistrano/deploy'
require 'capistrano/notifier/statsd'

describe "deploy:notify:statsd" do
  before do
    Capistrano::Configuration.reset!.tap do |cfg|
      cfg.set :application, "test-app"
      cfg.set :stage, "test-stage"
      cfg.set :notifier_statsd_options, {
        host: "10.0.0.1",
        port: "8125"
      }
    end
  end

  it "works" do
    Rake::Task["deploy:notify:statsd"].invoke
  end
end
