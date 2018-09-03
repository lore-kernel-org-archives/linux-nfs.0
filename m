Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:37527 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727405AbeICTuy (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Sep 2018 15:50:54 -0400
Received: by mail-it0-f66.google.com with SMTP id h20-v6so1469897itf.2
        for <linux-nfs@vger.kernel.org>; Mon, 03 Sep 2018 08:30:15 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-40-195-73.hsd1.mi.comcast.net. [68.40.195.73])
        by smtp.gmail.com with ESMTPSA id c25-v6sm7040027iob.30.2018.09.03.08.30.13
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 03 Sep 2018 08:30:13 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 16/27] SUNRPC: Minor cleanup for call_transmit()
Date: Mon,  3 Sep 2018 11:29:25 -0400
Message-Id: <20180903152936.24325-17-trond.myklebust@hammerspace.com>
In-Reply-To: <20180903152936.24325-16-trond.myklebust@hammerspace.com>
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
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/clnt.c | 33 +++++++++++++++------------------
 1 file changed, 15 insertions(+), 18 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index cf09aab11014..5fbd9875544e 100644
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
@@ -1969,9 +1967,8 @@ call_transmit(struct rpc_task *task)
 
 	if (!xprt_prepare_transmit(task))
 		return;
-	task->tk_action = call_transmit_status;
 	xprt_transmit(task);
-	if (task->tk_status < 0) {
+	if (task->tk_status < 0)
 		return;
 	if (is_retrans)
 		task->tk_client->cl_stats->rpcretrans++;
@@ -1996,19 +1993,28 @@ call_transmit_status(struct rpc_task *task)
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
@@ -2163,22 +2169,13 @@ call_status(struct rpc_task *task)
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
