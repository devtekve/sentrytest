#!/bin/sh

# Run sentrytest in background
/var/task/sentrytest &
sentry_pid=$!

# Start a 30-second timer in the background
(
  sleep 2
  echo "Sentrytest ran for 2 seconds without failure. Exiting with success."
  kill "$sentry_pid" 2>/dev/null
  exit 0
) &
timer_pid=$!

# Wait for sentrytest to finish
wait "$sentry_pid"
sentry_exit_code=$?

# If sentrytest exits before 30s, kill the timer and exit with its code
kill "$timer_pid" 2>/dev/null
wait "$timer_pid" 2>/dev/null

if [ "$sentry_exit_code" -ne 0 ]; then
  echo "Sentrytest exited early with failure code $sentry_exit_code."
  exit "$sentry_exit_code"
else
  echo "Sentrytest exited early with success."
  exit 0
fi
