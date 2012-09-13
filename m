Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:36066 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759116Ab2IMXgb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 13 Sep 2012 19:36:31 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@tonian.com>, NFS list <linux-nfs@vger.kernel.org>,
        open-osd <osd-dev@open-osd.org>
Subject: [PATCH 05/10] {SPLITME} SQUASHME: pnfsd: Revamp the all layout_return operations
Date: Fri, 14 Sep 2012 02:36:18 +0300
Message-ID: <1347579378-21582-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <50526B39.3000802@panasas.com>
References: <50526B39.3000802@panasas.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

cleanups:
  - In nfs4_pnfs_return_layout, move local variables into the
    code sections that use them, so to better understand their
    scope. (And untangle the error handling)
  - Lots of places had simulated layout_returns based on
    lo_segments. They are all in a single place now.

Fixes:
  Every code path that eventually called fs_layout_return
  had different locking. Some held both the layout_spinlock
  has well as nfs-lock. Some one or the other, some none.
  Fix all sites to never hold any locks, before calling
  The FS.

enhancements:
  We change the code so there is now a one-to-one
  relationship between a layout_gotten and a layout_returned.
  Note that this was the case in ROC or expire_client. We
  now do the same for layouts explicitly returned in
  nfs4_pnfs_return_layout and no_matching_layout.

  Now For each lo_segment received from FS and added to
  the layoutDB we send a corresponding layout_return, when
  the lo_segment is removed from the DB (and before
  it is destroyed releasing the inode ref).

  An FS can now attach an *lo_cookie* to each lo_segment
  and before this lo_segment is forever released this
  lo_cookie is layout_returned to the FS. An FS can have
  resources associated with each lo_segment, and when
  the client is completely done with that lo_segment
  it can now release those resources. (Eliminating the
  need for the FS to keep it's own lo_lists)

  If the client sent a partial lo_return we do report
  such a partial lo_return to FS, and as before, we adjust
  our lo_DB to only hold the reminder of the lo_segment.
  The final lo_return that has removed the lo_segment from
  DB will pass the lo_cookie to the FS denoting closure.

  If, for example, in the case of nfs4_pnfs_return_layout
  or no_matching_layout one lo_return spans multiple
  lo_segments. The FS is called multiple times, for each
  lo_segment released, together with its lo_cookie.

  And finally, like today, if a return satisfies a recall,
  before that recall is released the recall_cookie is also
  passed back to the FS, attached the the last segment
  matching the recall. (If because of races the recall was
  actually empty, a special lo_return is sent with just the
  recall_cookie)

  We also have a new flag in layout_return that tells the
  FS that the lo_list is *empty* attached to the very last
  lo returned.

  This new system makes the code surprisingly smaller and
  cleaner, because all code sites look the same and use
  common code. (And it can be done even better, if some of
  the lo_return and lo_get API gets united a bit)

  And probably some more stuff ...

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/nfsd/nfs4pnfsd.c             | 200 +++++++++++++++++++++++-----------------
 fs/nfsd/pnfsd.h                 |   1 +
 include/linux/nfsd/nfsd4_pnfs.h |   3 +
 3 files changed, 117 insertions(+), 87 deletions(-)

diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
index 5228e3b..e0ad1d7 100644
--- a/fs/nfsd/nfs4pnfsd.c
+++ b/fs/nfsd/nfs4pnfsd.c
@@ -304,13 +304,14 @@ init_layout(struct nfs4_layout *lp,
 	    struct nfsd4_pnfs_layoutget *lgp,
 	    struct nfsd4_pnfs_layoutget_res *res)
 {
-	dprintk("pNFS %s: lp %p ls %p clp %p fp %p ino %p\n", __func__,
-		lp, ls, clp, fp, fp->fi_inode);
+	dprintk("pNFS %s: lp %p ls %p clp %p fp %p ino %p lo_cookie %p\n",
+		__func__, lp, ls, clp, fp, fp->fi_inode, res->lg_lo_cookie);
 
 	get_nfs4_file(fp);
 	lp->lo_client = clp;
 	lp->lo_file = fp;
-	memcpy(&lp->lo_seg, &res->lg_seg, sizeof(lp->lo_seg));
+	lp->lo_seg = res->lg_seg;
+	lp->lo_cookie = res->lg_lo_cookie;
 	get_layout_state(ls);		/* put on destroy_layout */
 	lp->lo_state = ls;
 	update_layout_stateid(ls, &lgp->lg_sid);
@@ -349,25 +350,25 @@ destroy_layout(struct nfs4_layout *lp)
 	put_nfs4_file(fp);
 }
 
-void fs_layout_return(struct super_block *sb, struct inode *ino,
-		      struct nfsd4_pnfs_layoutreturn *lrp, void *recall_cookie)
+void fs_layout_return(struct inode *ino, struct nfsd4_pnfs_layoutreturn *lrp,
+		      bool empty, void *recall_cookie, void *lo_cookie)
 {
+	struct super_block *sb = ino->i_sb;
 	int ret;
 
 	if (unlikely(!sb->s_pnfs_op->layout_return))
 		return;
 
 	lrp->args.lr_cookie = recall_cookie;
-
-	if (!ino) /* FSID or ALL */
-		ino = sb->s_root->d_inode;
+	lrp->args.lr_lo_cookie = lo_cookie;
+	lrp->args.lr_empty = empty;
 
 	ret = sb->s_pnfs_op->layout_return(ino, &lrp->args);
 	dprintk("%s: inode %lu iomode=%d offset=0x%llx length=0x%llx "
-		"cookie=%p status=%d\n",
+		"cookie=%p empty=%x status=%d\n",
 		__func__, ino->i_ino, lrp->args.lr_seg.iomode,
 		lrp->args.lr_seg.offset, lrp->args.lr_seg.length,
-		recall_cookie, ret);
+		recall_cookie, empty, ret);
 }
 
 static u64
@@ -880,10 +881,65 @@ out:
 	dprintk("%s:End lo %llu:%lld\n", __func__, lo->offset, lo->length);
 }
 
+static void
+pnfsd_return_lo_list(struct list_head *lo_destroy_list, struct inode *ino_orig,
+		     struct nfsd4_pnfs_layoutreturn *lr_orig, void *cb_cookie)
+{
+	struct nfs4_layout *lo, *nextlp;
+
+	if (list_empty(lo_destroy_list) && cb_cookie) {
+		/* This is a rare race case where at the time of recall there
+		 * were some layouts, which got freed before the recall-done.
+		 * and the recall was left without any actual layouts to free.
+		 * If the FS gave us a cb_cookie it is waiting for it so we
+		 * report back about it here.
+		 */
+
+		/* Any caller with a cb_cookie must pass a none null
+		 * ino_orig and an lr_orig.
+		 */
+		struct inode *inode = igrab(ino_orig);
+
+		/* Probably a BUG_ON but just in case. Caller of cb_recall must
+		 * take care of this. Please report to ml */
+		if (WARN_ON(!inode))
+				return;
+
+		fs_layout_return(inode, lr_orig, true, cb_cookie, NULL);
+		iput(inode);
+		return;
+	}
+
+	list_for_each_entry_safe(lo, nextlp, lo_destroy_list, lo_perfile) {
+		struct inode *inode = lo->lo_file->fi_inode;
+		struct nfsd4_pnfs_layoutreturn lr;
+		bool empty;
+
+		memset(&lr, 0, sizeof(lr));
+		lr.args.lr_return_type = RETURN_FILE;
+		lr.args.lr_seg = lo->lo_seg;
+
+		list_del(&lo->lo_perfile);
+		empty = list_empty(lo_destroy_list);
+
+		fs_layout_return(inode, &lr, empty, empty ? cb_cookie : NULL,
+				 lo->lo_cookie);
+
+		/* FIXME: A comment at destroy_layout says we need layout_lock
+		 * But is that true? dequeue_layout was done under lock
+		 * Must we lock for destroy_layout?
+		 */
+		spin_lock(&layout_lock);
+		destroy_layout(lo); /* this will put the lo_file */
+		spin_unlock(&layout_lock);
+	}
+}
+
 static int
 pnfs_return_file_layouts(struct nfs4_client *clp, struct nfs4_file *fp,
 			 struct nfsd4_pnfs_layoutreturn *lrp,
-			 struct nfs4_layout_state *ls)
+			 struct nfs4_layout_state *ls,
+			 struct list_head *lo_destroy_list)
 {
 	int layouts_found = 0;
 	struct nfs4_layout *lp, *nextlp;
@@ -908,7 +964,7 @@ pnfs_return_file_layouts(struct nfs4_client *clp, struct nfs4_file *fp,
 		if (!lp->lo_seg.length) {
 			lrp->lrs_present = 0;
 			dequeue_layout(lp);
-			destroy_layout(lp);
+			list_add_tail(&lp->lo_perfile, lo_destroy_list);
 		}
 	}
 	if (ls && layouts_found && lrp->lrs_present)
@@ -920,7 +976,8 @@ pnfs_return_file_layouts(struct nfs4_client *clp, struct nfs4_file *fp,
 
 static int
 pnfs_return_client_layouts(struct nfs4_client *clp,
-			   struct nfsd4_pnfs_layoutreturn *lrp, u64 ex_fsid)
+			   struct nfsd4_pnfs_layoutreturn *lrp, u64 ex_fsid,
+			   struct list_head *lo_destroy_list)
 {
 	int layouts_found = 0;
 	struct nfs4_layout *lp, *nextlp;
@@ -938,7 +995,7 @@ pnfs_return_client_layouts(struct nfs4_client *clp,
 
 		layouts_found++;
 		dequeue_layout(lp);
-		destroy_layout(lp);
+		list_add_tail(&lp->lo_perfile, lo_destroy_list);
 	}
 	spin_unlock(&layout_lock);
 
@@ -1000,8 +1057,8 @@ int nfs4_pnfs_return_layout(struct super_block *sb, struct svc_fh *current_fh,
 	struct inode *ino = current_fh->fh_dentry->d_inode;
 	struct nfs4_file *fp = NULL;
 	struct nfs4_client *clp;
-	struct nfs4_layout_state *ls = NULL;
 	struct nfs4_layoutrecall *clr, *nextclr;
+	LIST_HEAD(lo_destroy_list);
 	u64 ex_fsid = current_fh->fh_export->ex_fsid;
 	void *recall_cookie = NULL;
 
@@ -1013,6 +1070,8 @@ int nfs4_pnfs_return_layout(struct super_block *sb, struct svc_fh *current_fh,
 		goto out;
 
 	if (lrp->args.lr_return_type == RETURN_FILE) {
+		struct nfs4_layout_state *ls = NULL;
+
 		fp = find_file(ino);
 		if (!fp) {
 			nfs4_unlock_state();
@@ -1023,7 +1082,7 @@ int nfs4_pnfs_return_layout(struct super_block *sb, struct svc_fh *current_fh,
 			 * don't then it means all layouts were ROC and at this
 			 * point we returned all of them on file close.
 			 */
-			goto out_no_fs_call;
+			goto out_see_about_recalls;
 		}
 
 		/* Check the stateid */
@@ -1033,12 +1092,12 @@ int nfs4_pnfs_return_layout(struct super_block *sb, struct svc_fh *current_fh,
 			goto out_put_file;
 
 		/* update layouts */
-		layouts_found = pnfs_return_file_layouts(clp, fp, lrp, ls);
-		/* optimize for the all-empty case */
-		if (list_empty(&fp->fi_layouts))
-			recall_cookie = PNFS_LAST_LAYOUT_NO_RECALLS;
+		layouts_found = pnfs_return_file_layouts(clp, fp, lrp, ls,
+							 &lo_destroy_list);
+		put_layout_state(ls);
 	} else {
-		layouts_found = pnfs_return_client_layouts(clp, lrp, ex_fsid);
+		layouts_found = pnfs_return_client_layouts(clp, lrp, ex_fsid,
+							   &lo_destroy_list);
 	}
 
 	dprintk("pNFS %s: clp %p fp %p layout_type 0x%x iomode %d "
@@ -1049,6 +1108,7 @@ int nfs4_pnfs_return_layout(struct super_block *sb, struct svc_fh *current_fh,
 		ex_fsid,
 		lrp->args.lr_seg.offset, lrp->args.lr_seg.length, layouts_found);
 
+out_see_about_recalls:
 	/* update layoutrecalls
 	 * note: for RETURN_{FSID,ALL}, fp may be NULL
 	 */
@@ -1066,18 +1126,15 @@ int nfs4_pnfs_return_layout(struct super_block *sb, struct svc_fh *current_fh,
 	}
 	spin_unlock(&layout_lock);
 
+	pnfsd_return_lo_list(&lo_destroy_list, ino ? ino : sb->s_root->d_inode,
+			     lrp, recall_cookie);
+
 out_put_file:
 	if (fp)
 		put_nfs4_file(fp);
-	if (ls)
-		put_layout_state(ls);
 out:
 	nfs4_unlock_state();
 
-	/* call exported filesystem layout_return (ignore return-code) */
-	fs_layout_return(sb, ino, lrp, recall_cookie);
-
-out_no_fs_call:
 	dprintk("pNFS %s: exit status %d\n", __func__, status);
 	return status;
 }
@@ -1188,32 +1245,26 @@ nomatching_layout(struct nfs4_layoutrecall *clr)
 		.args.lr_seg = clr->cb.cbl_seg,
 	};
 	struct inode *inode;
+	LIST_HEAD(lo_destroy_list);
 	void *recall_cookie;
 
-	if (clr->clr_file) {
-		inode = igrab(clr->clr_file->fi_inode);
-		if (WARN_ON(!inode))
-			return;
-	} else {
-		inode = NULL;
-	}
-
 	dprintk("%s: clp %p fp %p: simulating layout_return\n", __func__,
 		clr->clr_client, clr->clr_file);
 
 	if (clr->cb.cbl_recall_type == RETURN_FILE)
 		pnfs_return_file_layouts(clr->clr_client, clr->clr_file, &lr,
-					 NULL);
+					 NULL, &lo_destroy_list);
 	else
 		pnfs_return_client_layouts(clr->clr_client, &lr,
-					   clr->cb.cbl_fsid.major);
+					   clr->cb.cbl_fsid.major,
+					   &lo_destroy_list);
 
 	spin_lock(&layout_lock);
 	recall_cookie = layoutrecall_done(clr);
 	spin_unlock(&layout_lock);
 
-	fs_layout_return(clr->clr_sb, inode, &lr, recall_cookie);
-	iput(inode);
+	inode = clr->clr_file->fi_inode ?: clr->clr_sb->s_root->d_inode;
+	pnfsd_return_lo_list(&lo_destroy_list, inode, &lr, recall_cookie);
 }
 
 /* Return On Close:
@@ -1224,38 +1275,35 @@ nomatching_layout(struct nfs4_layoutrecall *clr)
 void pnfsd_roc(struct nfs4_client *clp, struct nfs4_file *fp)
 {
 	struct nfs4_layout *lo, *nextlp;
-	bool found = false;
+	LIST_HEAD(lo_destroy_list);
+
+
+	/* TODO: We need to also free layout recalls like pnfs_expire_client */
+	dprintk("%s: clp %p fp %p: simulating layout_return\n", __func__,
+		clp, fp);
 
 	dprintk("%s: fp=%p clp=%p", __func__, fp, clp);
 	spin_lock(&layout_lock);
 	list_for_each_entry_safe (lo, nextlp, &fp->fi_layouts, lo_perfile) {
-		struct nfsd4_pnfs_layoutreturn lr;
-		bool empty;
 
 		/* Check for a match */
 		if (!lo->lo_state->ls_roc || lo->lo_client != clp)
 			continue;
 
-		/* Return the layout */
-		memset(&lr, 0, sizeof(lr));
-		lr.args.lr_return_type = RETURN_FILE;
-		lr.args.lr_seg = lo->lo_seg;
+		/* Mark layout for return */
 		dequeue_layout(lo);
-		destroy_layout(lo); /* do not access lp after this */
-
-		empty = list_empty(&fp->fi_layouts);
-		found = true;
-		dprintk("%s: fp=%p clp=%p: return on close", __func__, fp, clp);
-		fs_layout_return(fp->fi_inode->i_sb, fp->fi_inode, &lr,
-				 empty ? PNFS_LAST_LAYOUT_NO_RECALLS : NULL);
+		list_add_tail(&lo->lo_perfile, &lo_destroy_list);
 	}
 	spin_unlock(&layout_lock);
-	if (!found)
-		dprintk("%s: no layout found", __func__);
+
+	pnfsd_return_lo_list(&lo_destroy_list, NULL, NULL, NULL);
 }
 
 void pnfs_expire_client(struct nfs4_client *clp)
 {
+	struct nfs4_layout *lo, *nextlo;
+	LIST_HEAD(lo_destroy_list);
+
 	for (;;) {
 		struct nfs4_layoutrecall *lrp = NULL;
 
@@ -1275,39 +1323,17 @@ void pnfs_expire_client(struct nfs4_client *clp)
 		put_layoutrecall(lrp);
 	}
 
-	for (;;) {
-		struct nfs4_layout *lp = NULL;
-		struct inode *inode = NULL;
-		struct nfsd4_pnfs_layoutreturn lr;
-		bool empty = false;
-
-		spin_lock(&layout_lock);
-		if (!list_empty(&clp->cl_layouts)) {
-			lp = list_entry(clp->cl_layouts.next,
-					struct nfs4_layout, lo_perclnt);
-			inode = igrab(lp->lo_file->fi_inode);
-			memset(&lr, 0, sizeof(lr));
-			lr.args.lr_return_type = RETURN_FILE;
-			lr.args.lr_seg = lp->lo_seg;
-			empty = list_empty(&lp->lo_file->fi_layouts);
-			BUG_ON(lp->lo_client != clp);
-			dequeue_layout(lp);
-			destroy_layout(lp); /* do not access lp after this */
-		}
-		spin_unlock(&layout_lock);
-		if (!lp)
-			break;
-
-		if (WARN_ON(!inode))
-			break;
-
-		dprintk("%s: inode %lu lp %p clp %p\n", __func__, inode->i_ino,
-			lp, clp);
-
-		fs_layout_return(inode->i_sb, inode, &lr,
-				 empty ? PNFS_LAST_LAYOUT_NO_RECALLS : NULL);
-		iput(inode);
+	spin_lock(&layout_lock);
+	list_for_each_entry_safe(lo, nextlo, &clp->cl_layouts, lo_perclnt) {
+		BUG_ON(lo->lo_client != clp);
+		dequeue_layout(lo);
+		list_add_tail(&lo->lo_perfile, &lo_destroy_list);
+		dprintk("%s: inode %lu lp %p clp %p\n", __func__,
+			lo->lo_file->fi_inode->i_ino, lo, clp);
 	}
+	spin_unlock(&layout_lock);
+
+	pnfsd_return_lo_list(&lo_destroy_list, NULL, NULL, NULL);
 }
 
 struct create_recall_list_arg {
diff --git a/fs/nfsd/pnfsd.h b/fs/nfsd/pnfsd.h
index 35859ff..53ed6f1 100644
--- a/fs/nfsd/pnfsd.h
+++ b/fs/nfsd/pnfsd.h
@@ -56,6 +56,7 @@ struct nfs4_layout {
 	struct nfs4_client		*lo_client;
 	struct nfs4_layout_state	*lo_state;
 	struct nfsd4_layout_seg		lo_seg;
+	void				*lo_cookie;
 };
 
 struct pnfs_inval_state {
diff --git a/include/linux/nfsd/nfsd4_pnfs.h b/include/linux/nfsd/nfsd4_pnfs.h
index 8d3d384..a35b93e 100644
--- a/include/linux/nfsd/nfsd4_pnfs.h
+++ b/include/linux/nfsd/nfsd4_pnfs.h
@@ -93,6 +93,7 @@ struct nfsd4_pnfs_layoutget_arg {
 struct nfsd4_pnfs_layoutget_res {
 	struct nfsd4_layout_seg	lg_seg;	/* request/resopnse */
 	u32			lg_return_on_close;
+	void			*lg_lo_cookie;  /* fs private */
 };
 
 struct nfsd4_pnfs_layoutcommit_arg {
@@ -119,6 +120,8 @@ struct nfsd4_pnfs_layoutreturn_arg {
 	u32			lrf_body_len;	/* request */
 	void			*lrf_body;	/* request */
 	void			*lr_cookie;	/* fs private */
+	void			*lr_lo_cookie;	/* fs private */
+	bool			lr_empty;	/* request */
 };
 
 /* pNFS Metadata to Data server state communication */
-- 
1.7.10.2.677.gb6bc67f

