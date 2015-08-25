Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:33875 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932757AbbHYPfq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Aug 2015 11:35:46 -0400
Received: by pabzx8 with SMTP id zx8so36960996pab.1
        for <linux-nfs@vger.kernel.org>; Tue, 25 Aug 2015 08:35:46 -0700 (PDT)
From: Peng Tao <tao.peng@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Christoph Hellwig <hch@infradead.org>, Zach Brown <zab@zabbo.net>,
        Darren Hart <dvhart@linux.intel.com>, bfields@fieldses.org,
        Jeff Layton <jeff.layton@primarydata.com>,
        Anna Schumaker <bjschuma@netapp.com>, Christoph Hellwig <hch@lst.de>,
        Peng Tao <tao.peng@primarydata.com>
Subject: [PATCH RFC 11/11] NFSD: Implement the CLONE call
Date: Tue, 25 Aug 2015 23:33:49 +0800
Message-Id: <1440516829-116041-12-git-send-email-tao.peng@primarydata.com>
In-Reply-To: <1440516829-116041-1-git-send-email-tao.peng@primarydata.com>
References: <1440516829-116041-1-git-send-email-tao.peng@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <bjschuma@netapp.com>

I can simply call vfs_file_clone_range() and have the vfs do the
right thing for the filesystem being exported.

Signed-off-by: Anna Schumaker <bjschuma@netapp.com>
[hch: change to implement the CLONE op instead of COPY]
Signed-off-by: Christoph Hellwig <hch@lst.de>
Signed-off-by: Peng Tao <tao.peng@primarydata.com>
---
 fs/nfsd/nfs4proc.c   | 79 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfsd/nfs4xdr.c    | 21 ++++++++++++++
 fs/nfsd/vfs.c        |  7 +++++
 fs/nfsd/vfs.h        |  1 +
 fs/nfsd/xdr4.h       | 10 +++++++
 include/linux/nfs4.h |  4 +--
 6 files changed, 120 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index d34c967..c2d3558 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1014,6 +1014,79 @@ nfsd4_write(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 }
 
 static __be32
+nfsd4_verify_clone(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
+		  struct nfsd4_clone *clone, struct file **src, struct file **dst)
+{
+	struct inode *src_ino, *dst_ino;
+	__be32 status;
+
+	status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->save_fh,
+					    &clone->cl_src_stateid, RD_STATE,
+					    src, NULL);
+	if (status) {
+		dprintk("NFSD: %s: couldn't process src stateid!\n", __func__);
+		return status;
+	}
+
+	status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->current_fh,
+					    &clone->cl_dst_stateid, WR_STATE,
+					    dst, NULL);
+	if (status) {
+		dprintk("NFSD: %s: couldn't process dst stateid!\n", __func__);
+		fput(*src);
+	}
+
+	/* a few extra check to make sure we send back proper errors per RFC */
+	src_ino = file_inode(*src);
+	dst_ino = file_inode(*dst);
+
+        if (S_ISDIR(src_ino->i_mode) || S_ISDIR(dst_ino->i_mode)) {
+		status = nfserr_wrong_type;
+		goto out_fput;
+	}
+
+	if (src_ino == dst_ino) {
+		status = nfserr_inval;
+		goto out_fput;
+	}
+
+	if (!(*src)->f_op || !(*src)->f_op->clone_range) {
+		status = nfserr_notsupp;
+		goto out_fput;
+	}
+out:
+	return status;
+out_fput:
+	fput(*src);
+	fput(*dst);
+	goto out;
+}
+
+static __be32
+nfsd4_clone(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
+		struct nfsd4_clone *clone)
+{
+	int ret;
+	__be32 status;
+	struct file *src = NULL, *dst = NULL;
+
+	status = nfsd4_verify_clone(rqstp, cstate, clone, &src, &dst);
+	if (status)
+		return status;
+
+	ret = nfsd4_clone_range(src, dst, clone->cl_src_pos,
+				clone->cl_count, clone->cl_dst_pos);
+	if (ret < 0)
+		status = nfserrno(ret);
+	else
+		status = nfs_ok;
+
+	fput(src);
+	fput(dst);
+	return status;
+}
+
+static __be32
 nfsd4_fallocate(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		struct nfsd4_fallocate *fallocate, int flags)
 {
@@ -2283,6 +2356,12 @@ static struct nfsd4_operation nfsd4_ops[] = {
 		.op_name = "OP_DEALLOCATE",
 		.op_rsize_bop = (nfsd4op_rsize)nfsd4_only_status_rsize,
 	},
+	[OP_CLONE] = {
+		.op_func = (nfsd4op_func)nfsd4_clone,
+		.op_flags = OP_MODIFIES_SOMETHING | OP_CACHEME,
+		.op_name = "OP_CLONE",
+		.op_rsize_bop = (nfsd4op_rsize)nfsd4_only_status_rsize,
+	},
 	[OP_SEEK] = {
 		.op_func = (nfsd4op_func)nfsd4_seek,
 		.op_name = "OP_SEEK",
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 5463385..a845db1 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1675,6 +1675,25 @@ nfsd4_decode_fallocate(struct nfsd4_compoundargs *argp,
 }
 
 static __be32
+nfsd4_decode_clone(struct nfsd4_compoundargs *argp, struct nfsd4_clone *clone)
+{
+	DECODE_HEAD;
+
+	status = nfsd4_decode_stateid(argp, &clone->cl_src_stateid);
+	if (status)
+		return status;
+	status = nfsd4_decode_stateid(argp, &clone->cl_dst_stateid);
+	if (status)
+		return status;
+
+	READ_BUF(8 + 8 + 8);
+	p = xdr_decode_hyper(p, &clone->cl_src_pos);
+	p = xdr_decode_hyper(p, &clone->cl_dst_pos);
+	p = xdr_decode_hyper(p, &clone->cl_count);
+	DECODE_TAIL;
+}
+
+static __be32
 nfsd4_decode_seek(struct nfsd4_compoundargs *argp, struct nfsd4_seek *seek)
 {
 	DECODE_HEAD;
@@ -1785,6 +1804,7 @@ static nfsd4_dec nfsd4_dec_ops[] = {
 	[OP_READ_PLUS]		= (nfsd4_dec)nfsd4_decode_notsupp,
 	[OP_SEEK]		= (nfsd4_dec)nfsd4_decode_seek,
 	[OP_WRITE_SAME]		= (nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_CLONE]		= (nfsd4_dec)nfsd4_decode_clone,
 };
 
 static inline bool
@@ -4249,6 +4269,7 @@ static nfsd4_enc nfsd4_enc_ops[] = {
 	[OP_READ_PLUS]		= (nfsd4_enc)nfsd4_encode_noop,
 	[OP_SEEK]		= (nfsd4_enc)nfsd4_encode_seek,
 	[OP_WRITE_SAME]		= (nfsd4_enc)nfsd4_encode_noop,
+	[OP_CLONE]		= (nfsd4_enc)nfsd4_encode_noop,
 };
 
 /*
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index b5e077a..7d43097 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -36,6 +36,7 @@
 #endif /* CONFIG_NFSD_V3 */
 
 #ifdef CONFIG_NFSD_V4
+#include "../internal.h"
 #include "acl.h"
 #include "idmap.h"
 #endif /* CONFIG_NFSD_V4 */
@@ -498,6 +499,12 @@ __be32 nfsd4_set_nfs4_label(struct svc_rqst *rqstp, struct svc_fh *fhp,
 }
 #endif
 
+int nfsd4_clone_range(struct file *src, struct file *dst, u64 src_pos,
+		      u64 count, u64 dst_pos)
+{
+	return vfs_file_clone_range(src, dst, src_pos, count, dst_pos);
+}
+
 __be32 nfsd4_vfs_fallocate(struct svc_rqst *rqstp, struct svc_fh *fhp,
 			   struct file *file, loff_t offset, loff_t len,
 			   int flags)
diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
index 5be875e..31d56a3 100644
--- a/fs/nfsd/vfs.h
+++ b/fs/nfsd/vfs.h
@@ -56,6 +56,7 @@ __be32          nfsd4_set_nfs4_label(struct svc_rqst *, struct svc_fh *,
 		    struct xdr_netobj *);
 __be32		nfsd4_vfs_fallocate(struct svc_rqst *, struct svc_fh *,
 				    struct file *, loff_t, loff_t, int);
+int		nfsd4_clone_range(struct file *, struct file *, u64, u64, u64);
 #endif /* CONFIG_NFSD_V4 */
 __be32		nfsd_create(struct svc_rqst *, struct svc_fh *,
 				char *name, int len, struct iattr *attrs,
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index 9f99100..3d70712 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -491,6 +491,15 @@ struct nfsd4_fallocate {
 	u64		falloc_length;
 };
 
+struct nfsd4_clone {
+	/* request */
+	stateid_t	cl_src_stateid;
+	stateid_t	cl_dst_stateid;
+	u64		cl_src_pos;
+	u64		cl_dst_pos;
+	u64		cl_count;
+};
+
 struct nfsd4_seek {
 	/* request */
 	stateid_t	seek_stateid;
@@ -555,6 +564,7 @@ struct nfsd4_op {
 		/* NFSv4.2 */
 		struct nfsd4_fallocate		allocate;
 		struct nfsd4_fallocate		deallocate;
+		struct nfsd4_clone		clone;
 		struct nfsd4_seek		seek;
 	} u;
 	struct nfs4_replay *			replay;
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index e7e7853..21c6612 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -139,10 +139,10 @@ enum nfs_opnum4 {
 Needs to be updated if more operations are defined in future.*/
 
 #define FIRST_NFS4_OP	OP_ACCESS
-#define LAST_NFS4_OP 	OP_WRITE_SAME
 #define LAST_NFS40_OP	OP_RELEASE_LOCKOWNER
 #define LAST_NFS41_OP	OP_RECLAIM_COMPLETE
-#define LAST_NFS42_OP	OP_WRITE_SAME
+#define LAST_NFS42_OP	OP_CLONE
+#define LAST_NFS4_OP 	LAST_NFS42_OP
 
 enum nfsstat4 {
 	NFS4_OK = 0,
-- 
1.8.3.1

