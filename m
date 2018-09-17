Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:46948 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726889AbeIQSbS (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Sep 2018 14:31:18 -0400
Received: by mail-qt0-f195.google.com with SMTP id l42-v6so15092774qtf.13
        for <linux-nfs@vger.kernel.org>; Mon, 17 Sep 2018 06:04:03 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain ([66.187.232.65])
        by smtp.gmail.com with ESMTPSA id q1-v6sm10499607qkl.31.2018.09.17.06.04.01
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 17 Sep 2018 06:04:01 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 05/44] SUNRPC: Avoid holding locks across the XDR encoding of the RPC message
Date: Mon, 17 Sep 2018 09:02:56 -0400
Message-Id: <20180917130335.112832-6-trond.myklebust@hammerspace.com>
In-Reply-To: <20180917130335.112832-5-trond.myklebust@hammerspace.com>
References: <20180917130335.112832-1-trond.myklebust@hammerspace.com>
 <20180917130335.112832-2-trond.myklebust@hammerspace.com>
 <20180917130335.112832-3-trond.myklebust@hammerspace.com>
 <20180917130335.112832-4-trond.myklebust@hammerspace.com>
 <20180917130335.112832-5-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, we grab the socket bit lock before we allow the message
to be XDR encoded. That significantly slows down the transmission
rate, since we serialise on a potentially blocking operation.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/clnt.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index e5ac35e803ad..a858366cd15d 100644
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
@@ -1965,6 +1962,9 @@ call_transmit(struct rpc_task *task)
 			return;
 		}
 	}
+	if (!xprt_prepare_transmit(task))
+		return;
+	task->tk_action = call_transmit_status;
 	xprt_transmit(task);
 	if (task->tk_status < 0)
 		return;
-- 
2.17.1
