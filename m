Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:41393 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759099Ab2CBTHR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 2 Mar 2012 14:07:17 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 3/3] NFS: Consolidate the parsing of the '-ov4.x' and '-overs=4.x' mount options
Date: Fri,  2 Mar 2012 14:07:11 -0500
Message-Id: <1330715231-20650-3-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1330715231-20650-2-git-send-email-Trond.Myklebust@netapp.com>
References: <1330715231-20650-1-git-send-email-Trond.Myklebust@netapp.com>
 <1330715231-20650-2-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/super.c |   31 +++----------------------------
 1 files changed, 3 insertions(+), 28 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 7f0c93f..f4ccdae 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -80,7 +80,6 @@ enum {
 	Opt_cto, Opt_nocto,
 	Opt_ac, Opt_noac,
 	Opt_lock, Opt_nolock,
-	Opt_v2, Opt_v3, Opt_v4, Opt_v4_0, Opt_v4_1,
 	Opt_udp, Opt_tcp, Opt_rdma,
 	Opt_acl, Opt_noacl,
 	Opt_rdirplus, Opt_nordirplus,
@@ -133,11 +132,6 @@ static const match_table_t nfs_mount_option_tokens = {
 	{ Opt_noac, "noac" },
 	{ Opt_lock, "lock" },
 	{ Opt_nolock, "nolock" },
-	{ Opt_v2, "v2" },
-	{ Opt_v3, "v3" },
-	{ Opt_v4, "v4" },
-	{ Opt_v4_0, "v4.0" },
-	{ Opt_v4_1, "v4.1" },
 	{ Opt_udp, "udp" },
 	{ Opt_tcp, "tcp" },
 	{ Opt_rdma, "rdma" },
@@ -183,6 +177,9 @@ static const match_table_t nfs_mount_option_tokens = {
 	{ Opt_fscache_uniq, "fsc=%s" },
 	{ Opt_local_lock, "local_lock=%s" },
 
+	/* The following needs to be listed after all other options */
+	{ Opt_nfsvers, "v%s" },
+
 	{ Opt_err, NULL }
 };
 
@@ -1228,28 +1225,6 @@ static int nfs_parse_mount_options(char *raw,
 			mnt->flags |= (NFS_MOUNT_LOCAL_FLOCK |
 				       NFS_MOUNT_LOCAL_FCNTL);
 			break;
-		case Opt_v2:
-			mnt->flags &= ~NFS_MOUNT_VER3;
-			mnt->version = 2;
-			break;
-		case Opt_v3:
-			mnt->flags |= NFS_MOUNT_VER3;
-			mnt->version = 3;
-			break;
-		case Opt_v4:
-			mnt->flags &= ~NFS_MOUNT_VER3;
-			mnt->version = 4;
-			break;
-		case Opt_v4_0:
-			mnt->flags &= ~NFS_MOUNT_VER3;
-			mnt->version = 4;
-			mnt->minorversion = 0;
-			break;
-		case Opt_v4_1:
-			mnt->flags &= ~NFS_MOUNT_VER3;
-			mnt->version = 4;
-			mnt->minorversion = 1;
-			break;
 		case Opt_udp:
 			mnt->flags &= ~NFS_MOUNT_TCP;
 			mnt->nfs_server.protocol = XPRT_TRANSPORT_UDP;
-- 
1.7.7.6

