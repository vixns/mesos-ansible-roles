#!/bin/bash
set -o errexit -o nounset -o pipefail
function -h {
cat <<USAGE
 USAGE: mesos-init-wrapper (master|agent)

  Run Mesos in master or agent mode, loading environment files, setting up
  logging and loading config parameters as appropriate.

  To configure Mesos, you have many options:

 *  Set a Zookeeper URL in

      /etc/mesos/zk

    and it will be picked up by the agent and master.

 *  You can set environment variables (including the MESOS_* variables) in
    files under /etc/default/:

      /etc/default/mesos          # For both agent and master.
      /etc/default/mesos-master   # For the master only.
      /etc/default/mesos-agent    # For the agent only.

 *  To set command line options for the agent or master, you can create files
    under certain directories:

      /etc/mesos-agent            # For the agent only.
      /etc/mesos-master           # For the master only.

    For example, to set the port for the agent:

      echo 5050 > /etc/mesos-agent/port

    To set the switch user flag:

      touch /etc/mesos-agent/?switch_user

    To explicitly disable it:

      touch /etc/mesos-agent/?no-switch_user

    Adding attributes and resources to the agents is slightly more granular.
    Although you can pass them all at once with files called 'attributes' and
    'resources', you can also set them by creating files under directories
    labeled 'attributes' or 'resources':

      echo north-west > /etc/mesos-agent/attributes/rack

    This is intended to allow easy addition and removal of attributes and
    resources from the agent configuration.

USAGE
}; function --help { -h ;}                 # A nice way to handle -h and --help
export LC_ALL=en_US.UTF-8                    # A locale that works consistently

function main {
  err "Please use \`master' or \`agent'."
}

function agent {
  local etc_agent=/etc/mesos-agent
  local args=()
  local attributes=()
  local resources=()
  # Call mesosphere-dnsconfig if present on the system to generate config files.
  [ -x /usr/bin/mesosphere-dnsconfig ] && mesosphere-dnsconfig -write -service=mesos-agent
  [[ ! -f /etc/default/mesos ]]       || . /etc/default/mesos
  [[ ! -f /etc/default/mesos-agent ]] || . /etc/default/mesos-agent
  [[ ! ${MASTER:-} ]]         || args+=( --master="$MASTER" )
  [[ ! ${IP:-} ]]             || args+=( --ip="$IP" )
  [[ ! ${LOGS:-} ]]           || args+=( --log_dir="$LOGS" )
  [[ ! ${ISOLATION:-} ]]      || args+=( --isolation="$ISOLATION" )
  [[ ! ${CONTAINERIZERS:-} ]] || args+=( --containerizers="$CONTAINERIZERS" )
  [[ ! ${ULIMIT_OPEN_FILES:-} ]]      || ulimit -n $ULIMIT_OPEN_FILES
  [[ ! ${ULIMIT_MAX_PROCESSES:-} ]]   || ulimit -u $ULIMIT_MAX_PROCESSES
  [[ ! ${ULIMIT_PENDING_SIGNALS:-} ]] || ulimit -i $ULIMIT_PENDING_SIGNALS

  for f in "$etc_agent"/* # attributes ip resources isolation &al.
  do
    if [[ -f $f ]]
    then
      local name="$(basename "$f")"
      if [[ $name == '?'* ]]         # Recognize flags (options without values)
      then args+=( --"${name#'?'}" )
      else args+=( --"$name"="$(cat "$f")" )
      fi
    fi
  done
  # We allow the great multitude of attributes and resources to be specified
  # in directories, where the filename is the key and the contents its value.
  for f in "$etc_agent"/attributes/*
  do [[ ! -s $f ]] || attributes+=( "$(basename "$f")":"$(cat "$f")" )
  done
  if [[ ${#attributes[@]} -gt 0 ]]
  then
    local formatted="$(printf ';%s' "${attributes[@]}")"
    args+=( --attributes="${formatted:1}" )        # NB: Leading ';' is clipped
  fi
  for f in "$etc_agent"/resources/*
  do [[ ! -s $f ]] || resources+=( "$(basename "$f")":"$(cat "$f")" )
  done
  if [[ ${#resources[@]} -gt 0 ]]
  then
    local formatted="$(printf ';%s' "${resources[@]}")"
    args+=( --resources="${formatted:1}" )         # NB: Leading ';' is clipped
  fi
  logged /usr/sbin/mesos-agent "${args[@]}"
}

function master {
  local etc_master=/etc/mesos-master
  local args=()
  # Call mesosphere-dnsconfig if present on the system to generate config files.
  [ -x /usr/bin/mesosphere-dnsconfig ] && mesosphere-dnsconfig -write -service=mesos-master
  [[ ! -f /etc/default/mesos ]]        || . /etc/default/mesos
  [[ ! -f /etc/default/mesos-master ]] || . /etc/default/mesos-master
  [[ ! ${ULIMIT:-} ]]  || ulimit $ULIMIT
  [[ ! ${ZK:-} ]]      || args+=( --zk="$ZK" )
  [[ ! ${IP:-} ]]      || args+=( --ip="$IP" )
  [[ ! ${PORT:-} ]]    || args+=( --port="$PORT" )
  [[ ! ${CLUSTER:-} ]] || args+=( --cluster="$CLUSTER" )
  [[ ! ${LOGS:-} ]]    || args+=( --log_dir="$LOGS" )
  [[ ! ${ULIMIT_OPEN_FILES:-} ]]      || ulimit -n $ULIMIT_OPEN_FILES
  [[ ! ${ULIMIT_MAX_PROCESSES:-} ]]   || ulimit -u $ULIMIT_MAX_PROCESSES
  [[ ! ${ULIMIT_PENDING_SIGNALS:-} ]] || ulimit -i $ULIMIT_PENDING_SIGNALS

  for f in "$etc_master"/* # cluster log_dir port &al.
  do
    if [[ -f $f ]]
    then
      local name="$(basename "$f")"
      if [[ $name == '?'* ]]         # Recognize flags (options without values)
      then args+=( --"${name#'?'}" )
      else args+=( --"$name"="$(cat "$f")" )
      fi
    fi
  done
  logged /usr/sbin/mesos-master "${args[@]}"
}

# Send all output to syslog and tag with PID and executable basename.
function logged {
  local tag="${1##*/}[$$]"
  exec 1> >(exec logger -p user.info -t "$tag")
  exec 2> >(exec logger -p user.err  -t "$tag")
  exec "$@"
}

function msg { out "$*" >&2 ;}
function err { local x=$? ; msg "$*" ; return $(( $x == 0 ? 1 : $x )) ;}
function out { printf '%s\n' "$*" ;}

if [[ ${1:-} ]] && declare -F | cut -d' ' -f3 | fgrep -qx -- "${1:-}"
then "$@"
else main "$@"
fi
