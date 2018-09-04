Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:40915 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725879AbeIEBdP (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Sep 2018 21:33:15 -0400
Received: by mail-it0-f68.google.com with SMTP id h23-v6so6694895ita.5
        for <linux-nfs@vger.kernel.org>; Tue, 04 Sep 2018 14:06:23 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-40-195-73.hsd1.mi.comcast.net. [68.40.195.73])
        by smtp.gmail.com with ESMTPSA id t64-v6sm172860ita.13.2018.09.04.14.06.22
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 04 Sep 2018 14:06:22 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 16/34] SUNRPC: Minor cleanup for call_transmit()
Date: Tue,  4 Sep 2018 17:05:31 -0400
Message-Id: <20180904210549.81673-17-trond.myklebust@hammerspace.com>
In-Reply-To: <20180904210549.81673-16-trond.myklebust@hammerspace.com>
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
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/clnt.c | 31 ++++++++++++++-----------------
 1 file changed, 14 insertions(+), 17 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 775d6e80b6e8..5fbd9875544e 100644
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
