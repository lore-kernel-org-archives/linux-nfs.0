Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53710 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751113AbbHYGF0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 Aug 2015 02:05:26 -0400
From: Pratyush Anand <panand@redhat.com>
To: bfields@fieldses.org
Cc: rostedt@goodmis.org, linux-nfs@vger.kernel.org,
        Pratyush Anand <panand@redhat.com>, Ingo Molnar <mingo@redhat.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        Jeff Layton <jlayton@primarydata.com>,
        linux-kernel@vger.kernel.org (open list),
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH 1/2] net: sunrpc: fix tracepoint Warning: unknown op '->'
Date: Tue, 25 Aug 2015 11:34:19 +0530
Message-Id: <edc9697b5140015b15c96cc1b505b3c53169e634.1440482404.git.panand@redhat.com>
In-Reply-To: <cover.1440482404.git.panand@redhat.com>
References: <cover.1440482404.git.panand@redhat.com>
In-Reply-To: <cover.1440482404.git.panand@redhat.com>
References: <cover.1440482404.git.panand@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

`perf stat  -e sunrpc:svc_xprt_do_enqueue true` results in

Warning: unknown op '->'
Warning: [sunrpc:svc_xprt_do_enqueue] unknown op '->'

Similar warning for svc_handle_xprt as well.

Actually TP_printk() should never dereference an address saved in the ring
buffer that points somewhere in the kernel. There's no guarantee that that
object still exists (with the exception of static strings).

Therefore change all the arguments for TP_printk(), so that it references
values existing in the ring buffer only.

While doing that, also fix another possible bug when argument xprt could be
NULL and TP_fast_assign() tries to access it's elements.

Signed-off-by: Pratyush Anand <panand@redhat.com>
Cc: Steven Rostedt <rostedt@goodmis.org>
---
 include/trace/events/sunrpc.h | 21 ++++++++++++++++-----
 1 file changed, 16 insertions(+), 5 deletions(-)

diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
index fd1a02cb3c82..937e482d80e9 100644
--- a/include/trace/events/sunrpc.h
+++ b/include/trace/events/sunrpc.h
@@ -529,18 +529,24 @@ TRACE_EVENT(svc_xprt_do_enqueue,
 
 	TP_STRUCT__entry(
 		__field(struct svc_xprt *, xprt)
+		__field(struct sockaddr *, addr)
 		__field(struct svc_rqst *, rqst)
+		__field(int, pid)
+		__field(unsigned long, flags)
 	),
 
 	TP_fast_assign(
 		__entry->xprt = xprt;
+		__entry->addr =
+			xprt ? (struct sockaddr *)&xprt->xpt_remote : NULL;
 		__entry->rqst = rqst;
+		__entry->pid = rqst? rqst->rq_task->pid : 0;
+		__entry->flags = xprt ? xprt->xpt_flags : 0;
 	),
 
 	TP_printk("xprt=0x%p addr=%pIScp pid=%d flags=%s", __entry->xprt,
-		(struct sockaddr *)&__entry->xprt->xpt_remote,
-		__entry->rqst ? __entry->rqst->rq_task->pid : 0,
-		show_svc_xprt_flags(__entry->xprt->xpt_flags))
+		__entry->addr, __entry->pid,
+		show_svc_xprt_flags(__entry->flags))
 );
 
 TRACE_EVENT(svc_xprt_dequeue,
@@ -589,16 +595,21 @@ TRACE_EVENT(svc_handle_xprt,
 	TP_STRUCT__entry(
 		__field(struct svc_xprt *, xprt)
 		__field(int, len)
+		__field(struct sockaddr *, addr)
+		__field(unsigned long, flags)
 	),
 
 	TP_fast_assign(
 		__entry->xprt = xprt;
+		__entry->addr =
+			xprt ? (struct sockaddr *)&xprt->xpt_remote : NULL;
 		__entry->len = len;
+		__entry->flags = xprt ? xprt->xpt_flags : 0;
 	),
 
 	TP_printk("xprt=0x%p addr=%pIScp len=%d flags=%s", __entry->xprt,
-		(struct sockaddr *)&__entry->xprt->xpt_remote, __entry->len,
-		show_svc_xprt_flags(__entry->xprt->xpt_flags))
+		__entry->addr, __entry->len,
+		show_svc_xprt_flags(__entry->flags))
 );
 #endif /* _TRACE_SUNRPC_H */
 
-- 
2.4.3

