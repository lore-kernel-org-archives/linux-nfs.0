Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:44570 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932610AbdELQRu (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 12 May 2017 12:17:50 -0400
From: Christoph Hellwig <hch@lst.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 13/33] nfs: don't cast callback decode/proc/encode routines
Date: Fri, 12 May 2017 18:16:41 +0200
Message-Id: <20170512161701.22468-14-hch@lst.de>
In-Reply-To: <20170512161701.22468-1-hch@lst.de>
References: <20170512161701.22468-1-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Instead declare all functions with the proper methods signature.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Jeff Layton <jlayton@redhat.com>
Acked-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/callback.h      | 27 ++++++----------
 fs/nfs/callback_proc.c | 33 ++++++++++++-------
 fs/nfs/callback_xdr.c  | 86 +++++++++++++++++++++++++++-----------------------
 3 files changed, 77 insertions(+), 69 deletions(-)

diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
index c701c308fac5..3dc54d7cb19c 100644
--- a/fs/nfs/callback.h
+++ b/fs/nfs/callback.h
@@ -114,8 +114,7 @@ struct cb_sequenceres {
 	uint32_t			csr_target_highestslotid;
 };
 
-extern __be32 nfs4_callback_sequence(struct cb_sequenceargs *args,
-				       struct cb_sequenceres *res,
+extern __be32 nfs4_callback_sequence(void *argp, void *resp,
 				       struct cb_process_state *cps);
 
 #define RCA4_TYPE_MASK_RDATA_DLG	0
@@ -134,15 +133,13 @@ struct cb_recallanyargs {
 	uint32_t	craa_type_mask;
 };
 
-extern __be32 nfs4_callback_recallany(struct cb_recallanyargs *args,
-					void *dummy,
+extern __be32 nfs4_callback_recallany(void *argp, void *resp,
 					struct cb_process_state *cps);
 
 struct cb_recallslotargs {
 	uint32_t	crsa_target_highest_slotid;
 };
-extern __be32 nfs4_callback_recallslot(struct cb_recallslotargs *args,
-					 void *dummy,
+extern __be32 nfs4_callback_recallslot(void *argp, void *resp,
 					 struct cb_process_state *cps);
 
 struct cb_layoutrecallargs {
@@ -159,9 +156,8 @@ struct cb_layoutrecallargs {
 	};
 };
 
-extern __be32 nfs4_callback_layoutrecall(
-	struct cb_layoutrecallargs *args,
-	void *dummy, struct cb_process_state *cps);
+extern __be32 nfs4_callback_layoutrecall(void *argp, void *resp,
+		struct cb_process_state *cps);
 
 struct cb_devicenotifyitem {
 	uint32_t		cbd_notify_type;
@@ -175,9 +171,8 @@ struct cb_devicenotifyargs {
 	struct cb_devicenotifyitem	 *devs;
 };
 
-extern __be32 nfs4_callback_devicenotify(
-	struct cb_devicenotifyargs *args,
-	void *dummy, struct cb_process_state *cps);
+extern __be32 nfs4_callback_devicenotify(void *argp, void *resp,
+		struct cb_process_state *cps);
 
 struct cb_notify_lock_args {
 	struct nfs_fh			cbnl_fh;
@@ -185,15 +180,13 @@ struct cb_notify_lock_args {
 	bool				cbnl_valid;
 };
 
-extern __be32 nfs4_callback_notify_lock(struct cb_notify_lock_args *args,
-					 void *dummy,
+extern __be32 nfs4_callback_notify_lock(void *argp, void *resp,
 					 struct cb_process_state *cps);
 #endif /* CONFIG_NFS_V4_1 */
 extern int check_gss_callback_principal(struct nfs_client *, struct svc_rqst *);
-extern __be32 nfs4_callback_getattr(struct cb_getattrargs *args,
-				    struct cb_getattrres *res,
+extern __be32 nfs4_callback_getattr(void *argp, void *resp,
 				    struct cb_process_state *cps);
-extern __be32 nfs4_callback_recall(struct cb_recallargs *args, void *dummy,
+extern __be32 nfs4_callback_recall(void *argp, void *resp,
 				   struct cb_process_state *cps);
 #if IS_ENABLED(CONFIG_NFS_V4)
 extern int nfs_callback_up(u32 minorversion, struct rpc_xprt *xprt);
diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 52479f180ea1..5427cdf04c5a 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -19,10 +19,11 @@
 
 #define NFSDBG_FACILITY NFSDBG_CALLBACK
 
-__be32 nfs4_callback_getattr(struct cb_getattrargs *args,
-			     struct cb_getattrres *res,
+__be32 nfs4_callback_getattr(void *argp, void *resp,
 			     struct cb_process_state *cps)
 {
+	struct cb_getattrargs *args = argp;
+	struct cb_getattrres *res = resp;
 	struct nfs_delegation *delegation;
 	struct nfs_inode *nfsi;
 	struct inode *inode;
@@ -68,9 +69,10 @@ __be32 nfs4_callback_getattr(struct cb_getattrargs *args,
 	return res->status;
 }
 
-__be32 nfs4_callback_recall(struct cb_recallargs *args, void *dummy,
+__be32 nfs4_callback_recall(void *argp, void *resp,
 			    struct cb_process_state *cps)
 {
+	struct cb_recallargs *args = argp;
 	struct inode *inode;
 	__be32 res;
 	
@@ -324,9 +326,10 @@ static u32 do_callback_layoutrecall(struct nfs_client *clp,
 	return initiate_bulk_draining(clp, args);
 }
 
-__be32 nfs4_callback_layoutrecall(struct cb_layoutrecallargs *args,
-				  void *dummy, struct cb_process_state *cps)
+__be32 nfs4_callback_layoutrecall(void *argp, void *resp,
+				  struct cb_process_state *cps)
 {
+	struct cb_layoutrecallargs *args = argp;
 	u32 res = NFS4ERR_OP_NOT_IN_SESSION;
 
 	if (cps->clp)
@@ -345,9 +348,10 @@ static void pnfs_recall_all_layouts(struct nfs_client *clp)
 	do_callback_layoutrecall(clp, &args);
 }
 
-__be32 nfs4_callback_devicenotify(struct cb_devicenotifyargs *args,
-				  void *dummy, struct cb_process_state *cps)
+__be32 nfs4_callback_devicenotify(void *argp, void *resp,
+				  struct cb_process_state *cps)
 {
+	struct cb_devicenotifyargs *args = argp;
 	int i;
 	__be32 res = 0;
 	struct nfs_client *clp = cps->clp;
@@ -469,10 +473,11 @@ static bool referring_call_exists(struct nfs_client *clp,
 	return status;
 }
 
-__be32 nfs4_callback_sequence(struct cb_sequenceargs *args,
-			      struct cb_sequenceres *res,
+__be32 nfs4_callback_sequence(void *argp, void *resp,
 			      struct cb_process_state *cps)
 {
+	struct cb_sequenceargs *args = argp;
+	struct cb_sequenceres *res = resp;
 	struct nfs4_slot_table *tbl;
 	struct nfs4_slot *slot;
 	struct nfs_client *clp;
@@ -571,9 +576,10 @@ validate_bitmap_values(unsigned long mask)
 	return (mask & ~RCA4_TYPE_MASK_ALL) == 0;
 }
 
-__be32 nfs4_callback_recallany(struct cb_recallanyargs *args, void *dummy,
+__be32 nfs4_callback_recallany(void *argp, void *resp,
 			       struct cb_process_state *cps)
 {
+	struct cb_recallanyargs *args = argp;
 	__be32 status;
 	fmode_t flags = 0;
 
@@ -606,9 +612,10 @@ __be32 nfs4_callback_recallany(struct cb_recallanyargs *args, void *dummy,
 }
 
 /* Reduce the fore channel's max_slots to the target value */
-__be32 nfs4_callback_recallslot(struct cb_recallslotargs *args, void *dummy,
+__be32 nfs4_callback_recallslot(void *argp, void *resp,
 				struct cb_process_state *cps)
 {
+	struct cb_recallslotargs *args = argp;
 	struct nfs4_slot_table *fc_tbl;
 	__be32 status;
 
@@ -631,9 +638,11 @@ __be32 nfs4_callback_recallslot(struct cb_recallslotargs *args, void *dummy,
 	return status;
 }
 
-__be32 nfs4_callback_notify_lock(struct cb_notify_lock_args *args, void *dummy,
+__be32 nfs4_callback_notify_lock(void *argp, void *resp,
 				 struct cb_process_state *cps)
 {
+	struct cb_notify_lock_args *args = argp;
+
 	if (!cps->clp) /* set in cb_sequence */
 		return htonl(NFS4ERR_OP_NOT_IN_SESSION);
 
diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index c14758e08d73..287c02202b25 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -43,16 +43,11 @@
 /* Internal error code */
 #define NFS4ERR_RESOURCE_HDR	11050
 
-typedef __be32 (*callback_process_op_t)(void *, void *,
-					struct cb_process_state *);
-typedef __be32 (*callback_decode_arg_t)(struct svc_rqst *, struct xdr_stream *, void *);
-typedef __be32 (*callback_encode_res_t)(struct svc_rqst *, struct xdr_stream *, void *);
-
-
 struct callback_op {
-	callback_process_op_t process_op;
-	callback_decode_arg_t decode_args;
-	callback_encode_res_t encode_res;
+	__be32 (*process_op)(void *, void *, struct cb_process_state *);
+	__be32 (*decode_args)(struct svc_rqst *, struct xdr_stream *, void *);
+	__be32 (*encode_res)(struct svc_rqst *, struct xdr_stream *,
+			const void *);
 	long res_maxsize;
 };
 
@@ -184,8 +179,10 @@ static __be32 decode_op_hdr(struct xdr_stream *xdr, unsigned int *op)
 	return 0;
 }
 
-static __be32 decode_getattr_args(struct svc_rqst *rqstp, struct xdr_stream *xdr, struct cb_getattrargs *args)
+static __be32 decode_getattr_args(struct svc_rqst *rqstp,
+		struct xdr_stream *xdr, void *argp)
 {
+	struct cb_getattrargs *args = argp;
 	__be32 status;
 
 	status = decode_fh(xdr, &args->fh);
@@ -194,8 +191,10 @@ static __be32 decode_getattr_args(struct svc_rqst *rqstp, struct xdr_stream *xdr
 	return decode_bitmap(xdr, args->bitmap);
 }
 
-static __be32 decode_recall_args(struct svc_rqst *rqstp, struct xdr_stream *xdr, struct cb_recallargs *args)
+static __be32 decode_recall_args(struct svc_rqst *rqstp,
+		struct xdr_stream *xdr, void *argp)
 {
+	struct cb_recallargs *args = argp;
 	__be32 *p;
 	__be32 status;
 
@@ -217,9 +216,9 @@ static __be32 decode_layout_stateid(struct xdr_stream *xdr, nfs4_stateid *statei
 }
 
 static __be32 decode_layoutrecall_args(struct svc_rqst *rqstp,
-				       struct xdr_stream *xdr,
-				       struct cb_layoutrecallargs *args)
+				       struct xdr_stream *xdr, void *argp)
 {
+	struct cb_layoutrecallargs *args = argp;
 	__be32 *p;
 	__be32 status = 0;
 	uint32_t iomode;
@@ -262,8 +261,9 @@ static __be32 decode_layoutrecall_args(struct svc_rqst *rqstp,
 static
 __be32 decode_devicenotify_args(struct svc_rqst *rqstp,
 				struct xdr_stream *xdr,
-				struct cb_devicenotifyargs *args)
+				void *argp)
 {
+	struct cb_devicenotifyargs *args = argp;
 	__be32 *p;
 	__be32 status = 0;
 	u32 tmp;
@@ -403,8 +403,9 @@ static __be32 decode_rc_list(struct xdr_stream *xdr,
 
 static __be32 decode_cb_sequence_args(struct svc_rqst *rqstp,
 					struct xdr_stream *xdr,
-					struct cb_sequenceargs *args)
+					void *argp)
 {
+	struct cb_sequenceargs *args = argp;
 	__be32 *p;
 	int i;
 	__be32 status;
@@ -450,8 +451,9 @@ static __be32 decode_cb_sequence_args(struct svc_rqst *rqstp,
 
 static __be32 decode_recallany_args(struct svc_rqst *rqstp,
 				      struct xdr_stream *xdr,
-				      struct cb_recallanyargs *args)
+				      void *argp)
 {
+	struct cb_recallanyargs *args = argp;
 	uint32_t bitmap[2];
 	__be32 *p, status;
 
@@ -469,8 +471,9 @@ static __be32 decode_recallany_args(struct svc_rqst *rqstp,
 
 static __be32 decode_recallslot_args(struct svc_rqst *rqstp,
 					struct xdr_stream *xdr,
-					struct cb_recallslotargs *args)
+					void *argp)
 {
+	struct cb_recallslotargs *args = argp;
 	__be32 *p;
 
 	p = read_buf(xdr, 4);
@@ -510,8 +513,10 @@ static __be32 decode_lockowner(struct xdr_stream *xdr, struct cb_notify_lock_arg
 	return 0;
 }
 
-static __be32 decode_notify_lock_args(struct svc_rqst *rqstp, struct xdr_stream *xdr, struct cb_notify_lock_args *args)
+static __be32 decode_notify_lock_args(struct svc_rqst *rqstp,
+		struct xdr_stream *xdr, void *argp)
 {
+	struct cb_notify_lock_args *args = argp;
 	__be32 status;
 
 	status = decode_fh(xdr, &args->cbnl_fh);
@@ -641,8 +646,10 @@ static __be32 encode_op_hdr(struct xdr_stream *xdr, uint32_t op, __be32 res)
 	return 0;
 }
 
-static __be32 encode_getattr_res(struct svc_rqst *rqstp, struct xdr_stream *xdr, const struct cb_getattrres *res)
+static __be32 encode_getattr_res(struct svc_rqst *rqstp, struct xdr_stream *xdr,
+		const void *resp)
 {
+	const struct cb_getattrres *res = resp;
 	__be32 *savep = NULL;
 	__be32 status = res->status;
 	
@@ -683,8 +690,9 @@ static __be32 encode_sessionid(struct xdr_stream *xdr,
 
 static __be32 encode_cb_sequence_res(struct svc_rqst *rqstp,
 				       struct xdr_stream *xdr,
-				       const struct cb_sequenceres *res)
+				       const void *resp)
 {
+	const struct cb_sequenceres *res = resp;
 	__be32 *p;
 	__be32 status = res->csr_status;
 
@@ -938,48 +946,46 @@ static struct callback_op callback_ops[] = {
 		.res_maxsize = CB_OP_HDR_RES_MAXSZ,
 	},
 	[OP_CB_GETATTR] = {
-		.process_op = (callback_process_op_t)nfs4_callback_getattr,
-		.decode_args = (callback_decode_arg_t)decode_getattr_args,
-		.encode_res = (callback_encode_res_t)encode_getattr_res,
+		.process_op = nfs4_callback_getattr,
+		.decode_args = decode_getattr_args,
+		.encode_res = encode_getattr_res,
 		.res_maxsize = CB_OP_GETATTR_RES_MAXSZ,
 	},
 	[OP_CB_RECALL] = {
-		.process_op = (callback_process_op_t)nfs4_callback_recall,
-		.decode_args = (callback_decode_arg_t)decode_recall_args,
+		.process_op = nfs4_callback_recall,
+		.decode_args = decode_recall_args,
 		.res_maxsize = CB_OP_RECALL_RES_MAXSZ,
 	},
 #if defined(CONFIG_NFS_V4_1)
 	[OP_CB_LAYOUTRECALL] = {
-		.process_op = (callback_process_op_t)nfs4_callback_layoutrecall,
-		.decode_args =
-			(callback_decode_arg_t)decode_layoutrecall_args,
+		.process_op = nfs4_callback_layoutrecall,
+		.decode_args = decode_layoutrecall_args,
 		.res_maxsize = CB_OP_LAYOUTRECALL_RES_MAXSZ,
 	},
 	[OP_CB_NOTIFY_DEVICEID] = {
-		.process_op = (callback_process_op_t)nfs4_callback_devicenotify,
-		.decode_args =
-			(callback_decode_arg_t)decode_devicenotify_args,
+		.process_op = nfs4_callback_devicenotify,
+		.decode_args = decode_devicenotify_args,
 		.res_maxsize = CB_OP_DEVICENOTIFY_RES_MAXSZ,
 	},
 	[OP_CB_SEQUENCE] = {
-		.process_op = (callback_process_op_t)nfs4_callback_sequence,
-		.decode_args = (callback_decode_arg_t)decode_cb_sequence_args,
-		.encode_res = (callback_encode_res_t)encode_cb_sequence_res,
+		.process_op = nfs4_callback_sequence,
+		.decode_args = decode_cb_sequence_args,
+		.encode_res = encode_cb_sequence_res,
 		.res_maxsize = CB_OP_SEQUENCE_RES_MAXSZ,
 	},
 	[OP_CB_RECALL_ANY] = {
-		.process_op = (callback_process_op_t)nfs4_callback_recallany,
-		.decode_args = (callback_decode_arg_t)decode_recallany_args,
+		.process_op = nfs4_callback_recallany,
+		.decode_args = decode_recallany_args,
 		.res_maxsize = CB_OP_RECALLANY_RES_MAXSZ,
 	},
 	[OP_CB_RECALL_SLOT] = {
-		.process_op = (callback_process_op_t)nfs4_callback_recallslot,
-		.decode_args = (callback_decode_arg_t)decode_recallslot_args,
+		.process_op = nfs4_callback_recallslot,
+		.decode_args = decode_recallslot_args,
 		.res_maxsize = CB_OP_RECALLSLOT_RES_MAXSZ,
 	},
 	[OP_CB_NOTIFY_LOCK] = {
-		.process_op = (callback_process_op_t)nfs4_callback_notify_lock,
-		.decode_args = (callback_decode_arg_t)decode_notify_lock_args,
+		.process_op = nfs4_callback_notify_lock,
+		.decode_args = decode_notify_lock_args,
 		.res_maxsize = CB_OP_NOTIFY_LOCK_RES_MAXSZ,
 	},
 #endif /* CONFIG_NFS_V4_1 */
-- 
2.11.0

