Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f42.google.com ([209.85.214.42]:37638 "EHLO
        mail-it0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726749AbeIEBdT (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Sep 2018 21:33:19 -0400
Received: by mail-it0-f42.google.com with SMTP id h20-v6so6706051itf.2
        for <linux-nfs@vger.kernel.org>; Tue, 04 Sep 2018 14:06:28 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-40-195-73.hsd1.mi.comcast.net. [68.40.195.73])
        by smtp.gmail.com with ESMTPSA id t64-v6sm172860ita.13.2018.09.04.14.06.26
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 04 Sep 2018 14:06:26 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 22/34] SUNRPC: Simplify xprt_prepare_transmit()
Date: Tue,  4 Sep 2018 17:05:37 -0400
Message-Id: <20180904210549.81673-23-trond.myklebust@hammerspace.com>
In-Reply-To: <20180904210549.81673-22-trond.myklebust@hammerspace.com>
References: <20180904210549.81673-1-trond.myklebust@hammerspace.com>
 <20180904210549.81673-2-trond.myklebust@hammerspace.com>
 <20180904210549.81673-3-trond.myklebust@hammerspace.com>
 <20180904210549.81673-4-trond.myklebust@hammerspace.com>
 <20180904210549.81673-5-trond.myklebust@hammerspace.com>
 <20180904210549.81673-6-trond.myklebust@hammerspace.com>
 <20180904210549.81673-7-trond.myklebust@hammerspace.com>
 <20180904210549.81673-8-trond.myklebust@hammerspace.com>
 <20180904210549.81673-9-trond.myklebust@hammerspace.com>
 <20180904210549.81673-10-trond.myklebust@hammerspace.com>
 <20180904210549.81673-11-trond.myklebust@hammerspace.com>
 <20180904210549.81673-12-trond.myklebust@hammerspace.com>
 <20180904210549.81673-13-trond.myklebust@hammerspace.com>
 <20180904210549.81673-14-trond.myklebust@hammerspace.com>
 <20180904210549.81673-15-trond.myklebust@hammerspace.com>
 <20180904210549.81673-16-trond.myklebust@hammerspace.com>
 <20180904210549.81673-17-trond.myklebust@hammerspace.com>
 <20180904210549.81673-18-trond.myklebust@hammerspace.com>
 <20180904210549.81673-19-trond.myklebust@hammerspace.com>
 <20180904210549.81673-20-trond.myklebust@hammerspace.com>
 <20180904210549.81673-21-trond.myklebust@hammerspace.com>
 <20180904210549.81673-22-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Remove the checks for whether or not we need to transmit, and whether
or not a reply has been received. Those are already handled in
call_transmit() itself.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/xprt.c | 21 +++------------------
 1 file changed, 3 insertions(+), 18 deletions(-)

diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 305aa9570873..f1301d391399 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -1102,27 +1102,12 @@ bool xprt_prepare_transmit(struct rpc_task *task)
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
-		if (!test_bit(RPC_TASK_NEED_XMIT, &task->tk_runstate))
-			goto out_unlock;
-	}
-	if (!xprt->ops->reserve_xprt(xprt, task)) {
-		task->tk_status = -EAGAIN;
-		goto out_unlock;
-	}
-	ret = true;
-out_unlock:
-	spin_unlock_bh(&xprt->transport_lock);
-	return ret;
+	if (!xprt_lock_write(xprt, task))
+		return false;
+	return true;
 }
 
 void xprt_end_transmit(struct rpc_task *task)
-- 
2.17.1
