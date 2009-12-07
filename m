From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 13/35] pnfsd: layout get
Date: Mon,  7 Dec 2009 11:32:39 +0200
Message-ID: <1260178359-15111-1-git-send-email-bhalevy@panasas.com>
References: <4B1CCA52.8020900@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	linux-fsdevel@vger.kernel.org, Benny Halevy <bhalevy@panasas.com>,
	Dean Hildebrand <dhildeb@us.ibm.com>,
	Andy Adamson <andros@netapp.com>,
	Boaz Harrosh <bharrosh@panasas.com>
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:6388 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S934641AbZLGJbn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Dec 2009 04:31:43 -0500
In-Reply-To: <4B1CCA52.8020900@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, always return a single record in the log_layout array.

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
Signed-off-by: Andy Adamson<andros@netapp.com>
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
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/Makefile                |    1 +
 fs/nfsd/export.c                |    3 +-
 fs/nfsd/nfs4pnfsd.c             |  272 +++++++++++++++++++++++++++++++++++++++
 fs/nfsd/nfs4proc.c              |   53 ++++++++
 fs/nfsd/nfs4state.c             |   61 +++++----
 fs/nfsd/nfs4xdr.c               |  109 +++++++++++++++-
 fs/nfsd/pnfsd.h                 |   15 ++
 fs/nfsd/state.h                 |   50 +++++++
 fs/nfsd/xdr4.h                  |   11 ++
 include/linux/exportfs.h        |    3 +-
 include/linux/nfsd/nfsd4_pnfs.h |   50 +++++++
 11 files changed, 598 insertions(+), 30 deletions(-)
 create mode 100644 fs/nfsd/nfs4pnfsd.c

diff --git a/fs/nfsd/Makefile b/fs/nfsd/Makefile
index 9b118ee..4b4214c 100644
--- a/fs/nfsd/Makefile
+++ b/fs/nfsd/Makefile
@@ -11,3 +11,4 @@ nfsd-$(CONFIG_NFSD_V3)	+= nfs3proc.o nfs3xdr.o
 nfsd-$(CONFIG_NFSD_V3_ACL) += nfs3acl.o
 nfsd-$(CONFIG_NFSD_V4)	+= nfs4proc.o nfs4xdr.o nfs4state.o nfs4idmap.o \
 			   nfs4acl.o nfs4callback.o nfs4recover.o
+nfsd-$(CONFIG_PNFSD)	+= nfs4pnfsd.o
diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index d847dd2..217b226 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -399,7 +399,8 @@ static int check_export(struct inode *inode, int flags, unsigned char *uuid,
 
 	if (inode->i_sb->s_pnfs_op &&
 	    (!inode->i_sb->s_pnfs_op->layout_type ||
-	     !inode->i_sb->s_pnfs_op->get_device_info)) {
+	     !inode->i_sb->s_pnfs_op->get_device_info ||
+	     !inode->i_sb->s_pnfs_op->layout_get)) {
 		dprintk("exp_export: export of invalid fs pnfs export ops.\n");
 		return -EINVAL;
 	}
diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
new file mode 100644
index 0000000..b0794e3
--- /dev/null
+++ b/fs/nfsd/nfs4pnfsd.c
@@ -0,0 +1,272 @@
+/******************************************************************************
+ *
+ * (c) 2007 Network Appliance, Inc.  All Rights Reserved.
+ * (c) 2009 NetApp.  All Rights Reserved.
+ *
+ * NetApp provides this source code under the GPL v2 License.
+ * The GPL v2 license is available at
+ * http://opensource.org/licenses/gpl-license.php.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
+ * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
+ * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
+ * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
+ * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
+ * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
+ * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
+ * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
+ * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
+ * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
+ * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ *
+ *****************************************************************************/
+
+#include "pnfsd.h"
+
+#define NFSDDBG_FACILITY                NFSDDBG_PROC
+
+/*
+ * Layout state - NFSv4.1 pNFS
+ */
+static struct kmem_cache *pnfs_layout_slab;
+
+void
+nfsd4_free_pnfs_slabs(void)
+{
+	nfsd4_free_slab(&pnfs_layout_slab);
+}
+
+int
+nfsd4_init_pnfs_slabs(void)
+{
+	pnfs_layout_slab = kmem_cache_create("pnfs_layouts",
+			sizeof(struct nfs4_layout), 0, 0, NULL);
+	if (pnfs_layout_slab == NULL)
+		return -ENOMEM;
+	return 0;
+}
+
+static inline struct nfs4_layout *
+alloc_layout(void)
+{
+	return kmem_cache_alloc(pnfs_layout_slab, GFP_KERNEL);
+}
+
+static inline void
+free_layout(struct nfs4_layout *lp)
+{
+	kmem_cache_free(pnfs_layout_slab, lp);
+}
+
+static void
+init_layout(struct nfs4_layout *lp,
+	    struct nfs4_file *fp,
+	    struct nfs4_client *clp,
+	    struct svc_fh *current_fh,
+	    struct nfsd4_layout_seg *seg)
+{
+	dprintk("pNFS %s: lp %p clp %p fp %p ino %p\n", __func__,
+		lp, clp, fp, fp->fi_inode);
+
+	get_nfs4_file(fp);
+	lp->lo_client = clp;
+	lp->lo_file = fp;
+	memcpy(&lp->lo_seg, seg, sizeof(lp->lo_seg));
+	list_add_tail(&lp->lo_perclnt, &clp->cl_layouts);
+	list_add_tail(&lp->lo_perfile, &fp->fi_layouts);
+	dprintk("pNFS %s end\n", __func__);
+}
+
+/*
+ * are two octet ranges overlapping?
+ * start1            last1
+ *   |-----------------|
+ *                start2            last2
+ *                  |----------------|
+ */
+static inline int
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
+static inline int
+same_fsid_major(struct nfs4_fsid *fsid, u64 major)
+{
+	return fsid->major == major;
+}
+
+static inline int
+same_fsid(struct nfs4_fsid *fsid, struct svc_fh *current_fh)
+{
+	return same_fsid_major(fsid, current_fh->fh_export->ex_fsid);
+}
+
+/*
+ * are two octet ranges overlapping or adjacent?
+ */
+static inline int
+lo_seg_mergeable(struct nfsd4_layout_seg *l1, struct nfsd4_layout_seg *l2)
+{
+	u64 start1 = l1->offset;
+	u64 end1 = end_offset(start1, l1->length);
+	u64 start2 = l2->offset;
+	u64 end2 = end_offset(start2, l2->length);
+
+	/* is end1 == start2 ranges are adjacent */
+	return (end2 >= start1) && (end1 >= start2);
+}
+
+static void
+extend_layout(struct nfsd4_layout_seg *lo, struct nfsd4_layout_seg *lg)
+{
+	u64 lo_start = lo->offset;
+	u64 lo_end = end_offset(lo_start, lo->length);
+	u64 lg_start = lg->offset;
+	u64 lg_end = end_offset(lg_start, lg->length);
+
+	/* lo already covers lg? */
+	if (lo_start <= lg_start && lg_end <= lo_end)
+		return;
+
+	/* extend start offset */
+	if (lo_start > lg_start)
+		lo_start = lg_start;
+
+	/* extend end offset */
+	if (lo_end < lg_end)
+		lo_end = lg_end;
+
+	lo->offset = lo_start;
+	lo->length = (lo_end == NFS4_MAX_UINT64) ?
+		      lo_end : lo_end - lo_start;
+}
+
+static struct nfs4_layout *
+merge_layout(struct nfs4_file *fp,
+	     struct nfs4_client *clp,
+	     struct nfsd4_layout_seg *seg)
+{
+	struct nfs4_layout *lp = NULL;
+
+	list_for_each_entry (lp, &fp->fi_layouts, lo_perfile)
+		if (lp->lo_seg.layout_type == seg->layout_type &&
+		    lp->lo_seg.clientid == seg->clientid &&
+		    lp->lo_seg.iomode == seg->iomode &&
+		    lo_seg_mergeable(&lp->lo_seg, seg)) {
+			extend_layout(&lp->lo_seg, seg);
+			break;
+		}
+
+	return lp;
+}
+
+int
+nfs4_pnfs_get_layout(struct nfsd4_pnfs_layoutget *lgp,
+		     struct exp_xdr_stream *xdr)
+{
+	int status = nfserr_layouttrylater;
+	struct inode *ino = lgp->lg_fhp->fh_dentry->d_inode;
+	struct super_block *sb = ino->i_sb;
+	int can_merge;
+	struct nfs4_file *fp;
+	struct nfs4_client *clp;
+	struct nfs4_layout *lp = NULL;
+	struct nfsd4_pnfs_layoutget_arg args = {
+		.lg_minlength = lgp->lg_minlength,
+		.lg_fsid = lgp->lg_fhp->fh_export->ex_fsid,
+		.lg_fh = &lgp->lg_fhp->fh_handle,
+	};
+	struct nfsd4_pnfs_layoutget_res res = {
+		.lg_seg = lgp->lg_seg,
+	};
+
+	dprintk("NFSD: %s Begin\n", __func__);
+
+	can_merge = sb->s_pnfs_op->can_merge_layouts != NULL &&
+		    sb->s_pnfs_op->can_merge_layouts(lgp->lg_seg.layout_type);
+
+	nfs4_lock_state();
+	fp = find_alloc_file(ino, lgp->lg_fhp);
+	clp = find_confirmed_client((clientid_t *)&lgp->lg_seg.clientid);
+	dprintk("pNFS %s: fp %p clp %p \n", __func__, fp, clp);
+	if (!fp || !clp)
+		goto out;
+
+	/* pre-alloc layout in case we can't merge after we call
+	 * the file system
+	 */
+	lp = alloc_layout();
+	if (!lp)
+		goto out;
+
+	dprintk("pNFS %s: pre-export type 0x%x maxcount %Zd "
+		"iomode %u offset %llu length %llu\n",
+		__func__, lgp->lg_seg.layout_type,
+		exp_xdr_qbytes(xdr->end - xdr->p),
+		lgp->lg_seg.iomode, lgp->lg_seg.offset, lgp->lg_seg.length);
+
+	/* FIXME: need to eliminate the use of the state lock */
+	nfs4_unlock_state();
+	status = sb->s_pnfs_op->layout_get(ino, xdr, &args, &res);
+	nfs4_lock_state();
+
+	dprintk("pNFS %s: post-export status %d "
+		"iomode %u offset %llu length %llu\n",
+		__func__, status, res.lg_seg.iomode,
+		res.lg_seg.offset, res.lg_seg.length);
+
+	if (status) {
+		switch (status) {
+		case -ETOOSMALL:
+			status = nfserr_toosmall;
+			break;
+		case -ENOMEM:
+		case -EAGAIN:
+		case -EINTR:
+			status = nfserr_layouttrylater;
+			break;
+		case -ENOENT:
+			status = nfserr_badlayout;
+			break;
+		case -E2BIG:
+			status = nfserr_toosmall;
+			break;
+		default:
+			status = nfserr_layoutunavailable;
+		}
+		goto out_freelayout;
+	}
+
+	lgp->lg_seg = res.lg_seg;
+	lgp->lg_roc = res.lg_return_on_close;
+
+	/* SUCCESS!
+	 * Can the new layout be merged into an existing one?
+	 * If so, free unused layout struct
+	 */
+	if (can_merge && merge_layout(fp, clp, &res.lg_seg))
+		goto out_freelayout;
+
+	/* Can't merge, so let's initialize this new layout */
+	init_layout(lp, fp, clp, lgp->lg_fhp, &res.lg_seg);
+out:
+	if (fp)
+		put_nfs4_file(fp);
+	nfs4_unlock_state();
+	dprintk("pNFS %s: lp %p exit status %d\n", __func__, lp, status);
+	return status;
+out_freelayout:
+	free_layout(lp);
+	goto out;
+}
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 8f274bf..b7e910f 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1059,6 +1059,55 @@ out:
 		exp_put(exp);
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
+				     lgp->lg_seg.layout_type);
+	if (status)
+		goto out;
+
+	status = nfserr_inval;
+	if (lgp->lg_seg.iomode != IOMODE_READ &&
+	    lgp->lg_seg.iomode != IOMODE_RW &&
+	    lgp->lg_seg.iomode != IOMODE_ANY) {
+		dprintk("pNFS %s: invalid iomode %d\n", __func__,
+			lgp->lg_seg.iomode);
+		goto out;
+	}
+
+	status = nfserr_badiomode;
+	if (lgp->lg_seg.iomode == IOMODE_ANY) {
+		dprintk("pNFS %s: IOMODE_ANY is not allowed\n", __func__);
+		goto out;
+	}
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
@@ -1431,6 +1480,10 @@ static struct nfsd4_operation nfsd4_ops[] = {
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
index dc9d553..cea0edc 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -110,7 +110,7 @@ opaque_hashval(const void *ptr, int nbytes)
 
 static struct list_head del_recall_lru;
 
-static inline void
+inline void
 put_nfs4_file(struct nfs4_file *fi)
 {
 	if (atomic_dec_and_lock(&fi->fi_ref, &recall_lock)) {
@@ -121,7 +121,7 @@ put_nfs4_file(struct nfs4_file *fi)
 	}
 }
 
-static inline void
+inline void
 get_nfs4_file(struct nfs4_file *fi)
 {
 	atomic_inc(&fi->fi_ref);
@@ -846,6 +846,9 @@ static struct nfs4_client *create_client(struct xdr_netobj name, char *recdir,
 	INIT_LIST_HEAD(&clp->cl_strhash);
 	INIT_LIST_HEAD(&clp->cl_openowners);
 	INIT_LIST_HEAD(&clp->cl_delegations);
+#if defined(CONFIG_PNFSD)
+	INIT_LIST_HEAD(&clp->cl_layouts);
+#endif /* CONFIG_PNFSD */
 	INIT_LIST_HEAD(&clp->cl_sessions);
 	INIT_LIST_HEAD(&clp->cl_lru);
 	clear_bit(0, &clp->cl_cb_slot_busy);
@@ -896,7 +899,7 @@ move_to_confirmed(struct nfs4_client *clp)
 	renew_client(clp);
 }
 
-static struct nfs4_client *
+struct nfs4_client *
 find_confirmed_client(clientid_t *clid)
 {
 	struct nfs4_client *clp;
@@ -1709,7 +1712,7 @@ out:
 
 /* OPEN Share state helper functions */
 static inline struct nfs4_file *
-alloc_init_file(struct inode *ino)
+alloc_init_file(struct inode *ino, struct svc_fh *current_fh)
 {
 	struct nfs4_file *fp;
 	unsigned int hashval = file_hashval(ino);
@@ -1720,18 +1723,29 @@ alloc_init_file(struct inode *ino)
 		INIT_LIST_HEAD(&fp->fi_hash);
 		INIT_LIST_HEAD(&fp->fi_stateids);
 		INIT_LIST_HEAD(&fp->fi_delegations);
+#if defined(CONFIG_PNFSD)
+		INIT_LIST_HEAD(&fp->fi_layouts);
+#endif /* CONFIG_PNFSD */
 		spin_lock(&recall_lock);
 		list_add(&fp->fi_hash, &file_hashtbl[hashval]);
 		spin_unlock(&recall_lock);
 		fp->fi_inode = igrab(ino);
 		fp->fi_id = current_fileid++;
 		fp->fi_had_conflict = false;
+#if defined(CONFIG_PNFSD)
+		fp->fi_fsid.major = current_fh->fh_export->ex_fsid;
+		fp->fi_fsid.minor = 0;
+		fp->fi_fhlen = current_fh->fh_handle.fh_size;
+		BUG_ON(fp->fi_fhlen > sizeof(fp->fi_fhval));
+		memcpy(fp->fi_fhval, &current_fh->fh_handle.fh_base,
+		       fp->fi_fhlen);
+#endif /* CONFIG_PNFSD */
 		return fp;
 	}
 	return NULL;
 }
 
-static void
+void
 nfsd4_free_slab(struct kmem_cache **slab)
 {
 	if (*slab == NULL)
@@ -1747,6 +1761,7 @@ nfsd4_free_slabs(void)
 	nfsd4_free_slab(&file_slab);
 	nfsd4_free_slab(&stateid_slab);
 	nfsd4_free_slab(&deleg_slab);
+	nfsd4_free_pnfs_slabs();
 }
 
 static int
@@ -1768,6 +1783,8 @@ nfsd4_init_slabs(void)
 			sizeof(struct nfs4_delegation), 0, 0, NULL);
 	if (deleg_slab == NULL)
 		goto out_nomem;
+	if (nfsd4_init_pnfs_slabs())
+		goto out_nomem;
 	return 0;
 out_nomem:
 	nfsd4_free_slabs();
@@ -1908,6 +1925,18 @@ find_file(struct inode *ino)
 	return NULL;
 }
 
+struct nfs4_file *
+find_alloc_file(struct inode *ino, struct svc_fh *current_fh)
+{
+	struct nfs4_file *fp;
+
+	fp = find_file(ino);
+	if (fp)
+		return fp;
+
+	return alloc_init_file(ino, current_fh);
+}
+
 static inline int access_valid(u32 x, u32 minorversion)
 {
 	if ((x & NFS4_SHARE_ACCESS_MASK) < NFS4_SHARE_ACCESS_READ)
@@ -2465,7 +2494,7 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
 		if (open->op_claim_type == NFS4_OPEN_CLAIM_DELEGATE_CUR)
 			goto out;
 		status = nfserr_resource;
-		fp = alloc_init_file(ino);
+		fp = alloc_init_file(ino, current_fh);
 		if (fp == NULL)
 			goto out;
 	}
@@ -3216,26 +3245,6 @@ out:
 #define LOCK_HASH_SIZE             (1 << LOCK_HASH_BITS)
 #define LOCK_HASH_MASK             (LOCK_HASH_SIZE - 1)
 
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
-	BUG_ON(!len);
-	end = start + len;
-	return end > start ? end - 1: NFS4_MAX_UINT64;
-}
-
 #define lockownerid_hashval(id) \
         ((id) & LOCK_HASH_MASK)
 
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index a374b1c..949e92d 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -51,6 +51,7 @@
 
 #include "xdr4.h"
 #include "vfs.h"
+#include "pnfsd.h"
 
 #define NFSDDBG_FACILITY		NFSDDBG_XDR
 
@@ -1269,6 +1270,26 @@ nfsd4_decode_getdevinfo(struct nfsd4_compoundargs *argp,
 
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
@@ -1376,7 +1397,7 @@ static nfsd4_dec nfsd41_dec_ops[] = {
 	[OP_GETDEVICEINFO]	= (nfsd4_dec)nfsd4_decode_getdevinfo,
 	[OP_GETDEVICELIST]	= (nfsd4_dec)nfsd4_decode_getdevlist,
 	[OP_LAYOUTCOMMIT]	= (nfsd4_dec)nfsd4_decode_notsupp,
-	[OP_LAYOUTGET]		= (nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_LAYOUTGET]		= (nfsd4_dec)nfsd4_decode_layoutget,
 	[OP_LAYOUTRETURN]	= (nfsd4_dec)nfsd4_decode_notsupp,
 #else  /* CONFIG_PNFSD */
 	[OP_GETDEVICEINFO]	= (nfsd4_dec)nfsd4_decode_notsupp,
@@ -3307,6 +3328,90 @@ toosmall:
 	ADJUST_ARGS();
 	goto out;
 }
+
+static __be32
+nfsd4_encode_layoutget(struct nfsd4_compoundres *resp,
+		       int nfserr,
+		       struct nfsd4_pnfs_layoutget *lgp)
+{
+	int maxcount, leadcount;
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
+	maxcount -= leadcount;
+	if (maxcount < 0) {
+		printk(KERN_ERR "%s: buffer too small\n", __func__);
+		nfserr = nfserr_toosmall;
+		goto err;
+	}
+
+	/* Set xdr info so file system can encode layout */
+	xdr.p = p_save = resp->p;
+	xdr.end = resp->end;
+	if (xdr.end - xdr.p > exp_xdr_qwords(maxcount & ~3))
+		xdr.end = xdr.p + exp_xdr_qwords(maxcount & ~3);
+
+	/* Retrieve, encode, and merge layout */
+	nfserr = nfs4_pnfs_get_layout(lgp, &xdr);
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
@@ -3373,7 +3478,7 @@ static nfsd4_enc nfsd4_enc_ops[] = {
 	[OP_GETDEVICEINFO]	= (nfsd4_enc)nfsd4_encode_getdevinfo,
 	[OP_GETDEVICELIST]	= (nfsd4_enc)nfsd4_encode_getdevlist,
 	[OP_LAYOUTCOMMIT]	= (nfsd4_enc)nfsd4_encode_noop,
-	[OP_LAYOUTGET]		= (nfsd4_enc)nfsd4_encode_noop,
+	[OP_LAYOUTGET]		= (nfsd4_enc)nfsd4_encode_layoutget,
 	[OP_LAYOUTRETURN]	= (nfsd4_enc)nfsd4_encode_noop,
 #else  /* CONFIG_PNFSD */
 	[OP_GETDEVICEINFO]	= (nfsd4_enc)nfsd4_encode_noop,
diff --git a/fs/nfsd/pnfsd.h b/fs/nfsd/pnfsd.h
index 7c46791..04d713f 100644
--- a/fs/nfsd/pnfsd.h
+++ b/fs/nfsd/pnfsd.h
@@ -34,6 +34,21 @@
 #ifndef LINUX_NFSD_PNFSD_H
 #define LINUX_NFSD_PNFSD_H
 
+#include <linux/list.h>
 #include <linux/nfsd/nfsd4_pnfs.h>
 
+#include <state.h>
+#include <xdr4.h>
+
+/* outstanding layout */
+struct nfs4_layout {
+	struct list_head		lo_perfile;	/* hash by f_id */
+	struct list_head		lo_perclnt;	/* hash by clientid */
+	struct nfs4_file		*lo_file;	/* backpointer */
+	struct nfs4_client		*lo_client;
+	struct nfsd4_layout_seg 	lo_seg;
+};
+
+int nfs4_pnfs_get_layout(struct nfsd4_pnfs_layoutget *, struct exp_xdr_stream *);
+
 #endif /* LINUX_NFSD_PNFSD_H */
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 2af7568..44b25d2 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -230,6 +230,14 @@ struct nfs4_client {
 	struct svc_xprt		*cl_cb_xprt;	/* 4.1 callback transport */
 	struct rpc_wait_queue	cl_cb_waitq;	/* backchannel callers may */
 						/* wait here for slots */
+#if defined(CONFIG_PNFSD)
+	struct list_head	cl_layouts;	/* outstanding layouts */
+#endif /* CONFIG_PNFSD */
+};
+
+struct nfs4_fsid {
+	u64	major;
+	u64	minor;
 };
 
 /* struct nfs4_client_reset
@@ -318,10 +326,19 @@ struct nfs4_file {
 	struct list_head        fi_hash;    /* hash by "struct inode *" */
 	struct list_head        fi_stateids;
 	struct list_head	fi_delegations;
+#if defined(CONFIG_PNFSD)
+	struct list_head	fi_layouts;
+#endif /* CONFIG_PNFSD */
 	struct inode		*fi_inode;
 	u32                     fi_id;      /* used with stateowner->so_id 
 					     * for stateid_hashtbl hash */
 	bool			fi_had_conflict;
+#if defined(CONFIG_PNFSD)
+	/* used by layoutget / layoutrecall */
+	struct nfs4_fsid	fi_fsid;
+	u32			fi_fhlen;
+	u8			fi_fhval[NFS4_FHSIZE];
+#endif /* CONFIG_PNFSD */
 };
 
 /*
@@ -393,6 +410,19 @@ extern int nfs4_has_reclaimed_state(const char *name, bool use_exchange_id);
 extern void nfsd4_recdir_purge_old(void);
 extern int nfsd4_create_clid_dir(struct nfs4_client *clp);
 extern void nfsd4_remove_clid_dir(struct nfs4_client *clp);
+extern void nfsd4_free_slab(struct kmem_cache **);
+extern struct nfs4_file *find_alloc_file(struct inode *, struct svc_fh *);
+extern void put_nfs4_file(struct nfs4_file *);
+extern void get_nfs4_file(struct nfs4_file *);
+extern struct nfs4_client *find_confirmed_client(clientid_t *);
+
+#if defined(CONFIG_PNFSD)
+extern int nfsd4_init_pnfs_slabs(void);
+extern void nfsd4_free_pnfs_slabs(void);
+#else /* CONFIG_PNFSD */
+static inline void nfsd4_free_pnfs_slabs(void) {}
+static inline int nfsd4_init_pnfs_slabs(void) { return 0; }
+#endif /* CONFIG_PNFSD */
 
 static inline void
 nfs4_put_stateowner(struct nfs4_stateowner *so)
@@ -406,4 +436,24 @@ nfs4_get_stateowner(struct nfs4_stateowner *so)
 	kref_get(&so->so_ref);
 }
 
+static inline u64
+end_offset(u64 start, u64 len)
+{
+	u64 end;
+
+	end = start + len;
+	return end >= start ? end : NFS4_MAX_UINT64;
+}
+
+/* last octet in a range */
+static inline u64
+last_byte_offset(u64 start, u64 len)
+{
+	u64 end;
+
+	BUG_ON(!len);
+	end = start + len;
+	return end > start ? end - 1 : NFS4_MAX_UINT64;
+}
+
 #endif   /* NFSD4_STATE_H */
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index acb215a..891f3d2 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -401,6 +401,16 @@ struct nfsd4_pnfs_getdevlist {
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
@@ -444,6 +454,7 @@ struct nfsd4_op {
 #if defined(CONFIG_PNFSD)
 		struct nfsd4_pnfs_getdevlist	pnfs_getdevlist;
 		struct nfsd4_pnfs_getdevinfo	pnfs_getdevinfo;
+		struct nfsd4_pnfs_layoutget	pnfs_layoutget;
 #endif /* CONFIG_PNFSD */
 	} u;
 	struct nfs4_replay *			replay;
diff --git a/include/linux/exportfs.h b/include/linux/exportfs.h
index 4a763a1..97d99e1 100644
--- a/include/linux/exportfs.h
+++ b/include/linux/exportfs.h
@@ -177,6 +177,7 @@ struct pnfs_filelayout_layout;
 
 extern int filelayout_encode_devinfo(struct exp_xdr_stream *xdr,
 				     const struct pnfs_filelayout_device *fdev);
-
+extern int filelayout_encode_layout(struct exp_xdr_stream *xdr,
+				    const struct pnfs_filelayout_layout *flp);
 #endif /* defined(CONFIG_EXPORTFS_FILE_LAYOUT) */
 #endif /* LINUX_EXPORTFS_H */
diff --git a/include/linux/nfsd/nfsd4_pnfs.h b/include/linux/nfsd/nfsd4_pnfs.h
index d68fd14..be15b7f 100644
--- a/include/linux/nfsd/nfsd4_pnfs.h
+++ b/include/linux/nfsd/nfsd4_pnfs.h
@@ -49,6 +49,36 @@ struct nfsd4_pnfs_dev_iter_res {
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
+	u64			lg_fsid;
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
@@ -81,6 +111,26 @@ struct pnfs_export_operations {
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
+	 */
+	int (*layout_get) (struct inode *,
+			   struct exp_xdr_stream *xdr,
+			   const struct nfsd4_pnfs_layoutget_arg *,
+			   struct nfsd4_pnfs_layoutget_res *);
+
+	/* Can layout segments be merged for this layout type? */
+	int (*can_merge_layouts) (u32 layout_type);
 };
 
 #endif /* _LINUX_NFSD_NFSD4_PNFS_H */
-- 
1.6.5.1

