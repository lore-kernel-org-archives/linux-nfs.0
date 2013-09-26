Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f50.google.com ([209.85.216.50]:60940 "EHLO
	mail-qa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752447Ab3IZSnH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Sep 2013 14:43:07 -0400
Received: by mail-qa0-f50.google.com with SMTP id j7so1103539qaq.9
        for <linux-nfs@vger.kernel.org>; Thu, 26 Sep 2013 11:43:05 -0700 (PDT)
From: Benny Halevy <bhalevy@primarydata.com>
To: " J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH RFC v0 46/49] pnfsd: layout return generic implementation
Date: Thu, 26 Sep 2013 14:43:03 -0400
Message-Id: <1380220983-14807-1-git-send-email-bhalevy@primarydata.com>
In-Reply-To: <52447EA0.7070004@primarydata.com>
References: <52447EA0.7070004@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Handle layout return by the generic layer for RETURN_{FILE,FSID,ALL}.
Keep track of the layout state sequence and remaining outstanding layout.
lrs_present set to false when the client returns all of its layout for the file.

Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
---
 fs/nfsd/nfs4pnfsd.c             | 284 ++++++++++++++++++++++++++++++++++++++++
 fs/nfsd/nfs4proc.c              |  58 ++++++++
 fs/nfsd/nfs4state.c             |  10 +-
 fs/nfsd/nfs4xdr.c               |  49 ++++++-
 fs/nfsd/pnfsd.h                 |   1 +
 fs/nfsd/state.h                 |   3 +
 fs/nfsd/xdr4.h                  |   7 +
 include/linux/nfsd/nfsd4_pnfs.h |  10 ++
 8 files changed, 416 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
index 1807455..2ba4a29 100644
--- a/fs/nfsd/nfs4pnfsd.c
+++ b/fs/nfsd/nfs4pnfsd.c
@@ -289,6 +289,54 @@ static void update_layout_stateid_locked(struct nfs4_layout_state *ls, stateid_t
 	dprintk("pNFS %s end\n", __func__);
 }
 
+/*
+ * Note: must be called under the layout_lock.
+ */
+static void
+dequeue_layout_for_return(struct nfs4_layout *lo,
+                          struct list_head *lo_destroy_list)
+{
+	ASSERT_LAYOUT_LOCKED();
+	list_del_init(&lo->lo_perstate);
+	list_add_tail(&lo->lo_perstate, lo_destroy_list);
+	if (list_empty(&lo->lo_state->ls_layouts)) {
+		unhash_layout_state(lo->lo_state);
+		nfsd4_unhash_stid(&lo->lo_state->ls_stid);
+	}
+}
+
+/*
+ * Note: must be called under the state lock
+ */
+static void
+destroy_layout(struct nfs4_layout *lp)
+{
+	struct nfs4_layout_state *ls;
+
+	ls = lp->lo_state;
+	dprintk("pNFS %s: lp %p ls %p ino %lu\n",
+		__func__, lp, ls, ls->ls_file->fi_inode->i_ino);
+
+	free_layout(lp);
+	/* release references taken by init_layout */
+	put_layout_state(ls);
+}
+
+/*
+ * Note: must be called under the state lock
+ */
+static void
+destroy_layout_list(struct list_head *lo_destroy_list)
+{
+	struct nfs4_layout *lp;
+
+	while (!list_empty(lo_destroy_list)) {
+		lp = list_first_entry(lo_destroy_list, struct nfs4_layout, lo_perstate);
+		list_del(&lp->lo_perstate);
+		destroy_layout(lp);
+	}
+}
+
 static u64
 alloc_init_sbid(struct super_block *sb)
 {
@@ -367,6 +415,35 @@ struct super_block *
 }
 
 /*
+ * are two octet ranges overlapping?
+ * start1            last1
+ *   |-----------------|
+ *                start2            last2
+ *                  |----------------|
+ */
+static int
+lo_seg_overlapping(struct nfsd4_layout_seg *l1, struct nfsd4_layout_seg *l2)
+{
+	u64 start1 = l1->offset;
+	u64 last1 = last_byte_offset(start1, l1->length);
+	u64 start2 = l2->offset;
+	u64 last2 = last_byte_offset(start2, l2->length);
+	int ret;
+
+	/* if last1 == start2 there's a single byte overlap */
+	ret = (last2 >= start1) && (last1 >= start2);
+	dprintk("%s: l1 %llu:%lld l2 %llu:%lld ret=%d\n", __func__,
+		l1->offset, l1->length, l2->offset, l2->length, ret);
+	return ret;
+}
+
+static int
+same_fsid_major(struct nfs4_fsid *fsid, u64 major)
+{
+	return fsid->major == major;
+}
+
+/*
  * are two octet ranges overlapping or adjacent?
  */
 static bool
@@ -578,3 +655,210 @@ struct super_block *
 	free_layout(lp);
 	goto out_unlock;
 }
+
+static void
+trim_layout(struct nfsd4_layout_seg *lo, struct nfsd4_layout_seg *lr)
+{
+	u64 lo_start = lo->offset;
+	u64 lo_end = end_offset(lo_start, lo->length);
+	u64 lr_start = lr->offset;
+	u64 lr_end = end_offset(lr_start, lr->length);
+
+	dprintk("%s:Begin lo %llu:%lld lr %llu:%lld\n", __func__,
+		lo->offset, lo->length, lr->offset, lr->length);
+
+	/* lr fully covers lo? */
+	if (lr_start <= lo_start && lo_end <= lr_end) {
+		lo->length = 0;
+		goto out;
+	}
+
+	/*
+	 * split not supported yet. retain layout segment.
+	 * remains must be returned by the client
+	 * on the final layout return.
+	 */
+	if (lo_start < lr_start && lr_end < lo_end) {
+		dprintk("%s: split not supported\n", __func__);
+		goto out;
+	}
+
+	if (lo_start < lr_start)
+		lo_end = lr_start - 1;
+	else /* lr_end < lo_end */
+		lo_start = lr_end + 1;
+
+	lo->offset = lo_start;
+	lo->length = (lo_end == NFS4_MAX_UINT64) ? lo_end : lo_end - lo_start;
+out:
+	dprintk("%s:End lo %llu:%lld\n", __func__, lo->offset, lo->length);
+}
+
+/*
+ * Note: should be called WITHOUT holding the layout_lock
+ */
+static int
+pnfs_return_file_layouts(struct nfsd4_pnfs_layoutreturn *lrp,
+			 struct nfs4_layout_state *ls,
+			 struct list_head *lo_destroy_list)
+{
+	int layouts_found = 0;
+	struct nfs4_layout *lp, *nextlp;
+
+	dprintk("%s: ls %p\n", __func__, ls);
+	lrp->lrs_present = 0;
+	spin_lock(&layout_lock);
+	list_for_each_entry_safe (lp, nextlp, &ls->ls_layouts, lo_perstate) {
+		dprintk("%s: lp %p ls %p inode %lu lo_type %x,%x iomode %d,%d\n",
+			__func__, lp, lp->lo_state,
+			lp->lo_state->ls_file->fi_inode->i_ino,
+			lp->lo_seg.layout_type, lrp->args.lr_seg.layout_type,
+			lp->lo_seg.iomode, lrp->args.lr_seg.iomode);
+		if ((lp->lo_seg.layout_type != lrp->args.lr_seg.layout_type &&
+		     lrp->args.lr_seg.layout_type) ||
+		    (lp->lo_seg.iomode != lrp->args.lr_seg.iomode &&
+		     lrp->args.lr_seg.iomode != IOMODE_ANY) ||
+		     !lo_seg_overlapping(&lp->lo_seg, &lrp->args.lr_seg)) {
+			lrp->lrs_present = 1;
+			continue;
+		}
+		layouts_found++;
+		trim_layout(&lp->lo_seg, &lrp->args.lr_seg);
+		if (!lp->lo_seg.length)
+			dequeue_layout_for_return(lp, lo_destroy_list);
+		else
+			lrp->lrs_present = 1;
+	}
+	if (ls && layouts_found && lrp->lrs_present)
+		update_layout_stateid_locked(ls, (stateid_t *)&lrp->args.lr_sid);
+	spin_unlock(&layout_lock);
+
+	return layouts_found;
+}
+
+/*
+ * Return layouts for RETURN_FSID or RETURN_ALL
+ *
+ * Note: must be called WITHOUT holding the layout lock
+ */
+static int
+pnfs_return_client_layouts(struct nfs4_client *clp,
+			   struct nfsd4_pnfs_layoutreturn *lrp,
+			   u64 ex_fsid,
+			   struct list_head *lo_destroy_list)
+{
+	int layouts_found = 0;
+	bool state_found;
+	struct nfs4_layout_state *ls, *nextls;
+	struct nfs4_layout *lp, *nextlp;
+
+	spin_lock(&layout_lock);
+	list_for_each_entry_safe (ls, nextls, &clp->cl_lo_states, ls_perclnt) {
+		if (lrp->args.lr_return_type == RETURN_FSID &&
+		    !same_fsid_major(&ls->ls_file->fi_fsid, ex_fsid))
+			continue;
+
+		/* first pass, test only */
+		state_found = false;
+		list_for_each_entry (lp, &ls->ls_layouts, lo_perstate) {
+			if (lrp->args.lr_seg.layout_type != lp->lo_seg.layout_type &&
+			    lrp->args.lr_seg.layout_type)
+				break;
+
+			if (lrp->args.lr_seg.iomode != lp->lo_seg.iomode &&
+			    lrp->args.lr_seg.iomode != IOMODE_ANY)
+				continue;
+
+			state_found = true;
+			break;
+		}
+
+		if (!state_found)
+			continue;
+
+		list_for_each_entry_safe (lp, nextlp, &ls->ls_layouts, lo_perstate) {
+			if (lrp->args.lr_seg.layout_type != lp->lo_seg.layout_type &&
+			    lrp->args.lr_seg.layout_type)
+				break;
+
+			if (lrp->args.lr_seg.iomode != lp->lo_seg.iomode &&
+			    lrp->args.lr_seg.iomode != IOMODE_ANY)
+				continue;
+
+			layouts_found++;
+			dequeue_layout_for_return(lp, lo_destroy_list);
+		}
+	}
+	spin_unlock(&layout_lock);
+	return layouts_found;
+}
+
+int nfs4_pnfs_return_layout(struct svc_rqst *rqstp,
+			    struct super_block *sb,
+			    struct svc_fh *current_fh,
+			    struct nfsd4_pnfs_layoutreturn *lrp)
+{
+	int status = 0;
+	int layouts_found = 0;
+	struct inode *ino = current_fh->fh_dentry->d_inode;
+	struct nfs4_file *fp = NULL;
+	struct nfs4_layout_state *ls = NULL;
+	struct nfs4_client *clp;
+	u64 ex_fsid = current_fh->fh_export->ex_fsid;
+	LIST_HEAD(lo_destroy_list);
+
+	dprintk("NFSD: %s\n", __func__);
+
+	nfs4_lock_state();
+	clp = find_confirmed_client(&lrp->lr_clientid,
+				    true, net_generic(SVC_NET(rqstp), nfsd_net_id));
+	if (!clp)
+		goto out_unlock;
+
+	if (lrp->args.lr_return_type == RETURN_FILE) {
+		LIST_HEAD(lo_destroy_list);
+
+		fp = find_file(ino);
+		if (!fp) {
+			dprintk("%s: RETURN_FILE: no nfs4_file for ino %p:%lu\n",
+				__func__, ino, ino ? ino->i_ino : 0L);
+			/* If we had a layout on the file the nfs4_file would
+			 * be referenced and we should have found it. Since we
+			 * don't then it means all layouts were ROC and at this
+			 * point we returned all of them on file close.
+			 */
+			goto out_unlock;
+		}
+
+		/* Check the stateid */
+		dprintk("%s PROCESS LO_STATEID inode %p\n", __func__, ino);
+		status = nfs4_process_layout_stateid(clp, fp,
+						     (stateid_t *)&lrp->args.lr_sid,
+						     NFS4_LAYOUT_STID, &ls);
+		if (status)
+			goto out_unlock;
+		layouts_found = pnfs_return_file_layouts(lrp, ls, &lo_destroy_list);
+	} else {
+		layouts_found = pnfs_return_client_layouts(clp, lrp, ex_fsid,
+							   &lo_destroy_list);
+	}
+
+	dprintk("pNFS %s: clp %p fp %p layout_type 0x%x iomode %d "
+		"return_type %d fsid 0x%llx offset %llu length %llu: "
+		"layouts_found %d\n",
+		__func__, clp, fp, lrp->args.lr_seg.layout_type,
+		lrp->args.lr_seg.iomode, lrp->args.lr_return_type,
+		ex_fsid,
+		lrp->args.lr_seg.offset, lrp->args.lr_seg.length, layouts_found);
+
+	if (ls)
+		put_layout_state(ls);
+	destroy_layout_list(&lo_destroy_list);
+out_unlock:
+	nfs4_unlock_state();
+	if (fp)
+		put_nfs4_file(fp);
+
+	dprintk("pNFS %s: exit status %d\n", __func__, status);
+	return status;
+}
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 960d8ff..54926cb 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1274,6 +1274,60 @@ static int fill_in_write_vector(struct kvec *vec, struct nfsd4_write *write)
 out:
 	return status;
 }
+
+static __be32
+nfsd4_layoutreturn(struct svc_rqst *rqstp,
+		struct nfsd4_compound_state *cstate,
+		struct nfsd4_pnfs_layoutreturn *lrp)
+{
+	int status;
+	struct super_block *sb;
+	struct svc_fh *current_fh = &cstate->current_fh;
+
+	status = fh_verify(rqstp, current_fh, 0, NFSD_MAY_NOP);
+	if (status)
+		goto out;
+
+	status = nfserr_inval;
+	sb = current_fh->fh_dentry->d_inode->i_sb;
+	if (!sb)
+		goto out;
+
+	/* Ensure underlying file system supports pNFS and,
+	 * if so, the requested layout type
+	 */
+	status = nfsd4_layout_verify(sb, current_fh->fh_export,
+				     lrp->args.lr_seg.layout_type);
+	if (status)
+		goto out;
+
+	status = nfserr_inval;
+	if (lrp->args.lr_return_type != RETURN_FILE &&
+	    lrp->args.lr_return_type != RETURN_FSID &&
+	    lrp->args.lr_return_type != RETURN_ALL) {
+		dprintk("pNFS %s: invalid return_type %d\n", __func__,
+			lrp->args.lr_return_type);
+		goto out;
+	}
+
+	status = nfserr_inval;
+	if (lrp->args.lr_seg.iomode != IOMODE_READ &&
+	    lrp->args.lr_seg.iomode != IOMODE_RW &&
+	    lrp->args.lr_seg.iomode != IOMODE_ANY) {
+		dprintk("pNFS %s: invalid iomode %d\n", __func__,
+			lrp->args.lr_seg.iomode);
+		goto out;
+	}
+
+	/* Set clientid from sessionid */
+	copy_clientid(&lrp->lr_clientid, cstate->session);
+	lrp->lrs_present = 0;
+	status = nfs4_pnfs_return_layout(rqstp, sb, current_fh, lrp);
+out:
+	dprintk("pNFS %s: status %d return_type 0x%x lrs_present %d\n",
+		__func__, status, lrp->args.lr_return_type, lrp->lrs_present);
+	return status;
+}
 #endif /* CONFIG_PNFSD */
 
 /*
@@ -2021,6 +2075,10 @@ static inline u32 nfsd4_create_session_rsize(struct svc_rqst *rqstp, struct nfsd
 		.op_func = (nfsd4op_func)nfsd4_layoutget,
 		.op_name = "OP_LAYOUTGET",
 	},
+	[OP_LAYOUTRETURN] = {
+		.op_func = (nfsd4op_func)nfsd4_layoutreturn,
+		.op_name = "OP_LAYOUTRETURN",
+	},
 #endif /* CONFIG_PNFSD */
 };
 
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 5d5dead..a9bd82b 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -463,7 +463,7 @@ static void nfs4_put_deleg_lease(struct nfs4_file *fp)
 	}
 }
 
-static void unhash_stid(struct nfs4_stid *s)
+void nfsd4_unhash_stid(struct nfs4_stid *s)
 {
 	s->sc_type = 0;
 }
@@ -660,7 +660,7 @@ static void release_lock_stateid(struct nfs4_ol_stateid *stp)
 	struct file *file;
 
 	unhash_generic_stateid(stp);
-	unhash_stid(&stp->st_stid);
+	nfsd4_unhash_stid(&stp->st_stid);
 	file = find_any_file(stp->st_file);
 	if (file)
 		locks_remove_posix(file, (fl_owner_t)lockowner(stp->st_stateowner));
@@ -2539,6 +2539,8 @@ static void nfsd4_init_file(struct nfs4_file *fp, struct inode *ino,
 	memset(fp->fi_access, 0, sizeof(fp->fi_access));
 #if defined(CONFIG_PNFSD)
 	INIT_LIST_HEAD(&fp->fi_lo_states);
+	fp->fi_fsid.major = current_fh->fh_export->ex_fsid;
+	fp->fi_fsid.minor = 0;
 #endif /* CONFIG_PNFSD */
 	spin_lock(&recall_lock);
 	hlist_add_head(&fp->fi_hash, &file_hashtbl[hashval]);
@@ -2725,7 +2727,7 @@ static void init_open_stateid(struct nfs4_ol_stateid *stp, struct nfs4_file *fp,
 }
 
 /* search file_hashtbl[] for file */
-static struct nfs4_file *
+struct nfs4_file *
 find_file(struct inode *ino)
 {
 	unsigned int hashval = file_hashval(ino);
@@ -3233,7 +3235,7 @@ static void nfsd4_open_deleg_none_ext(struct nfsd4_open *open, int status)
 	open->op_delegate_type = NFS4_OPEN_DELEGATE_READ;
 	return;
 out_free:
-	unhash_stid(&dp->dl_stid);
+	nfsd4_unhash_stid(&dp->dl_stid);
 	nfs4_put_delegation(dp);
 out_no_deleg:
 	open->op_delegate_type = NFS4_OPEN_DELEGATE_NONE;
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 1a50467..fc10dd7 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1541,6 +1541,33 @@ static __be32 nfsd4_decode_reclaim_complete(struct nfsd4_compoundargs *argp, str
 
 	DECODE_TAIL;
 }
+
+static __be32
+nfsd4_decode_layoutreturn(struct nfsd4_compoundargs *argp,
+			  struct nfsd4_pnfs_layoutreturn *lrp)
+{
+	DECODE_HEAD;
+
+	READ_BUF(16);
+	READ32(lrp->args.lr_reclaim);
+	READ32(lrp->args.lr_seg.layout_type);
+	READ32(lrp->args.lr_seg.iomode);
+	READ32(lrp->args.lr_return_type);
+	if (lrp->args.lr_return_type == RETURN_FILE) {
+		READ_BUF(16);
+		READ64(lrp->args.lr_seg.offset);
+		READ64(lrp->args.lr_seg.length);
+		nfsd4_decode_stateid(argp, (stateid_t *)&lrp->args.lr_sid);
+		READ_BUF(4);
+		READ32(lrp->args.lrf_body_len);
+		if (lrp->args.lrf_body_len > 0) {
+			READ_BUF(lrp->args.lrf_body_len);
+			READMEM(lrp->args.lrf_body, lrp->args.lrf_body_len);
+		}
+	}
+
+	DECODE_TAIL;
+}
 #endif /* CONFIG_PNFSD */
 
 static __be32
@@ -1649,7 +1676,7 @@ static __be32 nfsd4_decode_reclaim_complete(struct nfsd4_compoundargs *argp, str
 	[OP_GETDEVICELIST]	= (nfsd4_dec)nfsd4_decode_getdevlist,
 	[OP_LAYOUTCOMMIT]	= (nfsd4_dec)nfsd4_decode_notsupp,
 	[OP_LAYOUTGET]		= (nfsd4_dec)nfsd4_decode_layoutget,
-	[OP_LAYOUTRETURN]	= (nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_LAYOUTRETURN]	= (nfsd4_dec)nfsd4_decode_layoutreturn,
 #else  /* CONFIG_PNFSD */
 	[OP_GETDEVICEINFO]	= (nfsd4_dec)nfsd4_decode_notsupp,
 	[OP_GETDEVICELIST]	= (nfsd4_dec)nfsd4_decode_notsupp,
@@ -3903,6 +3930,24 @@ static __be32 nfsd4_encode_bind_conn_to_session(struct nfsd4_compoundres *resp,
 	resp->p = p_start;
 	return nfserr;
 }
+
+static __be32
+nfsd4_encode_layoutreturn(struct nfsd4_compoundres *resp, __be32 nfserr,
+			  struct nfsd4_pnfs_layoutreturn *lrp)
+{
+	__be32 *p;
+
+	if (nfserr)
+		goto out;
+
+	RESERVE_SPACE(4);
+	WRITE32(lrp->lrs_present != 0);    /* got stateid? */
+	ADJUST_ARGS();
+	if (lrp->lrs_present)
+		nfsd4_encode_stateid(resp, (stateid_t *)&lrp->args.lr_sid);
+out:
+	return nfserr;
+}
 #endif /* CONFIG_PNFSD */
 
 static __be32
@@ -3970,7 +4015,7 @@ static __be32 nfsd4_encode_bind_conn_to_session(struct nfsd4_compoundres *resp,
 	[OP_GETDEVICELIST]	= (nfsd4_enc)nfsd4_encode_getdevlist,
 	[OP_LAYOUTCOMMIT]	= (nfsd4_enc)nfsd4_encode_noop,
 	[OP_LAYOUTGET]		= (nfsd4_enc)nfsd4_encode_layoutget,
-	[OP_LAYOUTRETURN]	= (nfsd4_enc)nfsd4_encode_noop,
+	[OP_LAYOUTRETURN]	= (nfsd4_enc)nfsd4_encode_layoutreturn,
 #else  /* CONFIG_PNFSD */
 	[OP_GETDEVICEINFO]	= (nfsd4_enc)nfsd4_encode_noop,
 	[OP_GETDEVICELIST]	= (nfsd4_enc)nfsd4_encode_noop,
diff --git a/fs/nfsd/pnfsd.h b/fs/nfsd/pnfsd.h
index 1cd7a87..7ced4f3 100644
--- a/fs/nfsd/pnfsd.h
+++ b/fs/nfsd/pnfsd.h
@@ -61,6 +61,7 @@ struct nfs4_layout {
 u64 find_create_sbid(struct super_block *);
 struct super_block *find_sbid_id(u64);
 __be32 nfs4_pnfs_get_layout(struct svc_rqst *, struct nfsd4_pnfs_layoutget *, struct exp_xdr_stream *);
+int nfs4_pnfs_return_layout(struct svc_rqst *, struct super_block *, struct svc_fh *, struct nfsd4_pnfs_layoutreturn *);
 
 static inline struct nfs4_layout_state *layoutstateid(struct nfs4_stid *s)
 {
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 3be7507..d2c75c5 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -407,6 +407,7 @@ struct nfs4_file {
 	bool			fi_had_conflict;
 #if defined(CONFIG_PNFSD)
 	struct list_head	fi_lo_states;
+	struct nfs4_fsid	fi_fsid;
 #endif /* CONFIG_PNFSD */
 };
 
@@ -489,6 +490,7 @@ extern struct nfs4_client_reclaim *nfs4_client_to_reclaim(const char *name,
 extern bool nfs4_has_reclaimed_state(const char *name, struct nfsd_net *nn);
 extern void put_client_renew(struct nfs4_client *clp);
 extern void nfsd4_free_slab(struct kmem_cache **);
+extern struct nfs4_file *find_file(struct inode *);
 extern struct nfs4_file *find_alloc_file(struct inode *, struct svc_fh *);
 extern void put_nfs4_file(struct nfs4_file *);
 extern void put_nfs4_file_locked(struct nfs4_file *);
@@ -497,6 +499,7 @@ extern struct nfs4_client_reclaim *nfs4_client_to_reclaim(const char *name,
 extern struct nfs4_stid *nfsd4_alloc_stid(struct nfs4_client *cl, struct kmem_cache *slab);
 extern void nfsd4_free_stid(struct kmem_cache *slab, struct nfs4_stid *s);
 extern void nfsd4_remove_stid(struct nfs4_stid *s);
+extern void nfsd4_unhash_stid(struct nfs4_stid *s);
 extern struct nfs4_stid *nfsd4_find_stateid(struct nfs4_client *, stateid_t *);
 extern __be32 nfsd4_lookup_stateid(stateid_t *, unsigned char typemask, struct nfs4_stid **, bool sessions, struct nfsd_net *);
 
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index 727288b..cfa0bcf 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -458,6 +458,12 @@ struct nfsd4_pnfs_layoutget {
 	u32			lg_roc;		/* response */
 };
 
+struct nfsd4_pnfs_layoutreturn {
+	struct nfsd4_pnfs_layoutreturn_arg args;
+	clientid_t		lr_clientid;	/* request */
+	u32			lrs_present;	/* response */
+};
+
 struct nfsd4_op {
 	int					opnum;
 	__be32					status;
@@ -507,6 +513,7 @@ struct nfsd4_op {
 		struct nfsd4_pnfs_getdevlist	pnfs_getdevlist;
 		struct nfsd4_pnfs_getdevinfo	pnfs_getdevinfo;
 		struct nfsd4_pnfs_layoutget	pnfs_layoutget;
+		struct nfsd4_pnfs_layoutreturn	pnfs_layoutreturn;
 #endif /* CONFIG_PNFSD */
 	} u;
 	struct nfs4_replay *			replay;
diff --git a/include/linux/nfsd/nfsd4_pnfs.h b/include/linux/nfsd/nfsd4_pnfs.h
index a680085..e198979 100644
--- a/include/linux/nfsd/nfsd4_pnfs.h
+++ b/include/linux/nfsd/nfsd4_pnfs.h
@@ -36,6 +36,7 @@
 
 #include <linux/exportfs.h>
 #include <linux/exp_xdr.h>
+#include <linux/nfs_xdr.h>
 
 struct nfsd4_pnfs_deviceid {
 	u64	sbid;			/* per-superblock unique ID */
@@ -86,6 +87,15 @@ struct nfsd4_pnfs_layoutget_res {
 	u32			lg_return_on_close;
 };
 
+struct nfsd4_pnfs_layoutreturn_arg {
+	u32			lr_return_type;	/* request */
+	struct nfsd4_layout_seg	lr_seg;		/* request */
+	u32			lr_reclaim;	/* request */
+	u32			lrf_body_len;	/* request */
+	void			*lrf_body;	/* request */
+	nfs4_stateid		lr_sid;		/* request/response */
+};
+
 /*
  * pNFS export operations vector.
  *
-- 
1.8.3.1

