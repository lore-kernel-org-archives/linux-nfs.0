Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:53266 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726749AbeIEBdV (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Sep 2018 21:33:21 -0400
Received: by mail-it0-f67.google.com with SMTP id p79-v6so7028928itp.3
        for <linux-nfs@vger.kernel.org>; Tue, 04 Sep 2018 14:06:30 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-40-195-73.hsd1.mi.comcast.net. [68.40.195.73])
        by smtp.gmail.com with ESMTPSA id t64-v6sm172860ita.13.2018.09.04.14.06.28
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 04 Sep 2018 14:06:28 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 24/34] SUNRPC: Fix up the back channel transmit
Date: Tue,  4 Sep 2018 17:05:39 -0400
Message-Id: <20180904210549.81673-25-trond.myklebust@hammerspace.com>
In-Reply-To: <20180904210549.81673-24-trond.myklebust@hammerspace.com>
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
 <20180904210549.81673-23-trond.myklebust@hammerspace.com>
 <20180904210549.81673-24-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fix up the back channel code to recognise that it has already been
transmitted, so does not need to be called again.
Also ensure that we set req->rq_task.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/clnt.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 21713bed812a..00384bde593e 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1150,6 +1150,7 @@ struct rpc_task *rpc_run_bc_task(struct rpc_rqst *req)
 	 */
 	task = rpc_new_task(&task_setup_data);
 	task->tk_rqstp = req;
+	req->rq_task = task;
 
 	/*
 	 * Set up the xdr_buf length.
@@ -2054,6 +2055,9 @@ call_bc_transmit(struct rpc_task *task)
 	struct rpc_rqst *req = task->tk_rqstp;
 
 	xprt_request_enqueue_transmit(task);
+	if (!test_bit(RPC_TASK_NEED_XMIT, &task->tk_runstate))
+		goto out_wakeup;
+
 	if (!xprt_prepare_transmit(task))
 		goto out_retry;
 
@@ -2108,6 +2112,7 @@ call_bc_transmit(struct rpc_task *task)
 			"error: %d\n", task->tk_status);
 		break;
 	}
+out_wakeup:
 	rpc_wake_up_queued_task(&req->rq_xprt->pending, task);
 out_done:
 	task->tk_action = rpc_exit_task;
-- 
2.17.1
