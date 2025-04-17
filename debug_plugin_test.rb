# debug_plugin_test.rb

require "yaml"

# Fake SiteSetting module
module SiteSetting
  def self.selected_languages
    "en|sv|fr|de"
  end
end


# Simulate YAML file loading
locale_map = YAML.load_file("config/locale_mappings.yml") || {}
#puts "Locale Map: #{locale_map}"
#puts "Again: #{locale_map.to_yaml}"

puts "SiteSetting.selected_languages"
puts SiteSetting.selected_languages

puts ""


puts 'SiteSetting.selected_languages.split("|")'
puts SiteSetting.selected_languages.split("|")

puts ""


selected_language_codes = SiteSetting.selected_languages.split("|")
puts "selected_language_codes"
puts selected_language_codes

puts ""

# Takes the language codes
selected_language_names = selected_language_codes.map { |code| locale_map[code] || code }
puts "selected_language_names"
puts selected_language_names



# Simulate logic from your plugin
#language_codes = SiteSetting.selected_languages.split("|").map(&:strip)
#language_options = language_codes.map { |code| locale_map[code] || code }


#puts "Language Codes: #{language_codes.inspect}"
#puts "Language Options: #{language_options.inspect}"
