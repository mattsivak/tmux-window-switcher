#!/usr/bin/env zsh
#
# Simple script to track the timestamp of the last accessed tmux sessions & windows.
#

set -euo pipefail

# Storing the tmux windows accesses to a plain CSV file.
# Content format is: session_name,window_index,timestamp
datastore_file="${XDG_DATA_HOME:-${HOME}/.local/share}/tmux/tmux-window-switcher/history.csv"
sep=','

# Ensure history file exists
mkdir -p "$(dirname "${datastore_file}")"
touch "${datastore_file}"

key() {
  local session_name="${1}"
  local window_name="${2}"
  echo -e "${session_name}${sep}${window_name}"
}

save() {
  local session_name="${1}"
  local window_name="${2}"
  local key="$(key ${session_name} ${window_name})"
  local timestamp=$(date +%s)

  sed -i '' "/^${key}${sep}/d" "${datastore_file}"
  echo "${key}${sep}${timestamp}" >> "${datastore_file}"
}

get() {
  local session_name="${1}"
  local window_name="${2}"
  local key="${session_name}${sep}${window_name}"

  local timestamp=$(grep "^${key}" "${datastore_file}" | cut -d"${sep}" -f3 | head -1)
  echo ${timestamp:-0}
}

get_sorted_windows() {
  local temp_file=$(mktemp)

  tmux list-windows -a -F '#{session_name},#{window_name},#{window_index}' | while IFS=',' read -r session_name window_name window_index; do
    local timestamp=$(get "${session_name}" "${window_name}")
    echo "${session_name}${sep}${window_name}${sep}${window_index}${sep}${timestamp}"
  done | sort -rn -t"${sep}" -k4 > "${temp_file}"

  echo "Session name${sep}Window name${sep}Window index${sep}Timestamp"
  cat "${temp_file}"
  rm "${temp_file}"
}

case "$1" in
  "save")
    save "$2" "$3"
    ;;
  "get")
    get "$2" "$3"
    ;;
  "list")
    get_sorted_windows
    ;;
  *)
    echo "Usage: $0 {save|get|list} [session_name] [window_index]"
    exit 1
    ;;
esac
