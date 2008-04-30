From: Chuck Lever <chucklever@gmail.com>
Subject: [PATCH 2/6] NFS: Treat "intr" and "nointr" options as deprecated
Date: Wed, 30 Apr 2008 11:59:49 -0400
Message-ID: <20080430155949.32402.58428.stgit@manray.1015granger.net>
References: <20080430154011.32402.42101.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: jlayton@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.230]:53280 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756463AbYD3P7y (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Apr 2008 11:59:54 -0400
Received: by wx-out-0506.google.com with SMTP id h31so559410wxd.4
        for <linux-nfs@vger.kernel.org>; Wed, 30 Apr 2008 08:59:52 -0700 (PDT)
In-Reply-To: <20080430154011.32402.42101.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up:  the "intr" and "nointr" mount options were recently retired.
Document this in the NFS mount option parser.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/super.c |    9 +++------
 1 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index d199f7c..b69e3ec 100644
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
@@ -1102,6 +1098,7 @@ static int nfs_parse_mount_options(char *raw,
 
 		case Opt_userspace:
 		case Opt_deprecated:
+			dfprintk(MOUNT, "NFS:   ignoring nfs mount option '%s'\n", p);
 			break;
 
 		default:

