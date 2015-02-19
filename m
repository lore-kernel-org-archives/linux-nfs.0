Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f170.google.com ([209.85.192.170]:34606 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752943AbbBSTgR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Feb 2015 14:36:17 -0500
Received: by pdjg10 with SMTP id g10so1988392pdj.1
        for <linux-nfs@vger.kernel.org>; Thu, 19 Feb 2015 11:36:17 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/4] NFSv4.1: Clean up create_session
Date: Thu, 19 Feb 2015 11:36:08 -0800
Message-Id: <1424374571-4945-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Don't decode directly into the shared struct session

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c       | 42 +++++++++++++++++++++++++++++-------------
 fs/nfs/nfs4session.h    |  6 ++++++
 fs/nfs/nfs4xdr.c        | 16 +++++++---------
 include/linux/nfs_xdr.h |  8 +++++++-
 4 files changed, 49 insertions(+), 23 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 2e7c9f7a6f7c..006bfa3da55b 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -7166,10 +7166,11 @@ static void nfs4_init_channel_attrs(struct nfs41_create_session_args *args)
 		args->bc_attrs.max_reqs);
 }
 
-static int nfs4_verify_fore_channel_attrs(struct nfs41_create_session_args *args, struct nfs4_session *session)
+static int nfs4_verify_fore_channel_attrs(struct nfs41_create_session_args *args,
+		struct nfs41_create_session_res *res)
 {
 	struct nfs4_channel_attrs *sent = &args->fc_attrs;
-	struct nfs4_channel_attrs *rcvd = &session->fc_attrs;
+	struct nfs4_channel_attrs *rcvd = &res->fc_attrs;
 
 	if (rcvd->max_resp_sz > sent->max_resp_sz)
 		return -EINVAL;
@@ -7188,10 +7189,11 @@ static int nfs4_verify_fore_channel_attrs(struct nfs41_create_session_args *args
 	return 0;
 }
 
-static int nfs4_verify_back_channel_attrs(struct nfs41_create_session_args *args, struct nfs4_session *session)
+static int nfs4_verify_back_channel_attrs(struct nfs41_create_session_args *args,
+		struct nfs41_create_session_res *res)
 {
 	struct nfs4_channel_attrs *sent = &args->bc_attrs;
-	struct nfs4_channel_attrs *rcvd = &session->bc_attrs;
+	struct nfs4_channel_attrs *rcvd = &res->bc_attrs;
 
 	if (rcvd->max_rqst_sz > sent->max_rqst_sz)
 		return -EINVAL;
@@ -7208,14 +7210,23 @@ static int nfs4_verify_back_channel_attrs(struct nfs41_create_session_args *args
 }
 
 static int nfs4_verify_channel_attrs(struct nfs41_create_session_args *args,
-				     struct nfs4_session *session)
+				     struct nfs41_create_session_res *res)
 {
 	int ret;
 
-	ret = nfs4_verify_fore_channel_attrs(args, session);
+	ret = nfs4_verify_fore_channel_attrs(args, res);
 	if (ret)
 		return ret;
-	return nfs4_verify_back_channel_attrs(args, session);
+	return nfs4_verify_back_channel_attrs(args, res);
+}
+
+static void nfs4_update_session(struct nfs4_session *session,
+		struct nfs41_create_session_res *res)
+{
+	nfs4_copy_sessionid(&session->sess_id, &res->sessionid);
+	session->flags = res->flags;
+	memcpy(&session->fc_attrs, &res->fc_attrs, sizeof(session->fc_attrs));
+	memcpy(&session->bc_attrs, &res->bc_attrs, sizeof(session->bc_attrs));
 }
 
 static int _nfs4_proc_create_session(struct nfs_client *clp,
@@ -7224,11 +7235,12 @@ static int _nfs4_proc_create_session(struct nfs_client *clp,
 	struct nfs4_session *session = clp->cl_session;
 	struct nfs41_create_session_args args = {
 		.client = clp,
+		.clientid = clp->cl_clientid,
+		.seqid = clp->cl_seqid,
 		.cb_program = NFS4_CALLBACK,
 	};
-	struct nfs41_create_session_res res = {
-		.client = clp,
-	};
+	struct nfs41_create_session_res res;
+
 	struct rpc_message msg = {
 		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_CREATE_SESSION],
 		.rpc_argp = &args,
@@ -7245,11 +7257,15 @@ static int _nfs4_proc_create_session(struct nfs_client *clp,
 
 	if (!status) {
 		/* Verify the session's negotiated channel_attrs values */
-		status = nfs4_verify_channel_attrs(&args, session);
+		status = nfs4_verify_channel_attrs(&args, &res);
 		/* Increment the clientid slot sequence id */
-		clp->cl_seqid++;
+		if (clp->cl_seqid == res.seqid)
+			clp->cl_seqid++;
+		if (status)
+			goto out;
+		nfs4_update_session(session, &res);
 	}
-
+out:
 	return status;
 }
 
diff --git a/fs/nfs/nfs4session.h b/fs/nfs/nfs4session.h
index b34ada9bc6a2..fc46c7455898 100644
--- a/fs/nfs/nfs4session.h
+++ b/fs/nfs/nfs4session.h
@@ -118,6 +118,12 @@ static inline int nfs4_has_persistent_session(const struct nfs_client *clp)
 	return 0;
 }
 
+static inline void nfs4_copy_sessionid(struct nfs4_sessionid *dst,
+		const struct nfs4_sessionid *src)
+{
+	memcpy(dst->data, src->data, NFS4_MAX_SESSIONID_LEN);
+}
+
 #ifdef CONFIG_CRC32
 /*
  * nfs_session_id_hash - calculate the crc32 hash for the session id
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index e23a0a664e12..248903b138a8 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1806,8 +1806,8 @@ static void encode_create_session(struct xdr_stream *xdr,
 
 	encode_op_hdr(xdr, OP_CREATE_SESSION, decode_create_session_maxsz, hdr);
 	p = reserve_space(xdr, 16 + 2*28 + 20 + clnt->cl_nodelen + 12);
-	p = xdr_encode_hyper(p, clp->cl_clientid);
-	*p++ = cpu_to_be32(clp->cl_seqid);			/*Sequence id */
+	p = xdr_encode_hyper(p, args->clientid);
+	*p++ = cpu_to_be32(args->seqid);			/*Sequence id */
 	*p++ = cpu_to_be32(args->flags);			/*flags */
 
 	/* Fore Channel */
@@ -5641,12 +5641,10 @@ static int decode_create_session(struct xdr_stream *xdr,
 {
 	__be32 *p;
 	int status;
-	struct nfs_client *clp = res->client;
-	struct nfs4_session *session = clp->cl_session;
 
 	status = decode_op_hdr(xdr, OP_CREATE_SESSION);
 	if (!status)
-		status = decode_sessionid(xdr, &session->sess_id);
+		status = decode_sessionid(xdr, &res->sessionid);
 	if (unlikely(status))
 		return status;
 
@@ -5654,13 +5652,13 @@ static int decode_create_session(struct xdr_stream *xdr,
 	p = xdr_inline_decode(xdr, 8);
 	if (unlikely(!p))
 		goto out_overflow;
-	clp->cl_seqid = be32_to_cpup(p++);
-	session->flags = be32_to_cpup(p);
+	res->seqid = be32_to_cpup(p++);
+	res->flags = be32_to_cpup(p);
 
 	/* Channel attributes */
-	status = decode_chan_attrs(xdr, &session->fc_attrs);
+	status = decode_chan_attrs(xdr, &res->fc_attrs);
 	if (!status)
-		status = decode_chan_attrs(xdr, &session->bc_attrs);
+		status = decode_chan_attrs(xdr, &res->bc_attrs);
 	return status;
 out_overflow:
 	print_overflow_msg(__func__, xdr);
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 9a39132fda49..1af12fc16e98 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1185,6 +1185,8 @@ struct nfs41_exchange_id_res {
 
 struct nfs41_create_session_args {
 	struct nfs_client	       *client;
+	u64				clientid;
+	uint32_t			seqid;
 	uint32_t			flags;
 	uint32_t			cb_program;
 	struct nfs4_channel_attrs	fc_attrs;	/* Fore Channel */
@@ -1192,7 +1194,11 @@ struct nfs41_create_session_args {
 };
 
 struct nfs41_create_session_res {
-	struct nfs_client	       *client;
+	struct nfs4_sessionid		sessionid;
+	uint32_t			seqid;
+	uint32_t			flags;
+	struct nfs4_channel_attrs	fc_attrs;	/* Fore Channel */
+	struct nfs4_channel_attrs	bc_attrs;	/* Back Channel */
 };
 
 struct nfs41_reclaim_complete_args {
-- 
2.1.0

