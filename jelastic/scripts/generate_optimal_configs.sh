#!/bin/bash

SED=$(which sed);

#
# config optimizer for jetty8
#

JETTY_START_SCRIPT="${OPENSHIFT_JETTY9_DIR}.openshift/action_hooks/start";

[ -z "$XMS" ] && { XMS=32; }
memory_total=`free -m | grep Mem | awk '{print $2}'`;
[ -z "$XMX" ] && { let XMX=memory_total-35; }

$SED -i  "s/-Xms[0-9]*m/-Xms${XMS}m/g"  $JETTY_START_SCRIPT;
$SED -i  "s/-Xmx[0-9]*m/-Xmx${XMX}m/g"  $JETTY_START_SCRIPT;

if [[ "$UID" == '0' ]]; then
    echo -e "$(find $(realpath /usr/java/latest) -name libjli.so -printf "%h\n")" > /etc/ld.so.conf.d/java.conf ; \
    ldconfig

    JAVABIN=$(which java 2>/dev/null)
    [ ! -z "$JAVABIN" ] && {
        setcap 'cap_net_bind_service=+ep' $(readlink -f "$JAVABIN")
    }
fi
