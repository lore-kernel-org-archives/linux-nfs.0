From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 36/85] nfs41: create_session operation
Date: Mon, 10 Nov 2008 22:24:31 +0200
Message-ID: <1226348671-8423-1-git-send-email-bhalevy@panasas.com>
References: <4918920E.3030301@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:48813 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751762AbYKJUYi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:24:38 -0500
In-Reply-To: <4918920E.3030301@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Implement the create_session operation conforming to
http://tools.ietf.org/html/draft-ietf-nfsv4-minorversion1-26

Signed-off-by: Ricardo Labiaga <ricardo.labiaga@netapp.com>
Signed-off-by: Andy Adamson<andros@umich.edu>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c       |  141 ++++++++++++++++++++++++++++++++++-
 fs/nfs/nfs4xdr.c        |  193 +++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/nfs_xdr.h |   17 ++++
 3 files changed, 350 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index f1918fa..7607dfd 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -55,6 +55,7 @@
 #include "internal.h"
 #include "iostat.h"
 #if defined(CONFIG_NFS_V4_1)
+#include "callback.h"
 #include <linux/nfs4_session.h>
 #endif /* CONFIG_NFS_V4_1 */
 
@@ -4448,9 +4449,147 @@ void nfs4_get_session(struct nfs_client *clp)
 		atomic_inc(&clp->cl_session->ref_count);
 }
 
+/* Initialize the values to be used by the client in CREATE_SESSION */
+static void nfs4_init_channel_attrs(struct nfs_client *clp,
+				    struct nfs4_channel_attrs *fc_attrs,
+				    struct nfs4_channel_attrs *bc_attrs)
+{
+	/* XXX: We need to have good values here... 32K is a wild guess */
+	fc_attrs->headerpadsz = bc_attrs->headerpadsz = 0;
+	fc_attrs->max_rqst_sz = bc_attrs->max_rqst_sz = NFS_MAX_FILE_IO_SIZE;
+	fc_attrs->max_resp_sz = bc_attrs->max_resp_sz = NFS_MAX_FILE_IO_SIZE;
+	fc_attrs->max_resp_sz_cached = bc_attrs->max_resp_sz_cached =
+		NFS_MAX_FILE_IO_SIZE;
+	fc_attrs->max_ops = bc_attrs->max_ops = 0xFFFFFFFF;
+	fc_attrs->max_reqs = bc_attrs->max_reqs =
+				clp->cl_rpcclient->cl_xprt->max_reqs;
+	fc_attrs->rdma_attrs = bc_attrs->rdma_attrs = 0;
+}
+
+/* Check the values returned by the server for CREATE_SESSION. Since we made
+ * our needs known, if the server gives us more than we need, we don't bother
+ * with it.
+ */
+static void nfs4_adjust_channel_attrs(struct nfs4_channel_attrs *req_attrs,
+				      struct nfs4_channel_attrs *resp_attrs)
+{
+	dprintk("%s: before adjusting: max_rqst_sz=%u max_resp_sz=%u "
+		"max_resp_sz_cached=%u max_ops=%u max_reqs=%u\n",
+		__func__,
+		resp_attrs->max_rqst_sz, resp_attrs->max_resp_sz,
+		resp_attrs->max_resp_sz_cached, resp_attrs->max_ops,
+		resp_attrs->max_reqs);
+
+	if (req_attrs->max_rqst_sz < resp_attrs->max_rqst_sz)
+		resp_attrs->max_rqst_sz = req_attrs->max_rqst_sz;
+
+	if (req_attrs->max_resp_sz < resp_attrs->max_resp_sz)
+		resp_attrs->max_resp_sz = req_attrs->max_resp_sz;
+
+	if (req_attrs->max_resp_sz_cached < resp_attrs->max_resp_sz)
+		resp_attrs->max_resp_sz = req_attrs->max_resp_sz_cached;
+
+	if (req_attrs->max_ops < resp_attrs->max_ops)
+		resp_attrs->max_ops = req_attrs->max_ops;
+
+	if (req_attrs->max_reqs < resp_attrs->max_reqs)
+		resp_attrs->max_reqs = req_attrs->max_reqs;
+
+	dprintk("%s: after  adjusting: max_rqst_sz=%u max_resp_sz=%u "
+		"max_resp_sz_cached=%u max_ops=%u max_reqs=%u\n",
+		__func__,
+		resp_attrs->max_rqst_sz, resp_attrs->max_resp_sz,
+		resp_attrs->max_resp_sz_cached, resp_attrs->max_ops,
+		resp_attrs->max_reqs);
+
+	/* We ignore the rdma channel attributes */
+}
+
+static int _nfs4_proc_create_session(struct nfs4_session *session)
+{
+	struct nfs_client *clp = session->clp;
+	struct nfs41_create_session_args args = {
+		.client = clp,
+		.session = session,
+		.cb_program = NFS4_CALLBACK,
+	};
+
+	struct nfs41_create_session_res res = {
+		.client = clp,
+		.session = session,
+	};
+
+	struct rpc_message msg = {
+		.rpc_proc = nfs4_proc(clp, NFSPROC4_CLNT_CREATE_SESSION),
+		.rpc_argp = &args,
+		.rpc_resp = &res,
+	};
+	int status;
+
+	nfs4_init_channel_attrs(clp, &args.fc_attrs, &args.bc_attrs);
+	args.flags = (SESSION4_PERSIST);
+
+	status = rpc_call_sync(session->clnt, &msg, 0);
+
+	/* Set the negotiated values in the session's channel_attrs struct */
+
+	if (!status) {
+		nfs4_adjust_channel_attrs(&args.fc_attrs,
+					&session->fore_channel.chan_attrs);
+		nfs4_adjust_channel_attrs(&args.bc_attrs,
+					&session->back_channel.chan_attrs);
+		/* Increment the clientid slot sequence id */
+		clp->cl_seqid++;
+	}
+
+	return status;
+}
+
+/*
+ * Issues a CREATE_SESSION operation to the server.
+ * It is the responsibility of the caller to verify the session is
+ * expired before calling this routine.
+ */
 int nfs4_proc_create_session(struct nfs4_session *session)
 {
-	return -1;	/* stub */
+	int status;
+	u32 *ptr;
+	struct nfs_fsinfo fsinfo;
+	struct nfs_client *clp = session->clp;
+
+	dprintk("--> %s clp=%p session=%p\n", __func__, clp, session);
+
+	status = _nfs4_proc_create_session(session);
+	if (status)
+		goto out;
+
+	session->clnt = clp->cl_rpcclient;
+
+	/* Init the fore channel */
+	status = nfs4_init_slot_table(&session->fore_channel);
+	dprintk("fore channel initialization returned %d\n", status);
+	if (status)
+		goto out;
+
+	dprintk("%s client>seqid %d\n", __func__, clp->cl_seqid);
+	ptr = (int *)session->sess_id;
+	dprintk("sessionid is: %u:%u:%u:%u\n", ptr[0], ptr[1], ptr[2], ptr[3]);
+
+	/* Get the lease time */
+	status = nfs4_proc_get_lease_time(clp, session, &fsinfo);
+	if (status == 0) {
+		/* Update lease time and schedule renewal */
+		spin_lock(&clp->cl_lock);
+		clp->cl_lease_time = fsinfo.lease_time * HZ;
+		clp->cl_last_renewal = jiffies;
+		clear_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state);
+		spin_unlock(&clp->cl_lock);
+
+		nfs4_schedule_state_renewal(clp);
+	}
+out:
+	dprintk("<-- %s\n", __func__);
+	return status;
 }
 
 int nfs4_proc_destroy_session(struct nfs4_session *session)
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 7b7d4e8..4dfb04e 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -242,6 +242,8 @@ static int nfs4_stat_to_errno(int);
 				(0)
 
 #if defined(CONFIG_NFS_V4_1)
+#define NFS4_MAX_MACHINE_NAME_LEN (64)
+
 #define encode_exchange_id_maxsz (op_encode_hdr_maxsz + \
 				encode_verifier_maxsz + \
 				1 /* co_ownerid.len */ + \
@@ -263,6 +265,31 @@ static int nfs4_stat_to_errno(int);
 				XDR_QUADLEN(NFS4_OPAQUE_LIMIT) + 1 + \
 				1 /* eir_server_impl_id array length */ + \
 				0 /* ignored eir_server_impl_id contents */)
+#define encode_channel_attrs_maxsz  (6 + 1 /* ca_rdma_ird.len (0) */)
+#define decode_channel_attrs_maxsz  (6 + \
+				     1 /* ca_rdma_ird.len */ + \
+				     1 /* ca_rdma_ird */)
+#define encode_create_session_maxsz  (op_encode_hdr_maxsz + \
+				     2 /* csa_clientid */ + \
+				     1 /* csa_sequence */ + \
+				     1 /* csa_flags */ + \
+				     encode_channel_attrs_maxsz + \
+				     encode_channel_attrs_maxsz + \
+				     1 /* csa_cb_program */ + \
+				     1 /* csa_sec_parms.len (1) */ + \
+				     1 /* cb_secflavor (AUTH_SYS) */ + \
+				     1 /* stamp */ + \
+				     1 /* machinename.len */ + \
+				     XDR_QUADLEN(NFS4_MAX_MACHINE_NAME_LEN) + \
+				     1 /* uid */ + \
+				     1 /* gid */ + \
+				     1 /* gids.len (0) */)
+#define decode_create_session_maxsz  (op_decode_hdr_maxsz +	\
+				     XDR_QUADLEN(NFS4_MAX_SESSIONID_LEN) + \
+				     1 /* csr_sequence */ + \
+				     1 /* csr_flags */ + \
+				     decode_channel_attrs_maxsz + \
+				     decode_channel_attrs_maxsz)
 #define encode_sequence_maxsz	0 /* stub */
 #define decode_sequence_maxsz	0 /* stub */
 #else /* CONFIG_NFS_V4_1 */
@@ -618,6 +645,12 @@ static int nfs4_stat_to_errno(int);
 #define NFS4_dec_exchange_id_sz \
 				(compound_decode_hdr_maxsz + \
 				 decode_exchange_id_maxsz)
+#define NFS4_enc_create_session_sz \
+				(compound_encode_hdr_maxsz + \
+				 encode_create_session_maxsz)
+#define NFS4_dec_create_session_sz \
+				(compound_decode_hdr_maxsz + \
+				 decode_create_session_maxsz)
 #define NFS4_enc_get_lease_time_sz	(compound_encode_hdr_maxsz + \
 					 encode_sequence_maxsz + \
 					 encode_putrootfh_maxsz + \
@@ -1601,6 +1634,69 @@ static int encode_exchange_id(struct xdr_stream *xdr,
 	return 0;
 }
 
+static int encode_create_session(struct xdr_stream *xdr,
+				 struct nfs41_create_session_args *args,
+				 struct compound_hdr *hdr)
+{
+	uint32_t *p;
+	char machine_name[NFS4_MAX_MACHINE_NAME_LEN];
+	uint32_t len;
+	struct nfs_client *clp = args->client;
+
+	RESERVE_SPACE(4);
+	WRITE32(OP_CREATE_SESSION);
+
+	RESERVE_SPACE(8);
+	WRITE64(clp->cl_ex_clid);
+
+	RESERVE_SPACE(8);
+	WRITE32(clp->cl_seqid);			/*Sequence id */
+	WRITE32(args->flags);			/*flags */
+
+	RESERVE_SPACE(2*28);			/* 2 channel_attrs */
+	/* Fore Channel */
+	WRITE32(args->fc_attrs.headerpadsz);	/* header padding size */
+	WRITE32(args->fc_attrs.max_rqst_sz);	/* max req size */
+	WRITE32(args->fc_attrs.max_resp_sz);	/* max resp size */
+	WRITE32(args->fc_attrs.max_resp_sz_cached);	/* Max resp sz cached */
+	WRITE32(args->fc_attrs.max_ops);	/* max operations */
+	WRITE32(args->fc_attrs.max_reqs);	/* max requests */
+	WRITE32(0);				/* rdmachannel_attrs */
+
+	/* Back Channel */
+	WRITE32(args->fc_attrs.headerpadsz);	/* header padding size */
+	WRITE32(args->bc_attrs.max_rqst_sz);	/* max req size */
+	WRITE32(args->bc_attrs.max_resp_sz);	/* max resp size */
+	WRITE32(args->bc_attrs.max_resp_sz_cached);	/* Max resp sz cached */
+	WRITE32(args->bc_attrs.max_ops);	/* max operations */
+	WRITE32(args->bc_attrs.max_reqs);	/* max requests */
+	WRITE32(0);				/* rdmachannel_attrs */
+
+	RESERVE_SPACE(4);
+	WRITE32(args->cb_program);		/* cb_program */
+
+	RESERVE_SPACE(4);			/* # of security flavors */
+	WRITE32(1);
+
+	RESERVE_SPACE(4);
+	WRITE32(RPC_AUTH_UNIX);			/* auth_sys */
+
+	/* authsys_parms rfc1831 */
+	RESERVE_SPACE(4);
+	WRITE32((u32)clp->cl_boot_time.tv_nsec);	/* stamp */
+	len = scnprintf(machine_name, sizeof(machine_name), "%s",
+			clp->cl_ipaddr);
+	RESERVE_SPACE(16 + len);
+	WRITE32(len);
+	WRITEMEM(machine_name, len);
+	WRITE32(0);				/* UID */
+	WRITE32(0);				/* GID */
+	WRITE32(0);				/* No more gids */
+	hdr->nops++;
+
+	return 0;
+}
+
 static int encode_sequence(struct xdr_stream *xdr,
 			   const struct nfs41_sequence_args *args,
 			   struct compound_hdr *hdr)
@@ -2567,6 +2663,27 @@ static int nfs4_xdr_enc_exchange_id(struct rpc_rqst *req, uint32_t *p,
 }
 
 /*
+ * a CREATE_SESSION request
+ */
+static int nfs4_xdr_enc_create_session(struct rpc_rqst *req, uint32_t *p,
+					struct nfs41_create_session_args *args)
+{
+	struct xdr_stream xdr;
+	struct compound_hdr hdr = {
+		.minorversion = req->rq_task->tk_client->cl_mvers,
+	};
+	int status;
+	__be32 *nops;
+
+	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
+	nops = encode_compound_hdr(&xdr, &hdr);
+
+	status = encode_create_session(&xdr, args, &hdr);
+	encode_nops(nops, &hdr);
+	return status;
+}
+
+/*
  * a GET_LEASE_TIME request
  */
 static int nfs4_xdr_enc_get_lease_time(struct rpc_rqst *req, uint32_t *p,
@@ -4270,6 +4387,64 @@ static int decode_exchange_id(struct xdr_stream *xdr,
 	return 0;
 }
 
+static int decode_create_session(struct xdr_stream *xdr,
+				 struct nfs41_create_session_res *res)
+{
+	uint32_t *p;
+	int status;
+	u32 nr_attrs;
+
+	struct nfs4_session *session = res->session;
+	struct nfs_client *clp = res->client;
+
+	status = decode_op_hdr(xdr, OP_CREATE_SESSION);
+
+	if (status)
+		return status;
+
+	/* sessionid */
+	READ_BUF(NFS4_MAX_SESSIONID_LEN);
+	COPYMEM(&session->sess_id, NFS4_MAX_SESSIONID_LEN);
+
+	/* seqid, flags */
+	READ_BUF(8);
+	READ32(clp->cl_seqid);
+	READ32(session->flags);
+
+	/* Channel attributes */
+	/* fore channel */
+	READ_BUF(24);
+	READ32(session->fore_channel.chan_attrs.headerpadsz);
+	READ32(session->fore_channel.chan_attrs.max_rqst_sz);
+	READ32(session->fore_channel.chan_attrs.max_resp_sz);
+	READ32(session->fore_channel.chan_attrs.max_resp_sz_cached);
+	READ32(session->fore_channel.chan_attrs.max_ops);
+	READ32(session->fore_channel.chan_attrs.max_reqs);
+	READ_BUF(4);
+	READ32(nr_attrs);
+	if (nr_attrs == 1) {
+		READ_BUF(4);
+		READ32(session->fore_channel.chan_attrs.rdma_attrs);
+	}
+
+	/* back channel */
+	READ_BUF(24);
+	READ32(session->fore_channel.chan_attrs.headerpadsz);
+	READ32(session->back_channel.chan_attrs.max_rqst_sz);
+	READ32(session->back_channel.chan_attrs.max_resp_sz);
+	READ32(session->back_channel.chan_attrs.max_resp_sz_cached);
+	READ32(session->back_channel.chan_attrs.max_ops);
+	READ32(session->back_channel.chan_attrs.max_reqs);
+	READ_BUF(4);
+	READ32(nr_attrs);
+	if (nr_attrs == 1) {
+		READ_BUF(4);
+		READ32(session->back_channel.chan_attrs.rdma_attrs);
+	}
+
+	return 0;
+}
+
 static int decode_sequence(struct xdr_stream *xdr,
 			   struct nfs41_sequence_res *res,
 			   struct rpc_rqst *rqstp)
@@ -5148,6 +5323,23 @@ static int nfs4_xdr_dec_exchange_id(struct rpc_rqst *rqstp, uint32_t *p,
 }
 
 /*
+ * a CREATE_SESSION request
+ */
+static int nfs4_xdr_dec_create_session(struct rpc_rqst *rqstp, uint32_t *p,
+					struct nfs41_create_session_res *res)
+{
+	struct xdr_stream xdr;
+	struct compound_hdr hdr;
+	int status;
+
+	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
+	status = decode_compound_hdr(&xdr, &hdr);
+	if (!status)
+		status = decode_create_session(&xdr, res);
+	return status;
+}
+
+/*
  * a GET_LEASE_TIME request
  */
 static int nfs4_xdr_dec_get_lease_time(struct rpc_rqst *rqstp, uint32_t *p,
@@ -5414,6 +5606,7 @@ struct rpc_procinfo	nfs4_procedures[] = {
   PROC(FS_LOCATIONS,	enc_fs_locations, dec_fs_locations),
 #if defined(CONFIG_NFS_V4_1)
   PROC(EXCHANGE_ID,	enc_exchange_id,	dec_exchange_id),
+  PROC(CREATE_SESSION,	enc_create_session,	dec_create_session),
   PROC(GET_LEASE_TIME,	enc_get_lease_time,	dec_get_lease_time),
 #endif /* CONFIG_NFS_V4_1 */
 };
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 976ced7..18fcc96 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -2,6 +2,9 @@
 #define _LINUX_NFS_XDR_H
 
 #include <linux/nfsacl.h>
+#ifdef CONFIG_NFS_V4_1
+#include <linux/nfs4_session.h>
+#endif
 
 /*
  * To change the maximum rsize and wsize supported by the NFS client, adjust
@@ -899,6 +902,20 @@ struct nfs41_exchange_id_res {
 	struct server_scope		server_scope;
 	struct nfs_impl_id4		impl_id;
 };
+
+struct nfs41_create_session_args {
+	struct nfs_client	       *client;
+	struct nfs4_session	       *session;
+	uint32_t			flags;
+	uint32_t			cb_program;
+	struct nfs4_channel_attrs	fc_attrs;	/* Fore Channel */
+	struct nfs4_channel_attrs	bc_attrs;	/* Back Channel */
+};
+
+struct nfs41_create_session_res {
+	struct nfs_client	       *client;
+	struct nfs4_session	       *session;
+};
 #endif /* CONFIG_NFS_V4_1 */
 
 struct nfs_page;
-- 
1.6.0.2

