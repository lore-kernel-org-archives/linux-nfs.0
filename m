Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx.bwstor.com.cn ([211.103.180.228]:32825 "EHLO mx.bwstor.cn"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751004AbaBHCeT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 7 Feb 2014 21:34:19 -0500
From: shaobingqing <shaobingqing@bwstor.com.cn>
To: trond.myklebust@primarydata.com, bfields@redhat.com, davem@davemloft.net
Cc: linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        shaobingqing <shaobingqing@bwstor.com.cn>
Subject: [PATCH v2] SUNRPC: Allow one callback request to be received from two sk_buff
Date: Sat,  8 Feb 2014 10:29:03 +0800
Message-Id: <1391826543-3102-1-git-send-email-shaobingqing@bwstor.com.cn>
In-Reply-To: <no>
References: <no>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In current code, there only one struct rpc_rqst is prealloced. If one
callback request is received from two sk_buff, the xprt_alloc_bc_request
would be execute two times with the same transport->xid. The first time
xprt_alloc_bc_request will alloc one struct rpc_rqst and the TCP_RCV_COPY_DATA
bit of transport->tcp_flags will not be cleared. The second time
xprt_alloc_bc_request could not alloc struct rpc_rqst any more and NULL
pointer will be returned, then xprt_force_disconnect occur. I think one
callback request can be allowed to be received from two sk_buff.

Signed-off-by: shaobingqing <shaobingqing@bwstor.com.cn>
---
 include/linux/sunrpc/xprt.h |    1 +
 net/sunrpc/xprt.c           |    1 +
 net/sunrpc/xprtsock.c       |   13 ++++++++++++-
 3 files changed, 14 insertions(+), 1 deletions(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index cec7b9b..82bfe01 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -211,6 +211,7 @@ struct rpc_xprt {
 						 * items */
 	struct list_head	bc_pa_list;	/* List of preallocated
 						 * backchannel rpc_rqst's */
+	struct rpc_rqst	*req_first;
 #endif /* CONFIG_SUNRPC_BACKCHANNEL */
 	struct list_head	recv;
 
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 095363e..93ad8bc 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -1256,6 +1256,7 @@ static void xprt_init(struct rpc_xprt *xprt, struct net *net)
 #if defined(CONFIG_SUNRPC_BACKCHANNEL)
 	spin_lock_init(&xprt->bc_pa_lock);
 	INIT_LIST_HEAD(&xprt->bc_pa_list);
+	xprt->req_first = NULL;
 #endif /* CONFIG_SUNRPC_BACKCHANNEL */
 
 	xprt->last_used = jiffies;
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index ee03d35..c43dca4 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1272,7 +1272,16 @@ static inline int xs_tcp_read_callback(struct rpc_xprt *xprt,
 				container_of(xprt, struct sock_xprt, xprt);
 	struct rpc_rqst *req;
 
-	req = xprt_alloc_bc_request(xprt);
+	if (xprt->req_first != NULL &&
+			xprt->req_first->rq_xid == transport->tcp_xid) {
+		req = xprt->req_first;
+	} else if (xprt->req_first != NULL &&
+			xprt->req_first->rq_xid != transport->tcp_xid) {
+		xprt_free_bc_request(xprt);
+		req = xprt_alloc_bc_request(xprt);
+	} else {
+		req = xprt_alloc_bc_request(xprt);
+	}
 	if (req == NULL) {
 		printk(KERN_WARNING "Callback slot table overflowed\n");
 		xprt_force_disconnect(xprt);
@@ -1297,6 +1306,8 @@ static inline int xs_tcp_read_callback(struct rpc_xprt *xprt,
 		list_add(&req->rq_bc_list, &bc_serv->sv_cb_list);
 		spin_unlock(&bc_serv->sv_cb_lock);
 		wake_up(&bc_serv->sv_cb_waitq);
+	} else {
+		xprt->req_first = req;
 	}
 
 	req->rq_private_buf.len = transport->tcp_copied;
-- 
1.7.4.2

