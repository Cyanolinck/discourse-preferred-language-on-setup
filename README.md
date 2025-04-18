# Discourse Preferred Language on Setup Plugin

Automatically sets a user's interface language based on their selected language during account creation.

This plugin adds a custom user field (`language`) as a dropdown, visible and required on signup.
To change what languages will be shown for new users when creating an account,
 go to Plugins > Installed Plugins > Preferred Language on Signup settings > Selected languages.

Langugages manually added in the user field will be ignored. 

---

## ✨ Features

- Adds a **required language selection field** to the signup form
- Automatically sets `user.locale` on account creation

---

## 🛠 Installation

Add the plugin to your `app.yml`: then rebuild with ./launcher rebuild app in the root discourse folder

```yaml
hooks:
  after_code:
    - exec:
        cd: $home/plugins
        cmd:
          - git clone https://github.com/Cyanolinck/discourse-preferred-language-on-setup.git
