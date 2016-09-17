Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44656 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754765AbcIQWRp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 17 Sep 2016 18:17:45 -0400
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@primarydata.com, anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org, bfields@fieldses.org
Subject: [PATCH v4 6/9] nfs: add handling for CB_NOTIFY_LOCK in client
Date: Sat, 17 Sep 2016 18:17:36 -0400
Message-Id: <1474150659-23894-7-git-send-email-jlayton@redhat.com>
In-Reply-To: <1474150659-23894-1-git-send-email-jlayton@redhat.com>
References: <1474150659-23894-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

For now, the callback doesn't do anything. Support for that will be
added in later patches.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/callback.h      |  9 +++++++++
 fs/nfs/callback_proc.c | 12 ++++++++++++
 fs/nfs/callback_xdr.c  | 51 +++++++++++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 71 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
index 5fe1cecbf9f0..2c7b815de6d6 100644
--- a/fs/nfs/callback.h
+++ b/fs/nfs/callback.h
@@ -179,6 +179,15 @@ extern __be32 nfs4_callback_devicenotify(
 	struct cb_devicenotifyargs *args,
 	void *dummy, struct cb_process_state *cps);
 
+struct cb_notify_lock_args {
+	struct nfs_fh			cbnl_fh;
+	struct nfs_lowner		cbnl_owner;
+	bool				cbnl_valid;
+};
+
+extern __be32 nfs4_callback_notify_lock(struct cb_notify_lock_args *args,
+					 void *dummy,
+					 struct cb_process_state *cps);
 #endif /* CONFIG_NFS_V4_1 */
 extern int check_gss_callback_principal(struct nfs_client *, struct svc_rqst *);
 extern __be32 nfs4_callback_getattr(struct cb_getattrargs *args,
diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index f953ef6b2f2e..974881824414 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -628,4 +628,16 @@ out:
 	dprintk("%s: exit with status = %d\n", __func__, ntohl(status));
 	return status;
 }
+
+__be32 nfs4_callback_notify_lock(struct cb_notify_lock_args *args, void *dummy,
+				 struct cb_process_state *cps)
+{
+	if (!cps->clp) /* set in cb_sequence */
+		return htonl(NFS4ERR_OP_NOT_IN_SESSION);
+
+	dprintk_rcu("NFS: CB_NOTIFY_LOCK request from %s\n",
+		rpc_peeraddr2str(cps->clp->cl_rpcclient, RPC_DISPLAY_ADDR));
+
+	return htonl(NFS4_OK);
+}
 #endif /* CONFIG_NFS_V4_1 */
diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index a710825f3d61..eb094c6011d8 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -35,6 +35,7 @@
 					 (1 + 3) * 4) // seqid, 3 slotids
 #define CB_OP_RECALLANY_RES_MAXSZ	(CB_OP_HDR_RES_MAXSZ)
 #define CB_OP_RECALLSLOT_RES_MAXSZ	(CB_OP_HDR_RES_MAXSZ)
+#define CB_OP_NOTIFY_LOCK_RES_MAXSZ	(CB_OP_HDR_RES_MAXSZ)
 #endif /* CONFIG_NFS_V4_1 */
 
 #define NFSDBG_FACILITY NFSDBG_CALLBACK
@@ -534,6 +535,49 @@ static __be32 decode_recallslot_args(struct svc_rqst *rqstp,
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
+		args->cbnl_valid = true;
+	} else {
+		args->cbnl_owner.s_dev = 0;
+		args->cbnl_owner.id = 0;
+		args->cbnl_valid = false;
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
@@ -746,6 +790,7 @@ preprocess_nfs41_op(int nop, unsigned int op_nr, struct callback_op **op)
 	case OP_CB_RECALL_SLOT:
 	case OP_CB_LAYOUTRECALL:
 	case OP_CB_NOTIFY_DEVICEID:
+	case OP_CB_NOTIFY_LOCK:
 		*op = &callback_ops[op_nr];
 		break;
 
@@ -753,7 +798,6 @@ preprocess_nfs41_op(int nop, unsigned int op_nr, struct callback_op **op)
 	case OP_CB_PUSH_DELEG:
 	case OP_CB_RECALLABLE_OBJ_AVAIL:
 	case OP_CB_WANTS_CANCELLED:
-	case OP_CB_NOTIFY_LOCK:
 		return htonl(NFS4ERR_NOTSUPP);
 
 	default:
@@ -1006,6 +1050,11 @@ static struct callback_op callback_ops[] = {
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

