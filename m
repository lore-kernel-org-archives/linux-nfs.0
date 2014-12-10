Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f169.google.com ([209.85.216.169]:51073 "EHLO
	mail-qc0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932968AbaLJTIa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Dec 2014 14:08:30 -0500
Received: by mail-qc0-f169.google.com with SMTP id w7so2662720qcr.0
        for <linux-nfs@vger.kernel.org>; Wed, 10 Dec 2014 11:08:29 -0800 (PST)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        Tejun Heo <tj@kernel.org>, Al Viro <viro@zeniv.linux.org.uk>,
        NeilBrown <neilb@suse.de>
Subject: [PATCH v2 14/16] sunrpc: add more tracepoints around svc_xprt handling
Date: Wed, 10 Dec 2014 14:07:58 -0500
Message-Id: <1418238480-18857-15-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1418238480-18857-1-git-send-email-jlayton@primarydata.com>
References: <1418238480-18857-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Turn the svc_xprt_dequeue and svc_xprt_do_enqueue tracepoints into a
event classes, and use them to add events for svc_xprt_enqueued,
svc_xprt_active, svc_xprt_received, and svc_xprt_enqueue.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 include/trace/events/sunrpc.h | 36 +++++++++++++++++++++++++++---------
 net/sunrpc/svc_wq.c           |  4 ++++
 net/sunrpc/svc_xprt.c         |  9 ++++++++-
 3 files changed, 39 insertions(+), 10 deletions(-)

diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
index b9c1dc6c825a..41e09a1b962d 100644
--- a/include/trace/events/sunrpc.h
+++ b/include/trace/events/sunrpc.h
@@ -496,28 +496,40 @@ DEFINE_EVENT(svc_rqst_status, svc_send,
 		{ (1UL << XPT_CACHE_AUTH),	"XPT_CACHE_AUTH"},	\
 		{ (1UL << XPT_LOCAL),		"XPT_LOCAL"})
 
-TRACE_EVENT(svc_xprt_do_enqueue,
-	TP_PROTO(struct svc_xprt *xprt, struct svc_rqst *rqst),
+/* events associated with both a rqst and a xprt */
+DECLARE_EVENT_CLASS(svc_xprt_rqst_event,
+	TP_PROTO(struct svc_rqst *rqst, struct svc_xprt *xprt),
 
-	TP_ARGS(xprt, rqst),
+	TP_ARGS(rqst, xprt),
 
 	TP_STRUCT__entry(
-		__field(struct svc_xprt *, xprt)
 		__field(struct svc_rqst *, rqst)
+		__field(struct svc_xprt *, xprt)
 	),
 
 	TP_fast_assign(
-		__entry->xprt = xprt;
 		__entry->rqst = rqst;
+		__entry->xprt = xprt;
 	),
 
-	TP_printk("xprt=0x%p addr=%pIScp pid=%d flags=%s", __entry->xprt,
-		(struct sockaddr *)&__entry->xprt->xpt_remote,
-		__entry->rqst ? __entry->rqst->rq_task->pid : 0,
+	TP_printk("rqst=0x%p xprt=0x%p addr=%pIScp flags=%s", __entry->rqst,
+		__entry->xprt, (struct sockaddr *)&__entry->xprt->xpt_remote,
 		show_svc_xprt_flags(__entry->xprt->xpt_flags))
 );
 
-TRACE_EVENT(svc_xprt_dequeue,
+DEFINE_EVENT(svc_xprt_rqst_event, svc_xprt_enqueued,
+	TP_PROTO(struct svc_rqst *rqst, struct svc_xprt *xprt),
+	TP_ARGS(rqst, xprt));
+
+DEFINE_EVENT(svc_xprt_rqst_event, svc_xprt_active,
+	TP_PROTO(struct svc_rqst *rqst, struct svc_xprt *xprt),
+	TP_ARGS(rqst, xprt));
+
+DEFINE_EVENT(svc_xprt_rqst_event, svc_xprt_received,
+	TP_PROTO(struct svc_rqst *rqst, struct svc_xprt *xprt),
+	TP_ARGS(rqst, xprt));
+
+DECLARE_EVENT_CLASS(svc_xprt_event,
 	TP_PROTO(struct svc_xprt *xprt),
 
 	TP_ARGS(xprt),
@@ -539,6 +551,12 @@ TRACE_EVENT(svc_xprt_dequeue,
 		show_svc_xprt_flags(__entry->flags))
 );
 
+DEFINE_EVENT(svc_xprt_event, svc_xprt_enqueue,
+	TP_PROTO(struct svc_xprt *xprt), TP_ARGS(xprt));
+
+DEFINE_EVENT(svc_xprt_event, svc_xprt_dequeue,
+	TP_PROTO(struct svc_xprt *xprt), TP_ARGS(xprt));
+
 TRACE_EVENT(svc_wake_up,
 	TP_PROTO(int pid),
 
diff --git a/net/sunrpc/svc_wq.c b/net/sunrpc/svc_wq.c
index 1ca26d51b8ec..779eb51e4bbb 100644
--- a/net/sunrpc/svc_wq.c
+++ b/net/sunrpc/svc_wq.c
@@ -257,6 +257,8 @@ svc_wq_enqueue_xprt(struct svc_xprt *xprt)
 	struct svc_serv *serv = xprt->xpt_server;
 	struct svc_rqst *rqstp;
 
+	trace_svc_xprt_enqueue(xprt);
+
 	if (!svc_xprt_has_something_to_do(xprt))
 		return;
 
@@ -290,9 +292,11 @@ out:
 	rqstp = find_svc_rqst(serv);
 	if (!rqstp) {
 		queue_work(serv->sv_wq, &xprt->xpt_work);
+		trace_svc_xprt_enqueued(NULL, xprt);
 		return;
 	}
 	rqstp->rq_xprt = xprt;
 	queue_work(serv->sv_wq, &rqstp->rq_work);
+	trace_svc_xprt_enqueued(rqstp, xprt);
 }
 EXPORT_SYMBOL_GPL(svc_wq_enqueue_xprt);
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 17398eb9f38f..c759f04c9ee9 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -242,6 +242,7 @@ void svc_add_new_perm_xprt(struct svc_serv *serv, struct svc_xprt *new)
 	spin_lock_bh(&serv->sv_lock);
 	list_add(&new->xpt_list, &serv->sv_permsocks);
 	spin_unlock_bh(&serv->sv_lock);
+	trace_svc_xprt_received(NULL, new);
 	svc_xprt_received(new);
 }
 
@@ -329,6 +330,8 @@ void svc_xprt_do_enqueue(struct svc_xprt *xprt)
 	int cpu;
 	bool queued = false;
 
+	trace_svc_xprt_enqueue(xprt);
+
 	if (!svc_xprt_has_something_to_do(xprt))
 		goto out;
 
@@ -402,7 +405,7 @@ redo_search:
 	rqstp = NULL;
 	put_cpu();
 out:
-	trace_svc_xprt_do_enqueue(xprt, rqstp);
+	trace_svc_xprt_enqueued(rqstp, xprt);
 }
 EXPORT_SYMBOL_GPL(svc_xprt_do_enqueue);
 
@@ -738,6 +741,7 @@ static void svc_add_new_temp_xprt(struct svc_serv *serv, struct svc_xprt *newxpt
 			  jiffies + svc_conn_age_period * HZ);
 	}
 	spin_unlock_bh(&serv->sv_lock);
+	trace_svc_xprt_received(NULL, newxpt);
 	svc_xprt_received(newxpt);
 }
 
@@ -746,6 +750,8 @@ static int svc_handle_xprt(struct svc_rqst *rqstp, struct svc_xprt *xprt)
 	struct svc_serv *serv = rqstp->rq_server;
 	int len = 0;
 
+	trace_svc_xprt_active(rqstp, xprt);
+
 	if (test_bit(XPT_CLOSE, &xprt->xpt_flags)) {
 		dprintk("svc_recv: found XPT_CLOSE\n");
 		svc_delete_xprt(xprt);
@@ -780,6 +786,7 @@ static int svc_handle_xprt(struct svc_rqst *rqstp, struct svc_xprt *xprt)
 		atomic_add(rqstp->rq_reserved, &xprt->xpt_reserved);
 	}
 	/* clear XPT_BUSY: */
+	trace_svc_xprt_received(rqstp, xprt);
 	svc_xprt_received(xprt);
 out:
 	trace_svc_handle_xprt(xprt, len);
-- 
2.1.0

