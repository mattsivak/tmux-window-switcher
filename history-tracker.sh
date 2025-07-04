#!/usr/bin/env zsh
#
# Simple script to track the timestamp of the last accessed tmux sessions & windows.
#

set -euo pipefail

# Storing the tmux windows accesses to a plain CSV file.
# Content format is: session_name,window_name,window_index,timestamp
datastore_file="${XDG_DATA_HOME:-${HOME}/.local/share}/tmux/tmux-window-switcher/history.csv"
sep=','

# Ensure history file exists
mkdir -p "$(dirname "${datastore_file}")"
touch "${datastore_file}"

save() {
  local session_name="${1}"
  local window_name="${2}"
  local window_index="${3}"
  local key="${session_name}${sep}${window_name}${sep}${window_index}"
  local timestamp=$(date +%s)

  sed -i '' "/^${key}${sep}/d" "${datastore_file}"
  echo "${key}${sep}${timestamp}" >> "${datastore_file}"
}

get() {
  local session_name="${1}"
  local window_name="${2}"
  local window_index="${3}"
  local key="${session_name}${sep}${window_name}${sep}${window_index}"

  local timestamp=$(grep "^${key}" "${datastore_file}" | cut -d"${sep}" -f4 | head -1)
  echo ${timestamp:-0}
}

get_sorted_windows() {
  # Create a single awk command that:
  # 1. Reads the history file into memory
  # 2. Processes tmux windows and joins with history data
  # 3. Sorts by timestamp
  echo "Session name${sep}Window name${sep}Window index${sep}Timestamp"

  awk -F"${sep}" '
    # First, read the history file
    NR==FNR {
      history[$1 FS $2 FS $3] = $4
      next
    }
    # Then process tmux output
    {
      key = $1 FS $2 FS $3
      timestamp = (key in history) ? history[key] : 0
      print key FS timestamp
    }
  ' "${datastore_file}" <(tmux list-windows -a -F '#{session_name},#{window_name},#{window_index}') | \
  sort -rn -t"${sep}" -k4
}

case "$1" in
  "save")
    save "$2" "$3" "$4"
    ;;
  "get")
    get "$2" "$3" "$4"
    ;;
  "list")
    get_sorted_windows
    ;;
  *)
    echo "Usage: $0 {save|get|list} [session_name] [window_name] [window_index]"
    exit 1
    ;;
esac
