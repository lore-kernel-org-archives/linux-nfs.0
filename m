Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:20445 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933484Ab0LUCVB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Dec 2010 21:21:01 -0500
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 11/14] pnfs: wave 2: CB_LAYOUTRECALL xdr code
Date: Mon, 20 Dec 2010 21:20:43 -0500
Message-Id: <1292898046-7336-12-git-send-email-iisaman@netapp.com>
In-Reply-To: <1292898046-7336-1-git-send-email-iisaman@netapp.com>
References: <1292898046-7336-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

This is the xdr decoding for CB_LAYOUTRECALL.

Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
Signed-off-by: Dean Hildebrand <dhildeb@us.ibm.com>
Signed-off-by: Marc Eshel <eshel@almaden.ibm.com>
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/callback.h      |   20 ++++++++++++++
 fs/nfs/callback_proc.c |    6 ++++
 fs/nfs/callback_xdr.c  |   69 +++++++++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 94 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
index b678e3e..19570f4 100644
--- a/fs/nfs/callback.h
+++ b/fs/nfs/callback.h
@@ -138,6 +138,26 @@ extern __be32 nfs4_callback_recallslot(struct cb_recallslotargs *args,
 					 void *dummy,
 					 struct cb_process_state *cps);
 
+struct cb_layoutrecallargs {
+	struct sockaddr		*cbl_addr;
+	uint32_t		cbl_recall_type;
+	uint32_t		cbl_layout_type;
+	uint32_t		cbl_layoutchanged;
+	union {
+		struct {
+			struct nfs_fh		cbl_fh;
+			struct inode		*cbl_inode;
+			struct pnfs_layout_range cbl_range;
+			nfs4_stateid		cbl_stateid;
+		};
+		struct nfs_fsid		cbl_fsid;
+	};
+};
+
+extern unsigned nfs4_callback_layoutrecall(
+	struct cb_layoutrecallargs *args,
+	void *dummy, struct cb_process_state *cps);
+
 extern void nfs4_check_drain_bc_complete(struct nfs4_session *ses);
 extern void nfs4_cb_take_slot(struct nfs_client *clp);
 #endif /* CONFIG_NFS_V4_1 */
diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index c1bead2..c1bb157 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -107,6 +107,12 @@ int nfs4_validate_delegation_stateid(struct nfs_delegation *delegation, const nf
 
 #if defined(CONFIG_NFS_V4_1)
 
+__be32 nfs4_callback_layoutrecall(struct cb_layoutrecallargs *args,
+				  void *dummy, struct cb_process_state *cps)
+{
+	return cpu_to_be32(NFS4ERR_NOTSUPP); /* STUB */
+}
+
 int nfs41_validate_delegation_stateid(struct nfs_delegation *delegation, const nfs4_stateid *stateid)
 {
 	if (delegation == NULL)
diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 9dbccf4..1523c99 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -24,6 +24,7 @@
 #define CB_OP_RECALL_RES_MAXSZ	(CB_OP_HDR_RES_MAXSZ)
 
 #if defined(CONFIG_NFS_V4_1)
+#define CB_OP_LAYOUTRECALL_RES_MAXSZ	(CB_OP_HDR_RES_MAXSZ)
 #define CB_OP_SEQUENCE_RES_MAXSZ	(CB_OP_HDR_RES_MAXSZ + \
 					4 + 1 + 3)
 #define CB_OP_RECALLANY_RES_MAXSZ	(CB_OP_HDR_RES_MAXSZ)
@@ -223,6 +224,66 @@ out:
 
 #if defined(CONFIG_NFS_V4_1)
 
+static __be32 decode_layoutrecall_args(struct svc_rqst *rqstp,
+				       struct xdr_stream *xdr,
+				       struct cb_layoutrecallargs *args)
+{
+	__be32 *p;
+	__be32 status = 0;
+	uint32_t iomode;
+
+	args->cbl_addr = svc_addr(rqstp);
+	p = read_buf(xdr, 4 * sizeof(uint32_t));
+	if (unlikely(p == NULL)) {
+		status = htonl(NFS4ERR_BADXDR);
+		goto out;
+	}
+
+	args->cbl_layout_type = ntohl(*p++);
+	/* Depite the spec's xdr, iomode really belongs in the FILE switch,
+	 * as it is unuseable and ignored with the other types.
+	 */
+	iomode = ntohl(*p++);
+	args->cbl_layoutchanged = ntohl(*p++);
+	args->cbl_recall_type = ntohl(*p++);
+
+	if (args->cbl_recall_type == RETURN_FILE) {
+		args->cbl_range.iomode = iomode;
+		status = decode_fh(xdr, &args->cbl_fh);
+		if (unlikely(status != 0))
+			goto out;
+
+		p = read_buf(xdr, 2 * sizeof(uint64_t));
+		if (unlikely(p == NULL)) {
+			status = htonl(NFS4ERR_BADXDR);
+			goto out;
+		}
+		p = xdr_decode_hyper(p, &args->cbl_range.offset);
+		p = xdr_decode_hyper(p, &args->cbl_range.length);
+		status = decode_stateid(xdr, &args->cbl_stateid);
+		if (unlikely(status != 0))
+			goto out;
+	} else if (args->cbl_recall_type == RETURN_FSID) {
+		p = read_buf(xdr, 2 * sizeof(uint64_t));
+		if (unlikely(p == NULL)) {
+			status = htonl(NFS4ERR_BADXDR);
+			goto out;
+		}
+		p = xdr_decode_hyper(p, &args->cbl_fsid.major);
+		p = xdr_decode_hyper(p, &args->cbl_fsid.minor);
+	} else if (args->cbl_recall_type != RETURN_ALL) {
+		status = htonl(NFS4ERR_BADXDR);
+		goto out;
+	}
+	dprintk("%s: ltype 0x%x iomode %d changed %d recall_type %d\n",
+		__func__,
+		args->cbl_layout_type, iomode,
+		args->cbl_layoutchanged, args->cbl_recall_type);
+out:
+	dprintk("%s: exit with status = %d\n", __func__, ntohl(status));
+	return status;
+}
+
 static __be32 decode_sessionid(struct xdr_stream *xdr,
 				 struct nfs4_sessionid *sid)
 {
@@ -577,10 +638,10 @@ preprocess_nfs41_op(int nop, unsigned int op_nr, struct callback_op **op)
 	case OP_CB_SEQUENCE:
 	case OP_CB_RECALL_ANY:
 	case OP_CB_RECALL_SLOT:
+	case OP_CB_LAYOUTRECALL:
 		*op = &callback_ops[op_nr];
 		break;
 
-	case OP_CB_LAYOUTRECALL:
 	case OP_CB_NOTIFY_DEVICEID:
 	case OP_CB_NOTIFY:
 	case OP_CB_PUSH_DELEG:
@@ -784,6 +845,12 @@ static struct callback_op callback_ops[] = {
 		.res_maxsize = CB_OP_RECALL_RES_MAXSZ,
 	},
 #if defined(CONFIG_NFS_V4_1)
+	[OP_CB_LAYOUTRECALL] = {
+		.process_op = (callback_process_op_t)nfs4_callback_layoutrecall,
+		.decode_args =
+			(callback_decode_arg_t)decode_layoutrecall_args,
+		.res_maxsize = CB_OP_LAYOUTRECALL_RES_MAXSZ,
+	},
 	[OP_CB_SEQUENCE] = {
 		.process_op = (callback_process_op_t)nfs4_callback_sequence,
 		.decode_args = (callback_decode_arg_t)decode_cb_sequence_args,
-- 
1.7.2.1

