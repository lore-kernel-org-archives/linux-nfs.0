Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:42906 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726314AbeICTuo (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Sep 2018 15:50:44 -0400
Received: by mail-io0-f193.google.com with SMTP id n18-v6so676836ioa.9
        for <linux-nfs@vger.kernel.org>; Mon, 03 Sep 2018 08:30:04 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-40-195-73.hsd1.mi.comcast.net. [68.40.195.73])
        by smtp.gmail.com with ESMTPSA id c25-v6sm7040027iob.30.2018.09.03.08.30.03
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 03 Sep 2018 08:30:03 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 05/27] SUNRPC: Avoid holding locks across the XDR encoding of the RPC message
Date: Mon,  3 Sep 2018 11:29:14 -0400
Message-Id: <20180903152936.24325-6-trond.myklebust@hammerspace.com>
In-Reply-To: <20180903152936.24325-5-trond.myklebust@hammerspace.com>
References: <20180903152936.24325-1-trond.myklebust@hammerspace.com>
 <20180903152936.24325-2-trond.myklebust@hammerspace.com>
 <20180903152936.24325-3-trond.myklebust@hammerspace.com>
 <20180903152936.24325-4-trond.myklebust@hammerspace.com>
 <20180903152936.24325-5-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, we grab the socket bit lock before we allow the message
to be XDR encoded. That significantly slows down the transmission
rate, since we serialise on a potentially blocking operation.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/clnt.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index e5ac35e803ad..66ec61347716 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1949,9 +1949,6 @@ call_transmit(struct rpc_task *task)
 	task->tk_action = call_status;
 	if (task->tk_status < 0)
 		return;
-	if (!xprt_prepare_transmit(task))
-		return;
-	task->tk_action = call_transmit_status;
 	/* Encode here so that rpcsec_gss can use correct sequence number. */
 	if (rpc_task_need_encode(task)) {
 		rpc_xdr_encode(task);
@@ -1965,8 +1962,11 @@ call_transmit(struct rpc_task *task)
 			return;
 		}
 	}
+	if (!xprt_prepare_transmit(task))
+		return;
+	task->tk_action = call_transmit_status;
 	xprt_transmit(task);
-	if (task->tk_status < 0)
+	if (task->tk_status < 0) {
 		return;
 	if (is_retrans)
 		task->tk_client->cl_stats->rpcretrans++;
-- 
2.17.1
