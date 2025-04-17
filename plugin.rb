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
  # 🌍 Load locale map from config file
  locale_map =
    begin
      path = File.expand_path("../config/locale_mappings.yml", __FILE__)
      YAML.load_file(path) || {}
    rescue => e
      Rails.logger.warn(
        "[preferred-language-on-setup] Failed to load locale_mappings.yml: #{e.message}",
      )
      {}
    end

  def self.sync_language_user_field(locale_map)
    field_type = :dropdown

    field = UserField.find_or_initialize_by(name: "language")
    field.description = "Your preferred interface language"
    field.field_type = field_type
    field.editable = false
    field.required = true
    field.show_on_profile = false
    field.show_on_user_card = false
    field.requirement = 2 # show_on_signup: true
    field.save!

    language_codes = SiteSetting.preferred_language_on_setup_locales.split("|").map(&:strip)
    language_options = language_codes.map { |code| locale_map[code] || code }

    existing_options = field.user_field_options.pluck(:value)
    to_add = language_options - existing_options
    to_remove = existing_options - language_options

    to_add.each { |value| UserFieldOption.create!(user_field: field, value: value) }

    field.user_field_options.where(value: to_remove).destroy_all

    Rails.logger.info "[preferred-language-on-setup] Synced user field 'language' — added: #{to_add}, removed: #{to_remove}"
  end

  sync_language_user_field(locale_map) if SiteSetting.preferred_language_on_setup_enabled

  on(:site_setting_changed) do |name, _old_value, _new_value|
    if name.to_s == "preferred_language_on_setup_locales"
      Rails.logger.info "[preferred-language-on-setup] Site setting changed, syncing user field..."
      sync_language_user_field(locale_map)
    end
  end

  # 🔁 Set locale for new users based on selected language
  on(:user_created) do |user|
    begin
      field = UserField.find_by(name: "language")
      next unless field

      raw_value = UserCustomField.find_by(user_id: user.id, name: "user_field_#{field.id}")&.value
      next if raw_value.blank?

      value = raw_value.strip.downcase
      reverse_map = locale_map.invert.transform_keys(&:downcase)

      Rails.logger.debug "[preferred-language-on-setup] Raw value: '#{raw_value}', Normalized: '#{value}'"

      if reverse_map[value]
        user.locale = reverse_map[value]
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
