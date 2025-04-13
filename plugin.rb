# frozen_string_literal: true

# name: discourse-preferred-language-on-setup
# about: Automatically sets a user's interface language based on a custom user field completed during signup.
# meta_topic_id: 0
# version: 0.0.1
# authors: Lincken
# url: https://github.com/Cyanolinck/discourse-preferred-language-on-setup
# required_version: 2.7.0

enabled_site_setting :preferred_language_on_setup_enabled

after_initialize do
  on(:user_created) do |user|
    begin
      # Adjust the name below to match your actual custom user field name
      field = UserField.find_by(name: "språk")
      next unless field

      value = UserCustomField.find_by(
        user_id: user.id,
        name: "user_field_#{field.id}"
      )&.value

      next if value.blank?

      locale_map = {
        "English" => "en",
        "Swedish" => "sv",
        "Engelska" => "en",
        "Svenska" => "sv"
      }

      if locale_map[value]
        user.locale = locale_map[value]
        user.save!
        Rails.logger.info "[preferred-language-on-setup] Set locale '#{user.locale}' for user '#{user.username}'"
      else
        Rails.logger.warn "[preferred-language-on-setup] No locale match for '#{value}'"
      end
    rescue => e
      Rails.logger.error "[preferred-language-on-setup] Failed to set locale for user #{user.username}: #{e.message}"
    end
  end
end
