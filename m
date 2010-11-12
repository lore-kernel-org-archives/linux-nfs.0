Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:17286 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756024Ab0KLIt1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Nov 2010 03:49:27 -0500
Received: from localhost.localdomain (hess01-lxp.hq.netapp.com [10.58.60.52] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id oAC8n7fU025967
	for <linux-nfs@vger.kernel.org>; Fri, 12 Nov 2010 00:49:22 -0800 (PST)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 20/22] pnfs-submit refactor pnfs_layoutcommit_setup
Date: Fri, 12 Nov 2010 03:48:42 -0500
Message-Id: <1289551724-18575-21-git-send-email-iisaman@netapp.com>
In-Reply-To: <1289551724-18575-1-git-send-email-iisaman@netapp.com>
References: <1289551724-18575-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

Prepare for adding the layoutcommit operation to the close compound on
return-on-close.
Have pnfs_layoutcommit_setup handle all the layoutcommit operation setup.
Have pnfs_layoutcommit_inode handle all the layoutcommit compound setup.

Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/pnfs.c |  106 ++++++++++++++++++++++++++-------------------------------
 fs/nfs/pnfs.h |    3 ++
 2 files changed, 51 insertions(+), 58 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index b3f1946..f2ec773 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1245,98 +1245,88 @@ pnfs_try_to_commit(struct nfs_write_data *data,
 }
 
 /*
- * Set up the argument/result storage required for the RPC call.
+ * Set up the arguments required for the RPC call.
  */
-static int
+void
 pnfs_layoutcommit_setup(struct inode *inode,
-			struct nfs4_layoutcommit_data *data,
-			loff_t write_begin_pos, loff_t write_end_pos)
+			struct nfs4_layoutcommit_op_args *args, bool use_cred)
 {
-	struct nfs_server *nfss = NFS_SERVER(inode);
-	int result = 0;
+	struct nfs_inode *nfsi = NFS_I(inode);
+	loff_t write_begin_pos, write_end_pos;
 
 	dprintk("--> %s\n", __func__);
 
-	data->inode = inode;
-	data->args.fh = NFS_FH(inode);
-	data->args.op.layout_type = nfss->pnfs_curr_ld->id;
-	data->res.fattr = &data->fattr;
-	nfs_fattr_init(&data->fattr);
+	assert_spin_locked(&inode->i_lock);
 
-	/* Set values from inode so it can be reset
+	/*
+	 * Clear layoutcommit properties in the inode so
+	 * new layoutcommit info can be generated
 	 */
-	data->args.op.range.iomode = IOMODE_RW;
-	data->args.op.range.offset = write_begin_pos;
-	data->args.op.range.length = write_end_pos - write_begin_pos + 1;
-	data->args.op.lastbytewritten =  min(write_end_pos,
-					  i_size_read(inode) - 1);
-	data->args.bitmask = nfss->attr_bitmask;
-	data->res.server = nfss;
-
-	dprintk("<-- %s Status %d\n", __func__, result);
-	return result;
+	write_begin_pos = nfsi->layout->write_begin_pos;
+	write_end_pos = nfsi->layout->write_end_pos;
+	nfsi->layout->write_begin_pos = 0;
+	nfsi->layout->write_end_pos = 0;
+	/* In the true case, caller has passed on the cred to another struct */
+	if (use_cred == false)
+		put_rpccred(nfsi->layout->cred);
+	nfsi->layout->cred = NULL;
+	__clear_bit(NFS_LAYOUT_NEED_LCOMMIT, &nfsi->layout->plh_flags);
+	/* FIXME: figure out what to do here */
+	memcpy(args->stateid.data, nfsi->layout->stateid.data,
+	       NFS4_STATEID_SIZE);
+
+	args->layout_type = NFS_SERVER(inode)->pnfs_curr_ld->id;
+
+	args->range.iomode = IOMODE_RW;
+	args->range.offset = write_begin_pos;
+	args->range.length = write_end_pos - write_begin_pos + 1;
+	args->lastbytewritten =  min(write_end_pos, i_size_read(inode) - 1);
 }
 
-/* Issue a async layoutcommit for an inode.
+/*
+ * Issue a async layoutcommit for an inode.
+ * Returns 0 on success, negative value for error
  */
 int
 pnfs_layoutcommit_inode(struct inode *inode, int sync)
 {
 	struct nfs4_layoutcommit_data *data;
-	struct nfs_inode *nfsi = NFS_I(inode);
-	loff_t write_begin_pos;
-	loff_t write_end_pos;
-
-	int status = 0;
+	int status = -ENOMEM;
 
 	dprintk("%s Begin (sync:%d)\n", __func__, sync);
 
-	BUG_ON(!has_layout(nfsi));
-
 	data = kzalloc(sizeof(*data), GFP_NOFS);
 	if (!data)
-		return -ENOMEM;
+		goto out;
 
+	status = 0;
 	spin_lock(&inode->i_lock);
-	if (!layoutcommit_needed(nfsi)) {
+	if (!layoutcommit_needed(NFS_I(inode))) {
 		spin_unlock(&inode->i_lock);
-		goto out_free;
+		kfree(data);
+		goto out;
 	}
+	/* Use the layoutcommit cred */
+	data->args.cred = NFS_I(inode)->layout->cred;
 
-	/* Clear layoutcommit properties in the inode so
-	 * new lc info can be generated
-	 */
-	write_begin_pos = nfsi->layout->write_begin_pos;
-	write_end_pos = nfsi->layout->write_end_pos;
-	data->args.cred = nfsi->layout->cred;
-	nfsi->layout->write_begin_pos = 0;
-	nfsi->layout->write_end_pos = 0;
-	nfsi->layout->cred = NULL;
-	__clear_bit(NFS_LAYOUT_NEED_LCOMMIT, &nfsi->layout->plh_flags);
-	memcpy(data->args.op.stateid.data, nfsi->layout->stateid.data,
-	       NFS4_STATEID_SIZE);
+	/* Set up layoutcommit operation args */
+	pnfs_layoutcommit_setup(inode, &data->args.op, true);
 
 	/* Reference for layoutcommit matched in pnfs_layoutcommit_release */
 	get_layout_hdr(NFS_I(inode)->layout);
-
 	spin_unlock(&inode->i_lock);
 
-	/* Set up layout commit args */
-	status = pnfs_layoutcommit_setup(inode, data, write_begin_pos,
-					 write_end_pos);
-	if (status) {
-		/* The layout driver failed to setup the layoutcommit */
-		put_rpccred(data->args.cred);
-		put_layout_hdr(inode);
-		goto out_free;
-	}
+	data->args.fh = NFS_FH(inode);
+	data->args.bitmask = NFS_SERVER(inode)->attr_bitmask;
+
+	data->inode = inode;
+	data->res.server = NFS_SERVER(inode);
+	data->res.fattr = &data->fattr;
+	nfs_fattr_init(&data->fattr);
 	status = nfs4_proc_layoutcommit(data, sync);
 out:
 	dprintk("%s end (err:%d)\n", __func__, status);
 	return status;
-out_free:
-	kfree(data);
-	goto out;
 }
 
 /*
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 916a057..4812288 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -235,6 +235,9 @@ void nfs4_asynch_forget_layouts(struct pnfs_layout_hdr *lo,
 				int notify_bit, atomic_t *notify_count,
 				struct list_head *tmp_list);
 bool pnfs_roc(struct nfs4_closedata *data);
+void pnfs_layoutcommit_setup(struct inode *inode,
+			     struct nfs4_layoutcommit_op_args *args,
+			     bool use_cred);
 
 static inline bool
 has_layout(struct nfs_inode *nfsi)
-- 
1.7.2.1

