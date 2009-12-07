From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 33/35] pnfsd: layout commit
Date: Mon,  7 Dec 2009 11:37:06 +0200
Message-ID: <1260178626-16090-1-git-send-email-bhalevy@panasas.com>
References: <4B1CCA52.8020900@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	linux-fsdevel@vger.kernel.org, Benny Halevy <bhalevy@panasas.com>,
	Dean Hildebrand <seattleplus@gmail.com>,
	Dean Hildebrand <dhildeb@us.ibm.com>,
	Andy Adamson <andros@netapp.com>
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:6420 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S934928AbZLGJgK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Dec 2009 04:36:10 -0500
In-Reply-To: <4B1CCA52.8020900@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

[extracted from pnfsd: Initial pNFS server implementation.]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[pnfsd: Streamline error code checking for non-pnfs filesystems]
Signed-off-by: Dean Hildebrand <seattleplus@gmail.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[pnfsd: update server layout xdr for draft 19.]
Signed-off-by: Dean Hildebrand <dhildeb@us.ibm.com>
[pnfsd: use stateid_t for layout stateid xdr data structs]
[pnfsd: use stateid xdr decode function for layoutcommit]
[pnfsd: fix copy_clientid for layotucommit]
[pnfsd: convert generic code to use new pnfs api]
[pnfsd: define pnfs_export_operations]
[pnfsd: obliterate old vfs api]
[pnfsd: fixup ENCODE_HEAD for layoutcommit]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[pnfsd: layout commit all layout types]
Signed-off-by: Andy Adamson <andros@netapp.com>
[pnfsd: do not take the i_mutex when filesystem provides layout_commit]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[pnfsd: check ex_pnfs in nfsd4_verify_layout]
Signed-off-by: Andy Adamson <andros@netapp.com>
[pnfsd: fix cosmetic checkpatch warnings]
[pnfsd: clean up layoutcommit export api]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4proc.c              |   83 +++++++++++++++++++++++++++++++++++++++
 fs/nfsd/nfs4xdr.c               |   70 ++++++++++++++++++++++++++++++++-
 fs/nfsd/xdr4.h                  |    7 +++
 include/linux/nfsd/nfsd4_pnfs.h |   21 ++++++++++
 4 files changed, 179 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 0336037..d05e260 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1109,6 +1109,85 @@ nfsd4_layoutget(struct svc_rqst *rqstp,
 out:
 	return status;
 }
+
+static __be32
+nfsd4_layoutcommit(struct svc_rqst *rqstp,
+		struct nfsd4_compound_state *cstate,
+		struct nfsd4_pnfs_layoutcommit *lcp)
+{
+	int status;
+	struct inode *ino = NULL;
+	struct iattr ia;
+	struct super_block *sb;
+	struct svc_fh *current_fh = &cstate->current_fh;
+
+	dprintk("NFSD: nfsd4_layoutcommit \n");
+	status = fh_verify(rqstp, current_fh, 0, NFSD_MAY_NOP);
+	if (status)
+		goto out;
+
+	status = nfserr_inval;
+	ino = current_fh->fh_dentry->d_inode;
+	if (!ino)
+		goto out;
+
+	status = nfserr_inval;
+	sb = ino->i_sb;
+	if (!sb)
+		goto out;
+
+	/* Ensure underlying file system supports pNFS and,
+	 * if so, the requested layout type
+	 */
+	status = nfsd4_layout_verify(sb, current_fh->fh_export,
+				     lcp->args.lc_seg.layout_type);
+	if (status)
+		goto out;
+
+	/* This will only extend the file length.  Do a quick
+	 * check to see if there is any point in waiting for the update
+	 * locks.
+	 * TODO: Is this correct for all back ends?
+	 */
+	dprintk("%s:new offset: %d new size: %llu old size: %lld\n",
+		__func__, lcp->args.lc_newoffset, lcp->args.lc_last_wr + 1,
+		ino->i_size);
+
+	/* Set clientid from sessionid */
+	copy_clientid((clientid_t *)&lcp->args.lc_seg.clientid, cstate->session);
+	lcp->res.lc_size_chg = 0;
+	if (sb->s_pnfs_op->layout_commit) {
+		status = sb->s_pnfs_op->layout_commit(ino, &lcp->args, &lcp->res);
+		dprintk("%s:layout_commit result %d\n", __func__, status);
+	} else {
+		fh_lock(current_fh);
+		if ((lcp->args.lc_newoffset == 0) ||
+		    ((lcp->args.lc_last_wr + 1) <= ino->i_size)) {
+			status = 0;
+			lcp->res.lc_size_chg = 0;
+			fh_unlock(current_fh);
+			goto out;
+		}
+
+		/* Try our best to update the file size */
+		dprintk("%s: Modifying file size\n", __func__);
+		ia.ia_valid = ATTR_SIZE;
+		ia.ia_size = lcp->args.lc_last_wr + 1;
+		status = notify_change(current_fh->fh_dentry, &ia);
+		fh_unlock(current_fh);
+		dprintk("%s:notify_change result %d\n", __func__, status);
+	}
+
+	if (!status && lcp->res.lc_size_chg &&
+	    EX_ISSYNC(current_fh->fh_export)) {
+		dprintk("%s: Synchronously writing inode size %llu\n",
+			__func__, ino->i_size);
+		write_inode_now(ino, 1);
+		lcp->res.lc_newsize = i_size_read(ino);
+	}
+out:
+	return status;
+}
 #endif /* CONFIG_PNFSD */
 
 /*
@@ -1485,6 +1564,10 @@ static struct nfsd4_operation nfsd4_ops[] = {
 		.op_func = (nfsd4op_func)nfsd4_layoutget,
 		.op_name = "OP_LAYOUTGET",
 	},
+	[OP_LAYOUTCOMMIT] = {
+		.op_func = (nfsd4op_func)nfsd4_layoutcommit,
+		.op_name = "OP_LAYOUTCOMMIT",
+	},
 #endif /* CONFIG_PNFSD */
 };
 
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 40c794a..96f6567 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1290,6 +1290,51 @@ nfsd4_decode_layoutget(struct nfsd4_compoundargs *argp,
 
 	DECODE_TAIL;
 }
+
+static __be32
+nfsd4_decode_layoutcommit(struct nfsd4_compoundargs *argp,
+			  struct nfsd4_pnfs_layoutcommit *lcp)
+{
+	DECODE_HEAD;
+	u32 timechange;
+
+	READ_BUF(20);
+	READ64(lcp->args.lc_seg.offset);
+	READ64(lcp->args.lc_seg.length);
+	READ32(lcp->args.lc_reclaim);
+	nfsd4_decode_stateid(argp, &lcp->lc_sid);
+	READ_BUF(4);
+	READ32(lcp->args.lc_newoffset);
+	if (lcp->args.lc_newoffset) {
+		READ_BUF(8);
+		READ64(lcp->args.lc_last_wr);
+	} else
+		lcp->args.lc_last_wr = 0;
+	READ_BUF(4);
+	READ32(timechange);
+	if (timechange) {
+		READ_BUF(12);
+		READ64(lcp->args.lc_mtime.seconds);
+		READ32(lcp->args.lc_mtime.nseconds);
+	} else {
+		lcp->args.lc_mtime.seconds = 0;
+		lcp->args.lc_mtime.nseconds = 0;
+	}
+	READ_BUF(8);
+	READ32(lcp->args.lc_seg.layout_type);
+	/* XXX: saving XDR'ed layout update. Since we don't have the
+	 * current_fh yet, and therefore no export_ops, we can't call
+	 * the layout specific decode routines. File and pVFS2
+	 * do not use the layout update....
+	 */
+	READ32(lcp->args.lc_up_len);
+	if (lcp->args.lc_up_len > 0) {
+		READ_BUF(lcp->args.lc_up_len);
+		READMEM(lcp->args.lc_up_layout, lcp->args.lc_up_len);
+	}
+
+	DECODE_TAIL;
+}
 #endif /* CONFIG_PNFSD */
 
 static __be32
@@ -1396,7 +1441,7 @@ static nfsd4_dec nfsd41_dec_ops[] = {
 #if defined(CONFIG_PNFSD)
 	[OP_GETDEVICEINFO]	= (nfsd4_dec)nfsd4_decode_getdevinfo,
 	[OP_GETDEVICELIST]	= (nfsd4_dec)nfsd4_decode_getdevlist,
-	[OP_LAYOUTCOMMIT]	= (nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_LAYOUTCOMMIT]	= (nfsd4_dec)nfsd4_decode_layoutcommit,
 	[OP_LAYOUTGET]		= (nfsd4_dec)nfsd4_decode_layoutget,
 	[OP_LAYOUTRETURN]	= (nfsd4_dec)nfsd4_decode_notsupp,
 #else  /* CONFIG_PNFSD */
@@ -3436,6 +3481,27 @@ err:
 	resp->p = p_start;
 	return nfserr;
 }
+
+static __be32
+nfsd4_encode_layoutcommit(struct nfsd4_compoundres *resp, int nfserr,
+			  struct nfsd4_pnfs_layoutcommit *lcp)
+{
+	__be32 *p;
+
+	if (nfserr)
+		goto out;
+
+	RESERVE_SPACE(4);
+	WRITE32(lcp->res.lc_size_chg);
+	ADJUST_ARGS();
+	if (lcp->res.lc_size_chg) {
+		RESERVE_SPACE(8);
+		WRITE64(lcp->res.lc_newsize);
+		ADJUST_ARGS();
+	}
+out:
+	return nfserr;
+}
 #endif /* CONFIG_PNFSD */
 
 static __be32
@@ -3501,7 +3567,7 @@ static nfsd4_enc nfsd4_enc_ops[] = {
 #if defined(CONFIG_PNFSD)
 	[OP_GETDEVICEINFO]	= (nfsd4_enc)nfsd4_encode_getdevinfo,
 	[OP_GETDEVICELIST]	= (nfsd4_enc)nfsd4_encode_getdevlist,
-	[OP_LAYOUTCOMMIT]	= (nfsd4_enc)nfsd4_encode_noop,
+	[OP_LAYOUTCOMMIT]	= (nfsd4_enc)nfsd4_encode_layoutcommit,
 	[OP_LAYOUTGET]		= (nfsd4_enc)nfsd4_encode_layoutget,
 	[OP_LAYOUTRETURN]	= (nfsd4_enc)nfsd4_encode_noop,
 #else  /* CONFIG_PNFSD */
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index 891f3d2..19a94e2 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -411,6 +411,12 @@ struct nfsd4_pnfs_layoutget {
 	u32			lg_roc;		/* response */
 };
 
+struct nfsd4_pnfs_layoutcommit {
+	struct nfsd4_pnfs_layoutcommit_arg args;
+	stateid_t		lc_sid;		/* request */
+	struct nfsd4_pnfs_layoutcommit_res res;
+};
+
 struct nfsd4_op {
 	int					opnum;
 	__be32					status;
@@ -455,6 +461,7 @@ struct nfsd4_op {
 		struct nfsd4_pnfs_getdevlist	pnfs_getdevlist;
 		struct nfsd4_pnfs_getdevinfo	pnfs_getdevinfo;
 		struct nfsd4_pnfs_layoutget	pnfs_layoutget;
+		struct nfsd4_pnfs_layoutcommit	pnfs_layoutcommit;
 #endif /* CONFIG_PNFSD */
 	} u;
 	struct nfs4_replay *			replay;
diff --git a/include/linux/nfsd/nfsd4_pnfs.h b/include/linux/nfsd/nfsd4_pnfs.h
index b80ff01..69c43f6 100644
--- a/include/linux/nfsd/nfsd4_pnfs.h
+++ b/include/linux/nfsd/nfsd4_pnfs.h
@@ -36,6 +36,7 @@
 
 #include <linux/exportfs.h>
 #include <linux/exp_xdr.h>
+#include <linux/nfs_xdr.h>
 #include <linux/nfsd/nfsfh.h>
 
 struct nfsd4_pnfs_deviceid {
@@ -80,6 +81,21 @@ struct nfsd4_pnfs_layoutget_res {
 	u32			lg_return_on_close;
 };
 
+struct nfsd4_pnfs_layoutcommit_arg {
+	struct nfsd4_layout_seg	lc_seg;		/* request */
+	u32			lc_reclaim;	/* request */
+	u32			lc_newoffset;	/* request */
+	u64			lc_last_wr;	/* request */
+	struct nfstime4		lc_mtime;	/* request */
+	u32			lc_up_len;	/* layout length */
+	void			*lc_up_layout;	/* decoded by callback */
+};
+
+struct nfsd4_pnfs_layoutcommit_res {
+	u32			lc_size_chg;	/* boolean for response */
+	u64			lc_newsize;	/* response */
+};
+
 /*
  * pNFS export operations vector.
  *
@@ -130,6 +146,11 @@ struct pnfs_export_operations {
 			   const struct nfsd4_pnfs_layoutget_arg *,
 			   struct nfsd4_pnfs_layoutget_res *);
 
+	/* Commit changes to layout */
+	int (*layout_commit) (struct inode *,
+			      const struct nfsd4_pnfs_layoutcommit_arg *,
+			      struct nfsd4_pnfs_layoutcommit_res *);
+
 	/* Can layout segments be merged for this layout type? */
 	int (*can_merge_layouts) (u32 layout_type);
 };
-- 
1.6.5.1

