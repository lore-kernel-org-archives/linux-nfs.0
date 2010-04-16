From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH] NFSv4: Clean up the NFSv4 setclientid operation
Date: Fri, 16 Apr 2010 16:47:51 -0400
Message-ID: <1271450871-10777-6-git-send-email-Trond.Myklebust@netapp.com>
References: <1271450871-10777-1-git-send-email-Trond.Myklebust@netapp.com>
 <1271450871-10777-2-git-send-email-Trond.Myklebust@netapp.com>
 <1271450871-10777-3-git-send-email-Trond.Myklebust@netapp.com>
 <1271450871-10777-4-git-send-email-Trond.Myklebust@netapp.com>
 <1271450871-10777-5-git-send-email-Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:54877 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932522Ab0DPUrz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 16 Apr 2010 16:47:55 -0400
Received: from localhost.localdomain (marilynd-lxp.hq.netapp.com [10.58.50.136] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o3GKlp92008034
	for <linux-nfs@vger.kernel.org>; Fri, 16 Apr 2010 13:47:54 -0700 (PDT)
In-Reply-To: <1271450871-10777-5-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4_fs.h          |    4 ++--
 fs/nfs/nfs4proc.c         |   18 ++++++++++++------
 fs/nfs/nfs4state.c        |   15 ++++++++++-----
 fs/nfs/nfs4xdr.c          |   20 ++++++++++----------
 include/linux/nfs_fs_sb.h |    1 -
 include/linux/nfs_xdr.h   |    5 +++++
 6 files changed, 39 insertions(+), 24 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index a187200..5099306 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -206,8 +206,8 @@ extern ssize_t nfs4_listxattr(struct dentry *, char *, size_t);
 
 
 /* nfs4proc.c */
-extern int nfs4_proc_setclientid(struct nfs_client *, u32, unsigned short, struct rpc_cred *);
-extern int nfs4_proc_setclientid_confirm(struct nfs_client *, struct rpc_cred *);
+extern int nfs4_proc_setclientid(struct nfs_client *, u32, unsigned short, struct rpc_cred *, struct nfs4_setclientid_res *);
+extern int nfs4_proc_setclientid_confirm(struct nfs_client *, struct nfs4_setclientid_res *arg, struct rpc_cred *);
 extern int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred);
 extern int nfs4_proc_async_renew(struct nfs_client *, struct rpc_cred *);
 extern int nfs4_proc_renew(struct nfs_client *, struct rpc_cred *);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 6380670..8a9a412 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3494,7 +3494,9 @@ nfs4_async_handle_error(struct rpc_task *task, const struct nfs_server *server,
 	return _nfs4_async_handle_error(task, server, server->nfs_client, state);
 }
 
-int nfs4_proc_setclientid(struct nfs_client *clp, u32 program, unsigned short port, struct rpc_cred *cred)
+int nfs4_proc_setclientid(struct nfs_client *clp, u32 program,
+		unsigned short port, struct rpc_cred *cred,
+		struct nfs4_setclientid_res *res)
 {
 	nfs4_verifier sc_verifier;
 	struct nfs4_setclientid setclientid = {
@@ -3504,7 +3506,7 @@ int nfs4_proc_setclientid(struct nfs_client *clp, u32 program, unsigned short po
 	struct rpc_message msg = {
 		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_SETCLIENTID],
 		.rpc_argp = &setclientid,
-		.rpc_resp = clp,
+		.rpc_resp = res,
 		.rpc_cred = cred,
 	};
 	__be32 *p;
@@ -3547,12 +3549,14 @@ int nfs4_proc_setclientid(struct nfs_client *clp, u32 program, unsigned short po
 	return status;
 }
 
-static int _nfs4_proc_setclientid_confirm(struct nfs_client *clp, struct rpc_cred *cred)
+static int _nfs4_proc_setclientid_confirm(struct nfs_client *clp,
+		struct nfs4_setclientid_res *arg,
+		struct rpc_cred *cred)
 {
 	struct nfs_fsinfo fsinfo;
 	struct rpc_message msg = {
 		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_SETCLIENTID_CONFIRM],
-		.rpc_argp = clp,
+		.rpc_argp = arg,
 		.rpc_resp = &fsinfo,
 		.rpc_cred = cred,
 	};
@@ -3570,12 +3574,14 @@ static int _nfs4_proc_setclientid_confirm(struct nfs_client *clp, struct rpc_cre
 	return status;
 }
 
-int nfs4_proc_setclientid_confirm(struct nfs_client *clp, struct rpc_cred *cred)
+int nfs4_proc_setclientid_confirm(struct nfs_client *clp,
+		struct nfs4_setclientid_res *arg,
+		struct rpc_cred *cred)
 {
 	long timeout = 0;
 	int err;
 	do {
-		err = _nfs4_proc_setclientid_confirm(clp, cred);
+		err = _nfs4_proc_setclientid_confirm(clp, arg, cred);
 		switch (err) {
 			case 0:
 				return err;
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 6c5ed51..cd2d904 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -62,6 +62,7 @@ static LIST_HEAD(nfs4_clientid_list);
 
 int nfs4_init_clientid(struct nfs_client *clp, struct rpc_cred *cred)
 {
+	struct nfs4_setclientid_res clid;
 	unsigned short port;
 	int status;
 
@@ -69,11 +70,15 @@ int nfs4_init_clientid(struct nfs_client *clp, struct rpc_cred *cred)
 	if (clp->cl_addr.ss_family == AF_INET6)
 		port = nfs_callback_tcpport6;
 
-	status = nfs4_proc_setclientid(clp, NFS4_CALLBACK, port, cred);
-	if (status == 0)
-		status = nfs4_proc_setclientid_confirm(clp, cred);
-	if (status == 0)
-		nfs4_schedule_state_renewal(clp);
+	status = nfs4_proc_setclientid(clp, NFS4_CALLBACK, port, cred, &clid);
+	if (status != 0)
+		goto out;
+	status = nfs4_proc_setclientid_confirm(clp, &clid, cred);
+	if (status != 0)
+		goto out;
+	clp->cl_clientid = clid.clientid;
+	nfs4_schedule_state_renewal(clp);
+out:
 	return status;
 }
 
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 38f3b58..d66f9ac 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1504,14 +1504,14 @@ static void encode_setclientid(struct xdr_stream *xdr, const struct nfs4_setclie
 	hdr->replen += decode_setclientid_maxsz;
 }
 
-static void encode_setclientid_confirm(struct xdr_stream *xdr, const struct nfs_client *client_state, struct compound_hdr *hdr)
+static void encode_setclientid_confirm(struct xdr_stream *xdr, const struct nfs4_setclientid_res *arg, struct compound_hdr *hdr)
 {
 	__be32 *p;
 
 	p = reserve_space(xdr, 12 + NFS4_VERIFIER_SIZE);
 	*p++ = cpu_to_be32(OP_SETCLIENTID_CONFIRM);
-	p = xdr_encode_hyper(p, client_state->cl_clientid);
-	xdr_encode_opaque_fixed(p, client_state->cl_confirm.data, NFS4_VERIFIER_SIZE);
+	p = xdr_encode_hyper(p, arg->clientid);
+	xdr_encode_opaque_fixed(p, arg->confirm.data, NFS4_VERIFIER_SIZE);
 	hdr->nops++;
 	hdr->replen += decode_setclientid_confirm_maxsz;
 }
@@ -2324,7 +2324,7 @@ static int nfs4_xdr_enc_setclientid(struct rpc_rqst *req, __be32 *p, struct nfs4
 /*
  * a SETCLIENTID_CONFIRM request
  */
-static int nfs4_xdr_enc_setclientid_confirm(struct rpc_rqst *req, __be32 *p, struct nfs_client *clp)
+static int nfs4_xdr_enc_setclientid_confirm(struct rpc_rqst *req, __be32 *p, struct nfs4_setclientid_res *arg)
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
@@ -2334,7 +2334,7 @@ static int nfs4_xdr_enc_setclientid_confirm(struct rpc_rqst *req, __be32 *p, str
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
-	encode_setclientid_confirm(&xdr, clp, &hdr);
+	encode_setclientid_confirm(&xdr, arg, &hdr);
 	encode_putrootfh(&xdr, &hdr);
 	encode_fsinfo(&xdr, lease_bitmap, &hdr);
 	encode_nops(&hdr);
@@ -4397,7 +4397,7 @@ out_overflow:
 	return -EIO;
 }
 
-static int decode_setclientid(struct xdr_stream *xdr, struct nfs_client *clp)
+static int decode_setclientid(struct xdr_stream *xdr, struct nfs4_setclientid_res *res)
 {
 	__be32 *p;
 	uint32_t opnum;
@@ -4417,8 +4417,8 @@ static int decode_setclientid(struct xdr_stream *xdr, struct nfs_client *clp)
 		p = xdr_inline_decode(xdr, 8 + NFS4_VERIFIER_SIZE);
 		if (unlikely(!p))
 			goto out_overflow;
-		p = xdr_decode_hyper(p, &clp->cl_clientid);
-		memcpy(clp->cl_confirm.data, p, NFS4_VERIFIER_SIZE);
+		p = xdr_decode_hyper(p, &res->clientid);
+		memcpy(res->confirm.data, p, NFS4_VERIFIER_SIZE);
 	} else if (nfserr == NFSERR_CLID_INUSE) {
 		uint32_t len;
 
@@ -5498,7 +5498,7 @@ static int nfs4_xdr_dec_renew(struct rpc_rqst *rqstp, __be32 *p, void *dummy)
  * Decode SETCLIENTID response
  */
 static int nfs4_xdr_dec_setclientid(struct rpc_rqst *req, __be32 *p,
-		struct nfs_client *clp)
+		struct nfs4_setclientid_res *res)
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr;
@@ -5507,7 +5507,7 @@ static int nfs4_xdr_dec_setclientid(struct rpc_rqst *req, __be32 *p,
 	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
 	status = decode_compound_hdr(&xdr, &hdr);
 	if (!status)
-		status = decode_setclientid(&xdr, clp);
+		status = decode_setclientid(&xdr, res);
 	return status;
 }
 
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index e82957a..d6e10a4 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -44,7 +44,6 @@ struct nfs_client {
 
 #ifdef CONFIG_NFS_V4
 	u64			cl_clientid;	/* constant */
-	nfs4_verifier		cl_confirm;
 	unsigned long		cl_state;
 
 	struct rb_root		cl_openowner_id;
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 89b2881..6b31645 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -824,6 +824,11 @@ struct nfs4_setclientid {
 	u32				sc_cb_ident;
 };
 
+struct nfs4_setclientid_res {
+	u64				clientid;
+	nfs4_verifier			confirm;
+};
+
 struct nfs4_statfs_arg {
 	const struct nfs_fh *		fh;
 	const u32 *			bitmask;
-- 
1.6.6.1

