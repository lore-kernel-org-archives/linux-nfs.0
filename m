Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy02.merit.edu ([207.75.116.194]:59517 "EHLO
	merit-proxy02.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751041Ab1HKSSZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Aug 2011 14:18:25 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@tonian.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 1/2] blkmapd: remove init file
Date: Thu, 11 Aug 2011 14:18:20 -0400
Message-Id: <1313086701-7103-1-git-send-email-rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Jim Rees <rees@umich.edu>
---
 utils/blkmapd/etc/initd/initd.redhat |   76 ----------------------------------
 1 files changed, 0 insertions(+), 76 deletions(-)
 delete mode 100644 utils/blkmapd/etc/initd/initd.redhat

diff --git a/utils/blkmapd/etc/initd/initd.redhat b/utils/blkmapd/etc/initd/initd.redhat
deleted file mode 100644
index d6a77e8..0000000
--- a/utils/blkmapd/etc/initd/initd.redhat
+++ /dev/null
@@ -1,76 +0,0 @@
-#!/bin/sh
-#
-# description: Starts and stops the iSCSI initiator
-#
-# processname: blkmapd
-# pidfile: /var/run/blkmapd.pid
-# config:  /etc/blkmapd.conf
-
-# Source function library.
-if [ -f /etc/init.d/functions ] ; then
-	. /etc/init.d/functions
-elif [ -f /etc/rc.d/init.d/functions ] ; then
-	. /etc/rc.d/init.d/functions
-else
-	exit 0
-fi
-
-PATH=/sbin:/bin:/usr/sbin:/usr/bin
-
-RETVAL=0
-
-start()
-{
-	echo -n $"Starting pNFS block-layout device discovery service: "
-	modprobe -q blocklayoutdriver
-	daemon /usr/sbin/blkmapd
-	RETVAL=$?
-	if [ $RETVAL -eq 0 ]; then
-		touch /var/lock/subsys/blkmapd
-	fi
-	echo
-	return $RETVAL
-}
-
-stop()
-{
-	echo -n $"Stopping pNFS block-layout device discovery service: "
-	killproc blkmapd 2> /dev/null
-	rm -f /var/run/blkmapd.pid
-	RETVAL=$?
-	[ $RETVAL -eq 0 ] && rm -f /var/lock/subsys/blkmapd
-	if [ $RETVAL -eq 0 ]; then
-                echo_success
-        else
-                echo_failure
-        fi
-	echo
-	return $RETVAL
-}
-
-restart()
-{
-	stop
-	start
-}
-
-case "$1" in
-	start)
-		start
-		;;
-	stop)
-		stop
-		;;
-	restart)
-		stop
-		start
-		;;
-	status)
-		status blkmapd
-		;;
-	*)
-	echo $"Usage: $0 {start|stop|restart|status}"
-	exit 1
-esac
-
-exit $RETVAL
-- 
1.7.4.1

