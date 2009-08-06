From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 04/10] SUNRPC: Introduce new xdr_stream-based decoders to
	rpcb_clnt.c
Date: Thu, 06 Aug 2009 14:55:00 -0400
Message-ID: <20090806185500.3458.75166.stgit@matisse.1015granger.net>
References: <20090806184944.3458.44739.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net ([76.241.169.38]:45901
	"EHLO matisse.1015granger.net" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753343AbZHFSzD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 Aug 2009 14:55:03 -0400
In-Reply-To: <20090806184944.3458.44739.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Replace the open-coded decode logic for PMAP_GETPORT/RPCB_GETADDR with
an xdr_stream-based implementation, similar to what NFSv4 uses, to
protect against buffer overflows.  The new implementation also checks
that the incoming port number is reasonable.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/rpcb_clnt.c |   80 ++++++++++++++++++++++++++++++++++++++++++++++--
 1 files changed, 77 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index fe183af..88de754 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -454,7 +454,7 @@ int rpcb_getport_sync(struct sockaddr_in *sin, u32 prog, u32 vers, int prot)
 	struct rpc_message msg = {
 		.rpc_proc	= &rpcb_procedures2[RPCBPROC_GETPORT],
 		.rpc_argp	= &map,
-		.rpc_resp	= &map.r_port,
+		.rpc_resp	= &map,
 	};
 	struct rpc_clnt	*rpcb_clnt;
 	int status;
@@ -484,7 +484,7 @@ static struct rpc_task *rpcb_call_async(struct rpc_clnt *rpcb_clnt, struct rpcbi
 	struct rpc_message msg = {
 		.rpc_proc = proc,
 		.rpc_argp = map,
-		.rpc_resp = &map->r_port,
+		.rpc_resp = map,
 	};
 	struct rpc_task_setup task_setup_data = {
 		.rpc_client = rpcb_clnt,
@@ -727,6 +727,31 @@ static int rpcb_decode_getport(struct rpc_rqst *req, __be32 *p,
 	return 0;
 }
 
+static int rpcb_dec_getport(struct rpc_rqst *req, __be32 *p,
+			    struct rpcbind_args *rpcb)
+{
+	struct rpc_task *task = req->rq_task;
+	struct xdr_stream xdr;
+	unsigned long port;
+
+	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
+
+	rpcb->r_port = 0;
+
+	p = xdr_inline_decode(&xdr, sizeof(__be32));
+	if (unlikely(p == NULL))
+		return -EIO;
+
+	port = ntohl(*p);
+	dprintk("RPC: %5u PMAP_%s result: %lu\n", task->tk_pid,
+			task->tk_msg.rpc_proc->p_name, port);
+	if (unlikely(port > USHORT_MAX))
+		return -EIO;
+
+	rpcb->r_port = port;
+	return 0;
+}
+
 static int rpcb_decode_set(struct rpc_rqst *req, __be32 *p,
 			   unsigned int *boolp)
 {
@@ -871,11 +896,60 @@ out_err:
 	return -EIO;
 }
 
+static int rpcb_dec_getaddr(struct rpc_rqst *req, __be32 *p,
+			    struct rpcbind_args *rpcb)
+{
+	struct sockaddr_storage address;
+	struct sockaddr *sap = (struct sockaddr *)&address;
+	struct rpc_task *task = req->rq_task;
+	struct xdr_stream xdr;
+	u32 len;
+
+	rpcb->r_port = 0;
+
+	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
+
+	p = xdr_inline_decode(&xdr, sizeof(__be32));
+	if (unlikely(p == NULL))
+		goto out_fail;
+	len = ntohl(*p);
+
+	/*
+	 * If the returned universal address is a null string,
+	 * the requested RPC service was not registered.
+	 */
+	if (len == 0) {
+		dprintk("RPC: %5u RPCB reply: program not registered\n",
+				task->tk_pid);
+		return 0;
+	}
+
+	if (unlikely(len > RPCBIND_MAXUADDRLEN))
+		goto out_fail;
+
+	p = xdr_inline_decode(&xdr, len);
+	if (unlikely(p == NULL))
+		goto out_fail;
+	dprintk("RPC: %5u RPCB_%s reply: %s\n", task->tk_pid,
+			task->tk_msg.rpc_proc->p_name, (char *)p);
+
+	if (rpc_uaddr2sockaddr((char *)p, len, sap, sizeof(address)) == 0)
+		goto out_fail;
+	rpcb->r_port = rpc_get_port(sap);
+
+	return 0;
+
+out_fail:
+	dprintk("RPC: %5u malformed RPCB_%s reply\n",
+			task->tk_pid, task->tk_msg.rpc_proc->p_name);
+	return -EIO;
+}
+
 #define PROC(proc, argtype, restype)					\
 	[RPCBPROC_##proc] = {						\
 		.p_proc		= RPCBPROC_##proc,			\
 		.p_encode	= (kxdrproc_t) rpcb_enc_##argtype,	\
-		.p_decode	= (kxdrproc_t) rpcb_decode_##restype,	\
+		.p_decode	= (kxdrproc_t) rpcb_dec_##restype,	\
 		.p_arglen	= RPCB_##argtype##args_sz,		\
 		.p_replen	= RPCB_##restype##res_sz,		\
 		.p_statidx	= RPCBPROC_##proc,			\

