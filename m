Return-Path: <SRS0=26It=SA=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DA601C43381
	for <linux-nfs@archiver.kernel.org>; Fri, 29 Mar 2019 22:02:04 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 8D4202184D
	for <linux-nfs@archiver.kernel.org>; Fri, 29 Mar 2019 22:02:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Tyc0Ad7X"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730310AbfC2WCD (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 29 Mar 2019 18:02:03 -0400
Received: from mail-it1-f195.google.com ([209.85.166.195]:54502 "EHLO
        mail-it1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1730137AbfC2WCD (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Mar 2019 18:02:03 -0400
Received: by mail-it1-f195.google.com with SMTP id w18so6170902itj.4
        for <linux-nfs@vger.kernel.org>; Fri, 29 Mar 2019 15:02:02 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=X3N9vSctSCOsc6UFU8CFGbwzU55WZ2D+xcCfeHNx9kg=;
        b=Tyc0Ad7XitehBRcIRpOXbM/C0EpTfWiNNju9H3hcMQJ0Y2xwOTuMbbRwZ3pXQrn4co
         eE6FRKkESTYPK+YjCc5NcWwdkZ4oLtbWapEhtN13pR1xyX0CLDjOjNohxBxNC29jNnU5
         i3tV1nlgEIgs5G+4YLLncOjm5HFtlnxF014vzAMKWadU3/xw585J7dQfqjXtRwVkd3eU
         j21igiK20EQcPuBb6WZIgCQq8y6anVZ8c6M171ltijn+mn0W9zg183Gu44Bx+dtqj3Nk
         WqPp9loYlKc0qxHIophJIdxcElfu8pLZ5eKR3GXf2cZwZOdK5g3jQVaHt5N+jFYqGmnv
         cpZQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=X3N9vSctSCOsc6UFU8CFGbwzU55WZ2D+xcCfeHNx9kg=;
        b=G5rX8E6DaGA3BzMwZjs8RKt8jCIqBq7cM8MndE/8RlBz/k6Xa9NUxe/bqcXFeUM8q7
         6YeWezd7y2zPrXl9GlGB6pqzkgpGQAAH/6Yxe0cCe+tgca1xAKRwvX5/Wif6BOkseWNe
         F7EYxgP5F+KuZ68+nhUwEEZ8zKo0suYWcJh0PmGZe0L2UuyhgMt784DbsJ5C4KVKVcqt
         iIU9UdFhNzvzRjYscSqhER7IAdv6Pt2SqcPsTUsNXYf76Wpoh7XO1X1qXWCtayiPePy9
         J3v5Nj99MCfr120rBpEv1GfOGQKwDdFj+jEVB/vySiC6V8r5se/sZshD+GnUQu89osw1
         ShPg==
X-Gm-Message-State: APjAAAXFmTWxRfWbLgU4Wrus1/eRQ93G85uxJvODiteDGYeFkHaZOyrp
        HbLdw4H1tdbevYIm4kZyGdBB6zk=
X-Google-Smtp-Source: APXvYqziWtzb0I5h7xcAGX3g98yPkeOw3fT60oqvFwMZ0vNpGXZyeiiWzW6mIYK1SZpZ1i34fmz+ug==
X-Received: by 2002:a24:7557:: with SMTP id y84mr6206588itc.9.1553896921423;
        Fri, 29 Mar 2019 15:02:01 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id v20sm1376796ioh.17.2019.03.29.15.02.00
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 29 Mar 2019 15:02:00 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH v2 06/28] SUNRPC: Add function rpc_sleep_on_timeout()
Date:   Fri, 29 Mar 2019 17:59:26 -0400
Message-Id: <20190329215948.107328-7-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190329215948.107328-6-trond.myklebust@hammerspace.com>
References: <20190329215948.107328-1-trond.myklebust@hammerspace.com>
 <20190329215948.107328-2-trond.myklebust@hammerspace.com>
 <20190329215948.107328-3-trond.myklebust@hammerspace.com>
 <20190329215948.107328-4-trond.myklebust@hammerspace.com>
 <20190329215948.107328-5-trond.myklebust@hammerspace.com>
 <20190329215948.107328-6-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Clean up the RPC task sleep interfaces by replacing the task->tk_timeout
'hidden parameter' to rpc_sleep_on() with a new function that takes an
absolute timeout.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/nfs4proc.c              | 18 ++++++---
 include/linux/sunrpc/sched.h   |  9 ++++-
 net/sunrpc/auth_gss/auth_gss.c |  5 +--
 net/sunrpc/clnt.c              |  1 -
 net/sunrpc/rpcb_clnt.c         |  3 +-
 net/sunrpc/sched.c             | 69 +++++++++++++++++++++++++++-------
 net/sunrpc/xprt.c              | 36 ++++++++++--------
 7 files changed, 101 insertions(+), 40 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 222eccd8a715..96b988689f0e 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -978,10 +978,8 @@ int nfs4_setup_sequence(struct nfs_client *client,
 	if (res->sr_slot != NULL)
 		goto out_start;
 
-	if (session) {
+	if (session)
 		tbl = &session->fc_slot_table;
-		task->tk_timeout = 0;
-	}
 
 	spin_lock(&tbl->slot_tbl_lock);
 	/* The state manager will wait until the slot table is empty */
@@ -990,9 +988,8 @@ int nfs4_setup_sequence(struct nfs_client *client,
 
 	slot = nfs4_alloc_slot(tbl);
 	if (IS_ERR(slot)) {
-		/* Try again in 1/4 second */
 		if (slot == ERR_PTR(-ENOMEM))
-			task->tk_timeout = HZ >> 2;
+			goto out_sleep_timeout;
 		goto out_sleep;
 	}
 	spin_unlock(&tbl->slot_tbl_lock);
@@ -1004,7 +1001,16 @@ int nfs4_setup_sequence(struct nfs_client *client,
 	nfs41_sequence_res_init(res);
 	rpc_call_start(task);
 	return 0;
-
+out_sleep_timeout:
+	/* Try again in 1/4 second */
+	if (args->sa_privileged)
+		rpc_sleep_on_priority_timeout(&tbl->slot_tbl_waitq, task,
+				jiffies + (HZ >> 2), RPC_PRIORITY_PRIVILEGED);
+	else
+		rpc_sleep_on_timeout(&tbl->slot_tbl_waitq, task,
+				NULL, jiffies + (HZ >> 2));
+	spin_unlock(&tbl->slot_tbl_lock);
+	return -EAGAIN;
 out_sleep:
 	if (args->sa_privileged)
 		rpc_sleep_on_priority(&tbl->slot_tbl_waitq, task,
diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index 541b89d41afb..81f5d93f7109 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -35,7 +35,6 @@ struct rpc_wait {
 	struct list_head	list;		/* wait queue links */
 	struct list_head	links;		/* Links to related tasks */
 	struct list_head	timer_list;	/* Timer list */
-	unsigned long		expires;
 };
 
 /*
@@ -227,8 +226,16 @@ void		rpc_execute(struct rpc_task *);
 void		rpc_init_priority_wait_queue(struct rpc_wait_queue *, const char *);
 void		rpc_init_wait_queue(struct rpc_wait_queue *, const char *);
 void		rpc_destroy_wait_queue(struct rpc_wait_queue *);
+void		rpc_sleep_on_timeout(struct rpc_wait_queue *queue,
+					struct rpc_task *task,
+					rpc_action action,
+					unsigned long timeout);
 void		rpc_sleep_on(struct rpc_wait_queue *, struct rpc_task *,
 					rpc_action action);
+void		rpc_sleep_on_priority_timeout(struct rpc_wait_queue *queue,
+					struct rpc_task *task,
+					unsigned long timeout,
+					int priority);
 void		rpc_sleep_on_priority(struct rpc_wait_queue *,
 					struct rpc_task *,
 					int priority);
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 3fd56c0c90ae..c055edfec55e 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -581,8 +581,8 @@ gss_refresh_upcall(struct rpc_task *task)
 		/* XXX: warning on the first, under the assumption we
 		 * shouldn't normally hit this case on a refresh. */
 		warn_gssd();
-		task->tk_timeout = 15*HZ;
-		rpc_sleep_on(&pipe_version_rpc_waitqueue, task, NULL);
+		rpc_sleep_on_timeout(&pipe_version_rpc_waitqueue,
+				task, NULL, jiffies + (15 * HZ));
 		err = -EAGAIN;
 		goto out;
 	}
@@ -595,7 +595,6 @@ gss_refresh_upcall(struct rpc_task *task)
 	if (gss_cred->gc_upcall != NULL)
 		rpc_sleep_on(&gss_cred->gc_upcall->rpc_waitqueue, task, NULL);
 	else if (gss_msg->ctx == NULL && gss_msg->msg.errno >= 0) {
-		task->tk_timeout = 0;
 		gss_cred->gc_upcall = gss_msg;
 		/* gss_upcall_callback will release the reference to gss_upcall_msg */
 		refcount_inc(&gss_msg->count);
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 88b4685e7977..4d853b5420c8 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1869,7 +1869,6 @@ call_bind(struct rpc_task *task)
 	if (!xprt_prepare_transmit(task))
 		return;
 
-	task->tk_timeout = xprt->bind_timeout;
 	xprt->ops->rpcbind(task);
 }
 
diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 41a971ac1c63..18b0cf2a923f 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -694,7 +694,8 @@ void rpcb_getport_async(struct rpc_task *task)
 
 	/* Put self on the wait queue to ensure we get notified if
 	 * some other task is already attempting to bind the port */
-	rpc_sleep_on(&xprt->binding, task, NULL);
+	rpc_sleep_on_timeout(&xprt->binding, task,
+			NULL, jiffies + xprt->bind_timeout);
 
 	if (xprt_test_and_set_binding(xprt)) {
 		dprintk("RPC: %5u %s: waiting for another binder\n",
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index 04170c08b2cf..7e0f7b83262f 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -66,7 +66,7 @@ struct workqueue_struct *xprtiod_workqueue __read_mostly;
 static void
 __rpc_disable_timer(struct rpc_wait_queue *queue, struct rpc_task *task)
 {
-	if (task->tk_timeout == 0)
+	if (list_empty(&task->u.tk_wait.timer_list))
 		return;
 	dprintk("RPC: %5u disabling timer\n", task->tk_pid);
 	task->tk_timeout = 0;
@@ -86,17 +86,15 @@ rpc_set_queue_timer(struct rpc_wait_queue *queue, unsigned long expires)
  * Set up a timer for the current task.
  */
 static void
-__rpc_add_timer(struct rpc_wait_queue *queue, struct rpc_task *task)
+__rpc_add_timer(struct rpc_wait_queue *queue, struct rpc_task *task,
+		unsigned long timeout)
 {
-	if (!task->tk_timeout)
-		return;
-
 	dprintk("RPC: %5u setting alarm for %u ms\n",
-		task->tk_pid, jiffies_to_msecs(task->tk_timeout));
+		task->tk_pid, jiffies_to_msecs(timeout - jiffies));
 
-	task->u.tk_wait.expires = jiffies + task->tk_timeout;
-	if (list_empty(&queue->timer_list.list) || time_before(task->u.tk_wait.expires, queue->timer_list.expires))
-		rpc_set_queue_timer(queue, task->u.tk_wait.expires);
+	task->tk_timeout = timeout;
+	if (list_empty(&queue->timer_list.list) || time_before(timeout, queue->timer_list.expires))
+		rpc_set_queue_timer(queue, timeout);
 	list_add(&task->u.tk_wait.timer_list, &queue->timer_list.list);
 }
 
@@ -188,6 +186,7 @@ static void __rpc_add_wait_queue(struct rpc_wait_queue *queue,
 	if (RPC_IS_QUEUED(task))
 		return;
 
+	INIT_LIST_HEAD(&task->u.tk_wait.timer_list);
 	if (RPC_IS_PRIORITY(queue))
 		__rpc_add_wait_queue_priority(queue, task, queue_priority);
 	else if (RPC_IS_SWAPPER(task))
@@ -371,7 +370,17 @@ static void __rpc_sleep_on_priority(struct rpc_wait_queue *q,
 
 	__rpc_add_wait_queue(q, task, queue_priority);
 
-	__rpc_add_timer(q, task);
+}
+
+static void __rpc_sleep_on_priority_timeout(struct rpc_wait_queue *q,
+		struct rpc_task *task, unsigned long timeout,
+		unsigned char queue_priority)
+{
+	if (time_is_after_jiffies(timeout)) {
+		__rpc_sleep_on_priority(q, task, queue_priority);
+		__rpc_add_timer(q, task, timeout);
+	} else
+		task->tk_status = -ETIMEDOUT;
 }
 
 static void rpc_set_tk_callback(struct rpc_task *task, rpc_action action)
@@ -391,6 +400,23 @@ static bool rpc_sleep_check_activated(struct rpc_task *task)
 	return true;
 }
 
+void rpc_sleep_on_timeout(struct rpc_wait_queue *q, struct rpc_task *task,
+				rpc_action action, unsigned long timeout)
+{
+	if (!rpc_sleep_check_activated(task))
+		return;
+
+	rpc_set_tk_callback(task, action);
+
+	/*
+	 * Protect the queue operations.
+	 */
+	spin_lock_bh(&q->lock);
+	__rpc_sleep_on_priority_timeout(q, task, timeout, task->tk_priority);
+	spin_unlock_bh(&q->lock);
+}
+EXPORT_SYMBOL_GPL(rpc_sleep_on_timeout);
+
 void rpc_sleep_on(struct rpc_wait_queue *q, struct rpc_task *task,
 				rpc_action action)
 {
@@ -399,6 +425,7 @@ void rpc_sleep_on(struct rpc_wait_queue *q, struct rpc_task *task,
 
 	rpc_set_tk_callback(task, action);
 
+	WARN_ON_ONCE(task->tk_timeout != 0);
 	/*
 	 * Protect the queue operations.
 	 */
@@ -408,12 +435,29 @@ void rpc_sleep_on(struct rpc_wait_queue *q, struct rpc_task *task,
 }
 EXPORT_SYMBOL_GPL(rpc_sleep_on);
 
+void rpc_sleep_on_priority_timeout(struct rpc_wait_queue *q,
+		struct rpc_task *task, unsigned long timeout, int priority)
+{
+	if (!rpc_sleep_check_activated(task))
+		return;
+
+	priority -= RPC_PRIORITY_LOW;
+	/*
+	 * Protect the queue operations.
+	 */
+	spin_lock_bh(&q->lock);
+	__rpc_sleep_on_priority_timeout(q, task, timeout, priority);
+	spin_unlock_bh(&q->lock);
+}
+EXPORT_SYMBOL_GPL(rpc_sleep_on_priority_timeout);
+
 void rpc_sleep_on_priority(struct rpc_wait_queue *q, struct rpc_task *task,
 		int priority)
 {
 	if (!rpc_sleep_check_activated(task))
 		return;
 
+	WARN_ON_ONCE(task->tk_timeout != 0);
 	priority -= RPC_PRIORITY_LOW;
 	/*
 	 * Protect the queue operations.
@@ -711,7 +755,7 @@ static void __rpc_queue_timer_fn(struct timer_list *t)
 	spin_lock(&queue->lock);
 	expires = now = jiffies;
 	list_for_each_entry_safe(task, n, &queue->timer_list.list, u.tk_wait.timer_list) {
-		timeo = task->u.tk_wait.expires;
+		timeo = task->tk_timeout;
 		if (time_after_eq(now, timeo)) {
 			dprintk("RPC: %5u timeout\n", task->tk_pid);
 			task->tk_status = -ETIMEDOUT;
@@ -737,8 +781,7 @@ static void __rpc_atrun(struct rpc_task *task)
  */
 void rpc_delay(struct rpc_task *task, unsigned long delay)
 {
-	task->tk_timeout = delay;
-	rpc_sleep_on(&delay_queue, task, __rpc_atrun);
+	rpc_sleep_on_timeout(&delay_queue, task, __rpc_atrun, jiffies + delay);
 }
 EXPORT_SYMBOL_GPL(rpc_delay);
 
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 5afffa669d04..7c3623b17493 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -209,9 +209,12 @@ int xprt_reserve_xprt(struct rpc_xprt *xprt, struct rpc_task *task)
 out_sleep:
 	dprintk("RPC: %5u failed to lock transport %p\n",
 			task->tk_pid, xprt);
-	task->tk_timeout = RPC_IS_SOFT(task) ? req->rq_timeout : 0;
 	task->tk_status = -EAGAIN;
-	rpc_sleep_on(&xprt->sending, task, NULL);
+	if  (RPC_IS_SOFT(task))
+		rpc_sleep_on_timeout(&xprt->sending, task, NULL,
+				jiffies + req->rq_timeout);
+	else
+		rpc_sleep_on(&xprt->sending, task, NULL);
 	return 0;
 }
 EXPORT_SYMBOL_GPL(xprt_reserve_xprt);
@@ -273,9 +276,12 @@ int xprt_reserve_xprt_cong(struct rpc_xprt *xprt, struct rpc_task *task)
 	xprt_clear_locked(xprt);
 out_sleep:
 	dprintk("RPC: %5u failed to lock transport %p\n", task->tk_pid, xprt);
-	task->tk_timeout = RPC_IS_SOFT(task) ? req->rq_timeout : 0;
 	task->tk_status = -EAGAIN;
-	rpc_sleep_on(&xprt->sending, task, NULL);
+	if (RPC_IS_SOFT(task))
+		rpc_sleep_on_timeout(&xprt->sending, task, NULL,
+				jiffies + req->rq_timeout);
+	else
+		rpc_sleep_on(&xprt->sending, task, NULL);
 	return 0;
 }
 EXPORT_SYMBOL_GPL(xprt_reserve_xprt_cong);
@@ -787,9 +793,9 @@ void xprt_connect(struct rpc_task *task)
 		xprt->ops->close(xprt);
 
 	if (!xprt_connected(xprt)) {
-		task->tk_timeout = task->tk_rqstp->rq_timeout;
 		task->tk_rqstp->rq_connect_cookie = xprt->connect_cookie;
-		rpc_sleep_on(&xprt->pending, task, NULL);
+		rpc_sleep_on_timeout(&xprt->pending, task, NULL,
+				jiffies + task->tk_rqstp->rq_timeout);
 
 		if (test_bit(XPRT_CLOSING, &xprt->state))
 			return;
@@ -1080,8 +1086,8 @@ void xprt_wait_for_reply_request_def(struct rpc_task *task)
 {
 	struct rpc_rqst *req = task->tk_rqstp;
 
-	task->tk_timeout = req->rq_timeout;
-	rpc_sleep_on(&req->rq_xprt->pending, task, xprt_timer);
+	rpc_sleep_on_timeout(&req->rq_xprt->pending, task, xprt_timer,
+			jiffies + req->rq_timeout);
 }
 EXPORT_SYMBOL_GPL(xprt_wait_for_reply_request_def);
 
@@ -1099,12 +1105,14 @@ void xprt_wait_for_reply_request_rtt(struct rpc_task *task)
 	struct rpc_rtt *rtt = clnt->cl_rtt;
 	struct rpc_rqst *req = task->tk_rqstp;
 	unsigned long max_timeout = clnt->cl_timeout->to_maxval;
+	unsigned long timeout;
 
-	task->tk_timeout = rpc_calc_rto(rtt, timer);
-	task->tk_timeout <<= rpc_ntimeo(rtt, timer) + req->rq_retries;
-	if (task->tk_timeout > max_timeout || task->tk_timeout == 0)
-		task->tk_timeout = max_timeout;
-	rpc_sleep_on(&req->rq_xprt->pending, task, xprt_timer);
+	timeout = rpc_calc_rto(rtt, timer);
+	timeout <<= rpc_ntimeo(rtt, timer) + req->rq_retries;
+	if (timeout > max_timeout || timeout == 0)
+		timeout = max_timeout;
+	rpc_sleep_on_timeout(&req->rq_xprt->pending, task, xprt_timer,
+			jiffies + timeout);
 }
 EXPORT_SYMBOL_GPL(xprt_wait_for_reply_request_rtt);
 
@@ -1656,7 +1664,6 @@ void xprt_reserve(struct rpc_task *task)
 	if (task->tk_rqstp != NULL)
 		return;
 
-	task->tk_timeout = 0;
 	task->tk_status = -EAGAIN;
 	if (!xprt_throttle_congested(xprt, task))
 		xprt_do_reserve(xprt, task);
@@ -1679,7 +1686,6 @@ void xprt_retry_reserve(struct rpc_task *task)
 	if (task->tk_rqstp != NULL)
 		return;
 
-	task->tk_timeout = 0;
 	task->tk_status = -EAGAIN;
 	xprt_do_reserve(xprt, task);
 }
-- 
2.20.1

