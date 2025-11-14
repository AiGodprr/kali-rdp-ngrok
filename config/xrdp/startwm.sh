#!/bin/sh
# XRDP Session Startup Script
# This script is executed when an XRDP session starts

# Unset conflicting environment variables
unset DBUS_SESSION_BUS_ADDRESS
unset XDG_RUNTIME_DIR

# Set locale if available
if [ -r /etc/default/locale ]; then
  . /etc/default/locale
  export LANG LANGUAGE
fi

# Set XDG environment variables for XFCE
export XDG_SESSION_TYPE=x11
export XDG_CURRENT_DESKTOP=XFCE
export XDG_SESSION_DESKTOP=XFCE

# Start XFCE session - check user's .xsession first
if [ -r "$HOME/.xsession" ]; then
  . "$HOME/.xsession"
else
  exec startxfce4
fi
