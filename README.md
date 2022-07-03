Fork of [zsh-apple-touchbar](https://github.com/zsh-users/zsh-apple-touchbar) with some shell scripting to programmatically create dynamic touchbar widgets in iTerm2.

To use, clone this repo somewhere on your machine
```
git clone https://github.com/pnor/zsh-apple-touchbar.git ~/.zsh/zsh-apple-touchbar
```
and then source it towards the top of your `~/.zshrc`
```
source ~/.zsh/zsh-apple-touchbar/zsh-apple-touchbar.zsh
```

## Sections
![preview](images/mainbar.png)

Currently has:

### history

![preview](images/Touchbar.png)

Shows recent commands on touchbar

### configs

![preview](images/settingbar.png)

Shows configuration files

### commands

![preview](images/commandbar.png)

Shows chosen commands on touchbar

### stats

![preview](images/computerbar.png)

Shows statistics about computer and periodically updates

### weather

![preview](images/weatherbar.png)

Shows the weather, wind, and moon phase if it is night time.

(If you use powerline 10k's instant prompt feature, this may not work as intended on shell startup)

---
The original's README is [here](https://github.com/zsh-users/zsh-apple-touchbar).
---

You can start typing command and complete them on your own by passing the -n argument in the manual config setup or by using `command_to_complete` instead of `command` in the config.yml