Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:40811 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753408AbbKZSzw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Nov 2015 13:55:52 -0500
From: Christoph Hellwig <hch@lst.de>
To: viro@zeniv.linux.org.uk
Cc: tao.peng@primarydata.com, jeff.layton@primarydata.com,
        linux-fsdevel@vger.kernel.org, linux-btrfs@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org
Subject: [PATCH 5/5] nfsd: implement the NFSv4.2 CLONE operation
Date: Thu, 26 Nov 2015 19:50:59 +0100
Message-Id: <1448563859-21922-6-git-send-email-hch@lst.de>
In-Reply-To: <1448563859-21922-1-git-send-email-hch@lst.de>
References: <1448563859-21922-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is basically a remote version of the btrfs CLONE operation,
so the implementation is fairly trivial.  Made even more trivial
by stealing the XDR code and general framework Anna Schumaker's
COPY prototype.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfsd/nfs4proc.c   | 47 +++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfsd/nfs4xdr.c    | 21 +++++++++++++++++++++
 fs/nfsd/vfs.c        |  8 ++++++++
 fs/nfsd/vfs.h        |  2 ++
 fs/nfsd/xdr4.h       | 10 ++++++++++
 include/linux/nfs4.h |  4 ++--
 6 files changed, 90 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 3ba10a3..819ad81 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1012,6 +1012,47 @@ nfsd4_write(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 }
 
 static __be32
+nfsd4_clone(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
+		struct nfsd4_clone *clone)
+{
+	struct file *src, *dst;
+	__be32 status;
+
+	status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->save_fh,
+					    &clone->cl_src_stateid, RD_STATE,
+					    &src, NULL);
+	if (status) {
+		dprintk("NFSD: %s: couldn't process src stateid!\n", __func__);
+		goto out;
+	}
+
+	status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->current_fh,
+					    &clone->cl_dst_stateid, WR_STATE,
+					    &dst, NULL);
+	if (status) {
+		dprintk("NFSD: %s: couldn't process dst stateid!\n", __func__);
+		goto out_put_src;
+	}
+
+	/* fix up for NFS-specific error code */
+	if (!S_ISREG(file_inode(src)->i_mode) ||
+	    !S_ISREG(file_inode(dst)->i_mode)) {
+		status = nfserr_wrong_type;
+		goto out_put_dst;
+	}
+
+	status = nfsd4_clone_file_range(src, clone->cl_src_pos,
+			dst, clone->cl_dst_pos, clone->cl_count);
+
+out_put_dst:
+	fput(dst);
+out_put_src:
+	fput(src);
+out:
+	return status;
+}
+
+static __be32
 nfsd4_fallocate(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		struct nfsd4_fallocate *fallocate, int flags)
 {
@@ -2281,6 +2322,12 @@ static struct nfsd4_operation nfsd4_ops[] = {
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
index 51c9e9c..924416f 100644
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
@@ -4292,6 +4312,7 @@ static nfsd4_enc nfsd4_enc_ops[] = {
 	[OP_READ_PLUS]		= (nfsd4_enc)nfsd4_encode_noop,
 	[OP_SEEK]		= (nfsd4_enc)nfsd4_encode_seek,
 	[OP_WRITE_SAME]		= (nfsd4_enc)nfsd4_encode_noop,
+	[OP_CLONE]		= (nfsd4_enc)nfsd4_encode_noop,
 };
 
 /*
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 994d66f..5411bf0 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -36,6 +36,7 @@
 #endif /* CONFIG_NFSD_V3 */
 
 #ifdef CONFIG_NFSD_V4
+#include "../internal.h"
 #include "acl.h"
 #include "idmap.h"
 #endif /* CONFIG_NFSD_V4 */
@@ -498,6 +499,13 @@ __be32 nfsd4_set_nfs4_label(struct svc_rqst *rqstp, struct svc_fh *fhp,
 }
 #endif
 
+__be32 nfsd4_clone_file_range(struct file *src, u64 src_pos, struct file *dst,
+		u64 dst_pos, u64 count)
+{
+	return nfserrno(vfs_clone_file_range(src, src_pos, dst, dst_pos,
+			count));
+}
+
 __be32 nfsd4_vfs_fallocate(struct svc_rqst *rqstp, struct svc_fh *fhp,
 			   struct file *file, loff_t offset, loff_t len,
 			   int flags)
diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
index fcfc48c..c11ba31 100644
--- a/fs/nfsd/vfs.h
+++ b/fs/nfsd/vfs.h
@@ -56,6 +56,8 @@ __be32          nfsd4_set_nfs4_label(struct svc_rqst *, struct svc_fh *,
 		    struct xdr_netobj *);
 __be32		nfsd4_vfs_fallocate(struct svc_rqst *, struct svc_fh *,
 				    struct file *, loff_t, loff_t, int);
+__be32		nfsd4_clone_file_range(struct file *, u64, struct file *,
+			u64, u64);
 #endif /* CONFIG_NFSD_V4 */
 __be32		nfsd_create(struct svc_rqst *, struct svc_fh *,
 				char *name, int len, struct iattr *attrs,
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index ce7362c..d955481 100644
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
index e7e7853..43aeabd 100644
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
+#define LAST_NFS4_OP	LAST_NFS42_OP
 
 enum nfsstat4 {
 	NFS4_OK = 0,
-- 
1.9.1

