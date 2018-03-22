require 'spec_helper'
require 'capistrano/notifier/helpers/mail'

describe Capistrano::Notifier::Helpers::Mail do
  let(:configuration) { Capistrano::Configuration.new }
  let(:dummy_class) { configuration.extend(Capistrano::Notifier::Helpers::Mail) }

  before do
    dummy_class.set(:notifier_mail_options, {})
  end

  describe "#application" do
    before { dummy_class.set(:application, "testapp") }

    it "fetches :application from Capistrano configuration" do
      expect(dummy_class.application).to eq("testapp")
    end
  end

  describe "#branch" do
    context "when :branch is set in Capistrano configuration" do
      before { dummy_class.set(:branch, "dev") }

      it "fetches :branch from Capistrano configuration" do
        expect(dummy_class.branch).to eq("dev")
      end
    end

    context "when :branch is not set in Capistrano configuration" do
      it "returns 'master'" do
        expect(dummy_class.branch).to eq("master")
      end
    end
  end

  describe "#git_current_revision" do
    before { dummy_class.set(:current_revision, "949af5c") }

    it "fetches :current_revision from Capistrano configuration" do
      expect(dummy_class.git_current_revision).to eq("949af5c")
    end
  end

  describe "#git_previous_revision" do
    before { dummy_class.set(:previous_revision, "949af5c") }

    it "fetches :previous_revision from Capistrano configuration" do
      expect(dummy_class.git_previous_revision).to eq("949af5c")
    end
  end

  describe "#git_range" do
    context "when :current_revision and :previous_revision are set" do
      before do
        dummy_class.set(:current_revision, "949af5c")
        dummy_class.set(:previous_revision, "0469d2d")
      end

      it "returns revisions range in git log format" do
        expect(dummy_class.git_range).to eq("0469d2d..949af5c")
      end
    end

    context "when :current_revision and :previous_revision are empty" do
      it { expect(dummy_class.git_range).to eq(nil) }
    end
  end

  describe "#git_log_command" do
    before do
      dummy_class.set(:notifier_mail_options, { log_command: "my command" })
    end

    it "fetches :log_command from :notifier_mail_options in Capistrano configuration" do
      expect(dummy_class.git_log_command).to eq("my command")
    end
  end

  describe "#git_log" do
    before { allow(dummy_class).to receive(:git_range) { "0469d2d..949af5c" } }

    context "when #git_range returns nil" do
      before { allow(dummy_class).to receive(:git_range) { nil } }

      it { expect(dummy_class.git_log).to eq(nil) }
    end

    context "when :log_command is set" do
      before do
        dummy_class.set(:notifier_mail_options, { log_command: "my command" })
      end

      it "runs system call with custom command" do
        expect(dummy_class).to receive(:system_call).with("my command")
        dummy_class.git_log
      end
    end

    context "when :log_command not set" do
      before { allow(dummy_class).to receive(:git_log_command) { nil } }

      it "runs system call with deafult command" do
        expect(dummy_class)
          .to receive(:system_call)
          .with('git log #{git_range} --no-merges --format=format:"%h %s (%an)"')

        dummy_class.git_log
      end
    end
  end

  describe "#now" do
    it "returns instance of Time.now" do
      expect(Time).to receive(:now)
      dummy_class.now
    end
  end

  describe "#stage" do
    before { dummy_class.set(:stage, "test") }

    it "fetches :stage from Capistrano configuration" do
      expect(dummy_class.stage).to eq("test")
    end
  end

  describe "#user_name" do
    context "when ENV['DEPLOYER'] is set" do
      before do
        allow(ENV).to receive(:[]).with("DEPLOYER") { "me" }
      end

       it { expect(dummy_class.user_name).to eq("me") }
    end

    context "when ENV['DEPLOYER'] not set" do
      it "runs 'git config --get user.name'" do
        expect(dummy_class)
          .to receive(:system_call).with("git config --get user.name")
          .and_return("")
        dummy_class.user_name
      end
    end
  end

  describe "#notifier_mail_options" do
    it "fetches :notifier_mail_options from Capistrano configuration" do
      expect(dummy_class.notifier_mail_options).to eq({})
    end
  end

  describe "#email_format" do
    it "deafults to :text" do
      expect(dummy_class.email_format).to eq(:text)
    end

    context "when set in :notifier_mail_options" do
      before { dummy_class.set(:notifier_mail_options, { format: :plain }) }

      it "works" do
        expect(dummy_class.email_format).to eq(:plain)
      end
    end
  end

  describe "#email_template" do
    it "deafults to 'mail.text.erb'" do
      expect(dummy_class.email_template).to eq("mail.text.erb")
    end

    context "when set in :notifier_mail_options" do
      before { dummy_class.set(:notifier_mail_options, { template: "mail.erb" }) }

      it "works" do
        expect(dummy_class.email_template).to eq("mail.erb")
      end
    end
  end

  describe "#email_from" do
    before { dummy_class.set(:notifier_mail_options, { from: "test" }) }

    it "works" do
      expect(dummy_class.email_from).to eq("test")
    end
  end

  describe "#github" do
    before { dummy_class.set(:notifier_mail_options, { github: "test" }) }

    it "works" do
      expect(dummy_class.github).to eq("test")
    end
  end

  describe "#giturl" do
    before { dummy_class.set(:notifier_mail_options, { giturl: "test" }) }

    it "works" do
      expect(dummy_class.giturl).to eq("test")
    end
  end

  describe "#git_prefix" do
    before do
      allow(dummy_class).to receive(:giturl) { "http://giturl" }
    end

    it "deafults to #giturl" do
      expect(dummy_class.git_prefix).to eq("http://giturl")
    end

    context "when :notifier_mail_options not set" do
      before do
        allow(dummy_class).to receive(:giturl)
      end

      it "works" do
        expect(dummy_class.git_prefix).to eq("https://github.com/")
      end
    end
  end

  describe "#git_commit_prefix" do
    before do
      allow(dummy_class).to receive(:git_prefix)
    end

    it "works" do
      expect(dummy_class.git_commit_prefix).to eq("/commit")
    end
  end

  describe "#git_compare_prefix" do
    before do
      allow(dummy_class).to receive(:git_prefix)
    end

    it "works" do
      expect(dummy_class.git_compare_prefix).to eq("/compare")
    end
  end

  describe "#delivery_method" do
    before { dummy_class.set(:notifier_mail_options, { method: "test" }) }

    it "works" do
      expect(dummy_class.delivery_method).to eq("test")
    end
  end

  describe "#notifier_smtp_settings" do
    before { dummy_class.set(:notifier_mail_options, { smtp_settings: "test" }) }

    it "works" do
      expect(dummy_class.notifier_smtp_settings).to eq("test")
    end
  end

  describe "#email_text" do
    let(:templates_path) do
      File.expand_path(File.join(__FILE__, '..','..','..','..','..','fixtures','templates'))
    end

    before do
      allow(dummy_class).to receive(:templates_path) { templates_path }
      allow(dummy_class).to receive(:application) { "testapp" }
      allow(dummy_class).to receive(:github) { "applicaster/capistrano3-notifier" }
      allow(dummy_class).to receive(:github_range) { "0469d2d...949af5c" }
    end

    it "renders email template" do
      expect(dummy_class.email_text).to eq(
        "Application:  testapp\n\nCompare:\n"\
        "https://github.com/applicaster/capistrano3-notifier/compare/0469d2d...949af5c\n"
      )
    end
  end

  describe "#email_subject" do
    before do
      allow(dummy_class).to receive(:application) { "testapp" }
      allow(dummy_class).to receive(:branch) { "testbranch" }
      allow(dummy_class).to receive(:stage) { "teststage" }
    end

    it "defaults to '#application branch #branch deployed to #stage'" do
      expect(dummy_class.email_subject).to eq("testapp branch testbranch deployed to teststage")
    end

    it "can be set via :notifier_mail_options" do
      dummy_class.set(:notifier_mail_options, { subject: "test subject" })
      expect(dummy_class.email_subject).to eq("test subject")
    end
  end

  describe "#templates_path" do
    it "defaults to 'config/deploy/templates'" do
      expect(dummy_class.templates_path).to eq("config/deploy/templates")
    end

    it "can be set via :notifier_mail_options" do
      dummy_class.set(:notifier_mail_options, { templates_path: "templates" })
      expect(dummy_class.templates_path).to eq("templates")
    end
  end

  describe "#email_to" do
    before { dummy_class.set(:notifier_mail_options, { to: "test" }) }

    it "works" do
      expect(dummy_class.email_to).to eq("test")
    end
  end

  describe "#content_type_for_format" do
    it "defaults to 'text/plain'" do
      expect(dummy_class.content_type_for_format).to eq("text/plain")
    end

    it "returns 'text/html' if :html is passed as option" do
      expect(dummy_class.content_type_for_format(:html)).to eq("text/html")
    end
  end
end
