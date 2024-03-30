# shellcheck shell=sh enable=all disable=SC2034
# shellcheck disable=SC3006,SC3010,SC3024,SC3030,SC3034,SC3046

XDG_DATA_DIRS=/usr/local/share:/usr/share
XDG_CONFIG_DIRS=/etc/xdg

relative_cache=.cache
relative_config=.config
relative_data=.local/share
relative_runtime=.local/runtime
relative_state=.local/state

case $(uname) in
Linux)
  XDG_CACHE_HOME=$HOME/.cache
  XDG_CONFIG_HOME=$HOME/.config
  XDG_DATA_HOME=$HOME/.local/share
  XDG_RUNTIME_DIR="/run/user/$(id -u)"
  XDG_STATE_HOME=$HOME/.local/state
  ;;
Darwin)
  USER_CACHE=$(getconf DARWIN_USER_CACHE_DIR) || USER_CACHE=$HOME/Library/Caches
  USER_TEMP=$(getconf DARWIN_USER_TEMP_DIR) || USER_TEMP=$HOME/Library/TemporaryItems
  USER_APPSUP=$HOME/Library/Application\ Support

  mkdir -p $USER_APPSUP/.{cache,config,local{,/{share,state}}}
  mkdir -p $USER_TEMP/.local/runtime

  XDG_CACHE_HOME=$USER_CACHE/.cache
  XDG_CONFIG_DIRS=:
  XDG_CONFIG_HOME=$USER_APPSUP/.config
  XDG_DATA_HOME=$USER_APPSUP/.local/share
  XDG_RUNTIME_DIR=$USER_TEMP/.local/runtime
  XDG_STATE_HOME=$USER_APPSUP/.local/state
  ;;
esac

export XDG_CONFIG_DIRS XDG_DATA_DIRS XDG_CACHE_HOME XDG_CONFIG_HOME XDG_DATA_HOME XDG_RUNTIME_DIR XDG_STATE_HOME
