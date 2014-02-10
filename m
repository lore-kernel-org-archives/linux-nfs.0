Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f174.google.com ([209.85.223.174]:49225 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752932AbaBJRqp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Feb 2014 12:46:45 -0500
Received: by mail-ie0-f174.google.com with SMTP id tp5so3728258ieb.19
        for <linux-nfs@vger.kernel.org>; Mon, 10 Feb 2014 09:46:45 -0800 (PST)
Message-ID: <1392054402.16327.9.camel@leira.trondhjem.org>
Subject: Re: [PATCH v2] SUNRPC: Allow one callback request to be received
 from two sk_buff
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: shaobingqing <shaobingqing@bwstor.com.cn>
Cc: bfields@redhat.com, davem@davemloft.net, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Mon, 10 Feb 2014 12:46:42 -0500
In-Reply-To: <1391826543-3102-1-git-send-email-shaobingqing@bwstor.com.cn>
References: <no>
	 <1391826543-3102-1-git-send-email-shaobingqing@bwstor.com.cn>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 2014-02-08 at 10:29 +0800, shaobingqing wrote:
> In current code, there only one struct rpc_rqst is prealloced. If one
> callback request is received from two sk_buff, the xprt_alloc_bc_request
> would be execute two times with the same transport->xid. The first time
> xprt_alloc_bc_request will alloc one struct rpc_rqst and the TCP_RCV_COPY_DATA
> bit of transport->tcp_flags will not be cleared. The second time
> xprt_alloc_bc_request could not alloc struct rpc_rqst any more and NULL
> pointer will be returned, then xprt_force_disconnect occur. I think one
> callback request can be allowed to be received from two sk_buff.
> 
> Signed-off-by: shaobingqing <shaobingqing@bwstor.com.cn>
> ---

There are still several problems with this patch.
For one thing, xprt->req_first is never cleared, which means that the
tests you add in xs_tcp_read_callback() could trigger even if the
request is in use by the callback server.
Furthermore, if the xprt is destroyed before the RPC callback has been
filled, then the request is leaked: it is no longer on the xprt
backchannel list, so nothing will clean it up there, and nothing ever
checks xprt->req_first, so it won't get cleaned up there either.

Instead of adding a new tracking mechanism, what say we just keep the
request on the xprt callback list until it has been completely filled.

IOW: something like the following patch:

8<-------------------------------------------------------------------
>From 2aa57b6c6c6025e17d7ca164bbda01767af662be Mon Sep 17 00:00:00 2001
From: Trond Myklebust <trond.myklebust@primarydata.com>
Date: Mon, 10 Feb 2014 11:18:39 -0500
Subject: [PATCH] SUNRPC: RPC callbacks may be split across several TCP
 segments

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
 include/linux/sunrpc/bc_xprt.h |  3 +-
 net/sunrpc/backchannel_rqst.c  | 92 +++++++++++++++++++++++++++++-------------
 net/sunrpc/xprtsock.c          | 28 ++++---------
 3 files changed, 73 insertions(+), 50 deletions(-)

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
index 890a29912d5a..7cceeb06b939 100644
--- a/net/sunrpc/backchannel_rqst.c
+++ b/net/sunrpc/backchannel_rqst.c
@@ -210,39 +210,23 @@ out:
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
@@ -257,6 +241,7 @@ void xprt_free_bc_request(struct rpc_rqst *req)
 
 	dprintk("RPC:       free backchannel req=%p\n", req);
 
+	req->rq_connect_cookie = xprt->connect_cookie - 1;
 	smp_mb__before_clear_bit();
 	WARN_ON_ONCE(!test_bit(RPC_BC_PA_IN_USE, &req->rq_bc_pa_state));
 	clear_bit(RPC_BC_PA_IN_USE, &req->rq_bc_pa_state);
@@ -279,7 +264,56 @@ void xprt_free_bc_request(struct rpc_rqst *req)
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
+	list_move(&req->rq_bc_list, &bc_serv->sv_cb_list);
+	wake_up(&bc_serv->sv_cb_waitq);
+	spin_unlock(&bc_serv->sv_cb_lock);
+}
+
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 817a1e523969..6497c221612c 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1302,41 +1302,29 @@ static inline int xs_tcp_read_reply(struct rpc_xprt *xprt,
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


-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com


