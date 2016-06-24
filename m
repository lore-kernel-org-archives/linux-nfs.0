Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:35045 "EHLO
	mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751410AbcFXO40 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Jun 2016 10:56:26 -0400
Received: by mail-io0-f194.google.com with SMTP id u25so15984430iou.2
        for <linux-nfs@vger.kernel.org>; Fri, 24 Jun 2016 07:56:26 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 04/10] SUNRPC: Add tracepoints for dropped and deferred requests
Date: Fri, 24 Jun 2016 10:55:46 -0400
Message-Id: <1466780152-7154-4-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1466780152-7154-3-git-send-email-trond.myklebust@primarydata.com>
References: <1466780152-7154-1-git-send-email-trond.myklebust@primarydata.com>
 <1466780152-7154-2-git-send-email-trond.myklebust@primarydata.com>
 <1466780152-7154-3-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Dropping and/or deferring requests has an impact on performance. Let's
make sure we can trace those events.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 include/trace/events/sunrpc.h | 61 +++++++++++++++++++++++++++++++++++++++++++
 net/sunrpc/svc_xprt.c         |  4 +++
 2 files changed, 65 insertions(+)

diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
index f06701b3235c..8a13e3903839 100644
--- a/include/trace/events/sunrpc.h
+++ b/include/trace/events/sunrpc.h
@@ -475,6 +475,39 @@ TRACE_EVENT(svc_recv,
 			show_rqstp_flags(__entry->flags))
 );
 
+DECLARE_EVENT_CLASS(svc_rqst_event,
+
+	TP_PROTO(struct svc_rqst *rqst),
+
+	TP_ARGS(rqst),
+
+	TP_STRUCT__entry(
+		__field(__be32, xid)
+		__field(unsigned long, flags)
+		__dynamic_array(unsigned char, addr, rqst->rq_addrlen)
+	),
+
+	TP_fast_assign(
+		__entry->xid = rqst->rq_xid;
+		__entry->flags = rqst->rq_flags;
+		memcpy(__get_dynamic_array(addr),
+			&rqst->rq_addr, rqst->rq_addrlen);
+	),
+
+	TP_printk("addr=%pIScp rq_xid=0x%x flags=%s",
+		(struct sockaddr *)__get_dynamic_array(addr),
+		be32_to_cpu(__entry->xid),
+		show_rqstp_flags(__entry->flags))
+);
+
+DEFINE_EVENT(svc_rqst_event, svc_defer,
+	TP_PROTO(struct svc_rqst *rqst),
+	TP_ARGS(rqst));
+
+DEFINE_EVENT(svc_rqst_event, svc_drop,
+	TP_PROTO(struct svc_rqst *rqst),
+	TP_ARGS(rqst));
+
 DECLARE_EVENT_CLASS(svc_rqst_status,
 
 	TP_PROTO(struct svc_rqst *rqst, int status),
@@ -639,6 +672,34 @@ TRACE_EVENT(svc_handle_xprt,
 			(struct sockaddr *)__get_dynamic_array(addr) : NULL,
 		__entry->len, show_svc_xprt_flags(__entry->flags))
 );
+
+
+DECLARE_EVENT_CLASS(svc_deferred_event,
+	TP_PROTO(struct svc_deferred_req *dr),
+
+	TP_ARGS(dr),
+
+	TP_STRUCT__entry(
+		__field(__be32, xid)
+		__dynamic_array(unsigned char, addr, dr->addrlen)
+	),
+
+	TP_fast_assign(
+		__entry->xid = *(__be32 *)(dr->args + (dr->xprt_hlen>>2));
+		memcpy(__get_dynamic_array(addr), &dr->addr, dr->addrlen);
+	),
+
+	TP_printk("addr=%pIScp xid=0x%x",
+		(struct sockaddr *)__get_dynamic_array(addr),
+		be32_to_cpu(__entry->xid))
+);
+
+DEFINE_EVENT(svc_deferred_event, svc_drop_deferred,
+	TP_PROTO(struct svc_deferred_req *dr),
+	TP_ARGS(dr));
+DEFINE_EVENT(svc_deferred_event, svc_revisit_deferred,
+	TP_PROTO(struct svc_deferred_req *dr),
+	TP_ARGS(dr));
 #endif /* _TRACE_SUNRPC_H */
 
 #include <trace/define_trace.h>
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 58372076a41a..eccc61237ca9 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -873,6 +873,7 @@ EXPORT_SYMBOL_GPL(svc_recv);
  */
 void svc_drop(struct svc_rqst *rqstp)
 {
+	trace_svc_drop(rqstp);
 	dprintk("svc: xprt %p dropped request\n", rqstp->rq_xprt);
 	svc_xprt_release(rqstp);
 }
@@ -1150,6 +1151,7 @@ static void svc_revisit(struct cache_deferred_req *dreq, int too_many)
 		spin_unlock(&xprt->xpt_lock);
 		dprintk("revisit canceled\n");
 		svc_xprt_put(xprt);
+		trace_svc_drop_deferred(dr);
 		kfree(dr);
 		return;
 	}
@@ -1207,6 +1209,7 @@ static struct cache_deferred_req *svc_defer(struct cache_req *req)
 	set_bit(RQ_DROPME, &rqstp->rq_flags);
 
 	dr->handle.revisit = svc_revisit;
+	trace_svc_defer(rqstp);
 	return &dr->handle;
 }
 
@@ -1247,6 +1250,7 @@ static struct svc_deferred_req *svc_deferred_dequeue(struct svc_xprt *xprt)
 				struct svc_deferred_req,
 				handle.recent);
 		list_del_init(&dr->handle.recent);
+		trace_svc_revisit_deferred(dr);
 	} else
 		clear_bit(XPT_DEFERRED, &xprt->xpt_flags);
 	spin_unlock(&xprt->xpt_lock);
-- 
2.7.4

