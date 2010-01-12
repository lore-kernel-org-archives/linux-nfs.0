From: andros@netapp.com
Subject: [PATCH 6/6] nfs41: implement cb_recall_slot
Date: Tue, 12 Jan 2010 16:48:39 -0500
Message-ID: <1263332919-2900-7-git-send-email-andros@netapp.com>
References: <1263332919-2900-1-git-send-email-andros@netapp.com>
 <1263332919-2900-2-git-send-email-andros@netapp.com>
 <1263332919-2900-3-git-send-email-andros@netapp.com>
 <1263332919-2900-4-git-send-email-andros@netapp.com>
 <1263332919-2900-5-git-send-email-andros@netapp.com>
 <1263332919-2900-6-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:32488 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753418Ab0ALVs7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Jan 2010 16:48:59 -0500
In-Reply-To: <1263332919-2900-6-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Drain the fore channel and reset the max_slots to the new value.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/callback.h         |    8 ++++++++
 fs/nfs/callback_proc.c    |   32 ++++++++++++++++++++++++++++++++
 fs/nfs/callback_xdr.c     |   22 +++++++++++++++++++++-
 fs/nfs/nfs4_fs.h          |    2 ++
 fs/nfs/nfs4state.c        |   23 +++++++++++++++++++++++
 include/linux/nfs_fs_sb.h |    2 ++
 6 files changed, 88 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
index d4036be..85a7cfd 100644
--- a/fs/nfs/callback.h
+++ b/fs/nfs/callback.h
@@ -119,6 +119,14 @@ struct cb_recallanyargs {
 };
 
 extern unsigned nfs4_callback_recallany(struct cb_recallanyargs *args, void *dummy);
+
+struct cb_recallslotargs {
+	struct sockaddr	*crsa_addr;
+	uint32_t	crsa_target_max_slots;
+};
+extern unsigned nfs4_callback_recallslot(struct cb_recallslotargs *args,
+					  void *dummy);
+
 #endif /* CONFIG_NFS_V4_1 */
 
 extern __be32 nfs4_callback_getattr(struct cb_getattrargs *args, struct cb_getattrres *res);
diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 3cc2333..e81e1ea 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -297,4 +297,36 @@ out:
 	dprintk("%s: exit with status = %d\n", __func__, ntohl(status));
 	return status;
 }
+
+/* Reduce the fore channel's max_slots to the target value */
+unsigned nfs4_callback_recallslot(struct cb_recallslotargs *args, void *dummy)
+{
+	struct nfs_client *clp;
+	struct nfs4_slot_table *fc_stbl;
+	int status;
+
+	status = htonl(NFS4ERR_OP_NOT_IN_SESSION);
+	clp = nfs_find_client(args->crsa_addr, 4);
+	if (clp == NULL)
+		goto out;
+
+	dprintk("NFS: RECALL_SLOT callback request from %s "
+		" with target max slots: %d\n",
+		rpc_peeraddr2str(clp->cl_rpcclient, RPC_DISPLAY_ADDR),
+		args->crsa_target_max_slots);
+
+	fc_stbl = &clp->cl_session->fc_slot_table;
+
+	status = htonl(NFS4ERR_BAD_HIGH_SLOT);
+	if (args->crsa_target_max_slots >= fc_stbl->max_slots ||
+	    args->crsa_target_max_slots < 1)
+		goto out;
+
+	fc_stbl->target_max_slots = args->crsa_target_max_slots;
+	nfs41_handle_recall_slot(clp);
+	status = htonl(NFS4_OK);
+out:
+	dprintk("%s: exit with status = %d\n", __func__, ntohl(status));
+	return status;
+}
 #endif /* CONFIG_NFS_V4_1 */
diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 08b430d..8e66e20 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -24,6 +24,7 @@
 #define CB_OP_SEQUENCE_RES_MAXSZ	(CB_OP_HDR_RES_MAXSZ + \
 					4 + 1 + 3)
 #define CB_OP_RECALLANY_RES_MAXSZ	(CB_OP_HDR_RES_MAXSZ)
+#define CB_OP_RECALLSLOT_RES_MAXSZ	(CB_OP_HDR_RES_MAXSZ)
 #endif /* CONFIG_NFS_V4_1 */
 
 #define NFSDBG_FACILITY NFSDBG_CALLBACK
@@ -349,6 +350,20 @@ static unsigned decode_recallany_args(struct svc_rqst *rqstp,
 	return 0;
 }
 
+static unsigned decode_recallslot_args(struct svc_rqst *rqstp,
+					struct xdr_stream *xdr,
+					struct cb_recallslotargs *args)
+{
+	__be32 *p;
+
+	args->crsa_addr = svc_addr(rqstp);
+	p = read_buf(xdr, 4);
+	if (unlikely(p == NULL))
+		return htonl(NFS4ERR_BADXDR);
+	args->crsa_target_max_slots = ntohl(*p++);
+	return 0;
+}
+
 #endif /* CONFIG_NFS_V4_1 */
 
 static __be32 encode_string(struct xdr_stream *xdr, unsigned int len, const char *str)
@@ -557,6 +572,7 @@ preprocess_nfs41_op(int nop, unsigned int op_nr, struct callback_op **op)
 	case OP_CB_RECALL:
 	case OP_CB_SEQUENCE:
 	case OP_CB_RECALL_ANY:
+	case OP_CB_RECALL_SLOT:
 		*op = &callback_ops[op_nr];
 		break;
 
@@ -565,7 +581,6 @@ preprocess_nfs41_op(int nop, unsigned int op_nr, struct callback_op **op)
 	case OP_CB_NOTIFY:
 	case OP_CB_PUSH_DELEG:
 	case OP_CB_RECALLABLE_OBJ_AVAIL:
-	case OP_CB_RECALL_SLOT:
 	case OP_CB_WANTS_CANCELLED:
 	case OP_CB_NOTIFY_LOCK:
 		return htonl(NFS4ERR_NOTSUPP);
@@ -734,6 +749,11 @@ static struct callback_op callback_ops[] = {
 		.decode_args = (callback_decode_arg_t)decode_recallany_args,
 		.res_maxsize = CB_OP_RECALLANY_RES_MAXSZ,
 	},
+	[OP_CB_RECALL_SLOT] = {
+		.process_op = (callback_process_op_t)nfs4_callback_recallslot,
+		.decode_args = (callback_decode_arg_t)decode_recallslot_args,
+		.res_maxsize = CB_OP_RECALLSLOT_RES_MAXSZ,
+	},
 #endif /* CONFIG_NFS_V4_1 */
 };
 
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 865265b..cd93dfc 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -46,6 +46,7 @@ enum nfs4_client_state {
 	NFS4CLNT_DELEGRETURN,
 	NFS4CLNT_SESSION_RESET,
 	NFS4CLNT_SESSION_DRAINING,
+	NFS4CLNT_RECALL_SLOT,
 };
 
 /*
@@ -278,6 +279,7 @@ extern void nfs4_schedule_state_recovery(struct nfs_client *);
 extern void nfs4_schedule_state_manager(struct nfs_client *);
 extern int nfs4_state_mark_reclaim_nograce(struct nfs_client *clp, struct nfs4_state *state);
 extern void nfs41_handle_sequence_flag_errors(struct nfs_client *clp, u32 flags);
+extern void nfs41_handle_recall_slot(struct nfs_client *clp);
 extern void nfs4_put_lock_state(struct nfs4_lock_state *lsp);
 extern int nfs4_set_lock_state(struct nfs4_state *state, struct file_lock *fl);
 extern void nfs4_copy_stateid(nfs4_stateid *, struct nfs4_state *, fl_owner_t);
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 6d263ed..4f71bb1 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1249,6 +1249,12 @@ static int nfs4_reclaim_lease(struct nfs_client *clp)
 }
 
 #ifdef CONFIG_NFS_V4_1
+void nfs41_handle_recall_slot(struct nfs_client *clp)
+{
+	set_bit(NFS4CLNT_RECALL_SLOT, &clp->cl_state);
+	nfs4_schedule_state_recovery(clp);
+}
+
 void nfs41_handle_sequence_flag_errors(struct nfs_client *clp, u32 flags)
 {
 	if (!flags)
@@ -1299,6 +1305,16 @@ out:
 	return status;
 }
 
+static void nfs4_recall_slot(struct nfs_client *clp)
+{
+	struct nfs4_slot_table *fc_stbl = &clp->cl_session->fc_slot_table;
+
+	nfs4_begin_drain_session(clp);
+	fc_stbl->max_slots = fc_stbl->target_max_slots;
+	fc_stbl->target_max_slots = 0;
+	nfs4_end_drain_session(clp);
+}
+
 #else /* CONFIG_NFS_V4_1 */
 static int nfs4_reset_session(struct nfs_client *clp) { return 0; }
 static int nfs4_end_drain_session(struct nfs_client *clp) { return 0; }
@@ -1397,6 +1413,13 @@ static void nfs4_state_manager(struct nfs_client *clp)
 			nfs_client_return_marked_delegations(clp);
 			continue;
 		}
+		/* Recall session slots */
+		if (test_and_clear_bit(NFS4CLNT_RECALL_SLOT, &clp->cl_state)
+		   && nfs4_has_session(clp)) {
+			nfs4_recall_slot(clp);
+			continue;
+		}
+
 
 		nfs4_clear_state_manager_bit(clp);
 		/* Did we race with an attempt to give us more work? */
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 34fc6be..ecd9e6c 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -193,6 +193,8 @@ struct nfs4_slot_table {
 	int		max_slots;		/* # slots in table */
 	int		highest_used_slotid;	/* sent to server on each SEQ.
 						 * op for dynamic resizing */
+	int		target_max_slots;	/* Set by CB_RECALL_SLOT as
+						 * the new max_slots */
 };
 
 static inline int slot_idx(struct nfs4_slot_table *tbl, struct nfs4_slot *sp)
-- 
1.6.5.2

