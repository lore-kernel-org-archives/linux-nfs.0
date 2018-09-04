Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:50337 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726749AbeIEBdY (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Sep 2018 21:33:24 -0400
Received: by mail-it0-f66.google.com with SMTP id j81-v6so7043024ite.0
        for <linux-nfs@vger.kernel.org>; Tue, 04 Sep 2018 14:06:32 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-40-195-73.hsd1.mi.comcast.net. [68.40.195.73])
        by smtp.gmail.com with ESMTPSA id t64-v6sm172860ita.13.2018.09.04.14.06.31
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 04 Sep 2018 14:06:31 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 28/34] SUNRPC: Queue the request for transmission immediately after encoding
Date: Tue,  4 Sep 2018 17:05:43 -0400
Message-Id: <20180904210549.81673-29-trond.myklebust@hammerspace.com>
In-Reply-To: <20180904210549.81673-28-trond.myklebust@hammerspace.com>
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
 <20180904210549.81673-25-trond.myklebust@hammerspace.com>
 <20180904210549.81673-26-trond.myklebust@hammerspace.com>
 <20180904210549.81673-27-trond.myklebust@hammerspace.com>
 <20180904210549.81673-28-trond.myklebust@hammerspace.com>
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
index 52494baca7bc..4f8803413499 100644
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
