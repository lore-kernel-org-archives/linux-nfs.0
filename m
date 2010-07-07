From: andros@netapp.com
Subject: [PATCH 03/16] SQUASHME pnfs-submit embed pnfs_layout_type
Date: Wed,  7 Jul 2010 18:34:10 -0400
Message-ID: <1278542063-4009-4-git-send-email-andros@netapp.com>
References: <1278542063-4009-1-git-send-email-andros@netapp.com>
 <1278542063-4009-2-git-send-email-andros@netapp.com>
 <1278542063-4009-3-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:43252 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754820Ab0GGWeY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Jul 2010 18:34:24 -0400
In-Reply-To: <1278542063-4009-3-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Change nfs_inode layout field to a pointer

Each layoutdriver embeds the pnfs_layout_type in it's private layout cache
head structure, and allocates them both with the alloc_layout
layoutdriver_io_operation.

NOTE API change: the layoutdriver_io_operation alloc_layout and free_layout now
use pnfs_layout_type pointers instead of void*.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/callback_proc.c    |    2 +-
 fs/nfs/inode.c            |   12 +-----
 fs/nfs/nfs4proc.c         |    2 +-
 fs/nfs/nfs4state.c        |    4 +-
 fs/nfs/pnfs.c             |  111 +++++++++++++++++++++++----------------------
 include/linux/nfs4_pnfs.h |   19 +++-----
 include/linux/nfs_fs.h    |    4 +-
 7 files changed, 71 insertions(+), 83 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 4766695..d999ea8 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -233,7 +233,7 @@ static int pnfs_recall_layout(void *data)
 	rl.cbl_seg.length = NFS4_MAX_UINT64;
 
 	if (rl.cbl_recall_type == RETURN_FILE) {
-		if (pnfs_is_next_layout_stateid(&NFS_I(inode)->layout,
+		if (pnfs_is_next_layout_stateid(NFS_I(inode)->layout,
 						rl.cbl_stateid))
 			status = pnfs_return_layout(inode, &rl.cbl_seg,
 						    &rl.cbl_stateid, RETURN_FILE,
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 3d51602..30252f4 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1397,17 +1397,7 @@ static inline void nfs4_init_once(struct nfs_inode *nfsi)
 #ifdef CONFIG_NFS_V4_1
 	init_waitqueue_head(&nfsi->lo_waitq);
 	nfsi->pnfs_layout_suspend = 0;
-	seqlock_init(&nfsi->layout.seqlock);
-	INIT_LIST_HEAD(&nfsi->layout.lo_layouts);
-	INIT_LIST_HEAD(&nfsi->layout.segs);
-	nfsi->layout.refcount = 0;
-	nfsi->layout.ld_data = NULL;
-	nfsi->layout.pnfs_layout_state = 0;
-	memset(&nfsi->layout.stateid, 0, NFS4_STATEID_SIZE);
-	nfsi->layout.roc_iomode = 0;
-	nfsi->layout.lo_cred = NULL;
-	nfsi->layout.pnfs_write_begin_pos = 0;
-	nfsi->layout.pnfs_write_end_pos = 0;
+	nfsi->layout = NULL;
 #endif /* CONFIG_NFS_V4_1 */
 #endif
 }
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index c5b8a2f..6acebc3 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1086,7 +1086,7 @@ static void pnfs4_layout_reclaim(struct nfs4_state *state)
 	 * flag during grace period
 	 */
 	pnfs_destroy_layout(NFS_I(state->inode));
-	pnfs_set_layout_stateid(&NFS_I(state->inode)->layout, &zero_stateid);
+	pnfs_set_layout_stateid(NFS_I(state->inode)->layout, &zero_stateid);
 #endif /* CONFIG_NFS_V4_1 */
 }
 
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index bfe679b..6f44cb0 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -597,10 +597,10 @@ static void __nfs4_close(struct path *path, struct nfs4_state *state,
 #ifdef CONFIG_NFS_V4_1
 		struct nfs_inode *nfsi = NFS_I(state->inode);
 
-		if (has_layout(nfsi) && nfsi->layout.roc_iomode) {
+		if (has_layout(nfsi) && nfsi->layout->roc_iomode) {
 			struct nfs4_pnfs_layout_segment range;
 
-			range.iomode = nfsi->layout.roc_iomode;
+			range.iomode = nfsi->layout->roc_iomode;
 			range.offset = 0;
 			range.length = NFS4_MAX_UINT64;
 			pnfs_return_layout(state->inode, &range, NULL,
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 53c15b1..6d435ed 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -152,10 +152,11 @@ pnfs_need_layoutcommit(struct nfs_inode *nfsi, struct nfs_open_context *ctx)
 {
 	dprintk("%s: has_layout=%d ctx=%p\n", __func__, has_layout(nfsi), ctx);
 	spin_lock(&nfsi->vfs_inode.i_lock);
-	if (has_layout(nfsi) && !layoutcommit_needed(nfsi)) {
-		nfsi->layout.lo_cred = get_rpccred(ctx->state->owner->so_cred);
+	if (has_layout(nfsi) && !
+	    !test_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->layout->pnfs_layout_state)) {
+		nfsi->layout->lo_cred = get_rpccred(ctx->state->owner->so_cred);
 		__set_bit(NFS_INO_LAYOUTCOMMIT,
-			  &nfsi->layout.pnfs_layout_state);
+			  &nfsi->layout->pnfs_layout_state);
 		nfsi->change_attr++;
 		spin_unlock(&nfsi->vfs_inode.i_lock);
 		dprintk("%s: Set layoutcommit\n", __func__);
@@ -175,17 +176,17 @@ pnfs_update_last_write(struct nfs_inode *nfsi, loff_t offset, size_t extent)
 	loff_t end_pos;
 
 	spin_lock(&nfsi->vfs_inode.i_lock);
-	if (offset < nfsi->layout.pnfs_write_begin_pos)
-		nfsi->layout.pnfs_write_begin_pos = offset;
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
 	spin_unlock(&nfsi->vfs_inode.i_lock);
 }
 
@@ -326,10 +327,9 @@ get_layout(struct pnfs_layout_type *lo)
 static inline struct pnfs_layout_type *
 grab_current_layout(struct nfs_inode *nfsi)
 {
-	struct pnfs_layout_type *lo = &nfsi->layout;
+	struct pnfs_layout_type *lo = nfsi->layout;
 
-	BUG_ON_UNLOCKED_LO(lo);
-	if (!lo->ld_data)
+	if (!lo)
 		return NULL;
 	get_layout(lo);
 	return lo;
@@ -343,13 +343,13 @@ put_layout(struct pnfs_layout_type *lo)
 
 	lo->refcount--;
 	if (!lo->refcount) {
-		struct layoutdriver_io_operations *io_ops =
-			PNFS_LD_IO_OPS(lo);
+		struct layoutdriver_io_operations *io_ops = PNFS_LD_IO_OPS(lo);
+		struct nfs_inode *nfsi = PNFS_NFS_INODE(lo);
 
-		dprintk("%s: freeing layout %p\n", __func__, lo->ld_data);
+		dprintk("%s: freeing layout cache %p\n", __func__, lo);
 		WARN_ON(!list_empty(&lo->lo_layouts));
-		io_ops->free_layout(lo->ld_data);
-		lo->ld_data = NULL;
+		io_ops->free_layout(lo);
+		nfsi->layout = NULL;
 	}
 }
 
@@ -381,14 +381,13 @@ pnfs_destroy_layout(struct nfs_inode *nfsi)
 	lo = grab_current_layout(nfsi);
 	if (lo) {
 		pnfs_free_layout(lo, &range);
-		WARN_ON(!list_empty(&nfsi->layout.segs));
-		WARN_ON(!list_empty(&nfsi->layout.lo_layouts));
-		WARN_ON(nfsi->layout.ld_data);
+		WARN_ON(!list_empty(&nfsi->layout->segs));
+		WARN_ON(!list_empty(&nfsi->layout->lo_layouts));
 
-		if (nfsi->layout.refcount != 1)
+		if (nfsi->layout->refcount != 1)
 			printk(KERN_WARNING "%s: layout refcount not=1 %d\n",
-				__func__, nfsi->layout.refcount);
-		WARN_ON(nfsi->layout.refcount != 1);
+				__func__, nfsi->layout->refcount);
+		WARN_ON(nfsi->layout->refcount != 1);
 
 		put_layout(lo);
 	}
@@ -698,7 +697,7 @@ pnfs_return_layout_barrier(struct nfs_inode *nfsi,
 	bool ret = false;
 
 	spin_lock(&nfsi->vfs_inode.i_lock);
-	list_for_each_entry (lseg, &nfsi->layout.segs, fi_list) {
+	list_for_each_entry(lseg, &nfsi->layout->segs, fi_list) {
 		if (!should_free_lseg(lseg, range))
 			continue;
 		lseg->valid = false;
@@ -904,29 +903,33 @@ pnfs_insert_layout(struct pnfs_layout_type *lo,
 	dprintk("%s:Return\n", __func__);
 }
 
+/*
+ * Each layoutdriver embeds pnfs_layout_type as the first field in it's
+ * per-layout type layout cache structure and returns it ZEROed
+ * from layoutdriver_io_ops->alloc_layout
+ */
 static struct pnfs_layout_type *
 alloc_init_layout(struct inode *ino)
 {
-	void *ld_data;
 	struct pnfs_layout_type *lo;
 	struct layoutdriver_io_operations *io_ops;
 
+	BUG_ON(NFS_I(ino)->layout != NULL);
 	io_ops = NFS_SERVER(ino)->pnfs_curr_ld->ld_io_ops;
-	lo = &NFS_I(ino)->layout;
-	ld_data = io_ops->alloc_layout(ino);
-	if (!ld_data) {
+	lo = io_ops->alloc_layout(ino);
+	if (!lo) {
 		printk(KERN_ERR
 			"%s: out of memory: io_ops->alloc_layout failed\n",
 			__func__);
 		return NULL;
 	}
-
 	spin_lock(&ino->i_lock);
-	BUG_ON(lo->ld_data != NULL);
-	lo->ld_data = ld_data;
-	memset(&lo->stateid, 0, NFS4_STATEID_SIZE);
 	lo->refcount = 1;
-	lo->roc_iomode = 0;
+	INIT_LIST_HEAD(&lo->lo_layouts);
+	INIT_LIST_HEAD(&lo->segs);
+	seqlock_init(&lo->seqlock);
+	lo->lo_inode = ino;
+	NFS_I(ino)->layout = lo;
 	spin_unlock(&ino->i_lock);
 	return lo;
 }
@@ -961,7 +964,7 @@ get_lock_alloc_layout(struct inode *ino)
 		 * wait until bit is cleared if we lost this race.
 		 */
 		res = wait_on_bit_lock(
-			&nfsi->layout.pnfs_layout_state,
+			&nfsi->layout->pnfs_layout_state,
 			NFS_INO_LAYOUT_ALLOC,
 			pnfs_wait_schedule, TASK_KILLABLE);
 		if (res) {
@@ -972,7 +975,7 @@ get_lock_alloc_layout(struct inode *ino)
 		/* Was current_layout already allocated while we slept?
 		 * If so, retry get_lock'ing it. Otherwise, allocate it.
 		 */
-		if (nfsi->layout.ld_data) {
+		if (nfsi->layout) {
 			spin_lock(&ino->i_lock);
 			continue;
 		}
@@ -985,8 +988,8 @@ get_lock_alloc_layout(struct inode *ino)
 
 		/* release the NFS_INO_LAYOUT_ALLOC bit and wake up waiters */
 		clear_bit_unlock(NFS_INO_LAYOUT_ALLOC,
-				 &nfsi->layout.pnfs_layout_state);
-		wake_up_bit(&nfsi->layout.pnfs_layout_state,
+				 &nfsi->layout->pnfs_layout_state);
+		wake_up_bit(&nfsi->layout->pnfs_layout_state,
 			    NFS_INO_LAYOUT_ALLOC);
 		break;
 	}
@@ -1113,12 +1116,12 @@ _pnfs_update_layout(struct inode *ino,
 	}
 
 	/* if get layout already failed once goto out */
-	if (test_bit(lo_fail_bit(iomode), &nfsi->layout.pnfs_layout_state)) {
+	if (test_bit(lo_fail_bit(iomode), &nfsi->layout->pnfs_layout_state)) {
 		if (unlikely(nfsi->pnfs_layout_suspend &&
 		    get_seconds() >= nfsi->pnfs_layout_suspend)) {
 			dprintk("%s: layout_get resumed\n", __func__);
 			clear_bit(lo_fail_bit(iomode),
-				  &nfsi->layout.pnfs_layout_state);
+				  &nfsi->layout->pnfs_layout_state);
 			nfsi->pnfs_layout_suspend = 0;
 		} else
 			goto out_put;
@@ -1130,7 +1133,7 @@ _pnfs_update_layout(struct inode *ino,
 	send_layoutget(ino, ctx, &arg, lsegpp, lo);
 out:
 	dprintk("%s end, state 0x%lx lseg %p\n", __func__,
-		nfsi->layout.pnfs_layout_state, lseg);
+		nfsi->layout->pnfs_layout_state, lseg);
 	return;
 out_put:
 	if (lsegpp)
@@ -1235,12 +1238,12 @@ pnfs_get_layout_done(struct nfs4_pnfs_layoutget *lgp, int rpc_status)
 	/* remember that get layout failed and suspend trying */
 	nfsi->pnfs_layout_suspend = suspend;
 	set_bit(lo_fail_bit(lgp->args.lseg.iomode),
-		&nfsi->layout.pnfs_layout_state);
+		&nfsi->layout->pnfs_layout_state);
 	dprintk("%s: layout_get suspended until %ld\n",
 		__func__, suspend);
 out:
 	dprintk("%s end (err:%d) state 0x%lx lseg %p\n",
-		__func__, lgp->status, nfsi->layout.pnfs_layout_state, lseg);
+		__func__, lgp->status, nfsi->layout->pnfs_layout_state, lseg);
 	return;
 }
 
@@ -1321,7 +1324,7 @@ pnfs_set_pg_test(struct inode *inode, struct nfs_pageio_descriptor *pgio)
 
 	pgio->pg_test = NULL;
 
-	laytype = &NFS_I(inode)->layout;
+	laytype = NFS_I(inode)->layout;
 	ld = NFS_SERVER(inode)->pnfs_curr_ld;
 	if (!pnfs_enabled_sb(NFS_SERVER(inode)) || !laytype)
 		return;
@@ -1454,7 +1457,7 @@ pnfs_writepages(struct nfs_write_data *wdata, int how)
 		numpages);
 	wdata->pdata.lseg = lseg;
 	trypnfs = nfss->pnfs_curr_ld->ld_io_ops->write_pagelist(
-							&nfsi->layout,
+							nfsi->layout,
 							args->pages,
 							args->pgbase,
 							numpages,
@@ -1507,7 +1510,7 @@ pnfs_readpages(struct nfs_read_data *rdata)
 		__func__, numpages);
 	rdata->pdata.lseg = lseg;
 	trypnfs = nfss->pnfs_curr_ld->ld_io_ops->read_pagelist(
-							&nfsi->layout,
+							nfsi->layout,
 							args->pages,
 							args->pgbase,
 							numpages,
@@ -1568,7 +1571,7 @@ pnfs_commit(struct nfs_write_data *data, int sync)
 	 * This will be done by passing the buck to the layout driver.
 	 */
 	data->pdata.lseg = NULL;
-	trypnfs = nfss->pnfs_curr_ld->ld_io_ops->commit(&nfsi->layout,
+	trypnfs = nfss->pnfs_curr_ld->ld_io_ops->commit(nfsi->layout,
 							sync, data);
 	dprintk("%s End (trypnfs:%d)\n", __func__, trypnfs);
 	return trypnfs;
@@ -1639,14 +1642,14 @@ pnfs_layoutcommit_inode(struct inode *inode, int sync)
 	/* Clear layoutcommit properties in the inode so
 	 * new lc info can be generated
 	 */
-	write_begin_pos = nfsi->layout.pnfs_write_begin_pos;
-	write_end_pos = nfsi->layout.pnfs_write_end_pos;
-	data->cred = nfsi->layout.lo_cred;
-	nfsi->layout.pnfs_write_begin_pos = 0;
-	nfsi->layout.pnfs_write_end_pos = 0;
-	nfsi->layout.lo_cred = NULL;
-	__clear_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->layout.pnfs_layout_state);
-	pnfs_get_layout_stateid(&data->args.stateid, &nfsi->layout);
+	write_begin_pos = nfsi->layout->pnfs_write_begin_pos;
+	write_end_pos = nfsi->layout->pnfs_write_end_pos;
+	data->cred = nfsi->layout->lo_cred;
+	nfsi->layout->pnfs_write_begin_pos = 0;
+	nfsi->layout->pnfs_write_end_pos = 0;
+	nfsi->layout->lo_cred = NULL;
+	__clear_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->layout->pnfs_layout_state);
+	pnfs_get_layout_stateid(&data->args.stateid, nfsi->layout);
 
 	spin_unlock(&inode->i_lock);
 
diff --git a/include/linux/nfs4_pnfs.h b/include/linux/nfs4_pnfs.h
index c5af82f..2c6ce4c 100644
--- a/include/linux/nfs4_pnfs.h
+++ b/include/linux/nfs4_pnfs.h
@@ -35,13 +35,13 @@ struct pnfs_layoutdriver_type {
 static inline struct nfs_inode *
 PNFS_NFS_INODE(struct pnfs_layout_type *lo)
 {
-	return container_of(lo, struct nfs_inode, layout);
+	return NFS_I(lo->lo_inode);
 }
 
 static inline struct inode *
 PNFS_INODE(struct pnfs_layout_type *lo)
 {
-	return &PNFS_NFS_INODE(lo)->vfs_inode;
+	return lo->lo_inode;
 }
 
 static inline struct nfs_server *
@@ -50,12 +50,6 @@ PNFS_NFS_SERVER(struct pnfs_layout_type *lo)
 	return NFS_SERVER(PNFS_INODE(lo));
 }
 
-static inline void *
-PNFS_LD_DATA(struct pnfs_layout_type *lo)
-{
-	return lo->ld_data;
-}
-
 static inline struct pnfs_layoutdriver_type *
 PNFS_LD(struct pnfs_layout_type *lo)
 {
@@ -77,13 +71,14 @@ PNFS_LD_POLICY_OPS(struct pnfs_layout_type *lo)
 static inline bool
 has_layout(struct nfs_inode *nfsi)
 {
-	return nfsi->layout.ld_data != NULL;
+	return nfsi->layout != NULL;
 }
 
 static inline bool
 layoutcommit_needed(struct nfs_inode *nfsi)
 {
-	return test_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->layout.pnfs_layout_state);
+	return has_layout(nfsi) &&
+	       test_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->layout->pnfs_layout_state);
 }
 
 #else /* CONFIG_NFS_V4_1 */
@@ -149,8 +144,8 @@ struct layoutdriver_io_operations {
 	/* Layout information. For each inode, alloc_layout is executed once to retrieve an
 	 * inode specific layout structure.  Each subsequent layoutget operation results in
 	 * a set_layout call to set the opaque layout in the layout driver.*/
-	void * (*alloc_layout) (struct inode *inode);
-	void (*free_layout) (void *layoutid);
+	struct pnfs_layout_type * (*alloc_layout) (struct inode *inode);
+	void (*free_layout) (struct pnfs_layout_type *);
 	struct pnfs_layout_segment * (*alloc_lseg) (struct pnfs_layout_type *layoutid, struct nfs4_pnfs_layoutget_res *lgr);
 	void (*free_lseg) (struct pnfs_layout_segment *lseg);
 
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index b612746..7b999a4 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -104,7 +104,6 @@ struct pnfs_layout_type {
 	int roc_iomode;			/* iomode to return on close, 0=none */
 	seqlock_t seqlock;		/* Protects the stateid */
 	nfs4_stateid stateid;
-	void *ld_data;			/* layout driver private data */
 	unsigned long pnfs_layout_state;
 	#define NFS_INO_RO_LAYOUT_FAILED 0      /* get ro layout failed stop trying */
 	#define NFS_INO_RW_LAYOUT_FAILED 1      /* get rw layout failed stop trying */
@@ -116,6 +115,7 @@ struct pnfs_layout_type {
 	 */
 	loff_t                  pnfs_write_begin_pos;
 	loff_t                  pnfs_write_end_pos;
+	struct inode		*lo_inode;
 };
 
 /*
@@ -206,7 +206,7 @@ struct nfs_inode {
 	/* pNFS layout information */
 #if defined(CONFIG_NFS_V4_1)
 	wait_queue_head_t lo_waitq;
-	struct pnfs_layout_type layout;
+	struct pnfs_layout_type *layout;
 	time_t pnfs_layout_suspend;
 #endif /* CONFIG_NFS_V4_1 */
 #endif /* CONFIG_NFS_V4*/
-- 
1.6.6

