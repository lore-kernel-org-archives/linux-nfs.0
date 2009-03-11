From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 9/9] SUNRPC: xprt_connect() don't abort the task if the
 transport isn't bound
Date: Wed, 11 Mar 2009 14:25:26 -0400
Message-ID: <20090311182526.403.37137.stgit@heimdal.trondhjem.org>
References: <20090311182525.403.42026.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:52465 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755257AbZCKS3x (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Mar 2009 14:29:53 -0400
Received: from sacrsexc2-prd.hq.netapp.com (sacrsexc2-prd.hq.netapp.com [10.99.115.28])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id n2BIThF4008166
	for <linux-nfs@vger.kernel.org>; Wed, 11 Mar 2009 11:29:51 -0700 (PDT)
In-Reply-To: <20090311182525.403.42026.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the transport isn't bound, then we should just return ENOTCONN, letting
call_connect_status() and/or call_status() deal with retrying. Currently,
we appear to abort all pending tasks with an EIO error.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 net/sunrpc/xprt.c     |    2 +-
 net/sunrpc/xprtsock.c |   13 +++++++++----
 2 files changed, 10 insertions(+), 5 deletions(-)


diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 29e401b..62098d1 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -663,7 +663,7 @@ void xprt_connect(struct rpc_task *task)
 			xprt, (xprt_connected(xprt) ? "is" : "is not"));
 
 	if (!xprt_bound(xprt)) {
-		task->tk_status = -EIO;
+		task->tk_status = -EAGAIN;
 		return;
 	}
 	if (!xprt_lock_write(xprt, task))
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index a71fefd..29c71e6 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -577,6 +577,8 @@ static int xs_udp_send_request(struct rpc_task *task)
 				req->rq_svec->iov_base,
 				req->rq_svec->iov_len);
 
+	if (!xprt_bound(xprt))
+		return -ENOTCONN;
 	status = xs_sendpages(transport->sock,
 			      xs_addr(xprt),
 			      xprt->addrlen, xdr,
@@ -1531,7 +1533,7 @@ static void xs_udp_connect_worker4(struct work_struct *work)
 	struct socket *sock = transport->sock;
 	int err, status = -EIO;
 
-	if (xprt->shutdown || !xprt_bound(xprt))
+	if (xprt->shutdown)
 		goto out;
 
 	/* Start by resetting any existing state */
@@ -1572,7 +1574,7 @@ static void xs_udp_connect_worker6(struct work_struct *work)
 	struct socket *sock = transport->sock;
 	int err, status = -EIO;
 
-	if (xprt->shutdown || !xprt_bound(xprt))
+	if (xprt->shutdown)
 		goto out;
 
 	/* Start by resetting any existing state */
@@ -1656,6 +1658,9 @@ static int xs_tcp_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)
 		write_unlock_bh(&sk->sk_callback_lock);
 	}
 
+	if (!xprt_bound(xprt))
+		return -ENOTCONN;
+
 	/* Tell the socket layer to start connecting... */
 	xprt->stat.connect_count++;
 	xprt->stat.connect_start = jiffies;
@@ -1676,7 +1681,7 @@ static void xs_tcp_connect_worker4(struct work_struct *work)
 	struct socket *sock = transport->sock;
 	int err, status = -EIO;
 
-	if (xprt->shutdown || !xprt_bound(xprt))
+	if (xprt->shutdown)
 		goto out;
 
 	if (!sock) {
@@ -1736,7 +1741,7 @@ static void xs_tcp_connect_worker6(struct work_struct *work)
 	struct socket *sock = transport->sock;
 	int err, status = -EIO;
 
-	if (xprt->shutdown || !xprt_bound(xprt))
+	if (xprt->shutdown)
 		goto out;
 
 	if (!sock) {

