Return-Path: <SRS0=umLH=R7=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 50126C43381
	for <linux-nfs@archiver.kernel.org>; Thu, 28 Mar 2019 20:56:16 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 09C4221855
	for <linux-nfs@archiver.kernel.org>; Thu, 28 Mar 2019 20:56:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="EK6W6YiQ"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726453AbfC1U4P (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 28 Mar 2019 16:56:15 -0400
Received: from mail-it1-f169.google.com ([209.85.166.169]:37661 "EHLO
        mail-it1-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726307AbfC1U4P (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Mar 2019 16:56:15 -0400
Received: by mail-it1-f169.google.com with SMTP id u65so487068itc.2
        for <linux-nfs@vger.kernel.org>; Thu, 28 Mar 2019 13:56:14 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=X3N9vSctSCOsc6UFU8CFGbwzU55WZ2D+xcCfeHNx9kg=;
        b=EK6W6YiQPUQs0HN7YohF/Z1oL9UmwSQbCIBGCANbAF9fPNHqJn8AlPLplnJ8/XHkXJ
         yb6HPzYdE39bsIlkxJsmTxbow0zZhg6v5D00jqihwpDUKYmQ02MQttKH58W+Qjm07m//
         zBJJABOGn74IIZ1dXFzBhf59kOfrtHY/PsiGDhatkajls6eOnNI+EtK+iH2WGTRfqZ9L
         93phYmqK4vp8Wcf5Ly3+R6keEO0sUSKDvrrhgBgYF9X4wPOZH+2TWtZ+Zlm22BmfwbRn
         e4lVtcDzl82GqqZoZF75XfeAdIi7G3hfMx5TXGu7pva9kWHELBZt5RchDvaoNRrGxDoc
         8SCg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=X3N9vSctSCOsc6UFU8CFGbwzU55WZ2D+xcCfeHNx9kg=;
        b=BN5dreu8j5ux86kEmD/vl5UEVqFMSRgoJ+cRXleq/wS+L6E9Knn7eRj2V5l2mBRy4e
         2ntzzn+LDgMLr6xmqXDrpds8kE19WW5ImW4YHM1wr1ivcPHQxDIm6uWjm+OJKmIonDrl
         wn0p6OzEUL8i1Z6p2I2qmeBZqavCD5Ep9naUtJ9Nu3VTgH1lfbCgQYsuolWMW/oABHTH
         cXrS2JXWlGqPwhfs973Su1gaKjyOFCFNRorawpGMd8exOhCH+CTokvr1LCaK586b7JEa
         gRK13auGcebqAAjCqdT8FgA2/DRrFVweHQ2IF0yeb6N4uJ55p/5F0nsLTF8oZROn5NsB
         1vVw==
X-Gm-Message-State: APjAAAW/fEHP9Es9EvR24inUGBvNjWT3An8SJUCBq/mE2+2kMraUTfvF
        GBF0Y27E0O04ztjkJi9qe6zEvxU=
X-Google-Smtp-Source: APXvYqzlub3Ws4KhyEgfLRDBVsW/+6da5cIxtqLw6naVaOxvVIbO0aFInJgjGxM58SxqQ5MyVVom9g==
X-Received: by 2002:a05:660c:243:: with SMTP id t3mr1781944itk.152.1553806573464;
        Thu, 28 Mar 2019 13:56:13 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id t67sm1084750ita.35.2019.03.28.13.56.12
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 28 Mar 2019 13:56:12 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 06/25] SUNRPC: Add function rpc_sleep_on_timeout()
Date:   Thu, 28 Mar 2019 16:52:20 -0400
Message-Id: <20190328205239.29674-7-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190328205239.29674-6-trond.myklebust@hammerspace.com>
References: <20190328205239.29674-1-trond.myklebust@hammerspace.com>
 <20190328205239.29674-2-trond.myklebust@hammerspace.com>
 <20190328205239.29674-3-trond.myklebust@hammerspace.com>
 <20190328205239.29674-4-trond.myklebust@hammerspace.com>
 <20190328205239.29674-5-trond.myklebust@hammerspace.com>
 <20190328205239.29674-6-trond.myklebust@hammerspace.com>
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

