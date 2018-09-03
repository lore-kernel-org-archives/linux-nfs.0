Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:37326 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727434AbeICTvC (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Sep 2018 15:51:02 -0400
Received: by mail-io0-f196.google.com with SMTP id v14-v6so696199iob.4
        for <linux-nfs@vger.kernel.org>; Mon, 03 Sep 2018 08:30:22 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-40-195-73.hsd1.mi.comcast.net. [68.40.195.73])
        by smtp.gmail.com with ESMTPSA id c25-v6sm7040027iob.30.2018.09.03.08.30.21
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 03 Sep 2018 08:30:21 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 24/27] SUNRPC: Fix up the back channel transmit
Date: Mon,  3 Sep 2018 11:29:33 -0400
Message-Id: <20180903152936.24325-25-trond.myklebust@hammerspace.com>
In-Reply-To: <20180903152936.24325-24-trond.myklebust@hammerspace.com>
References: <20180903152936.24325-1-trond.myklebust@hammerspace.com>
 <20180903152936.24325-2-trond.myklebust@hammerspace.com>
 <20180903152936.24325-3-trond.myklebust@hammerspace.com>
 <20180903152936.24325-4-trond.myklebust@hammerspace.com>
 <20180903152936.24325-5-trond.myklebust@hammerspace.com>
 <20180903152936.24325-6-trond.myklebust@hammerspace.com>
 <20180903152936.24325-7-trond.myklebust@hammerspace.com>
 <20180903152936.24325-8-trond.myklebust@hammerspace.com>
 <20180903152936.24325-9-trond.myklebust@hammerspace.com>
 <20180903152936.24325-10-trond.myklebust@hammerspace.com>
 <20180903152936.24325-11-trond.myklebust@hammerspace.com>
 <20180903152936.24325-12-trond.myklebust@hammerspace.com>
 <20180903152936.24325-13-trond.myklebust@hammerspace.com>
 <20180903152936.24325-14-trond.myklebust@hammerspace.com>
 <20180903152936.24325-15-trond.myklebust@hammerspace.com>
 <20180903152936.24325-16-trond.myklebust@hammerspace.com>
 <20180903152936.24325-17-trond.myklebust@hammerspace.com>
 <20180903152936.24325-18-trond.myklebust@hammerspace.com>
 <20180903152936.24325-19-trond.myklebust@hammerspace.com>
 <20180903152936.24325-20-trond.myklebust@hammerspace.com>
 <20180903152936.24325-21-trond.myklebust@hammerspace.com>
 <20180903152936.24325-22-trond.myklebust@hammerspace.com>
 <20180903152936.24325-23-trond.myklebust@hammerspace.com>
 <20180903152936.24325-24-trond.myklebust@hammerspace.com>
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
index fb40d1e9f636..586976c4c02a 100644
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
