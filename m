From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 34/35] pnfsd: layout return
Date: Mon,  7 Dec 2009 11:37:19 +0200
Message-ID: <1260178639-16126-1-git-send-email-bhalevy@panasas.com>
References: <4B1CCA52.8020900@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	linux-fsdevel@vger.kernel.org, Benny Halevy <bhalevy@panasas.com>,
	Andy Adamson <andros@umich.edu>, Mike Sager <sager@netapp.com>,
	Marc Eshel <eshel@almaden.ibm.com>,
	Dean Hildebrand <dhildeb@us.ibm.com>,
	Andy Adamson <andros@netapp.com>,
	Boaz Harrosh <bharrosh@panasas.com>
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:15674 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S934934AbZLGJgY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Dec 2009 04:36:24 -0500
In-Reply-To: <4B1CCA52.8020900@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Split pnfs_return_layout return file/{fsid,all} loops
into sub-functions in preparation for NFS4ERR_NOMATCHING_LAYOUT
error handling.

[extracted from pnfsd: Initial pNFS server implementation.]
[pnfsd: nfsd layout cache: layout return changes]
Signed-off-by: Benny Halevy <bhalevy at panasas.com>
Signed-off-by: Andy Adamson <andros@umich.edu>
Signed-off-by: Mike Sager <sager@netapp.com>
[pnfsd: fix bug in return_layout for RETURN_FILE]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[pnfsd: exit from nfs4_pnfs_return_layout without unlocking]
Signed-off-by: Marc Eshel <eshel@almaden.ibm.com>
[pnfsd: add debug printouts in return_layout path]
[pnfsd: refactor return_layout]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[pnfsd: Streamline error code checking for non-pnfs filesystems]
[pnfsd: update server layout xdr for draft 19.]
Signed-off-by: Dean Hildebrand <dhildeb@us.ibm.com>
[pnfsd: fix bug nfsd4_encode_layoutreturn]
[pnfsd: nfsd4_encode_layoutreturn needs ADJUST_ARGS when encoding response stateid]
[pnfsd: use stateid_t for layout stateid xdr data structs]
[pnfsd: layoutreturn optional stateid in response only for RETURN_FILE]
[pnfsd: decode opaque lrf_body in layoutreturn draft-19]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[pnfsd: reset recall flags]
Signed-off-by: Marc Eshel <eshel@almaden.ibm.com>
[pnfsd: handle RETURN_{FSID,ALL} with no nfs4_file]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[pnfsd: test and fix layout return]
Signed-off-by: Marc Eshel <eshel@almaden.ibm.com>
[pnfsd: Fixes in nfs4_pnfs_return_layout]
Signed-off-by: Dean Hildebrand <dhildeb@us.ibm.com>
[pnfsd: use stateid xdr {en,de}code functions for layoutreturn]
[pnfsd: fix copy_clientid for layoutreturn]
[pnfsd: convert generic code to use new pnfs api]
[pnfsd: define pnfs_export_operations]
[pnfsd: obliterate old vfs api]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Signed-off-by: Andy Adamson <andros@netapp.com>
[pnfsd: fixup ENCODE_HEAD for layoutreturn]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[pnfsd: set lrs_present to false on final layout return]
[Moved pnfsd code from nfs4state.c to nfs4pnfsd.c]
Signed-off-by: Andy Adamson <andros@netapp.com>
[pnfsd: use a spinlock for layout state]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[pnfsd: layout return all layout types]
Signed-off-by: Andy Adamson <andros@netapp.com>
[pnfsd: layout_return hint PART 01]
Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
[pnfsd: check ex_pnfs in nfsd4_verify_layout]
Signed-off-by: Andy Adamson <andros@netapp.com>
[pnfsd: fix cosmetic checkpatch warnings]
[pnfsd: clean up layoutreturn export API]
[moved find_file into RETURN_FILE condition]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4pnfsd.c             |  176 +++++++++++++++++++++++++++++++++++++++
 fs/nfsd/nfs4proc.c              |   58 +++++++++++++
 fs/nfsd/nfs4state.c             |    2 +-
 fs/nfsd/nfs4xdr.c               |   49 ++++++++++-
 fs/nfsd/pnfsd.h                 |    2 +
 fs/nfsd/state.h                 |    1 +
 fs/nfsd/xdr4.h                  |   12 +++
 include/linux/nfsd/nfsd4_pnfs.h |   15 ++++
 8 files changed, 312 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
index f475b3c..ba3d96f 100644
--- a/fs/nfsd/nfs4pnfsd.c
+++ b/fs/nfsd/nfs4pnfsd.c
@@ -351,6 +351,29 @@ destroy_layout(struct nfs4_layout *lp)
 	put_nfs4_file(fp);
 }
 
+void fs_layout_return(struct super_block *sb, struct inode *ino,
+		      struct nfsd4_pnfs_layoutreturn *lrp, int flags,
+		      void *recall_cookie)
+{
+	int ret;
+
+	if (unlikely(!sb->s_pnfs_op->layout_return))
+		return;
+
+	lrp->lr_flags = flags;
+	lrp->args.lr_cookie = recall_cookie;
+
+	if (!ino) /* FSID or ALL */
+		ino = sb->s_root->d_inode;
+
+	ret = sb->s_pnfs_op->layout_return(ino, &lrp->args);
+	dprintk("%s: inode %lu iomode=%d offset=0x%llx length=0x%llx "
+		"cookie = %p flags 0x%x status=%d\n",
+		__func__, ino->i_ino, lrp->args.lr_seg.iomode,
+		lrp->args.lr_seg.offset, lrp->args.lr_seg.length,
+		recall_cookie, flags, ret);
+}
+
 /*
  * are two octet ranges overlapping?
  * start1            last1
@@ -555,6 +578,159 @@ out_freelayout:
 	goto out;
 }
 
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
+static int
+pnfs_return_file_layouts(struct nfs4_client *clp, struct nfs4_file *fp,
+			 struct nfsd4_pnfs_layoutreturn *lrp)
+{
+	int layouts_found = 0;
+	struct nfs4_layout *lp, *nextlp;
+
+	dprintk("%s: clp %p fp %p\n", __func__, clp, fp);
+	spin_lock(&layout_lock);
+	list_for_each_entry_safe (lp, nextlp, &fp->fi_layouts, lo_perfile) {
+		dprintk("%s: lp %p client %p,%p lo_type %x,%x iomode %d,%d\n",
+			__func__, lp,
+			lp->lo_client, clp,
+			lp->lo_seg.layout_type, lrp->args.lr_seg.layout_type,
+			lp->lo_seg.iomode, lrp->args.lr_seg.iomode);
+		if (lp->lo_client != clp ||
+		    lp->lo_seg.layout_type != lrp->args.lr_seg.layout_type ||
+		    (lp->lo_seg.iomode != lrp->args.lr_seg.iomode &&
+		     lrp->args.lr_seg.iomode != IOMODE_ANY) ||
+		     !lo_seg_overlapping(&lp->lo_seg, &lrp->args.lr_seg))
+			continue;
+		layouts_found++;
+		trim_layout(&lp->lo_seg, &lrp->args.lr_seg);
+		if (!lp->lo_seg.length) {
+			lrp->lrs_present = 0;
+			destroy_layout(lp);
+		}
+	}
+	spin_unlock(&layout_lock);
+
+	return layouts_found;
+}
+
+static int
+pnfs_return_client_layouts(struct nfs4_client *clp,
+			   struct nfsd4_pnfs_layoutreturn *lrp, u64 ex_fsid)
+{
+	int layouts_found = 0;
+	struct nfs4_layout *lp, *nextlp;
+
+	spin_lock(&layout_lock);
+	list_for_each_entry_safe (lp, nextlp, &clp->cl_layouts, lo_perclnt) {
+		if (lrp->args.lr_seg.layout_type != lp->lo_seg.layout_type ||
+		   (lrp->args.lr_seg.iomode != lp->lo_seg.iomode &&
+		    lrp->args.lr_seg.iomode != IOMODE_ANY))
+			continue;
+
+		if (lrp->args.lr_return_type == RETURN_FSID &&
+		    !same_fsid_major(&lp->lo_file->fi_fsid, ex_fsid))
+			continue;
+
+		layouts_found++;
+		destroy_layout(lp);
+	}
+	spin_unlock(&layout_lock);
+
+	return layouts_found;
+}
+
+int nfs4_pnfs_return_layout(struct super_block *sb, struct svc_fh *current_fh,
+			    struct nfsd4_pnfs_layoutreturn *lrp)
+{
+	int status = 0;
+	int layouts_found = 0;
+	struct inode *ino = current_fh->fh_dentry->d_inode;
+	struct nfs4_file *fp = NULL;
+	struct nfs4_client *clp;
+	u64 ex_fsid = current_fh->fh_export->ex_fsid;
+	void *recall_cookie = NULL;
+
+	dprintk("NFSD: %s\n", __func__);
+
+	nfs4_lock_state();
+	clp = find_confirmed_client((clientid_t *)&lrp->args.lr_seg.clientid);
+	if (!clp)
+		goto out;
+
+	if (lrp->args.lr_return_type == RETURN_FILE) {
+		fp = find_file(ino);
+		if (!fp) {
+			printk(KERN_ERR "%s: RETURN_FILE: no nfs4_file for "
+				"ino %p:%lu\n",
+				__func__, ino, ino ? ino->i_ino : 0L);
+			goto out;
+		}
+
+		/* update layouts */
+		layouts_found = pnfs_return_file_layouts(clp, fp, lrp);
+		/* optimize for the all-empty case */
+		if (list_empty(&fp->fi_layouts))
+			recall_cookie = PNFS_LAST_LAYOUT_NO_RECALLS;
+	} else {
+		layouts_found = pnfs_return_client_layouts(clp, lrp, ex_fsid);
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
+	if (fp)
+		put_nfs4_file(fp);
+out:
+	nfs4_unlock_state();
+
+	/* call exported filesystem layout_return (ignore return-code) */
+	fs_layout_return(sb, ino, lrp, 0, recall_cookie);
+
+	dprintk("pNFS %s: exit status %d \n", __func__, status);
+	return status;
+}
+
 void pnfs_expire_client(struct nfs4_client *clp)
 {
 	struct nfs4_layout *lp;
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index d05e260..b4c3ff2 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1188,6 +1188,60 @@ nfsd4_layoutcommit(struct svc_rqst *rqstp,
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
+	copy_clientid((clientid_t *)&lrp->args.lr_seg.clientid, cstate->session);
+	lrp->lrs_present = (lrp->args.lr_return_type == RETURN_FILE);
+	status = nfs4_pnfs_return_layout(sb, current_fh, lrp);
+out:
+	dprintk("pNFS %s: status %d return_type 0x%x lrs_present %d\n",
+		__func__, status, lrp->args.lr_return_type, lrp->lrs_present);
+	return status;
+}
 #endif /* CONFIG_PNFSD */
 
 /*
@@ -1568,6 +1622,10 @@ static struct nfsd4_operation nfsd4_ops[] = {
 		.op_func = (nfsd4op_func)nfsd4_layoutcommit,
 		.op_name = "OP_LAYOUTCOMMIT",
 	},
+	[OP_LAYOUTRETURN] = {
+		.op_func = (nfsd4op_func)nfsd4_layoutreturn,
+		.op_name = "OP_LAYOUTRETURN",
+	},
 #endif /* CONFIG_PNFSD */
 };
 
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 1833ddf..108cb3e 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1909,7 +1909,7 @@ find_openstateowner_str(unsigned int hashval, struct nfsd4_open *open)
 }
 
 /* search file_hashtbl[] for file */
-static struct nfs4_file *
+struct nfs4_file *
 find_file(struct inode *ino)
 {
 	unsigned int hashval = file_hashval(ino);
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 96f6567..238ff6a 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1335,6 +1335,33 @@ nfsd4_decode_layoutcommit(struct nfsd4_compoundargs *argp,
 
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
+		nfsd4_decode_stateid(argp, &lrp->lr_sid);
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
@@ -1443,7 +1470,7 @@ static nfsd4_dec nfsd41_dec_ops[] = {
 	[OP_GETDEVICELIST]	= (nfsd4_dec)nfsd4_decode_getdevlist,
 	[OP_LAYOUTCOMMIT]	= (nfsd4_dec)nfsd4_decode_layoutcommit,
 	[OP_LAYOUTGET]		= (nfsd4_dec)nfsd4_decode_layoutget,
-	[OP_LAYOUTRETURN]	= (nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_LAYOUTRETURN]	= (nfsd4_dec)nfsd4_decode_layoutreturn,
 #else  /* CONFIG_PNFSD */
 	[OP_GETDEVICEINFO]	= (nfsd4_dec)nfsd4_decode_notsupp,
 	[OP_GETDEVICELIST]	= (nfsd4_dec)nfsd4_decode_notsupp,
@@ -3502,6 +3529,24 @@ nfsd4_encode_layoutcommit(struct nfsd4_compoundres *resp, int nfserr,
 out:
 	return nfserr;
 }
+
+static __be32
+nfsd4_encode_layoutreturn(struct nfsd4_compoundres *resp, int nfserr,
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
+		nfsd4_encode_stateid(resp, &lrp->lr_sid);
+out:
+	return nfserr;
+}
 #endif /* CONFIG_PNFSD */
 
 static __be32
@@ -3569,7 +3614,7 @@ static nfsd4_enc nfsd4_enc_ops[] = {
 	[OP_GETDEVICELIST]	= (nfsd4_enc)nfsd4_encode_getdevlist,
 	[OP_LAYOUTCOMMIT]	= (nfsd4_enc)nfsd4_encode_layoutcommit,
 	[OP_LAYOUTGET]		= (nfsd4_enc)nfsd4_encode_layoutget,
-	[OP_LAYOUTRETURN]	= (nfsd4_enc)nfsd4_encode_noop,
+	[OP_LAYOUTRETURN]	= (nfsd4_enc)nfsd4_encode_layoutreturn,
 #else  /* CONFIG_PNFSD */
 	[OP_GETDEVICEINFO]	= (nfsd4_enc)nfsd4_encode_noop,
 	[OP_GETDEVICELIST]	= (nfsd4_enc)nfsd4_encode_noop,
diff --git a/fs/nfsd/pnfsd.h b/fs/nfsd/pnfsd.h
index 523b149..96000f1 100644
--- a/fs/nfsd/pnfsd.h
+++ b/fs/nfsd/pnfsd.h
@@ -62,5 +62,7 @@ struct nfs4_layout {
 };
 
 int nfs4_pnfs_get_layout(struct nfsd4_pnfs_layoutget *, struct exp_xdr_stream *);
+int nfs4_pnfs_return_layout(struct super_block *, struct svc_fh *,
+					struct nfsd4_pnfs_layoutreturn *);
 
 #endif /* LINUX_NFSD_PNFSD_H */
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 9f68fd2..3da4be4 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -412,6 +412,7 @@ extern void nfsd4_recdir_purge_old(void);
 extern int nfsd4_create_clid_dir(struct nfs4_client *clp);
 extern void nfsd4_remove_clid_dir(struct nfs4_client *clp);
 extern void nfsd4_free_slab(struct kmem_cache **);
+extern struct nfs4_file *find_file(struct inode *);
 extern struct nfs4_file *find_alloc_file(struct inode *, struct svc_fh *);
 extern void put_nfs4_file(struct nfs4_file *);
 extern void get_nfs4_file(struct nfs4_file *);
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index 19a94e2..b72bfd4 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -417,6 +417,17 @@ struct nfsd4_pnfs_layoutcommit {
 	struct nfsd4_pnfs_layoutcommit_res res;
 };
 
+enum layoutreturn_flags {
+	LR_FLAG_INTERN = 1 << 0,	/* internal return */
+};
+
+struct nfsd4_pnfs_layoutreturn {
+	struct nfsd4_pnfs_layoutreturn_arg args;
+	u32			lr_flags;
+	stateid_t		lr_sid;		/* request/resopnse */
+	u32			lrs_present;	/* response */
+};
+
 struct nfsd4_op {
 	int					opnum;
 	__be32					status;
@@ -462,6 +473,7 @@ struct nfsd4_op {
 		struct nfsd4_pnfs_getdevinfo	pnfs_getdevinfo;
 		struct nfsd4_pnfs_layoutget	pnfs_layoutget;
 		struct nfsd4_pnfs_layoutcommit	pnfs_layoutcommit;
+		struct nfsd4_pnfs_layoutreturn	pnfs_layoutreturn;
 #endif /* CONFIG_PNFSD */
 	} u;
 	struct nfs4_replay *			replay;
diff --git a/include/linux/nfsd/nfsd4_pnfs.h b/include/linux/nfsd/nfsd4_pnfs.h
index 69c43f6..be17aa6 100644
--- a/include/linux/nfsd/nfsd4_pnfs.h
+++ b/include/linux/nfsd/nfsd4_pnfs.h
@@ -96,6 +96,17 @@ struct nfsd4_pnfs_layoutcommit_res {
 	u64			lc_newsize;	/* response */
 };
 
+#define PNFS_LAST_LAYOUT_NO_RECALLS ((void *)-1) /* used with lr_cookie below */
+
+struct nfsd4_pnfs_layoutreturn_arg {
+	u32			lr_return_type;	/* request */
+	struct nfsd4_layout_seg	lr_seg;		/* request */
+	u32			lr_reclaim;	/* request */
+	u32			lrf_body_len;	/* request */
+	void			*lrf_body;	/* request */
+	void			*lr_cookie;	/* fs private */
+};
+
 /*
  * pNFS export operations vector.
  *
@@ -151,6 +162,10 @@ struct pnfs_export_operations {
 			      const struct nfsd4_pnfs_layoutcommit_arg *,
 			      struct nfsd4_pnfs_layoutcommit_res *);
 
+	/* Returns the layout */
+	int (*layout_return) (struct inode *,
+			      const struct nfsd4_pnfs_layoutreturn_arg *);
+
 	/* Can layout segments be merged for this layout type? */
 	int (*can_merge_layouts) (u32 layout_type);
 };
-- 
1.6.5.1

