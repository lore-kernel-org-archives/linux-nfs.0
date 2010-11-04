Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:33432 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752431Ab0KDPWv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Nov 2010 11:22:51 -0400
Received: from localhost.localdomain (dnsindia.hq.netapp.com [10.58.52.94] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id oA4FMYMN029583
	for <linux-nfs@vger.kernel.org>; Thu, 4 Nov 2010 08:22:35 -0700 (PDT)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 01/18] NFSv4.1: Callback share session between ops
Date: Thu,  4 Nov 2010 11:22:14 -0400
Message-Id: <1288884151-11128-2-git-send-email-iisaman@netapp.com>
In-Reply-To: <1288884151-11128-1-git-send-email-iisaman@netapp.com>
References: <1288884151-11128-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

The NFSv4.1 session found in cb_sequence needs to be shared by other
callback operations in the same cb_compound.
Hold a reference to the session's nfs_client throughout the cb_compound
processing.

Move NFS4ERR_RETRY_UNCACHED_REP processing into nfs4_callback_sequence.

Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/callback.h      |   24 ++++++--
 fs/nfs/callback_proc.c |  138 ++++++++++++++++++++++++++++--------------------
 fs/nfs/callback_xdr.c  |   29 +++++-----
 3 files changed, 113 insertions(+), 78 deletions(-)

diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
index 2ce61b8..89fee05 100644
--- a/fs/nfs/callback.h
+++ b/fs/nfs/callback.h
@@ -34,6 +34,11 @@ enum nfs4_callback_opnum {
 	OP_CB_ILLEGAL = 10044,
 };
 
+struct cb_process_state {
+	__be32			drc_status;
+	struct nfs4_session	*session;
+};
+
 struct cb_compound_hdr_arg {
 	unsigned int taglen;
 	const char *tag;
@@ -104,7 +109,8 @@ struct cb_sequenceres {
 };
 
 extern unsigned nfs4_callback_sequence(struct cb_sequenceargs *args,
-				       struct cb_sequenceres *res);
+				       struct cb_sequenceres *res,
+				       struct cb_process_state *cps);
 
 extern int nfs41_validate_delegation_stateid(struct nfs_delegation *delegation,
 					     const nfs4_stateid *stateid);
@@ -125,14 +131,17 @@ struct cb_recallanyargs {
 	uint32_t	craa_type_mask;
 };
 
-extern unsigned nfs4_callback_recallany(struct cb_recallanyargs *args, void *dummy);
+extern unsigned nfs4_callback_recallany(struct cb_recallanyargs *args,
+					void *dummy,
+					struct cb_process_state *cps);
 
 struct cb_recallslotargs {
 	struct sockaddr	*crsa_addr;
 	uint32_t	crsa_target_max_slots;
 };
 extern unsigned nfs4_callback_recallslot(struct cb_recallslotargs *args,
-					  void *dummy);
+					 void *dummy,
+					 struct cb_process_state *cps);
 
 struct cb_layoutrecallargs {
 	struct sockaddr		*cbl_addr;
@@ -147,12 +156,15 @@ struct cb_layoutrecallargs {
 
 extern unsigned nfs4_callback_layoutrecall(
 	struct cb_layoutrecallargs *args,
-	void *dummy);
+	void *dummy, struct cb_process_state *cps);
 
 #endif /* CONFIG_NFS_V4_1 */
 
-extern __be32 nfs4_callback_getattr(struct cb_getattrargs *args, struct cb_getattrres *res);
-extern __be32 nfs4_callback_recall(struct cb_recallargs *args, void *dummy);
+extern __be32 nfs4_callback_getattr(struct cb_getattrargs *args,
+				    struct cb_getattrres *res,
+				    struct cb_process_state *cps);
+extern __be32 nfs4_callback_recall(struct cb_recallargs *args, void *dummy,
+				   struct cb_process_state *cps);
 
 #ifdef CONFIG_NFS_V4
 extern int nfs_callback_up(u32 minorversion, struct rpc_xprt *xprt);
diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 6b560ce..84c5a1b 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -20,8 +20,10 @@
 #ifdef NFS_DEBUG
 #define NFSDBG_FACILITY NFSDBG_CALLBACK
 #endif
- 
-__be32 nfs4_callback_getattr(struct cb_getattrargs *args, struct cb_getattrres *res)
+
+__be32 nfs4_callback_getattr(struct cb_getattrargs *args,
+			     struct cb_getattrres *res,
+			     struct cb_process_state *cps)
 {
 	struct nfs_client *clp;
 	struct nfs_delegation *delegation;
@@ -30,9 +32,13 @@ __be32 nfs4_callback_getattr(struct cb_getattrargs *args, struct cb_getattrres *
 
 	res->bitmap[0] = res->bitmap[1] = 0;
 	res->status = htonl(NFS4ERR_BADHANDLE);
-	clp = nfs_find_client(args->addr, 4);
-	if (clp == NULL)
-		goto out;
+	if (cps->session) { /* set in cb_sequence */
+		clp = cps->session->clp;
+	} else {
+		clp = nfs_find_client(args->addr, 4);
+		if (clp == NULL)
+			goto out;
+	}
 
 	dprintk("NFS: GETATTR callback request from %s\n",
 		rpc_peeraddr2str(clp->cl_rpcclient, RPC_DISPLAY_ADDR));
@@ -60,22 +66,28 @@ out_iput:
 	rcu_read_unlock();
 	iput(inode);
 out_putclient:
-	nfs_put_client(clp);
+	if (!cps->session)
+		nfs_put_client(clp);
 out:
 	dprintk("%s: exit with status = %d\n", __func__, ntohl(res->status));
 	return res->status;
 }
 
-__be32 nfs4_callback_recall(struct cb_recallargs *args, void *dummy)
+__be32 nfs4_callback_recall(struct cb_recallargs *args, void *dummy,
+			    struct cb_process_state *cps)
 {
 	struct nfs_client *clp;
 	struct inode *inode;
 	__be32 res;
 	
 	res = htonl(NFS4ERR_BADHANDLE);
-	clp = nfs_find_client(args->addr, 4);
-	if (clp == NULL)
-		goto out;
+	if (cps->session) { /* set in cb_sequence */
+		clp = cps->session->clp;
+	} else {
+		clp = nfs_find_client(args->addr, 4);
+		if (clp == NULL)
+			goto out;
+	}
 
 	dprintk("NFS: RECALL callback request from %s\n",
 		rpc_peeraddr2str(clp->cl_rpcclient, RPC_DISPLAY_ADDR));
@@ -99,9 +111,11 @@ __be32 nfs4_callback_recall(struct cb_recallargs *args, void *dummy)
 			}
 			iput(inode);
 		}
-		clp = nfs_find_client_next(prev);
-		nfs_put_client(prev);
-	} while (clp != NULL);
+		if (!cps->session) {
+			clp = nfs_find_client_next(prev);
+			nfs_put_client(prev);
+		}
+	} while (!cps->session && clp != NULL);
 out:
 	dprintk("%s: exit with status = %d\n", __func__, ntohl(res));
 	return res;
@@ -346,46 +360,40 @@ static int pnfs_recall_all_layouts(struct nfs_client *clp)
 }
 
 __be32 nfs4_callback_layoutrecall(struct cb_layoutrecallargs *args,
-				  void *dummy)
+				  void *dummy, struct cb_process_state *cps)
 {
 	struct nfs_client *clp;
 	struct inode *inode = NULL;
 	__be32 res;
 	int status;
-	unsigned int num_client = 0;
 
 	dprintk("%s: -->\n", __func__);
 
 	res = cpu_to_be32(NFS4ERR_OP_NOT_IN_SESSION);
-	clp  = nfs_find_client(args->cbl_addr, 4);
-	if (clp == NULL)
+	if (cps->session) /* set in cb_sequence */
+		clp = cps->session->clp;
+	else
 		goto out;
 
-	res = cpu_to_be32(NFS4ERR_NOMATCHING_LAYOUT);
-	do {
-		struct nfs_client *prev = clp;
-		num_client++;
-		/* the callback must come from the MDS personality */
-		if (!(clp->cl_exchange_flags & EXCHGID4_FLAG_USE_PNFS_MDS))
-			goto loop;
-		/* In the _ALL or _FSID case, we need the inode to get
-		 * the nfs_server struct.
-		 */
-		inode = nfs_layoutrecall_find_inode(clp, args);
-		if (!inode)
-			goto loop;
-		status = pnfs_async_return_layout(clp, inode, args);
-		if (status)
-			res = cpu_to_be32(NFS4ERR_DELAY);
-		iput(inode);
-loop:
-		clp = nfs_find_client_next(prev);
-		nfs_put_client(prev);
-	} while (clp != NULL);
+	/* the callback must come from the MDS personality */
+	res = cpu_to_be32(NFS4ERR_NOTSUPP);
+	if (!(clp->cl_exchange_flags & EXCHGID4_FLAG_USE_PNFS_MDS))
+		goto out;
 
+	res = cpu_to_be32(NFS4ERR_NOMATCHING_LAYOUT);
+	/*
+	 * In the _ALL or _FSID case, we need the inode to get
+	 * the nfs_server struct.
+	 */
+	inode = nfs_layoutrecall_find_inode(clp, args);
+	if (!inode)
+		goto out;
+	status = pnfs_async_return_layout(clp, inode, args);
+	if (status)
+		res = cpu_to_be32(NFS4ERR_DELAY);
+	iput(inode);
 out:
-	dprintk("%s: exit with status = %d numclient %u\n",
-		__func__, ntohl(res), num_client);
+	dprintk("%s: exit with status = %d\n", __func__, ntohl(res));
 	return res;
 }
 
@@ -552,12 +560,15 @@ out:
 }
 
 __be32 nfs4_callback_sequence(struct cb_sequenceargs *args,
-				struct cb_sequenceres *res)
+			      struct cb_sequenceres *res,
+			      struct cb_process_state *cps)
 {
 	struct nfs_client *clp;
 	int i;
 	__be32 status;
 
+	cps->session = NULL;
+
 	status = htonl(NFS4ERR_BADSESSION);
 	clp = find_client_with_session(args->csa_addr, 4, &args->csa_sessionid);
 	if (clp == NULL)
@@ -583,21 +594,27 @@ __be32 nfs4_callback_sequence(struct cb_sequenceargs *args,
 	res->csr_slotid = args->csa_slotid;
 	res->csr_highestslotid = NFS41_BC_MAX_CALLBACKS - 1;
 	res->csr_target_highestslotid = NFS41_BC_MAX_CALLBACKS - 1;
+	cps->session = clp->cl_session; /* caller must put nfs_client */
 
-out_putclient:
-	nfs_put_client(clp);
 out:
 	for (i = 0; i < args->csa_nrclists; i++)
 		kfree(args->csa_rclists[i].rcl_refcalls);
 	kfree(args->csa_rclists);
 
-	if (status == htonl(NFS4ERR_RETRY_UNCACHED_REP))
+	if (status == htonl(NFS4ERR_RETRY_UNCACHED_REP)) {
 		res->csr_status = 0;
-	else
+		cps->drc_status = status;
+		status = 0;
+	} else
 		res->csr_status = status;
+
 	dprintk("%s: exit with status = %d res->csr_status %d\n", __func__,
 		ntohl(status), ntohl(res->csr_status));
 	return status;
+
+out_putclient:
+	nfs_put_client(clp);
+	goto out;
 }
 
 static inline bool
@@ -624,24 +641,31 @@ validate_bitmap_values(const unsigned long *mask)
 	return false;
 }
 
-__be32 nfs4_callback_recallany(struct cb_recallanyargs *args, void *dummy)
+__be32 nfs4_callback_recallany(struct cb_recallanyargs *args, void *dummy,
+			       struct cb_process_state *cps)
 {
 	struct nfs_client *clp;
 	__be32 status;
 	fmode_t flags = 0;
 
 	status = cpu_to_be32(NFS4ERR_OP_NOT_IN_SESSION);
-	clp = nfs_find_client(args->craa_addr, 4);
-	if (clp == NULL)
+	if (cps->session) /* set in cb_sequence */
+		clp = cps->session->clp;
+	else
 		goto out;
 
 	dprintk("NFS: RECALL_ANY callback request from %s\n",
 		rpc_peeraddr2str(clp->cl_rpcclient, RPC_DISPLAY_ADDR));
 
+	/* the callback must come from the MDS personality */
+	status = cpu_to_be32(NFS4ERR_NOTSUPP);
+	if (!(clp->cl_exchange_flags & EXCHGID4_FLAG_USE_PNFS_MDS))
+		goto out;
+
 	status = cpu_to_be32(NFS4ERR_INVAL);
 	if (!validate_bitmap_values((const unsigned long *)
 				    &args->craa_type_mask))
-		goto out_put;
+		goto out;
 
 	status = cpu_to_be32(NFS4_OK);
 	if (test_bit(RCA4_TYPE_MASK_RDATA_DLG, (const unsigned long *)
@@ -657,23 +681,23 @@ __be32 nfs4_callback_recallany(struct cb_recallanyargs *args, void *dummy)
 
 	if (flags)
 		nfs_expire_all_delegation_types(clp, flags);
-out_put:
-	nfs_put_client(clp);
 out:
 	dprintk("%s: exit with status = %d\n", __func__, ntohl(status));
 	return status;
 }
 
 /* Reduce the fore channel's max_slots to the target value */
-__be32 nfs4_callback_recallslot(struct cb_recallslotargs *args, void *dummy)
+__be32 nfs4_callback_recallslot(struct cb_recallslotargs *args, void *dummy,
+				struct cb_process_state *cps)
 {
 	struct nfs_client *clp;
 	struct nfs4_slot_table *fc_tbl;
 	__be32 status;
 
 	status = htonl(NFS4ERR_OP_NOT_IN_SESSION);
-	clp = nfs_find_client(args->crsa_addr, 4);
-	if (clp == NULL)
+	if (cps->session) /* set in cb_sequence */
+		clp = cps->session->clp;
+	else
 		goto out;
 
 	dprintk("NFS: CB_RECALL_SLOT request from %s target max slots %d\n",
@@ -685,16 +709,14 @@ __be32 nfs4_callback_recallslot(struct cb_recallslotargs *args, void *dummy)
 	status = htonl(NFS4ERR_BAD_HIGH_SLOT);
 	if (args->crsa_target_max_slots > fc_tbl->max_slots ||
 	    args->crsa_target_max_slots < 1)
-		goto out_putclient;
+		goto out;
 
 	status = htonl(NFS4_OK);
 	if (args->crsa_target_max_slots == fc_tbl->max_slots)
-		goto out_putclient;
+		goto out;
 
 	fc_tbl->target_max_slots = args->crsa_target_max_slots;
 	nfs41_handle_recall_slot(clp);
-out_putclient:
-	nfs_put_client(clp);	/* balance nfs_find_client */
 out:
 	dprintk("%s: exit with status = %d\n", __func__, ntohl(status));
 	return status;
diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 63b17d0..1650ab0 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -12,6 +12,7 @@
 #include <linux/slab.h>
 #include "nfs4_fs.h"
 #include "callback.h"
+#include "internal.h"
 
 #define CB_OP_TAGLEN_MAXSZ	(512)
 #define CB_OP_HDR_RES_MAXSZ	(2 + CB_OP_TAGLEN_MAXSZ)
@@ -34,7 +35,8 @@
 /* Internal error code */
 #define NFS4ERR_RESOURCE_HDR	11050
 
-typedef __be32 (*callback_process_op_t)(void *, void *);
+typedef __be32 (*callback_process_op_t)(void *, void *,
+					struct cb_process_state *);
 typedef __be32 (*callback_decode_arg_t)(struct svc_rqst *, struct xdr_stream *, void *);
 typedef __be32 (*callback_encode_res_t)(struct svc_rqst *, struct xdr_stream *, void *);
 
@@ -676,7 +678,8 @@ preprocess_nfs4_op(unsigned int op_nr, struct callback_op **op)
 static __be32 process_op(uint32_t minorversion, int nop,
 		struct svc_rqst *rqstp,
 		struct xdr_stream *xdr_in, void *argp,
-		struct xdr_stream *xdr_out, void *resp, int* drc_status)
+		struct xdr_stream *xdr_out, void *resp,
+		struct cb_process_state *cps)
 {
 	struct callback_op *op = &callback_ops[0];
 	unsigned int op_nr;
@@ -699,8 +702,8 @@ static __be32 process_op(uint32_t minorversion, int nop,
 	if (status)
 		goto encode_hdr;
 
-	if (*drc_status) {
-		status = *drc_status;
+	if (cps->drc_status) {
+		status = cps->drc_status;
 		goto encode_hdr;
 	}
 
@@ -708,16 +711,10 @@ static __be32 process_op(uint32_t minorversion, int nop,
 	if (maxlen > 0 && maxlen < PAGE_SIZE) {
 		status = op->decode_args(rqstp, xdr_in, argp);
 		if (likely(status == 0))
-			status = op->process_op(argp, resp);
+			status = op->process_op(argp, resp, cps);
 	} else
 		status = htonl(NFS4ERR_RESOURCE);
 
-	/* Only set by OP_CB_SEQUENCE processing */
-	if (status == htonl(NFS4ERR_RETRY_UNCACHED_REP)) {
-		*drc_status = status;
-		status = 0;
-	}
-
 encode_hdr:
 	res = encode_op_hdr(xdr_out, op_nr, status);
 	if (unlikely(res))
@@ -736,8 +733,10 @@ static __be32 nfs4_callback_compound(struct svc_rqst *rqstp, void *argp, void *r
 	struct cb_compound_hdr_arg hdr_arg = { 0 };
 	struct cb_compound_hdr_res hdr_res = { NULL };
 	struct xdr_stream xdr_in, xdr_out;
-	__be32 *p;
-	__be32 status, drc_status = 0;
+	__be32 *p, status;
+	struct cb_process_state cps = {
+		.drc_status = 0,
+	};
 	unsigned int nops = 0;
 
 	dprintk("%s: start\n", __func__);
@@ -758,7 +757,7 @@ static __be32 nfs4_callback_compound(struct svc_rqst *rqstp, void *argp, void *r
 
 	while (status == 0 && nops != hdr_arg.nops) {
 		status = process_op(hdr_arg.minorversion, nops, rqstp,
-				    &xdr_in, argp, &xdr_out, resp, &drc_status);
+				    &xdr_in, argp, &xdr_out, resp, &cps);
 		nops++;
 	}
 
@@ -771,6 +770,8 @@ static __be32 nfs4_callback_compound(struct svc_rqst *rqstp, void *argp, void *r
 
 	*hdr_res.status = status;
 	*hdr_res.nops = htonl(nops);
+	if (cps.session) /* matched by cb_sequence find_client_with_session */
+		nfs_put_client(cps.session->clp);
 	dprintk("%s: done, status = %u\n", __func__, ntohl(status));
 	return rpc_success;
 }
-- 
1.7.2.1

