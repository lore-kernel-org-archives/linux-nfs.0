Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:56440 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757299AbdJQAr3 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 16 Oct 2017 20:47:29 -0400
Received: by mail-pf0-f174.google.com with SMTP id b85so58930pfj.13
        for <linux-nfs@vger.kernel.org>; Mon, 16 Oct 2017 17:47:29 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
To: "David S. Miller" <davem@davemloft.net>
Cc: Kees Cook <keescook@chromium.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
        Thomas Gleixner <tglx@linutronix.de>,
        linux-kernel@vger.kernel.org
Subject: [PATCH 58/58] sunrpc: Convert timers to use timer_setup()
Date: Mon, 16 Oct 2017 17:29:42 -0700
Message-Id: <1508200182-104605-59-git-send-email-keescook@chromium.org>
In-Reply-To: <1508200182-104605-1-git-send-email-keescook@chromium.org>
References: <1508200182-104605-1-git-send-email-keescook@chromium.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using the new timer_setup() and from_timer()
to pass the timer pointer explicitly.

Cc: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Anna Schumaker <anna.schumaker@netapp.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jeff Layton <jlayton@poochiereds.net>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: linux-nfs@vger.kernel.org
Cc: netdev@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 net/sunrpc/sched.c    | 8 ++++----
 net/sunrpc/svc.c      | 2 +-
 net/sunrpc/svc_xprt.c | 9 ++++-----
 net/sunrpc/xprt.c     | 9 ++++-----
 4 files changed, 13 insertions(+), 15 deletions(-)

diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index 0cc83839c13c..5dea47eb31bb 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -44,7 +44,7 @@ static mempool_t	*rpc_buffer_mempool __read_mostly;
 
 static void			rpc_async_schedule(struct work_struct *);
 static void			 rpc_release_task(struct rpc_task *task);
-static void __rpc_queue_timer_fn(unsigned long ptr);
+static void __rpc_queue_timer_fn(struct timer_list *t);
 
 /*
  * RPC tasks sit here while waiting for conditions to improve.
@@ -228,7 +228,7 @@ static void __rpc_init_priority_wait_queue(struct rpc_wait_queue *queue, const c
 	queue->maxpriority = nr_queues - 1;
 	rpc_reset_waitqueue_priority(queue);
 	queue->qlen = 0;
-	setup_timer(&queue->timer_list.timer, __rpc_queue_timer_fn, (unsigned long)queue);
+	timer_setup(&queue->timer_list.timer, __rpc_queue_timer_fn, 0);
 	INIT_LIST_HEAD(&queue->timer_list.list);
 	rpc_assign_waitqueue_name(queue, qname);
 }
@@ -635,9 +635,9 @@ void rpc_wake_up_status(struct rpc_wait_queue *queue, int status)
 }
 EXPORT_SYMBOL_GPL(rpc_wake_up_status);
 
-static void __rpc_queue_timer_fn(unsigned long ptr)
+static void __rpc_queue_timer_fn(struct timer_list *t)
 {
-	struct rpc_wait_queue *queue = (struct rpc_wait_queue *)ptr;
+	struct rpc_wait_queue *queue = from_timer(queue, t, timer_list.timer);
 	struct rpc_task *task, *n;
 	unsigned long expires, now, timeo;
 
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index aa04666f929d..33f4ae68426d 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -455,7 +455,7 @@ __svc_create(struct svc_program *prog, unsigned int bufsize, int npools,
 	serv->sv_xdrsize   = xdrsize;
 	INIT_LIST_HEAD(&serv->sv_tempsocks);
 	INIT_LIST_HEAD(&serv->sv_permsocks);
-	init_timer(&serv->sv_temptimer);
+	timer_setup(&serv->sv_temptimer, NULL, 0);
 	spin_lock_init(&serv->sv_lock);
 
 	__svc_init_bc(serv);
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index d16a8b423c20..71de77bd4423 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -28,7 +28,7 @@ module_param(svc_rpc_per_connection_limit, uint, 0644);
 static struct svc_deferred_req *svc_deferred_dequeue(struct svc_xprt *xprt);
 static int svc_deferred_recv(struct svc_rqst *rqstp);
 static struct cache_deferred_req *svc_defer(struct cache_req *req);
-static void svc_age_temp_xprts(unsigned long closure);
+static void svc_age_temp_xprts(struct timer_list *t);
 static void svc_delete_xprt(struct svc_xprt *xprt);
 
 /* apparently the "standard" is that clients close
@@ -785,8 +785,7 @@ static void svc_add_new_temp_xprt(struct svc_serv *serv, struct svc_xprt *newxpt
 	serv->sv_tmpcnt++;
 	if (serv->sv_temptimer.function == NULL) {
 		/* setup timer to age temp transports */
-		setup_timer(&serv->sv_temptimer, svc_age_temp_xprts,
-			    (unsigned long)serv);
+		serv->sv_temptimer.function = (TIMER_FUNC_TYPE)svc_age_temp_xprts;
 		mod_timer(&serv->sv_temptimer,
 			  jiffies + svc_conn_age_period * HZ);
 	}
@@ -960,9 +959,9 @@ int svc_send(struct svc_rqst *rqstp)
  * Timer function to close old temporary transports, using
  * a mark-and-sweep algorithm.
  */
-static void svc_age_temp_xprts(unsigned long closure)
+static void svc_age_temp_xprts(struct timer_list *t)
 {
-	struct svc_serv *serv = (struct svc_serv *)closure;
+	struct svc_serv *serv = from_timer(serv, t, sv_temptimer);
 	struct svc_xprt *xprt;
 	struct list_head *le, *next;
 
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index e741ec2b4d8e..4b00302e1867 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -696,9 +696,9 @@ xprt_schedule_autodisconnect(struct rpc_xprt *xprt)
 }
 
 static void
-xprt_init_autodisconnect(unsigned long data)
+xprt_init_autodisconnect(struct timer_list *t)
 {
-	struct rpc_xprt *xprt = (struct rpc_xprt *)data;
+	struct rpc_xprt *xprt = from_timer(xprt, t, timer);
 
 	spin_lock(&xprt->transport_lock);
 	if (!list_empty(&xprt->recv))
@@ -1422,10 +1422,9 @@ struct rpc_xprt *xprt_create_transport(struct xprt_create *args)
 		xprt->idle_timeout = 0;
 	INIT_WORK(&xprt->task_cleanup, xprt_autoclose);
 	if (xprt_has_timer(xprt))
-		setup_timer(&xprt->timer, xprt_init_autodisconnect,
-			    (unsigned long)xprt);
+		timer_setup(&xprt->timer, xprt_init_autodisconnect, 0);
 	else
-		init_timer(&xprt->timer);
+		timer_setup(&xprt->timer, NULL, 0);
 
 	if (strlen(args->servername) > RPC_MAXNETNAMELEN) {
 		xprt_destroy(xprt);
-- 
2.7.4

