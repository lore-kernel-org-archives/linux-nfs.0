From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 36/37] NFS: Treat "intr" and "nointr" options as deprecated
Date: Thu, 12 Jun 2008 15:22:01 -0400
Message-ID: <20080612192201.24528.16000.stgit@localhost.localdomain>
References: <20080612192159.24528.43756.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Chuck Lever <chuck.lever@oracle.com>,
	Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:63672 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754993AbYFLTeM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Jun 2008 15:34:12 -0400
In-Reply-To: <20080612192159.24528.43756.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Chuck Lever <chuck.lever@oracle.com>

Clean up:  the "intr" and "nointr" mount options were recently retired.
Document this in the NFS mount option parser.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/super.c |   10 ++++------
 1 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index dea138b..09e563b 100644
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
@@ -787,9 +786,6 @@ static int nfs_parse_mount_options(char *raw,
 		case Opt_hard:
 			mnt->flags &= ~NFS_MOUNT_SOFT;
 			break;
-		case Opt_intr:
-		case Opt_nointr:
-			break;
 		case Opt_posix:
 			mnt->flags |= NFS_MOUNT_POSIX;
 			break;
@@ -1105,6 +1101,8 @@ static int nfs_parse_mount_options(char *raw,
 
 		case Opt_userspace:
 		case Opt_deprecated:
+			dfprintk(MOUNT, "NFS:   ignoring mount option "
+					"'%s'\n", p);
 			break;
 
 		default:

