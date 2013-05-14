Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:59897 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758585Ab3ENVQJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 May 2013 17:16:09 -0400
From: Zach Brown <zab@redhat.com>
To: "Martin K. Petersen" <martin.petersen@oracle.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-btrfs@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: [RFC v0 4/4] nfs, nfsd: rough sys_copy_range and COPY support
Date: Tue, 14 May 2013 14:15:26 -0700
Message-Id: <1368566126-17610-5-git-send-email-zab@redhat.com>
In-Reply-To: <1368566126-17610-1-git-send-email-zab@redhat.com>
References: <1368566126-17610-1-git-send-email-zab@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This crude patch illustrates the simplest plumbing involved in
supporting sys_call_range with the NFS COPY operation that's pending in
the 4.2 draft spec.

The patch is based on a previous prototype that used the COPY op to
implement sys_copyfileat which created a new file (based on the ocfs2
reflink ioctl).  By contrast, this copies file contents between existing
files.

There's still a lot of implementation and testing to do, but this can
get discussion going.
---
 fs/nfs/file.c           |  25 +++++++++
 fs/nfs/nfs4proc.c       |  72 ++++++++++++++++++++++++++
 fs/nfs/nfs4xdr.c        | 132 ++++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfsd/nfs4proc.c      |  35 +++++++++++++
 fs/nfsd/nfs4xdr.c       |  43 ++++++++++++++++
 fs/nfsd/vfs.c           |  41 +++++++++++++++
 fs/nfsd/vfs.h           |   3 ++
 fs/nfsd/xdr4.h          |  21 ++++++++
 include/linux/nfs4.h    |   6 ++-
 include/linux/nfs_xdr.h |  24 +++++++++
 10 files changed, 401 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index a87a44f..7d7bedf 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -917,6 +917,30 @@ int nfs_setlease(struct file *file, long arg, struct file_lock **fl)
 }
 EXPORT_SYMBOL_GPL(nfs_setlease);
 
+ssize_t nfs_copy_range(struct file *file_in, loff_t pos_in,
+		       struct file *file_out, loff_t pos_out,
+		       size_t count)
+{
+	struct dentry *dentry_in = file_in->f_path.dentry;
+	struct dentry *dentry_out = file_out->f_path.dentry;
+	struct inode *inode_in = dentry_in->d_inode;
+	struct inode *inode_out = dentry_out->d_inode;
+	loff_t ret;
+
+	dprintk("NFS copy_range(%s/%s@%llu, %s/%s@%llu, %zd)\n",
+		dentry_in->d_parent->d_name.name, dentry_in->d_name.name,
+		(unsigned long long)pos_in,
+		dentry_out->d_parent->d_name.name, dentry_out->d_name.name,
+		(unsigned long long)pos_out, count);
+
+	if (NFS_PROTO(inode_in)->copy == NULL)
+		ret = -EOPNOTSUPP;
+	else
+		ret = NFS_PROTO(inode_in)->copy(inode_in, inode_out, NULL,
+						0, count, pos_in, pos_out);
+	return ret;
+}
+
 const struct file_operations nfs_file_operations = {
 	.llseek		= nfs_file_llseek,
 	.read		= do_sync_read,
@@ -934,5 +958,6 @@ const struct file_operations nfs_file_operations = {
 	.splice_write	= nfs_file_splice_write,
 	.check_flags	= nfs_check_flags,
 	.setlease	= nfs_setlease,
+	.copy_range	= nfs_copy_range,
 };
 EXPORT_SYMBOL_GPL(nfs_file_operations);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 8fbc100..1586b3e 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5405,6 +5405,75 @@ int nfs4_proc_secinfo(struct inode *dir, const struct qstr *name,
 }
 
 #ifdef CONFIG_NFS_V4_1
+static loff_t _nfs4_proc_copy(struct inode *inode,
+			      struct inode *dir,
+			      struct qstr *name,
+			      int flags,
+			      loff_t nbyte,
+			      loff_t src_offset,
+			      loff_t dst_offset)
+{
+	struct nfs_server *server = NFS_SERVER(inode);
+	int status;
+	struct nfs_copy_args arg = {
+		.fh     = NFS_FH(inode),
+		.dir_fh = NFS_FH(dir),
+		.src_offset = src_offset,
+		.dst_offset = dst_offset,
+		.count = nbyte,
+		.flags = flags,
+		.destination   = name,
+		.bitmask = server->attr_bitmask,
+	};
+	struct nfs_copy_res res = {
+		.fh = NFS_FH(inode),
+		.callback_id_length = 0,
+		.callback_id = 0,
+		.bytes_copied = 0,
+		.server = server,
+	};
+	struct rpc_message msg = {
+		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_COPY],
+		.rpc_argp = &arg,
+		.rpc_resp = &res,
+	};
+
+	res.fattr = nfs_alloc_fattr();
+	if (res.fattr == NULL)
+		return -ENOMEM;
+
+	status = nfs4_call_sync(server->client, server, &msg, &arg.seq_args,
+				&res.seq_res, 1);
+	if (res.bytes_copied)
+		status = res.bytes_copied;
+
+	nfs_free_fattr(res.fattr);
+	return status;
+}
+
+static loff_t nfs4_proc_copy(struct inode *inode,
+			struct inode *dir,
+			struct qstr *name,
+			int flags,
+			loff_t nbyte,
+			loff_t src_offset,
+			loff_t dst_offset)
+{
+	struct nfs4_exception exception = {0, };
+	loff_t ret;
+
+	do {
+		ret = _nfs4_proc_copy(inode, dir, name, flags, nbyte,
+				      src_offset, dst_offset);
+		if (ret < 0)
+			ret = nfs4_handle_exception(NFS_SERVER(inode), ret,
+						    &exception);
+	} while (exception.retry);
+
+	return ret;
+}
+
+
 /*
  * Check the exchange flags returned by the server for invalid flags, having
  * both PNFS and NON_PNFS flags set, and not having one of NON_PNFS, PNFS, or
@@ -7097,6 +7166,9 @@ const struct nfs_rpc_ops nfs_v4_clientops = {
 	.free_client	= nfs4_free_client,
 	.create_server	= nfs4_create_server,
 	.clone_server	= nfs_clone_server,
+#ifdef CONFIG_NFS_V4_1
+	.copy		= nfs4_proc_copy,
+#endif
 };
 
 static const struct xattr_handler nfs4_xattr_nfs4_acl_handler = {
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 4be8d13..28598b0 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -397,6 +397,8 @@ static int nfs4_stat_to_errno(int);
 #define encode_free_stateid_maxsz	(op_encode_hdr_maxsz + 1 + \
 					 XDR_QUADLEN(NFS4_STATEID_SIZE))
 #define decode_free_stateid_maxsz	(op_decode_hdr_maxsz + 1)
+#define encode_copy_maxsz	(op_encode_hdr_maxsz + 8 + nfs4_name_maxsz)
+#define decode_copy_maxsz	(op_decode_hdr_maxsz + 1 + decode_stateid_maxsz)
 #else /* CONFIG_NFS_V4_1 */
 #define encode_sequence_maxsz	0
 #define decode_sequence_maxsz	0
@@ -840,6 +842,22 @@ static int nfs4_stat_to_errno(int);
 #define NFS4_dec_free_stateid_sz	(compound_decode_hdr_maxsz + \
 					 decode_sequence_maxsz + \
 					 decode_free_stateid_maxsz)
+#define NFS4_enc_copy_sz		(compound_encode_hdr_maxsz + \
+					 encode_sequence_maxsz + \
+					 encode_putfh_maxsz + \
+					 encode_savefh_maxsz + \
+					 encode_putfh_maxsz + \
+					 encode_copy_maxsz + \
+					 encode_getfh_maxsz + \
+					 encode_getattr_maxsz)
+#define NFS4_dec_copy_sz		(compound_decode_hdr_maxsz + \
+					 decode_sequence_maxsz + \
+					 decode_putfh_maxsz + \
+					 decode_savefh_maxsz + \
+					 decode_putfh_maxsz + \
+					 decode_copy_maxsz + \
+					 decode_getfh_maxsz + \
+					 decode_getattr_maxsz)
 
 const u32 nfs41_maxwrite_overhead = ((RPC_MAX_HEADER_WITH_AUTH +
 				      compound_encode_hdr_maxsz +
@@ -1817,6 +1835,23 @@ static void encode_reclaim_complete(struct xdr_stream *xdr,
 	encode_op_hdr(xdr, OP_RECLAIM_COMPLETE, decode_reclaim_complete_maxsz, hdr);
 	encode_uint32(xdr, args->one_fs);
 }
+
+static void encode_copy(struct xdr_stream *xdr,
+			const struct nfs_copy_args *args,
+			struct compound_hdr *hdr)
+{
+	__be32 *p;
+
+	p = reserve_space(xdr, 36 + args->destination->len);
+	*p++ = cpu_to_be32(OP_COPY);
+	p = xdr_encode_hyper(p, args->src_offset);
+	p = xdr_encode_hyper(p, args->dst_offset);
+	p = xdr_encode_hyper(p, args->count);
+	*p++ = cpu_to_be32(args->flags);
+	xdr_encode_opaque(p, args->destination->name, args->destination->len);
+	hdr->nops++;
+	hdr->replen += decode_copy_maxsz;
+}
 #endif /* CONFIG_NFS_V4_1 */
 
 static void encode_sequence(struct xdr_stream *xdr,
@@ -2761,6 +2796,30 @@ static void nfs4_xdr_enc_sequence(struct rpc_rqst *req, struct xdr_stream *xdr,
 }
 
 /*
+ * Encode a COPY request
+ */
+static int nfs4_xdr_enc_copy(struct rpc_rqst *req, __be32 *p,
+				struct nfs_copy_args *args)
+{
+	struct xdr_stream xdr;
+	struct compound_hdr hdr = {
+		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
+	};
+
+	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
+	encode_compound_hdr(&xdr, req, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
+	encode_putfh(&xdr, args->fh, &hdr);
+	encode_savefh(&xdr, &hdr);
+	encode_putfh(&xdr, args->dir_fh, &hdr);
+	encode_copy(&xdr, args, &hdr);
+	encode_getfh(&xdr, &hdr);
+	encode_getfattr(&xdr, args->bitmask, &hdr);
+	encode_nops(&hdr);
+	return 0;
+}
+
+/*
  * a GET_LEASE_TIME request
  */
 static void nfs4_xdr_enc_get_lease_time(struct rpc_rqst *req,
@@ -4688,6 +4747,41 @@ static int decode_link(struct xdr_stream *xdr, struct nfs4_change_info *cinfo)
 	return decode_change_info(xdr, cinfo);
 }
 
+#if defined(CONFIG_NFS_V4_1)
+static int decode_copy(struct xdr_stream *xdr, struct nfs_copy_res *res)
+{
+	__be32 *p;
+	int status;
+
+	status = decode_op_hdr(xdr, OP_COPY);
+	if (status)
+		return status;
+
+	if (status == 0) {
+		p = xdr_inline_decode(xdr, 4);
+		if (unlikely(!p))
+			goto out_overflow;
+		res->callback_id_length = be32_to_cpup(p);
+		if (res->callback_id_length == 1) {
+			status = decode_stateid(xdr, res->callback_id);
+			if (unlikely(status))
+				return status;
+		} else if (res->callback_id_length != 0)
+			return -EIO;
+	} else {
+		p = xdr_inline_decode(xdr, 8);
+		if (unlikely(!p))
+			goto out_overflow;
+		p = xdr_decode_hyper(p, &res->bytes_copied);
+	}
+
+	return 0;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
+}
+#endif /* CONFIG_NFS_V4_1 */
+
 /*
  * We create the owner, so we know a proper owner.id length is 4.
  */
@@ -7047,6 +7141,43 @@ static int nfs4_xdr_dec_free_stateid(struct rpc_rqst *rqstp,
 out:
 	return status;
 }
+
+/*
+ * Decode COPY response
+ */
+static int nfs4_xdr_dec_copy(struct rpc_rqst *rqstp, __be32 *p,
+				struct nfs_copy_res *res)
+{
+	struct xdr_stream xdr;
+	struct compound_hdr hdr;
+	int status;
+
+	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
+	status = decode_compound_hdr(&xdr, &hdr);
+	if (status)
+		goto out;
+	status = decode_sequence(&xdr, &res->seq_res, rqstp);
+	if (status)
+		goto out;
+	status = decode_putfh(&xdr);
+	if (status)
+		goto out;
+	status = decode_savefh(&xdr);
+	if (status != 0)
+		goto out;
+	status = decode_putfh(&xdr);
+	if (status != 0)
+		goto out;
+	status = decode_copy(&xdr, res);
+	if (status)
+		goto out;
+	status = decode_getfh(&xdr, res->fh);
+	if (status != 0)
+		goto out;
+	decode_getfattr(&xdr, res->fattr, res->server);
+out:
+	return status;
+}
 #endif /* CONFIG_NFS_V4_1 */
 
 /**
@@ -7257,6 +7388,7 @@ struct rpc_procinfo	nfs4_procedures[] = {
 	PROC(BIND_CONN_TO_SESSION,
 			enc_bind_conn_to_session, dec_bind_conn_to_session),
 	PROC(DESTROY_CLIENTID,	enc_destroy_clientid,	dec_destroy_clientid),
+	PROC(COPY,		enc_copy,		dec_copy),
 #endif /* CONFIG_NFS_V4_1 */
 };
 
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 27d74a2..2f62ebb 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -986,6 +986,37 @@ nfsd4_write(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	return status;
 }
 
+/*
+ * XXX:
+ *  - do something with stateids :)
+ *  - implement callback results and OFFLOAD_ABORT
+ *  - inter-server copies?
+ */
+static __be32
+nfsd4_copy(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
+		struct nfsd4_copy *copy)
+{
+	__be32 status;
+
+	/* only support copying data to an existing file */
+	if (copy->ca_destinationlen)
+		return nfserr_inval;
+
+	if (!cstate->current_fh.fh_dentry || !cstate->save_fh.fh_dentry)
+		return nfserr_nofilehandle;
+
+	status = nfsd_copy_range(rqstp, &cstate->save_fh, copy->ca_src_offset,
+				 &cstate->current_fh, copy->ca_dst_offset,
+				 copy->ca_count);
+	if (status == nfs_ok)
+		copy->u.cr_bytes_copied = copy->ca_count;
+
+	/* don't support async callbacks yet */
+	copy->u.ok.cr_callback_id_length = 0;
+
+	return status;
+}
+
 /* This routine never returns NFS_OK!  If there are no other errors, it
  * will return NFSERR_SAME or NFSERR_NOT_SAME depending on whether the
  * attributes matched.  VERIFY is implemented by mapping NFSERR_SAME
@@ -1798,6 +1829,10 @@ static struct nfsd4_operation nfsd4_ops[] = {
 		.op_get_currentstateid = (stateid_getter)nfsd4_get_freestateid,
 		.op_rsize_bop = (nfsd4op_rsize)nfsd4_only_status_rsize,
 	},
+	[OP_COPY] = {
+		.op_func = (nfsd4op_func)nfsd4_copy,
+		.op_name = "OP_COPY",
+	},
 };
 
 #ifdef NFSD_DEBUG
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 6cd86e0..d2978e9 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1445,6 +1445,26 @@ static __be32 nfsd4_decode_reclaim_complete(struct nfsd4_compoundargs *argp, str
 }
 
 static __be32
+nfsd4_decode_copy(struct nfsd4_compoundargs *argp, struct nfsd4_copy *copy)
+{
+	DECODE_HEAD;
+
+	READ_BUF(32);
+	READ64(copy->ca_src_offset);
+	READ64(copy->ca_dst_offset);
+	READ64(copy->ca_count);
+	READ32(copy->ca_flags);
+	READ32(copy->ca_destinationlen);
+	READ_BUF(copy->ca_destinationlen);
+	SAVEMEM(copy->ca_destination, copy->ca_destinationlen);
+	if ((status = check_filename(copy->ca_destination,
+				     copy->ca_destinationlen)))
+		return status;
+
+	DECODE_TAIL;
+}
+
+static __be32
 nfsd4_decode_noop(struct nfsd4_compoundargs *argp, void *p)
 {
 	return nfs_ok;
@@ -1557,6 +1577,7 @@ static nfsd4_dec nfsd41_dec_ops[] = {
 	[OP_WANT_DELEGATION]	= (nfsd4_dec)nfsd4_decode_notsupp,
 	[OP_DESTROY_CLIENTID]	= (nfsd4_dec)nfsd4_decode_destroy_clientid,
 	[OP_RECLAIM_COMPLETE]	= (nfsd4_dec)nfsd4_decode_reclaim_complete,
+	[OP_COPY]               = (nfsd4_dec)nfsd4_decode_copy,
 };
 
 struct nfsd4_minorversion_ops {
@@ -3394,6 +3415,27 @@ nfsd4_encode_test_stateid(struct nfsd4_compoundres *resp, __be32 nfserr,
 }
 
 static __be32
+nfsd4_encode_copy(struct nfsd4_compoundres *resp, __be32 nfserr,
+			struct nfsd4_copy *copy)
+{
+	__be32 *p;
+
+	if (!nfserr) {
+		RESERVE_SPACE(4);
+		WRITE32(copy->u.ok.cr_callback_id_length);
+		ADJUST_ARGS();
+		if (copy->u.ok.cr_callback_id_length == 1)
+			nfsd4_encode_stateid(resp, copy->u.ok.cr_callback_id);
+	} else {
+		RESERVE_SPACE(8);
+		WRITE64(copy->u.cr_bytes_copied);
+		ADJUST_ARGS();
+	}
+
+	return nfserr;
+}
+
+static __be32
 nfsd4_encode_noop(struct nfsd4_compoundres *resp, __be32 nfserr, void *p)
 {
 	return nfserr;
@@ -3465,6 +3507,7 @@ static nfsd4_enc nfsd4_enc_ops[] = {
 	[OP_WANT_DELEGATION]	= (nfsd4_enc)nfsd4_encode_noop,
 	[OP_DESTROY_CLIENTID]	= (nfsd4_enc)nfsd4_encode_noop,
 	[OP_RECLAIM_COMPLETE]	= (nfsd4_enc)nfsd4_encode_noop,
+	[OP_COPY]		= (nfsd4_enc)nfsd4_encode_copy,
 };
 
 /*
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 84ce601..0c1b427 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -28,6 +28,8 @@
 #include <asm/uaccess.h>
 #include <linux/exportfs.h>
 #include <linux/writeback.h>
+#include <linux/fs_struct.h>
+#include <linux/kmod.h>
 
 #ifdef CONFIG_NFSD_V3
 #include "xdr3.h"
@@ -621,6 +623,45 @@ int nfsd4_is_junction(struct dentry *dentry)
 		return 0;
 	return 1;
 }
+
+__be32
+nfsd_copy_range(struct svc_rqst *rqstp, struct svc_fh *fhp_in, u64 pos_in,
+		struct svc_fh *fhp_out, u64 pos_out, u64 count)
+{
+	struct file *filp_in = NULL;
+	struct file *filp_out = NULL;
+	int err;
+
+	/* XXX verify pos and count within sane limits? */
+
+	err = nfsd_open(rqstp, fhp_in, S_IFREG, NFSD_MAY_READ, &filp_in);
+	if (err)
+		goto out;
+
+	err = nfsd_open(rqstp, fhp_out, S_IFREG, NFSD_MAY_WRITE, &filp_out);
+	if (err)
+		goto out;
+
+	err = vfs_copy_range(filp_in, pos_in, filp_out, pos_out, count);
+	/* fall back if .copy_range isn't supported */
+
+	if (!err && EX_ISSYNC(fhp_out->fh_export))
+		err = vfs_fsync_range(filp_out, pos_out, pos_out + count-1, 0);
+
+out:
+	if (filp_in)
+		nfsd_close(filp_in);
+	if (filp_out)
+		nfsd_close(filp_out);
+
+	if (err < 0)
+		err = nfserrno(err);
+	else
+		err = 0;
+
+	return err;
+}
+
 #endif /* defined(CONFIG_NFSD_V4) */
 
 #ifdef CONFIG_NFSD_V3
diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
index 5b58941..bbc9483 100644
--- a/fs/nfsd/vfs.h
+++ b/fs/nfsd/vfs.h
@@ -85,6 +85,9 @@ __be32		nfsd_symlink(struct svc_rqst *, struct svc_fh *,
 				struct svc_fh *res, struct iattr *);
 __be32		nfsd_link(struct svc_rqst *, struct svc_fh *,
 				char *, int, struct svc_fh *);
+__be32		nfsd_copy_range(struct svc_rqst *,
+				struct svc_fh *, u64,
+				struct svc_fh *, u64, u64);
 __be32		nfsd_rename(struct svc_rqst *,
 				struct svc_fh *, char *, int,
 				struct svc_fh *, char *, int);
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index 3b271d2..95fd1c3 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -426,6 +426,26 @@ struct nfsd4_reclaim_complete {
 	u32 rca_one_fs;
 };
 
+struct nfsd4_copy {
+	/* request */
+	u64             ca_src_offset;
+	u64             ca_dst_offset;
+	u64             ca_count;
+	u32             ca_flags;
+	u32             ca_destinationlen;
+	char *          ca_destination;
+
+	/* response */
+	union {
+		struct {
+			u32			cr_callback_id_length;
+			stateid_t *             cr_callback_id;
+		} ok;
+		u64	cr_bytes_copied;
+	} u;
+
+};
+
 struct nfsd4_op {
 	int					opnum;
 	__be32					status;
@@ -471,6 +491,7 @@ struct nfsd4_op {
 		struct nfsd4_reclaim_complete	reclaim_complete;
 		struct nfsd4_test_stateid	test_stateid;
 		struct nfsd4_free_stateid	free_stateid;
+		struct nfsd4_copy		copy;
 	} u;
 	struct nfs4_replay *			replay;
 };
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 7b8fc73..6be484e 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -100,6 +100,7 @@ enum nfs_opnum4 {
 	OP_WANT_DELEGATION = 56,
 	OP_DESTROY_CLIENTID = 57,
 	OP_RECLAIM_COMPLETE = 58,
+	OP_COPY = 59,
 
 	OP_ILLEGAL = 10044,
 };
@@ -108,7 +109,7 @@ enum nfs_opnum4 {
 Needs to be updated if more operations are defined in future.*/
 
 #define FIRST_NFS4_OP	OP_ACCESS
-#define LAST_NFS4_OP 	OP_RECLAIM_COMPLETE
+#define LAST_NFS4_OP	OP_COPY
 
 enum nfsstat4 {
 	NFS4_OK = 0,
@@ -456,6 +457,9 @@ enum {
 	NFSPROC4_CLNT_GETDEVICELIST,
 	NFSPROC4_CLNT_BIND_CONN_TO_SESSION,
 	NFSPROC4_CLNT_DESTROY_CLIENTID,
+
+	/* nfs42 */
+	NFSPROC4_CLNT_COPY,
 };
 
 /* nfs41 types */
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 104b62f..2256e31 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1184,6 +1184,28 @@ struct nfs41_free_stateid_res {
 	unsigned int			status;
 };
 
+struct nfs_copy_args {
+	struct nfs_fh			*fh;
+	struct nfs_fh			*dir_fh;
+	u32				*bitmask;
+	__u64				src_offset;
+	__u64				dst_offset;
+	__u64				count;
+	__u32				flags;
+	const struct qstr		*destination;
+	struct nfs4_sequence_args	seq_args;
+};
+
+struct nfs_copy_res {
+	struct nfs_fh			*fh;
+	struct nfs_fattr		*fattr;
+	__u32				callback_id_length;
+	nfs4_stateid			*callback_id;
+	__u64				bytes_copied;
+	const struct nfs_server		*server;
+	struct nfs4_sequence_res	seq_res;
+};
+
 #else
 
 struct pnfs_ds_commit_info {
@@ -1433,6 +1455,8 @@ struct nfs_rpc_ops {
 	struct nfs_server *(*create_server)(struct nfs_mount_info *, struct nfs_subversion *);
 	struct nfs_server *(*clone_server)(struct nfs_server *, struct nfs_fh *,
 					   struct nfs_fattr *, rpc_authflavor_t);
+	loff_t  (*copy)    (struct inode *, struct inode *, struct qstr *,
+				int, loff_t, loff_t, loff_t);
 };
 
 /*
-- 
1.7.11.7

