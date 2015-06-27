Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:35521 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752400AbbF0PwT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 27 Jun 2015 11:52:19 -0400
Received: by iebrt9 with SMTP id rt9so92402273ieb.2
        for <linux-nfs@vger.kernel.org>; Sat, 27 Jun 2015 08:52:19 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] NFSv4.2: LAYOUTSTATS is optional to implement
Date: Sat, 27 Jun 2015 11:52:14 -0400
Message-Id: <1435420334-12967-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1435420334-12967-1-git-send-email-trond.myklebust@primarydata.com>
References: <1435420334-12967-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Make it so, by checking the return value for NFS4ERR_MOTSUPP and
caching the information as a server capability.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs42proc.c        | 10 ++++++++--
 fs/nfs/nfs4proc.c         |  3 ++-
 fs/nfs/pnfs.c             |  3 +++
 include/linux/nfs_fs_sb.h |  1 +
 4 files changed, 14 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index 06c74cd93875..f486b80f927a 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -189,9 +189,15 @@ nfs42_layoutstat_done(struct rpc_task *task, void *calldata)
 	if (!nfs4_sequence_done(task, &data->res.seq_res))
 		return;
 
-	/* well, we don't care about errors at all! */
-	if (task->tk_status)
+	switch (task->tk_status) {
+	case 0:
+		break;
+	case -ENOTSUPP:
+	case -EOPNOTSUPP:
+		NFS_SERVER(data->inode)->caps &= ~NFS_CAP_LAYOUTSTATS;
+	default:
 		dprintk("%s server returns %d\n", __func__, task->tk_status);
+	}
 }
 
 static void
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 643ce3a91b22..8eab42407d39 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -8635,7 +8635,8 @@ static const struct nfs4_minor_version_ops nfs_v4_2_minor_ops = {
 		| NFS_CAP_ATOMIC_OPEN_V1
 		| NFS_CAP_ALLOCATE
 		| NFS_CAP_DEALLOCATE
-		| NFS_CAP_SEEK,
+		| NFS_CAP_SEEK
+		| NFS_CAP_LAYOUTSTATS,
 	.init_client = nfs41_init_client,
 	.shutdown_client = nfs41_shutdown_client,
 	.match_stateid = nfs41_match_stateid,
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 40bacebb5b97..0ba9a02c9566 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -2266,6 +2266,9 @@ pnfs_report_layoutstat(struct inode *inode)
 	if (!pnfs_enabled_sb(server) || !ld->prepare_layoutstats)
 		goto out;
 
+	if (!nfs_server_capable(inode, NFS_CAP_LAYOUTSTATS))
+		goto out;
+
 	if (test_and_set_bit(NFS_INO_LAYOUTSTATS, &nfsi->flags))
 		goto out;
 
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 5e1273d4de14..a2ea1491d3df 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -237,5 +237,6 @@ struct nfs_server {
 #define NFS_CAP_SEEK		(1U << 19)
 #define NFS_CAP_ALLOCATE	(1U << 20)
 #define NFS_CAP_DEALLOCATE	(1U << 21)
+#define NFS_CAP_LAYOUTSTATS	(1U << 22)
 
 #endif
-- 
2.4.3

