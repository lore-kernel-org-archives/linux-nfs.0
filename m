From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 22/39] nfs41: Get the rpc_xprt * from the rpc_rqst instead of the rpc_clnt.
Date: Fri,  1 May 2009 02:22:49 +0300
Message-ID: <1241133769-1021-1-git-send-email-bhalevy@panasas.com>
References: <49FA3180.5030404@panasas.com>
Cc: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>, pnfs@linux-nfs.org,
	linux-nfs@vger.kernel.org, Rahul Iyer <iyer@netapp.com>,
	Ricardo Labiaga <ricardo.labiaga@netapp.com>,
	Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:2371 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754778AbZD3XW5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Apr 2009 19:22:57 -0400
In-Reply-To: <49FA3180.5030404@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Rahul Iyer <iyer@netapp.com>

Obtain the rpc_xprt from the rpc_rqst so that calls and callback replies
can both use the same code path.  A client needs the rpc_xprt in order
to reply to a callback.

Signed-off-by: Rahul Iyer <iyer@netapp.com>
Signed-off-by: Ricardo Labiaga <ricardo.labiaga@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 net/sunrpc/xprt.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index df65d15..c73b31f 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -195,8 +195,8 @@ EXPORT_SYMBOL_GPL(xprt_load_transport);
  */
 int xprt_reserve_xprt(struct rpc_task *task)
 {
-	struct rpc_xprt	*xprt = task->tk_xprt;
 	struct rpc_rqst *req = task->tk_rqstp;
+	struct rpc_xprt	*xprt = req->rq_xprt;
 
 	if (test_and_set_bit(XPRT_LOCKED, &xprt->state)) {
 		if (task == xprt->snd_task)
@@ -860,7 +860,7 @@ out_unlock:
 
 void xprt_end_transmit(struct rpc_task *task)
 {
-	xprt_release_write(task->tk_xprt, task);
+	xprt_release_write(task->tk_rqstp->rq_xprt, task);
 }
 
 /**
-- 
1.6.2.1

