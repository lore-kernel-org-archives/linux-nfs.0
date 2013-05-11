Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f176.google.com ([74.125.82.176]:51518 "EHLO
	mail-we0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757178Ab3EKCoZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 May 2013 22:44:25 -0400
Received: by mail-we0-f176.google.com with SMTP id p60so4442131wes.21
        for <linux-nfs@vger.kernel.org>; Fri, 10 May 2013 19:44:24 -0700 (PDT)
Received: from bhalevy-lt.il.tonian.com (bzq-79-180-144-28.red.bezeqint.net. [79.180.144.28])
        by mx.google.com with ESMTPSA id q20sm1356368wiv.7.2013.05.10.19.44.23
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 10 May 2013 19:44:23 -0700 (PDT)
From: Benny Halevy <bhalevy@tonian.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 29/38] pnfsd: layout state: hang layouts on layout state
Date: Sat, 11 May 2013 05:44:19 +0300
Message-Id: <1368240259-821-1-git-send-email-bhalevy@tonian.com>
In-Reply-To: <518B6377.3000207@tonian.com>
References: <518B6377.3000207@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Rather than list the layout directly on the corresponding file and client
list the layout state on the file and client and list all layout segments
associated with the state on the respective layout state.

Use the layout state list (lo_layouts) for looking up the layout.

Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 fs/nfsd/nfs4pnfsd.c | 157 ++++++++++++++++++++++++++--------------------------
 fs/nfsd/nfs4state.c |   2 -
 fs/nfsd/pnfsd.h     |   6 +-
 fs/nfsd/state.h     |   2 -
 4 files changed, 79 insertions(+), 88 deletions(-)

diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
index 50b5208..d3a0bde 100644
--- a/fs/nfsd/nfs4pnfsd.c
+++ b/fs/nfsd/nfs4pnfsd.c
@@ -133,6 +133,7 @@ struct sbid_tracker {
 	nfsd4_init_stid(&new->ls_stid, clp, NFS4_LAYOUT_STID);
 	INIT_LIST_HEAD(&new->ls_perclnt);
 	INIT_LIST_HEAD(&new->ls_perfile);
+	INIT_LIST_HEAD(&new->ls_layouts);
 	new->ls_client = clp;
 	get_nfs4_file(fp);	/* released on destroy_layout_state */
 	new->ls_file = fp;
@@ -276,13 +277,6 @@ static void update_layout_stateid_locked(struct nfs4_layout_state *ls, stateid_t
 		__func__, sid->si_generation, ls);
 }
 
-static void update_layout_stateid(struct nfs4_layout_state *ls, stateid_t *sid)
-{
-	spin_lock(&layout_lock);
-	update_layout_stateid_locked(ls, sid);
-	spin_unlock(&layout_lock);
-}
-
 static void update_layout_roc(struct nfs4_layout_state *ls, bool roc)
 {
 	if (roc) {
@@ -295,35 +289,28 @@ static void update_layout_roc(struct nfs4_layout_state *ls, bool roc)
 static void
 init_layout(struct nfs4_layout *lp,
 	    struct nfs4_layout_state *ls,
-	    struct nfs4_file *fp,
-	    struct nfs4_client *clp,
 	    struct svc_fh *current_fh,
 	    struct nfsd4_layout_seg *seg,
 	    stateid_t *stateid)
 {
-	dprintk("pNFS %s: lp %p ls %p clp %p fp %p ino %p\n", __func__,
-		lp, ls, clp, fp, fp->fi_inode);
+	dprintk("pNFS %s: lp %p ls %p ino %lu\n", __func__,
+		lp, ls, ls->ls_file->fi_inode->i_ino);
 
-	get_nfs4_file(fp);
-	lp->lo_client = clp;
-	lp->lo_file = fp;
 	memcpy(&lp->lo_seg, seg, sizeof(lp->lo_seg));
 	get_layout_state(ls);		/* put on destroy_layout */
 	lp->lo_state = ls;
-	update_layout_stateid(ls, stateid);
-	list_add_tail(&lp->lo_perclnt, &clp->cl_layouts);
-	list_add_tail(&lp->lo_perfile, &fp->fi_layouts);
+	spin_lock(&layout_lock);
+	update_layout_stateid_locked(ls, stateid);
+	list_add_tail(&lp->lo_perstate, &ls->ls_layouts);
+	spin_unlock(&layout_lock);
 	dprintk("pNFS %s end\n", __func__);
 }
 
-/*
- * Note: always called under the layout_lock
- */
 static void
 dequeue_layout(struct nfs4_layout *lp)
 {
-	list_del(&lp->lo_perclnt);
-	list_del(&lp->lo_perfile);
+	ASSERT_LAYOUT_LOCKED();
+	list_del_init(&lp->lo_perstate);
 }
 
 /*
@@ -332,20 +319,15 @@ static void update_layout_roc(struct nfs4_layout_state *ls, bool roc)
 static void
 destroy_layout(struct nfs4_layout *lp)
 {
-	struct nfs4_client *clp;
-	struct nfs4_file *fp;
 	struct nfs4_layout_state *ls;
 
-	clp = lp->lo_client;
-	fp = lp->lo_file;
 	ls = lp->lo_state;
-	dprintk("pNFS %s: lp %p clp %p fp %p ino %p\n",
-		__func__, lp, clp, fp, fp->fi_inode);
+	dprintk("pNFS %s: lp %p ls %p ino %lu\n",
+		__func__, lp, ls, ls->ls_file->fi_inode->i_ino);
 
 	kmem_cache_free(pnfs_layout_slab, lp);
 	/* release references taken by init_layout */
 	put_layout_state(ls);
-	put_nfs4_file(fp);
 }
 
 static void fs_layout_return(struct inode *ino,
@@ -635,15 +617,13 @@ struct super_block *
 }
 
 static bool
-merge_layout(struct nfs4_file *fp,
-	     struct nfs4_client *clp,
-	     struct nfsd4_layout_seg *seg)
+merge_layout(struct nfs4_layout_state *ls, struct nfsd4_layout_seg *seg)
 {
 	bool ret = false;
 	struct nfs4_layout *lp;
 
 	spin_lock(&layout_lock);
-	list_for_each_entry (lp, &fp->fi_layouts, lo_perfile)
+	list_for_each_entry (lp, &ls->ls_layouts, lo_perstate)
 		if (lp->lo_seg.layout_type == seg->layout_type &&
 		    lp->lo_seg.clientid == seg->clientid &&
 		    lp->lo_seg.iomode == seg->iomode &&
@@ -795,11 +775,11 @@ struct super_block *
 	 * Can the new layout be merged into an existing one?
 	 * If so, free unused layout struct
 	 */
-	if (can_merge && merge_layout(fp, clp, &res.lg_seg))
+	if (can_merge && merge_layout(ls, &res.lg_seg))
 		goto out_freelayout;
 
 	/* Can't merge, so let's initialize this new layout */
-	init_layout(lp, ls, fp, clp, lgp->lg_fhp, &res.lg_seg, &lgp->lg_sid);
+	init_layout(lp, ls, lgp->lg_fhp, &res.lg_seg, &lgp->lg_sid);
 out_unlock:
 	if (ls)
 		put_layout_state(ls);
@@ -883,8 +863,8 @@ struct super_block *
 		return;
 	}
 
-	list_for_each_entry_safe(lo, nextlp, lo_destroy_list, lo_perfile) {
-		struct inode *inode = lo->lo_file->fi_inode;
+	list_for_each_entry_safe(lo, nextlp, lo_destroy_list, lo_perstate) {
+		struct inode *inode = lo->lo_state->ls_file->fi_inode;
 		struct nfsd4_pnfs_layoutreturn lr;
 		bool empty;
 		int lr_flags = flags;
@@ -894,39 +874,39 @@ struct super_block *
 		lr.args.lr_seg = lo->lo_seg;
 
 		spin_lock(&layout_lock);
-		if (list_empty(&lo->lo_file->fi_layouts))
+		if (list_empty(&lo->lo_state->ls_file->fi_lo_states))
 			lr_flags |= LR_FLAG_EMPTY;
 		spin_unlock(&layout_lock);
 
-		list_del(&lo->lo_perfile);
+		list_del(&lo->lo_perstate);
 		empty = list_empty(lo_destroy_list);
 
 		fs_layout_return(inode, &lr, lr_flags, empty ? cb_cookie : NULL);
 
-		destroy_layout(lo); /* this will put the lo_file */
+		destroy_layout(lo);
 	}
 }
 
+/*
+ * Return layouts for RETURN_FILE
+ */
 static int
-pnfs_return_file_layouts(struct nfs4_client *clp, struct nfs4_file *fp,
-			 struct nfsd4_pnfs_layoutreturn *lrp,
+pnfs_return_file_layouts(struct nfsd4_pnfs_layoutreturn *lrp,
 			 struct nfs4_layout_state *ls,
 			 struct list_head *lo_destroy_list)
 {
 	int layouts_found = 0;
 	struct nfs4_layout *lp, *nextlp;
 
-	dprintk("%s: clp %p fp %p\n", __func__, clp, fp);
+	dprintk("%s: ls %p\n", __func__, ls);
 	lrp->lrs_present = 0;
 	spin_lock(&layout_lock);
-	list_for_each_entry_safe (lp, nextlp, &fp->fi_layouts, lo_perfile) {
-		dprintk("%s: lp %p client %p,%p lo_type %x,%x iomode %d,%d\n",
-			__func__, lp,
-			lp->lo_client, clp,
+	list_for_each_entry_safe (lp, nextlp, &ls->ls_layouts, lo_perstate) {
+		dprintk("%s: lp %p ls %p inode %lu lo_type %x,%x iomode %d,%d\n",
+			__func__, lp, lp->lo_state,
+			lp->lo_state->ls_file->fi_inode->i_ino,
 			lp->lo_seg.layout_type, lrp->args.lr_seg.layout_type,
 			lp->lo_seg.iomode, lrp->args.lr_seg.iomode);
-		if (lp->lo_client != clp)
-			continue;
 		if (lp->lo_seg.layout_type != lrp->args.lr_seg.layout_type ||
 		    (lp->lo_seg.iomode != lrp->args.lr_seg.iomode &&
 		     lrp->args.lr_seg.iomode != IOMODE_ANY) ||
@@ -938,7 +918,7 @@ struct super_block *
 		trim_layout(&lp->lo_seg, &lrp->args.lr_seg);
 		if (!lp->lo_seg.length) {
 			dequeue_layout(lp);
-			list_add_tail(&lp->lo_perfile, lo_destroy_list);
+			list_add_tail(&lp->lo_perstate, lo_destroy_list);
 		} else
 			lrp->lrs_present = 1;
 	}
@@ -949,28 +929,36 @@ struct super_block *
 	return layouts_found;
 }
 
+/*
+ * Return layouts for RETURN_FSID or RETURN_ALL
+ */
 static int
 pnfs_return_client_layouts(struct nfs4_client *clp,
 			   struct nfsd4_pnfs_layoutreturn *lrp, u64 ex_fsid,
 			   struct list_head *lo_destroy_list)
 {
 	int layouts_found = 0;
+	struct nfs4_layout_state *ls, *nextls;
 	struct nfs4_layout *lp, *nextlp;
 
 	spin_lock(&layout_lock);
-	list_for_each_entry_safe (lp, nextlp, &clp->cl_layouts, lo_perclnt) {
-		if (lrp->args.lr_seg.layout_type != lp->lo_seg.layout_type ||
-		   (lrp->args.lr_seg.iomode != lp->lo_seg.iomode &&
-		    lrp->args.lr_seg.iomode != IOMODE_ANY))
-			continue;
-
+	list_for_each_entry_safe (ls, nextls, &clp->cl_lo_states, ls_perclnt) {
 		if (lrp->args.lr_return_type == RETURN_FSID &&
-		    !same_fsid_major(&lp->lo_file->fi_fsid, ex_fsid))
+		    !same_fsid_major(&ls->ls_file->fi_fsid, ex_fsid))
 			continue;
 
-		layouts_found++;
-		dequeue_layout(lp);
-		list_add_tail(&lp->lo_perfile, lo_destroy_list);
+		list_for_each_entry_safe (lp, nextlp, &ls->ls_layouts, lo_perstate) {
+			if (lrp->args.lr_seg.layout_type != lp->lo_seg.layout_type)
+				break;
+
+			if (lrp->args.lr_seg.iomode != lp->lo_seg.iomode &&
+			    lrp->args.lr_seg.iomode != IOMODE_ANY)
+				continue;
+
+			layouts_found++;
+			dequeue_layout(lp);
+			list_add_tail(&lp->lo_perstate, lo_destroy_list);
+		}
 	}
 	spin_unlock(&layout_lock);
 
@@ -1071,8 +1059,7 @@ int nfs4_pnfs_return_layout(struct svc_rqst *rqstp,
 			goto out_put_file;
 
 		/* update layouts */
-		layouts_found = pnfs_return_file_layouts(clp, fp, lrp, ls,
-							 &lo_destroy_list);
+		layouts_found = pnfs_return_file_layouts(lrp, ls, &lo_destroy_list);
 		put_layout_state(ls);
 		if (!lrp->lrs_present)
 			lr_flags |= LR_FLAG_CL_EMPTY;
@@ -1202,8 +1189,13 @@ int nfs4_pnfs_return_layout(struct svc_rqst *rqstp,
 		clr->clr_client, clr->clr_file);
 
 	if (clr->cb.cbl_recall_type == RETURN_FILE) {
-		pnfs_return_file_layouts(clr->clr_client, clr->clr_file, &lr,
-					 NULL, &lo_destroy_list);
+		struct nfs4_layout_state *ls;
+
+		list_for_each_entry (ls, &clr->clr_client->cl_lo_states, ls_perclnt)
+			if (ls->ls_file == clr->clr_file) {
+				pnfs_return_file_layouts(&lr, ls, &lo_destroy_list);
+				break;
+			}
 		if (!lr.lrs_present)
 			lr_flags |= LR_FLAG_CL_EMPTY;
 	} else {
@@ -1222,6 +1214,15 @@ int nfs4_pnfs_return_layout(struct svc_rqst *rqstp,
 			     recall_cookie);
 }
 
+void strip_layout_state(struct nfs4_layout_state *ls, struct list_head *lo_destroy_list)
+{
+	unhash_layout_state(ls);
+	if (!list_empty(&ls->ls_layouts)) {
+		list_splice(&ls->ls_layouts, lo_destroy_list);
+		INIT_LIST_HEAD(&ls->ls_layouts);
+	}
+}
+
 /* Return On Close:
  *   Look for all layouts of @fp that belong to @clp, if ROC is set, remove
  *   the layout and simulate a layout_return. Surly the client has forgotten
@@ -1229,30 +1230,27 @@ int nfs4_pnfs_return_layout(struct svc_rqst *rqstp,
  */
 void pnfsd_roc(struct nfs4_client *clp, struct nfs4_file *fp)
 {
-	struct nfs4_layout *lo, *nextlp;
+	struct nfs4_layout_state *ls, *nextls;
 	LIST_HEAD(lo_destroy_list);
 
 	/* TODO: We need to also free layout recalls like pnfs_expire_client */
 	dprintk("%s: fp=%p clp=%p", __func__, fp, clp);
 	spin_lock(&layout_lock);
-	list_for_each_entry_safe (lo, nextlp, &fp->fi_layouts, lo_perfile) {
-		/* Check for a match */
-		if (lo->lo_client != clp)
+	list_for_each_entry_safe (ls, nextls, &fp->fi_lo_states, ls_perfile) {
+		if (ls->ls_client != clp)
 			continue;
 
-		/* Return the layout */
-		list_del_init(&lo->lo_state->ls_perfile);	/* just to be on the safe side */
-		dequeue_layout(lo);
-		list_add_tail(&lo->lo_perfile, &lo_destroy_list);
+		strip_layout_state(ls, &lo_destroy_list);
+		break;
 	}
 	spin_unlock(&layout_lock);
 
-	pnfsd_return_lo_list(&lo_destroy_list, NULL, NULL, LR_FLAG_INTERN, NULL);
+	pnfsd_return_lo_list(&lo_destroy_list, fp->fi_inode, NULL, LR_FLAG_INTERN, NULL);
 }
 
 void pnfs_expire_client(struct nfs4_client *clp)
 {
-	struct nfs4_layout *lo, *nextlo;
+	struct nfs4_layout_state *ls, *nextls;
 	LIST_HEAD(lo_destroy_list);
 
 	for (;;) {
@@ -1275,12 +1273,11 @@ void pnfs_expire_client(struct nfs4_client *clp)
 	}
 
 	spin_lock(&layout_lock);
-	list_for_each_entry_safe (lo, nextlo, &clp->cl_layouts, lo_perclnt) {
-		BUG_ON(lo->lo_client != clp);
-		dequeue_layout(lo);
-		list_add_tail(&lo->lo_perfile, &lo_destroy_list);
-		dprintk("%s: inode %lu lp %p clp %p\n", __func__,
-			lo->lo_file->fi_inode->i_ino, lo, clp);
+	list_for_each_entry_safe (ls, nextls, &clp->cl_lo_states, ls_perclnt) {
+		BUG_ON(ls->ls_client != clp);
+		strip_layout_state(ls, &lo_destroy_list);
+		dprintk("%s: inode %lu ls %p clp %p\n", __func__,
+			ls->ls_file->fi_inode->i_ino, ls, clp);
 	}
 	spin_unlock(&layout_lock);
 
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 4f40327..faef919 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1321,7 +1321,6 @@ static struct nfs4_client *create_client(struct xdr_netobj name,
 	INIT_LIST_HEAD(&clp->cl_openowners);
 	INIT_LIST_HEAD(&clp->cl_delegations);
 #if defined(CONFIG_PNFSD)
-	INIT_LIST_HEAD(&clp->cl_layouts);
 	INIT_LIST_HEAD(&clp->cl_lo_states);
 	INIT_LIST_HEAD(&clp->cl_layoutrecalls);
 #endif /* CONFIG_PNFSD */
@@ -2364,7 +2363,6 @@ static void nfsd4_init_file(struct nfs4_file *fp, struct inode *ino,
 	memset(fp->fi_fds, 0, sizeof(fp->fi_fds));
 	memset(fp->fi_access, 0, sizeof(fp->fi_access));
 #if defined(CONFIG_PNFSD)
-	INIT_LIST_HEAD(&fp->fi_layouts);
 	INIT_LIST_HEAD(&fp->fi_lo_states);
 	fp->fi_fsid.major = current_fh->fh_export->ex_fsid;
 	fp->fi_fsid.minor = 0;
diff --git a/fs/nfsd/pnfsd.h b/fs/nfsd/pnfsd.h
index 454ef23..453f951 100644
--- a/fs/nfsd/pnfsd.h
+++ b/fs/nfsd/pnfsd.h
@@ -48,15 +48,13 @@ struct nfs4_layout_state {
 	struct nfs4_client	*ls_client;
 	struct list_head	ls_perfile;
 	struct nfs4_file	*ls_file;
+	struct list_head	ls_layouts;
 	bool			ls_roc;
 };
 
 /* outstanding layout */
 struct nfs4_layout {
-	struct list_head		lo_perfile;	/* hash by f_id */
-	struct list_head		lo_perclnt;	/* hash by clientid */
-	struct nfs4_file		*lo_file;	/* backpointer */
-	struct nfs4_client		*lo_client;
+	struct list_head		lo_perstate;
 	struct nfs4_layout_state	*lo_state;
 	struct nfsd4_layout_seg		lo_seg;
 };
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index e026e0d..ab4a136 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -282,7 +282,6 @@ struct nfs4_client {
 						/* wait here for slots */
 	struct net		*net;
 #if defined(CONFIG_PNFSD)
-	struct list_head	cl_layouts;	/* outstanding layouts */
 	struct list_head	cl_lo_states;	/* outstanding layout states */
 	struct list_head	cl_layoutrecalls; /* outstanding layoutrecall
 						     callbacks */
@@ -412,7 +411,6 @@ struct nfs4_file {
 	struct inode		*fi_inode;
 	bool			fi_had_conflict;
 #if defined(CONFIG_PNFSD)
-	struct list_head	fi_layouts;
 	struct list_head	fi_lo_states;
 	/* used by layoutget / layoutrecall */
 	struct nfs4_fsid	fi_fsid;
-- 
1.7.11.7

