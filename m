Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:35436 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752374AbbFDV05 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Jun 2015 17:26:57 -0400
Received: by igbzc4 with SMTP id zc4so1249279igb.0
        for <linux-nfs@vger.kernel.org>; Thu, 04 Jun 2015 14:26:57 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/6] SUNRPC: Backchannel handle socket nospace
Date: Thu,  4 Jun 2015 17:26:49 -0400
Message-Id: <1433453213-13466-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1433453213-13466-1-git-send-email-trond.myklebust@primarydata.com>
References: <1433453213-13466-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the socket was busy due to a socket nospace error, then we should
retry the send.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 net/sunrpc/clnt.c | 27 ++++++++++++++++-----------
 1 file changed, 16 insertions(+), 11 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index e6ce1517367f..fa70f663eb92 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1951,24 +1951,22 @@ call_bc_transmit(struct rpc_task *task)
 {
 	struct rpc_rqst *req = task->tk_rqstp;
 
-	if (!xprt_prepare_transmit(task)) {
-		/*
-		 * Could not reserve the transport. Try again after the
-		 * transport is released.
-		 */
-		task->tk_status = 0;
-		task->tk_action = call_bc_transmit;
-		return;
-	}
+	if (!xprt_prepare_transmit(task))
+		goto out_retry;
 
-	task->tk_action = rpc_exit_task;
 	if (task->tk_status < 0) {
 		printk(KERN_NOTICE "RPC: Could not send backchannel reply "
 			"error: %d\n", task->tk_status);
-		return;
+		goto out_done;
 	}
+	if (req->rq_connect_cookie != req->rq_xprt->connect_cookie)
+		req->rq_bytes_sent = 0;
 
 	xprt_transmit(task);
+
+	if (task->tk_status == -EAGAIN)
+		goto out_nospace;
+
 	xprt_end_transmit(task);
 	dprint_status(task);
 	switch (task->tk_status) {
@@ -2002,6 +2000,13 @@ call_bc_transmit(struct rpc_task *task)
 		break;
 	}
 	rpc_wake_up_queued_task(&req->rq_xprt->pending, task);
+out_done:
+	task->tk_action = rpc_exit_task;
+	return;
+out_nospace:
+	req->rq_connect_cookie = req->rq_xprt->connect_cookie;
+out_retry:
+	task->tk_status = 0;
 }
 #endif /* CONFIG_SUNRPC_BACKCHANNEL */
 
-- 
2.4.2

