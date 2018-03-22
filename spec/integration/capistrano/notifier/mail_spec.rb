require 'spec_helper'
require 'capistrano/setup'
require 'capistrano/deploy'
require 'capistrano/notifier/mail'

describe "deploy:notify:mail" do
  before do
    Capistrano::Configuration.reset!.tap do |cfg|
      cfg.set :application, "test-app"
      cfg.set :stage, "test-stage"
      cfg.set :notifier_mail_options, {
        method:  :test,
        from:    '"Deploy Notification" <deploy@example.com>',
        to:      ['deploy+test-app@example.com'],
        github:  'applicaster/test-app',
      }
    end
  end

  it "works" do
    Rake::Task["deploy:notify:mail"].invoke
    expect(ActionMailer::Base.deliveries.first.subject)
      .to eq("test-app branch master deployed to test-stage")
  end
end
