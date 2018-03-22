require 'action_mailer'
require 'capistrano/notifier/helpers/mail'
include Capistrano::Notifier::Helpers::Mail

namespace :deploy do
  namespace :notify do
    desc "Send a deployment notification via email."
    task :mail do
      run_locally do
        ActionMailer::Base.smtp_settings = notifier_smtp_settings
        ActionMailer::Base.mail({
          body: email_text,
          delivery_method: delivery_method,
          content_type: content_type_for_format(email_format),
          from: email_from,
          subject: email_subject,
          to: email_to
        }).deliver

        if delivery_method == :test
          puts ActionMailer::Base.deliveries
        end
      end
    end
  end
end

after "deploy:updated", "deploy:notify:mail"
