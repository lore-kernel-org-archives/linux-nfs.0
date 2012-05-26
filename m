Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:64117 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754264Ab2EZSkZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 26 May 2012 14:40:25 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 8/9] NFSv4.1: Add DESTROY_CLIENTID
Date: Sat, 26 May 2012 14:39:59 -0400
Message-Id: <1338057600-11130-8-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1338057600-11130-7-git-send-email-Trond.Myklebust@netapp.com>
References: <1338057600-11130-1-git-send-email-Trond.Myklebust@netapp.com>
 <1338057600-11130-2-git-send-email-Trond.Myklebust@netapp.com>
 <1338057600-11130-3-git-send-email-Trond.Myklebust@netapp.com>
 <1338057600-11130-4-git-send-email-Trond.Myklebust@netapp.com>
 <1338057600-11130-5-git-send-email-Trond.Myklebust@netapp.com>
 <1338057600-11130-6-git-send-email-Trond.Myklebust@netapp.com>
 <1338057600-11130-7-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ensure that we destroy our lease on last unmount

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/client.c      |    1 +
 fs/nfs/nfs4_fs.h     |    1 +
 fs/nfs/nfs4proc.c    |   59 ++++++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/nfs4xdr.c     |   52 ++++++++++++++++++++++++++++++++++++++++++++
 include/linux/nfs4.h |    1 +
 5 files changed, 114 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index a50bdfb..7d10875 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -209,6 +209,7 @@ static void nfs4_shutdown_session(struct nfs_client *clp)
 	if (nfs4_has_session(clp)) {
 		nfs4_deviceid_purge_client(clp);
 		nfs4_destroy_session(clp->cl_session);
+		nfs4_destroy_clientid(clp);
 	}
 
 }
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index f730730..b20b516 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -214,6 +214,7 @@ extern int nfs4_proc_setclientid_confirm(struct nfs_client *, struct nfs4_setcli
 extern int nfs4_proc_get_rootfh(struct nfs_server *, struct nfs_fh *, struct nfs_fsinfo *);
 extern int nfs4_proc_bind_conn_to_session(struct nfs_client *, struct rpc_cred *cred);
 extern int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred);
+extern int nfs4_destroy_clientid(struct nfs_client *clp);
 extern int nfs4_init_clientid(struct nfs_client *, struct rpc_cred *);
 extern int nfs41_init_clientid(struct nfs_client *, struct rpc_cred *);
 extern int nfs4_do_close(struct nfs4_state *state, gfp_t gfp_mask, int wait, bool roc);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 3fdff0c..485a6c0 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5261,6 +5261,65 @@ out:
 	return status;
 }
 
+static int _nfs4_proc_destroy_clientid(struct nfs_client *clp,
+		struct rpc_cred *cred)
+{
+	struct rpc_message msg = {
+		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_DESTROY_CLIENTID],
+		.rpc_argp = clp,
+		.rpc_cred = cred,
+	};
+	int status;
+
+	status = rpc_call_sync(clp->cl_rpcclient, &msg, RPC_TASK_TIMEOUT);
+	if (status)
+		pr_warn("NFS: Got error %d from the server %s on "
+			"DESTROY_CLIENTID.", status, clp->cl_hostname);
+	return status;
+}
+
+static int nfs4_proc_destroy_clientid(struct nfs_client *clp,
+		struct rpc_cred *cred)
+{
+	unsigned int loop;
+	int ret;
+
+	for (loop = NFS4_MAX_LOOP_ON_RECOVER; loop != 0; loop--) {
+		ret = _nfs4_proc_destroy_clientid(clp, cred);
+		switch (ret) {
+		case -NFS4ERR_DELAY:
+		case -NFS4ERR_CLIENTID_BUSY:
+			ssleep(1);
+			break;
+		default:
+			return ret;
+		}
+	}
+	return 0;
+}
+
+int nfs4_destroy_clientid(struct nfs_client *clp)
+{
+	struct rpc_cred *cred;
+	int ret = 0;
+
+	if (clp->cl_mvops->minor_version < 1)
+		goto out;
+	if (clp->cl_exchange_flags == 0)
+		goto out;
+	cred = nfs4_get_exchange_id_cred(clp);
+	ret = nfs4_proc_destroy_clientid(clp, cred);
+	if (cred)
+		put_rpccred(cred);
+	switch (ret) {
+	case 0:
+	case -NFS4ERR_STALE_CLIENTID:
+		clp->cl_exchange_flags = 0;
+	}
+out:
+	return ret;
+}
+
 struct nfs4_get_lease_time_data {
 	struct nfs4_get_lease_time_args *args;
 	struct nfs4_get_lease_time_res *res;
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 1d4d259..b9ce3fd 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -338,6 +338,8 @@ static int nfs4_stat_to_errno(int);
 				     1 /* bctsr_use_conn_in_rdma_mode */)
 #define encode_destroy_session_maxsz    (op_encode_hdr_maxsz + 4)
 #define decode_destroy_session_maxsz    (op_decode_hdr_maxsz)
+#define encode_destroy_clientid_maxsz   (op_encode_hdr_maxsz + 2)
+#define decode_destroy_clientid_maxsz   (op_decode_hdr_maxsz)
 #define encode_sequence_maxsz	(op_encode_hdr_maxsz + \
 				XDR_QUADLEN(NFS4_MAX_SESSIONID_LEN) + 4)
 #define decode_sequence_maxsz	(op_decode_hdr_maxsz + \
@@ -751,6 +753,10 @@ static int nfs4_stat_to_errno(int);
 					 encode_destroy_session_maxsz)
 #define NFS4_dec_destroy_session_sz	(compound_decode_hdr_maxsz + \
 					 decode_destroy_session_maxsz)
+#define NFS4_enc_destroy_clientid_sz	(compound_encode_hdr_maxsz + \
+					 encode_destroy_clientid_maxsz)
+#define NFS4_dec_destroy_clientid_sz	(compound_decode_hdr_maxsz + \
+					 decode_destroy_clientid_maxsz)
 #define NFS4_enc_sequence_sz \
 				(compound_decode_hdr_maxsz + \
 				 encode_sequence_maxsz)
@@ -1804,6 +1810,14 @@ static void encode_destroy_session(struct xdr_stream *xdr,
 	encode_opaque_fixed(xdr, session->sess_id.data, NFS4_MAX_SESSIONID_LEN);
 }
 
+static void encode_destroy_clientid(struct xdr_stream *xdr,
+				   uint64_t clientid,
+				   struct compound_hdr *hdr)
+{
+	encode_op_hdr(xdr, OP_DESTROY_CLIENTID, decode_destroy_clientid_maxsz, hdr);
+	encode_uint64(xdr, clientid);
+}
+
 static void encode_reclaim_complete(struct xdr_stream *xdr,
 				    struct nfs41_reclaim_complete_args *args,
 				    struct compound_hdr *hdr)
@@ -2724,6 +2738,22 @@ static void nfs4_xdr_enc_destroy_session(struct rpc_rqst *req,
 }
 
 /*
+ * a DESTROY_CLIENTID request
+ */
+static void nfs4_xdr_enc_destroy_clientid(struct rpc_rqst *req,
+					 struct xdr_stream *xdr,
+					 struct nfs_client *clp)
+{
+	struct compound_hdr hdr = {
+		.minorversion = clp->cl_mvops->minor_version,
+	};
+
+	encode_compound_hdr(xdr, req, &hdr);
+	encode_destroy_clientid(xdr, clp->cl_clientid, &hdr);
+	encode_nops(&hdr);
+}
+
+/*
  * a SEQUENCE request
  */
 static void nfs4_xdr_enc_sequence(struct rpc_rqst *req, struct xdr_stream *xdr,
@@ -5479,6 +5509,11 @@ static int decode_destroy_session(struct xdr_stream *xdr, void *dummy)
 	return decode_op_hdr(xdr, OP_DESTROY_SESSION);
 }
 
+static int decode_destroy_clientid(struct xdr_stream *xdr, void *dummy)
+{
+	return decode_op_hdr(xdr, OP_DESTROY_CLIENTID);
+}
+
 static int decode_reclaim_complete(struct xdr_stream *xdr, void *dummy)
 {
 	return decode_op_hdr(xdr, OP_RECLAIM_COMPLETE);
@@ -6789,6 +6824,22 @@ static int nfs4_xdr_dec_destroy_session(struct rpc_rqst *rqstp,
 }
 
 /*
+ * Decode DESTROY_CLIENTID response
+ */
+static int nfs4_xdr_dec_destroy_clientid(struct rpc_rqst *rqstp,
+					struct xdr_stream *xdr,
+					void *res)
+{
+	struct compound_hdr hdr;
+	int status;
+
+	status = decode_compound_hdr(xdr, &hdr);
+	if (!status)
+		status = decode_destroy_clientid(xdr, res);
+	return status;
+}
+
+/*
  * Decode SEQUENCE response
  */
 static int nfs4_xdr_dec_sequence(struct rpc_rqst *rqstp,
@@ -7237,6 +7288,7 @@ struct rpc_procinfo	nfs4_procedures[] = {
 	PROC(GETDEVICELIST,	enc_getdevicelist,	dec_getdevicelist),
 	PROC(BIND_CONN_TO_SESSION,
 			enc_bind_conn_to_session, dec_bind_conn_to_session),
+	PROC(DESTROY_CLIENTID,	enc_destroy_clientid,	dec_destroy_clientid),
 #endif /* CONFIG_NFS_V4_1 */
 };
 
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 54006a9..af2d2fa 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -608,6 +608,7 @@ enum {
 	NFSPROC4_CLNT_FREE_STATEID,
 	NFSPROC4_CLNT_GETDEVICELIST,
 	NFSPROC4_CLNT_BIND_CONN_TO_SESSION,
+	NFSPROC4_CLNT_DESTROY_CLIENTID,
 };
 
 /* nfs41 types */
-- 
1.7.7.6

