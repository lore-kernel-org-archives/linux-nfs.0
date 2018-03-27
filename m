Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:39961 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750898AbeC0Owf (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 27 Mar 2018 10:52:35 -0400
Received: by mail-it0-f68.google.com with SMTP id y20-v6so15634507itc.5
        for <linux-nfs@vger.kernel.org>; Tue, 27 Mar 2018 07:52:35 -0700 (PDT)
Subject: [PATCH v2 10/18] svc: Report xprt dequeue latency
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Date: Tue, 27 Mar 2018 10:52:27 -0400
Message-ID: <20180327145227.7710.63124.stgit@oracle-ib-101.nfsv4bat.org>
In-Reply-To: <20180327144420.7710.82288.stgit@oracle-ib-101.nfsv4bat.org>
References: <20180327144420.7710.82288.stgit@oracle-ib-101.nfsv4bat.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Record the time between when a rqstp is enqueued on a transport
and when it is dequeued. This includes how long the rqstp waits on
the queue and how long it takes the kernel scheduler to wake a
nfsd thread to service it.

The svc_xprt_dequeue trace point is altered to include the number
of microseconds between xprt_enqueue and xprt_dequeue.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/svc.h    |    1 +
 include/trace/events/sunrpc.h |   30 ++++++++++++++++++++++++++----
 net/sunrpc/svc_xprt.c         |    4 ++--
 3 files changed, 29 insertions(+), 6 deletions(-)

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 3bd7504..dc4c009 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -272,6 +272,7 @@ struct svc_rqst {
 #define	RQ_BUSY		(6)			/* request is busy */
 #define	RQ_DATA		(7)			/* request has data */
 	unsigned long		rq_flags;	/* flags field */
+	ktime_t			rq_qtime;	/* enqueue time */
 
 	void *			rq_argp;	/* decoded arguments */
 	void *			rq_resp;	/* xdr'd results */
diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
index 1b383f7..922cb89 100644
--- a/include/trace/events/sunrpc.h
+++ b/include/trace/events/sunrpc.h
@@ -657,14 +657,36 @@
 			show_svc_xprt_flags(__entry->flags))
 );
 
-DEFINE_EVENT(svc_xprt_event, svc_xprt_dequeue,
-	TP_PROTO(struct svc_xprt *xprt),
-	TP_ARGS(xprt));
-
 DEFINE_EVENT(svc_xprt_event, svc_xprt_no_write_space,
 	TP_PROTO(struct svc_xprt *xprt),
 	TP_ARGS(xprt));
 
+TRACE_EVENT(svc_xprt_dequeue,
+	TP_PROTO(struct svc_rqst *rqst),
+
+	TP_ARGS(rqst),
+
+	TP_STRUCT__entry(
+		__field(struct svc_xprt *, xprt)
+		__field(unsigned long, flags)
+		__field(unsigned long, wakeup)
+		__string(addr, rqst->rq_xprt->xpt_remotebuf)
+	),
+
+	TP_fast_assign(
+		__entry->xprt = rqst->rq_xprt;
+		__entry->flags = rqst->rq_xprt->xpt_flags;
+		__entry->wakeup = ktime_to_us(ktime_sub(ktime_get(),
+							rqst->rq_qtime));
+		__assign_str(addr, rqst->rq_xprt->xpt_remotebuf);
+	),
+
+	TP_printk("xprt=%p addr=%s flags=%s wakeup-us=%lu",
+			__entry->xprt, __get_str(addr),
+			show_svc_xprt_flags(__entry->flags),
+			__entry->wakeup)
+);
+
 TRACE_EVENT(svc_wake_up,
 	TP_PROTO(int pid),
 
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index a7425da..5185efb 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -409,6 +409,7 @@ void svc_xprt_do_enqueue(struct svc_xprt *xprt)
 		if (test_and_set_bit(RQ_BUSY, &rqstp->rq_flags))
 			continue;
 		atomic_long_inc(&pool->sp_stats.threads_woken);
+		rqstp->rq_qtime = ktime_get();
 		wake_up_process(rqstp->rq_task);
 		goto out_unlock;
 	}
@@ -530,7 +531,6 @@ void svc_wake_up(struct svc_serv *serv)
 		if (test_bit(RQ_BUSY, &rqstp->rq_flags))
 			continue;
 		rcu_read_unlock();
-		dprintk("svc: daemon %p woken up.\n", rqstp);
 		wake_up_process(rqstp->rq_task);
 		trace_svc_wake_up(rqstp->rq_task->pid);
 		return;
@@ -726,7 +726,7 @@ static struct svc_xprt *svc_get_next_xprt(struct svc_rqst *rqstp, long timeout)
 		rqstp->rq_chandle.thread_wait = 5*HZ;
 	else
 		rqstp->rq_chandle.thread_wait = 1*HZ;
-	trace_svc_xprt_dequeue(rqstp->rq_xprt);
+	trace_svc_xprt_dequeue(rqstp);
 	return rqstp->rq_xprt;
 }
 

