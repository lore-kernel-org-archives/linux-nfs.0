From: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 08/10] pnfs-submit: change nfsi->layout to a pointer
Date: Mon, 14 Jun 2010 21:46:13 -0400
Message-ID: <1276566375-24566-9-git-send-email-iisaman@netapp.com>
References: <1276566375-24566-1-git-send-email-iisaman@netapp.com>
 <1276566375-24566-2-git-send-email-iisaman@netapp.com>
 <1276566375-24566-3-git-send-email-iisaman@netapp.com>
 <1276566375-24566-4-git-send-email-iisaman@netapp.com>
 <1276566375-24566-5-git-send-email-iisaman@netapp.com>
 <1276566375-24566-6-git-send-email-iisaman@netapp.com>
 <1276566375-24566-7-git-send-email-iisaman@netapp.com>
 <1276566375-24566-8-git-send-email-iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.212.112.111]:52264 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932178Ab0FOO3E (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Jun 2010 10:29:04 -0400
Received: from localhost.localdomain (netapp-61.citi.umich.edu [141.212.112.250])
	by citi.umich.edu (Postfix) with ESMTP id 6252818169
	for <linux-nfs@vger.kernel.org>; Tue, 15 Jun 2010 10:20:11 -0400 (EDT)
In-Reply-To: <1276566375-24566-8-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Preparing for the lo_cache_head patch

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/callback_proc.c    |    2 +-
 fs/nfs/inode.c            |   20 +--------
 fs/nfs/nfs4proc.c         |    4 +-
 fs/nfs/nfs4xdr.c          |    4 +-
 fs/nfs/pnfs.c             |   93 ++++++++++++++++++++++++---------------------
 include/linux/nfs4_pnfs.h |    2 +-
 include/linux/nfs_fs.h    |    2 +-
 7 files changed, 60 insertions(+), 67 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index a598b5a..f5c4859 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -243,7 +243,7 @@ static int pnfs_recall_layout(void *data)
 	rl.cbl_seg.length = NFS4_MAX_UINT64;
 
 	if (rl.cbl_recall_type == RETURN_FILE) {
-		if (pnfs_is_next_layout_stateid(&NFS_I(inode)->layout,
+		if (pnfs_is_next_layout_stateid(NFS_I(inode)->layout,
 						rl.cbl_stateid))
 			status = pnfs_return_layout(inode, &rl.cbl_seg,
 						    &rl.cbl_stateid, RETURN_FILE,
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 1a03f9a..5802787 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1364,12 +1364,8 @@ void nfs4_clear_inode(struct inode *inode)
 static void pnfs_alloc_init_inode(struct nfs_inode *nfsi)
 {
 #ifdef CONFIG_NFS_V4_1
+	nfsi->layout = NULL;
 	nfsi->pnfs_layout_state = 0;
-	memset(&nfsi->layout.stateid, 0, NFS4_STATEID_SIZE);
-	nfsi->layout.roc_iomode = 0;
-	nfsi->layout.lo_cred = NULL;
-	nfsi->layout.pnfs_write_begin_pos = 0;
-	nfsi->layout.pnfs_write_end_pos = 0;
 #endif /* CONFIG_NFS_V4_1 */
 }
 
@@ -1395,13 +1391,9 @@ struct inode *nfs_alloc_inode(struct super_block *sb)
 static void pnfs_destroy_inode(struct nfs_inode *nfsi)
 {
 #ifdef CONFIG_NFS_V4_1
-	if (!list_empty(&nfsi->layout.segs))
+	if (nfsi->layout)
 		pnfs_destroy_layout(nfsi);
-
-	BUG_ON(!list_empty(&nfsi->layout.lo_layouts));
-	BUG_ON(!list_empty(&nfsi->layout.segs));
-	BUG_ON(nfsi->layout.refcount);
-	BUG_ON(nfsi->layout.ld_data);
+	BUG_ON(nfsi->layout);
 #endif /* CONFIG_NFS_V4_1 */
 }
 
@@ -1418,12 +1410,6 @@ static void pnfs_init_once(struct nfs_inode *nfsi)
 #ifdef CONFIG_NFS_V4_1
 	init_waitqueue_head(&nfsi->lo_waitq);
 	spin_lock_init(&nfsi->lo_lock);
-	seqlock_init(&nfsi->layout.seqlock);
-	INIT_LIST_HEAD(&nfsi->layout.lo_layouts);
-	INIT_LIST_HEAD(&nfsi->layout.segs);
-	nfsi->layout.refcount = 0;
-	nfsi->layout.ld_data = NULL;
-	nfsi->layout.lo_inode = &nfsi->vfs_inode;
 #endif /* CONFIG_NFS_V4_1 */
 }
 
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index c7d68f5..e9dca4c 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1089,7 +1089,7 @@ static void pnfs4_layout_reclaim(struct nfs4_state *state)
 	 */
 	pnfs_return_layout(state->inode, NULL, &state->open_stateid,
 			   RETURN_FILE, true);
-	pnfs_set_layout_stateid(&NFS_I(state->inode)->layout, &zero_stateid);
+	pnfs_set_layout_stateid(NFS_I(state->inode)->layout, &zero_stateid);
 #endif /* CONFIG_NFS_V4_1 */
 }
 
@@ -2392,7 +2392,7 @@ pnfs4_proc_setattr(struct dentry *dentry, struct nfs_fattr *fattr,
 	struct nfs_server *server = NFS_SERVER(inode);
 	struct nfs_inode *nfsi = NFS_I(inode);
 
-	if (pnfs_enabled_sb(server) && has_layout(nfsi) &&
+	if (has_layout(nfsi) &&
 	    pnfs_ld_layoutret_on_setattr(server->pnfs_curr_ld))
 		pnfs_return_layout(inode, NULL, NULL, RETURN_FILE, true);
 	return nfs4_proc_setattr(dentry, fattr, sattr);
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 301ae14..ada46d6 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1885,7 +1885,7 @@ encode_layoutcommit(struct xdr_stream *xdr,
 
 	if (ld_io_ops->encode_layoutcommit)
 		ld_io_ops->encode_layoutcommit(
-			&NFS_I(args->inode)->layout, xdr, args);
+			NFS_I(args->inode)->layout, xdr, args);
 	else {
 		p = reserve_space(xdr, 4);
 		xdr_encode_opaque(p, NULL, 0);
@@ -1923,7 +1923,7 @@ encode_layoutreturn(struct xdr_stream *xdr,
 			ld_io_ops->encode_layoutreturn);
 		if (ld_io_ops->encode_layoutreturn) {
 			ld_io_ops->encode_layoutreturn(
-				&NFS_I(args->inode)->layout, xdr, args);
+				NFS_I(args->inode)->layout, xdr, args);
 		} else {
 			p = reserve_space(xdr, 4);
 			*p = cpu_to_be32(0);
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index bd11ec7..943519b 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -154,7 +154,7 @@ pnfs_need_layoutcommit(struct nfs_inode *nfsi, struct nfs_open_context *ctx)
 	dprintk("%s: has_layout=%d ctx=%p\n", __func__, has_layout(nfsi), ctx);
 	spin_lock(&nfsi->lo_lock);
 	if (has_layout(nfsi) && !layoutcommit_needed(nfsi)) {
-		nfsi->layout.lo_cred = get_rpccred(ctx->state->owner->so_cred);
+		nfsi->layout->lo_cred = get_rpccred(ctx->state->owner->so_cred);
 		__set_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->pnfs_layout_state);
 		nfsi->change_attr++;
 		spin_unlock(&nfsi->lo_lock);
@@ -175,17 +175,20 @@ pnfs_update_last_write(struct nfs_inode *nfsi, loff_t offset, size_t extent)
 	loff_t end_pos;
 
 	spin_lock(&nfsi->lo_lock);
-	if (offset < nfsi->layout.pnfs_write_begin_pos)
-		nfsi->layout.pnfs_write_begin_pos = offset;
+	if (!has_layout(nfsi))
+		goto out_unlock;
+	if (offset < nfsi->layout->pnfs_write_begin_pos)
+		nfsi->layout->pnfs_write_begin_pos = offset;
 	end_pos = offset + extent - 1; /* I'm being inclusive */
-	if (end_pos > nfsi->layout.pnfs_write_end_pos)
-		nfsi->layout.pnfs_write_end_pos = end_pos;
+	if (end_pos > nfsi->layout->pnfs_write_end_pos)
+		nfsi->layout->pnfs_write_end_pos = end_pos;
 	dprintk("%s: Wrote %lu@%lu bpos %lu, epos: %lu\n",
 		__func__,
 		(unsigned long) extent,
 		(unsigned long) offset ,
-		(unsigned long) nfsi->layout.pnfs_write_begin_pos,
-		(unsigned long) nfsi->layout.pnfs_write_end_pos);
+		(unsigned long) nfsi->layout->pnfs_write_begin_pos,
+		(unsigned long) nfsi->layout->pnfs_write_end_pos);
+ out_unlock:
 	spin_unlock(&nfsi->lo_lock);
 }
 
@@ -315,8 +318,8 @@ pnfs_unregister_layoutdriver(struct pnfs_layoutdriver_type *ld_type)
  * pNFS client layout cache
  */
 #if defined(CONFIG_SMP)
-#define BUG_ON_UNLOCKED_LO(lo) \
-	BUG_ON(!spin_is_locked(&PNFS_NFS_INODE(lo)->lo_lock))
+#define BUG_ON_UNLOCKED_LO(nfsi) \
+	BUG_ON(!spin_is_locked(&nfsi->lo_lock))
 #else /* CONFIG_SMP */
 #define BUG_ON_UNLOCKED_LO(lo) do {} while (0)
 #endif /* CONFIG_SMP */
@@ -327,7 +330,7 @@ int nfs4_roc_iomode(struct nfs_inode *nfsi)
 
 	spin_lock(&pnfs_spinlock);
 	if (has_layout(nfsi))
-		rv = nfsi->layout.roc_iomode;
+		rv = nfsi->layout->roc_iomode;
 	spin_unlock(&pnfs_spinlock);
 	return rv;
 }
@@ -335,19 +338,18 @@ int nfs4_roc_iomode(struct nfs_inode *nfsi)
 static inline void
 get_layout(struct pnfs_layout_type *lo)
 {
-	BUG_ON_UNLOCKED_LO(lo);
+	BUG_ON_UNLOCKED_LO(PNFS_NFS_INODE(lo));
 	lo->refcount++;
 }
 
 static inline struct pnfs_layout_type *
 grab_current_layout(struct nfs_inode *nfsi)
 {
-	struct pnfs_layout_type *lo = &nfsi->layout;
+	struct pnfs_layout_type *lo = nfsi->layout;
 
-	BUG_ON_UNLOCKED_LO(lo);
-	if (!lo->ld_data)
-		return NULL;
-	get_layout(lo);
+	BUG_ON_UNLOCKED_LO(nfsi);
+	if (lo)
+		get_layout(lo);
 	return lo;
 }
 
@@ -357,7 +359,7 @@ put_layout(struct pnfs_layout_type *lo)
 	struct nfs_inode *nfsi = PNFS_NFS_INODE(lo);
 	struct nfs_client *clp;
 
-	BUG_ON_UNLOCKED_LO(lo);
+	BUG_ON_UNLOCKED_LO(nfsi);
 	BUG_ON(lo->refcount <= 0);
 
 	lo->refcount--;
@@ -380,7 +382,8 @@ put_layout(struct pnfs_layout_type *lo)
 
 		dprintk("%s: freeing layout %p\n", __func__, lo->ld_data);
 		io_ops->free_layout(lo->ld_data);
-		lo->ld_data = NULL;
+		nfsi->layout = NULL;
+		kfree(lo);
 	}
 }
 
@@ -661,7 +664,7 @@ has_layout_to_return(struct pnfs_layout_type *lo,
 	dprintk("%s:Begin lo %p offset %llu length %llu iomode %d\n",
 		__func__, lo, range->offset, range->length, range->iomode);
 
-	BUG_ON_UNLOCKED_LO(lo);
+	BUG_ON_UNLOCKED_LO(PNFS_NFS_INODE(lo));
 	list_for_each_entry (lseg, &lo->segs, fi_list)
 		if (should_free_lseg(lseg, range)) {
 			out = lseg;
@@ -687,7 +690,7 @@ pnfs_free_layout(struct pnfs_layout_type *lo,
 	dprintk("%s:Begin lo %p offset %llu length %llu iomode %d\n",
 		__func__, lo, range->offset, range->length, range->iomode);
 
-	BUG_ON_UNLOCKED_LO(lo);
+	BUG_ON_UNLOCKED_LO(PNFS_NFS_INODE(lo));
 	list_for_each_entry_safe (lseg, next, &lo->segs, fi_list) {
 		if (!should_free_lseg(lseg, range) ||
 		    !_pnfs_can_return_lseg(lseg))
@@ -711,7 +714,7 @@ pnfs_return_layout_barrier(struct nfs_inode *nfsi,
 	bool ret = false;
 
 	spin_lock(&nfsi->lo_lock);
-	list_for_each_entry (lseg, &nfsi->layout.segs, fi_list) {
+	list_for_each_entry(lseg, &nfsi->layout->segs, fi_list) {
 		if (!should_free_lseg(lseg, range))
 			continue;
 		lseg->valid = false;
@@ -887,7 +890,7 @@ pnfs_insert_layout(struct pnfs_layout_type *lo,
 
 	dprintk("%s:Begin\n", __func__);
 
-	BUG_ON_UNLOCKED_LO(lo);
+	BUG_ON_UNLOCKED_LO(PNFS_NFS_INODE(lo));
 	list_for_each_entry (lp, &lo->segs, fi_list) {
 		if (cmp_layout(&lp->range, &lseg->range) > 0)
 			continue;
@@ -919,25 +922,28 @@ alloc_init_layout(struct inode *ino)
 	void *ld_data;
 	struct pnfs_layout_type *lo;
 	struct layoutdriver_io_operations *io_ops;
-	struct nfs_inode *nfsi = NFS_I(ino);
 
+	lo = kzalloc(sizeof(struct pnfs_layout_type), GFP_KERNEL);
+	if (!lo)
+		return NULL;
 	io_ops = NFS_SERVER(ino)->pnfs_curr_ld->ld_io_ops;
-	lo  = &nfsi->layout;
 	ld_data = io_ops->alloc_layout(ino);
 	if (!ld_data) {
 		printk(KERN_ERR
 			"%s: out of memory: io_ops->alloc_layout failed\n",
 			__func__);
+		kfree(lo);
 		return NULL;
 	}
 
-	spin_lock(&nfsi->lo_lock);
-	BUG_ON(lo->ld_data != NULL);
 	lo->ld_data = ld_data;
 	memset(&lo->stateid, 0, NFS4_STATEID_SIZE);
 	lo->refcount = 1;
 	lo->roc_iomode = 0;
-	spin_unlock(&nfsi->lo_lock);
+	lo->lo_inode = ino;
+	INIT_LIST_HEAD(&lo->lo_layouts);
+	INIT_LIST_HEAD(&lo->segs);
+	seqlock_init(&lo->seqlock);
 	return lo;
 }
 
@@ -982,8 +988,9 @@ get_lock_alloc_layout(struct inode *ino)
 		/* Was current_layout already allocated while we slept?
 		 * If so, retry get_lock'ing it. Otherwise, allocate it.
 		 */
-		if (nfsi->layout.ld_data) {
+		if (nfsi->layout) {
 			spin_lock(&nfsi->lo_lock);
+			/* FIXME XXX deadlock here, need to relese ALLOC lock */
 			continue;
 		}
 
@@ -993,7 +1000,7 @@ get_lock_alloc_layout(struct inode *ino)
 
 			/* must grab the layout lock before the client lock */
 			spin_lock(&nfsi->lo_lock);
-
+			nfsi->layout = lo;
 			spin_lock(&clp->cl_lock);
 			if (list_empty(&lo->lo_layouts)) {
 				list_add_tail(&lo->lo_layouts, &clp->cl_layouts);
@@ -1060,7 +1067,7 @@ pnfs_has_layout(struct pnfs_layout_type *lo,
 
 	dprintk("%s:Begin\n", __func__);
 
-	BUG_ON_UNLOCKED_LO(lo);
+	BUG_ON_UNLOCKED_LO(PNFS_NFS_INODE(lo));
 	list_for_each_entry (lseg, &lo->segs, fi_list) {
 		if (has_matching_lseg(lseg, range) &&
 		    (lseg->valid || !only_valid)) {
@@ -1342,7 +1349,7 @@ pnfs_set_pg_test(struct inode *inode, struct nfs_pageio_descriptor *pgio)
 
 	pgio->pg_test = NULL;
 
-	laytype = &NFS_I(inode)->layout;
+	laytype = NFS_I(inode)->layout;
 	ld = NFS_SERVER(inode)->pnfs_curr_ld;
 	if (!pnfs_enabled_sb(NFS_SERVER(inode)) || !laytype)
 		return;
@@ -1475,7 +1482,7 @@ pnfs_writepages(struct nfs_write_data *wdata, int how)
 		numpages);
 	wdata->pdata.lseg = lseg;
 	trypnfs = nfss->pnfs_curr_ld->ld_io_ops->write_pagelist(
-							&nfsi->layout,
+							nfsi->layout,
 							args->pages,
 							args->pgbase,
 							numpages,
@@ -1528,7 +1535,7 @@ pnfs_readpages(struct nfs_read_data *rdata)
 		__func__, numpages);
 	rdata->pdata.lseg = lseg;
 	trypnfs = nfss->pnfs_curr_ld->ld_io_ops->read_pagelist(
-							&nfsi->layout,
+							nfsi->layout,
 							args->pages,
 							args->pgbase,
 							numpages,
@@ -1589,7 +1596,7 @@ pnfs_commit(struct nfs_write_data *data, int sync)
 	 * This will be done by passing the buck to the layout driver.
 	 */
 	data->pdata.lseg = NULL;
-	trypnfs = nfss->pnfs_curr_ld->ld_io_ops->commit(&nfsi->layout,
+	trypnfs = nfss->pnfs_curr_ld->ld_io_ops->commit(nfsi->layout,
 							sync, data);
 	dprintk("%s End (trypnfs:%d)\n", __func__, trypnfs);
 	return trypnfs;
@@ -1613,7 +1620,7 @@ pnfs_layoutcommit_done(struct pnfs_layoutcommit_data *data)
 	 */
 	if (nfss->pnfs_curr_ld->ld_io_ops->cleanup_layoutcommit)
 		nfss->pnfs_curr_ld->ld_io_ops->cleanup_layoutcommit(
-							&nfsi->layout,
+							nfsi->layout,
 							&data->args,
 							data->status);
 	put_rpccred(data->cred);
@@ -1657,7 +1664,7 @@ pnfs_layoutcommit_setup(struct inode *inode,
 	 */
 	if (nfss->pnfs_curr_ld->ld_io_ops->setup_layoutcommit)
 		result = nfss->pnfs_curr_ld->ld_io_ops->setup_layoutcommit(
-				&nfsi->layout, &data->args);
+				nfsi->layout, &data->args);
 
 	dprintk("%s End Status %d\n", __func__, result);
 	return result;
@@ -1692,14 +1699,14 @@ pnfs_layoutcommit_inode(struct inode *inode, int sync)
 	/* Clear layoutcommit properties in the inode so
 	 * new lc info can be generated
 	 */
-	write_begin_pos = nfsi->layout.pnfs_write_begin_pos;
-	write_end_pos = nfsi->layout.pnfs_write_end_pos;
-	data->cred = nfsi->layout.lo_cred;
-	nfsi->layout.pnfs_write_begin_pos = 0;
-	nfsi->layout.pnfs_write_end_pos = 0;
-	nfsi->layout.lo_cred = NULL;
+	write_begin_pos = nfsi->layout->pnfs_write_begin_pos;
+	write_end_pos = nfsi->layout->pnfs_write_end_pos;
+	data->cred = nfsi->layout->lo_cred;
+	nfsi->layout->pnfs_write_begin_pos = 0;
+	nfsi->layout->pnfs_write_end_pos = 0;
+	nfsi->layout->lo_cred = NULL;
 	__clear_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->pnfs_layout_state);
-	pnfs_get_layout_stateid(&data->args.stateid, &nfsi->layout);
+	pnfs_get_layout_stateid(&data->args.stateid, nfsi->layout);
 
 	spin_unlock(&nfsi->lo_lock);
 
diff --git a/include/linux/nfs4_pnfs.h b/include/linux/nfs4_pnfs.h
index 2ea131f..5885352 100644
--- a/include/linux/nfs4_pnfs.h
+++ b/include/linux/nfs4_pnfs.h
@@ -77,7 +77,7 @@ PNFS_LD_POLICY_OPS(struct pnfs_layout_type *lo)
 static inline bool
 has_layout(struct nfs_inode *nfsi)
 {
-	return nfsi->layout.ld_data != NULL;
+	return nfsi->layout != NULL;
 }
 
 static inline bool
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 71bbc4c..6b62a53 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -203,7 +203,7 @@ struct nfs_inode {
 #if defined(CONFIG_NFS_V4_1)
 	wait_queue_head_t lo_waitq;
 	spinlock_t lo_lock;
-	struct pnfs_layout_type layout;
+	struct pnfs_layout_type *layout;
 	unsigned long pnfs_layout_state;
 	#define NFS_INO_RO_LAYOUT_FAILED 0	/* get ro layout failed stop trying */
 	#define NFS_INO_RW_LAYOUT_FAILED 1	/* get rw layout failed stop trying */
-- 
1.6.6.1

