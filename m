Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:34485 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727458AbeICTvE (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Sep 2018 15:51:04 -0400
Received: by mail-io0-f193.google.com with SMTP id c22-v6so707482iob.1
        for <linux-nfs@vger.kernel.org>; Mon, 03 Sep 2018 08:30:24 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-40-195-73.hsd1.mi.comcast.net. [68.40.195.73])
        by smtp.gmail.com with ESMTPSA id c25-v6sm7040027iob.30.2018.09.03.08.30.23
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 03 Sep 2018 08:30:23 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 26/27] SUNRPC: Queue the request for transmission immediately after encoding
Date: Mon,  3 Sep 2018 11:29:35 -0400
Message-Id: <20180903152936.24325-27-trond.myklebust@hammerspace.com>
In-Reply-To: <20180903152936.24325-26-trond.myklebust@hammerspace.com>
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
 <20180903152936.24325-25-trond.myklebust@hammerspace.com>
 <20180903152936.24325-26-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Move up the call to xprt_request_enqueue_transmit() to call_encode()
so that the queue order reflects the order in which slots were
allocated.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/clnt.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 586976c4c02a..8eea3c4d2532 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1785,6 +1785,7 @@ call_encode(struct rpc_task *task)
 	if (rpc_reply_expected(task))
 		xprt_request_enqueue_receive(task);
 	set_bit(RPC_TASK_NEED_XMIT, &task->tk_runstate);
+	xprt_request_enqueue_transmit(task);
 out:
 	task->tk_action = call_bind;
 }
@@ -1971,7 +1972,6 @@ call_transmit(struct rpc_task *task)
 	dprint_status(task);
 
 	task->tk_action = call_transmit_status;
-	xprt_request_enqueue_transmit(task);
 	if (!test_bit(RPC_TASK_NEED_XMIT, &task->tk_runstate))
 		return;
 
-- 
2.17.1
