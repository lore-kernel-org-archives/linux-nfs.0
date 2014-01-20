Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx.nrchpc.ac.cn ([211.103.180.228]:34021 "EHLO mx.bwstor.cn"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750733AbaATHAL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Jan 2014 02:00:11 -0500
From: shaobingqing <shaobingqing@bwstor.com.cn>
To: trond.myklebust@primarydata.com, bfields@redhat.com, davem@davemloft.net
Cc: linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        shaobingqing <shaobingqing@bwstor.com.cn>
Subject: [PATCH] SUNRPC: Allow one callback request to be received from two sk_buff
Date: Mon, 20 Jan 2014 14:59:14 +0800
Message-Id: <1390201154-20815-1-git-send-email-shaobingqing@bwstor.com.cn>
In-Reply-To: <n>
References: <n>
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
 net/sunrpc/xprtsock.c |   11 +++++++++--
 1 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index ee03d35..606950d 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1271,8 +1271,13 @@ static inline int xs_tcp_read_callback(struct rpc_xprt *xprt,
 	struct sock_xprt *transport =
 				container_of(xprt, struct sock_xprt, xprt);
 	struct rpc_rqst *req;
+	static struct rpc_rqst *req_partial;
+
+	if (req_partial == NULL)
+		req = xprt_alloc_bc_request(xprt);
+	else if (req_partial->rq_xid == transport->tcp_xid)
+		req = req_partial;
 
-	req = xprt_alloc_bc_request(xprt);
 	if (req == NULL) {
 		printk(KERN_WARNING "Callback slot table overflowed\n");
 		xprt_force_disconnect(xprt);
@@ -1285,6 +1290,7 @@ static inline int xs_tcp_read_callback(struct rpc_xprt *xprt,
 
 	if (!(transport->tcp_flags & TCP_RCV_COPY_DATA)) {
 		struct svc_serv *bc_serv = xprt->bc_serv;
+		req_partial = NULL;
 
 		/*
 		 * Add callback request to callback list.  The callback
@@ -1297,7 +1303,8 @@ static inline int xs_tcp_read_callback(struct rpc_xprt *xprt,
 		list_add(&req->rq_bc_list, &bc_serv->sv_cb_list);
 		spin_unlock(&bc_serv->sv_cb_lock);
 		wake_up(&bc_serv->sv_cb_waitq);
-	}
+	} else
+		req_partial = req;
 
 	req->rq_private_buf.len = transport->tcp_copied;
 
-- 
1.7.4.2

