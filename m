Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f178.google.com ([209.85.223.178]:52880 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932257AbaBKTmX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Feb 2014 14:42:23 -0500
Received: by mail-ie0-f178.google.com with SMTP id rl12so1630219iec.37
        for <linux-nfs@vger.kernel.org>; Tue, 11 Feb 2014 11:42:23 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: shaobingqing <shaobingqing@bwstor.com.cn>
Subject: [PATCH v2] SUNRPC: RPC callbacks may be split across several TCP segments
Date: Tue, 11 Feb 2014 14:42:20 -0500
Message-Id: <1392147740-23272-1-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1392054402.16327.9.camel@leira.trondhjem.org>
References: <1392054402.16327.9.camel@leira.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Since TCP is a stream protocol, our callback read code needs to take into
account the fact that RPC callbacks are not always confined to a single
TCP segment.
This patch adds support for multiple TCP segments by ensuring that we
only remove the rpc_rqst structure from the 'free backchannel requests'
list once the data has been completely received. We rely on the fact
that TCP data is ordered for the duration of the connection.

Reported-by: shaobingqing <shaobingqing@bwstor.com.cn>
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
v2: fix a list corruption issue

 include/linux/sunrpc/bc_xprt.h |  3 +-
 net/sunrpc/backchannel_rqst.c  | 93 +++++++++++++++++++++++++++++-------------
 net/sunrpc/xprtsock.c          | 28 ++++---------
 3 files changed, 74 insertions(+), 50 deletions(-)

diff --git a/include/linux/sunrpc/bc_xprt.h b/include/linux/sunrpc/bc_xprt.h
index 969c0a671dbf..2ca67b55e0fe 100644
--- a/include/linux/sunrpc/bc_xprt.h
+++ b/include/linux/sunrpc/bc_xprt.h
@@ -32,7 +32,8 @@ SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 #include <linux/sunrpc/sched.h>
 
 #ifdef CONFIG_SUNRPC_BACKCHANNEL
-struct rpc_rqst *xprt_alloc_bc_request(struct rpc_xprt *xprt);
+struct rpc_rqst *xprt_lookup_bc_request(struct rpc_xprt *xprt, __be32 xid);
+void xprt_complete_bc_request(struct rpc_rqst *req, uint32_t copied);
 void xprt_free_bc_request(struct rpc_rqst *req);
 int xprt_setup_backchannel(struct rpc_xprt *, unsigned int min_reqs);
 void xprt_destroy_backchannel(struct rpc_xprt *, unsigned int max_reqs);
diff --git a/net/sunrpc/backchannel_rqst.c b/net/sunrpc/backchannel_rqst.c
index e860d4f7ed2a..3513d559bc45 100644
--- a/net/sunrpc/backchannel_rqst.c
+++ b/net/sunrpc/backchannel_rqst.c
@@ -212,39 +212,23 @@ out:
 }
 EXPORT_SYMBOL_GPL(xprt_destroy_backchannel);
 
-/*
- * One or more rpc_rqst structure have been preallocated during the
- * backchannel setup.  Buffer space for the send and private XDR buffers
- * has been preallocated as well.  Use xprt_alloc_bc_request to allocate
- * to this request.  Use xprt_free_bc_request to return it.
- *
- * We know that we're called in soft interrupt context, grab the spin_lock
- * since there is no need to grab the bottom half spin_lock.
- *
- * Return an available rpc_rqst, otherwise NULL if non are available.
- */
-struct rpc_rqst *xprt_alloc_bc_request(struct rpc_xprt *xprt)
+static struct rpc_rqst *xprt_alloc_bc_request(struct rpc_xprt *xprt, __be32 xid)
 {
-	struct rpc_rqst *req;
+	struct rpc_rqst *req = NULL;
 
 	dprintk("RPC:       allocate a backchannel request\n");
-	spin_lock(&xprt->bc_pa_lock);
-	if (!list_empty(&xprt->bc_pa_list)) {
-		req = list_first_entry(&xprt->bc_pa_list, struct rpc_rqst,
-				rq_bc_pa_list);
-		list_del(&req->rq_bc_pa_list);
-	} else {
-		req = NULL;
-	}
-	spin_unlock(&xprt->bc_pa_lock);
+	if (list_empty(&xprt->bc_pa_list))
+		goto not_found;
 
-	if (req != NULL) {
-		set_bit(RPC_BC_PA_IN_USE, &req->rq_bc_pa_state);
-		req->rq_reply_bytes_recvd = 0;
-		req->rq_bytes_sent = 0;
-		memcpy(&req->rq_private_buf, &req->rq_rcv_buf,
+	req = list_first_entry(&xprt->bc_pa_list, struct rpc_rqst,
+				rq_bc_pa_list);
+	req->rq_reply_bytes_recvd = 0;
+	req->rq_bytes_sent = 0;
+	memcpy(&req->rq_private_buf, &req->rq_rcv_buf,
 			sizeof(req->rq_private_buf));
-	}
+	req->rq_xid = xid;
+	req->rq_connect_cookie = xprt->connect_cookie;
+not_found:
 	dprintk("RPC:       backchannel req=%p\n", req);
 	return req;
 }
@@ -259,6 +243,7 @@ void xprt_free_bc_request(struct rpc_rqst *req)
 
 	dprintk("RPC:       free backchannel req=%p\n", req);
 
+	req->rq_connect_cookie = xprt->connect_cookie - 1;
 	smp_mb__before_clear_bit();
 	WARN_ON_ONCE(!test_bit(RPC_BC_PA_IN_USE, &req->rq_bc_pa_state));
 	clear_bit(RPC_BC_PA_IN_USE, &req->rq_bc_pa_state);
@@ -281,7 +266,57 @@ void xprt_free_bc_request(struct rpc_rqst *req)
 	 * may be reused by a new callback request.
 	 */
 	spin_lock_bh(&xprt->bc_pa_lock);
-	list_add(&req->rq_bc_pa_list, &xprt->bc_pa_list);
+	list_add_tail(&req->rq_bc_pa_list, &xprt->bc_pa_list);
 	spin_unlock_bh(&xprt->bc_pa_lock);
 }
 
+/*
+ * One or more rpc_rqst structure have been preallocated during the
+ * backchannel setup.  Buffer space for the send and private XDR buffers
+ * has been preallocated as well.  Use xprt_alloc_bc_request to allocate
+ * to this request.  Use xprt_free_bc_request to return it.
+ *
+ * We know that we're called in soft interrupt context, grab the spin_lock
+ * since there is no need to grab the bottom half spin_lock.
+ *
+ * Return an available rpc_rqst, otherwise NULL if non are available.
+ */
+struct rpc_rqst *xprt_lookup_bc_request(struct rpc_xprt *xprt, __be32 xid)
+{
+	struct rpc_rqst *req;
+
+	spin_lock(&xprt->bc_pa_lock);
+	list_for_each_entry(req, &xprt->bc_pa_list, rq_bc_pa_list) {
+		if (req->rq_connect_cookie != xprt->connect_cookie)
+			continue;
+		if (req->rq_xid == xid)
+			goto found;
+	}
+	req = xprt_alloc_bc_request(xprt, xid);
+found:
+	spin_unlock(&xprt->bc_pa_lock);
+	return req;
+}
+
+/*
+ * Add callback request to callback list.  The callback
+ * service sleeps on the sv_cb_waitq waiting for new
+ * requests.  Wake it up after adding enqueing the
+ * request.
+ */
+void xprt_complete_bc_request(struct rpc_rqst *req, uint32_t copied)
+{
+	struct rpc_xprt *xprt = req->rq_xprt;
+	struct svc_serv *bc_serv = xprt->bc_serv;
+
+	req->rq_private_buf.len = copied;
+	set_bit(RPC_BC_PA_IN_USE, &req->rq_bc_pa_state);
+
+	dprintk("RPC:       add callback request to list\n");
+	spin_lock(&bc_serv->sv_cb_lock);
+	list_del(&req->rq_bc_pa_list);
+	list_add(&req->rq_bc_list, &bc_serv->sv_cb_list);
+	wake_up(&bc_serv->sv_cb_waitq);
+	spin_unlock(&bc_serv->sv_cb_lock);
+}
+
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 0addefca8e77..966763d735e9 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1306,41 +1306,29 @@ static inline int xs_tcp_read_reply(struct rpc_xprt *xprt,
  * If we're unable to obtain the rpc_rqst we schedule the closing of the
  * connection and return -1.
  */
-static inline int xs_tcp_read_callback(struct rpc_xprt *xprt,
+static int xs_tcp_read_callback(struct rpc_xprt *xprt,
 				       struct xdr_skb_reader *desc)
 {
 	struct sock_xprt *transport =
 				container_of(xprt, struct sock_xprt, xprt);
 	struct rpc_rqst *req;
 
-	req = xprt_alloc_bc_request(xprt);
+	/* Look up and lock the request corresponding to the given XID */
+	spin_lock(&xprt->transport_lock);
+	req = xprt_lookup_bc_request(xprt, transport->tcp_xid);
 	if (req == NULL) {
+		spin_unlock(&xprt->transport_lock);
 		printk(KERN_WARNING "Callback slot table overflowed\n");
 		xprt_force_disconnect(xprt);
 		return -1;
 	}
 
-	req->rq_xid = transport->tcp_xid;
 	dprintk("RPC:       read callback  XID %08x\n", ntohl(req->rq_xid));
 	xs_tcp_read_common(xprt, desc, req);
 
-	if (!(transport->tcp_flags & TCP_RCV_COPY_DATA)) {
-		struct svc_serv *bc_serv = xprt->bc_serv;
-
-		/*
-		 * Add callback request to callback list.  The callback
-		 * service sleeps on the sv_cb_waitq waiting for new
-		 * requests.  Wake it up after adding enqueing the
-		 * request.
-		 */
-		dprintk("RPC:       add callback request to list\n");
-		spin_lock(&bc_serv->sv_cb_lock);
-		list_add(&req->rq_bc_list, &bc_serv->sv_cb_list);
-		spin_unlock(&bc_serv->sv_cb_lock);
-		wake_up(&bc_serv->sv_cb_waitq);
-	}
-
-	req->rq_private_buf.len = transport->tcp_copied;
+	if (!(transport->tcp_flags & TCP_RCV_COPY_DATA))
+		xprt_complete_bc_request(req, transport->tcp_copied);
+	spin_unlock(&xprt->transport_lock);
 
 	return 0;
 }
-- 
1.8.5.3

