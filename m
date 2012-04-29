Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:55610 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754369Ab2D2Uuf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 29 Apr 2012 16:50:35 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v4 14/15] NFSv4: Don't request cache consistency attributes on some writes
Date: Sun, 29 Apr 2012 16:50:19 -0400
Message-Id: <1335732620-10445-15-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1335732620-10445-14-git-send-email-Trond.Myklebust@netapp.com>
References: <1335732620-10445-1-git-send-email-Trond.Myklebust@netapp.com>
 <1335732620-10445-2-git-send-email-Trond.Myklebust@netapp.com>
 <1335732620-10445-3-git-send-email-Trond.Myklebust@netapp.com>
 <1335732620-10445-4-git-send-email-Trond.Myklebust@netapp.com>
 <1335732620-10445-5-git-send-email-Trond.Myklebust@netapp.com>
 <1335732620-10445-6-git-send-email-Trond.Myklebust@netapp.com>
 <1335732620-10445-7-git-send-email-Trond.Myklebust@netapp.com>
 <1335732620-10445-8-git-send-email-Trond.Myklebust@netapp.com>
 <1335732620-10445-9-git-send-email-Trond.Myklebust@netapp.com>
 <1335732620-10445-10-git-send-email-Trond.Myklebust@netapp.com>
 <1335732620-10445-11-git-send-email-Trond.Myklebust@netapp.com>
 <1335732620-10445-12-git-send-email-Trond.Myklebust@netapp.com>
 <1335732620-10445-13-git-send-email-Trond.Myklebust@netapp.com>
 <1335732620-10445-14-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We don't need cache consistency information when we're doing O_DIRECT
writes. Ditto for the case of delegated writes.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c |   19 +++++++++++++++++--
 1 files changed, 17 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index c746b0c..64b67f3 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3370,7 +3370,7 @@ static int nfs4_write_done_cb(struct rpc_task *task, struct nfs_write_data *data
 	}
 	if (task->tk_status >= 0) {
 		renew_lease(NFS_SERVER(inode), data->timestamp);
-		nfs_post_op_update_inode_force_wcc(inode, data->res.fattr);
+		nfs_post_op_update_inode_force_wcc(inode, &data->fattr);
 	}
 	return 0;
 }
@@ -3401,15 +3401,30 @@ void nfs4_reset_write(struct rpc_task *task, struct nfs_write_data *data)
 }
 EXPORT_SYMBOL_GPL(nfs4_reset_write);
 
+static
+bool nfs4_write_need_cache_consistency_data(const struct nfs_write_data *data)
+{
+	const struct nfs_pgio_header *hdr = data->header;
+
+	/* Don't request attributes for pNFS or O_DIRECT writes */
+	if (data->ds_clp != NULL || hdr->dreq != NULL)
+		return false;
+	/* Otherwise, request attributes if and only if we don't hold
+	 * a delegation
+	 */
+	return nfs_have_delegation(hdr->inode, FMODE_READ) == 0;
+}
+
 static void nfs4_proc_write_setup(struct nfs_write_data *data, struct rpc_message *msg)
 {
 	struct nfs_server *server = NFS_SERVER(data->header->inode);
 
-	if (data->ds_clp) {
+	if (!nfs4_write_need_cache_consistency_data(data)) {
 		data->args.bitmask = NULL;
 		data->res.fattr = NULL;
 	} else
 		data->args.bitmask = server->cache_consistency_bitmask;
+
 	if (!data->write_done_cb)
 		data->write_done_cb = nfs4_write_done_cb;
 	data->res.server = server;
-- 
1.7.7.6

