Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:19442 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754794AbaHLTIX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Aug 2014 15:08:23 -0400
Received: from int-mx13.intmail.prod.int.phx2.redhat.com (int-mx13.intmail.prod.int.phx2.redhat.com [10.5.11.26])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s7CJ8Nmi015053
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 12 Aug 2014 15:08:23 -0400
Received: from bighat.boston.devel.redhat.com (bighat.boston.devel.redhat.com [10.19.60.55])
	by int-mx13.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id s7CJ8NHu012384
	for <linux-nfs@vger.kernel.org>; Tue, 12 Aug 2014 15:08:23 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] server: Added -A flag which will cause server script to ask to mount.
Date: Tue, 12 Aug 2014 15:08:06 -0400
Message-Id: <1407870486-7215-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

By default the server script will no longer ask to mount. Use
the new -A flag to restore the asking about the mount

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 server | 31 ++++++++++++++++++-------------
 1 file changed, 18 insertions(+), 13 deletions(-)

diff --git a/server b/server
index 439c96f..e63f6d5 100755
--- a/server
+++ b/server
@@ -11,6 +11,7 @@
 #	-c		use cachefs; need to specify cachefs mount
 #			options with -o
 #	-N passes	repeat "passes" times
+#   -A    Ask before doing the mount [default: no]
 #	mnt_options	arg to -o mount options
 #	server_path	path to mount from server
 #	mntpoint	path to mount on locally
@@ -19,15 +20,16 @@
 Program=`basename $0`
 
 InitFile="./tests.init"
-USAGE="usage:  $Program [-a|-b|-g|-s|-l|-c] [-f|-t|-n|-h|-C] [-o mnt_options] [-p server_path] [-m mntpoint] [-N passes] server_name"
+USAGE="usage:  $Program [-a|-b|-B|-g|-s|-l|-c] [-f|-t|-n|-h|-C] [-o mnt_options] [-p server_path] [-m mntpoint] [-N passes] server_name"
 
 # defaults
 . $InitFile
 export PATH CFLAGS LIBS MOUNT UMOUNT MNTOPTIONS
 
 passes="1"
+askt2mnt="no"
 
-set - `getopt abcCfglhm:N:no:p:st $*`
+set - `getopt aAbcCfglhm:N:no:p:st $*`
 
 if [ $? != 0 ]
 then
@@ -40,6 +42,7 @@ do
 		-a|-b|-g|-s|-l)	TEST=$c; shift	;;
 		-f|-n|-t)	TESTARG=$c; shift	;;
 		-c)		cachefs="yes"; shift	;;
+		-A)		ask2mnt="yes"; shift ;;
 		-C)		CIFS="yes"; export CIFS; shift ;;
 		-h)		HARDLINKS=n; export HARDLINKS; shift	;;
 		-m)		USRMNTPOINT=$2; shift; shift	;;
@@ -124,18 +127,20 @@ HOSTNAME=`hostname`
 HOSTNAME=`expr $HOSTNAME : '\([^.]*\)'`
 NFSTESTDIR=$MNTPOINT/$HOSTNAME.test
 export NFSTESTDIR
-echo $DASHN "Start tests on path $NFSTESTDIR [y/n]?" "$BLC"
-read ans
-case $ans in
-    Y*|y*)
-	;;
-    *)
-	echo "Terminating ($MNTPOINT left mounted)."
-	exit 1
-	;;
-esac
-	
+if test $ask2mnt = "yes" 
+then
+	echo $DASHN "Start tests on path $NFSTESTDIR [y/n]?" "$BLC"
+	read ans
+	case $ans in
+    	Y*|y*)
+		;;
+    	*)
+		echo "Terminating ($MNTPOINT left mounted)."
+		exit 1
+		;;
+	esac
 echo ""
+fi
 
 if test $passes = "1"
 then
-- 
1.9.3

