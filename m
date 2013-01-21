Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ea0-f169.google.com ([209.85.215.169]:44382 "EHLO
	mail-ea0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752612Ab3AUOyo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jan 2013 09:54:44 -0500
Received: by mail-ea0-f169.google.com with SMTP id d13so2562375eaa.28
        for <linux-nfs@vger.kernel.org>; Mon, 21 Jan 2013 06:54:42 -0800 (PST)
From: Benny Halevy <bhalevy@tonian.com>
To: linux-nfs@vger.kernel.org
Cc: Boaz Harrosh <bharrosh@panasas.com>, Benny Halevy <bhalevy@tonian.com>
Subject: [PATCH 5/9] SQUASHME: pnfsd: fix locking around fs_layout_return
Date: Mon, 21 Jan 2013 16:54:39 +0200
Message-Id: <1358780079-6067-1-git-send-email-bhalevy@tonian.com>
In-Reply-To: <50FD5646.4020206@tonian.com>
References: <50FD5646.4020206@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Boaz Harrosh <bharrosh@panasas.com>

Every code path that eventually called fs_layout_return
had different locking. Some held both the layout_spinlock
has well as nfs-lock. Some one or the other, some none.
Fix all sites to never hold any locks, before calling
The FS.

Also, deprecate PNFS_LAST_LAYOUT_NO_RECALLS.
To be replaced with lr_flags bit

Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 fs/nfsd/nfs4pnfsd.c             | 176 ++++++++++++++++++++++------------------
 include/linux/nfsd/nfsd4_pnfs.h |   2 -
 2 files changed, 97 insertions(+), 81 deletions(-)

diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
index b8d0db8..d48abba 100644
--- a/fs/nfsd/nfs4pnfsd.c
+++ b/fs/nfsd/nfs4pnfsd.c
@@ -186,6 +186,9 @@ void pnfs_clear_device_notify(struct nfs4_client *clp)
 	kfree(ls);
 }
 
+/*
+ * Note: caller must not hold layout_lock
+ */
 static void
 put_layout_state(struct nfs4_layout_state *ls)
 {
@@ -321,6 +324,9 @@ static void update_layout_roc(struct nfs4_layout_state *ls, bool roc)
 	dprintk("pNFS %s end\n", __func__);
 }
 
+/*
+ * Note: always called under the layout_lock
+ */
 static void
 dequeue_layout(struct nfs4_layout *lp)
 {
@@ -329,7 +335,7 @@ static void update_layout_roc(struct nfs4_layout_state *ls, bool roc)
 }
 
 /*
- * Note: always called under the layout_lock
+ * Note: caller must not hold layout_lock
  */
 static void
 destroy_layout(struct nfs4_layout *lp)
@@ -881,10 +887,59 @@ struct super_block *
 	dprintk("%s:End lo %llu:%lld\n", __func__, lo->offset, lo->length);
 }
 
+static void
+pnfsd_return_lo_list(struct list_head *lo_destroy_list, struct inode *ino_orig,
+		     struct nfsd4_pnfs_layoutreturn *lr_orig, int flags,
+		     void *cb_cookie)
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
+			return;
+
+		fs_layout_return(inode, lr_orig, flags, cb_cookie);
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
+		fs_layout_return(inode, &lr, flags, empty ? cb_cookie : NULL);
+
+		destroy_layout(lo); /* this will put the lo_file */
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
@@ -911,7 +966,7 @@ struct super_block *
 		trim_layout(&lp->lo_seg, &lrp->args.lr_seg);
 		if (!lp->lo_seg.length) {
 			dequeue_layout(lp);
-			destroy_layout(lp);
+			list_add_tail(&lp->lo_perfile, lo_destroy_list);
 		} else
 			lrp->lrs_present = 1;
 	}
@@ -924,7 +979,8 @@ struct super_block *
 
 static int
 pnfs_return_client_layouts(struct nfs4_client *clp,
-			   struct nfsd4_pnfs_layoutreturn *lrp, u64 ex_fsid)
+			   struct nfsd4_pnfs_layoutreturn *lrp, u64 ex_fsid,
+			   struct list_head *lo_destroy_list)
 {
 	int layouts_found = 0;
 	struct nfs4_layout *lp, *nextlp;
@@ -942,7 +998,7 @@ struct super_block *
 
 		layouts_found++;
 		dequeue_layout(lp);
-		destroy_layout(lp);
+		list_add_tail(&lp->lo_perfile, lo_destroy_list);
 	}
 	spin_unlock(&layout_lock);
 
@@ -1004,10 +1060,10 @@ int nfs4_pnfs_return_layout(struct super_block *sb, struct svc_fh *current_fh,
 	struct inode *ino = current_fh->fh_dentry->d_inode;
 	struct nfs4_file *fp = NULL;
 	struct nfs4_client *clp;
-	struct nfs4_layout_state *ls = NULL;
 	struct nfs4_layoutrecall *clr, *nextclr;
 	u64 ex_fsid = current_fh->fh_export->ex_fsid;
 	void *recall_cookie = NULL;
+	LIST_HEAD(lo_destroy_list);
 
 	dprintk("NFSD: %s\n", __func__);
 
@@ -1017,6 +1073,8 @@ int nfs4_pnfs_return_layout(struct super_block *sb, struct svc_fh *current_fh,
 		goto out;
 
 	if (lrp->args.lr_return_type == RETURN_FILE) {
+		struct nfs4_layout_state *ls = NULL;
+
 		fp = find_file(ino);
 		if (!fp) {
 			nfs4_unlock_state();
@@ -1037,12 +1095,12 @@ int nfs4_pnfs_return_layout(struct super_block *sb, struct svc_fh *current_fh,
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
@@ -1073,13 +1131,12 @@ int nfs4_pnfs_return_layout(struct super_block *sb, struct svc_fh *current_fh,
 out_put_file:
 	if (fp)
 		put_nfs4_file(fp);
-	if (ls)
-		put_layout_state(ls);
+
 out:
 	nfs4_unlock_state();
 
-	/* call exported filesystem layout_return (ignore return-code) */
-	fs_layout_return(ino, lrp, 0, recall_cookie);
+	pnfsd_return_lo_list(&lo_destroy_list, ino ? ino : sb->s_root->d_inode,
+			     lrp, 0, recall_cookie);
 
 out_no_fs_call:
 	dprintk("pNFS %s: exit status %d\n", __func__, status);
@@ -1194,30 +1251,26 @@ int nfs4_pnfs_return_layout(struct super_block *sb, struct svc_fh *current_fh,
 	};
 	struct inode *inode;
 	void *recall_cookie;
-
-	if (clr->clr_file) {
-		inode = igrab(clr->clr_file->fi_inode);
-		if (WARN_ON(!inode))
-			return;
-	} else
-		inode = clr->clr_sb->s_root->d_inode;
+	LIST_HEAD(lo_destroy_list);
 
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
 
-	fs_layout_return(inode, &lr, LR_FLAG_INTERN, recall_cookie);
-	iput(inode);
+	inode = clr->clr_file->fi_inode ?: clr->clr_sb->s_root->d_inode;
+	pnfsd_return_lo_list(&lo_destroy_list, inode, &lr, LR_FLAG_INTERN,
+			     recall_cookie);
 }
 
 /* Return On Close:
@@ -1228,39 +1281,31 @@ int nfs4_pnfs_return_layout(struct super_block *sb, struct svc_fh *current_fh,
 void pnfsd_roc(struct nfs4_client *clp, struct nfs4_file *fp)
 {
 	struct nfs4_layout *lo, *nextlp;
-	bool found = false;
+	LIST_HEAD(lo_destroy_list);
 
+	/* TODO: We need to also free layout recalls like pnfs_expire_client */
 	dprintk("%s: fp=%p clp=%p", __func__, fp, clp);
 	spin_lock(&layout_lock);
 	list_for_each_entry_safe (lo, nextlp, &fp->fi_layouts, lo_perfile) {
-		struct nfsd4_pnfs_layoutreturn lr;
-		bool empty;
-
 		/* Check for a match */
 		if (lo->lo_client != clp)
 			continue;
 
 		/* Return the layout */
-		memset(&lr, 0, sizeof(lr));
-		lr.args.lr_return_type = RETURN_FILE;
-		lr.args.lr_seg = lo->lo_seg;
 		list_del_init(&lo->lo_state->ls_perfile);	/* just to be on the safe side */
 		dequeue_layout(lo);
-		destroy_layout(lo); /* do not access lp after this */
-
-		empty = list_empty(&fp->fi_layouts);
-		found = true;
-		dprintk("%s: fp=%p clp=%p: return on close", __func__, fp, clp);
-		fs_layout_return(fp->fi_inode, &lr, LR_FLAG_INTERN,
-				 empty ? PNFS_LAST_LAYOUT_NO_RECALLS : NULL);
+		list_add_tail(&lo->lo_perfile, &lo_destroy_list);
 	}
 	spin_unlock(&layout_lock);
-	if (!found)
-		dprintk("%s: no layout found", __func__);
+
+	pnfsd_return_lo_list(&lo_destroy_list, NULL, NULL, LR_FLAG_INTERN, NULL);
 }
 
 void pnfs_expire_client(struct nfs4_client *clp)
 {
+	struct nfs4_layout *lo, *nextlo;
+	LIST_HEAD(lo_destroy_list);
+
 	for (;;) {
 		struct nfs4_layoutrecall *lrp = NULL;
 
@@ -1280,40 +1325,17 @@ void pnfs_expire_client(struct nfs4_client *clp)
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
-			list_del_init(&lp->lo_state->ls_perfile);	/* just to be on the safe side */
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
-		fs_layout_return(inode, &lr, LR_FLAG_EXPIRE,
-				 empty ? PNFS_LAST_LAYOUT_NO_RECALLS : NULL);
-		iput(inode);
+	spin_lock(&layout_lock);
+	list_for_each_entry_safe (lo, nextlo, &clp->cl_layouts, lo_perclnt) {
+		BUG_ON(lo->lo_client != clp);
+		dequeue_layout(lo);
+		list_add_tail(&lo->lo_perfile, &lo_destroy_list);
+		dprintk("%s: inode %lu lp %p clp %p\n", __func__,
+			lo->lo_file->fi_inode->i_ino, lo, clp);
 	}
+	spin_unlock(&layout_lock);
+
+	pnfsd_return_lo_list(&lo_destroy_list, NULL, NULL, LR_FLAG_EXPIRE, NULL);
 }
 
 struct create_recall_list_arg {
@@ -1516,10 +1538,6 @@ struct create_recall_list_arg {
 
 	INIT_LIST_HEAD(&todolist);
 
-	/* If no cookie provided by FS, return a default one */
-	if (!cbl->cbl_cookie)
-		cbl->cbl_cookie = PNFS_LAST_LAYOUT_NO_RECALLS;
-
 	status = create_layout_recall_list(&todolist, &todo_len, cbl, lrfile);
 	if (list_empty(&todolist)) {
 		status = -ENOENT;
diff --git a/include/linux/nfsd/nfsd4_pnfs.h b/include/linux/nfsd/nfsd4_pnfs.h
index 76427d0..ec77175 100644
--- a/include/linux/nfsd/nfsd4_pnfs.h
+++ b/include/linux/nfsd/nfsd4_pnfs.h
@@ -110,8 +110,6 @@ struct nfsd4_pnfs_layoutcommit_res {
 	u64			lc_newsize;	/* response */
 };
 
-#define PNFS_LAST_LAYOUT_NO_RECALLS ((void *)-1) /* used with lr_cookie below */
-
 enum layoutreturn_flags {
 	LR_FLAG_INTERN = 1 << 0,	/* internal return */
 	LR_FLAG_EXPIRE = 1 << 1,	/* return on client expiration */
-- 
1.7.11.7

