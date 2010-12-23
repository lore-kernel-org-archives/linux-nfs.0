Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:57622 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753398Ab0LWRaX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 23 Dec 2010 12:30:23 -0500
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 03/15] pnfs: add prefix to struct pnfs_layout_segment fields
Date: Thu, 23 Dec 2010 12:29:45 -0500
Message-Id: <1293125397-30088-4-git-send-email-iisaman@netapp.com>
In-Reply-To: <1293125397-30088-1-git-send-email-iisaman@netapp.com>
References: <1293125397-30088-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

While we are renaming all the fields, change lo->state to lo->plh_flags.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/nfs4filelayout.c |    2 +-
 fs/nfs/pnfs.c           |   66 +++++++++++++++++++++++-----------------------
 fs/nfs/pnfs.h           |   10 +++---
 3 files changed, 39 insertions(+), 39 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 2e92f0d..738d6a4 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -243,7 +243,7 @@ filelayout_alloc_lseg(struct pnfs_layout_hdr *layoutid,
 static void
 filelayout_free_lseg(struct pnfs_layout_segment *lseg)
 {
-	struct nfs_server *nfss = NFS_SERVER(lseg->layout->inode);
+	struct nfs_server *nfss = NFS_SERVER(lseg->pls_layout->inode);
 	struct nfs4_filelayout_segment *fl = FILELAYOUT_LSEG(lseg);
 
 	dprintk("--> %s\n", __func__);
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 6e9daff..c3ca5fe 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -210,9 +210,9 @@ put_layout_hdr(struct inode *inode)
 static void
 init_lseg(struct pnfs_layout_hdr *lo, struct pnfs_layout_segment *lseg)
 {
-	INIT_LIST_HEAD(&lseg->fi_list);
-	kref_init(&lseg->kref);
-	lseg->layout = lo;
+	INIT_LIST_HEAD(&lseg->pls_list);
+	kref_init(&lseg->pls_refcount);
+	lseg->pls_layout = lo;
 }
 
 /* Called without i_lock held, as the free_lseg call may sleep */
@@ -220,8 +220,8 @@ static void
 destroy_lseg(struct kref *kref)
 {
 	struct pnfs_layout_segment *lseg =
-		container_of(kref, struct pnfs_layout_segment, kref);
-	struct inode *ino = lseg->layout->inode;
+		container_of(kref, struct pnfs_layout_segment, pls_refcount);
+	struct inode *ino = lseg->pls_layout->inode;
 
 	dprintk("--> %s\n", __func__);
 	NFS_SERVER(ino)->pnfs_curr_ld->free_lseg(lseg);
@@ -236,8 +236,8 @@ put_lseg(struct pnfs_layout_segment *lseg)
 		return;
 
 	dprintk("%s: lseg %p ref %d\n", __func__, lseg,
-		atomic_read(&lseg->kref.refcount));
-	kref_put(&lseg->kref, destroy_lseg);
+		atomic_read(&lseg->pls_refcount.refcount));
+	kref_put(&lseg->pls_refcount, destroy_lseg);
 }
 
 static void
@@ -249,9 +249,9 @@ pnfs_clear_lseg_list(struct pnfs_layout_hdr *lo, struct list_head *tmp_list)
 	dprintk("%s:Begin lo %p\n", __func__, lo);
 
 	assert_spin_locked(&lo->inode->i_lock);
-	list_for_each_entry_safe(lseg, next, &lo->segs, fi_list) {
+	list_for_each_entry_safe(lseg, next, &lo->segs, pls_list) {
 		dprintk("%s: freeing lseg %p\n", __func__, lseg);
-		list_move(&lseg->fi_list, tmp_list);
+		list_move(&lseg->pls_list, tmp_list);
 	}
 	clp = NFS_SERVER(lo->inode)->nfs_client;
 	spin_lock(&clp->cl_lock);
@@ -259,7 +259,7 @@ pnfs_clear_lseg_list(struct pnfs_layout_hdr *lo, struct list_head *tmp_list)
 	list_del_init(&lo->layouts);
 	spin_unlock(&clp->cl_lock);
 	write_seqlock(&lo->seqlock);
-	clear_bit(NFS_LAYOUT_STATEID_SET, &lo->state);
+	clear_bit(NFS_LAYOUT_STATEID_SET, &lo->plh_flags);
 	write_sequnlock(&lo->seqlock);
 
 	dprintk("%s:Return\n", __func__);
@@ -272,9 +272,9 @@ pnfs_free_lseg_list(struct list_head *tmp_list)
 
 	while (!list_empty(tmp_list)) {
 		lseg = list_entry(tmp_list->next, struct pnfs_layout_segment,
-				fi_list);
+				pls_list);
 		dprintk("%s calling put_lseg on %p\n", __func__, lseg);
-		list_del(&lseg->fi_list);
+		list_del(&lseg->pls_list);
 		put_lseg(lseg);
 	}
 }
@@ -331,7 +331,7 @@ pnfs_set_layout_stateid(struct pnfs_layout_hdr *lo,
 	bool overwrite = false;
 
 	write_seqlock(&lo->seqlock);
-	if (!test_bit(NFS_LAYOUT_STATEID_SET, &lo->state) ||
+	if (!test_bit(NFS_LAYOUT_STATEID_SET, &lo->plh_flags) ||
 	    memcmp(old->stateid.other, new->stateid.other, sizeof(new->stateid.other)))
 		overwrite = true;
 	else {
@@ -360,7 +360,7 @@ pnfs_layout_from_open_stateid(struct pnfs_layout_hdr *lo,
 		memcpy(lo->stateid.data, state->stateid.data,
 		       sizeof(state->stateid.data));
 	} while (read_seqretry(&state->seqlock, seq));
-	set_bit(NFS_LAYOUT_STATEID_SET, &lo->state);
+	set_bit(NFS_LAYOUT_STATEID_SET, &lo->plh_flags);
 	write_sequnlock(&lo->seqlock);
 	dprintk("<-- %s\n", __func__);
 }
@@ -374,7 +374,7 @@ pnfs_get_layout_stateid(nfs4_stateid *dst, struct pnfs_layout_hdr *lo,
 	dprintk("--> %s\n", __func__);
 	do {
 		seq = read_seqbegin(&lo->seqlock);
-		if (!test_bit(NFS_LAYOUT_STATEID_SET, &lo->state)) {
+		if (!test_bit(NFS_LAYOUT_STATEID_SET, &lo->plh_flags)) {
 			/* This will trigger retry of the read */
 			pnfs_layout_from_open_stateid(lo, open_state);
 		} else
@@ -424,7 +424,7 @@ send_layoutget(struct pnfs_layout_hdr *lo,
 	nfs4_proc_layoutget(lgp);
 	if (!lseg) {
 		/* remember that LAYOUTGET failed and suspend trying */
-		set_bit(lo_fail_bit(iomode), &lo->state);
+		set_bit(lo_fail_bit(iomode), &lo->plh_flags);
 	}
 	return lseg;
 }
@@ -459,26 +459,26 @@ pnfs_insert_layout(struct pnfs_layout_hdr *lo,
 		list_add_tail(&lo->layouts, &clp->cl_layouts);
 		spin_unlock(&clp->cl_lock);
 	}
-	list_for_each_entry(lp, &lo->segs, fi_list) {
-		if (cmp_layout(lp->range.iomode, lseg->range.iomode) > 0)
+	list_for_each_entry(lp, &lo->segs, pls_list) {
+		if (cmp_layout(lp->pls_range.iomode, lseg->pls_range.iomode) > 0)
 			continue;
-		list_add_tail(&lseg->fi_list, &lp->fi_list);
+		list_add_tail(&lseg->pls_list, &lp->pls_list);
 		dprintk("%s: inserted lseg %p "
 			"iomode %d offset %llu length %llu before "
 			"lp %p iomode %d offset %llu length %llu\n",
-			__func__, lseg, lseg->range.iomode,
-			lseg->range.offset, lseg->range.length,
-			lp, lp->range.iomode, lp->range.offset,
-			lp->range.length);
+			__func__, lseg, lseg->pls_range.iomode,
+			lseg->pls_range.offset, lseg->pls_range.length,
+			lp, lp->pls_range.iomode, lp->pls_range.offset,
+			lp->pls_range.length);
 		found = 1;
 		break;
 	}
 	if (!found) {
-		list_add_tail(&lseg->fi_list, &lo->segs);
+		list_add_tail(&lseg->pls_list, &lo->segs);
 		dprintk("%s: inserted lseg %p "
 			"iomode %d offset %llu length %llu at tail\n",
-			__func__, lseg, lseg->range.iomode,
-			lseg->range.offset, lseg->range.length);
+			__func__, lseg, lseg->pls_range.iomode,
+			lseg->pls_range.offset, lseg->pls_range.length);
 	}
 	get_layout_hdr_locked(lo);
 
@@ -538,7 +538,7 @@ pnfs_find_alloc_layout(struct inode *ino)
 static int
 is_matching_lseg(struct pnfs_layout_segment *lseg, u32 iomode)
 {
-	return (iomode != IOMODE_RW || lseg->range.iomode == IOMODE_RW);
+	return (iomode != IOMODE_RW || lseg->pls_range.iomode == IOMODE_RW);
 }
 
 /*
@@ -552,17 +552,17 @@ pnfs_has_layout(struct pnfs_layout_hdr *lo, u32 iomode)
 	dprintk("%s:Begin\n", __func__);
 
 	assert_spin_locked(&lo->inode->i_lock);
-	list_for_each_entry(lseg, &lo->segs, fi_list) {
+	list_for_each_entry(lseg, &lo->segs, pls_list) {
 		if (is_matching_lseg(lseg, iomode)) {
 			ret = lseg;
 			break;
 		}
-		if (cmp_layout(iomode, lseg->range.iomode) > 0)
+		if (cmp_layout(iomode, lseg->pls_range.iomode) > 0)
 			break;
 	}
 
 	dprintk("%s:Return lseg %p ref %d\n",
-		__func__, ret, ret ? atomic_read(&ret->kref.refcount) : 0);
+		__func__, ret, ret ? atomic_read(&ret->pls_refcount.refcount) : 0);
 	return ret;
 }
 
@@ -597,7 +597,7 @@ pnfs_update_layout(struct inode *ino,
 	}
 
 	/* if LAYOUTGET already failed once we don't try again */
-	if (test_bit(lo_fail_bit(iomode), &nfsi->layout->state))
+	if (test_bit(lo_fail_bit(iomode), &nfsi->layout->plh_flags))
 		goto out_unlock;
 
 	get_layout_hdr_locked(lo); /* Matched in nfs4_layoutget_release */
@@ -606,7 +606,7 @@ pnfs_update_layout(struct inode *ino,
 	lseg = send_layoutget(lo, ctx, iomode);
 out:
 	dprintk("%s end, state 0x%lx lseg %p\n", __func__,
-		nfsi->layout->state, lseg);
+		nfsi->layout->plh_flags, lseg);
 	return lseg;
 out_unlock:
 	spin_unlock(&ino->i_lock);
@@ -636,7 +636,7 @@ pnfs_layout_process(struct nfs4_layoutget *lgp)
 
 	spin_lock(&ino->i_lock);
 	init_lseg(lo, lseg);
-	lseg->range = res->range;
+	lseg->pls_range = res->range;
 	*lgp->lsegpp = lseg;
 	pnfs_insert_layout(lo, lseg);
 
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index e12367d..6fcc073 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -31,10 +31,10 @@
 #define FS_NFS_PNFS_H
 
 struct pnfs_layout_segment {
-	struct list_head fi_list;
-	struct pnfs_layout_range range;
-	struct kref kref;
-	struct pnfs_layout_hdr *layout;
+	struct list_head pls_list;
+	struct pnfs_layout_range pls_range;
+	struct kref pls_refcount;
+	struct pnfs_layout_hdr *pls_layout;
 };
 
 #ifdef CONFIG_NFS_V4_1
@@ -65,7 +65,7 @@ struct pnfs_layout_hdr {
 	struct list_head	segs;      /* layout segments list */
 	seqlock_t		seqlock;   /* Protects the stateid */
 	nfs4_stateid		stateid;
-	unsigned long		state;
+	unsigned long		plh_flags;
 	struct inode		*inode;
 };
 
-- 
1.7.2.1

