# frozen_string_literal: true

# name: discourse-preferred-language-on-setup
# about: Automatically sets a user's interface language based on a custom user field completed during signup.
# meta_topic_id: 0
# version: 0.0.2
# authors: Lincken
# url: https://github.com/Cyanolinck/discourse-preferred-language-on-setup
# required_version: 2.7.0

enabled_site_setting :preferred_language_on_setup_enabled

after_initialize do
  if SiteSetting.preferred_language_on_setup_enabled
    begin
      field_name = "language"
      field = UserField.find_by(name: field_name)

      if field.nil?
        field =
          UserField.create!(
            name: field_name,
            field_type: UserField.types[:dropdown],
            editable: true,
            required: true,
            show_on_profile: false,
            show_on_user_card: false,
            show_on_signup: true,
          )

        %w[English Swedish].each_with_index do |option, idx|
          UserFieldOption.create!(user_field: field, value: option, position: idx)
        end

        Rails.logger.info "[preferred-language-on-setup] Created custom user field '#{field_name}' with dropdown options."
      else
        Rails.logger.info "[preferred-language-on-setup] Custom user field '#{field_name}' already exists."
      end
    rescue => e
      Rails.logger.error "[preferred-language-on-setup] Failed to create or find user field: #{e.message}"
    end

    # Hook to set user locale
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
