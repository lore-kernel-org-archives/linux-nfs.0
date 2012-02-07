Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:53946 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753791Ab2BGQt1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Feb 2012 11:49:27 -0500
From: Weston Andros Adamson <dros@netapp.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH] NFS: add mount options 'v4.0' and 'v4.1'
Date: Tue,  7 Feb 2012 11:49:11 -0500
Message-Id: <1328633351-1741-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
Updated to add 'v4.0' as trond requested.

We'll talk about this change at connectathon.

This 'just works' with mount.nfs(8) -- v.* options are passed to the 
kernel with no modifications needed.

 fs/nfs/super.c |   14 +++++++++++++-
 1 files changed, 13 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index b88e023..d89cee2 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -80,7 +80,7 @@ enum {
 	Opt_cto, Opt_nocto,
 	Opt_ac, Opt_noac,
 	Opt_lock, Opt_nolock,
-	Opt_v2, Opt_v3, Opt_v4,
+	Opt_v2, Opt_v3, Opt_v4, Opt_v4_0, Opt_v4_1,
 	Opt_udp, Opt_tcp, Opt_rdma,
 	Opt_acl, Opt_noacl,
 	Opt_rdirplus, Opt_nordirplus,
@@ -136,6 +136,8 @@ static const match_table_t nfs_mount_option_tokens = {
 	{ Opt_v2, "v2" },
 	{ Opt_v3, "v3" },
 	{ Opt_v4, "v4" },
+	{ Opt_v4_0, "v4.0" },
+	{ Opt_v4_1, "v4.1" },
 	{ Opt_udp, "udp" },
 	{ Opt_tcp, "tcp" },
 	{ Opt_rdma, "rdma" },
@@ -1172,6 +1174,16 @@ static int nfs_parse_mount_options(char *raw,
 			mnt->flags &= ~NFS_MOUNT_VER3;
 			mnt->version = 4;
 			break;
+		case Opt_v4_0:
+			mnt->flags &= ~NFS_MOUNT_VER3;
+			mnt->version = 4;
+			mnt->minorversion = 0;
+			break;
+		case Opt_v4_1:
+			mnt->flags &= ~NFS_MOUNT_VER3;
+			mnt->version = 4;
+			mnt->minorversion = 1;
+			break;
 		case Opt_udp:
 			mnt->flags &= ~NFS_MOUNT_TCP;
 			mnt->nfs_server.protocol = XPRT_TRANSPORT_UDP;
-- 
1.7.4.4

