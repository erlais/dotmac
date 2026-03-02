# Mac OS Configuration Files

## Does this work?
-```defaults write com.apple.Dock appswitcher-all-displays -bool true```
Initially didn't do anything but it probably needed a dock restart. After restart was working, nice!

## Instant dock
```
defaults write com.apple.dock autohide-delay -float 0;
defaults write com.apple.dock autohide-time-modifier -float 0.25;
killall Dock;
```

## If tmux navigator shortcuts M-{h,j,k,l} etc don't work in iterm
* Try reloading iterm profile
* The profile must have "Report keys using CSI u" enabled. It's under `Profiles` -> `Keys` -> `General`
* For a quickfix: Iterm menu bar: `Session` -> `Terminal State` -> `CSI u Mode`
