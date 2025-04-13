# frozen_string_literal: true

# name: discourse-preferred-language-on-setup
# about: Automatically sets a user's interface language based on a custom user field completed during signup.
# meta_topic_id: 0
# version: 0.0.3
# authors: Lincken
# url: https://github.com/Cyanolinck/discourse-preferred-language-on-setup
# required_version: 2.7.0

require "yaml"

enabled_site_setting :preferred_language_on_setup_enabled

after_initialize do
  if SiteSetting.preferred_language_on_setup_enabled
    # ✅ Safely resolve dropdown enum value once
    field_type = :dropdown

    begin
      field = UserField.find_by(name: "language")

      if field.nil?
        field =
          UserField.create!(
            name: "language",
            description: "Your preferred interface language",
            field_type: field_type,
            editable: true,
            required: true,
            show_on_profile: false,
            show_on_user_card: false,
            requirement: 2, # aka show_on_signup: true
          )

        # Load language options from config file or fallback
        language_config_path = File.expand_path("../config/languages.yml", __FILE__)
        language_options = []

        if File.exist?(language_config_path)
          yaml = YAML.load_file(language_config_path)
          language_options = yaml["languages"] || []
        else
          Rails.logger.warn(
            "[preferred-language-on-setup] Language config file not found. Defaulting to English and Swedish.",
          )
          language_options = ["English (US)", "Swedish"]
        end

        language_options.each_with_index do |option, idx|
          UserFieldOption.create!(user_field: field, value: option, position: idx)
        end

        Rails.logger.info "[preferred-language-on-setup] Created custom user field 'language' with dropdown options."
      else
        Rails.logger.info "[preferred-language-on-setup] Custom user field 'language' already exists."
      end
    rescue => e
      Rails.logger.error "[preferred-language-on-setup] Failed to create or find user field: #{e.message}"
    end

    on(:user_created) do |user|
      begin
        field = UserField.find_by(name: "language")
        next unless field

        raw_value = UserCustomField.find_by(user_id: user.id, name: "user_field_#{field.id}")&.value
        next if raw_value.blank?

        value = raw_value.strip.downcase
        locale_map = { "english" => "en", "swedish" => "sv" }

        if locale_map[value]
          user.locale = locale_map[value]
          user.save!
          Rails.logger.info "[preferred-language-on-setup] Set locale '#{user.locale}' for user '#{user.username}'"
        else
          Rails.logger.warn "[preferred-language-on-setup] No locale match for '#{raw_value}'"
        end
      rescue => e
        Rails.logger.error "[preferred-language-on-setup] Failed to set locale for user #{user.username}: #{e.message}"
      end
    end
  end
end
