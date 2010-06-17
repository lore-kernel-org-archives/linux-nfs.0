From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 17/19] SQUASHME: pnfs-submit: merge pnfs4_proc_write_setup into nfs4_proc_write_setup
Date: Thu, 17 Jun 2010 10:51:15 -0400
Message-ID: <1276786275-13074-1-git-send-email-bhalevy@panasas.com>
References: <4C1A3570.5030709@panasas.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:36602 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932803Ab0FQOvI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Jun 2010 10:51:08 -0400
In-Reply-To: <4C1A3570.5030709@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c |   30 +++++++-----------------------
 1 files changed, 7 insertions(+), 23 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 3d15d34..667d525 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3237,6 +3237,13 @@ static void nfs4_proc_write_setup(struct nfs_write_data *data, struct rpc_messag
 	data->res.server = server;
 	data->timestamp   = jiffies;
 
+#ifdef CONFIG_NFS_V4_1
+	/* writes to DS use pnfs vector */
+	if (data->fldata.ds_nfs_client) {
+		msg->rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_PNFS_WRITE];
+		return;
+	}
+#endif /* CONFIG_NFS_V4_1 */
 	msg->rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_WRITE];
 }
 
@@ -3296,28 +3303,6 @@ pnfs4_proc_commit_setup(struct nfs_write_data *data, struct rpc_message *msg)
 	data->res.server = server;
 	msg->rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_PNFS_COMMIT];
 }
-
-/*
- * pNFS does not send a getattr on write.
- */
-static void pnfs4_proc_write_setup(struct nfs_write_data *data,
-				   struct rpc_message *msg)
-{
-	struct nfs_server *server = NFS_SERVER(data->inode);
-
-	dprintk("--> %s ds_nfs_client %p\n", __func__,
-		data->fldata.ds_nfs_client);
-
-	/* writes to MDS use non-pnfs vector */
-	if (!data->fldata.ds_nfs_client)
-		return nfs4_proc_write_setup(data, msg);
-
-	data->args.bitmask = server->attr_bitmask;
-	data->res.server = server;
-	data->timestamp   = jiffies;
-
-	msg->rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_PNFS_WRITE];
-}
 #endif /* CONFIG_NFS_V4_1 */
 
 struct nfs4_renewdata {
@@ -5978,7 +5963,6 @@ pnfs_v4_clientops_init(void)
 	struct nfs_rpc_ops *p = (struct nfs_rpc_ops *)&pnfs_v4_clientops;
 
 	memcpy(p, &nfs_v4_clientops, sizeof(*p));
-	p->write_setup		= pnfs4_proc_write_setup;
 	p->commit_setup		= pnfs4_proc_commit_setup;
 }
 #endif /* CONFIG_NFS_V4_1 */
-- 
1.6.4.4

