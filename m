Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:60121 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752858Ab2BATAZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 1 Feb 2012 14:00:25 -0500
From: Weston Andros Adamson <dros@netapp.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH 2/2] NFS: add mount option 'v4.1'
Date: Wed,  1 Feb 2012 14:00:17 -0500
Message-Id: <1328122817-661-2-git-send-email-dros@netapp.com>
In-Reply-To: <1328122817-661-1-git-send-email-dros@netapp.com>
References: <1328122817-661-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
I was already messing around with mountoptions and figured "why not".
It's been joked (?) that 4.1 really should have been NFSv5! 

 fs/nfs/super.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 50baca1..801b060 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -80,7 +80,7 @@ enum {
 	Opt_cto, Opt_nocto,
 	Opt_ac, Opt_noac,
 	Opt_lock, Opt_nolock,
-	Opt_v2, Opt_v3, Opt_v4,
+	Opt_v2, Opt_v3, Opt_v4, Opt_v4_1,
 	Opt_udp, Opt_tcp, Opt_rdma,
 	Opt_acl, Opt_noacl,
 	Opt_rdirplus, Opt_nordirplus,
@@ -136,6 +136,7 @@ static const match_table_t nfs_mount_option_tokens = {
 	{ Opt_v2, "v2" },
 	{ Opt_v3, "v3" },
 	{ Opt_v4, "v4" },
+	{ Opt_v4_1, "v4.1" },
 	{ Opt_udp, "udp" },
 	{ Opt_tcp, "tcp" },
 	{ Opt_rdma, "rdma" },
@@ -1172,6 +1173,11 @@ static int nfs_parse_mount_options(char *raw,
 			mnt->flags &= ~NFS_MOUNT_VER3;
 			mnt->version = 4;
 			break;
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

