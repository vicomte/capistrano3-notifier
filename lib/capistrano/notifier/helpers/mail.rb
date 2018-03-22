module Capistrano
  module Notifier
    module Helpers
      module Mail
        def application
          fetch :application
        end

        def branch
          fetch(:branch, "master")
        end

        def git_current_revision
          fetch :current_revision
        end

        def git_previous_revision
          fetch :previous_revision
        end

        def git_range(ranger = "..")
          return unless git_previous_revision && git_current_revision
          "#{git_previous_revision}#{ranger}#{git_current_revision}"
        end

        def github_range
          git_range("...")
        end

        def git_log_command
          notifier_mail_options[:log_command]
        end

        def git_log
          return unless git_range
          command =
            git_log_command || 'git log #{git_range} --no-merges --format=format:"%h %s (%an)"'

          system_call(command)
        end

        def now
          @now ||= Time.now
        end

        def stage
          fetch :stage
        end

        def user_name
          ENV['DEPLOYER'] || system_call("git config --get user.name").strip
        end

        def notifier_mail_options
          @notifier_mail_options ||= fetch :notifier_mail_options
        end

        def email_format
          notifier_mail_options[:format] || :text
        end

        def email_template
          notifier_mail_options[:template] || "mail.#{email_format.to_s}.erb"
        end

        def email_from
          notifier_mail_options[:from]
        end

        def github
          notifier_mail_options[:github]
        end

        def giturl
          notifier_mail_options[:giturl]
        end

        def git_prefix
          giturl ? giturl : "https://github.com/#{github}"
        end

        def git_commit_prefix
          "#{git_prefix}/commit"
        end

        def git_compare_prefix
          "#{git_prefix}/compare"
        end

        def delivery_method
          notifier_mail_options[:method]
        end

        def notifier_smtp_settings
          notifier_mail_options[:smtp_settings]
        end

        def email_subject
          notifier_mail_options[:subject] ||
            "#{application} branch #{branch} deployed to #{stage}"
        end

        def render_template(template_name)
          config_file = "#{templates_path}/#{template_name}"

          unless File.exists?(config_file)
            config_file = File.join(File.dirname(__FILE__),'..', "templates/#{template_name}")
          end

          ERB.new(File.read(config_file), nil, '-').result(binding)
        end

        def templates_path
          notifier_mail_options[:templates_path] || 'config/deploy/templates'
        end

        def email_text
          render_template(email_template)
        end

        def email_to
          notifier_mail_options[:to]
        end

        def content_type_for_format(format = nil)
          format == :html ? 'text/html' : 'text/plain'
        end

        def system_call(command)
          `#{command}`
        end
      end
    end
  end
end
