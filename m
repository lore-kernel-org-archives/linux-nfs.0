From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/5] NFS: Treat "intr" and "nointr" options as deprecated
Date: Thu, 12 Jun 2008 12:37:41 -0400
Message-ID: <20080612163741.13197.95765.stgit@manray.1015granger.net>
References: <20080612163416.13197.92911.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.183]:1403 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752860AbYFLQhq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Jun 2008 12:37:46 -0400
Received: by wa-out-1112.google.com with SMTP id j37so2960659waf.23
        for <linux-nfs@vger.kernel.org>; Thu, 12 Jun 2008 09:37:45 -0700 (PDT)
In-Reply-To: <20080612163416.13197.92911.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up:  the "intr" and "nointr" mount options were recently retired.
Document this in the NFS mount option parser.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/super.c |   10 ++++------
 1 files changed, 4 insertions(+), 6 deletions(-)


diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 9f38309..e9dd5b6 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -65,7 +65,6 @@
 enum {
 	/* Mount options that take no arguments */
 	Opt_soft, Opt_hard,
-	Opt_intr, Opt_nointr,
 	Opt_posix, Opt_noposix,
 	Opt_cto, Opt_nocto,
 	Opt_ac, Opt_noac,
@@ -105,8 +104,8 @@ static match_table_t nfs_mount_option_tokens = {
 
 	{ Opt_soft, "soft" },
 	{ Opt_hard, "hard" },
-	{ Opt_intr, "intr" },
-	{ Opt_nointr, "nointr" },
+	{ Opt_deprecated, "intr" },
+	{ Opt_deprecated, "nointr" },
 	{ Opt_posix, "posix" },
 	{ Opt_noposix, "noposix" },
 	{ Opt_cto, "cto" },
@@ -784,9 +783,6 @@ static int nfs_parse_mount_options(char *raw,
 		case Opt_hard:
 			mnt->flags &= ~NFS_MOUNT_SOFT;
 			break;
-		case Opt_intr:
-		case Opt_nointr:
-			break;
 		case Opt_posix:
 			mnt->flags |= NFS_MOUNT_POSIX;
 			break;
@@ -1102,6 +1098,8 @@ static int nfs_parse_mount_options(char *raw,
 
 		case Opt_userspace:
 		case Opt_deprecated:
+			dfprintk(MOUNT, "NFS:   ignoring mount option "
+					"'%s'\n", p);
 			break;
 
 		default:

