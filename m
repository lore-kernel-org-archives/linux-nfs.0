From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH] SUNRPC: Fix a use after free bug with the NFSv4.1
 backchannel
Date: Fri, 19 Mar 2010 15:30:19 -0400
Message-ID: <1269027019.10771.5.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>,
	Benny Halevy <bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:10700 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750710Ab0CSTat convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Mar 2010 15:30:49 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <Trond.Myklebust@netapp.com>

The ->release_request() callback was designed to allow the transport layer
to do housekeeping after the RPC call is done. It cannot be used to free
the request itself, and doing so leads to a use-after-free bug in
xprt_release().

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 include/linux/sunrpc/bc_xprt.h |    1 -
 net/sunrpc/bc_svc.c            |   15 ---------------
 net/sunrpc/xprt.c              |   22 +++++++++-------------
 net/sunrpc/xprtsock.c          |    3 ---
 4 files changed, 9 insertions(+), 32 deletions(-)


diff --git a/include/linux/sunrpc/bc_xprt.h b/include/linux/sunrpc/bc_xprt.h
index d7152b4..2452abe 100644
--- a/include/linux/sunrpc/bc_xprt.h
+++ b/include/linux/sunrpc/bc_xprt.h
@@ -36,7 +36,6 @@ struct rpc_rqst *xprt_alloc_bc_request(struct rpc_xprt *xprt);
 void xprt_free_bc_request(struct rpc_rqst *req);
 int xprt_setup_backchannel(struct rpc_xprt *, unsigned int min_reqs);
 void xprt_destroy_backchannel(struct rpc_xprt *, int max_reqs);
-void bc_release_request(struct rpc_task *);
 int bc_send(struct rpc_rqst *req);
 
 /*
diff --git a/net/sunrpc/bc_svc.c b/net/sunrpc/bc_svc.c
index 13f214f..f0c05d3 100644
--- a/net/sunrpc/bc_svc.c
+++ b/net/sunrpc/bc_svc.c
@@ -37,21 +37,6 @@ SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 #define RPCDBG_FACILITY	RPCDBG_SVCDSP
 
-void bc_release_request(struct rpc_task *task)
-{
-	struct rpc_rqst *req = task->tk_rqstp;
-
-	dprintk("RPC:       bc_release_request: task= %p\n", task);
-
-	/*
-	 * Release this request only if it's a backchannel
-	 * preallocated request
-	 */
-	if (!bc_prealloc(req))
-		return;
-	xprt_free_bc_request(req);
-}
-
 /* Empty callback ops */
 static const struct rpc_call_ops nfs41_callback_ops = {
 };
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 469de29..42f09ad 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -46,6 +46,7 @@
 
 #include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/metrics.h>
+#include <linux/sunrpc/bc_xprt.h>
 
 #include "sunrpc.h"
 
@@ -1032,21 +1033,16 @@ void xprt_release(struct rpc_task *task)
 	if (req->rq_release_snd_buf)
 		req->rq_release_snd_buf(req);
 
-	/*
-	 * Early exit if this is a backchannel preallocated request.
-	 * There is no need to have it added to the RPC slot list.
-	 */
-	if (is_bc_request)
-		return;
-
-	memset(req, 0, sizeof(*req));	/* mark unused */
-
 	dprintk("RPC: %5u release request %p\n", task->tk_pid, req);
+	if (likely(!is_bc_request)) {
+		memset(req, 0, sizeof(*req));	/* mark unused */
 
-	spin_lock(&xprt->reserve_lock);
-	list_add(&req->rq_list, &xprt->free);
-	rpc_wake_up_next(&xprt->backlog);
-	spin_unlock(&xprt->reserve_lock);
+		spin_lock(&xprt->reserve_lock);
+		list_add(&req->rq_list, &xprt->free);
+		rpc_wake_up_next(&xprt->backlog);
+		spin_unlock(&xprt->reserve_lock);
+	} else
+		xprt_free_bc_request(req);
 }
 
 /**
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index e4839c0..9847c30 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -2251,9 +2251,6 @@ static struct rpc_xprt_ops xs_tcp_ops = {
 	.buf_free		= rpc_free,
 	.send_request		= xs_tcp_send_request,
 	.set_retrans_timeout	= xprt_set_retrans_timeout_def,
-#if defined(CONFIG_NFS_V4_1)
-	.release_request	= bc_release_request,
-#endif /* CONFIG_NFS_V4_1 */
 	.close			= xs_tcp_close,
 	.destroy		= xs_destroy,
 	.print_stats		= xs_tcp_print_stats,

