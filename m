Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-lb0-f182.google.com ([209.85.217.182]:36976 "EHLO
	mail-lb0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753680AbaHFMB3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Aug 2014 08:01:29 -0400
From: Pavel Shilovsky <pshilovsky@samba.org>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org,
        Jeff Layton <jlayton@samba.org>, Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 2/5] Add SMB/CIFS mounts support
Date: Wed,  6 Aug 2014 16:01:09 +0400
Message-Id: <1407326472-13853-3-git-send-email-pshilovsky@samba.org>
In-Reply-To: <1407326472-13853-1-git-send-email-pshilovsky@samba.org>
References: <1407326472-13853-1-git-send-email-pshilovsky@samba.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Jeff Layton <jlayton@redhat.com>

The connectathon tests are also useful for testing SMB/CIFS filesystems
but when running without unix extensions, some tests are expected to fail.
Add a "CIFS mode" that skips tests that are known to fail when running on
CIFS filesystems without POSIX extensions.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
Signed-off-by: Pavel Shilovsky <pshilovsky@samba.org>
---
 basic/runtests       |  8 +++++---
 lock/runtests        |  4 ++++
 lock/tlock.c         | 10 ++++++++--
 server               |  5 +++--
 special/runtests.wrk |  2 +-
 5 files changed, 21 insertions(+), 8 deletions(-)

diff --git a/basic/runtests b/basic/runtests
index 32e1d85..16b2402 100644
--- a/basic/runtests
+++ b/basic/runtests
@@ -37,10 +37,12 @@ echo ""
 
 # Setattr, getattr and lookup tests
 echo ""
-./test4 $TESTARG
+if [ "$CIFS" != "yes" ]; then
+	./test4 $TESTARG
 # Getattr and lookup tests
-# echo ""
-# ./test4a $TESTARG
+else
+	./test4a $TESTARG
+fi
 
 # Write and read tests
 echo ""
diff --git a/lock/runtests b/lock/runtests
index a25f101..006742e 100644
--- a/lock/runtests
+++ b/lock/runtests
@@ -41,6 +41,10 @@ then
 	TESTARGS="-v 2 $TESTARGS"
 fi
 
+if [ "$CIFS" = "yes" ]; then
+	TESTARGS="-c $TESTARGS"
+fi
+
 for i in $LOCKTESTS
 do
 	echo ""
diff --git a/lock/tlock.c b/lock/tlock.c
index 6e19a3d..8c837a8 100644
--- a/lock/tlock.c
+++ b/lock/tlock.c
@@ -105,6 +105,8 @@ static off_t maxeof;
 #define	DO_TEST(n)	((testnum == 0) || (testnum == (n)))
 #define	DO_RATE(n)	((ratetest > 0) || (testnum == (n)))
 #define	DO_MAND(n)	((mandtest > 0) || (testnum == (n)))
+/* exclude stuff known to fail on CIFS w/o unix extensions */
+#define DO_CIFS		(!cifstest)
 
 #define	DO_UNLINK	1
 #define	JUST_CLOSE	0
@@ -119,6 +121,7 @@ static off_t maxeof;
 static int ratetest = 0;
 static int ratecount = 1000;		/* test 8 */
 static int mandtest = 0;
+static int cifstest = 0;
 
 static int iorate_kb = 256;		/* test 14 */
 static int iorate_count = 10;		/* test 14 */
@@ -1600,7 +1603,7 @@ runtests()
 	if (DO_MAND(9)) {
 		test9();
 	}
-	if (DO_TEST(10)) {
+	if (DO_TEST(10) && DO_CIFS) {
 		test10();
 	}
 	if (DO_TEST(11)) {
@@ -1637,8 +1640,11 @@ main(argc, argv)
 
 	passcnt = 1;	/* default, test for 1 pass */
 
-	while ((c = getopt(argc, argv, "p:t:rmv:w:")) != -1) {
+	while ((c = getopt(argc, argv, "cp:t:rmv:w:")) != -1) {
 		switch (c) {
+		case 'c':
+			cifstest++;
+			break;
 		case 'p':
 			sscanf(optarg, "%d", &passcnt);
 			break;
diff --git a/server b/server
index 0a76f33..439c96f 100755
--- a/server
+++ b/server
@@ -19,7 +19,7 @@
 Program=`basename $0`
 
 InitFile="./tests.init"
-USAGE="usage:  $Program [-a|-b|-g|-s|-l|-c] [-f|-t|-n|-h] [-o mnt_options] [-p server_path] [-m mntpoint] [-N passes] server_name"
+USAGE="usage:  $Program [-a|-b|-g|-s|-l|-c] [-f|-t|-n|-h|-C] [-o mnt_options] [-p server_path] [-m mntpoint] [-N passes] server_name"
 
 # defaults
 . $InitFile
@@ -27,7 +27,7 @@ export PATH CFLAGS LIBS MOUNT UMOUNT MNTOPTIONS
 
 passes="1"
 
-set - `getopt abcfglhm:N:no:p:st $*`
+set - `getopt abcCfglhm:N:no:p:st $*`
 
 if [ $? != 0 ]
 then
@@ -40,6 +40,7 @@ do
 		-a|-b|-g|-s|-l)	TEST=$c; shift	;;
 		-f|-n|-t)	TESTARG=$c; shift	;;
 		-c)		cachefs="yes"; shift	;;
+		-C)		CIFS="yes"; export CIFS; shift ;;
 		-h)		HARDLINKS=n; export HARDLINKS; shift	;;
 		-m)		USRMNTPOINT=$2; shift; shift	;;
 		-o)		MNTOPTIONS=$2; export MNTOPTIONS;
diff --git a/special/runtests.wrk b/special/runtests.wrk
index 9543761..a941d33 100644
--- a/special/runtests.wrk
+++ b/special/runtests.wrk
@@ -64,7 +64,7 @@ echo ""
 echo "test holey file support"
 ./holey
 
-if [ "$HARDLINKS"o != no ]
+if [ "$HARDLINKS"o != no -a "$CIFS" != "yes" ]
 then
 	echo ""
 	echo "second check for lost reply on non-idempotent requests"
-- 
1.8.1.2

