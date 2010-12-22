Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:7880 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752054Ab0LVEA6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Dec 2010 23:00:58 -0500
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 04/15] pnfs: add prefix to struct pnfs_layout_hdr fields
Date: Tue, 21 Dec 2010 23:00:38 -0500
Message-Id: <1292990449-20057-5-git-send-email-iisaman@netapp.com>
In-Reply-To: <1292990449-20057-1-git-send-email-iisaman@netapp.com>
References: <1292990449-20057-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/nfs4filelayout.c |    6 +-
 fs/nfs/pnfs.c           |   94 +++++++++++++++++++++++-----------------------
 fs/nfs/pnfs.h           |   12 +++---
 3 files changed, 56 insertions(+), 56 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 738d6a4..23f930c 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -82,7 +82,7 @@ filelayout_check_layout(struct pnfs_layout_hdr *lo,
 {
 	struct nfs4_file_layout_dsaddr *dsaddr;
 	int status = -EINVAL;
-	struct nfs_server *nfss = NFS_SERVER(lo->inode);
+	struct nfs_server *nfss = NFS_SERVER(lo->plh_inode);
 
 	dprintk("--> %s\n", __func__);
 
@@ -101,7 +101,7 @@ filelayout_check_layout(struct pnfs_layout_hdr *lo,
 	/* find and reference the deviceid */
 	dsaddr = nfs4_fl_find_get_deviceid(nfss->nfs_client, id);
 	if (dsaddr == NULL) {
-		dsaddr = get_device_info(lo->inode, id);
+		dsaddr = get_device_info(lo->plh_inode, id);
 		if (dsaddr == NULL)
 			goto out;
 	}
@@ -243,7 +243,7 @@ filelayout_alloc_lseg(struct pnfs_layout_hdr *layoutid,
 static void
 filelayout_free_lseg(struct pnfs_layout_segment *lseg)
 {
-	struct nfs_server *nfss = NFS_SERVER(lseg->pls_layout->inode);
+	struct nfs_server *nfss = NFS_SERVER(lseg->pls_layout->plh_inode);
 	struct nfs4_filelayout_segment *fl = FILELAYOUT_LSEG(lseg);
 
 	dprintk("--> %s\n", __func__);
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index c3ca5fe..6736f9e 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -180,21 +180,21 @@ EXPORT_SYMBOL_GPL(pnfs_unregister_layoutdriver);
 static void
 get_layout_hdr_locked(struct pnfs_layout_hdr *lo)
 {
-	assert_spin_locked(&lo->inode->i_lock);
-	lo->refcount++;
+	assert_spin_locked(&lo->plh_inode->i_lock);
+	lo->plh_refcount++;
 }
 
 static void
 put_layout_hdr_locked(struct pnfs_layout_hdr *lo)
 {
-	assert_spin_locked(&lo->inode->i_lock);
-	BUG_ON(lo->refcount == 0);
+	assert_spin_locked(&lo->plh_inode->i_lock);
+	BUG_ON(lo->plh_refcount == 0);
 
-	lo->refcount--;
-	if (!lo->refcount) {
+	lo->plh_refcount--;
+	if (!lo->plh_refcount) {
 		dprintk("%s: freeing layout cache %p\n", __func__, lo);
-		BUG_ON(!list_empty(&lo->layouts));
-		NFS_I(lo->inode)->layout = NULL;
+		BUG_ON(!list_empty(&lo->plh_layouts));
+		NFS_I(lo->plh_inode)->layout = NULL;
 		kfree(lo);
 	}
 }
@@ -221,7 +221,7 @@ destroy_lseg(struct kref *kref)
 {
 	struct pnfs_layout_segment *lseg =
 		container_of(kref, struct pnfs_layout_segment, pls_refcount);
-	struct inode *ino = lseg->pls_layout->inode;
+	struct inode *ino = lseg->pls_layout->plh_inode;
 
 	dprintk("--> %s\n", __func__);
 	NFS_SERVER(ino)->pnfs_curr_ld->free_lseg(lseg);
@@ -248,19 +248,19 @@ pnfs_clear_lseg_list(struct pnfs_layout_hdr *lo, struct list_head *tmp_list)
 
 	dprintk("%s:Begin lo %p\n", __func__, lo);
 
-	assert_spin_locked(&lo->inode->i_lock);
-	list_for_each_entry_safe(lseg, next, &lo->segs, pls_list) {
+	assert_spin_locked(&lo->plh_inode->i_lock);
+	list_for_each_entry_safe(lseg, next, &lo->plh_segs, pls_list) {
 		dprintk("%s: freeing lseg %p\n", __func__, lseg);
 		list_move(&lseg->pls_list, tmp_list);
 	}
-	clp = NFS_SERVER(lo->inode)->nfs_client;
+	clp = NFS_SERVER(lo->plh_inode)->nfs_client;
 	spin_lock(&clp->cl_lock);
 	/* List does not take a reference, so no need for put here */
-	list_del_init(&lo->layouts);
+	list_del_init(&lo->plh_layouts);
 	spin_unlock(&clp->cl_lock);
-	write_seqlock(&lo->seqlock);
+	write_seqlock(&lo->plh_seqlock);
 	clear_bit(NFS_LAYOUT_STATEID_SET, &lo->plh_flags);
-	write_sequnlock(&lo->seqlock);
+	write_sequnlock(&lo->plh_seqlock);
 
 	dprintk("%s:Return\n", __func__);
 }
@@ -312,25 +312,25 @@ pnfs_destroy_all_layouts(struct nfs_client *clp)
 
 	while (!list_empty(&tmp_list)) {
 		lo = list_entry(tmp_list.next, struct pnfs_layout_hdr,
-				layouts);
+				plh_layouts);
 		dprintk("%s freeing layout for inode %lu\n", __func__,
-			lo->inode->i_ino);
-		pnfs_destroy_layout(NFS_I(lo->inode));
+			lo->plh_inode->i_ino);
+		pnfs_destroy_layout(NFS_I(lo->plh_inode));
 	}
 }
 
-/* update lo->stateid with new if is more recent
+/* update lo->plh_stateid with new if is more recent
  *
- * lo->stateid could be the open stateid, in which case we just use what given.
+ * lo->plh_stateid could be the open stateid, in which case we just use what given.
  */
 static void
 pnfs_set_layout_stateid(struct pnfs_layout_hdr *lo,
 			const nfs4_stateid *new)
 {
-	nfs4_stateid *old = &lo->stateid;
+	nfs4_stateid *old = &lo->plh_stateid;
 	bool overwrite = false;
 
-	write_seqlock(&lo->seqlock);
+	write_seqlock(&lo->plh_seqlock);
 	if (!test_bit(NFS_LAYOUT_STATEID_SET, &lo->plh_flags) ||
 	    memcmp(old->stateid.other, new->stateid.other, sizeof(new->stateid.other)))
 		overwrite = true;
@@ -344,7 +344,7 @@ pnfs_set_layout_stateid(struct pnfs_layout_hdr *lo,
 	}
 	if (overwrite)
 		memcpy(&old->stateid, &new->stateid, sizeof(new->stateid));
-	write_sequnlock(&lo->seqlock);
+	write_sequnlock(&lo->plh_seqlock);
 }
 
 static void
@@ -354,14 +354,14 @@ pnfs_layout_from_open_stateid(struct pnfs_layout_hdr *lo,
 	int seq;
 
 	dprintk("--> %s\n", __func__);
-	write_seqlock(&lo->seqlock);
+	write_seqlock(&lo->plh_seqlock);
 	do {
 		seq = read_seqbegin(&state->seqlock);
-		memcpy(lo->stateid.data, state->stateid.data,
+		memcpy(lo->plh_stateid.data, state->stateid.data,
 		       sizeof(state->stateid.data));
 	} while (read_seqretry(&state->seqlock, seq));
 	set_bit(NFS_LAYOUT_STATEID_SET, &lo->plh_flags);
-	write_sequnlock(&lo->seqlock);
+	write_sequnlock(&lo->plh_seqlock);
 	dprintk("<-- %s\n", __func__);
 }
 
@@ -373,14 +373,14 @@ pnfs_get_layout_stateid(nfs4_stateid *dst, struct pnfs_layout_hdr *lo,
 
 	dprintk("--> %s\n", __func__);
 	do {
-		seq = read_seqbegin(&lo->seqlock);
+		seq = read_seqbegin(&lo->plh_seqlock);
 		if (!test_bit(NFS_LAYOUT_STATEID_SET, &lo->plh_flags)) {
 			/* This will trigger retry of the read */
 			pnfs_layout_from_open_stateid(lo, open_state);
 		} else
-			memcpy(dst->data, lo->stateid.data,
-			       sizeof(lo->stateid.data));
-	} while (read_seqretry(&lo->seqlock, seq));
+			memcpy(dst->data, lo->plh_stateid.data,
+			       sizeof(lo->plh_stateid.data));
+	} while (read_seqretry(&lo->plh_seqlock, seq));
 	dprintk("<-- %s\n", __func__);
 }
 
@@ -395,7 +395,7 @@ send_layoutget(struct pnfs_layout_hdr *lo,
 	   struct nfs_open_context *ctx,
 	   u32 iomode)
 {
-	struct inode *ino = lo->inode;
+	struct inode *ino = lo->plh_inode;
 	struct nfs_server *server = NFS_SERVER(ino);
 	struct nfs4_layoutget *lgp;
 	struct pnfs_layout_segment *lseg = NULL;
@@ -405,7 +405,7 @@ send_layoutget(struct pnfs_layout_hdr *lo,
 	BUG_ON(ctx == NULL);
 	lgp = kzalloc(sizeof(*lgp), GFP_KERNEL);
 	if (lgp == NULL) {
-		put_layout_hdr(lo->inode);
+		put_layout_hdr(lo->plh_inode);
 		return NULL;
 	}
 	lgp->args.minlength = NFS4_MAX_UINT64;
@@ -450,16 +450,16 @@ pnfs_insert_layout(struct pnfs_layout_hdr *lo,
 
 	dprintk("%s:Begin\n", __func__);
 
-	assert_spin_locked(&lo->inode->i_lock);
-	if (list_empty(&lo->segs)) {
-		struct nfs_client *clp = NFS_SERVER(lo->inode)->nfs_client;
+	assert_spin_locked(&lo->plh_inode->i_lock);
+	if (list_empty(&lo->plh_segs)) {
+		struct nfs_client *clp = NFS_SERVER(lo->plh_inode)->nfs_client;
 
 		spin_lock(&clp->cl_lock);
-		BUG_ON(!list_empty(&lo->layouts));
-		list_add_tail(&lo->layouts, &clp->cl_layouts);
+		BUG_ON(!list_empty(&lo->plh_layouts));
+		list_add_tail(&lo->plh_layouts, &clp->cl_layouts);
 		spin_unlock(&clp->cl_lock);
 	}
-	list_for_each_entry(lp, &lo->segs, pls_list) {
+	list_for_each_entry(lp, &lo->plh_segs, pls_list) {
 		if (cmp_layout(lp->pls_range.iomode, lseg->pls_range.iomode) > 0)
 			continue;
 		list_add_tail(&lseg->pls_list, &lp->pls_list);
@@ -474,7 +474,7 @@ pnfs_insert_layout(struct pnfs_layout_hdr *lo,
 		break;
 	}
 	if (!found) {
-		list_add_tail(&lseg->pls_list, &lo->segs);
+		list_add_tail(&lseg->pls_list, &lo->plh_segs);
 		dprintk("%s: inserted lseg %p "
 			"iomode %d offset %llu length %llu at tail\n",
 			__func__, lseg, lseg->pls_range.iomode,
@@ -493,11 +493,11 @@ alloc_init_layout_hdr(struct inode *ino)
 	lo = kzalloc(sizeof(struct pnfs_layout_hdr), GFP_KERNEL);
 	if (!lo)
 		return NULL;
-	lo->refcount = 1;
-	INIT_LIST_HEAD(&lo->layouts);
-	INIT_LIST_HEAD(&lo->segs);
-	seqlock_init(&lo->seqlock);
-	lo->inode = ino;
+	lo->plh_refcount = 1;
+	INIT_LIST_HEAD(&lo->plh_layouts);
+	INIT_LIST_HEAD(&lo->plh_segs);
+	seqlock_init(&lo->plh_seqlock);
+	lo->plh_inode = ino;
 	return lo;
 }
 
@@ -551,8 +551,8 @@ pnfs_has_layout(struct pnfs_layout_hdr *lo, u32 iomode)
 
 	dprintk("%s:Begin\n", __func__);
 
-	assert_spin_locked(&lo->inode->i_lock);
-	list_for_each_entry(lseg, &lo->segs, pls_list) {
+	assert_spin_locked(&lo->plh_inode->i_lock);
+	list_for_each_entry(lseg, &lo->plh_segs, pls_list) {
 		if (is_matching_lseg(lseg, iomode)) {
 			ret = lseg;
 			break;
@@ -619,7 +619,7 @@ pnfs_layout_process(struct nfs4_layoutget *lgp)
 	struct pnfs_layout_hdr *lo = NFS_I(lgp->args.inode)->layout;
 	struct nfs4_layoutget_res *res = &lgp->res;
 	struct pnfs_layout_segment *lseg;
-	struct inode *ino = lo->inode;
+	struct inode *ino = lo->plh_inode;
 	int status = 0;
 
 	/* Inject layout blob into I/O device driver */
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 6fcc073..c2f1086 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -60,13 +60,13 @@ struct pnfs_layoutdriver_type {
 };
 
 struct pnfs_layout_hdr {
-	unsigned long		refcount;
-	struct list_head	layouts;   /* other client layouts */
-	struct list_head	segs;      /* layout segments list */
-	seqlock_t		seqlock;   /* Protects the stateid */
-	nfs4_stateid		stateid;
+	unsigned long		plh_refcount;
+	struct list_head	plh_layouts;   /* other client layouts */
+	struct list_head	plh_segs;      /* layout segments list */
+	seqlock_t		plh_seqlock;   /* Protects the stateid */
+	nfs4_stateid		plh_stateid;
 	unsigned long		plh_flags;
-	struct inode		*inode;
+	struct inode		*plh_inode;
 };
 
 struct pnfs_device {
-- 
1.7.2.1

