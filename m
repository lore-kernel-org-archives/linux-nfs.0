Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:18403 "EHLO mx143.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754198AbbLCUzo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Dec 2015 15:55:44 -0500
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <linux-nfs@vger.kernel.org>, <Trond.Myklebust@primarydata.com>,
        <bfields@fieldses.org>, <hch@infradead.org>
Subject: [PATCH v1 2/3] NFSD: Implement the COPY call
Date: Thu, 3 Dec 2015 15:55:35 -0500
Message-ID: <1449176137-4940-3-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1449176137-4940-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1449176137-4940-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@netapp.com>

I only implemented the sync version of this call, since it's the
easiest.  I can simply call vfs_copy_range() and have the vfs do the
right thing for the filesystem being exported.

Signed-off-by: Anna Schumaker <bjschuma@netapp.com>
---
 fs/nfsd/nfs4proc.c | 75 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfsd/nfs4xdr.c  | 62 ++++++++++++++++++++++++++++++++++++++++++--
 fs/nfsd/vfs.c      | 17 +++++++++++++
 fs/nfsd/vfs.h      |  1 +
 fs/nfsd/xdr4.h     | 23 +++++++++++++++++
 5 files changed, 176 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 3ba10a3..e0b1f43 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1012,6 +1012,63 @@ nfsd4_write(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 }
 
 static __be32
+nfsd4_verify_copy(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
+		  struct nfsd4_copy *copy, struct file **src, struct file **dst)
+{
+	__be32 status;
+
+	status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->save_fh,
+						&copy->cp_src_stateid, RD_STATE,
+						src, NULL);
+	if (status) {
+		dprintk("NFSD: nfsd4_copy: couldn't process src stateid!\n");
+		return status;
+	}
+
+	status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->current_fh,
+						&copy->cp_dst_stateid, WR_STATE,
+						dst, NULL);
+	if (status) {
+		dprintk("NFSD: nfsd4_copy: couldn't process dst stateid!\n");
+		fput(*src);
+	}
+
+	return status;
+}
+
+static __be32
+nfsd4_copy(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
+		struct nfsd4_copy *copy)
+{
+	ssize_t bytes;
+	__be32 status;
+	struct file *src = NULL, *dst = NULL;
+
+	status = nfsd4_verify_copy(rqstp, cstate, copy, &src, &dst);
+	if (status)
+		return status;
+
+	bytes = nfsd_copy_range(src, copy->cp_src_pos,
+				 dst, copy->cp_dst_pos,
+				 copy->cp_count);
+
+	if (bytes < 0)
+		status = nfserrno(bytes);
+	else {
+		copy->cp_res.wr_bytes_written = bytes;
+		copy->cp_res.wr_stable_how = NFS_FILE_SYNC;
+		copy->cp_consecutive = 1;
+		copy->cp_synchronous = 1;
+		gen_boot_verifier(&copy->cp_res.wr_verifier, SVC_NET(rqstp));
+		status = nfs_ok;
+	}
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
@@ -1925,6 +1982,18 @@ static inline u32 nfsd4_create_session_rsize(struct svc_rqst *rqstp, struct nfsd
 		op_encode_channel_attrs_maxsz) * sizeof(__be32);
 }
 
+static inline u32 nfsd4_copy_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op)
+{
+	return (op_encode_hdr_size +
+		1 /* wr_callback */ +
+		op_encode_stateid_maxsz /* wr_callback */ +
+		2 /* wr_count */ +
+		1 /* wr_committed */ +
+		op_encode_verifier_maxsz +
+		1 /* cr_consecutive */ +
+		1 /* cr_synchronous */) * sizeof(__be32);
+}
+
 #ifdef CONFIG_NFSD_PNFS
 /*
  * At this stage we don't really know what layout driver will handle the request,
@@ -2281,6 +2350,12 @@ static struct nfsd4_operation nfsd4_ops[] = {
 		.op_name = "OP_DEALLOCATE",
 		.op_rsize_bop = (nfsd4op_rsize)nfsd4_only_status_rsize,
 	},
+	[OP_COPY] = {
+		.op_func = (nfsd4op_func)nfsd4_copy,
+		.op_flags = OP_MODIFIES_SOMETHING | OP_CACHEME,
+		.op_name = "OP_COPY",
+		.op_rsize_bop = (nfsd4op_rsize)nfsd4_copy_rsize,
+	},
 	[OP_SEEK] = {
 		.op_func = (nfsd4op_func)nfsd4_seek,
 		.op_name = "OP_SEEK",
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 51c9e9c..d86a3c7 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1675,6 +1675,30 @@ nfsd4_decode_fallocate(struct nfsd4_compoundargs *argp,
 }
 
 static __be32
+nfsd4_decode_copy(struct nfsd4_compoundargs *argp, struct nfsd4_copy *copy)
+{
+	DECODE_HEAD;
+	unsigned int tmp;
+
+	status = nfsd4_decode_stateid(argp, &copy->cp_src_stateid);
+	if (status)
+		return status;
+	status = nfsd4_decode_stateid(argp, &copy->cp_dst_stateid);
+	if (status)
+		return status;
+
+	READ_BUF(8 + 8 + 8 + 4 + 4 + 4);
+	p = xdr_decode_hyper(p, &copy->cp_src_pos);
+	p = xdr_decode_hyper(p, &copy->cp_dst_pos);
+	p = xdr_decode_hyper(p, &copy->cp_count);
+	copy->cp_consecutive = be32_to_cpup(p++);
+	copy->cp_synchronous = be32_to_cpup(p++);
+	tmp = be32_to_cpup(p); /* Source server list not supported */
+
+	DECODE_TAIL;
+}
+
+static __be32
 nfsd4_decode_seek(struct nfsd4_compoundargs *argp, struct nfsd4_seek *seek)
 {
 	DECODE_HEAD;
@@ -1774,7 +1798,7 @@ static nfsd4_dec nfsd4_dec_ops[] = {
 
 	/* new operations for NFSv4.2 */
 	[OP_ALLOCATE]		= (nfsd4_dec)nfsd4_decode_fallocate,
-	[OP_COPY]		= (nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_COPY]		= (nfsd4_dec)nfsd4_decode_copy,
 	[OP_COPY_NOTIFY]	= (nfsd4_dec)nfsd4_decode_notsupp,
 	[OP_DEALLOCATE]		= (nfsd4_dec)nfsd4_decode_fallocate,
 	[OP_IO_ADVISE]		= (nfsd4_dec)nfsd4_decode_notsupp,
@@ -4183,6 +4207,40 @@ nfsd4_encode_layoutreturn(struct nfsd4_compoundres *resp, __be32 nfserr,
 #endif /* CONFIG_NFSD_PNFS */
 
 static __be32
+nfsd42_encode_write_res(struct nfsd4_compoundres *resp, struct nfsd42_write_res *write)
+{
+	__be32 *p;
+
+	p = xdr_reserve_space(&resp->xdr, 4 + 8 + 4 + NFS4_VERIFIER_SIZE);
+	if (!p)
+		return nfserr_resource;
+
+	*p++ = cpu_to_be32(0);
+	p = xdr_encode_hyper(p, write->wr_bytes_written);
+	*p++ = cpu_to_be32(write->wr_stable_how);
+	p = xdr_encode_opaque_fixed(p, write->wr_verifier.data, NFS4_VERIFIER_SIZE);
+	return nfs_ok;
+}
+
+static __be32
+nfsd4_encode_copy(struct nfsd4_compoundres *resp, __be32 nfserr,
+		  struct nfsd4_copy *copy)
+{
+	__be32 *p, err;
+
+	if (!nfserr) {
+		err = nfsd42_encode_write_res(resp, &copy->cp_res);
+		if (err)
+			return err;
+
+		p = xdr_reserve_space(&resp->xdr, 4 + 4);
+		*p++ = cpu_to_be32(copy->cp_consecutive);
+		*p++ = cpu_to_be32(copy->cp_synchronous);
+	}
+	return nfserr;
+}
+
+static __be32
 nfsd4_encode_seek(struct nfsd4_compoundres *resp, __be32 nfserr,
 		  struct nfsd4_seek *seek)
 {
@@ -4281,7 +4339,7 @@ static nfsd4_enc nfsd4_enc_ops[] = {
 
 	/* NFSv4.2 operations */
 	[OP_ALLOCATE]		= (nfsd4_enc)nfsd4_encode_noop,
-	[OP_COPY]		= (nfsd4_enc)nfsd4_encode_noop,
+	[OP_COPY]		= (nfsd4_enc)nfsd4_encode_copy,
 	[OP_COPY_NOTIFY]	= (nfsd4_enc)nfsd4_encode_noop,
 	[OP_DEALLOCATE]		= (nfsd4_enc)nfsd4_encode_noop,
 	[OP_IO_ADVISE]		= (nfsd4_enc)nfsd4_encode_noop,
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 994d66f..225ff12 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -36,6 +36,7 @@
 #endif /* CONFIG_NFSD_V3 */
 
 #ifdef CONFIG_NFSD_V4
+#include "../internal.h"
 #include "acl.h"
 #include "idmap.h"
 #endif /* CONFIG_NFSD_V4 */
@@ -498,6 +499,22 @@ __be32 nfsd4_set_nfs4_label(struct svc_rqst *rqstp, struct svc_fh *fhp,
 }
 #endif
 
+ssize_t nfsd_copy_range(struct file *src, u64 src_pos,
+		       struct file *dst, u64 dst_pos,
+		       u64 count)
+{
+	ssize_t bytes;
+	u64 limit = 0x10000000;
+
+	if (count > limit)
+		count = limit;
+
+	bytes = vfs_copy_file_range(src, src_pos, dst, dst_pos, count, 0);
+	if (bytes > 0)
+		vfs_fsync_range(dst, dst_pos, dst_pos + bytes, 0);
+	return bytes;
+}
+
 __be32 nfsd4_vfs_fallocate(struct svc_rqst *rqstp, struct svc_fh *fhp,
 			   struct file *file, loff_t offset, loff_t len,
 			   int flags)
diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
index fcfc48c..0243c5a 100644
--- a/fs/nfsd/vfs.h
+++ b/fs/nfsd/vfs.h
@@ -91,6 +91,7 @@ __be32		nfsd_symlink(struct svc_rqst *, struct svc_fh *,
 				struct svc_fh *res);
 __be32		nfsd_link(struct svc_rqst *, struct svc_fh *,
 				char *, int, struct svc_fh *);
+ssize_t		nfsd_copy_range(struct file *, u64, struct file *, u64, u64);
 __be32		nfsd_rename(struct svc_rqst *,
 				struct svc_fh *, char *, int,
 				struct svc_fh *, char *, int);
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index ce7362c..7ef82c9 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -491,6 +491,28 @@ struct nfsd4_fallocate {
 	u64		falloc_length;
 };
 
+struct nfsd42_write_res {
+	u64			wr_bytes_written;
+	u32			wr_stable_how;
+	nfs4_verifier		wr_verifier;
+};
+
+struct nfsd4_copy {
+	/* request */
+	stateid_t	cp_src_stateid;
+	stateid_t	cp_dst_stateid;
+	u64		cp_src_pos;
+	u64		cp_dst_pos;
+	u64		cp_count;
+
+	/* both */
+	bool		cp_consecutive;
+	bool		cp_synchronous;
+
+	/* response */
+	struct nfsd42_write_res	cp_res;
+};
+
 struct nfsd4_seek {
 	/* request */
 	stateid_t	seek_stateid;
@@ -555,6 +577,7 @@ struct nfsd4_op {
 		/* NFSv4.2 */
 		struct nfsd4_fallocate		allocate;
 		struct nfsd4_fallocate		deallocate;
+		struct nfsd4_copy		copy;
 		struct nfsd4_seek		seek;
 	} u;
 	struct nfs4_replay *			replay;
-- 
2.6.3

