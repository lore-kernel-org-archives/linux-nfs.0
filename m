From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 11/19] SQUASHME: pnfs-submit: merge pnfs4_write_done into nfs4_write_done - part 4
Date: Thu, 17 Jun 2010 10:50:09 -0400
Message-ID: <1276786209-12598-1-git-send-email-bhalevy@panasas.com>
References: <4C1A3570.5030709@panasas.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:14460 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1760185Ab0FQOuD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Jun 2010 10:50:03 -0400
In-Reply-To: <4C1A3570.5030709@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Renew lease only for MDS writes.
Update last byte written and mark for layoutcommit for DS writes.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c |   20 ++++++++++++++++++--
 1 files changed, 18 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 60898f6..7b501ec 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3268,6 +3268,14 @@ static void nfs4_proc_read_setup(struct nfs_read_data *data, struct rpc_message
 	msg->rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_READ];
 }
 
+static void pnfs4_update_write_done(struct nfs_inode *nfsi, struct nfs_write_data *data)
+{
+#ifdef CONFIG_NFS_V4_1
+	pnfs_update_last_write(nfsi, data->args.offset, data->res.count);
+	pnfs_need_layoutcommit(nfsi, data->args.context);
+#endif /* CONFIG_NFS_V4_1 */
+}
+
 static int nfs4_write_done(struct rpc_task *task, struct nfs_write_data *data)
 {
 	struct inode *inode = data->inode;
@@ -3299,9 +3307,17 @@ static int nfs4_write_done(struct rpc_task *task, struct nfs_write_data *data)
 		nfs_restart_rpc(task, client);
 		return -EAGAIN;
 	}
+
+	/*
+	 * MDS write: renew lease
+	 * DS write: update lastbyte written, mark for layout commit
+	 */
 	if (task->tk_status >= 0) {
-		renew_lease(server, data->timestamp);
-		nfs_post_op_update_inode_force_wcc(inode, data->res.fattr);
+		if (client == server->nfs_client) {
+			renew_lease(server, data->timestamp);
+			nfs_post_op_update_inode_force_wcc(inode, data->res.fattr);
+		} else
+			pnfs4_update_write_done(NFS_I(inode), data);
 	}
 	return 0;
 }
-- 
1.6.4.4

