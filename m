Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f169.google.com ([209.85.212.169]:36677 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756664Ab3EKCoc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 May 2013 22:44:32 -0400
Received: by mail-wi0-f169.google.com with SMTP id h11so1325012wiv.2
        for <linux-nfs@vger.kernel.org>; Fri, 10 May 2013 19:44:31 -0700 (PDT)
Received: from bhalevy-lt.il.tonian.com (bzq-79-180-144-28.red.bezeqint.net. [79.180.144.28])
        by mx.google.com with ESMTPSA id e8sm1219387wic.5.2013.05.10.19.44.30
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 10 May 2013 19:44:30 -0700 (PDT)
From: Benny Halevy <bhalevy@tonian.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 31/38] pnfsd: use the layout stateid for layout recalls
Date: Sat, 11 May 2013 05:44:26 +0300
Message-Id: <1368240266-920-1-git-send-email-bhalevy@tonian.com>
In-Reply-To: <518B6377.3000207@tonian.com>
References: <518B6377.3000207@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Implement for RETURN_FILE only at this stage.
A non-null stateid indicates a particular client to recall the layout from.
A null stateid indicates a recall from all clients holding a layout for the
specified file.

Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 fs/nfsd/nfs4pnfsd.c             | 169 ++++++++++++++--------------------------
 fs/nfsd/pnfsd.h                 |   1 +
 fs/nfsd/state.h                 |  13 ++++
 include/linux/nfsd/nfsd4_pnfs.h |  21 +++++
 4 files changed, 95 insertions(+), 109 deletions(-)

diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
index d3a0bde..27f717f 100644
--- a/fs/nfsd/nfs4pnfsd.c
+++ b/fs/nfsd/nfs4pnfsd.c
@@ -434,7 +434,6 @@ struct super_block *
  */
 static struct nfs4_layoutrecall *
 alloc_init_layoutrecall(struct nfsd4_pnfs_cb_layout *cbl,
-			struct nfs4_client *clp,
 			struct nfs4_file *lrfile)
 {
 	struct nfs4_layoutrecall *clr;
@@ -449,7 +448,6 @@ struct super_block *
 	memset(clr, 0, sizeof(*clr));
 	if (lrfile)
 		get_nfs4_file(lrfile);
-	clr->clr_client = clp;
 	clr->clr_file = lrfile;
 	clr->cb = *cbl;
 
@@ -490,6 +488,9 @@ struct super_block *
 	return kref_put(&clr->clr_ref, destroy_layoutrecall);
 }
 
+/*
+ * Note: must be called under the layout lock
+ */
 void *
 layoutrecall_done(struct nfs4_layoutrecall *clr)
 {
@@ -1109,67 +1110,6 @@ int nfs4_pnfs_return_layout(struct svc_rqst *rqstp,
 	return status;
 }
 
-static bool
-cl_has_file_layout(struct nfs4_client *clp, struct nfs4_file *fp,
-		   stateid_t *lsid, struct nfsd4_pnfs_cb_layout *cbl)
-{
-	struct nfs4_layout *lo;
-	bool ret = false;
-
-	spin_lock(&layout_lock);
-	list_for_each_entry(lo, &fp->fi_layouts, lo_perfile) {
-		if (same_clid(&lo->lo_client->cl_clientid, &clp->cl_clientid) &&
-		    lo_seg_overlapping(&cbl->cbl_seg, &lo->lo_seg) &&
-		    (cbl->cbl_seg.iomode & lo->lo_seg.iomode))
-			goto found;
-	}
-	goto unlock;
-found:
-	/* Im going to send a recall on this latout update state */
-	update_layout_stateid_locked(lo->lo_state, lsid);
-	ret = true;
-unlock:
-	spin_unlock(&layout_lock);
-	return ret;
-}
-
-static int
-cl_has_fsid_layout(struct nfs4_client *clp, struct nfs4_fsid *fsid)
-{
-	int found = 0;
-	struct nfs4_layout *lp;
-
-	/* note: minor version unused */
-	spin_lock(&layout_lock);
-	list_for_each_entry(lp, &clp->cl_layouts, lo_perclnt)
-		if (lp->lo_file->fi_fsid.major == fsid->major) {
-			found = 1;
-			break;
-		}
-	spin_unlock(&layout_lock);
-	return found;
-}
-
-static int
-cl_has_any_layout(struct nfs4_client *clp)
-{
-	return !list_empty(&clp->cl_layouts);
-}
-
-static int
-cl_has_layout(struct nfs4_client *clp, struct nfsd4_pnfs_cb_layout *cbl,
-	      struct nfs4_file *lrfile, stateid_t *lsid)
-{
-	switch (cbl->cbl_recall_type) {
-	case RETURN_FILE:
-		return cl_has_file_layout(clp, lrfile, lsid, cbl);
-	case RETURN_FSID:
-		return cl_has_fsid_layout(clp, &cbl->cbl_fsid);
-	default:
-		return cl_has_any_layout(clp);
-	}
-}
-
 /*
  * Called without the layout_lock.
  */
@@ -1292,33 +1232,40 @@ struct create_recall_list_arg {
 };
 
 /*
- * look for matching layout for the given client
- * and add a pending layout recall to the todo list
- * if found any.
- * returns:
- *   0 if layouts found or negative error.
+ * Note: must be called under the layout lock
  */
-static int
-lo_recall_per_client(struct nfs4_client *clp, void *p)
+static struct nfs4_layout_state *
+should_recall_file_layout(struct nfsd4_pnfs_cb_layout *cbl,
+			  struct nfs4_file *fp)
 {
-	stateid_t lsid;
-	struct nfs4_layoutrecall *pending;
-	struct create_recall_list_arg *arg = p;
+	struct nfs4_layout_state *ls, *ret = NULL;
+	stateid_t *stid = (stateid_t *)&cbl->cbl_sid;
+	struct nfs4_layout *lo;
 
-	memset(&lsid, 0, sizeof(lsid));
-	if (!cl_has_layout(clp, arg->cbl, arg->lrfile, &lsid))
-		return 0;
+	dprintk("%s: ino=%lu clientid=%llux iomode=%u", __func__,
+		fp->fi_inode->i_ino, cbl->cbl_seg.clientid,
+		cbl->cbl_seg.iomode);
 
-	/* Matching put done by layoutreturn */
-	pending = alloc_init_layoutrecall(arg->cbl, clp, arg->lrfile);
-	/* out of memory, drain todo queue */
-	if (!pending)
-		return -ENOMEM;
+	list_for_each_entry (ls, &fp->fi_lo_states, ls_perfile) {
+		if (!is_null_stid(stid) &&
+		    !same_stid(stid, &ls->ls_stid.sc_stateid))
+			continue;
 
-	*(stateid_t *)&pending->cb.cbl_sid = lsid;
-	list_add(&pending->clr_perclnt, arg->todolist);
-	arg->todo_count++;
-	return 0;
+		if (cbl->cbl_seg.clientid &&
+		    !same_clid(&ls->ls_client->cl_clientid,
+			       (clientid_t *)&cbl->cbl_seg.clientid))
+			continue;
+
+		list_for_each_entry (lo, &ls->ls_layouts, lo_perstate)
+			if (cbl->cbl_seg.layout_type == lo->lo_seg.layout_type &&
+			    lo_seg_overlapping(&cbl->cbl_seg, &lo->lo_seg) &&
+			    (cbl->cbl_seg.iomode & lo->lo_seg.iomode)) {
+				ret = ls;
+				break;
+			}
+	}
+
+	return ret;
 }
 
 /* Create a layoutrecall structure for each client based on the
@@ -1328,37 +1275,41 @@ struct create_recall_list_arg {
 			  struct nfsd4_pnfs_cb_layout *cbl,
 			  struct nfs4_file *lrfile)
 {
-	struct nfs4_client *clp;
-	struct create_recall_list_arg arg = {
-		.cbl = cbl,
-		.lrfile = lrfile,
-		.todolist = todolist,
-	};
+	struct nfs4_layout_state *ls;
+	struct nfs4_layoutrecall *pending;
 	int status = 0;
 
-#if 0
 	dprintk("%s: -->\n", __func__);
 
-	/* If client given by fs, just do single client */
-	if (cbl->cbl_seg.clientid) {
-		clp = find_confirmed_client((clientid_t *)&cbl->cbl_seg.clientid, true);
-		if (!clp) {
-			status = -ENOENT;
-			dprintk("%s: clientid %llx not found\n", __func__,
-				(unsigned long long)cbl->cbl_seg.clientid);
-			goto out;
-		}
+	/* We do not support wildcard recalls yet */
+	if (cbl->cbl_recall_type != RETURN_FILE)
+		return -EOPNOTSUPP;
 
-		status = lo_recall_per_client(clp, &arg);
-	} else {
-		/* Check all clients for layout matches */
-		status = filter_confirmed_clients(lo_recall_per_client, &arg);
+	/* Matching put done by layoutreturn */
+	pending = alloc_init_layoutrecall(cbl, lrfile);
+	if (!pending)
+		return -ENOMEM;
+
+	switch (cbl->cbl_recall_type) {
+	case RETURN_FILE:
+		spin_lock(&layout_lock);
+		ls = should_recall_file_layout(cbl, lrfile);
+		if (ls) {
+			update_layout_stateid_locked(ls,
+					(stateid_t *)&pending->cb.cbl_sid);
+			pending->clr_client = ls->ls_client;
+			list_add(&pending->clr_perclnt, todolist);
+			(*todo_len)++;
+		}
+		spin_unlock(&layout_lock);
+		break;
+	case RETURN_FSID:
+	default:
+		WARN_ON(1);
+		return -EINVAL;	/* not supported yet */
 	}
 
-out:
-	*todo_len = arg.todo_count;
 	dprintk("%s: <-- list len %u status %d\n", __func__, *todo_len, status);
-#endif
 	return status;
 }
 
@@ -1380,7 +1331,7 @@ struct create_recall_list_arg {
 		pending = list_entry(todolist->next, struct nfs4_layoutrecall,
 				     clr_perclnt);
 
-		parent = alloc_init_layoutrecall(&pending->cb, NULL,
+		parent = alloc_init_layoutrecall(&pending->cb,
 						 pending->clr_file);
 		if (unlikely(!parent)) {
 			/* We want forward progress. If parent cannot be
diff --git a/fs/nfsd/pnfsd.h b/fs/nfsd/pnfsd.h
index 453f951..159fe94 100644
--- a/fs/nfsd/pnfsd.h
+++ b/fs/nfsd/pnfsd.h
@@ -49,6 +49,7 @@ struct nfs4_layout_state {
 	struct list_head	ls_perfile;
 	struct nfs4_file	*ls_file;
 	struct list_head	ls_layouts;
+	struct list_head	ls_lo_recalls;
 	bool			ls_roc;
 };
 
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index ab4a136..9057c86 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -62,6 +62,19 @@
 	stateid_opaque_t        si_opaque;
 } stateid_t;
 
+static inline bool
+is_null_stid(stateid_t *stid)
+{
+	return stid->si_opaque.so_id == 0;
+}
+
+static inline int
+same_stid(stateid_t *stid1, stateid_t *stid2)
+{
+	return !memcmp(&stid1->si_opaque, &stid2->si_opaque,
+		       NFS4_STATEID_OTHER_SIZE);
+}
+
 #define STATEID_FMT	"(%08x/%08x/%08x/%08x)"
 #define STATEID_VAL(s) \
 	(s)->si_opaque.so_clid.cl_boot, \
diff --git a/include/linux/nfsd/nfsd4_pnfs.h b/include/linux/nfsd/nfsd4_pnfs.h
index a49d5f6..a10bcf2 100644
--- a/include/linux/nfsd/nfsd4_pnfs.h
+++ b/include/linux/nfsd/nfsd4_pnfs.h
@@ -200,6 +200,27 @@ struct pnfs_export_operations {
 	int (*can_merge_layouts) (u32 layout_type);
 };
 
+/*
+ * @cbl_recall_type	Indicates RETURN_FILE, RETURN_FSID, or RETURN_ALL
+ *
+ * @cbl_seg		Indicates a the layout_type and iomode to recall,
+ * 			IOMODE_READ, IOMODE_RW, or IOMODE_ANY.
+ * 			For RETURN_FILE, offset and length can be given to recall
+ * 			a particular range.  To recall the layout for the whole
+ * 			file, offset is set to 0 and length to NFS4_MAX_UINT64.
+ *
+ * cbl_layoutchanged	Set to true to provide a hint to the client not to
+ * 			attempt flushing dirty data to the data servers
+ * 			using the recalled layout.
+ *
+ * cbl_sid		For RETURN_FILE, non-zero stateid indicates a particular
+ * 			stateid (file/clientid tuple) to recall.
+ *
+ * cbl_fsid		For RETURN_FSID, indicated the fsid to recall.
+ *
+ * cbl_cookie		A private file system value to be given on the final
+ *			layoutreturn completing the layout recall.
+ */
 struct nfsd4_pnfs_cb_layout {
 	u32			cbl_recall_type;	/* request */
 	struct nfsd4_layout_seg cbl_seg;		/* request */
-- 
1.7.11.7

