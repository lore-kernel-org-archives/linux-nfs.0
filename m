From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 04/10] SUNRPC: Introduce new xdr_stream-based decoders to
	rpcb_clnt.c
Date: Wed, 15 Jul 2009 17:42:16 -0400
Message-ID: <20090715214216.7883.57212.stgit@matisse.1015granger.net>
References: <20090715213842.7883.48947.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net ([76.241.169.38]:60984
	"EHLO matisse.1015granger.net" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753136AbZGOVmT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Jul 2009 17:42:19 -0400
In-Reply-To: <20090715213842.7883.48947.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Replace the open-coded decode logic for PMAP_GETPORT/RPCB_GETADDR with
an xdr_stream-based implementation, similar to what NFSv4 uses, to
protect against buffer overflows.  The new implementation also checks
that the incoming port number is reasonable.

In the age of TI-RPC, rpcbind RPCB_GETADDR replies return a full
address to which the client should bind.  Introduce support in the
PMAP_GETPORT and RPCB_GETADDR XDR decoders for handing back a
full address for successful rpcbind operations.  Subsequent patches
will pass this address to the parent transport's ->set_port method.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/rpcb_clnt.c |  150 +++++++++++++++++++++++++++++++++++++++++++++---
 1 files changed, 142 insertions(+), 8 deletions(-)

diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index d52bb0f..91af1f8 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -14,6 +14,7 @@
 
 #include <linux/module.h>
 
+#include <linux/kernel.h>
 #include <linux/types.h>
 #include <linux/socket.h>
 #include <linux/in.h>
@@ -122,6 +123,8 @@ struct rpcbind_args {
 	const char *		r_owner;
 
 	int			r_status;
+	struct sockaddr_storage	r_raddr;
+	size_t			r_raddrlen;
 };
 
 static struct rpc_procinfo rpcb_procedures2[];
@@ -157,6 +160,18 @@ static void rpcb_map_release(void *data)
 	kfree(map);
 }
 
+static const struct sockaddr rpcb_inaddr_unspec = {
+	.sa_family		= AF_UNSPEC,
+};
+
+static void rpcb_set_unspec_raddr(struct rpcbind_args *rpcb)
+{
+	struct sockaddr *sap = (struct sockaddr *)&rpcb->r_raddr;
+
+	rpcb->r_raddrlen = sizeof(rpcb_inaddr_unspec);
+	memcpy(sap, &rpcb_inaddr_unspec, rpcb->r_raddrlen);
+}
+
 static const struct sockaddr_in rpcb_inaddr_loopback = {
 	.sin_family		= AF_INET,
 	.sin_addr.s_addr	= htonl(INADDR_LOOPBACK),
@@ -454,7 +469,7 @@ int rpcb_getport_sync(struct sockaddr_in *sin, u32 prog, u32 vers, int prot)
 	struct rpc_message msg = {
 		.rpc_proc	= &rpcb_procedures2[RPCBPROC_GETPORT],
 		.rpc_argp	= &map,
-		.rpc_resp	= &map.r_port,
+		.rpc_resp	= &map,
 	};
 	struct rpc_clnt	*rpcb_clnt;
 	int status;
@@ -467,12 +482,14 @@ int rpcb_getport_sync(struct sockaddr_in *sin, u32 prog, u32 vers, int prot)
 	if (IS_ERR(rpcb_clnt))
 		return PTR_ERR(rpcb_clnt);
 
+	memcpy(&map.r_raddr, sin, sizeof(*sin));
 	status = rpc_call_sync(rpcb_clnt, &msg, 0);
 	rpc_shutdown_client(rpcb_clnt);
 
 	if (status >= 0) {
-		if (map.r_port != 0)
-			return map.r_port;
+		sin = (struct sockaddr_in *)&map.r_raddr;
+		if (sin->sin_family == AF_INET)
+			return ntohs(sin->sin_port);
 		status = -EACCES;
 	}
 	return status;
@@ -484,7 +501,7 @@ static struct rpc_task *rpcb_call_async(struct rpc_clnt *rpcb_clnt, struct rpcbi
 	struct rpc_message msg = {
 		.rpc_proc = proc,
 		.rpc_argp = map,
-		.rpc_resp = &map->r_port,
+		.rpc_resp = map,
 	};
 	struct rpc_task_setup task_setup_data = {
 		.rpc_client = rpcb_clnt,
@@ -627,6 +644,8 @@ void rpcb_getport_async(struct rpc_task *task)
 		break;
 	case RPCBVERS_2:
 		map->r_addr = NULL;
+		memcpy(&map->r_raddr, sap, salen);
+		map->r_raddrlen = salen;
 		break;
 	default:
 		BUG();
@@ -659,8 +678,10 @@ EXPORT_SYMBOL_GPL(rpcb_getport_async);
 static void rpcb_getport_done(struct rpc_task *child, void *data)
 {
 	struct rpcbind_args *map = data;
+	struct sockaddr *sap = (struct sockaddr *)&map->r_raddr;
 	struct rpc_xprt *xprt = map->r_xprt;
 	int status = child->tk_status;
+	unsigned short port = 0;
 
 	/* Garbage reply: retry with a lesser rpcbind version */
 	if (status == -EIO)
@@ -673,19 +694,30 @@ static void rpcb_getport_done(struct rpc_task *child, void *data)
 	if (status < 0) {
 		/* rpcbind server not available on remote host? */
 		xprt->ops->set_port(xprt, 0);
-	} else if (map->r_port == 0) {
+		xprt_clear_bound(xprt);
+	} else if (sap->sa_family == AF_UNSPEC) {
 		/* Requested RPC service wasn't registered on remote host */
 		xprt->ops->set_port(xprt, 0);
+		xprt_clear_bound(xprt);
 		status = -EACCES;
 	} else {
 		/* Succeeded */
-		xprt->ops->set_port(xprt, map->r_port);
+		switch (sap->sa_family) {
+		case AF_INET:
+			port = ntohs(((struct sockaddr_in *)sap)->sin_port);
+			break;
+		case AF_INET6:
+			port = ntohs(((struct sockaddr_in6 *)sap)->sin6_port);
+			break;
+		}
+
+		xprt->ops->set_port(xprt, port);
 		xprt_set_bound(xprt);
 		status = 0;
 	}
 
 	dprintk("RPC: %5u rpcb_getport_done(status %d, port %u)\n",
-			child->tk_pid, status, map->r_port);
+			child->tk_pid, status, port);
 
 	map->r_status = status;
 }
@@ -727,6 +759,37 @@ static int rpcb_decode_getport(struct rpc_rqst *req, __be32 *p,
 	return 0;
 }
 
+static int rpcb_dec_getport(struct rpc_rqst *req, __be32 *p,
+			    struct rpcbind_args *rpcb)
+{
+	struct sockaddr *sap = (struct sockaddr *)&rpcb->r_raddr;
+	struct rpc_task *task = req->rq_task;
+	struct xdr_stream xdr;
+	unsigned long port;
+
+	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
+
+	p = xdr_inline_decode(&xdr, sizeof(u32));
+	if (unlikely(p == NULL))
+		return -EIO;
+	port = ntohl(*p);
+	dprintk("RPC: %5u PMAP_%s result: %lu\n", task->tk_pid,
+			task->tk_msg.rpc_proc->p_name, port);
+
+	if (unlikely(port > USHORT_MAX))
+		return -EIO;
+
+	if (sap->sa_family != AF_INET)
+		return -EIO;
+
+	if (port == 0)
+		rpcb_set_unspec_raddr(rpcb);
+	else
+		((struct sockaddr_in *)sap)->sin_port = htons(port);
+
+	return 0;
+}
+
 static int rpcb_decode_set(struct rpc_rqst *req, __be32 *p,
 			   unsigned int *boolp)
 {
@@ -871,11 +934,82 @@ out_err:
 	return -EIO;
 }
 
+static int rpcb_dec_getaddr(struct rpc_rqst *req, __be32 *p,
+			    struct rpcbind_args *rpcb)
+{
+	struct sockaddr *sap = (struct sockaddr *)&rpcb->r_raddr;
+	size_t salen = sizeof(rpcb->r_raddr);
+	struct rpc_task *task = req->rq_task;
+	struct sockaddr_in6 sin6;
+	struct xdr_stream xdr;
+	u32 len;
+
+	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
+
+	p = xdr_inline_decode(&xdr, sizeof(u32));
+	if (unlikely(p == NULL))
+		goto out_fail;
+	len = ntohl(*p);
+
+	/*
+	 * Special case: if the returned universal address is a null
+	 * string, the requested RPC service was not registered.
+	 */
+	if (len == 0) {
+		rpcb_set_unspec_raddr(rpcb);
+		dprintk("RPC:       RPCB reply: program not registered\n");
+		return 0;
+	}
+
+	if (unlikely(len > RPCBIND_MAXUADDRLEN))
+		goto out_fail;
+
+	p = xdr_inline_decode(&xdr, len);
+	if (unlikely(p == NULL))
+		goto out_fail;
+
+	/*
+	 * If both the parent's destination address and the returned
+	 * address are site-local, or both are link-local, copy the
+	 * scope ID from the parent's address.  Universal addresses
+	 * do not support scope IDs.
+	 */
+	if (sap->sa_family == AF_INET6)
+		memcpy(&sin6, sap, sizeof(sin6));
+
+	salen = rpc_uaddr2sockaddr((char *)p, len, sap, salen);
+	if (unlikely(salen == 0))
+		goto out_fail;
+	rpcb->r_raddrlen = salen;
+
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+	/* NB: sap now contains the returned address */
+	if (sap->sa_family == AF_INET6) {
+		struct sockaddr_in6 *recvd = (struct sockaddr_in6 *)sap;
+
+		if ((ipv6_addr_type(&sin6.sin6_addr) & IPV6_ADDR_LINKLOCAL &&
+		    ipv6_addr_type(&recvd->sin6_addr) & IPV6_ADDR_LINKLOCAL) ||
+		    (ipv6_addr_type(&sin6.sin6_addr) & IPV6_ADDR_SITELOCAL &&
+		    ipv6_addr_type(&recvd->sin6_addr) & IPV6_ADDR_SITELOCAL))
+			recvd->sin6_scope_id = sin6.sin6_scope_id;
+	}
+#endif
+
+	dprintk("RPC: %5u RPCB_%s reply: %s\n", task->tk_pid,
+			task->tk_msg.rpc_proc->p_name, (char *)p);
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

