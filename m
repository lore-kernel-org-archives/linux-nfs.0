Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56212 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754020AbbKGSOP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 7 Nov 2015 13:14:15 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (Postfix) with ESMTPS id 1ACFCE707F
	for <linux-nfs@vger.kernel.org>; Sat,  7 Nov 2015 18:14:15 +0000 (UTC)
Received: from smallhat.boston.devel.redhat.com (vpn-59-101.rdu2.redhat.com [10.10.59.101])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id tA7IECrN027545
	for <linux-nfs@vger.kernel.org>; Sat, 7 Nov 2015 13:14:14 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 2/3] gssd: log all fatal errors
Date: Sat,  7 Nov 2015 13:14:09 -0500
Message-Id: <1446920050-5968-3-git-send-email-steved@redhat.com>
In-Reply-To: <1446920050-5968-1-git-send-email-steved@redhat.com>
References: <1446920050-5968-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When gssd exist ensure a error message is logged.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/gssd/gssd.c      | 12 ++++++------
 utils/gssd/gssd_proc.c |  2 +-
 utils/gssd/krb5_util.c |  2 +-
 3 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/utils/gssd/gssd.c b/utils/gssd/gssd.c
index 078e558..804c53a 100644
--- a/utils/gssd/gssd.c
+++ b/utils/gssd/gssd.c
@@ -716,7 +716,7 @@ gssd_inotify_cb(int ifd, short UNUSED(which), void *UNUSED(data))
 
 found:
 			if (!tdi) {
-				printerr(1, "inotify event for unknown wd!!! - "
+				printerr(5, "inotify event for unknown wd!!! - "
 					 "ev->wd (%d) ev->name (%s) ev->mask (0x%08x)\n",
 					 ev->wd, ev->len > 0 ? ev->name : "<?>", ev->mask);
 				rescan = true;
@@ -820,7 +820,7 @@ main(int argc, char *argv[])
 	 * the results of getpw*.
 	 */
 	if (setenv("HOME", "/", 1)) {
-		printerr(1, "Unable to set $HOME: %s\n", strerror(errno));
+		printerr(0, "gssd: Unable to set $HOME: %s\n", strerror(errno));
 		exit(1);
 	}
 
@@ -891,19 +891,19 @@ main(int argc, char *argv[])
 
 	pipefs_dir = opendir(pipefs_path);
 	if (!pipefs_dir) {
-		printerr(1, "ERROR: opendir(%s) failed: %s\n", pipefs_path, strerror(errno));
+		printerr(0, "ERROR: opendir(%s) failed: %s\n", pipefs_path, strerror(errno));
 		exit(EXIT_FAILURE);
 	}
 
 	pipefs_fd = dirfd(pipefs_dir);
 	if (fchdir(pipefs_fd)) {
-		printerr(1, "ERROR: fchdir(%s) failed: %s\n", pipefs_path, strerror(errno));
+		printerr(0, "ERROR: fchdir(%s) failed: %s\n", pipefs_path, strerror(errno));
 		exit(EXIT_FAILURE);
 	}
 
 	inotify_fd = inotify_init1(IN_NONBLOCK);
 	if (inotify_fd == -1) {
-		printerr(1, "ERROR: inotify_init1 failed: %s\n", strerror(errno));
+		printerr(0, "ERROR: inotify_init1 failed: %s\n", strerror(errno));
 		exit(EXIT_FAILURE);
 	}
 
@@ -920,7 +920,7 @@ main(int argc, char *argv[])
 
 	event_dispatch();
 
-	printerr(1, "ERROR: event_dispatch() returned!\n");
+	printerr(0, "ERROR: event_dispatch() returned!\n");
 	return EXIT_FAILURE;
 }
 
diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index 3d9ca75..29f0e24 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -703,7 +703,7 @@ no_fork:
 	 * try to use it after this point.
 	 */
 	if (serialize_context_for_kernel(&pd.pd_ctx, &token, &krb5oid, NULL)) {
-		printerr(0, "WARNING: Failed to serialize krb5 context for "
+		printerr(1, "WARNING: Failed to serialize krb5 context for "
 			    "user with uid %d for server %s\n",
 			 uid, clp->servername);
 		goto out_return_error;
diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
index 1d91483..0d07d1f 100644
--- a/utils/gssd/krb5_util.c
+++ b/utils/gssd/krb5_util.c
@@ -383,7 +383,7 @@ gssd_get_single_krb5_cred(krb5_context context,
 			 "tickets.  May have problems behind a NAT.\n");
 #ifdef TEST_SHORT_LIFETIME
 	/* set a short lifetime (for debugging only!) */
-	printerr(0, "WARNING: Using (debug) short machine cred lifetime!\n");
+	printerr(1, "WARNING: Using (debug) short machine cred lifetime!\n");
 	krb5_get_init_creds_opt_set_tkt_life(init_opts, 5*60);
 #endif
 	opts = init_opts;
-- 
2.4.3

