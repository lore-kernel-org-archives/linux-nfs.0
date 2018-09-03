Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:32860 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727430AbeICTu6 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Sep 2018 15:50:58 -0400
Received: by mail-io0-f196.google.com with SMTP id r196-v6so711794iod.0
        for <linux-nfs@vger.kernel.org>; Mon, 03 Sep 2018 08:30:18 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-40-195-73.hsd1.mi.comcast.net. [68.40.195.73])
        by smtp.gmail.com with ESMTPSA id c25-v6sm7040027iob.30.2018.09.03.08.30.16
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 03 Sep 2018 08:30:16 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 19/27] SUNRPC: Refactor RPC call encoding
Date: Mon,  3 Sep 2018 11:29:28 -0400
Message-Id: <20180903152936.24325-20-trond.myklebust@hammerspace.com>
In-Reply-To: <20180903152936.24325-19-trond.myklebust@hammerspace.com>
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
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Move the call encoding so that it occurs before the transport connection
etc.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/clnt.c | 67 +++++++++++++++++++++++++++--------------------
 1 file changed, 39 insertions(+), 28 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index a817f70d6192..497a30762a6d 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -61,6 +61,7 @@ static void	call_start(struct rpc_task *task);
 static void	call_reserve(struct rpc_task *task);
 static void	call_reserveresult(struct rpc_task *task);
 static void	call_allocate(struct rpc_task *task);
+static void	call_encode(struct rpc_task *task);
 static void	call_decode(struct rpc_task *task);
 static void	call_bind(struct rpc_task *task);
 static void	call_bind_status(struct rpc_task *task);
@@ -1680,7 +1681,7 @@ call_allocate(struct rpc_task *task)
 	dprint_status(task);
 
 	task->tk_status = 0;
-	task->tk_action = call_bind;
+	task->tk_action = call_encode;
 
 	if (req->rq_buffer)
 		return;
@@ -1727,9 +1728,6 @@ rpc_task_need_encode(struct rpc_task *task)
 	return test_bit(RPC_TASK_NEED_XMIT, &task->tk_runstate) == 0;
 }
 
-/*
- * 3.	Encode arguments of an RPC call
- */
 static void
 rpc_xdr_encode(struct rpc_task *task)
 {
@@ -1745,6 +1743,7 @@ rpc_xdr_encode(struct rpc_task *task)
 	xdr_buf_init(&req->rq_rcv_buf,
 		     req->rq_rbuffer,
 		     req->rq_rcvsize);
+	req->rq_bytes_sent = 0;
 
 	p = rpc_encode_header(task);
 	if (p == NULL) {
@@ -1761,6 +1760,34 @@ rpc_xdr_encode(struct rpc_task *task)
 			task->tk_msg.rpc_argp);
 }
 
+/*
+ * 3.	Encode arguments of an RPC call
+ */
+static void
+call_encode(struct rpc_task *task)
+{
+	if (!rpc_task_need_encode(task))
+		goto out;
+	/* Encode here so that rpcsec_gss can use correct sequence number. */
+	rpc_xdr_encode(task);
+	/* Did the encode result in an error condition? */
+	if (task->tk_status != 0) {
+		/* Was the error nonfatal? */
+		if (task->tk_status == -EAGAIN)
+			rpc_delay(task, HZ >> 4);
+		else
+			rpc_exit(task, task->tk_status);
+		return;
+	}
+
+	/* Add task to reply queue before transmission to avoid races */
+	if (rpc_reply_expected(task))
+		xprt_request_enqueue_receive(task);
+	set_bit(RPC_TASK_NEED_XMIT, &task->tk_runstate);
+out:
+	task->tk_action = call_bind;
+}
+
 /*
  * 4.	Get the server port number if not yet set
  */
@@ -1945,25 +1972,9 @@ call_transmit(struct rpc_task *task)
 	dprint_status(task);
 
 	task->tk_action = call_transmit_status;
-	/* Encode here so that rpcsec_gss can use correct sequence number. */
-	if (rpc_task_need_encode(task)) {
-		rpc_xdr_encode(task);
-		/* Did the encode result in an error condition? */
-		if (task->tk_status != 0) {
-			/* Was the error nonfatal? */
-			if (task->tk_status == -EAGAIN)
-				rpc_delay(task, HZ >> 4);
-			else
-				rpc_exit(task, task->tk_status);
-			return;
-		}
-		set_bit(RPC_TASK_NEED_XMIT, &task->tk_runstate);
-	}
-
-	/* Add task to reply queue before transmission to avoid races */
-	if (rpc_reply_expected(task))
-		xprt_request_enqueue_receive(task);
 	xprt_request_enqueue_transmit(task);
+	if (!test_bit(RPC_TASK_NEED_XMIT, &task->tk_runstate))
+		return;
 
 	if (!xprt_prepare_transmit(task))
 		return;
@@ -1998,8 +2009,8 @@ call_transmit_status(struct rpc_task *task)
 		xprt_end_transmit(task);
 		break;
 	case -EBADMSG:
-		task->tk_action = call_transmit;
 		xprt_end_transmit(task);
+		task->tk_action = call_encode;
 		break;
 		/*
 		 * Special cases: if we've been waiting on the
@@ -2170,7 +2181,7 @@ call_status(struct rpc_task *task)
 	case -EPIPE:
 	case -ENOTCONN:
 	case -EAGAIN:
-		task->tk_action = call_bind;
+		task->tk_action = call_encode;
 		break;
 	case -EIO:
 		/* shutdown or soft timeout */
@@ -2235,7 +2246,7 @@ call_timeout(struct rpc_task *task)
 	rpcauth_invalcred(task);
 
 retry:
-	task->tk_action = call_bind;
+	task->tk_action = call_encode;
 	task->tk_status = 0;
 }
 
@@ -2279,7 +2290,7 @@ call_decode(struct rpc_task *task)
 
 	if (req->rq_rcv_buf.len < 12) {
 		if (!RPC_IS_SOFT(task)) {
-			task->tk_action = call_bind;
+			task->tk_action = call_encode;
 			goto out_retry;
 		}
 		dprintk("RPC:       %s: too small RPC reply size (%d bytes)\n",
@@ -2410,7 +2421,7 @@ rpc_verify_header(struct rpc_task *task)
 			task->tk_garb_retry--;
 			dprintk("RPC: %5u %s: retry garbled creds\n",
 					task->tk_pid, __func__);
-			task->tk_action = call_bind;
+			task->tk_action = call_encode;
 			goto out_retry;
 		case RPC_AUTH_TOOWEAK:
 			printk(KERN_NOTICE "RPC: server %s requires stronger "
@@ -2479,7 +2490,7 @@ rpc_verify_header(struct rpc_task *task)
 		task->tk_garb_retry--;
 		dprintk("RPC: %5u %s: retrying\n",
 				task->tk_pid, __func__);
-		task->tk_action = call_bind;
+		task->tk_action = call_encode;
 out_retry:
 		return ERR_PTR(-EAGAIN);
 	}
-- 
2.17.1
