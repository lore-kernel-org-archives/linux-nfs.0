Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f43.google.com ([209.85.216.43]:39495 "EHLO
	mail-qa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753078Ab3IZSlM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Sep 2013 14:41:12 -0400
Received: by mail-qa0-f43.google.com with SMTP id k15so4620388qaq.2
        for <linux-nfs@vger.kernel.org>; Thu, 26 Sep 2013 11:41:11 -0700 (PDT)
From: Benny Halevy <bhalevy@primarydata.com>
To: " J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH RFC v0 19/49] pnfsd: layout get
Date: Thu, 26 Sep 2013 14:41:09 -0400
Message-Id: <1380220869-13552-1-git-send-email-bhalevy@primarydata.com>
In-Reply-To: <52447EA0.7070004@primarydata.com>
References: <52447EA0.7070004@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Benny Halevy <bhalevy@panasas.com>

Currently, always return a single record in the log_layout array.

If an invalid iomode, or an iomode of LAYOUTIOMODE4_ANY is specified, the
metadata server MUST return NFS4ERR_BADIOMODE.

[extracted from pnfsd: Initial pNFS server implementation.]
[pnfsd: nfsd layout cache: layout return changes]
[pnfsd: add debug printouts in return_layout path]
[pnfsd: refactor return_layout]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[pnfsd: Streamline error code checking for non-pnfs filesystems]
[pnfsd: Use nfsd4_layout_seg instead of wrapper struct.]
[pnfsd: Move nfsd4_layout_seg to exportfs.h]
[pnfsd: Fix file layout layoutget export op for d13]
[pnfsd: Simplify layout get export interface.]
Signed-off-by: Dean Hildebrand <dhildeb@us.ibm.com>
[pnfsd: improve nfs4_pnfs_get_layout dprintks]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[pnfsd: initialize layoutget return_on_close]
Signed-off-by: Andy Adamson <andros@netapp.com>
[pnfsd: update server layout xdr for draft 19.]
Signed-off-by: Dean Hildebrand <dhildeb@us.ibm.com>
[pnfsd: use stateid_t for layout stateid xdr data structs]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[pnfsd: Update getdeviceinfo for draft-19]
Signed-off-by: Dean Hildebrand <dhildeb@us.ibm.com>
[pnfsd: xdr encode layoutget response logr_layout array count as per draft-19]
[pnfsd: use stateid xdr {en,de}code functions for layoutget]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[pnfsd: use nfsd4_compoundres pointer in pnfs_xdr_info]
Signed-off-by: Andy Adamson <andros@netapp.com>
[pnfsd: move vfs api structures to nfsd4_pnfs.h]
[pnfsd: convert generic code to use new pnfs api]
[pnfsd: define pnfs_export_operations]
[pnfsd: obliterate old vfs api]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[Split this patch into filelayout only (this patch) and all layout types]
(patch pnfsd: layout get all layout types).
Remove use of pnfs_export_operations.
Signed-off-by: Andy Adamson <andros@netapp.com>
[pnfsd: fixup ENCODE_HEAD for layoutget]
[pnfsd: rewind xdr response pointer on nfsd4_encode_layoutget error]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[Move pnfsd code from nfs4state.c to nfs4pnfsd.c]
[Move common state code from linux/nfsd/state.h to fs/nfsd/internal.h]
Signed-off-by: Andy Adamson <andros@netapp.com>
[pnfsd: Release lock during layout export ops.]
Signed-off-by: Dean Hildebrand <dhildeb@us.ibm.com>
[cosmetic changes from pnfsd: Helper functions for layout stateid processing.]
[pnfsd: layout get all layout types]
[pnfsd: check ex_pnfs in nfsd4_verify_layout]
Signed-off-by: Andy Adamson <andros@netapp.com>
[removed the nfsd4_pnfs_fl_layoutget stub]
[pnfsd: get rid of layout encoding function vector]
[pnfsd: filelayout: convert to using exp_xdr]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[pnfsd: Move pnfsd code out of nfs4state.c/h]
Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
[fixed !CONFIG_PNFSD and clean up for pnfsd-files]
[gfs2: set pnfs_dlm_export_ops only for CONFIG_PNFSD]
[moved pnfsd defs back into state.h]
[pnfsd: rename deviceid_t struct pnfs_deviceid]
[pnfsd: fix cosmetic checkpatch warnings]
[pnfsd: handle s_pnfs_op==NULL]
[pnfsd: move layoutget xdr structure to xdr4.h]
[pnfsd: clean up layoutget export API]
[pnfsd: moved find_alloc_file to nfs4state.c]
[moved struct nfs4_fsid to public include/linux/nfs4.h]
[pnfsd: rename device fsid member to sbid]
[pnfsd: use sbid hash table to map super_blocks to devid major identifiers]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[pnfsd: fix file system API layout_get error codes]
[pnfsd: fix NFS4ERR_BADIOMODE in layoutget]
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[pnfsd: require filesystem layout_get method return a u32 rather than int]
[pnfsd: allow filesystem to return canonical nfs4 errors for layoutget]
[pnfsd: do not allow filesystem to return encoded nfs errors on layout_get]
[pnfsd: fixup nfs4_pnfs_get_layout to use __be32 nfserr]
[pnfsd: allow filesystem to return NFS4ERR_WRONG_TYPE for layout_get]
[pnfsd: fix error handling in layout_get]
[pnfsd: fix uninitialized usage of nfserr in nfs4_pnfs_get_layout]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[pnfsd: handle LAYOUTGET with maxcount >= 2^31]
[pnfsd: verify minlength and range as per RFC5661]
[pnfsd: use nfsd_net for layoutget starting v3.8]
[pnfsd: merge_layout needs to acquire the layout_lock for traversing fi_layouts]
[pnfsd: return bool from merge_layout and fix not found path]
Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
[pnfsd: nfsd4_pnfs_dlm_layoutget]
Signed-off-by: Andy Adamson <andros@netapp.com>
[pnfsd: layout state: hang layouts on layout state]
[pnfsd: do not release the state lock around call to fs layout_get]
Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
---
 fs/nfsd/export.c                |   3 +-
 fs/nfsd/nfs4pnfsd.c             | 169 ++++++++++++++++++++++++++++++++++++++++
 fs/nfsd/nfs4proc.c              |  50 ++++++++++++
 fs/nfsd/nfs4state.c             |  51 ++++++------
 fs/nfsd/nfs4xdr.c               | 109 +++++++++++++++++++++++++-
 fs/nfsd/pnfsd.h                 |   8 ++
 fs/nfsd/state.h                 |  33 ++++++++
 fs/nfsd/xdr4.h                  |  11 +++
 include/linux/exportfs.h        |   3 +-
 include/linux/nfs4.h            |   5 ++
 include/linux/nfsd/nfsd4_pnfs.h |  67 ++++++++++++++++
 11 files changed, 479 insertions(+), 30 deletions(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index 462f0df..043c8e2 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -378,7 +378,8 @@ static int check_export(struct inode *inode, int *flags, unsigned char *uuid)
 
 	if (inode->i_sb->s_pnfs_op &&
 	    (!inode->i_sb->s_pnfs_op->layout_type ||
-	     !inode->i_sb->s_pnfs_op->get_device_info)) {
+	     !inode->i_sb->s_pnfs_op->get_device_info ||
+	     !inode->i_sb->s_pnfs_op->layout_get)) {
 		dprintk("exp_export: export of invalid fs pnfs export ops.\n");
 		return -EINVAL;
 	}
diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
index d219e42..b8ddd82 100644
--- a/fs/nfsd/nfs4pnfsd.c
+++ b/fs/nfsd/nfs4pnfsd.c
@@ -22,11 +22,24 @@
  *****************************************************************************/
 
 #include "pnfsd.h"
+#include "netns.h"
 
 #define NFSDDBG_FACILITY                NFSDDBG_PNFS
 
+/*
+ * w.r.t layout lists and recalls, layout_lock protects readers from a writer
+ * All modifications to per-file layout state / layout lists are done under the file_lo_lock
+ * The only writer-exclusion done with layout_lock is for the sbid table
+ */
 static DEFINE_SPINLOCK(layout_lock);
 
+#define ASSERT_LAYOUT_LOCKED()	assert_spin_locked(&layout_lock);
+
+/*
+ * Layout state - NFSv4.1 pNFS
+ */
+static struct kmem_cache *pnfs_layout_slab;
+
 /* hash table for nfsd4_pnfs_deviceid.sbid */
 #define SBID_HASH_BITS	8
 #define SBID_HASH_SIZE	(1 << SBID_HASH_BITS)
@@ -68,6 +81,8 @@ struct sbid_tracker {
 	int i;
 	struct sbid_tracker *sbid;
 
+	nfsd4_free_slab(&pnfs_layout_slab);
+
 	for (i = 0; i < SBID_HASH_SIZE; i++) {
 		while (!list_empty(&sbid_hashtbl[i])) {
 			sbid = list_first_entry(&sbid_hashtbl[i],
@@ -83,12 +98,39 @@ struct sbid_tracker {
 {
 	int i;
 
+	pnfs_layout_slab = kmem_cache_create("pnfs_layouts",
+			sizeof(struct nfs4_layout), 0, 0, NULL);
+	if (pnfs_layout_slab == NULL)
+		return -ENOMEM;
+
 	for (i = 0; i < SBID_HASH_SIZE; i++)
 		INIT_LIST_HEAD(&sbid_hashtbl[i]);
 
 	return 0;
 }
 
+static struct nfs4_layout *
+alloc_layout(void)
+{
+	return kmem_cache_alloc(pnfs_layout_slab, GFP_KERNEL);
+}
+
+static void
+free_layout(struct nfs4_layout *lp)
+{
+	kmem_cache_free(pnfs_layout_slab, lp);
+}
+
+static void
+init_layout(struct nfs4_layout *lp,
+	    struct nfsd4_layout_seg *seg)
+{
+	dprintk("pNFS %s: lp %p\n", __func__, lp);
+
+	memcpy(&lp->lo_seg, seg, sizeof(lp->lo_seg));
+	dprintk("pNFS %s end\n", __func__);
+}
+
 static u64
 alloc_init_sbid(struct super_block *sb)
 {
@@ -165,3 +207,130 @@ struct super_block *
 
 	return id;
 }
+
+__be32
+nfs4_pnfs_get_layout(struct svc_rqst *rqstp,
+		     struct nfsd4_pnfs_layoutget *lgp,
+		     struct exp_xdr_stream *xdr)
+{
+	u32 status;
+	__be32 nfserr;
+	struct inode *ino = lgp->lg_fhp->fh_dentry->d_inode;
+	struct super_block *sb = ino->i_sb;
+	struct nfs4_file *fp;
+	struct nfs4_client *clp;
+	struct nfs4_layout *lp = NULL;
+	struct nfsd4_pnfs_layoutget_arg args = {
+		.lg_minlength = lgp->lg_minlength,
+		.lg_fh = &lgp->lg_fhp->fh_handle,
+	};
+	struct nfsd4_pnfs_layoutget_res res = {
+		.lg_seg = lgp->lg_seg,
+	};
+
+	dprintk("NFSD: %s Begin\n", __func__);
+
+	/* verify minlength and range as per RFC5661:
+	 *  o  If loga_length is less than loga_minlength,
+	 *     the metadata server MUST return NFS4ERR_INVAL.
+	 *  o  If the sum of loga_offset and loga_minlength exceeds
+	 *     NFS4_UINT64_MAX, and loga_minlength is not
+	 *     NFS4_UINT64_MAX, the error NFS4ERR_INVAL MUST result.
+	 *  o  If the sum of loga_offset and loga_length exceeds
+	 *     NFS4_UINT64_MAX, and loga_length is not NFS4_UINT64_MAX,
+	 *     the error NFS4ERR_INVAL MUST result.
+	 */
+	if ((lgp->lg_seg.length < lgp->lg_minlength) ||
+	    (lgp->lg_minlength != NFS4_MAX_UINT64 &&
+	     lgp->lg_minlength > NFS4_MAX_UINT64 - lgp->lg_seg.offset) ||
+	    (lgp->lg_seg.length != NFS4_MAX_UINT64 &&
+	     lgp->lg_seg.length > NFS4_MAX_UINT64 - lgp->lg_seg.offset)) {
+		nfserr = nfserr_inval;
+		goto out;
+	}
+
+	args.lg_sbid = find_create_sbid(sb);
+	if (!args.lg_sbid) {
+		nfserr = nfserr_layouttrylater;
+		goto out;
+	}
+
+	nfs4_lock_state();
+	fp = find_alloc_file(ino, lgp->lg_fhp);
+	clp = find_confirmed_client((clientid_t *)&lgp->lg_seg.clientid, true,
+				    net_generic(SVC_NET(rqstp), nfsd_net_id));
+	dprintk("pNFS %s: fp %p clp %p\n", __func__, fp, clp);
+	if (!fp || !clp) {
+		nfserr = nfserr_inval;
+		goto out_unlock;
+	}
+
+	lp = alloc_layout();
+	if (!lp) {
+		nfserr = nfserr_layouttrylater;
+		goto out_unlock;
+	}
+
+	dprintk("pNFS %s: pre-export type 0x%x maxcount %Zd "
+		"iomode %u offset %llu length %llu\n",
+		__func__, lgp->lg_seg.layout_type,
+		exp_xdr_qbytes(xdr->end - xdr->p),
+		lgp->lg_seg.iomode, lgp->lg_seg.offset, lgp->lg_seg.length);
+
+	status = sb->s_pnfs_op->layout_get(ino, xdr, &args, &res);
+
+	dprintk("pNFS %s: post-export status %u "
+		"iomode %u offset %llu length %llu\n",
+		__func__, status, res.lg_seg.iomode,
+		res.lg_seg.offset, res.lg_seg.length);
+
+	/*
+	 * The allowable error codes for the layout_get pNFS export
+	 * operations vector function (from the file system) can be
+	 * expanded as needed to include other errors defined for
+	 * the RFC 5561 LAYOUTGET operation.
+	 */
+	switch (status) {
+	case 0:
+		nfserr = NFS4_OK;
+		break;
+	case NFS4ERR_ACCESS:
+	case NFS4ERR_BADIOMODE:
+		/* No support for LAYOUTIOMODE4_RW layouts */
+	case NFS4ERR_BADLAYOUT:
+		/* No layout matching loga_minlength rules */
+	case NFS4ERR_INVAL:
+	case NFS4ERR_IO:
+	case NFS4ERR_LAYOUTTRYLATER:
+	case NFS4ERR_LAYOUTUNAVAILABLE:
+	case NFS4ERR_LOCKED:
+	case NFS4ERR_NOSPC:
+	case NFS4ERR_RECALLCONFLICT:
+	case NFS4ERR_SERVERFAULT:
+	case NFS4ERR_TOOSMALL:
+		/* Requested layout too big for loga_maxcount */
+	case NFS4ERR_WRONG_TYPE:
+		/* Not a regular file */
+		nfserr = cpu_to_be32(status);
+		goto out_freelayout;
+	default:
+		BUG();
+		nfserr = nfserr_serverfault;
+	}
+
+	lgp->lg_seg = res.lg_seg;
+	lgp->lg_roc = res.lg_return_on_close;
+
+	init_layout(lp, &res.lg_seg);
+out_unlock:
+	nfs4_unlock_state();
+	if (fp)
+		put_nfs4_file(fp);
+out:
+	dprintk("pNFS %s: lp %p exit nfserr %u\n", __func__, lp,
+		be32_to_cpu(nfserr));
+	return nfserr;
+out_freelayout:
+	free_layout(lp);
+	goto out_unlock;
+}
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 81d41a4..960d8ff 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1228,6 +1228,52 @@ static int fill_in_write_vector(struct kvec *vec, struct nfsd4_write *write)
 out:
 	return status;
 }
+
+static __be32
+nfsd4_layoutget(struct svc_rqst *rqstp,
+		struct nfsd4_compound_state *cstate,
+		struct nfsd4_pnfs_layoutget *lgp)
+{
+	int status;
+	struct super_block *sb;
+	struct svc_fh *current_fh = &cstate->current_fh;
+	int accmode;
+
+	if (lgp->lg_seg.iomode == IOMODE_READ) {
+		accmode = NFSD_MAY_READ;
+	} else if (lgp->lg_seg.iomode == IOMODE_RW) {
+		accmode = NFSD_MAY_READ | NFSD_MAY_WRITE;
+	} else {
+		status = nfserr_badiomode;
+		dprintk("pNFS %s: invalid iomode %d\n", __func__,
+			lgp->lg_seg.iomode);
+		goto out;
+	}
+
+	status = fh_verify(rqstp, current_fh, 0, accmode);
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
+				     lgp->lg_seg.layout_type);
+	if (status)
+		goto out;
+
+	/* Set up arguments so layout can be retrieved at encode time */
+	lgp->lg_fhp = current_fh;
+	copy_clientid((clientid_t *)&lgp->lg_seg.clientid, cstate->session);
+	status = nfs_ok;
+out:
+	return status;
+}
 #endif /* CONFIG_PNFSD */
 
 /*
@@ -1971,6 +2017,10 @@ static inline u32 nfsd4_create_session_rsize(struct svc_rqst *rqstp, struct nfsd
 		.op_flags = ALLOWED_WITHOUT_FH,
 		.op_name = "OP_GETDEVICEINFO",
 	},
+	[OP_LAYOUTGET] = {
+		.op_func = (nfsd4op_func)nfsd4_layoutget,
+		.op_name = "OP_LAYOUTGET",
+	},
 #endif /* CONFIG_PNFSD */
 };
 
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index f6022a6..a8a18d4 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -239,7 +239,7 @@ static void nfsd4_free_file(struct nfs4_file *f)
 	kmem_cache_free(file_slab, f);
 }
 
-static inline void
+void
 put_nfs4_file(struct nfs4_file *fi)
 {
 	if (atomic_dec_and_lock(&fi->fi_ref, &recall_lock)) {
@@ -250,7 +250,7 @@ static void nfsd4_free_file(struct nfs4_file *f)
 	}
 }
 
-static inline void
+void
 get_nfs4_file(struct nfs4_file *fi)
 {
 	atomic_inc(&fi->fi_ref);
@@ -1462,7 +1462,7 @@ static struct nfs4_client *create_client(struct xdr_netobj name,
 	return NULL;
 }
 
-static struct nfs4_client *
+struct nfs4_client *
 find_confirmed_client(clientid_t *clid, bool sessions, struct nfsd_net *nn)
 {
 	struct list_head *tbl = nn->conf_id_hashtbl;
@@ -2490,7 +2490,8 @@ static struct nfs4_file *nfsd4_alloc_file(void)
 }
 
 /* OPEN Share state helper functions */
-static void nfsd4_init_file(struct nfs4_file *fp, struct inode *ino)
+static void nfsd4_init_file(struct nfs4_file *fp, struct inode *ino,
+			    struct svc_fh *current_fh)
 {
 	unsigned int hashval = file_hashval(ino);
 
@@ -2507,7 +2508,7 @@ static void nfsd4_init_file(struct nfs4_file *fp, struct inode *ino)
 	spin_unlock(&recall_lock);
 }
 
-static void
+void
 nfsd4_free_slab(struct kmem_cache **slab)
 {
 	if (*slab == NULL)
@@ -2524,6 +2525,7 @@ static void nfsd4_init_file(struct nfs4_file *fp, struct inode *ino)
 	nfsd4_free_slab(&file_slab);
 	nfsd4_free_slab(&stateid_slab);
 	nfsd4_free_slab(&deleg_slab);
+	nfsd4_free_pnfs_slabs();
 }
 
 int
@@ -2549,6 +2551,8 @@ static void nfsd4_init_file(struct nfs4_file *fp, struct inode *ino)
 			sizeof(struct nfs4_delegation), 0, 0, NULL);
 	if (deleg_slab == NULL)
 		goto out_nomem;
+	if (nfsd4_init_pnfs_slabs())
+		goto out_nomem;
 	return 0;
 out_nomem:
 	nfsd4_free_slabs();
@@ -2702,6 +2706,21 @@ static void init_open_stateid(struct nfs4_ol_stateid *stp, struct nfs4_file *fp,
 	return NULL;
 }
 
+struct nfs4_file *
+find_alloc_file(struct inode *ino, struct svc_fh *current_fh)
+{
+	struct nfs4_file *fp;
+
+	fp = find_file(ino);
+	if (!fp) {
+		fp = nfsd4_alloc_file();
+		if (fp)
+			nfsd4_init_file(fp, ino, current_fh);
+	}
+
+	return fp;
+}
+
 /*
  * Called to check deny when READ with all zero stateid or
  * WRITE with all zero or all one stateid
@@ -3244,7 +3263,7 @@ static void nfsd4_deleg_xgrade_none_ext(struct nfsd4_open *open,
 		status = nfserr_jukebox;
 		fp = open->op_file;
 		open->op_file = NULL;
-		nfsd4_init_file(fp, ino);
+		nfsd4_init_file(fp, ino, current_fh);
 	}
 
 	/*
@@ -4082,26 +4101,6 @@ static void nfsd4_close_open_stateid(struct nfs4_ol_stateid *s)
 
 #define LOCKOWNER_INO_HASH_MASK (LOCKOWNER_INO_HASH_SIZE - 1)
 
-static inline u64
-end_offset(u64 start, u64 len)
-{
-	u64 end;
-
-	end = start + len;
-	return end >= start ? end: NFS4_MAX_UINT64;
-}
-
-/* last octet in a range */
-static inline u64
-last_byte_offset(u64 start, u64 len)
-{
-	u64 end;
-
-	WARN_ON_ONCE(!len);
-	end = start + len;
-	return end > start ? end - 1: NFS4_MAX_UINT64;
-}
-
 static unsigned int lockowner_ino_hashval(struct inode *inode, u32 cl_id, struct xdr_netobj *ownername)
 {
 	return (file_hashval(inode) + cl_id
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index ed86a2d..1cc19cd 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1521,6 +1521,26 @@ static __be32 nfsd4_decode_reclaim_complete(struct nfsd4_compoundargs *argp, str
 
 	DECODE_TAIL;
 }
+
+static __be32
+nfsd4_decode_layoutget(struct nfsd4_compoundargs *argp,
+			struct nfsd4_pnfs_layoutget *lgp)
+{
+	DECODE_HEAD;
+
+	READ_BUF(36);
+	READ32(lgp->lg_signal);
+	READ32(lgp->lg_seg.layout_type);
+	READ32(lgp->lg_seg.iomode);
+	READ64(lgp->lg_seg.offset);
+	READ64(lgp->lg_seg.length);
+	READ64(lgp->lg_minlength);
+	nfsd4_decode_stateid(argp, &lgp->lg_sid);
+	READ_BUF(4);
+	READ32(lgp->lg_maxcount);
+
+	DECODE_TAIL;
+}
 #endif /* CONFIG_PNFSD */
 
 static __be32
@@ -1628,7 +1648,7 @@ static __be32 nfsd4_decode_reclaim_complete(struct nfsd4_compoundargs *argp, str
 	[OP_GETDEVICEINFO]	= (nfsd4_dec)nfsd4_decode_getdevinfo,
 	[OP_GETDEVICELIST]	= (nfsd4_dec)nfsd4_decode_getdevlist,
 	[OP_LAYOUTCOMMIT]	= (nfsd4_dec)nfsd4_decode_notsupp,
-	[OP_LAYOUTGET]		= (nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_LAYOUTGET]		= (nfsd4_dec)nfsd4_decode_layoutget,
 	[OP_LAYOUTRETURN]	= (nfsd4_dec)nfsd4_decode_notsupp,
 #else  /* CONFIG_PNFSD */
 	[OP_GETDEVICEINFO]	= (nfsd4_dec)nfsd4_decode_notsupp,
@@ -3767,6 +3787,91 @@ static __be32 nfsd4_encode_bind_conn_to_session(struct nfsd4_compoundres *resp,
 	ADJUST_ARGS();
 	goto out;
 }
+
+static __be32
+nfsd4_encode_layoutget(struct nfsd4_compoundres *resp,
+		       __be32 nfserr,
+		       struct nfsd4_pnfs_layoutget *lgp)
+{
+	u32 maxcount, leadcount;
+	struct super_block *sb;
+	struct exp_xdr_stream xdr;
+	__be32 *p, *p_save, *p_start = resp->p;
+
+	dprintk("%s: err %d\n", __func__, nfserr);
+	if (nfserr)
+		return nfserr;
+
+	sb = lgp->lg_fhp->fh_dentry->d_inode->i_sb;
+	maxcount = PAGE_SIZE;
+	if (maxcount > lgp->lg_maxcount)
+		maxcount = lgp->lg_maxcount;
+
+	/* Check for space on xdr stream */
+	leadcount = 36 + sizeof(stateid_opaque_t);
+	RESERVE_SPACE(leadcount);
+	/* encode layout metadata after file system encodes layout */
+	p += XDR_QUADLEN(leadcount);
+	ADJUST_ARGS();
+
+	/* Ensure have room for ret_on_close, off, len, iomode, type */
+	if (maxcount < leadcount) {
+		dprintk("%s: buffer too small for response header (%u < %u)\n",
+			__func__, maxcount, leadcount);
+		nfserr = nfserr_toosmall;
+		goto err;
+	}
+	maxcount -= leadcount;
+
+	/* Set xdr info so file system can encode layout */
+	xdr.p = p_save = resp->p;
+	xdr.end = resp->end;
+	if (xdr.end - xdr.p > exp_xdr_qwords(maxcount & ~3))
+		xdr.end = xdr.p + exp_xdr_qwords(maxcount & ~3);
+
+	/* Retrieve, encode, and merge layout */
+	nfserr = nfs4_pnfs_get_layout(resp->rqstp, lgp, &xdr);
+	if (nfserr)
+		goto err;
+
+	/* Ensure file system returned enough bytes for the client
+	 * to access.
+	 */
+	if (lgp->lg_seg.length < lgp->lg_minlength) {
+		nfserr = nfserr_badlayout;
+		goto err;
+	}
+
+	/* The file system should never write 0 bytes without
+	 * returning an error
+	 */
+	BUG_ON(xdr.p == p_save);
+
+	/* Rewind to beginning and encode attrs */
+	resp->p = p_start;
+	RESERVE_SPACE(4);
+	WRITE32(lgp->lg_roc);	/* return on close */
+	ADJUST_ARGS();
+	nfsd4_encode_stateid(resp, &lgp->lg_sid);
+	RESERVE_SPACE(28);
+	/* Note: response logr_layout array count, always one for now */
+	WRITE32(1);
+	WRITE64(lgp->lg_seg.offset);
+	WRITE64(lgp->lg_seg.length);
+	WRITE32(lgp->lg_seg.iomode);
+	WRITE32(lgp->lg_seg.layout_type);
+
+	/* Update the xdr stream with the number of bytes written
+	 * by the file system
+	 */
+	p = xdr.p;
+	ADJUST_ARGS();
+
+	return nfs_ok;
+err:
+	resp->p = p_start;
+	return nfserr;
+}
 #endif /* CONFIG_PNFSD */
 
 static __be32
@@ -3833,7 +3938,7 @@ static __be32 nfsd4_encode_bind_conn_to_session(struct nfsd4_compoundres *resp,
 	[OP_GETDEVICEINFO]	= (nfsd4_enc)nfsd4_encode_getdevinfo,
 	[OP_GETDEVICELIST]	= (nfsd4_enc)nfsd4_encode_getdevlist,
 	[OP_LAYOUTCOMMIT]	= (nfsd4_enc)nfsd4_encode_noop,
-	[OP_LAYOUTGET]		= (nfsd4_enc)nfsd4_encode_noop,
+	[OP_LAYOUTGET]		= (nfsd4_enc)nfsd4_encode_layoutget,
 	[OP_LAYOUTRETURN]	= (nfsd4_enc)nfsd4_encode_noop,
 #else  /* CONFIG_PNFSD */
 	[OP_GETDEVICEINFO]	= (nfsd4_enc)nfsd4_encode_noop,
diff --git a/fs/nfsd/pnfsd.h b/fs/nfsd/pnfsd.h
index cfcfc9a..6920e43 100644
--- a/fs/nfsd/pnfsd.h
+++ b/fs/nfsd/pnfsd.h
@@ -34,11 +34,19 @@
 #ifndef LINUX_NFSD_PNFSD_H
 #define LINUX_NFSD_PNFSD_H
 
+#include <linux/list.h>
 #include <linux/nfsd/nfsd4_pnfs.h>
 
+#include "state.h"
 #include "xdr4.h"
 
+/* outstanding layout */
+struct nfs4_layout {
+	struct nfsd4_layout_seg		lo_seg;
+};
+
 u64 find_create_sbid(struct super_block *);
 struct super_block *find_sbid_id(u64);
+__be32 nfs4_pnfs_get_layout(struct svc_rqst *, struct nfsd4_pnfs_layoutget *, struct exp_xdr_stream *);
 
 #endif /* LINUX_NFSD_PNFSD_H */
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 2e601a2..b85ad60 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -481,6 +481,39 @@ extern struct nfs4_client_reclaim *nfs4_client_to_reclaim(const char *name,
 							struct nfsd_net *nn);
 extern bool nfs4_has_reclaimed_state(const char *name, struct nfsd_net *nn);
 extern void put_client_renew(struct nfs4_client *clp);
+extern void nfsd4_free_slab(struct kmem_cache **);
+extern struct nfs4_file *find_alloc_file(struct inode *, struct svc_fh *);
+extern void put_nfs4_file(struct nfs4_file *);
+extern void get_nfs4_file(struct nfs4_file *);
+extern struct nfs4_client *find_confirmed_client(clientid_t *, bool sessions, struct nfsd_net *);
+
+#if defined(CONFIG_PNFSD)
+extern int nfsd4_init_pnfs_slabs(void);
+extern void nfsd4_free_pnfs_slabs(void);
+#else /* CONFIG_PNFSD */
+static inline void nfsd4_free_pnfs_slabs(void) {}
+static inline int nfsd4_init_pnfs_slabs(void) { return 0; }
+#endif /* CONFIG_PNFSD */
+
+static inline u64
+end_offset(u64 start, u64 len)
+{
+	u64 end;
+
+	end = start + len;
+	return end >= start ? end: NFS4_MAX_UINT64;
+}
+
+/* last octet in a range */
+static inline u64
+last_byte_offset(u64 start, u64 len)
+{
+	u64 end;
+
+	WARN_ON_ONCE(!len);
+	end = start + len;
+	return end > start ? end - 1: NFS4_MAX_UINT64;
+}
 
 /* nfs4recover operations */
 extern int nfsd4_client_tracking_init(struct net *net);
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index faf37bc..727288b 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -448,6 +448,16 @@ struct nfsd4_pnfs_getdevlist {
 	u32		gd_eof;		/* response */
 };
 
+struct nfsd4_pnfs_layoutget {
+	u64			lg_minlength;	/* request */
+	u32			lg_signal;	/* request */
+	u32			lg_maxcount;	/* request */
+	struct svc_fh		*lg_fhp;	/* request */
+	stateid_t		lg_sid;		/* request/response */
+	struct nfsd4_layout_seg	lg_seg;		/* request/response */
+	u32			lg_roc;		/* response */
+};
+
 struct nfsd4_op {
 	int					opnum;
 	__be32					status;
@@ -496,6 +506,7 @@ struct nfsd4_op {
 #if defined(CONFIG_PNFSD)
 		struct nfsd4_pnfs_getdevlist	pnfs_getdevlist;
 		struct nfsd4_pnfs_getdevinfo	pnfs_getdevinfo;
+		struct nfsd4_pnfs_layoutget	pnfs_layoutget;
 #endif /* CONFIG_PNFSD */
 	} u;
 	struct nfs4_replay *			replay;
diff --git a/include/linux/exportfs.h b/include/linux/exportfs.h
index ade74e1..017f1753 100644
--- a/include/linux/exportfs.h
+++ b/include/linux/exportfs.h
@@ -218,6 +218,7 @@ extern struct dentry *generic_fh_to_parent(struct super_block *sb,
 
 extern int filelayout_encode_devinfo(struct exp_xdr_stream *xdr,
 				     const struct pnfs_filelayout_device *fdev);
-
+extern int filelayout_encode_layout(struct exp_xdr_stream *xdr,
+				    const struct pnfs_filelayout_layout *flp);
 #endif /* defined(CONFIG_EXPORTFS_FILE_LAYOUT) */
 #endif /* LINUX_EXPORTFS_H */
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index e36dee5..2c3aa9f 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -32,6 +32,11 @@ struct nfs4_acl {
 	struct nfs4_ace	aces[0];
 };
 
+struct nfs4_fsid {
+	u64	major;
+	u64	minor;
+};
+
 #define NFS4_MAXLABELLEN	2048
 
 struct nfs4_label {
diff --git a/include/linux/nfsd/nfsd4_pnfs.h b/include/linux/nfsd/nfsd4_pnfs.h
index 28f9daa..a680085 100644
--- a/include/linux/nfsd/nfsd4_pnfs.h
+++ b/include/linux/nfsd/nfsd4_pnfs.h
@@ -56,6 +56,36 @@ struct nfsd4_pnfs_dev_iter_res {
 	u32		gd_eof;		/* response */
 };
 
+struct nfsd4_layout_seg {
+	u64	clientid;
+	u32	layout_type;
+	u32	iomode;
+	u64	offset;
+	u64	length;
+};
+
+/* Used by layout_get to encode layout (loc_body var in spec)
+ * Args:
+ * minlength - min number of accessible bytes given by layout
+ * fsid - Major part of struct pnfs_deviceid.  File system uses this
+ * to build the deviceid returned in the layout.
+ * fh - fs can modify the file handle for use on data servers
+ * seg - layout info requested and layout info returned
+ * xdr - xdr info
+ * return_on_close - true if layout to be returned on file close
+ */
+
+struct nfsd4_pnfs_layoutget_arg {
+	u64			lg_minlength;
+	u64			lg_sbid;
+	const struct knfsd_fh	*lg_fh;
+};
+
+struct nfsd4_pnfs_layoutget_res {
+	struct nfsd4_layout_seg	lg_seg;	/* request/resopnse */
+	u32			lg_return_on_close;
+};
+
 /*
  * pNFS export operations vector.
  *
@@ -88,6 +118,43 @@ struct pnfs_export_operations {
 	int (*get_device_iter) (struct super_block *,
 				u32 layout_type,
 				struct nfsd4_pnfs_dev_iter_res *);
+
+	/* Retrieve and encode a layout for inode onto the xdr stream.
+	 * arg->minlength is the minimum number of accessible bytes required
+	 *   by the client.
+	 * The maximum number of bytes to encode the layout is given by
+	 *   the xdr stream end pointer.
+	 * arg->fsid contains the major part of struct pnfs_deviceid.
+	 *   The file system uses this to build the deviceid returned
+	 *   in the layout.
+	 * res->seg - layout segment requested and layout info returned.
+	 * res->fh can be modified the file handle for use on data servers
+	 * res->return_on_close - true if layout to be returned on file close
+	 *
+	 * return one of the following nfs errors:
+	 * NFS_OK			Success
+	 * NFS4ERR_ACCESS		Permission error
+	 * NFS4ERR_BADIOMODE		Server does not support requested iomode
+	 * NFS4ERR_BADLAYOUT		No layout matching loga_minlength rules
+	 * NFS4ERR_INVAL		Parameter other than layout is invalid
+	 * NFS4ERR_IO			I/O error
+	 * NFS4ERR_LAYOUTTRYLATER	Layout may be retrieved later
+	 * NFS4ERR_LAYOUTUNAVAILABLE	Layout unavailable for this file
+	 * NFS4ERR_LOCKED		Lock conflict
+	 * NFS4ERR_NOSPC		Out-of-space error occured
+	 * NFS4ERR_RECALLCONFLICT	Layout currently unavialable due to
+	 *				a conflicting CB_LAYOUTRECALL
+	 * NFS4ERR_SERVERFAULT		Server went bezerk
+	 * NFS4ERR_TOOSMALL		loga_maxcount too small to fit layout
+	 * NFS4ERR_WRONG_TYPE		Wrong file type (not a regular file)
+	 */
+	enum nfsstat4 (*layout_get) (struct inode *,
+				     struct exp_xdr_stream *xdr,
+				     const struct nfsd4_pnfs_layoutget_arg *,
+				     struct nfsd4_pnfs_layoutget_res *);
+
+	/* Can layout segments be merged for this layout type? */
+	int (*can_merge_layouts) (u32 layout_type);
 };
 
 #endif /* _LINUX_NFSD_NFSD4_PNFS_H */
-- 
1.8.3.1

