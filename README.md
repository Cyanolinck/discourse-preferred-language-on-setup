# Discourse Preferred Language on Setup Plugin

Automatically sets a user's interface language based on their selected language during account creation.

This plugin adds a custom user field (`language`) as a dropdown, visible and required on signup. It then maps the selected value to a Discourse locale (e.g. `"English"` → `en`, `"Swedish"` → `sv`) and applies it to the user's interface language as soon as their account is created.

---

## ✨ Features

- Adds a **required language selection field** to the signup form
- Automatically sets `user.locale` on account creation
- Supports English and Swedish out of the box
- Easily extensible to support additional languages
- Safe to run multiple times (idempotent field creation)
- Designed for **Docker production installs** with support for hot-reload via `sv restart unicorn`

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
