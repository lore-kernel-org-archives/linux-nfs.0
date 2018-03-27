Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:35130 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751349AbeC0OwT (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 27 Mar 2018 10:52:19 -0400
Received: by mail-it0-f68.google.com with SMTP id v194-v6so15640717itb.0
        for <linux-nfs@vger.kernel.org>; Tue, 27 Mar 2018 07:52:19 -0700 (PDT)
Subject: [PATCH v2 09/18] sunrpc: Report per-RPC execution stats
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Date: Tue, 27 Mar 2018 10:51:39 -0400
Message-ID: <20180327145139.7710.14287.stgit@oracle-ib-101.nfsv4bat.org>
In-Reply-To: <20180327144420.7710.82288.stgit@oracle-ib-101.nfsv4bat.org>
References: <20180327144420.7710.82288.stgit@oracle-ib-101.nfsv4bat.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Introduce a mechanism to report the server-side execution latency of
each RPC. The goal is to enable user space to filter the trace
record for latency outliers, build histograms, etc.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/svc.h    |    1 +
 include/trace/events/sunrpc.h |   21 +++++++++++++++++++++
 net/sunrpc/svc_xprt.c         |    3 ++-
 3 files changed, 24 insertions(+), 1 deletion(-)

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 786ae22..3bd7504 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -283,6 +283,7 @@ struct svc_rqst {
 	int			rq_reserved;	/* space on socket outq
 						 * reserved for this request
 						 */
+	ktime_t			rq_stime;	/* start time */
 
 	struct cache_req	rq_chandle;	/* handle passed to caches for 
 						 * request delaying 
diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
index 5a8157c..1b383f7 100644
--- a/include/trace/events/sunrpc.h
+++ b/include/trace/events/sunrpc.h
@@ -705,6 +705,27 @@
 		__entry->len, show_svc_xprt_flags(__entry->flags))
 );
 
+TRACE_EVENT(svc_stats_latency,
+	TP_PROTO(const struct svc_rqst *rqst),
+
+	TP_ARGS(rqst),
+
+	TP_STRUCT__entry(
+		__field(u32, xid)
+		__field(unsigned long, execute)
+		__string(addr, rqst->rq_xprt->xpt_remotebuf)
+	),
+
+	TP_fast_assign(
+		__entry->xid = be32_to_cpu(rqst->rq_xid);
+		__entry->execute = ktime_to_us(ktime_sub(ktime_get(),
+							 rqst->rq_stime));
+		__assign_str(addr, rqst->rq_xprt->xpt_remotebuf);
+	),
+
+	TP_printk("addr=%s xid=0x%08x execute-us=%lu",
+		__get_str(addr), __entry->xid, __entry->execute)
+);
 
 DECLARE_EVENT_CLASS(svc_deferred_event,
 	TP_PROTO(struct svc_deferred_req *dr),
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index f745754..a7425da 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -782,7 +782,7 @@ static int svc_handle_xprt(struct svc_rqst *rqstp, struct svc_xprt *xprt)
 			len = svc_deferred_recv(rqstp);
 		else
 			len = xprt->xpt_ops->xpo_recvfrom(rqstp);
-		dprintk("svc: got len=%d\n", len);
+		rqstp->rq_stime = ktime_get();
 		rqstp->rq_reserved = serv->sv_max_mesg;
 		atomic_add(rqstp->rq_reserved, &xprt->xpt_reserved);
 	}
@@ -888,6 +888,7 @@ int svc_send(struct svc_rqst *rqstp)
 
 	/* Grab mutex to serialize outgoing data. */
 	mutex_lock(&xprt->xpt_mutex);
+	trace_svc_stats_latency(rqstp);
 	if (test_bit(XPT_DEAD, &xprt->xpt_flags)
 			|| test_bit(XPT_CLOSE, &xprt->xpt_flags))
 		len = -ENOTCONN;

