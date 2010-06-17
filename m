From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 18/19] SQUASHME: pnfs-submit: merge pnfs4_proc_commit_setup into nfs4_proc_commit_setup
Date: Thu, 17 Jun 2010 10:51:25 -0400
Message-ID: <1276786285-13117-1-git-send-email-bhalevy@panasas.com>
References: <4C1A3570.5030709@panasas.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:16701 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932915Ab0FQOvT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Jun 2010 10:51:19 -0400
In-Reply-To: <4C1A3570.5030709@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c |   28 ++++++----------------------
 1 files changed, 6 insertions(+), 22 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 667d525..915e7cb 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3281,29 +3281,14 @@ static void nfs4_proc_commit_setup(struct nfs_write_data *data, struct rpc_messa
 	
 	data->args.bitmask = server->cache_consistency_bitmask;
 	data->res.server = server;
-	msg->rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_COMMIT];
-}
-
 #if defined(CONFIG_NFS_V4_1)
-/*
- * pNFS doew not send a getattr to Data Servers on commit.
- */
-static void
-pnfs4_proc_commit_setup(struct nfs_write_data *data, struct rpc_message *msg)
-{
-	struct nfs_server *server = NFS_SERVER(data->inode);
-
-	dprintk("--> %s ds_nfs_client %p\n", __func__,
-		data->fldata.ds_nfs_client);
-
-	if (!data->fldata.ds_nfs_client)
-		return nfs4_proc_commit_setup(data, msg);
-
-	data->args.bitmask = server->attr_bitmask;
-	data->res.server = server;
-	msg->rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_PNFS_COMMIT];
-}
+	if (data->fldata.ds_nfs_client) {
+		msg->rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_PNFS_COMMIT];
+		return;
+	}
 #endif /* CONFIG_NFS_V4_1 */
+	msg->rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_COMMIT];
+}
 
 struct nfs4_renewdata {
 	struct nfs_client	*client;
@@ -5963,7 +5948,6 @@ pnfs_v4_clientops_init(void)
 	struct nfs_rpc_ops *p = (struct nfs_rpc_ops *)&pnfs_v4_clientops;
 
 	memcpy(p, &nfs_v4_clientops, sizeof(*p));
-	p->commit_setup		= pnfs4_proc_commit_setup;
 }
 #endif /* CONFIG_NFS_V4_1 */
 
-- 
1.6.4.4

