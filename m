Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f172.google.com ([209.85.212.172]:36644 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753114Ab2JEXOs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Oct 2012 19:14:48 -0400
Received: by mail-wi0-f172.google.com with SMTP id hq12so1436417wib.1
        for <linux-nfs@vger.kernel.org>; Fri, 05 Oct 2012 16:14:46 -0700 (PDT)
From: =?UTF-8?q?Mantas=20Mikul=C4=97nas?= <grawity@gmail.com>
To: linux-nfs@vger.kernel.org
Cc: =?UTF-8?q?Mantas=20Mikul=C4=97nas?= <grawity@gmail.com>
Subject: [PATCH] utils: Return status 0 on clean exits
Date: Sat,  6 Oct 2012 02:14:26 +0300
Message-Id: <1349478866-680992-1-git-send-email-grawity@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Some init systems actually expect daemons to return 0 on success.
---
 utils/gssd/gssd.c     | 2 +-
 utils/gssd/svcgssd.c  | 2 +-
 utils/mountd/mountd.c | 3 ++-
 utils/statd/statd.c   | 3 ++-
 4 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/utils/gssd/gssd.c b/utils/gssd/gssd.c
index 7825255..a3292c9 100644
--- a/utils/gssd/gssd.c
+++ b/utils/gssd/gssd.c
@@ -71,7 +71,7 @@ sig_die(int signal)
 	if (root_uses_machine_creds)
 		gssd_destroy_krb5_machine_creds();
 	printerr(1, "exiting on signal %d\n", signal);
-	exit(1);
+	exit(0);
 }
 
 void
diff --git a/utils/gssd/svcgssd.c b/utils/gssd/svcgssd.c
index 1afff9e..8aee3b2 100644
--- a/utils/gssd/svcgssd.c
+++ b/utils/gssd/svcgssd.c
@@ -153,7 +153,7 @@ sig_die(int signal)
 {
 	/* destroy krb5 machine creds */
 	printerr(1, "exiting on signal %d\n", signal);
-	exit(1);
+	exit(0);
 }
 
 void
diff --git a/utils/mountd/mountd.c b/utils/mountd/mountd.c
index bcf5080..993b6e6 100644
--- a/utils/mountd/mountd.c
+++ b/utils/mountd/mountd.c
@@ -196,7 +196,8 @@ killer (int sig)
 		wait_for_workers();
 	}
 	cleanup_lockfiles();
-	xlog (L_FATAL, "Caught signal %d, un-registering and exiting.", sig);
+	xlog (L_NOTICE, "Caught signal %d, un-registering and exiting.", sig);
+	exit(0);
 }
 
 static void
diff --git a/utils/statd/statd.c b/utils/statd/statd.c
index 01fdb41..652546c 100644
--- a/utils/statd/statd.c
+++ b/utils/statd/statd.c
@@ -99,7 +99,8 @@ static void
 killer (int sig)
 {
 	statd_unregister ();
-	xlog_err ("Caught signal %d, un-registering and exiting", sig);
+	xlog(D_GENERAL, "Caught signal %d, un-registering and exiting", sig);
+	exit(0);
 }
 
 static void
-- 
1.7.12.2

