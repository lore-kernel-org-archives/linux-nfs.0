Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:12561 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754995AbcHSRZp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 19 Aug 2016 13:25:45 -0400
From: <andros@netapp.com>
To: <trondmy.myklebust@primarydata.com>
CC: <anna.schumaker@netapp.com>, <bfields@fieldses.org>,
        <linux-nfs@vger.kernel.org>,
        Anna Schumaker <Anna.Schumaker@netapp.com>,
        Anna Schumaker <bjschuma@netapp.com>
Subject: [PATCH Version-2 02/12] NFSD: Implement the COPY call
Date: Fri, 19 Aug 2016 13:25:02 -0400
Message-ID: <1471627512-4102-3-git-send-email-andros@netapp.com>
In-Reply-To: <1471627512-4102-1-git-send-email-andros@netapp.com>
References: <1471627512-4102-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@netapp.com>

I only implemented the sync version of this call, since it's the
easiest.  I can simply call vfs_copy_range() and have the vfs do the
right thing for the filesystem being exported.

Signed-off-by: Anna Schumaker <bjschuma@netapp.com>
--
v2:
- Don't fsync() after copy
- Tell client that the result is NFS_UNSTABLE
- Fix conflicts with clone

v3:
- Check for copying beyond the end of the file

v4:
- Rename nfsd_copy_range() -> nfsd_copy_file_range()
- Remove size checks handled by VFS
---
 fs/nfsd/nfs4proc.c | 90 +++++++++++++++++++++++++++++++++++++++++++++++-------
 fs/nfsd/nfs4xdr.c  | 63 ++++++++++++++++++++++++++++++++++++--
 fs/nfsd/vfs.c      |  6 ++++
 fs/nfsd/vfs.h      |  2 ++
 fs/nfsd/xdr4.h     | 23 ++++++++++++++
 5 files changed, 171 insertions(+), 13 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 1fb2227..abb09b5 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1010,47 +1010,97 @@ nfsd4_write(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 }
 
 static __be32
-nfsd4_clone(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
-		struct nfsd4_clone *clone)
+nfsd4_verify_copy(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
+		  stateid_t *src_stateid, struct file **src,
+		  stateid_t *dst_stateid, struct file **dst)
 {
-	struct file *src, *dst;
 	__be32 status;
 
 	status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->save_fh,
-					    &clone->cl_src_stateid, RD_STATE,
-					    &src, NULL);
+					    src_stateid, RD_STATE, src, NULL);
 	if (status) {
 		dprintk("NFSD: %s: couldn't process src stateid!\n", __func__);
 		goto out;
 	}
 
 	status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->current_fh,
-					    &clone->cl_dst_stateid, WR_STATE,
-					    &dst, NULL);
+					    dst_stateid, WR_STATE, dst, NULL);
 	if (status) {
 		dprintk("NFSD: %s: couldn't process dst stateid!\n", __func__);
 		goto out_put_src;
 	}
 
 	/* fix up for NFS-specific error code */
-	if (!S_ISREG(file_inode(src)->i_mode) ||
-	    !S_ISREG(file_inode(dst)->i_mode)) {
+	if (!S_ISREG(file_inode(*src)->i_mode) ||
+	    !S_ISREG(file_inode(*dst)->i_mode)) {
 		status = nfserr_wrong_type;
 		goto out_put_dst;
 	}
 
+out:
+	return status;
+out_put_dst:
+	fput(*dst);
+out_put_src:
+	fput(*src);
+	goto out;
+}
+
+static __be32
+nfsd4_clone(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
+		struct nfsd4_clone *clone)
+{
+	struct file *src, *dst;
+	__be32 status;
+
+	status = nfsd4_verify_copy(rqstp, cstate, &clone->cl_src_stateid, &src,
+				   &clone->cl_dst_stateid, &dst);
+	if (status)
+		goto out;
+
 	status = nfsd4_clone_file_range(src, clone->cl_src_pos,
 			dst, clone->cl_dst_pos, clone->cl_count);
 
-out_put_dst:
 	fput(dst);
-out_put_src:
 	fput(src);
 out:
 	return status;
 }
 
 static __be32
+nfsd4_copy(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
+		struct nfsd4_copy *copy)
+{
+	struct file *src, *dst;
+	__be32 status;
+	ssize_t bytes;
+
+	status = nfsd4_verify_copy(rqstp, cstate, &copy->cp_src_stateid, &src,
+				   &copy->cp_dst_stateid, &dst);
+	if (status)
+		goto out;
+
+	bytes = nfsd_copy_file_range(src, copy->cp_src_pos,
+			dst, copy->cp_dst_pos, copy->cp_count);
+
+	if (bytes < 0)
+		status = nfserrno(bytes);
+	else {
+		copy->cp_res.wr_bytes_written = bytes;
+		copy->cp_res.wr_stable_how = NFS_UNSTABLE;
+		copy->cp_consecutive = 1;
+		copy->cp_synchronous = 1;
+		gen_boot_verifier(&copy->cp_res.wr_verifier, SVC_NET(rqstp));
+		status = nfs_ok;
+	}
+
+	fput(src);
+	fput(dst);
+out:
+	return status;
+}
+
+static __be32
 nfsd4_fallocate(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		struct nfsd4_fallocate *fallocate, int flags)
 {
@@ -1966,6 +2016,18 @@ static inline u32 nfsd4_create_session_rsize(struct svc_rqst *rqstp, struct nfsd
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
@@ -2328,6 +2390,12 @@ static struct nfsd4_operation nfsd4_ops[] = {
 		.op_name = "OP_CLONE",
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
index 0aa0236..5e148d4 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1694,6 +1694,30 @@ nfsd4_decode_clone(struct nfsd4_compoundargs *argp, struct nfsd4_clone *clone)
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
@@ -1793,7 +1817,7 @@ static nfsd4_dec nfsd4_dec_ops[] = {
 
 	/* new operations for NFSv4.2 */
 	[OP_ALLOCATE]		= (nfsd4_dec)nfsd4_decode_fallocate,
-	[OP_COPY]		= (nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_COPY]		= (nfsd4_dec)nfsd4_decode_copy,
 	[OP_COPY_NOTIFY]	= (nfsd4_dec)nfsd4_decode_notsupp,
 	[OP_DEALLOCATE]		= (nfsd4_dec)nfsd4_decode_fallocate,
 	[OP_IO_ADVISE]		= (nfsd4_dec)nfsd4_decode_notsupp,
@@ -4202,6 +4226,41 @@ nfsd4_encode_layoutreturn(struct nfsd4_compoundres *resp, __be32 nfserr,
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
+	p = xdr_encode_opaque_fixed(p, write->wr_verifier.data,
+				    NFS4_VERIFIER_SIZE);
+	return nfs_ok;
+}
+
+static __be32
+nfsd4_encode_copy(struct nfsd4_compoundres *resp, __be32 nfserr,
+		  struct nfsd4_copy *copy)
+{
+	__be32 *p;
+
+	if (!nfserr) {
+		nfserr = nfsd42_encode_write_res(resp, &copy->cp_res);
+		if (nfserr)
+			return nfserr;
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
@@ -4300,7 +4359,7 @@ static nfsd4_enc nfsd4_enc_ops[] = {
 
 	/* NFSv4.2 operations */
 	[OP_ALLOCATE]		= (nfsd4_enc)nfsd4_encode_noop,
-	[OP_COPY]		= (nfsd4_enc)nfsd4_encode_noop,
+	[OP_COPY]		= (nfsd4_enc)nfsd4_encode_copy,
 	[OP_COPY_NOTIFY]	= (nfsd4_enc)nfsd4_encode_noop,
 	[OP_DEALLOCATE]		= (nfsd4_enc)nfsd4_encode_noop,
 	[OP_IO_ADVISE]		= (nfsd4_enc)nfsd4_encode_noop,
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index ff476e6..58f8219 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -513,6 +513,12 @@ __be32 nfsd4_clone_file_range(struct file *src, u64 src_pos, struct file *dst,
 			count));
 }
 
+ssize_t nfsd_copy_file_range(struct file *src, u64 src_pos, struct file *dst,
+			     u64 dst_pos, u64 count)
+{
+	return vfs_copy_file_range(src, src_pos, dst, dst_pos, count, 0);
+}
+
 __be32 nfsd4_vfs_fallocate(struct svc_rqst *rqstp, struct svc_fh *fhp,
 			   struct file *file, loff_t offset, loff_t len,
 			   int flags)
diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
index 3cbb1b3..0bf9e7b 100644
--- a/fs/nfsd/vfs.h
+++ b/fs/nfsd/vfs.h
@@ -96,6 +96,8 @@ __be32		nfsd_symlink(struct svc_rqst *, struct svc_fh *,
 				struct svc_fh *res);
 __be32		nfsd_link(struct svc_rqst *, struct svc_fh *,
 				char *, int, struct svc_fh *);
+ssize_t		nfsd_copy_file_range(struct file *, u64,
+				     struct file *, u64, u64);
 __be32		nfsd_rename(struct svc_rqst *,
 				struct svc_fh *, char *, int,
 				struct svc_fh *, char *, int);
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index beea0c5..8fda4ab 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -503,6 +503,28 @@ struct nfsd4_clone {
 	u64		cl_count;
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
@@ -568,6 +590,7 @@ struct nfsd4_op {
 		struct nfsd4_fallocate		allocate;
 		struct nfsd4_fallocate		deallocate;
 		struct nfsd4_clone		clone;
+		struct nfsd4_copy		copy;
 		struct nfsd4_seek		seek;
 	} u;
 	struct nfs4_replay *			replay;
-- 
1.8.3.1

