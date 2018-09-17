Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:33518 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728229AbeIQSbl (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Sep 2018 14:31:41 -0400
Received: by mail-qt0-f195.google.com with SMTP id r37-v6so15164216qtc.0
        for <linux-nfs@vger.kernel.org>; Mon, 17 Sep 2018 06:04:26 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain ([66.187.232.65])
        by smtp.gmail.com with ESMTPSA id q1-v6sm10499607qkl.31.2018.09.17.06.04.24
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 17 Sep 2018 06:04:24 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 24/44] SUNRPC: Simplify xprt_prepare_transmit()
Date: Mon, 17 Sep 2018 09:03:15 -0400
Message-Id: <20180917130335.112832-25-trond.myklebust@hammerspace.com>
In-Reply-To: <20180917130335.112832-24-trond.myklebust@hammerspace.com>
References: <20180917130335.112832-1-trond.myklebust@hammerspace.com>
 <20180917130335.112832-2-trond.myklebust@hammerspace.com>
 <20180917130335.112832-3-trond.myklebust@hammerspace.com>
 <20180917130335.112832-4-trond.myklebust@hammerspace.com>
 <20180917130335.112832-5-trond.myklebust@hammerspace.com>
 <20180917130335.112832-6-trond.myklebust@hammerspace.com>
 <20180917130335.112832-7-trond.myklebust@hammerspace.com>
 <20180917130335.112832-8-trond.myklebust@hammerspace.com>
 <20180917130335.112832-9-trond.myklebust@hammerspace.com>
 <20180917130335.112832-10-trond.myklebust@hammerspace.com>
 <20180917130335.112832-11-trond.myklebust@hammerspace.com>
 <20180917130335.112832-12-trond.myklebust@hammerspace.com>
 <20180917130335.112832-13-trond.myklebust@hammerspace.com>
 <20180917130335.112832-14-trond.myklebust@hammerspace.com>
 <20180917130335.112832-15-trond.myklebust@hammerspace.com>
 <20180917130335.112832-16-trond.myklebust@hammerspace.com>
 <20180917130335.112832-17-trond.myklebust@hammerspace.com>
 <20180917130335.112832-18-trond.myklebust@hammerspace.com>
 <20180917130335.112832-19-trond.myklebust@hammerspace.com>
 <20180917130335.112832-20-trond.myklebust@hammerspace.com>
 <20180917130335.112832-21-trond.myklebust@hammerspace.com>
 <20180917130335.112832-22-trond.myklebust@hammerspace.com>
 <20180917130335.112832-23-trond.myklebust@hammerspace.com>
 <20180917130335.112832-24-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Remove the checks for whether or not we need to transmit, and whether
or not a reply has been received. Those are already handled in
call_transmit() itself.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/xprt.c | 23 +++++++----------------
 1 file changed, 7 insertions(+), 16 deletions(-)

diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 3b31830ef851..385ee9f64353 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -1122,27 +1122,18 @@ bool xprt_prepare_transmit(struct rpc_task *task)
 {
 	struct rpc_rqst	*req = task->tk_rqstp;
 	struct rpc_xprt	*xprt = req->rq_xprt;
-	bool ret = false;
 
 	dprintk("RPC: %5u xprt_prepare_transmit\n", task->tk_pid);
 
-	spin_lock_bh(&xprt->transport_lock);
-	if (!req->rq_bytes_sent) {
-		if (req->rq_reply_bytes_recvd) {
-			task->tk_status = req->rq_reply_bytes_recvd;
-			goto out_unlock;
-		}
+	if (!xprt_lock_write(xprt, task)) {
+		/* Race breaker: someone may have transmitted us */
 		if (!test_bit(RPC_TASK_NEED_XMIT, &task->tk_runstate))
-			goto out_unlock;
-	}
-	if (!xprt->ops->reserve_xprt(xprt, task)) {
-		task->tk_status = -EAGAIN;
-		goto out_unlock;
+			rpc_wake_up_queued_task_set_status(&xprt->sending,
+					task, 0);
+		return false;
+
 	}
-	ret = true;
-out_unlock:
-	spin_unlock_bh(&xprt->transport_lock);
-	return ret;
+	return true;
 }
 
 void xprt_end_transmit(struct rpc_task *task)
-- 
2.17.1
