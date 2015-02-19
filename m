Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f53.google.com ([209.85.220.53]:33325 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752971AbbBSTg0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Feb 2015 14:36:26 -0500
Received: by pabkx10 with SMTP id kx10so2079787pab.0
        for <linux-nfs@vger.kernel.org>; Thu, 19 Feb 2015 11:36:25 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 4/4] NFSv4.1: Clean up bind_conn_to_session
Date: Thu, 19 Feb 2015 11:36:11 -0800
Message-Id: <1424374571-4945-4-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1424374571-4945-3-git-send-email-trond.myklebust@primarydata.com>
References: <1424374571-4945-1-git-send-email-trond.myklebust@primarydata.com>
 <1424374571-4945-2-git-send-email-trond.myklebust@primarydata.com>
 <1424374571-4945-3-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We don't need to fake up an entire session in order retrieve the arguments.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c       | 28 ++++++++++++++--------------
 fs/nfs/nfs4xdr.c        | 16 ++++++++--------
 include/linux/nfs_xdr.h |  9 ++++++++-
 3 files changed, 30 insertions(+), 23 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 59853797825c..88180ac5ea0e 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6648,47 +6648,47 @@ nfs41_same_server_scope(struct nfs41_server_scope *a,
 int nfs4_proc_bind_conn_to_session(struct nfs_client *clp, struct rpc_cred *cred)
 {
 	int status;
+	struct nfs41_bind_conn_to_session_args args = {
+		.client = clp,
+		.dir = NFS4_CDFC4_FORE_OR_BOTH,
+	};
 	struct nfs41_bind_conn_to_session_res res;
 	struct rpc_message msg = {
 		.rpc_proc =
 			&nfs4_procedures[NFSPROC4_CLNT_BIND_CONN_TO_SESSION],
-		.rpc_argp = clp,
+		.rpc_argp = &args,
 		.rpc_resp = &res,
 		.rpc_cred = cred,
 	};
 
 	dprintk("--> %s\n", __func__);
 
-	res.session = kzalloc(sizeof(struct nfs4_session), GFP_NOFS);
-	if (unlikely(res.session == NULL)) {
-		status = -ENOMEM;
-		goto out;
-	}
+	nfs4_copy_sessionid(&args.sessionid, &clp->cl_session->sess_id);
+	if (!(clp->cl_session->flags & SESSION4_BACK_CHAN))
+		args.dir = NFS4_CDFC4_FORE;
 
 	status = rpc_call_sync(clp->cl_rpcclient, &msg, RPC_TASK_TIMEOUT);
 	trace_nfs4_bind_conn_to_session(clp, status);
 	if (status == 0) {
-		if (memcmp(res.session->sess_id.data,
+		if (memcmp(res.sessionid.data,
 		    clp->cl_session->sess_id.data, NFS4_MAX_SESSIONID_LEN)) {
 			dprintk("NFS: %s: Session ID mismatch\n", __func__);
 			status = -EIO;
-			goto out_session;
+			goto out;
 		}
-		if (res.dir != NFS4_CDFS4_BOTH) {
+		if ((res.dir & args.dir) != res.dir || res.dir == 0) {
 			dprintk("NFS: %s: Unexpected direction from server\n",
 				__func__);
 			status = -EIO;
-			goto out_session;
+			goto out;
 		}
-		if (res.use_conn_in_rdma_mode) {
+		if (res.use_conn_in_rdma_mode != args.use_conn_in_rdma_mode) {
 			dprintk("NFS: %s: Server returned RDMA mode = true\n",
 				__func__);
 			status = -EIO;
-			goto out_session;
+			goto out;
 		}
 	}
-out_session:
-	kfree(res.session);
 out:
 	dprintk("<-- %s status= %d\n", __func__, status);
 	return status;
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 97d4bdf53541..5c399ec41079 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1715,17 +1715,17 @@ static void encode_secinfo(struct xdr_stream *xdr, const struct qstr *name, stru
 #if defined(CONFIG_NFS_V4_1)
 /* NFSv4.1 operations */
 static void encode_bind_conn_to_session(struct xdr_stream *xdr,
-				   struct nfs4_session *session,
+				   struct nfs41_bind_conn_to_session_args *args,
 				   struct compound_hdr *hdr)
 {
 	__be32 *p;
 
 	encode_op_hdr(xdr, OP_BIND_CONN_TO_SESSION,
 		decode_bind_conn_to_session_maxsz, hdr);
-	encode_opaque_fixed(xdr, session->sess_id.data, NFS4_MAX_SESSIONID_LEN);
+	encode_opaque_fixed(xdr, args->sessionid.data, NFS4_MAX_SESSIONID_LEN);
 	p = xdr_reserve_space(xdr, 8);
-	*p++ = cpu_to_be32(NFS4_CDFC4_FORE_OR_BOTH);
-	*p = 0;	/* use_conn_in_rdma_mode = False */
+	*p++ = cpu_to_be32(args->dir);
+	*p = (args->use_conn_in_rdma_mode) ? cpu_to_be32(1) : cpu_to_be32(0);
 }
 
 static void encode_op_map(struct xdr_stream *xdr, struct nfs4_op_map *op_map)
@@ -2734,14 +2734,14 @@ static void nfs4_xdr_enc_fsid_present(struct rpc_rqst *req,
  */
 static void nfs4_xdr_enc_bind_conn_to_session(struct rpc_rqst *req,
 				struct xdr_stream *xdr,
-				struct nfs_client *clp)
+				struct nfs41_bind_conn_to_session_args *args)
 {
 	struct compound_hdr hdr = {
-		.minorversion = clp->cl_mvops->minor_version,
+		.minorversion = args->client->cl_mvops->minor_version,
 	};
 
 	encode_compound_hdr(xdr, req, &hdr);
-	encode_bind_conn_to_session(xdr, clp->cl_session, &hdr);
+	encode_bind_conn_to_session(xdr, args, &hdr);
 	encode_nops(&hdr);
 }
 
@@ -5613,7 +5613,7 @@ static int decode_bind_conn_to_session(struct xdr_stream *xdr,
 
 	status = decode_op_hdr(xdr, OP_BIND_CONN_TO_SESSION);
 	if (!status)
-		status = decode_sessionid(xdr, &res->session->sess_id);
+		status = decode_sessionid(xdr, &res->sessionid);
 	if (unlikely(status))
 		return status;
 
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 1af12fc16e98..4cb3eaa89cf7 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1167,8 +1167,15 @@ struct nfs41_impl_id {
 	struct nfstime4			date;
 };
 
+struct nfs41_bind_conn_to_session_args {
+	struct nfs_client		*client;
+	struct nfs4_sessionid		sessionid;
+	u32				dir;
+	bool				use_conn_in_rdma_mode;
+};
+
 struct nfs41_bind_conn_to_session_res {
-	struct nfs4_session		*session;
+	struct nfs4_sessionid		sessionid;
 	u32				dir;
 	bool				use_conn_in_rdma_mode;
 };
-- 
2.1.0

