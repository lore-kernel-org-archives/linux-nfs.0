From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH] nfs-utils: remove etc/ directory
Date: Wed, 20 Oct 2004 16:37:11 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20041020203711.GC12305@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CKNCq-0001IR-CH
	for nfs@lists.sourceforge.net; Wed, 20 Oct 2004 13:37:12 -0700
Received: from dsl093-002-214.det1.dsl.speakeasy.net ([66.93.2.214] helo=pickle.fieldses.org)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.41)
	id 1CKNCo-0001tq-78
	for nfs@lists.sourceforge.net; Wed, 20 Oct 2004 13:37:12 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Redhat isn't actually using the files in etc/redhat, or the nfs-utils.spec
file.  Similarly, I don't know whether anyone is using etc/nodist.
(Counterexamples, anyone?)

Since they're not used, they're going to go out of date (most probably are
already), and noone is going to notice when they're broken.  This will cause
confusion.

It's better just to remove them entirely.  People in need of example init files
and such can look at the examples in debian/ or go peek inside Fedora's
.src.rpm's--both of those are actually used, hence will probably be correct.

So this patch is just a long way of saying

	rm -rf etc nfs-utils.spec nfs-utils.spec.in
	perl -pi -e 's/nfs-utils.spec //' configure.in

autoconf will need to be re-run after applying.

---

 nfs-utils-1.0.6-bfields/configure.in      |    2 
 nfs-utils-1.0.6/etc/nodist/nfs-client     |   74 -----------
 nfs-utils-1.0.6/etc/nodist/nfs-functions  |  104 ----------------
 nfs-utils-1.0.6/etc/nodist/nfs-server     |  135 ---------------------
 nfs-utils-1.0.6/etc/redhat/nfs            |   34 -----
 nfs-utils-1.0.6/etc/redhat/nfs.init       |  189 ------------------------------
 nfs-utils-1.0.6/etc/redhat/nfslock.init   |   90 --------------
 nfs-utils-1.0.6/etc/redhat/rpcidmapd.init |   70 -----------
 nfs-utils-1.0.6/nfs-utils.spec            |  110 -----------------
 nfs-utils-1.0.6/nfs-utils.spec.in         |  110 -----------------
 10 files changed, 1 insertion(+), 917 deletions(-)

diff -puN configure.in~remove_etc configure.in
--- nfs-utils-1.0.6/configure.in~remove_etc	2004-10-18 18:25:59.000000000 -0400
+++ nfs-utils-1.0.6-bfields/configure.in	2004-10-18 18:26:53.000000000 -0400
@@ -239,4 +239,4 @@ AC_DEFINE_UNQUOTED(NFS_STATEDIR, "$state
 AC_SUBST(LDFLAGS)
 AC_SUBST(CXXFLAGS)
 AC_SUBST(CFLAGS)
-AC_OUTPUT(config.mk nfs-utils.spec utils/Makefile)
+AC_OUTPUT(config.mk utils/Makefile)
diff -L etc/nodist/nfs-client -puN etc/nodist/nfs-client~remove_etc /dev/null
--- nfs-utils-1.0.6/etc/nodist/nfs-client
+++ /dev/null	2004-08-19 17:44:20.000000000 -0400
@@ -1,74 +0,0 @@
-#!/bin/sh
-# nfs   This shell script starts and stops the nfs services in a distribution
-#       independent fashion.
-#
-# description:  starts and stops nfs client services
-# chkconfig: 2345 60 86
-#
-# Copyright (c) 2000-2001 Mission Critical Linux, Inc.
-#
-
-PATH=/sbin:/bin:/usr/sbin:/usr/bin
-export PATH
-
-# Who am I?
-SCRIPT_NAME=`basename $0`
-
-# Grab our daemon functions.
-. `dirname $0`/nfs-functions
-
-# Kernel daemons and options
-PREFIX="rpc."		# Prefix for kernel execs (usually "rpc.")
-LOCKD="lockd"		# Lockd
-
-# User daemons and options
-STATD="rpc.statd"	# NLM Server
-
-# We use "type -path" instead of "which" since it's internal to bash.
-[ -x "`type -path $STATD`" ] || exit 0
-[ -x "`type -path $PREFIX$LOCKD`" ] || exit 0
-
-# Handle how we were called.
-case "$1" in
-start)
-    # Start rpc.statd daemon without options...
-    echo -n "Starting $STATD: "
-    startdaemon $STATD
-
-    echo -n "Starting $LOCKD: "
-    startdaemon $PREFIX$LOCKD
-
-    # if this lock file doesn't exist, init won't even try to run
-    # the shutdown script for this service on RedHat systems!
-    # on non-RedHat systems, /var/lock/subsys may not exist.
-    touch /var/lock/subsys/$SCRIPT_NAME &> /dev/null
-    ;;
-
-stop)
-    echo -n "Stopping $STATD: "
-    stopdaemon $STATD
-
-    echo -n "Stopping $LOCKD: "
-    stopdaemon $LOCKD
-
-    rm -f /var/lock/subsys/$SCRIPT_NAME 
-    ;;
-
-restart)
-    $0 stop
-    $0 start
-    ;;
-
-status)
-    daemonstatus $STATD
-    daemonstatus $LOCKD
-
-    exit 0
-    ;;
-
-*)
-    echo "Usage: $0 {start|stop|status|restart}"
-    exit 1
-esac
-
-exit 0
diff -L etc/nodist/nfs-functions -puN etc/nodist/nfs-functions~remove_etc /dev/null
--- nfs-utils-1.0.6/etc/nodist/nfs-functions
+++ /dev/null	2004-08-19 17:44:20.000000000 -0400
@@ -1,104 +0,0 @@
-#!/bin/bash
-#
-# An attempt at a simple, distribution-independent daemon management.
-#
-# Copyright (C) 2000-2001 Mission Critical Linux, Inc.
-#
-
-# daemon functions
-getpid()
-{
-    pid=''
-    if [ -f /var/run/${base}.pid ] 
-    then
-        pid=`head -1 /var/run/${base}.pid`
-    fi
-    if [ "$pid" = "" ]
-    then
-        pid=`pidof $1`
-    fi
-    if [ "$pid" = "" ]
-    then
-        pid=`ps ax | awk 'BEGIN { prog=ARGV[1]; ARGC=1 }
-                   { if ((prog == $5) || (("(" prog ")") == $5) ||
-                     (("[" prog "]") == $5) ||
-                   ((prog ":") == $5)) { print $1 ; exit 0 } }' $1`
-    fi
-
-    echo $pid
-}
-
-startdaemon()
-{
-    base=`basename $1`
-
-    # check if it is already running
-    pid=`getpid $base`
-    [ -n "$pid" ] && ps h $pid >/dev/null 2>&1 && echo " already running." && return
-
-    # don't dump core
-    ulimit -c 0
-
-    $* && echo " done." || echo " failed."
-}
-
-stopdaemon()
-{
-    base=`basename $1`
-    pid=`getpid $base`
-
-    if [ "$pid" != "" ]
-    then
-        if ps h $pid>/dev/null 2>&1
-        then
-            kill -TERM $pid
-            if ps h $pid>/dev/null 2>&1
-            then
-                sleep 1
-                if ps h $pid>/dev/null 2>&1
-                then
-                    sleep 3
-                    if ps h $pid>/dev/null 2>&1
-                    then
-                        kill -KILL $pid
-			sleep 2
-                    fi
-                fi
-            fi
-        fi
-        ps h $pid >/dev/null 2>&1
-        RC=$?
-        [ $RC -eq 0 ] && echo " failed." || echo " done."
-        [ $RC -eq 0 ] || rm -f /var/run/$base.pid >/dev/null 2>&1
-    else
-        echo " not running."
-    fi
-}
-
-daemonstatus()
-{
-    base=`basename $1`
-    pid=`getpid $base`
-    
-    if [ "$pid" != "" ]
-    then
-        if ps h $pid >/dev/null 2>&1
-        then
-            echo "$base (pid $pid) is running."
-            return 0
-        else
-            if [ -f /var/run/${base}.pid ]
-            then
-                echo "$base dead but pid file exists."
-                return 1
-            else
-                echo "$base is stopped."
-                return 2
-            fi
-        fi
-    else
-        echo "$base is stopped."
-        return 3
-    fi
-}
-
diff -L etc/nodist/nfs-server -puN etc/nodist/nfs-server~remove_etc /dev/null
--- nfs-utils-1.0.6/etc/nodist/nfs-server
+++ /dev/null	2004-08-19 17:44:20.000000000 -0400
@@ -1,135 +0,0 @@
-#!/bin/sh
-# nfs   This shell script starts and stops the nfs services in a distribution
-#       independent fashion.
-#
-# description:  starts and stops nfs server services
-# chkconfig: 2345 60 20
-#
-# Copyright (c) 2000-2001 Mission Critical Linux, Inc.
-#
-
-PATH=/sbin:/bin:/usr/sbin:/usr/bin
-export PATH
-
-# Who am I?
-SCRIPT_NAME=`basename $0`
-
-# Grab our daemon functions.
-. `dirname $0`/nfs-functions
-
-# Kernel daemons and options
-PREFIX="rpc."		# Prefix for kernel execs (usually "rpc.")
-NFSD="nfsd"		# Kernel NFS Server
-RPCNFSDCOUNT="8"	# Number of nfsd threads
-
-# User daemons and options
-RQUOTAD="rpc.rquotad"	# Remote quota server
-MOUNTD="rpc.mountd"	# Mount server
-RPCMOUNTDOPTS=""	# options for rpc.mountd
-EXPORTFS="exportfs"	# Exportfs command
-
-SCRIPT_NAME=`basename $0`
-DESC="NFS kernel daemon"
-
-# We use "type -path" instead of "which" since it's internal to bash.
-[ -x "`type -path $PREFIX$NFSD`" ] || exit 0
-[ -x "`type -path $MOUNTD`" ] || exit 0
-
-# Also make sure we have our exportfs command.
-[ -x "`type -path $EXPORTFS`" ] || exit 0
-[ -s /etc/exports ] || exit 0
-
-# rquotad is not required for NFS to work, however.
-# Unset if it is not present.
-[ -x "`type -path $RQUOTAD`" ] || unset RQUOTAD
-
-# Handle how we were called.
-case "$1" in
-start)
-    if [ -d /proc/fs/nfsd -a ! -f /proc/fs/nfsd/exports ] ;
-    then
-         /bin/mount -t nfsd nfsd /proc/fs/nfsd
-    fi
-    echo -n "Exporting directories for $DESC..."
-    $EXPORTFS -r
-    echo "done."
-
-    echo -n "Starting $NFSD: "
-    startdaemon $PREFIX$NFSD $RPCNFSDCOUNT
-
-    # Disable NFSv3 on mountd if we don't have NFSv3
-    ClearAddr=
-    if [ -f /proc/net/rpc/auth.unix.ip/channel ] ; then
-      if   grep -s 127.0.0.1 /proc/net/rpc/auth.unix.ip/content > /dev/null ; then
-	     : address already known
-      else
-             echo nfsd 127.0.0.1 2147483647 localhost > /proc/net/rpc/auth.unix.ip/channel
-	     ClearAddr=
-      fi
-    fi
-    rpcinfo -u localhost nfs 3 &>/dev/null 
-    if [ "$?" != "0" ]
-    then
-        RPCMOUNTDOPTS="$RPCMOUNTDOPTS --no-nfs-version 3"
-    fi
-    if [ -n "$ClearAddr" ]; then
-          echo nfsd 127.0.0.1 1  > /proc/net/rpc/auth.unix.ip/channel
-    fi
-
-    echo -n "Starting $MOUNTD: "
-    startdaemon $MOUNTD $RPCMOUNTDOPTS
-
-    # Start rquotad if it is set
-    if [ -n "$RQUOTAD" ]
-    then
-        echo -n "Starting $RQUOTAD: "
-        startdaemon $RQUOTAD
-    fi
-
-    # if this lock file doesn't exist, init won't even try to run
-    # the shutdown script for this service on RedHat systems!
-    # on non-RedHat systems, /var/lock/subsys may not exist.
-    touch /var/lock/subsys/$SCRIPT_NAME &> /dev/null
-    ;;
-
-stop)
-    for process in $RQUOTAD $MOUNTD $NFSD
-    do
-        echo -n "Stopping $process: "
-        stopdaemon $process
-    done
-
-    echo "Unexporting directories for $DESC..."
-    $EXPORTFS -au
-    if [ -f /proc/fs/nfsd/exports ] ; then /bin/umount -t nfsd nfsd /proc/fs/nfsd ; fi
-    rm -f /var/lock/subsys/$SCRIPT_NAME 
-    echo "done."
-    ;;
-
-restart)
-    $0 stop
-    sleep 1
-    $0 start
-    ;;
-
-reload)
-    # Update exports
-    echo "Re-exporting directories for $DESC..."
-    $EXPORTFS -r
-    touch /var/lock/subsys/$SCRIPT_NAME &> /dev/null
-    echo "done."
-    ;;
-
-status)
-    # First, check status of userland daemons
-    for process in $RQUOTAD $MOUNTD $NFSD
-    do
-	daemonstatus $process
-    done
-    exit 0
-    ;;
-
-*)
-    echo "Usage: $0 {start|stop|status|restart|reload}"
-    exit 1
-esac
diff -L etc/redhat/nfs -puN etc/redhat/nfs~remove_etc /dev/null
--- nfs-utils-1.0.6/etc/redhat/nfs
+++ /dev/null	2004-08-19 17:44:20.000000000 -0400
@@ -1,34 +0,0 @@
-# For more information on nfs tuning, please see the NFS-HOWTO
-# http://nfs.sourceforge.net/nfs-howto/
-
-# Pass any additional options for mountd.
-# MOUNTD_OPTIONS=
-
-# Pin mountd to a given port rather than random one from portmapper
-# MOUNTD_PORT=
-
-# Don't advertise TCP for mount.
-# MOUNTD_TCP=no
-
-# NFS V3
-# MOUNTD_NFS_V3=auto|yes|no
-
-# NFS V2
-# MOUNTD_NFS_V2=auto|yes|no
-
-# The number of open file descriptors
-# MOUNTD_OPEN_FILES=128
-
-# Pass the number of instances of nfsd (8 is default; 16 or more
-# might be needed to handle heavy client traffic)
-# NFSDCOUNT=8
-
-# Increase the memory limits on the socket input queues for
-# the nfs processes .. NFS  benchmark SPECsfs demonstrate a
-# need for a larger than default size (64kb) .. setting
-# TUNE_QUEUE to yes will set the values to 256kb.
-# TUNE_QUEUE="yes"
-# NFS_QS=262144
-
-# Mount /proc/fs/nfsd (2.6 kernel only)
-MOUNT_NFSD="yes"
diff -L etc/redhat/nfs.init -puN etc/redhat/nfs.init~remove_etc /dev/null
--- nfs-utils-1.0.6/etc/redhat/nfs.init
+++ /dev/null	2004-08-19 17:44:20.000000000 -0400
@@ -1,189 +0,0 @@
-#!/bin/sh
-#
-# nfs           This shell script takes care of starting and stopping
-#               the NFS services.
-#
-# chkconfig: - 60 20
-# description: NFS is a popular protocol for file sharing across TCP/IP \
-#              networks. This service provides NFS server functionality, \
-#              which is configured via the /etc/exports file.
-# probe: true
-# config: /etc/sysconfig/nfs
-
-# Source function library.
-. /etc/rc.d/init.d/functions
-
-# Source networking configuration.
-if [ ! -f /etc/sysconfig/network ]; then
-    exit 0
-fi
-
-. /etc/sysconfig/network
-
-# Check that networking is up.
-[ ${NETWORKING} = "no" ] && exit 0
-
-[ -x /usr/sbin/rpc.nfsd ] || exit 0
-[ -x /usr/sbin/rpc.mountd ] || exit 0
-[ -x /usr/sbin/exportfs ] || exit 0
-[ -s /etc/exports ] || exit 0
-
-# Check for and source configuration file otherwise set defaults
-# TUNE_QUEUE: controls whether to up the size of input queues
-[ -f /etc/sysconfig/nfs ] && . /etc/sysconfig/nfs
-
-[ -z "$MOUNTD_NFS_V2" ] && MOUNTD_NFS_V2=auto
-[ -z "$MOUNTD_NFS_V3" ] && MOUNTD_NFS_V3=auto
-
-# Number of servers to be started by default
-[ -z "$NFSDCOUNT" ] && NFSDCOUNT=8
-
-# Remote quota server
-[ -z "$RQUOTAD" ] && RQUOTAD=`type -path rpc.rquotad`
-
-# Get the initial values for the input sock queues
-# at the time of running the script.
-if [ "$TUNE_QUEUE" = "yes" ]; then
-    RMEM_DEFAULT=`/sbin/sysctl -n net.core.rmem_default`
-    RMEM_MAX=`/sbin/sysctl -n net.core.rmem_max`
-    # 256kb recommended minimum size based on SPECsfs NFS benchmarks
-    [ -z "$NFS_QS" ] && NFS_QS=262144
-fi
-
-
-# See how we were called.
-case "$1" in
-  start)
-	if [ -d /proc/fs/nfsd -a "$MOUNT_NFSD" = "yes" ] ; then
-	    /bin/mount -t nfsd nfsd /proc/fs/nfsd
-	fi
-	# Start daemons.
-	# Apply input queue increase for nfs server
-	if [ "$TUNE_QUEUE" = "yes" ]; then
- 	    /sbin/sysctl -w net.core.rmem_default=$NFSD_QS >/dev/null 2>&1
-	    /sbin/sysctl -w net.core.rmem_max=$NFSD_QS >/dev/null 2>&1
-	fi
-	action "Starting NFS services: " /usr/sbin/exportfs -r
-	if [ -n "$RQUOTAD" -a "$RQUOTAD" != "no" ]; then
-	    echo -n "Starting NFS quotas: "
-	    daemon rpc.rquotad
-	    echo
-	fi
-	echo -n "Starting NFS daemon: "
-	daemon rpc.nfsd $NFSDCOUNT
-	echo
-
-	[ -n "$MOUNTD_PORT" ] \
-	&& MOUNTD_OPTIONS="$MOUNTD_OPTIONS -p $MOUNTD_PORT"
-	[ "$MOUNTD_TCP" = "no" -o "$MOUNTD_TCP" = "NO" ] \
-	&& MOUNTD_OPTIONS="$MOUNTD_OPTIONS --no-tcp"
-
-	case $MOUNTD_NFS_V2 in
-	auto|AUTO)
-	    # Let's see if we support NFS version 2.
-	    ClearAddr=
-	    if [ -f /proc/net/rpc/auth.unix.ip/channel ] ; then
-	       if   grep -s 127.0.0.1 /proc/net/rpc/auth.unix.ip/content > /dev/null ; then
-		    : address already known
-	       else
-                    echo nfsd 127.0.0.1 2147483647 localhost > /proc/net/rpc/auth.unix.ip/channel
-		    ClearAddr=yes
-	      fi
-	    fi
-	    /usr/sbin/rpcinfo -u localhost nfs 2 &>/dev/null
-	    if [ $? -ne 0 ]; then
-		MOUNTD_OPTIONS="$MOUNTD_OPTIONS --no-nfs-version 2"
-	    fi
-	    if [ -n "$ClearAddr" ]; then
-                  echo nfsd 127.0.0.1 1  > /proc/net/rpc/auth.unix.ip/channel
-	    fi
-	    ;;
-	no|NO)
-	    MOUNTD_OPTIONS="$MOUNTD_OPTIONS --no-nfs-version 2"
-	    ;;
-	yes|YES)
-	    MOUNTD_OPTIONS="$MOUNTD_OPTIONS --nfs-version 2"
-	    ;;
-	esac
-
-	case $MOUNTD_NFS_V3 in
-	auto|AUTO)
-	    # Let's see if we support NFS version 3.
-	    /usr/sbin/rpcinfo -u localhost nfs 3 &>/dev/null
-	    if [ $? -ne 0 ]; then
-		MOUNTD_OPTIONS="$MOUNTD_OPTIONS --no-nfs-version 3"
-	    fi
-	    ;;
-	no|NO)
-	    MOUNTD_OPTIONS="$MOUNTD_OPTIONS --no-nfs-version 3"
-	    ;;
-	yes|YES)
-	    MOUNTD_OPTIONS="$MOUNTD_OPTIONS --nfs-version 3"
-	    ;;
-	esac
-
-	echo -n "Starting NFS mountd: "
-	daemon rpc.mountd $MOUNTD_OPTIONS
-	echo
-	touch /var/lock/subsys/nfs
-	# reset input queue for rest of network services
-	if [ "$TUNE_QUEUE" = "yes" ]; then
-	    /sbin/sysctl -w net.core.rmem_default=$RMEM_DEFAULT >/dev/null 2>&1
-	    /sbin/sysctl -w net.core.rmem_max=$RMEM_MAX >/dev/null 2>&1
-	fi
-	;;
-  stop)
-	# Stop daemons.
-	echo -n "Shutting down NFS mountd: "
-	killproc rpc.mountd
-	echo
-	echo -n "Shutting down NFS daemon: "
-	killproc nfsd
-	echo
-	if [ -n "$RQUOTAD" ]; then
-		echo -n "Shutting down NFS quotas: "
-		killproc rpc.rquotad
-		echo
-	fi
-	# Do it the last so that clients can still access the server
-	# when the server is running.
-	action "Shutting down NFS services: " /usr/sbin/exportfs -au
-	if [ -d /proc/fs/nfsd -a "$MOUNT_NFSD" = "yes" ] ; then
-		/bin/umount /proc/fs/nfsd
-	fi
-	rm -f /var/lock/subsys/nfs
-	;;
-  status)
-	status rpc.mountd
-	status nfsd
-	if [ -n "$RQUOTAD" ]; then
-		status rpc.rquotad
-	fi
-	;;
-  restart)
-	$0 stop
-	$0 start
-	;;
-  reload)
-	/usr/sbin/exportfs -r
-	touch /var/lock/subsys/nfs
-	;;
-  probe)
-	if [ ! -f /var/lock/subsys/nfs ] ; then
-	  echo start; exit 0
-	fi
-	/sbin/pidof rpc.mountd >/dev/null 2>&1; MOUNTD="$?"
-	/sbin/pidof nfsd >/dev/null 2>&1; NFSD="$?"
-	if [ $MOUNTD = 1 -o $NFSD = 1 ] ; then
-	  echo restart; exit 0
-	fi
-	if [ /etc/exports -nt /var/lock/subsys/nfs ] ; then
-	  echo reload; exit 0
-	fi
-	;;
-  *)
-	echo "Usage: nfs {start|stop|status|restart|reload}"
-	exit 1
-esac
-
-exit 0
diff -L etc/redhat/nfslock.init -puN etc/redhat/nfslock.init~remove_etc /dev/null
--- nfs-utils-1.0.6/etc/redhat/nfslock.init
+++ /dev/null	2004-08-19 17:44:20.000000000 -0400
@@ -1,90 +0,0 @@
-#!/bin/sh
-#
-# nfslock       This shell script takes care of starting and stopping
-#               the NFS file locking service.
-#
-# chkconfig: 345 60 86
-# description: NFS is a popular protocol for file sharing across \
-#	       TCP/IP networks. This service provides NFS file \
-#	       locking functionality.
-# probe: true
-
-# Source function library.
-. /etc/rc.d/init.d/functions
-
-# Source networking configuration.
-if [ ! -f /etc/sysconfig/network ]; then
-    exit 0
-fi
-
-. /etc/sysconfig/network
-
-# Check that networking is up.
-[ ${NETWORKING} = "no" ] && exit 0
-
-[ -x /sbin/rpc.lockd ] || exit 0
-[ -x /sbin/rpc.statd ] || exit 0
-
-if [ -n "${STATD_HOSTNAME}" ]; then
-    STATDARG="-n ${STATD_HOSTNAME}"
-else
-    STATDARG=""
-fi
-
-# See how we were called.
-case "$1" in
-  start)
-	# Start daemons.
-	echo "Starting NFS file locking services: "
-	echo -n "Starting NFS lockd: "
-	daemon rpc.lockd
-	echo
-	echo -n "Starting NFS statd: "
-	daemon rpc.statd ${STATDARG}
-	echo
-	touch /var/lock/subsys/nfslock
-	;;
-  stop)
-	# Stop daemons.
-	echo "Shutting down NFS file locking services: "
-	pidlist=`pidofproc lockd`
-	if [ -n "$pidlist" ]; then
-		pid=
-		for apid in $pidlist ; do
-			[ -f /proc/$apid/exe ] && pid="$pid $apid"
-		done
-		if [ -n "$pid" ]; then
-			echo -n "Shutting down NFS lockd: "
-			killproc lockd
-			echo
-		fi
-	fi
-	echo -n "Shutting down NFS statd: "
-	killproc rpc.statd
-	echo
-	rm -f /var/lock/subsys/nfslock
-	;;
-  status)
-	status lockd
-	status rpc.statd
-	;;
-  restart)
-	$0 stop
-	$0 start
-	;;
-  probe)
-	if [ ! -f /var/lock/subsys/nfslock ] ; then
-	  echo start; exit 0
-	fi
-	/sbin/pidof rpc.statd >/dev/null 2>&1; STATD="$?"
-	/sbin/pidof lockd >/dev/null 2>&1; LOCKD="$?"
-	if [ $STATD = 1 -o $LOCKD = 1 ] ; then
-	  echo restart; exit 0
-	fi
-	;;
-  *)
-	echo "Usage: nfslock {start|stop|status|restart}"
-	exit 1
-esac
-
-exit 0
diff -L etc/redhat/rpcidmapd.init -puN etc/redhat/rpcidmapd.init~remove_etc /dev/null
--- nfs-utils-1.0.6/etc/redhat/rpcidmapd.init
+++ /dev/null	2004-08-19 17:44:20.000000000 -0400
@@ -1,70 +0,0 @@
-#!/bin/bash
-#
-# rpcidmapd     Start up and shut down RPC name to UID/GID mapper
-#
-# Authors:	Chuck Lever <cel@netapp.com>
-#
-# chkconfig: 0356 19 69
-# description: Starts user-level daemon for NFSv4 that maps user \
-#              names to UID and GID numbers.
-
-# Source function library.
-. /etc/init.d/functions
-
-# Source networking configuration.
-if [ ! -f /etc/sysconfig/network ]; then
-    exit 0
-fi
-. /etc/sysconfig/network
-
-# Check that networking is up.
-[ "${NETWORKING}" = "no" ] && exit 0
-
-[ ! -x /usr/sbin/rpc.idmapd ] && exit 0
-
-OPTIONS=""
-RETVAL=0
-prog="rpc.idmapd"
-
-case "$1" in
-  start)
-	# make sure the rpc pipe fs is mounted already
-	RPCMTAB=`grep -v '^#' /proc/mounts | awk '{ if ($3 ~ /^rpc_pipefs$/ ) print $2}'`
-	if [ -n "$RPCMTAB" ]; then
-		# Start daemon.
-		echo -n $"Starting $prog: "
-		daemon /usr/sbin/rpc.idmapd ${OPTIONS} -p ${RPCMTAB}/nfs
-		RETVAL=$?
-		echo
-		[ $RETVAL -eq 0 ] && touch /var/lock/subsys/rpc.idmapd
-	fi
-	;;
-  stop)
-	# Stop daemon.
-	echo -n $"Shutting down $prog: "
-	killproc $prog
-	RETVAL=$?
-	echo
-	[ $RETVAL -eq 0 ] && rm -f /var/lock/subsys/rpc.idmapd
-	;;
-  status)
-	status rpc.idmapd
-	RETVAL=$?
-	;;
-  restart|reload)
-	$0 stop
-	$0 start
-	RETVAL=$?
-	;;
-  condrestart)
-	if [ -f /var/lock/subsys/rpc.idmapd ]; then
-		$0 restart
-		RETVAL=$?
-	fi
-	;;
-  *)
-	echo $"Usage: $0 {start|stop|restart|condrestart|status}"
-	exit 1
-esac
-
-exit $RETVAL
diff -L nfs-utils.spec -puN nfs-utils.spec~remove_etc /dev/null
--- nfs-utils-1.0.6/nfs-utils.spec
+++ /dev/null	2004-08-19 17:44:20.000000000 -0400
@@ -1,110 +0,0 @@
-%define rquotad 0
-%{?do_rquotad:%define rquotad 1}
-
-# We don't use libtool. 
-%define __libtoolize :
-
-Summary: NFS utlilities and supporting daemons for the kernel NFS server.
-Name: nfs-utils
-Version: 1.0.6
-Release: 1
-Source0: ftp://nfs.sourceforge.net/pub/nfs/%{name}-%{version}.tar.gz
-Group: System Environment/Daemons
-Obsoletes: nfs-server
-Obsoletes: knfsd
-Obsoletes: knfsd-clients
-Obsoletes: nfs-server-clients 
-Obsoletes: knfsd-lock
-Provides: nfs-server 
-Provides: nfs-server-clients 
-Provides: knfsd-lock 
-Provides: knfsd-clients 
-Provides: knfsd
-Copyright: GPL
-Buildroot: /var/tmp/%{name}-root
-Requires: kernel >= 2.2.7, portmap >= 4.0
-
-%description
-The nfs-utils package provides a daemon for the kernel NFS server and
-related tools, which provides a much higher level of performance than the
-traditional Linux NFS server used by most users.
-
-This package also contains the showmount program.  Showmount queries the
-mount daemon on a remote host for information about the NFS (Network File
-System) server on the remote host.  For example, showmount can display the
-clients which are mounted on that host.
-
-%prep
-%setup -q
-
-%build
-CC=%{__cc}; export CC
-CC_FOR_BUILD=gcc; export CC_FOR_BUILD
-%configure \
-%if !%{rquotad}
-	--disable-rquotad \
-%endif
-	--build=%{_build_alias}
-
-make all
-
-%install
-rm -rf $RPM_BUILD_ROOT
-mkdir -p $RPM_BUILD_ROOT/{/sbin,/usr/sbin}
-mkdir -p $RPM_BUILD_ROOT%{_mandir}/{man5,man8}
-mkdir -p $RPM_BUILD_ROOT/etc/rc.d/init.d
-mkdir -p $RPM_BUILD_ROOT/etc/sysconfig
-mkdir -p $RPM_BUILD_ROOT/var/lib/nfs
-make install_prefix=$RPM_BUILD_ROOT MANDIR=$RPM_BUILD_ROOT%{_mandir} SBINDIR=$RPM_BUILD_ROOT%{_prefix}/sbin install
-install -s -m 755 tools/rpcdebug/rpcdebug $RPM_BUILD_ROOT/sbin
-install -m 755 etc/redhat/nfs.init $RPM_BUILD_ROOT/etc/rc.d/init.d/nfs
-install -m 755 etc/redhat/nfs $RPM_BUILD_ROOT/etc/sysconfig/nfs
-install -m 755 etc/redhat/nfslock.init $RPM_BUILD_ROOT/etc/rc.d/init.d/nfslock
-touch $RPM_BUILD_ROOT/var/lib/nfs/rmtab
-mv $RPM_BUILD_ROOT/usr/sbin/{rpc.lockd,rpc.statd} $RPM_BUILD_ROOT/sbin
-
-%clean
-rm -rf $RPM_BUILD_ROOT
-
-%post
-/sbin/chkconfig --add nfs
-/sbin/chkconfig --add nfslock
-
-%preun
-if [ "$1" = "0" ]; then
-    /sbin/chkconfig --del nfs
-    /sbin/chkconfig --del nfslock
-fi
-
-%triggerpostun -- nfs-server
-/sbin/chkconfig --add nfs
-
-%triggerpostun -- knfsd
-/sbin/chkconfig --add nfs
-
-%triggerpostun -- knfsd-clients
-/sbin/chkconfig --add nfslock
-
-%files
-%defattr(-,root,root)
-%config /etc/rc.d/init.d/nfs
-%dir /var/lib/nfs
-%config(noreplace) /etc/sysconfig/nfs
-%config(noreplace) /var/lib/nfs/xtab
-%config(noreplace) /var/lib/nfs/etab
-%config(noreplace) /var/lib/nfs/rmtab
-/sbin/rpcdebug
-/sbin/rpc.lockd
-/sbin/rpc.statd
-/usr/sbin/exportfs
-/usr/sbin/nfsstat
-/usr/sbin/nhfsstone
-/usr/sbin/rpc.mountd
-/usr/sbin/rpc.nfsd
-%if %{rquotad}
-/usr/sbin/rpc.rquotad
-%endif
-/usr/sbin/showmount
-%{_mandir}/man?/*
-%config /etc/rc.d/init.d/nfslock
-%doc README ChangeLog COPYING
diff -L nfs-utils.spec.in -puN nfs-utils.spec.in~remove_etc /dev/null
--- nfs-utils-1.0.6/nfs-utils.spec.in
+++ /dev/null	2004-08-19 17:44:20.000000000 -0400
@@ -1,110 +0,0 @@
-%define rquotad 0
-%{?do_rquotad:%define rquotad 1}
-
-# We don't use libtool. 
-%define __libtoolize :
-
-Summary: NFS utlilities and supporting daemons for the kernel NFS server.
-Name: nfs-utils
-Version: @VERSION@
-Release: @RELEASE@
-Source0: ftp://nfs.sourceforge.net/pub/nfs/%{name}-%{version}.tar.gz
-Group: System Environment/Daemons
-Obsoletes: nfs-server
-Obsoletes: knfsd
-Obsoletes: knfsd-clients
-Obsoletes: nfs-server-clients 
-Obsoletes: knfsd-lock
-Provides: nfs-server 
-Provides: nfs-server-clients 
-Provides: knfsd-lock 
-Provides: knfsd-clients 
-Provides: knfsd
-Copyright: GPL
-Buildroot: /var/tmp/%{name}-root
-Requires: kernel >= 2.2.7, portmap >= 4.0
-
-%description
-The nfs-utils package provides a daemon for the kernel NFS server and
-related tools, which provides a much higher level of performance than the
-traditional Linux NFS server used by most users.
-
-This package also contains the showmount program.  Showmount queries the
-mount daemon on a remote host for information about the NFS (Network File
-System) server on the remote host.  For example, showmount can display the
-clients which are mounted on that host.
-
-%prep
-%setup -q
-
-%build
-CC=%{__cc}; export CC
-CC_FOR_BUILD=gcc; export CC_FOR_BUILD
-%configure \
-%if !%{rquotad}
-	--disable-rquotad \
-%endif
-	--build=%{_build_alias}
-
-make all
-
-%install
-rm -rf $RPM_BUILD_ROOT
-mkdir -p $RPM_BUILD_ROOT/{/sbin,/usr/sbin}
-mkdir -p $RPM_BUILD_ROOT%{_mandir}/{man5,man8}
-mkdir -p $RPM_BUILD_ROOT/etc/rc.d/init.d
-mkdir -p $RPM_BUILD_ROOT/etc/sysconfig
-mkdir -p $RPM_BUILD_ROOT/var/lib/nfs
-make install_prefix=$RPM_BUILD_ROOT MANDIR=$RPM_BUILD_ROOT%{_mandir} SBINDIR=$RPM_BUILD_ROOT%{_prefix}/sbin install
-install -s -m 755 tools/rpcdebug/rpcdebug $RPM_BUILD_ROOT/sbin
-install -m 755 etc/redhat/nfs.init $RPM_BUILD_ROOT/etc/rc.d/init.d/nfs
-install -m 755 etc/redhat/nfs $RPM_BUILD_ROOT/etc/sysconfig/nfs
-install -m 755 etc/redhat/nfslock.init $RPM_BUILD_ROOT/etc/rc.d/init.d/nfslock
-touch $RPM_BUILD_ROOT/var/lib/nfs/rmtab
-mv $RPM_BUILD_ROOT/usr/sbin/{rpc.lockd,rpc.statd} $RPM_BUILD_ROOT/sbin
-
-%clean
-rm -rf $RPM_BUILD_ROOT
-
-%post
-/sbin/chkconfig --add nfs
-/sbin/chkconfig --add nfslock
-
-%preun
-if [ "$1" = "0" ]; then
-    /sbin/chkconfig --del nfs
-    /sbin/chkconfig --del nfslock
-fi
-
-%triggerpostun -- nfs-server
-/sbin/chkconfig --add nfs
-
-%triggerpostun -- knfsd
-/sbin/chkconfig --add nfs
-
-%triggerpostun -- knfsd-clients
-/sbin/chkconfig --add nfslock
-
-%files
-%defattr(-,root,root)
-%config /etc/rc.d/init.d/nfs
-%dir /var/lib/nfs
-%config(noreplace) /etc/sysconfig/nfs
-%config(noreplace) /var/lib/nfs/xtab
-%config(noreplace) /var/lib/nfs/etab
-%config(noreplace) /var/lib/nfs/rmtab
-/sbin/rpcdebug
-/sbin/rpc.lockd
-/sbin/rpc.statd
-/usr/sbin/exportfs
-/usr/sbin/nfsstat
-/usr/sbin/nhfsstone
-/usr/sbin/rpc.mountd
-/usr/sbin/rpc.nfsd
-%if %{rquotad}
-/usr/sbin/rpc.rquotad
-%endif
-/usr/sbin/showmount
-%{_mandir}/man?/*
-%config /etc/rc.d/init.d/nfslock
-%doc README ChangeLog COPYING
_


-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
