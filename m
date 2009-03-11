From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 26/30] SUNRPC: Ensure that xs_nospace return values are
 propagated
Date: Wed, 11 Mar 2009 14:41:10 -0400
Message-ID: <20090311184110.5578.28078.stgit@heimdal.trondhjem.org>
References: <20090311184105.5578.22131.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:54975 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754161AbZCKSpU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Mar 2009 14:45:20 -0400
Received: from sacrsexc1-prd.hq.netapp.com (sacrsexc1-prd.hq.netapp.com [10.99.115.27])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id n2BIj6i3022202
	for <linux-nfs@vger.kernel.org>; Wed, 11 Mar 2009 11:45:17 -0700 (PDT)
In-Reply-To: <20090311184105.5578.22131.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If xs_nospace() finds that the socket has disconnected, it attempts to
return ENOTCONN, however that value is then squashed by the callers.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 net/sunrpc/xprtsock.c |   11 +++++++----
 1 files changed, 7 insertions(+), 4 deletions(-)


diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 9f3e615..2e07067 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -521,11 +521,12 @@ static void xs_nospace_callback(struct rpc_task *task)
  * @task: task to put to sleep
  *
  */
-static void xs_nospace(struct rpc_task *task)
+static int xs_nospace(struct rpc_task *task)
 {
 	struct rpc_rqst *req = task->tk_rqstp;
 	struct rpc_xprt *xprt = req->rq_xprt;
 	struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);
+	int ret = 0;
 
 	dprintk("RPC: %5u xmit incomplete (%u left of %u)\n",
 			task->tk_pid, req->rq_slen - req->rq_bytes_sent,
@@ -537,6 +538,7 @@ static void xs_nospace(struct rpc_task *task)
 	/* Don't race with disconnect */
 	if (xprt_connected(xprt)) {
 		if (test_bit(SOCK_ASYNC_NOSPACE, &transport->sock->flags)) {
+			ret = -EAGAIN;
 			/*
 			 * Notify TCP that we're limited by the application
 			 * window size
@@ -548,10 +550,11 @@ static void xs_nospace(struct rpc_task *task)
 		}
 	} else {
 		clear_bit(SOCK_ASYNC_NOSPACE, &transport->sock->flags);
-		task->tk_status = -ENOTCONN;
+		ret = -ENOTCONN;
 	}
 
 	spin_unlock_bh(&xprt->transport_lock);
+	return ret;
 }
 
 /**
@@ -603,7 +606,7 @@ static int xs_udp_send_request(struct rpc_task *task)
 		/* Should we call xs_close() here? */
 		break;
 	case -EAGAIN:
-		xs_nospace(task);
+		status = xs_nospace(task);
 		break;
 	default:
 		dprintk("RPC:       sendmsg returned unrecognized error %d\n",
@@ -706,7 +709,7 @@ static int xs_tcp_send_request(struct rpc_task *task)
 		/* Should we call xs_close() here? */
 		break;
 	case -EAGAIN:
-		xs_nospace(task);
+		status = xs_nospace(task);
 		break;
 	default:
 		dprintk("RPC:       sendmsg returned unrecognized error %d\n",

