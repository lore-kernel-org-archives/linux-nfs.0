Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:42912 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726314AbeICTut (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Sep 2018 15:50:49 -0400
Received: by mail-io0-f196.google.com with SMTP id n18-v6so677003ioa.9
        for <linux-nfs@vger.kernel.org>; Mon, 03 Sep 2018 08:30:09 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-40-195-73.hsd1.mi.comcast.net. [68.40.195.73])
        by smtp.gmail.com with ESMTPSA id c25-v6sm7040027iob.30.2018.09.03.08.30.07
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 03 Sep 2018 08:30:07 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 10/27] SUNRPC: Refactor the transport request pinning
Date: Mon,  3 Sep 2018 11:29:19 -0400
Message-Id: <20180903152936.24325-11-trond.myklebust@hammerspace.com>
In-Reply-To: <20180903152936.24325-10-trond.myklebust@hammerspace.com>
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
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We are going to need to pin for both send and receive.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 include/linux/sunrpc/sched.h |  2 --
 include/linux/sunrpc/xprt.h  |  1 +
 net/sunrpc/xprt.c            | 37 +++++++++++++++++-------------------
 3 files changed, 18 insertions(+), 22 deletions(-)

diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index 9e655df70131..a4a42b3a1f03 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -142,8 +142,6 @@ struct rpc_task_setup {
 #define RPC_TASK_ACTIVE		2
 #define RPC_TASK_NEED_XMIT	3
 #define RPC_TASK_NEED_RECV	4
-#define RPC_TASK_MSG_RECV	5
-#define RPC_TASK_MSG_RECV_WAIT	6
 
 #define RPC_IS_RUNNING(t)	test_bit(RPC_TASK_RUNNING, &(t)->tk_runstate)
 #define rpc_set_running(t)	set_bit(RPC_TASK_RUNNING, &(t)->tk_runstate)
diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 3d80524e92d6..bd743c51a865 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -103,6 +103,7 @@ struct rpc_rqst {
 						/* A cookie used to track the
 						   state of the transport
 						   connection */
+	atomic_t		rq_pin;
 	
 	/*
 	 * Partial send handling
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 45d580cd93ac..bf8fc1a5dbd1 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -847,16 +847,22 @@ struct rpc_rqst *xprt_lookup_rqst(struct rpc_xprt *xprt, __be32 xid)
 }
 EXPORT_SYMBOL_GPL(xprt_lookup_rqst);
 
+static bool
+xprt_is_pinned_rqst(struct rpc_rqst *req)
+{
+	return atomic_read(&req->rq_pin) != 0;
+}
+
 /**
  * xprt_pin_rqst - Pin a request on the transport receive list
  * @req: Request to pin
  *
  * Caller must ensure this is atomic with the call to xprt_lookup_rqst()
- * so should be holding the xprt transport lock.
+ * so should be holding the xprt receive lock.
  */
 void xprt_pin_rqst(struct rpc_rqst *req)
 {
-	set_bit(RPC_TASK_MSG_RECV, &req->rq_task->tk_runstate);
+	atomic_inc(&req->rq_pin);
 }
 EXPORT_SYMBOL_GPL(xprt_pin_rqst);
 
@@ -864,31 +870,18 @@ EXPORT_SYMBOL_GPL(xprt_pin_rqst);
  * xprt_unpin_rqst - Unpin a request on the transport receive list
  * @req: Request to pin
  *
- * Caller should be holding the xprt transport lock.
+ * Caller should be holding the xprt receive lock.
  */
 void xprt_unpin_rqst(struct rpc_rqst *req)
 {
-	struct rpc_task *task = req->rq_task;
-
-	clear_bit(RPC_TASK_MSG_RECV, &task->tk_runstate);
-	if (test_bit(RPC_TASK_MSG_RECV_WAIT, &task->tk_runstate))
-		wake_up_bit(&task->tk_runstate, RPC_TASK_MSG_RECV);
+	if (atomic_dec_and_test(&req->rq_pin))
+		wake_up_var(&req->rq_pin);
 }
 EXPORT_SYMBOL_GPL(xprt_unpin_rqst);
 
 static void xprt_wait_on_pinned_rqst(struct rpc_rqst *req)
-__must_hold(&req->rq_xprt->recv_lock)
 {
-	struct rpc_task *task = req->rq_task;
-
-	if (task && test_bit(RPC_TASK_MSG_RECV, &task->tk_runstate)) {
-		spin_unlock(&req->rq_xprt->recv_lock);
-		set_bit(RPC_TASK_MSG_RECV_WAIT, &task->tk_runstate);
-		wait_on_bit(&task->tk_runstate, RPC_TASK_MSG_RECV,
-				TASK_UNINTERRUPTIBLE);
-		clear_bit(RPC_TASK_MSG_RECV_WAIT, &task->tk_runstate);
-		spin_lock(&req->rq_xprt->recv_lock);
-	}
+	wait_var_event(&req->rq_pin, !xprt_is_pinned_rqst(req));
 }
 
 /**
@@ -1388,7 +1381,11 @@ void xprt_release(struct rpc_task *task)
 	spin_lock(&xprt->recv_lock);
 	if (!list_empty(&req->rq_list)) {
 		list_del_init(&req->rq_list);
-		xprt_wait_on_pinned_rqst(req);
+		if (atomic_read(&req->rq_pin)) {
+			spin_unlock(&xprt->recv_lock);
+			xprt_wait_on_pinned_rqst(req);
+			spin_lock(&xprt->recv_lock);
+		}
 	}
 	spin_unlock(&xprt->recv_lock);
 	spin_lock_bh(&xprt->transport_lock);
-- 
2.17.1
