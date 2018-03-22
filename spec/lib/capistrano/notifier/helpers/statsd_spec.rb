require 'spec_helper'
require 'capistrano/notifier/helpers/statsd'

describe Capistrano::Notifier::Helpers::StatsD do
  let(:configuration) { Capistrano::Configuration.new }
  let(:dummy_class) { configuration.extend(Capistrano::Notifier::Helpers::StatsD) }

  before do
    dummy_class.set(:application, "test-app")
    dummy_class.set(:stage, "test-stage")
    dummy_class.set(:notifier_statsd_options, {})
  end

  describe "#statsd_notifier_command" do
    it "works" do
      expect(dummy_class.statsd_notifier_command)
        .to eq("echo -n test-app.test-stage.deploy:1\\|c | nc -w 1 -u 127.0.0.1 8125")
    end
  end
 end
