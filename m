Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-lb0-f169.google.com ([209.85.217.169]:59858 "EHLO
	mail-lb0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754795AbaHFMBb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Aug 2014 08:01:31 -0400
From: Pavel Shilovsky <pshilovsky@samba.org>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org,
        Jeff Layton <jlayton@samba.org>
Subject: [PATCH 3/5] Add capability to test SMB 2.0 and higher verions
Date: Wed,  6 Aug 2014 16:01:10 +0400
Message-Id: <1407326472-13853-4-git-send-email-pshilovsky@samba.org>
In-Reply-To: <1407326472-13853-1-git-send-email-pshilovsky@samba.org>
References: <1407326472-13853-1-git-send-email-pshilovsky@samba.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Pavel Shilovsky <pshilovsky@samba.org>
---
 lock/runtests        | 5 +++--
 special/runtests.wrk | 9 +++++++--
 2 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/lock/runtests b/lock/runtests
index 006742e..21b09a5 100644
--- a/lock/runtests
+++ b/lock/runtests
@@ -36,7 +36,7 @@ case $TESTARG in
 	-t)	TESTARGS="-r"	;;
 esac
 
-if echo "$mntopts" | grep vers=2 > /dev/null
+if [ "$CIFS" != "yes" ] && echo "$mntopts" | grep vers=2 > /dev/null
 then
 	TESTARGS="-v 2 $TESTARGS"
 fi
@@ -52,7 +52,8 @@ do
 		tlock)		echo 'Testing native pre-LFS locking';;
 		tlocklfs)	echo 'Testing native post-LFS locking';;
 		tlock64)
-			if echo "$mntopts" | grep vers=2 > /dev/null
+			if [ "$CIFS" != "yes" ] &&
+			   echo "$mntopts" | grep vers=2 > /dev/null
 			then
 			echo "64-bit locking not supported with NFS v2"
 				echo " "
diff --git a/special/runtests.wrk b/special/runtests.wrk
index a941d33..8f099fa 100644
--- a/special/runtests.wrk
+++ b/special/runtests.wrk
@@ -25,7 +25,12 @@ TMPDIR= ./op_unlk
 
 echo ""
 echo "check for proper open/rename operation"
-TMPDIR= ./op_ren
+if [ "$CIFS" = "yes" ] && echo $MNTOPTIONS | grep -E "vers=2|vers=3" > /dev/null
+then
+	echo "skipping test; not supported by SMB 2.0 and higher versions"
+else
+	TMPDIR= ./op_ren
+fi
 
 echo ""
 echo "check for proper open/chmod 0 operation"
@@ -93,7 +98,7 @@ echo "write/read" $size "MB file"
 
 echo ""
 echo "write/read at 2GB, 4GB edges"
-if echo $MNTOPTIONS | grep vers=2 > /dev/null
+if [ "$CIFS" != "yes" ] && echo $MNTOPTIONS | grep vers=2 > /dev/null
 then
 	echo "skipping test; not supported with v2"
 else
-- 
1.8.1.2

