Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:64950 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751323Ab0LJGIn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Dec 2010 01:08:43 -0500
Received: from localhost.localdomain (kozen-lxp.hq.netapp.com [10.58.53.114] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id oBA68VLg023313
	for <linux-nfs@vger.kernel.org>; Thu, 9 Dec 2010 22:08:41 -0800 (PST)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 05/22] Revert "pnfs-submit refactor pnfs_layoutcommit_setup"
Date: Thu,  9 Dec 2010 20:22:40 -0500
Message-Id: <1291944177-7819-6-git-send-email-iisaman@netapp.com>
In-Reply-To: <1291944177-7819-1-git-send-email-iisaman@netapp.com>
References: <1291944177-7819-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

This reverts commit 536da3e86e791f72b2ef81831391d2f1e9dd38f7.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/pnfs.c |  106 +++++++++++++++++++++++++++++++--------------------------
 fs/nfs/pnfs.h |    3 --
 2 files changed, 58 insertions(+), 51 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 4746b20..36955e1 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1191,88 +1191,98 @@ pnfs_try_to_commit(struct nfs_write_data *data,
 }
 
 /*
- * Set up the arguments required for the RPC call.
+ * Set up the argument/result storage required for the RPC call.
  */
-void
+static int
 pnfs_layoutcommit_setup(struct inode *inode,
-			struct nfs4_layoutcommit_op_args *args, bool use_cred)
+			struct nfs4_layoutcommit_data *data,
+			loff_t write_begin_pos, loff_t write_end_pos)
 {
-	struct nfs_inode *nfsi = NFS_I(inode);
-	loff_t write_begin_pos, write_end_pos;
+	struct nfs_server *nfss = NFS_SERVER(inode);
+	int result = 0;
 
 	dprintk("--> %s\n", __func__);
 
-	assert_spin_locked(&inode->i_lock);
+	data->inode = inode;
+	data->args.fh = NFS_FH(inode);
+	data->args.op.layout_type = nfss->pnfs_curr_ld->id;
+	data->res.fattr = &data->fattr;
+	nfs_fattr_init(&data->fattr);
 
-	/*
-	 * Clear layoutcommit properties in the inode so
-	 * new layoutcommit info can be generated
+	/* Set values from inode so it can be reset
 	 */
-	write_begin_pos = nfsi->layout->write_begin_pos;
-	write_end_pos = nfsi->layout->write_end_pos;
-	nfsi->layout->write_begin_pos = 0;
-	nfsi->layout->write_end_pos = 0;
-	/* In the true case, caller has passed on the cred to another struct */
-	if (use_cred == false)
-		put_rpccred(nfsi->layout->cred);
-	nfsi->layout->cred = NULL;
-	__clear_bit(NFS_LAYOUT_NEED_LCOMMIT, &nfsi->layout->plh_flags);
-	/* FIXME: figure out what to do here */
-	memcpy(args->stateid.data, nfsi->layout->stateid.data,
-	       NFS4_STATEID_SIZE);
-
-	args->layout_type = NFS_SERVER(inode)->pnfs_curr_ld->id;
-
-	args->range.iomode = IOMODE_RW;
-	args->range.offset = write_begin_pos;
-	args->range.length = write_end_pos - write_begin_pos + 1;
-	args->lastbytewritten =  min(write_end_pos, i_size_read(inode) - 1);
+	data->args.op.range.iomode = IOMODE_RW;
+	data->args.op.range.offset = write_begin_pos;
+	data->args.op.range.length = write_end_pos - write_begin_pos + 1;
+	data->args.op.lastbytewritten =  min(write_end_pos,
+					  i_size_read(inode) - 1);
+	data->args.bitmask = nfss->attr_bitmask;
+	data->res.server = nfss;
+
+	dprintk("<-- %s Status %d\n", __func__, result);
+	return result;
 }
 
-/*
- * Issue a async layoutcommit for an inode.
- * Returns 0 on success, negative value for error
+/* Issue a async layoutcommit for an inode.
  */
 int
 pnfs_layoutcommit_inode(struct inode *inode, int sync)
 {
 	struct nfs4_layoutcommit_data *data;
-	int status = -ENOMEM;
+	struct nfs_inode *nfsi = NFS_I(inode);
+	loff_t write_begin_pos;
+	loff_t write_end_pos;
+
+	int status = 0;
 
 	dprintk("%s Begin (sync:%d)\n", __func__, sync);
 
+	BUG_ON(!has_layout(nfsi));
+
 	data = kzalloc(sizeof(*data), GFP_NOFS);
 	if (!data)
-		goto out;
+		return -ENOMEM;
 
-	status = 0;
 	spin_lock(&inode->i_lock);
-	if (!layoutcommit_needed(NFS_I(inode))) {
+	if (!layoutcommit_needed(nfsi)) {
 		spin_unlock(&inode->i_lock);
-		kfree(data);
-		goto out;
+		goto out_free;
 	}
-	/* Use the layoutcommit cred */
-	data->args.cred = NFS_I(inode)->layout->cred;
 
-	/* Set up layoutcommit operation args */
-	pnfs_layoutcommit_setup(inode, &data->args.op, true);
+	/* Clear layoutcommit properties in the inode so
+	 * new lc info can be generated
+	 */
+	write_begin_pos = nfsi->layout->write_begin_pos;
+	write_end_pos = nfsi->layout->write_end_pos;
+	data->args.cred = nfsi->layout->cred;
+	nfsi->layout->write_begin_pos = 0;
+	nfsi->layout->write_end_pos = 0;
+	nfsi->layout->cred = NULL;
+	__clear_bit(NFS_LAYOUT_NEED_LCOMMIT, &nfsi->layout->plh_flags);
+	memcpy(data->args.op.stateid.data, nfsi->layout->stateid.data,
+	       NFS4_STATEID_SIZE);
 
 	/* Reference for layoutcommit matched in pnfs_layoutcommit_release */
 	get_layout_hdr(NFS_I(inode)->layout);
-	spin_unlock(&inode->i_lock);
 
-	data->args.fh = NFS_FH(inode);
-	data->args.bitmask = NFS_SERVER(inode)->attr_bitmask;
+	spin_unlock(&inode->i_lock);
 
-	data->inode = inode;
-	data->res.server = NFS_SERVER(inode);
-	data->res.fattr = &data->fattr;
-	nfs_fattr_init(&data->fattr);
+	/* Set up layout commit args */
+	status = pnfs_layoutcommit_setup(inode, data, write_begin_pos,
+					 write_end_pos);
+	if (status) {
+		/* The layout driver failed to setup the layoutcommit */
+		put_rpccred(data->args.cred);
+		put_layout_hdr(inode);
+		goto out_free;
+	}
 	status = nfs4_proc_layoutcommit(data, sync);
 out:
 	dprintk("%s end (err:%d)\n", __func__, status);
 	return status;
+out_free:
+	kfree(data);
+	goto out;
 }
 
 /*
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 8ef47e9..7029926 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -231,9 +231,6 @@ void nfs4_asynch_forget_layouts(struct pnfs_layout_hdr *lo,
 				int notify_bit, atomic_t *notify_count,
 				struct list_head *tmp_list);
 bool pnfs_roc(struct nfs4_closedata *data);
-void pnfs_layoutcommit_setup(struct inode *inode,
-			     struct nfs4_layoutcommit_op_args *args,
-			     bool use_cred);
 
 static inline bool
 has_layout(struct nfs_inode *nfsi)
-- 
1.7.2.1

