From: Alexandros Batsakis <batsakis@netapp.com>
Subject: [PATCH 06/10] nfs41: initial support for CB_RECALL_ANY
Date: Mon, 23 Nov 2009 13:54:43 -0800
Message-ID: <1259013287-3349-6-git-send-email-batsakis@netapp.com>
References: <1259013287-3349-1-git-send-email-batsakis@netapp.com>
 <1259013287-3349-2-git-send-email-batsakis@netapp.com>
 <1259013287-3349-3-git-send-email-batsakis@netapp.com>
 <1259013287-3349-4-git-send-email-batsakis@netapp.com>
 <1259013287-3349-5-git-send-email-batsakis@netapp.com>
Cc: Alexandros Batsakis <batsakis@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:42997 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757275AbZKWV7Z (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 23 Nov 2009 16:59:25 -0500
In-Reply-To: <1259013287-3349-5-git-send-email-batsakis@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

For now the clients returns _all_ the delegations of the specificed type
it holds

Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
---
 fs/nfs/callback.h      |   10 ++++++++++
 fs/nfs/callback_proc.c |   30 ++++++++++++++++++++++++++++++
 fs/nfs/callback_xdr.c  |   27 ++++++++++++++++++++++++++-
 fs/nfs/delegation.h    |    1 +
 4 files changed, 67 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
index 07baa82..b4cd63c 100644
--- a/fs/nfs/callback.h
+++ b/fs/nfs/callback.h
@@ -103,8 +103,18 @@ struct cb_sequenceres {
 	uint32_t			csr_target_highestslotid;
 };
 
+#define RCA4_TYPE_MASK_RDATA_DLG	0
+#define RCA4_TYPE_MASK_WDATA_DLG	1
+
+struct cb_recallanyargs {
+	struct sockaddr 		*craa_addr;
+	uint32_t 			craa_objs_to_keep;
+	uint32_t 			craa_type_mask;
+};
+
 extern unsigned nfs4_callback_sequence(struct cb_sequenceargs *args,
 				       struct cb_sequenceres *res);
+extern unsigned nfs4_callback_recallany(struct cb_recallanyargs *args, void *dummy);
 
 #endif /* CONFIG_NFS_V4_1 */
 
diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index b7da1f5..d37e8c9 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -227,4 +227,34 @@ out:
 	return res->csr_status;
 }
 
+unsigned nfs4_callback_recallany(struct cb_recallanyargs *args,
+				 void *dummy)
+{
+	struct nfs_client *clp;
+	int status;
+	fmode_t flags = 0;
+
+	status = htonl(NFS4ERR_OP_NOT_IN_SESSION);
+	clp = nfs_find_client(args->craa_addr, 4);
+	if (clp == NULL)
+		goto out;
+
+	dprintk("NFS: RECALL_ANY callback request from %s\n",
+		rpc_peeraddr2str(clp->cl_rpcclient, RPC_DISPLAY_ADDR));
+
+	if (test_bit(RCA4_TYPE_MASK_RDATA_DLG, (const unsigned long *)
+		     &args->craa_type_mask))
+		flags = FMODE_READ;
+	if (test_bit(RCA4_TYPE_MASK_WDATA_DLG, (const unsigned long *)
+		     &args->craa_type_mask))
+		flags |= FMODE_WRITE;
+
+	if (flags)
+		nfs_expire_all_delegation_types(clp, flags);
+	status = htonl(NFS4_OK);
+ out:
+	dprintk("%s: exit with status = %d\n", __func__, ntohl(status));
+	return status;
+}
+
 #endif /* CONFIG_NFS_V4_1 */
diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 0fda5e6..8e1a251 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -23,6 +23,7 @@
 #if defined(CONFIG_NFS_V4_1)
 #define CB_OP_SEQUENCE_RES_MAXSZ	(CB_OP_HDR_RES_MAXSZ + \
 					4 + 1 + 3)
+#define CB_OP_RECALLANY_RES_MAXSZ	(CB_OP_HDR_RES_MAXSZ)
 #endif /* CONFIG_NFS_V4_1 */
 
 #define NFSDBG_FACILITY NFSDBG_CALLBACK
@@ -326,6 +327,25 @@ out_free:
 	goto out;
 }
 
+static unsigned decode_recallany_args(struct svc_rqst *rqstp,
+				      struct xdr_stream *xdr,
+				      struct cb_recallanyargs *args)
+{
+	uint32_t *p;
+
+	args->craa_addr = svc_addr(rqstp);
+	p = read_buf(xdr, 4);
+	if (unlikely(p == NULL))
+		return htonl(NFS4ERR_BADXDR);
+	args->craa_objs_to_keep = ntohl(*p++);
+	p = read_buf(xdr, 4);
+	if (unlikely(p == NULL))
+		return htonl(NFS4ERR_BADXDR);
+	args->craa_type_mask = ntohl(*p);
+
+	return 0;
+}
+
 #endif /* CONFIG_NFS_V4_1 */
 
 static __be32 encode_string(struct xdr_stream *xdr, unsigned int len, const char *str)
@@ -533,6 +553,7 @@ preprocess_nfs41_op(int nop, unsigned int op_nr, struct callback_op **op)
 	case OP_CB_GETATTR:
 	case OP_CB_RECALL:
 	case OP_CB_SEQUENCE:
+	case OP_CB_RECALL_ANY:
 		*op = &callback_ops[op_nr];
 		break;
 
@@ -540,7 +561,6 @@ preprocess_nfs41_op(int nop, unsigned int op_nr, struct callback_op **op)
 	case OP_CB_NOTIFY_DEVICEID:
 	case OP_CB_NOTIFY:
 	case OP_CB_PUSH_DELEG:
-	case OP_CB_RECALL_ANY:
 	case OP_CB_RECALLABLE_OBJ_AVAIL:
 	case OP_CB_RECALL_SLOT:
 	case OP_CB_WANTS_CANCELLED:
@@ -688,6 +708,11 @@ static struct callback_op callback_ops[] = {
 		.encode_res = (callback_encode_res_t)encode_cb_sequence_res,
 		.res_maxsize = CB_OP_SEQUENCE_RES_MAXSZ,
 	},
+	[OP_CB_RECALL_ANY] = {
+		.process_op = (callback_process_op_t)nfs4_callback_recallany,
+		.decode_args = (callback_decode_arg_t)decode_recallany_args,
+		.res_maxsize = CB_OP_RECALLANY_RES_MAXSZ,
+	},
 #endif /* CONFIG_NFS_V4_1 */
 };
 
diff --git a/fs/nfs/delegation.h b/fs/nfs/delegation.h
index 09f3837..ad8b18d 100644
--- a/fs/nfs/delegation.h
+++ b/fs/nfs/delegation.h
@@ -40,6 +40,7 @@ void nfs_inode_return_delegation_noreclaim(struct inode *inode);
 struct inode *nfs_delegation_find_inode(struct nfs_client *clp, const struct nfs_fh *fhandle);
 void nfs_super_return_all_delegations(struct super_block *sb);
 void nfs_expire_all_delegations(struct nfs_client *clp);
+void nfs_expire_all_delegation_types(struct nfs_client *clp, fmode_t flags);
 void nfs_expire_unreferenced_delegations(struct nfs_client *clp);
 void nfs_handle_cb_pathdown(struct nfs_client *clp);
 void nfs_client_return_marked_delegations(struct nfs_client *clp);
-- 
1.6.2.5

