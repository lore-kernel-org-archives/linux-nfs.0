Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk1-f196.google.com ([209.85.222.196]:40181 "EHLO
        mail-qk1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728229AbeIQSbd (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Sep 2018 14:31:33 -0400
Received: by mail-qk1-f196.google.com with SMTP id c126-v6so8903753qkd.7
        for <linux-nfs@vger.kernel.org>; Mon, 17 Sep 2018 06:04:18 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain ([66.187.232.65])
        by smtp.gmail.com with ESMTPSA id q1-v6sm10499607qkl.31.2018.09.17.06.04.16
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 17 Sep 2018 06:04:16 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 17/44] SUNRPC: Minor cleanup for call_transmit()
Date: Mon, 17 Sep 2018 09:03:08 -0400
Message-Id: <20180917130335.112832-18-trond.myklebust@hammerspace.com>
In-Reply-To: <20180917130335.112832-17-trond.myklebust@hammerspace.com>
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
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/clnt.c | 32 +++++++++++++++-----------------
 1 file changed, 15 insertions(+), 17 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 775d6e80b6e8..be0f06a8156b 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1946,9 +1946,7 @@ call_transmit(struct rpc_task *task)
 
 	dprint_status(task);
 
-	task->tk_action = call_status;
-	if (task->tk_status < 0)
-		return;
+	task->tk_action = call_transmit_status;
 	/* Encode here so that rpcsec_gss can use correct sequence number. */
 	if (rpc_task_need_encode(task)) {
 		rpc_xdr_encode(task);
@@ -1969,7 +1967,6 @@ call_transmit(struct rpc_task *task)
 
 	if (!xprt_prepare_transmit(task))
 		return;
-	task->tk_action = call_transmit_status;
 	xprt_transmit(task);
 	if (task->tk_status < 0)
 		return;
@@ -1996,19 +1993,29 @@ call_transmit_status(struct rpc_task *task)
 	}
 
 	switch (task->tk_status) {
-	case -EAGAIN:
-	case -ENOBUFS:
-		break;
 	default:
 		dprint_status(task);
 		xprt_end_transmit(task);
 		break;
+	case -EBADMSG:
+		clear_bit(RPC_TASK_NEED_XMIT, &task->tk_runstate);
+		task->tk_action = call_transmit;
+		task->tk_status = 0;
+		xprt_end_transmit(task);
+		break;
 		/*
 		 * Special cases: if we've been waiting on the
 		 * socket's write_space() callback, or if the
 		 * socket just returned a connection error,
 		 * then hold onto the transport lock.
 		 */
+	case -ENOBUFS:
+		rpc_delay(task, HZ>>2);
+		/* fall through */
+	case -EAGAIN:
+		task->tk_action = call_transmit;
+		task->tk_status = 0;
+		break;
 	case -ECONNREFUSED:
 	case -EHOSTDOWN:
 	case -ENETDOWN:
@@ -2163,22 +2170,13 @@ call_status(struct rpc_task *task)
 		/* fall through */
 	case -EPIPE:
 	case -ENOTCONN:
-		task->tk_action = call_bind;
-		break;
-	case -ENOBUFS:
-		rpc_delay(task, HZ>>2);
-		/* fall through */
 	case -EAGAIN:
-		task->tk_action = call_transmit;
+		task->tk_action = call_bind;
 		break;
 	case -EIO:
 		/* shutdown or soft timeout */
 		rpc_exit(task, status);
 		break;
-	case -EBADMSG:
-		clear_bit(RPC_TASK_NEED_XMIT, &task->tk_runstate);
-		task->tk_action = call_transmit;
-		break;
 	default:
 		if (clnt->cl_chatty)
 			printk("%s: RPC call returned error %d\n",
-- 
2.17.1
