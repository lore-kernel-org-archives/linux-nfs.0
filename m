Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:52908 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S964881AbeCMPoY (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Mar 2018 11:44:24 -0400
Received: by mail-it0-f68.google.com with SMTP id k135-v6so681116ite.2
        for <linux-nfs@vger.kernel.org>; Tue, 13 Mar 2018 08:44:23 -0700 (PDT)
Subject: [PATCH 08/15] sunrpc: Re-purpose trace_svc_process
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Date: Tue, 13 Mar 2018 11:44:22 -0400
Message-ID: <20180313154422.21531.76600.stgit@klimt.1015granger.net>
In-Reply-To: <20180313154053.21531.86316.stgit@klimt.1015granger.net>
References: <20180313154053.21531.86316.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, trace_svc_process has two call sites:

1. Just after a call to svc_send. svc_send already invokes
   trace_svc_send with the same arguments just before returning

2. Just before a call to svc_drop. svc_drop already invokes
   trace_svc_drop with the same arguments just after it is called

Therefore trace_svc_process does not provide any additional
information not already provided by these other trace points.

However, it would be useful to record the incoming RPC procedure.
So reuse trace_svc_process for this purpose.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/trace/events/sunrpc.h |   30 ++++++++++++++++++++++++++----
 net/sunrpc/svc.c              |    9 +++------
 2 files changed, 29 insertions(+), 10 deletions(-)

diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
index 1ec8c4c..5a8157c 100644
--- a/include/trace/events/sunrpc.h
+++ b/include/trace/events/sunrpc.h
@@ -508,6 +508,32 @@
 			show_rqstp_flags(__entry->flags))
 );
 
+TRACE_EVENT(svc_process,
+	TP_PROTO(const struct svc_rqst *rqst, const char *name),
+
+	TP_ARGS(rqst, name),
+
+	TP_STRUCT__entry(
+		__field(u32, xid)
+		__field(u32, vers)
+		__field(u32, proc)
+		__string(service, name)
+		__string(addr, rqst->rq_xprt->xpt_remotebuf)
+	),
+
+	TP_fast_assign(
+		__entry->xid = be32_to_cpu(rqst->rq_xid);
+		__entry->vers = rqst->rq_vers;
+		__entry->proc = rqst->rq_proc;
+		__assign_str(service, name);
+		__assign_str(addr, rqst->rq_xprt->xpt_remotebuf);
+	),
+
+	TP_printk("addr=%s xid=0x%08x service=%s vers=%u proc=%u",
+			__get_str(addr), __entry->xid,
+			__get_str(service), __entry->vers, __entry->proc)
+);
+
 DECLARE_EVENT_CLASS(svc_rqst_event,
 
 	TP_PROTO(struct svc_rqst *rqst),
@@ -564,10 +590,6 @@
 		  __entry->status, show_rqstp_flags(__entry->flags))
 );
 
-DEFINE_EVENT(svc_rqst_status, svc_process,
-	TP_PROTO(struct svc_rqst *rqst, int status),
-	TP_ARGS(rqst, status));
-
 DEFINE_EVENT(svc_rqst_status, svc_send,
 	TP_PROTO(struct svc_rqst *rqst, int status),
 	TP_ARGS(rqst, status));
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 387cc4a..f19987f 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1255,6 +1255,7 @@ static __printf(2,3) void svc_printk(struct svc_rqst *rqstp, const char *fmt, ..
 
 	/* Syntactic check complete */
 	serv->sv_stats->rpccnt++;
+	trace_svc_process(rqstp, progp->pg_name);
 
 	/* Build the reply header. */
 	statp = resv->iov_base +resv->iov_len;
@@ -1431,14 +1432,10 @@ static __printf(2,3) void svc_printk(struct svc_rqst *rqstp, const char *fmt, ..
 	}
 
 	/* Returns 1 for send, 0 for drop */
-	if (likely(svc_process_common(rqstp, argv, resv))) {
-		int ret = svc_send(rqstp);
+	if (likely(svc_process_common(rqstp, argv, resv)))
+		return svc_send(rqstp);
 
-		trace_svc_process(rqstp, ret);
-		return ret;
-	}
 out_drop:
-	trace_svc_process(rqstp, 0);
 	svc_drop(rqstp);
 	return 0;
 }

