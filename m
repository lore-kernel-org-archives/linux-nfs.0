Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51482 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933860AbcIFPMo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 6 Sep 2016 11:12:44 -0400
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 5/9] nfs: add handling for CB_NOTIFY_LOCK in client
Date: Tue,  6 Sep 2016 11:12:36 -0400
Message-Id: <1473174760-29859-6-git-send-email-jlayton@redhat.com>
In-Reply-To: <1473174760-29859-1-git-send-email-jlayton@redhat.com>
References: <1473174760-29859-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

For now, the callback doesn't do anything. Support for that will be
added in later patches.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/callback.h      |  8 ++++++++
 fs/nfs/callback_proc.c | 19 +++++++++++++++++++
 fs/nfs/callback_xdr.c  | 49 ++++++++++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 75 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
index 5fe1cecbf9f0..b486848306f0 100644
--- a/fs/nfs/callback.h
+++ b/fs/nfs/callback.h
@@ -179,6 +179,14 @@ extern __be32 nfs4_callback_devicenotify(
 	struct cb_devicenotifyargs *args,
 	void *dummy, struct cb_process_state *cps);
 
+struct cb_notify_lock_args {
+	struct nfs_fh			cbnl_fh;
+	struct nfs_lowner		cbnl_owner;
+};
+
+extern __be32 nfs4_callback_notify_lock(struct cb_notify_lock_args *args,
+					 void *dummy,
+					 struct cb_process_state *cps);
 #endif /* CONFIG_NFS_V4_1 */
 extern int check_gss_callback_principal(struct nfs_client *, struct svc_rqst *);
 extern __be32 nfs4_callback_getattr(struct cb_getattrargs *args,
diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index f953ef6b2f2e..a211af339f32 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -628,4 +628,23 @@ out:
 	dprintk("%s: exit with status = %d\n", __func__, ntohl(status));
 	return status;
 }
+
+__be32 nfs4_callback_notify_lock(struct cb_notify_lock_args *args, void *dummy,
+				 struct cb_process_state *cps)
+{
+	struct nfs4_slot_table	*fc_tbl;
+	__be32			status;
+
+	status = htonl(NFS4ERR_OP_NOT_IN_SESSION);
+	if (!cps->clp) /* set in cb_sequence */
+		return status;
+
+	dprintk_rcu("NFS: CB_RECALL_NOTIFY_LOCK request from %s\n",
+		rpc_peeraddr2str(cps->clp->cl_rpcclient, RPC_DISPLAY_ADDR));
+
+	fc_tbl = &cps->clp->cl_session->fc_slot_table;
+
+	status = htonl(NFS4_OK);
+	return status;
+}
 #endif /* CONFIG_NFS_V4_1 */
diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index d6a40c06ec26..d3c0485cf437 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -35,6 +35,7 @@
 					 (1 + 3) * 4) // seqid, 3 slotids
 #define CB_OP_RECALLANY_RES_MAXSZ	(CB_OP_HDR_RES_MAXSZ)
 #define CB_OP_RECALLSLOT_RES_MAXSZ	(CB_OP_HDR_RES_MAXSZ)
+#define CB_OP_NOTIFY_LOCK_RES_MAXSZ	(CB_OP_HDR_RES_MAXSZ)
 #endif /* CONFIG_NFS_V4_1 */
 
 #define NFSDBG_FACILITY NFSDBG_CALLBACK
@@ -534,6 +535,47 @@ static __be32 decode_recallslot_args(struct svc_rqst *rqstp,
 	return 0;
 }
 
+static __be32 decode_lockowner(struct xdr_stream *xdr, struct cb_notify_lock_args *args)
+{
+	__be32		*p;
+	unsigned int	len;
+
+	p = read_buf(xdr, 12);
+	if (unlikely(p == NULL))
+		return htonl(NFS4ERR_BADXDR);
+
+	p = xdr_decode_hyper(p, &args->cbnl_owner.clientid);
+	len = be32_to_cpu(*p);
+
+	p = read_buf(xdr, len);
+	if (unlikely(p == NULL))
+		return htonl(NFS4ERR_BADXDR);
+
+	/* Only try to decode if the length is right */
+	if (len == 20) {
+		p += 2;	/* skip "lock id:" */
+		args->cbnl_owner.s_dev = be32_to_cpu(*p++);
+		xdr_decode_hyper(p, &args->cbnl_owner.id);
+	} else {
+		args->cbnl_owner.s_dev = 0;
+		args->cbnl_owner.id = 0;
+	}
+	return 0;
+}
+
+static __be32 decode_notify_lock_args(struct svc_rqst *rqstp, struct xdr_stream *xdr, struct cb_notify_lock_args *args)
+{
+	__be32 status;
+
+	status = decode_fh(xdr, &args->cbnl_fh);
+	if (unlikely(status != 0))
+		goto out;
+	status = decode_lockowner(xdr, args);
+out:
+	dprintk("%s: exit with status = %d\n", __func__, ntohl(status));
+	return status;
+}
+
 #endif /* CONFIG_NFS_V4_1 */
 
 static __be32 encode_string(struct xdr_stream *xdr, unsigned int len, const char *str)
@@ -746,6 +788,7 @@ preprocess_nfs41_op(int nop, unsigned int op_nr, struct callback_op **op)
 	case OP_CB_RECALL_SLOT:
 	case OP_CB_LAYOUTRECALL:
 	case OP_CB_NOTIFY_DEVICEID:
+	case OP_CB_NOTIFY_LOCK:
 		*op = &callback_ops[op_nr];
 		break;
 
@@ -753,7 +796,6 @@ preprocess_nfs41_op(int nop, unsigned int op_nr, struct callback_op **op)
 	case OP_CB_PUSH_DELEG:
 	case OP_CB_RECALLABLE_OBJ_AVAIL:
 	case OP_CB_WANTS_CANCELLED:
-	case OP_CB_NOTIFY_LOCK:
 		return htonl(NFS4ERR_NOTSUPP);
 
 	default:
@@ -1006,6 +1048,11 @@ static struct callback_op callback_ops[] = {
 		.decode_args = (callback_decode_arg_t)decode_recallslot_args,
 		.res_maxsize = CB_OP_RECALLSLOT_RES_MAXSZ,
 	},
+	[OP_CB_NOTIFY_LOCK] = {
+		.process_op = (callback_process_op_t)nfs4_callback_notify_lock,
+		.decode_args = (callback_decode_arg_t)decode_notify_lock_args,
+		.res_maxsize = CB_OP_NOTIFY_LOCK_RES_MAXSZ,
+	},
 #endif /* CONFIG_NFS_V4_1 */
 };
 
-- 
2.7.4

