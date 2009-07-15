Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net ([76.241.169.38]:60975
	"EHLO matisse.1015granger.net" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752749AbZGOVl6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Jul 2009 17:41:58 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 01/10] SUNRPC: Introduce new xdr_stream-based encoders to
	rpcb_clnt.c
To: trond.myklebust@fys.uio.no
Cc: linux-nfs@vger.kernel.org
Date: Wed, 15 Jul 2009 17:41:55 -0400
Message-ID: <20090715214154.7883.34731.stgit@matisse.1015granger.net>
In-Reply-To: <20090715213842.7883.48947.stgit@matisse.1015granger.net>
References: <20090715213842.7883.48947.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Replace the open-coded encode logic for rpcbind arguments with an
xdr_stream-based implementation, similar to what NFSv4 uses, to
better protect against buffer overflows.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/rpcb_clnt.c |   76 +++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 75 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 1fb1c07..2e8be8f 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -708,6 +708,30 @@ static int rpcb_encode_mapping(struct rpc_rqst *req, __be32 *p,
 	return 0;
 }
 
+static int rpcb_enc_mapping(struct rpc_rqst *req, __be32 *p,
+			    const struct rpcbind_args *rpcb)
+{
+	struct rpc_task *task = req->rq_task;
+	struct xdr_stream xdr;
+
+	dprintk("RPC: %5u encoding PMAP_%s call (%u, %u, %d, %u)\n",
+			task->tk_pid, task->tk_msg.rpc_proc->p_name,
+			rpcb->r_prog, rpcb->r_vers, rpcb->r_prot, rpcb->r_port);
+
+	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
+
+	p = xdr_reserve_space(&xdr, sizeof(u32) * RPCB_mappingargs_sz);
+	if (unlikely(p == NULL))
+		return -EIO;
+
+	*p++ = htonl(rpcb->r_prog);
+	*p++ = htonl(rpcb->r_vers);
+	*p++ = htonl(rpcb->r_prot);
+	*p   = htonl(rpcb->r_port);
+
+	return 0;
+}
+
 static int rpcb_decode_getport(struct rpc_rqst *req, __be32 *p,
 			       unsigned short *portp)
 {
@@ -746,6 +770,56 @@ static int rpcb_encode_getaddr(struct rpc_rqst *req, __be32 *p,
 	return 0;
 }
 
+static int encode_rpcb_string(struct xdr_stream *xdr, const char *string,
+				const u32 maxstrlen)
+{
+	u32 len;
+	__be32 *p;
+
+	if (unlikely(string == NULL))
+		return -EIO;
+	len = strlen(string);
+	if (unlikely(len > maxstrlen))
+		return -EIO;
+
+	p = xdr_reserve_space(xdr, sizeof(u32) + len);
+	if (unlikely(p == NULL))
+		return -EIO;
+	xdr_encode_opaque(p, string, len);
+
+	return 0;
+}
+
+static int rpcb_enc_getaddr(struct rpc_rqst *req, __be32 *p,
+			    const struct rpcbind_args *rpcb)
+{
+	struct rpc_task *task = req->rq_task;
+	struct xdr_stream xdr;
+
+	dprintk("RPC: %5u encoding RPCB_%s call (%u, %u, '%s', '%s')\n",
+			task->tk_pid, task->tk_msg.rpc_proc->p_name,
+			rpcb->r_prog, rpcb->r_vers,
+			rpcb->r_netid, rpcb->r_addr);
+
+	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
+
+	p = xdr_reserve_space(&xdr,
+			sizeof(u32) * (RPCB_program_sz + RPCB_version_sz));
+	if (unlikely(p == NULL))
+		return -EIO;
+	*p++ = htonl(rpcb->r_prog);
+	*p = htonl(rpcb->r_vers);
+
+	if (encode_rpcb_string(&xdr, rpcb->r_netid, RPCBIND_MAXNETIDLEN))
+		return -EIO;
+	if (encode_rpcb_string(&xdr, rpcb->r_addr, RPCBIND_MAXUADDRLEN))
+		return -EIO;
+	if (encode_rpcb_string(&xdr, rpcb->r_owner, RPCB_MAXOWNERLEN))
+		return -EIO;
+
+	return 0;
+}
+
 static int rpcb_decode_getaddr(struct rpc_rqst *req, __be32 *p,
 			       unsigned short *portp)
 {
@@ -812,7 +886,7 @@ out_err:
 #define PROC(proc, argtype, restype)					\
 	[RPCBPROC_##proc] = {						\
 		.p_proc		= RPCBPROC_##proc,			\
-		.p_encode	= (kxdrproc_t) rpcb_encode_##argtype,	\
+		.p_encode	= (kxdrproc_t) rpcb_enc_##argtype,	\
 		.p_decode	= (kxdrproc_t) rpcb_decode_##restype,	\
 		.p_arglen	= RPCB_##argtype##args_sz,		\
 		.p_replen	= RPCB_##restype##res_sz,		\

