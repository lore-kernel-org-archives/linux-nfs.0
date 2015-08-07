Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:7454 "EHLO mx142.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1946224AbbHGUie (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 7 Aug 2015 16:38:34 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>,
        <bfields@fieldses.org>
CC: <Anna.Schumaker@netapp.com>
Subject: [PATCH 6/7] NFSD: Implement the COPY call
Date: Fri, 7 Aug 2015 16:38:22 -0400
Message-ID: <1438979904-8775-7-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1438979904-8775-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1438979904-8775-1-git-send-email-Anna.Schumaker@Netapp.com>
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
 fs/nfsd/nfs4proc.c | 63 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfsd/nfs4xdr.c  | 62 +++++++++++++++++++++++++++++++++++++++++++++++++++--
 fs/nfsd/vfs.c      | 13 +++++++++++
 fs/nfsd/vfs.h      |  1 +
 fs/nfsd/xdr4.h     | 23 ++++++++++++++++++++
 5 files changed, 160 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index d34c967..fbfb509 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1014,6 +1014,63 @@ nfsd4_write(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
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
@@ -2283,6 +2340,12 @@ static struct nfsd4_operation nfsd4_ops[] = {
 		.op_name = "OP_DEALLOCATE",
 		.op_rsize_bop = (nfsd4op_rsize)nfsd4_only_status_rsize,
 	},
+	[OP_COPY] = {
+		.op_func = (nfsd4op_func)nfsd4_copy,
+		.op_flags = OP_MODIFIES_SOMETHING | OP_CACHEME,
+		.op_name = "OP_COPY",
+		.op_rsize_bop = (nfsd4op_rsize)nfsd4_write_rsize,
+	},
 	[OP_SEEK] = {
 		.op_func = (nfsd4op_func)nfsd4_seek,
 		.op_name = "OP_SEEK",
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 5463385..3a78c7f 100644
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
@@ -4140,6 +4164,40 @@ nfsd4_encode_layoutreturn(struct nfsd4_compoundres *resp, __be32 nfserr,
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
@@ -4238,7 +4296,7 @@ static nfsd4_enc nfsd4_enc_ops[] = {
 
 	/* NFSv4.2 operations */
 	[OP_ALLOCATE]		= (nfsd4_enc)nfsd4_encode_noop,
-	[OP_COPY]		= (nfsd4_enc)nfsd4_encode_noop,
+	[OP_COPY]		= (nfsd4_enc)nfsd4_encode_copy,
 	[OP_COPY_NOTIFY]	= (nfsd4_enc)nfsd4_encode_noop,
 	[OP_DEALLOCATE]		= (nfsd4_enc)nfsd4_encode_noop,
 	[OP_IO_ADVISE]		= (nfsd4_enc)nfsd4_encode_noop,
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index b5e077a..4065f38 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -36,6 +36,7 @@
 #endif /* CONFIG_NFSD_V3 */
 
 #ifdef CONFIG_NFSD_V4
+#include "../internal.h"
 #include "acl.h"
 #include "idmap.h"
 #endif /* CONFIG_NFSD_V4 */
@@ -498,6 +499,18 @@ __be32 nfsd4_set_nfs4_label(struct svc_rqst *rqstp, struct svc_fh *fhp,
 }
 #endif
 
+ssize_t nfsd_copy_range(struct file *src, u64 src_pos,
+		       struct file *dst, u64 dst_pos,
+		       u64 count)
+{
+	ssize_t bytes;
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
index 5be875e..c529f9e 100644
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
index 9f99100..9e83f95 100644
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
2.5.0

