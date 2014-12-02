Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f171.google.com ([209.85.216.171]:34913 "EHLO
	mail-qc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932616AbaLBSYt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Dec 2014 13:24:49 -0500
Received: by mail-qc0-f171.google.com with SMTP id r5so9745235qcx.2
        for <linux-nfs@vger.kernel.org>; Tue, 02 Dec 2014 10:24:48 -0800 (PST)
From: Jeff Layton <jlayton@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>,
        Al Viro <viro@zeniv.linux.org.uk>
Subject: [RFC PATCH 13/14] sunrpc: add more tracepoints around svc_xprt handling
Date: Tue,  2 Dec 2014 13:24:22 -0500
Message-Id: <1417544663-13299-14-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1417544663-13299-1-git-send-email-jlayton@primarydata.com>
References: <1417544663-13299-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Turn the svc_xprt_dequeue tracepoint into an event class, and use it
to add events for svc_xprt_received and svc_xprt_enqueue.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 include/trace/events/sunrpc.h | 14 ++++++++++++--
 net/sunrpc/svc_wq.c           |  1 +
 net/sunrpc/svc_xprt.c         |  5 ++++-
 3 files changed, 17 insertions(+), 3 deletions(-)

diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
index b9c1dc6c825a..434b46e79053 100644
--- a/include/trace/events/sunrpc.h
+++ b/include/trace/events/sunrpc.h
@@ -496,7 +496,7 @@ DEFINE_EVENT(svc_rqst_status, svc_send,
 		{ (1UL << XPT_CACHE_AUTH),	"XPT_CACHE_AUTH"},	\
 		{ (1UL << XPT_LOCAL),		"XPT_LOCAL"})
 
-TRACE_EVENT(svc_xprt_do_enqueue,
+TRACE_EVENT(svc_xprt_enqueue,
 	TP_PROTO(struct svc_xprt *xprt, struct svc_rqst *rqst),
 
 	TP_ARGS(xprt, rqst),
@@ -517,7 +517,7 @@ TRACE_EVENT(svc_xprt_do_enqueue,
 		show_svc_xprt_flags(__entry->xprt->xpt_flags))
 );
 
-TRACE_EVENT(svc_xprt_dequeue,
+DECLARE_EVENT_CLASS(svc_xprt_event,
 	TP_PROTO(struct svc_xprt *xprt),
 
 	TP_ARGS(xprt),
@@ -539,6 +539,15 @@ TRACE_EVENT(svc_xprt_dequeue,
 		show_svc_xprt_flags(__entry->flags))
 );
 
+DEFINE_EVENT(svc_xprt_event, svc_xprt_dequeue,
+	TP_PROTO(struct svc_xprt *xprt), TP_ARGS(xprt));
+
+DEFINE_EVENT(svc_xprt_event, svc_xprt_received,
+	TP_PROTO(struct svc_xprt *xprt), TP_ARGS(xprt));
+
+DEFINE_EVENT(svc_xprt_event, svc_xprt_active,
+	TP_PROTO(struct svc_xprt *xprt), TP_ARGS(xprt));
+
 TRACE_EVENT(svc_wake_up,
 	TP_PROTO(int pid),
 
@@ -574,6 +583,7 @@ TRACE_EVENT(svc_handle_xprt,
 		(struct sockaddr *)&__entry->xprt->xpt_remote, __entry->len,
 		show_svc_xprt_flags(__entry->xprt->xpt_flags))
 );
+
 #endif /* _TRACE_SUNRPC_H */
 
 #include <trace/define_trace.h>
diff --git a/net/sunrpc/svc_wq.c b/net/sunrpc/svc_wq.c
index e96bbf49c1a0..315a86c7ed10 100644
--- a/net/sunrpc/svc_wq.c
+++ b/net/sunrpc/svc_wq.c
@@ -275,6 +275,7 @@ svc_wq_enqueue_xprt(struct svc_xprt *xprt)
 	}
 out:
 	svc_xprt_get(xprt);
+	trace_svc_xprt_enqueue(xprt, NULL);
 	queue_work(serv->sv_wq, &xprt->xpt_work);
 }
 EXPORT_SYMBOL_GPL(svc_wq_enqueue_xprt);
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 30f9fdfbff0c..7dd08f16140f 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -221,6 +221,7 @@ static struct svc_xprt *__svc_xpo_create(struct svc_xprt_class *xcl,
  */
 static void svc_xprt_received(struct svc_xprt *xprt)
 {
+	trace_svc_xprt_received(xprt);
 	if (!test_bit(XPT_BUSY, &xprt->xpt_flags)) {
 		WARN_ONCE(1, "xprt=0x%p already busy!", xprt);
 		return;
@@ -402,7 +403,7 @@ redo_search:
 	rqstp = NULL;
 	put_cpu();
 out:
-	trace_svc_xprt_do_enqueue(xprt, rqstp);
+	trace_svc_xprt_enqueue(xprt, rqstp);
 }
 EXPORT_SYMBOL_GPL(svc_xprt_do_enqueue);
 
@@ -746,6 +747,8 @@ static int svc_handle_xprt(struct svc_rqst *rqstp, struct svc_xprt *xprt)
 	struct svc_serv *serv = rqstp->rq_server;
 	int len = 0;
 
+	trace_svc_xprt_active(xprt);
+
 	if (test_bit(XPT_CLOSE, &xprt->xpt_flags)) {
 		dprintk("svc_recv: found XPT_CLOSE\n");
 		svc_delete_xprt(xprt);
-- 
2.1.0

