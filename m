Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:61537 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757797Ab2EXVTg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 24 May 2012 17:19:36 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH 1/2] nfs4.1: add BIND_CONN_TO_SESSION operation
Date: Thu, 24 May 2012 17:19:33 -0400
Message-Id: <1337894374-23340-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch adds the BIND_CONN_TO_SESSION operation which is needed for
upcoming SP4_MACH_CRED work and useful for recovering from broken connections
without destroying the session.

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
Updated with comment from Trond

 fs/nfs/nfs4_fs.h        |    1 +
 fs/nfs/nfs4proc.c       |   54 ++++++++++++++++++++++++++
 fs/nfs/nfs4xdr.c        |   95 +++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/nfs4.h    |    5 ++
 include/linux/nfs_xdr.h |    6 +++
 5 files changed, 161 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index edeef71..ad90bc7 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -215,6 +215,7 @@ struct vfsmount *nfs4_submount(struct nfs_server *, struct dentry *,
 extern int nfs4_proc_setclientid(struct nfs_client *, u32, unsigned short, struct rpc_cred *, struct nfs4_setclientid_res *);
 extern int nfs4_proc_setclientid_confirm(struct nfs_client *, struct nfs4_setclientid_res *arg, struct rpc_cred *);
 extern int nfs4_proc_get_rootfh(struct nfs_server *, struct nfs_fh *, struct nfs_fsinfo *);
+extern int nfs4_proc_bind_conn_to_session(struct nfs_client *);
 extern int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred);
 extern int nfs4_init_clientid(struct nfs_client *, struct rpc_cred *);
 extern int nfs41_init_clientid(struct nfs_client *, struct rpc_cred *);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 78784e5..1d1bef6 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5062,6 +5062,60 @@ nfs41_same_server_scope(struct server_scope *a, struct server_scope *b)
 }
 
 /*
+ * nfs4_proc_bind_conn_to_session()
+ *
+ * The 4.1 client currently uses the same TCP connection for the
+ * fore and backchannel.
+ */
+int nfs4_proc_bind_conn_to_session(struct nfs_client *clp)
+{
+	int status;
+	struct nfs41_bind_conn_to_session_res res;
+	struct rpc_message msg = {
+		.rpc_proc =
+			&nfs4_procedures[NFSPROC4_CLNT_BIND_CONN_TO_SESSION],
+		.rpc_argp = clp,
+		.rpc_resp = &res,
+	};
+
+	dprintk("--> %s\n", __func__);
+	BUG_ON(clp == NULL);
+
+	res.session = kzalloc(sizeof(struct nfs4_session), GFP_NOFS);
+	if (unlikely(res.session == NULL)) {
+		status = -ENOMEM;
+		goto out;
+	}
+
+	status = rpc_call_sync(clp->cl_rpcclient, &msg, RPC_TASK_TIMEOUT);
+	if (status == 0) {
+		if (memcmp(res.session->sess_id.data,
+		    clp->cl_session->sess_id.data, NFS4_MAX_SESSIONID_LEN)) {
+			dprintk("NFS: %s: Session ID mismatch\n", __func__);
+			status = -EIO;
+			goto out_session;
+		}
+		if (res.dir != NFS4_CDFS4_BOTH) {
+			dprintk("NFS: %s: Unexpected direction from server\n",
+				__func__);
+			status = -EIO;
+			goto out_session;
+		}
+		if (res.use_conn_in_rdma_mode) {
+			dprintk("NFS: %s: Server returned RDMA mode = true\n",
+				__func__);
+			status = -EIO;
+			goto out_session;
+		}
+	}
+out_session:
+	kfree(res.session);
+out:
+	dprintk("<-- %s status= %d\n", __func__, status);
+	return status;
+}
+
+/*
  * nfs4_proc_exchange_id()
  *
  * Since the clientid has expired, all compounds using sessions
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index db040e9..e9be74f 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -321,6 +321,16 @@ static int nfs4_stat_to_errno(int);
 				     1 /* csr_flags */ + \
 				     decode_channel_attrs_maxsz + \
 				     decode_channel_attrs_maxsz)
+#define encode_bind_conn_to_session_maxsz  (op_encode_hdr_maxsz + \
+				     /* bctsa_sessid */ \
+				     XDR_QUADLEN(NFS4_MAX_SESSIONID_LEN) + \
+				     1 /* bctsa_dir */ + \
+				     1 /* bctsa_use_conn_in_rdma_mode */)
+#define decode_bind_conn_to_session_maxsz  (op_decode_hdr_maxsz +	\
+				     /* bctsr_sessid */ \
+				     XDR_QUADLEN(NFS4_MAX_SESSIONID_LEN) + \
+				     1 /* bctsr_dir */ + \
+				     1 /* bctsr_use_conn_in_rdma_mode */)
 #define encode_destroy_session_maxsz    (op_encode_hdr_maxsz + 4)
 #define decode_destroy_session_maxsz    (op_decode_hdr_maxsz)
 #define encode_sequence_maxsz	(op_encode_hdr_maxsz + \
@@ -714,6 +724,12 @@ static int nfs4_stat_to_errno(int);
 				decode_putfh_maxsz + \
 				decode_secinfo_maxsz)
 #if defined(CONFIG_NFS_V4_1)
+#define NFS4_enc_bind_conn_to_session_sz \
+				(compound_encode_hdr_maxsz + \
+				 encode_bind_conn_to_session_maxsz)
+#define NFS4_dec_bind_conn_to_session_sz \
+				(compound_decode_hdr_maxsz + \
+				 decode_bind_conn_to_session_maxsz)
 #define NFS4_enc_exchange_id_sz \
 				(compound_encode_hdr_maxsz + \
 				 encode_exchange_id_maxsz)
@@ -1654,6 +1670,20 @@ static void encode_secinfo(struct xdr_stream *xdr, const struct qstr *name, stru
 
 #if defined(CONFIG_NFS_V4_1)
 /* NFSv4.1 operations */
+static void encode_bind_conn_to_session(struct xdr_stream *xdr,
+				   struct nfs4_session *session,
+				   struct compound_hdr *hdr)
+{
+	__be32 *p;
+
+	encode_op_hdr(xdr, OP_BIND_CONN_TO_SESSION,
+		decode_bind_conn_to_session_maxsz, hdr);
+	encode_opaque_fixed(xdr, session->sess_id.data, NFS4_MAX_SESSIONID_LEN);
+	p = xdr_reserve_space(xdr, 8);
+	*p++ = cpu_to_be32(NFS4_CDFC4_BACK_OR_BOTH);
+	*p = 0;	/* use_conn_in_rdma_mode = False */
+}
+
 static void encode_exchange_id(struct xdr_stream *xdr,
 			       struct nfs41_exchange_id_args *args,
 			       struct compound_hdr *hdr)
@@ -2614,6 +2644,22 @@ static void nfs4_xdr_enc_secinfo(struct rpc_rqst *req,
 
 #if defined(CONFIG_NFS_V4_1)
 /*
+ * BIND_CONN_TO_SESSION request
+ */
+static void nfs4_xdr_enc_bind_conn_to_session(struct rpc_rqst *req,
+				struct xdr_stream *xdr,
+				struct nfs_client *clp)
+{
+	struct compound_hdr hdr = {
+		.minorversion = clp->cl_mvops->minor_version,
+	};
+
+	encode_compound_hdr(xdr, req, &hdr);
+	encode_bind_conn_to_session(xdr, clp->cl_session, &hdr);
+	encode_nops(&hdr);
+}
+
+/*
  * EXCHANGE_ID request
  */
 static void nfs4_xdr_enc_exchange_id(struct rpc_rqst *req,
@@ -5239,6 +5285,37 @@ static int decode_sessionid(struct xdr_stream *xdr, struct nfs4_sessionid *sid)
 	return decode_opaque_fixed(xdr, sid->data, NFS4_MAX_SESSIONID_LEN);
 }
 
+static int decode_bind_conn_to_session(struct xdr_stream *xdr,
+				struct nfs41_bind_conn_to_session_res *res)
+{
+	__be32 *p;
+	int status;
+
+	status = decode_op_hdr(xdr, OP_BIND_CONN_TO_SESSION);
+	if (!status)
+		status = decode_sessionid(xdr, &res->session->sess_id);
+	if (unlikely(status))
+		return status;
+
+	/* dir flags, rdma mode bool */
+	p = xdr_inline_decode(xdr, 8);
+	if (unlikely(!p))
+		goto out_overflow;
+
+	res->dir = be32_to_cpup(p++);
+	if (res->dir == 0 || res->dir > NFS4_CDFS4_BOTH)
+		return -EIO;
+	if (be32_to_cpup(p) == 0)
+		res->use_conn_in_rdma_mode = false;
+	else
+		res->use_conn_in_rdma_mode = true;
+
+	return 0;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
+}
+
 static int decode_create_session(struct xdr_stream *xdr,
 				 struct nfs41_create_session_res *res)
 {
@@ -6521,6 +6598,22 @@ out:
 
 #if defined(CONFIG_NFS_V4_1)
 /*
+ * Decode BIND_CONN_TO_SESSION response
+ */
+static int nfs4_xdr_dec_bind_conn_to_session(struct rpc_rqst *rqstp,
+					struct xdr_stream *xdr,
+					void *res)
+{
+	struct compound_hdr hdr;
+	int status;
+
+	status = decode_compound_hdr(xdr, &hdr);
+	if (!status)
+		status = decode_bind_conn_to_session(xdr, res);
+	return status;
+}
+
+/*
  * Decode EXCHANGE_ID response
  */
 static int nfs4_xdr_dec_exchange_id(struct rpc_rqst *rqstp,
@@ -7001,6 +7094,8 @@ struct rpc_procinfo	nfs4_procedures[] = {
 	PROC(RELEASE_LOCKOWNER,	enc_release_lockowner,	dec_release_lockowner),
 	PROC(SECINFO,		enc_secinfo,		dec_secinfo),
 #if defined(CONFIG_NFS_V4_1)
+	PROC(BIND_CONN_TO_SESSION,
+			enc_bind_conn_to_session, dec_bind_conn_to_session),
 	PROC(EXCHANGE_ID,	enc_exchange_id,	dec_exchange_id),
 	PROC(CREATE_SESSION,	enc_create_session,	dec_create_session),
 	PROC(DESTROY_SESSION,	enc_destroy_session,	dec_destroy_session),
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 0987146..5b1a504 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -69,6 +69,10 @@
 #define NFS4_CDFC4_FORE_OR_BOTH 0x3
 #define NFS4_CDFC4_BACK_OR_BOTH 0x7
 
+#define NFS4_CDFS4_FORE 0x1
+#define NFS4_CDFS4_BACK 0x2
+#define NFS4_CDFS4_BOTH 0x3
+
 #define NFS4_SET_TO_SERVER_TIME	0
 #define NFS4_SET_TO_CLIENT_TIME	1
 
@@ -582,6 +586,7 @@ enum {
 	NFSPROC4_CLNT_SECINFO,
 
 	/* nfs41 */
+	NFSPROC4_CLNT_BIND_CONN_TO_SESSION,
 	NFSPROC4_CLNT_EXCHANGE_ID,
 	NFSPROC4_CLNT_CREATE_SESSION,
 	NFSPROC4_CLNT_DESTROY_SESSION,
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 2e53a3f..aa2a3bb 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1115,6 +1115,12 @@ struct nfs41_impl_id {
 	struct nfstime4			date;
 };
 
+struct nfs41_bind_conn_to_session_res {
+	struct nfs4_session		*session;
+	u32				dir;
+	bool				use_conn_in_rdma_mode;
+};
+
 struct nfs41_exchange_id_res {
 	struct nfs_client		*client;
 	u32				flags;
-- 
1.7.4.4

