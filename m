Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:48989 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753888Ab0HMVcY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Aug 2010 17:32:24 -0400
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 23/50] pnfs_submit: layout helper functions
Date: Fri, 13 Aug 2010 17:31:35 -0400
Message-Id: <1281735122-1496-24-git-send-email-andros@netapp.com>
In-Reply-To: <1281735122-1496-23-git-send-email-andros@netapp.com>
References: <1281735122-1496-1-git-send-email-andros@netapp.com>
 <1281735122-1496-2-git-send-email-andros@netapp.com>
 <1281735122-1496-3-git-send-email-andros@netapp.com>
 <1281735122-1496-4-git-send-email-andros@netapp.com>
 <1281735122-1496-5-git-send-email-andros@netapp.com>
 <1281735122-1496-6-git-send-email-andros@netapp.com>
 <1281735122-1496-7-git-send-email-andros@netapp.com>
 <1281735122-1496-8-git-send-email-andros@netapp.com>
 <1281735122-1496-9-git-send-email-andros@netapp.com>
 <1281735122-1496-10-git-send-email-andros@netapp.com>
 <1281735122-1496-11-git-send-email-andros@netapp.com>
 <1281735122-1496-12-git-send-email-andros@netapp.com>
 <1281735122-1496-13-git-send-email-andros@netapp.com>
 <1281735122-1496-14-git-send-email-andros@netapp.com>
 <1281735122-1496-15-git-send-email-andros@netapp.com>
 <1281735122-1496-16-git-send-email-andros@netapp.com>
 <1281735122-1496-17-git-send-email-andros@netapp.com>
 <1281735122-1496-18-git-send-email-andros@netapp.com>
 <1281735122-1496-19-git-send-email-andros@netapp.com>
 <1281735122-1496-20-git-send-email-andros@netapp.com>
 <1281735122-1496-21-git-send-email-andros@netapp.com>
 <1281735122-1496-22-git-send-email-andros@netapp.com>
 <1281735122-1496-23-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: The pNFS Team <linux-nfs@vger.kernel.org>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/inode.c         |    1 +
 fs/nfs/pnfs.c          |  377 ++++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/pnfs.h          |   34 +++++
 include/linux/nfs_fs.h |    1 +
 4 files changed, 413 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index ce91e8f..5e355de 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1445,6 +1445,7 @@ static inline void nfs4_init_once(struct nfs_inode *nfsi)
 	init_rwsem(&nfsi->rwsem);
 #ifdef CONFIG_NFS_V4_1
 	init_waitqueue_head(&nfsi->lo_waitq);
+	nfsi->pnfs_layout_suspend = 0;
 	nfsi->layout = NULL;
 #endif /* CONFIG_NFS_V4_1 */
 #endif
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 36a3056..0f98261 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -259,6 +259,18 @@ void
 pnfs_layout_release(struct pnfs_layout_type *lo,
 		    struct nfs4_pnfs_layout_segment *range)
 {
+	struct nfs_inode *nfsi = PNFS_NFS_INODE(lo);
+
+	spin_lock(&nfsi->vfs_inode.i_lock);
+	if (range)
+		pnfs_free_layout(lo, range);
+	/*
+	 * Matched in _pnfs_update_layout for layoutget
+	 * and by get_layout in _pnfs_return_layout for layoutreturn
+	 */
+	put_layout_locked(lo);
+	spin_unlock(&nfsi->vfs_inode.i_lock);
+	wake_up_all(&nfsi->lo_waitq);
 }
 
 void
@@ -412,6 +424,61 @@ pnfs_layout_from_open_stateid(struct pnfs_layout_type *lo,
 }
 
 /*
+* Get layout from server.
+*    for now, assume that whole file layouts are requested.
+*    arg->offset: 0
+*    arg->length: all ones
+*/
+static int
+send_layoutget(struct inode *ino,
+	   struct nfs_open_context *ctx,
+	   struct nfs4_pnfs_layout_segment *range,
+	   struct pnfs_layout_segment **lsegpp,
+	   struct pnfs_layout_type *lo)
+{
+	int status;
+	struct nfs_server *server = NFS_SERVER(ino);
+	struct nfs4_pnfs_layoutget *lgp;
+
+	dprintk("--> %s\n", __func__);
+
+	lgp = kzalloc(sizeof(*lgp), GFP_KERNEL);
+	if (lgp == NULL) {
+		pnfs_layout_release(lo, NULL);
+		return -ENOMEM;
+	}
+	lgp->args.minlength = NFS4_MAX_UINT64;
+	lgp->args.maxcount = PNFS_LAYOUT_MAXSIZE;
+	lgp->args.lseg.iomode = range->iomode;
+	lgp->args.lseg.offset = 0;
+	lgp->args.lseg.length = NFS4_MAX_UINT64;
+	lgp->args.type = server->pnfs_curr_ld->id;
+	lgp->args.inode = ino;
+	lgp->lsegpp = lsegpp;
+
+	if (!memcmp(lo->stateid.u.data, &zero_stateid, NFS4_STATEID_SIZE)) {
+		struct nfs_open_context *oldctx = ctx;
+
+		if (!oldctx) {
+			ctx = nfs_find_open_context(ino, NULL,
+					(range->iomode == IOMODE_READ) ?
+					FMODE_READ: FMODE_WRITE);
+			BUG_ON(!ctx);
+		}
+		/* Set the layout stateid from the open stateid */
+		pnfs_layout_from_open_stateid(NFS_I(ino)->layout, ctx->state);
+		if (!oldctx)
+			put_nfs_open_context(ctx);
+	}
+
+	/* Retrieve layout information from server */
+	status = pnfs4_proc_layoutget(lgp);
+
+	dprintk("<-- %s status %d\n", __func__, status);
+	return status;
+}
+
+/*
  * iomode matching rules:
  * range	lseg	match
  * -----	-----	-----
@@ -471,6 +538,62 @@ pnfs_free_layout(struct pnfs_layout_type *lo,
 }
 
 /*
+ * cmp two layout segments for sorting into layout cache
+ */
+static inline s64
+cmp_layout(struct nfs4_pnfs_layout_segment *l1,
+	   struct nfs4_pnfs_layout_segment *l2)
+{
+	/* read > read/write */
+	return (int)(l1->iomode == IOMODE_READ) -
+	       (int)(l2->iomode == IOMODE_READ);
+}
+
+static void
+pnfs_insert_layout(struct pnfs_layout_type *lo,
+		   struct pnfs_layout_segment *lseg)
+{
+	struct pnfs_layout_segment *lp;
+	int found = 0;
+
+	dprintk("%s:Begin\n", __func__);
+
+	BUG_ON_UNLOCKED_LO(lo);
+	if (list_empty(&lo->segs)) {
+		struct nfs_client *clp = PNFS_NFS_SERVER(lo)->nfs_client;
+
+		spin_lock(&clp->cl_lock);
+		BUG_ON(!list_empty(&lo->lo_layouts));
+		list_add_tail(&lo->lo_layouts, &clp->cl_layouts);
+		spin_unlock(&clp->cl_lock);
+	}
+	list_for_each_entry (lp, &lo->segs, fi_list) {
+		if (cmp_layout(&lp->range, &lseg->range) > 0)
+			continue;
+		list_add_tail(&lseg->fi_list, &lp->fi_list);
+		dprintk("%s: inserted lseg %p "
+			"iomode %d offset %llu length %llu before "
+			"lp %p iomode %d offset %llu length %llu\n",
+			__func__, lseg, lseg->range.iomode,
+			lseg->range.offset, lseg->range.length,
+			lp, lp->range.iomode, lp->range.offset,
+			lp->range.length);
+		found = 1;
+		break;
+	}
+	if (!found) {
+		list_add_tail(&lseg->fi_list, &lo->segs);
+		dprintk("%s: inserted lseg %p "
+			"iomode %d offset %llu length %llu at tail\n",
+			__func__, lseg, lseg->range.iomode,
+			lseg->range.offset, lseg->range.length);
+	}
+	get_layout(lo);
+
+	dprintk("%s:Return\n", __func__);
+}
+
+/*
  * Each layoutdriver embeds pnfs_layout_type as the first field in it's
  * per-layout type layout cache structure and returns it ZEROed
  * from layoutdriver_io_ops->alloc_layout
@@ -531,16 +654,270 @@ pnfs_alloc_layout(struct inode *ino)
 	return nfsi->layout;
 }
 
+/*
+ * iomode matching rules:
+ * range	lseg	match
+ * -----	-----	-----
+ * ANY		READ	true
+ * ANY		RW	true
+ * RW		READ	false
+ * RW		RW	true
+ * READ		READ	true
+ * READ		RW	true
+ */
+static inline int
+has_matching_lseg(struct pnfs_layout_segment *lseg,
+		  struct nfs4_pnfs_layout_segment *range)
+{
+	return (range->iomode != IOMODE_RW || lseg->range.iomode == IOMODE_RW);
+}
+
+/*
+ * lookup range in layout
+ */
+static struct pnfs_layout_segment *
+pnfs_has_layout(struct pnfs_layout_type *lo,
+		struct nfs4_pnfs_layout_segment *range)
+{
+	struct pnfs_layout_segment *lseg, *ret = NULL;
+
+	dprintk("%s:Begin\n", __func__);
+
+	BUG_ON_UNLOCKED_LO(lo);
+	list_for_each_entry (lseg, &lo->segs, fi_list) {
+		if (has_matching_lseg(lseg, range)) {
+			ret = lseg;
+			get_lseg(ret);
+			break;
+		}
+		if (cmp_layout(range, &lseg->range) > 0)
+			break;
+	}
+
+	dprintk("%s:Return lseg %p ref %d valid %d\n",
+		__func__, ret, ret ? atomic_read(&ret->kref.refcount) : 0,
+		ret ? ret->valid : 0);
+	return ret;
+}
+
+/* Update the file's layout for the given range and iomode.
+ * Layout is retreived from the server if needed.
+ * The appropriate layout segment is referenced and returned to the caller.
+ */
+void
+_pnfs_update_layout(struct inode *ino,
+		   struct nfs_open_context *ctx,
+		   enum pnfs_iomode iomode,
+		   struct pnfs_layout_segment **lsegpp)
+{
+	struct nfs4_pnfs_layout_segment arg = {
+		.iomode = iomode,
+		.offset = 0,
+		.length = NFS4_MAX_UINT64,
+	};
+	struct nfs_inode *nfsi = NFS_I(ino);
+	struct pnfs_layout_type *lo;
+	struct pnfs_layout_segment *lseg = NULL;
+
+	*lsegpp = NULL;
+	spin_lock(&ino->i_lock);
+	lo = pnfs_alloc_layout(ino);
+	if (lo == NULL) {
+		dprintk("%s ERROR: can't get pnfs_layout_type\n", __func__);
+		goto out_unlock;
+	}
+
+	/* Check to see if the layout for the given range already exists */
+	lseg = pnfs_has_layout(lo, &arg);
+	if (lseg && !lseg->valid) {
+		put_lseg_locked(lseg);
+		/* someone is cleaning the layout */
+		lseg = NULL;
+		goto out_unlock;
+	}
+
+	if (lseg) {
+		dprintk("%s: Using cached lseg %p for %llu@%llu iomode %d)\n",
+			__func__,
+			lseg,
+			arg.length,
+			arg.offset,
+			arg.iomode);
+
+		goto out_unlock;
+	}
+
+	/* if get layout already failed once goto out */
+	if (test_bit(lo_fail_bit(iomode), &nfsi->layout->pnfs_layout_state)) {
+		if (unlikely(nfsi->pnfs_layout_suspend &&
+		    get_seconds() >= nfsi->pnfs_layout_suspend)) {
+			dprintk("%s: layout_get resumed\n", __func__);
+			clear_bit(lo_fail_bit(iomode),
+				  &nfsi->layout->pnfs_layout_state);
+			nfsi->pnfs_layout_suspend = 0;
+		} else
+			goto out_unlock;
+	}
+
+	/* Reference the layout for layoutget matched in pnfs_layout_release */
+	get_layout(lo);
+	spin_unlock(&ino->i_lock);
+
+	send_layoutget(ino, ctx, &arg, lsegpp, lo);
+out:
+	dprintk("%s end, state 0x%lx lseg %p\n", __func__,
+		nfsi->layout->pnfs_layout_state, lseg);
+	return;
+out_unlock:
+	*lsegpp = lseg;
+	spin_unlock(&ino->i_lock);
+	goto out;
+}
+
 void
 pnfs_get_layout_done(struct nfs4_pnfs_layoutget *lgp, int rpc_status)
 {
+	struct pnfs_layout_segment *lseg = NULL;
+	struct nfs_inode *nfsi = NFS_I(lgp->args.inode);
+	time_t suspend = 0;
+
+	dprintk("-->%s\n", __func__);
+
+	lgp->status = rpc_status;
+	if (likely(!rpc_status)) {
+		if (unlikely(lgp->res.layout.len < 0)) {
+			printk(KERN_ERR
+			       "%s: ERROR Returned layout size is ZERO\n", __func__);
+			lgp->status = -EIO;
+		}
+		goto out;
+	}
+
+	dprintk("%s: ERROR retrieving layout %d\n", __func__, rpc_status);
+	switch (rpc_status) {
+	case -NFS4ERR_BADLAYOUT:
+		lgp->status = -ENOENT;
+		/* FALLTHROUGH */
+	case -EACCES:	/* NFS4ERR_ACCESS */
+		/* transient error, don't mark with NFS_INO_LAYOUT_FAILED */
+		goto out;
+
+	case -NFS4ERR_LAYOUTTRYLATER:
+	case -NFS4ERR_RECALLCONFLICT:
+	case -NFS4ERR_OLD_STATEID:
+	case -EAGAIN:	/* NFS4ERR_LOCKED */
+		lgp->status = -NFS4ERR_DELAY;	/* for nfs4_handle_exception */
+		/* FALLTHROUGH */
+	case -NFS4ERR_GRACE:
+	case -NFS4ERR_DELAY:
+		goto out;
+
+	case -NFS4ERR_ADMIN_REVOKED:
+	case -NFS4ERR_DELEG_REVOKED:
+		/* The layout is expected to be returned at this point.
+		 * This should clear the layout stateid as well */
+		suspend = get_seconds() + 1;
+		break;
+
+	case -NFS4ERR_LAYOUTUNAVAILABLE:
+		lgp->status = -ENOTSUPP;
+		break;
+
+	case -NFS4ERR_REP_TOO_BIG:
+	case -NFS4ERR_REP_TOO_BIG_TO_CACHE:
+		lgp->status = -E2BIG;
+		break;
+
+	/* Leave the following errors untranslated */
+	case -NFS4ERR_DEADSESSION:
+	case -NFS4ERR_DQUOT:
+	case -EINVAL:		/* NFS4ERR_INVAL */
+	case -EIO:		/* NFS4ERR_IO */
+	case -NFS4ERR_FHEXPIRED:
+	case -NFS4ERR_MOVED:
+	case -NFS4ERR_NOSPC:
+	case -ESERVERFAULT:	/* NFS4ERR_SERVERFAULT */
+	case -ESTALE:		/* NFS4ERR_STALE */
+	case -ETOOSMALL:	/* NFS4ERR_TOOSMALL */
+		break;
+
+	/* The following errors are our fault and should never happen */
+	case -NFS4ERR_BADIOMODE:
+	case -NFS4ERR_BADXDR:
+	case -NFS4ERR_REQ_TOO_BIG:
+	case -NFS4ERR_UNKNOWN_LAYOUTTYPE:
+	case -NFS4ERR_WRONG_TYPE:
+		lgp->status = -EINVAL;
+		/* FALLTHROUGH */
+	case -NFS4ERR_BAD_STATEID:
+	case -NFS4ERR_NOFILEHANDLE:
+	case -ENOTSUPP:	/* NFS4ERR_NOTSUPP */
+	case -NFS4ERR_OPENMODE:
+	case -NFS4ERR_OP_NOT_IN_SESSION:
+	case -NFS4ERR_TOO_MANY_OPS:
+		dprintk("%s: error %d: should never happen\n", __func__,
+			rpc_status);
+		break;
+
+	/* The following errors are the server's fault */
+	default:
+		dprintk("%s: illegal error %d\n", __func__, rpc_status);
+		lgp->status = -EIO;
+		break;
+	}
+
+	/* remember that get layout failed and suspend trying */
+	nfsi->pnfs_layout_suspend = suspend;
+	set_bit(lo_fail_bit(lgp->args.lseg.iomode),
+		&nfsi->layout->pnfs_layout_state);
+	dprintk("%s: layout_get suspended until %ld\n",
+		__func__, suspend);
+out:
+	dprintk("%s end (err:%d) state 0x%lx lseg %p\n",
+		__func__, lgp->status, nfsi->layout->pnfs_layout_state, lseg);
+	return;
 }
 
 int
 pnfs_layout_process(struct nfs4_pnfs_layoutget *lgp)
 {
+	struct pnfs_layout_type *lo = NFS_I(lgp->args.inode)->layout;
+	struct nfs4_pnfs_layoutget_res *res = &lgp->res;
+	struct pnfs_layout_segment *lseg;
+	struct inode *ino = PNFS_INODE(lo);
 	int status = 0;
 
+	/* Inject layout blob into I/O device driver */
+	lseg = PNFS_LD_IO_OPS(lo)->alloc_lseg(lo, res);
+	if (!lseg || IS_ERR(lseg)) {
+		if (!lseg)
+			status = -ENOMEM;
+		else
+			status = PTR_ERR(lseg);
+		dprintk("%s: Could not allocate layout: error %d\n",
+		       __func__, status);
+		goto out;
+	}
+
+	spin_lock(&ino->i_lock);
+	init_lseg(lo, lseg);
+	lseg->range = res->lseg;
+	if (lgp->lsegpp) {
+		get_lseg(lseg);
+		*lgp->lsegpp = lseg;
+	}
+	pnfs_insert_layout(lo, lseg);
+
+	if (res->return_on_close) {
+		lo->roc_iomode |= res->lseg.iomode;
+		if (!lo->roc_iomode)
+			lo->roc_iomode = IOMODE_ANY;
+	}
+
+	/* Done processing layoutget. Set the layout stateid */
+	pnfs_set_layout_stateid(lo, &res->stateid);
+	spin_unlock(&ino->i_lock);
+out:
 	return status;
 }
 
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 8c1d50e..379aa18 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -28,6 +28,10 @@ extern int pnfs4_proc_layoutget(struct nfs4_pnfs_layoutget *lgp);
 
 /* pnfs.c */
 void put_lseg(struct pnfs_layout_segment *lseg);
+void _pnfs_update_layout(struct inode *ino, struct nfs_open_context *ctx,
+	enum pnfs_iomode access_type,
+	struct pnfs_layout_segment **lsegpp);
+
 void set_pnfs_layoutdriver(struct nfs_server *, u32 id);
 void unmount_pnfs_layoutdriver(struct nfs_server *);
 int pnfs_initialize(void);
@@ -47,6 +51,12 @@ void pnfs_get_layout_stateid(nfs4_stateid *dst, struct pnfs_layout_type *lo);
 
 #define LAYOUT_NFSV4_1_MODULE_PREFIX "nfs-layouttype4"
 
+static inline int lo_fail_bit(u32 iomode)
+{
+	return iomode == IOMODE_RW ?
+			 NFS_INO_RW_LAYOUT_FAILED : NFS_INO_RO_LAYOUT_FAILED;
+}
+
 static inline void get_lseg(struct pnfs_layout_segment *lseg)
 {
 	kref_get(&lseg->kref);
@@ -58,6 +68,21 @@ static inline int pnfs_enabled_sb(struct nfs_server *nfss)
 	return nfss->pnfs_curr_ld != NULL;
 }
 
+static inline void pnfs_update_layout(struct inode *ino,
+	struct nfs_open_context *ctx,
+	enum pnfs_iomode access_type,
+	struct pnfs_layout_segment **lsegpp)
+{
+	struct nfs_server *nfss = NFS_SERVER(ino);
+
+	if (pnfs_enabled_sb(nfss))
+		_pnfs_update_layout(ino, ctx, access_type, lsegpp);
+	else {
+		if (lsegpp)
+			*lsegpp = NULL;
+	}
+}
+
 #else  /* CONFIG_NFS_V4_1 */
 
 static inline void pnfs_destroy_all_layouts(struct nfs_client *clp)
@@ -76,6 +101,15 @@ static inline void put_lseg(struct pnfs_layout_segment *lseg)
 {
 }
 
+static inline void
+pnfs_update_layout(struct inode *ino, struct nfs_open_context *ctx,
+	enum pnfs_iomode access_type,
+	struct pnfs_layout_segment **lsegpp)
+{
+	if (lsegpp)
+		*lsegpp = NULL;
+}
+
 #endif /* CONFIG_NFS_V4_1 */
 
 #endif /* FS_NFS_PNFS_H */
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index c8b6129..7202c05 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -213,6 +213,7 @@ struct nfs_inode {
 #if defined(CONFIG_NFS_V4_1)
 	wait_queue_head_t lo_waitq;
 	struct pnfs_layout_type *layout;
+	time_t pnfs_layout_suspend;
 #endif /* CONFIG_NFS_V4_1 */
 #endif /* CONFIG_NFS_V4*/
 #ifdef CONFIG_NFS_FSCACHE
-- 
1.6.2.5

