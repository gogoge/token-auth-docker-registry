#!/bin/sh
# Example external authenticator program for use with `ext_auth`.
#

read u p

if [ "$u" == "user1" -a "$p" == "pass" ]; then
  exit 0
fi

if [ "$u" == "user" -a "$p" == "pass" ]; then
#  echo '{"labels": {"level": ["max"], "groups": ["VIP", "ATeam"]}}'
  exit 0
fi

exit 1

