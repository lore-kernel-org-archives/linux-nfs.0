Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:36333 "EHLO
	mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750997AbcFXO4X (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Jun 2016 10:56:23 -0400
Received: by mail-io0-f193.google.com with SMTP id s63so16495907ioi.3
        for <linux-nfs@vger.kernel.org>; Fri, 24 Jun 2016 07:56:23 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 02/10] SUNRPC: Don't allocate a full sockaddr_storage for tracing
Date: Fri, 24 Jun 2016 10:55:44 -0400
Message-Id: <1466780152-7154-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1466780152-7154-1-git-send-email-trond.myklebust@primarydata.com>
References: <1466780152-7154-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We're always tracing IPv4 or IPv6 addresses, so we can save a lot
of space on the ringbuffer by allocating the correct sockaddr size.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 include/trace/events/sunrpc.h | 47 +++++++++++++++++++++++++++++++------------
 1 file changed, 34 insertions(+), 13 deletions(-)

diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
index e82493d07a86..a01a076ea060 100644
--- a/include/trace/events/sunrpc.h
+++ b/include/trace/events/sunrpc.h
@@ -532,20 +532,27 @@ TRACE_EVENT(svc_xprt_do_enqueue,
 
 	TP_STRUCT__entry(
 		__field(struct svc_xprt *, xprt)
-		__field_struct(struct sockaddr_storage, ss)
 		__field(int, pid)
 		__field(unsigned long, flags)
+		__dynamic_array(unsigned char, addr, xprt != NULL ?
+			xprt->xpt_remotelen : 0)
 	),
 
 	TP_fast_assign(
 		__entry->xprt = xprt;
-		xprt ? memcpy(&__entry->ss, &xprt->xpt_remote, sizeof(__entry->ss)) : memset(&__entry->ss, 0, sizeof(__entry->ss));
 		__entry->pid = rqst? rqst->rq_task->pid : 0;
-		__entry->flags = xprt ? xprt->xpt_flags : 0;
+		if (xprt) {
+			memcpy(__get_dynamic_array(addr),
+				&xprt->xpt_remote,
+				xprt->xpt_remotelen);
+			__entry->flags = xprt->xpt_flags;
+		} else
+			__entry->flags = 0;
 	),
 
 	TP_printk("xprt=0x%p addr=%pIScp pid=%d flags=%s", __entry->xprt,
-		(struct sockaddr *)&__entry->ss,
+		__get_dynamic_array_len(addr) != 0 ?
+			(struct sockaddr *)__get_dynamic_array(addr) : NULL,
 		__entry->pid, show_svc_xprt_flags(__entry->flags))
 );
 
@@ -556,18 +563,25 @@ TRACE_EVENT(svc_xprt_dequeue,
 
 	TP_STRUCT__entry(
 		__field(struct svc_xprt *, xprt)
-		__field_struct(struct sockaddr_storage, ss)
 		__field(unsigned long, flags)
+		__dynamic_array(unsigned char, addr, xprt != NULL ?
+			xprt->xpt_remotelen : 0)
 	),
 
 	TP_fast_assign(
-		__entry->xprt = xprt,
-		xprt ? memcpy(&__entry->ss, &xprt->xpt_remote, sizeof(__entry->ss)) : memset(&__entry->ss, 0, sizeof(__entry->ss));
-		__entry->flags = xprt ? xprt->xpt_flags : 0;
+		__entry->xprt = xprt;
+		if (xprt) {
+			memcpy(__get_dynamic_array(addr),
+					&xprt->xpt_remote,
+					xprt->xpt_remotelen);
+			__entry->flags = xprt->xpt_flags;
+		} else
+			__entry->flags = 0;
 	),
 
 	TP_printk("xprt=0x%p addr=%pIScp flags=%s", __entry->xprt,
-		(struct sockaddr *)&__entry->ss,
+		__get_dynamic_array_len(addr) != 0 ?
+			(struct sockaddr *)__get_dynamic_array(addr) : NULL,
 		show_svc_xprt_flags(__entry->flags))
 );
 
@@ -595,19 +609,26 @@ TRACE_EVENT(svc_handle_xprt,
 	TP_STRUCT__entry(
 		__field(struct svc_xprt *, xprt)
 		__field(int, len)
-		__field_struct(struct sockaddr_storage, ss)
 		__field(unsigned long, flags)
+		__dynamic_array(unsigned char, addr, xprt != NULL ?
+			xprt->xpt_remotelen : 0)
 	),
 
 	TP_fast_assign(
 		__entry->xprt = xprt;
-		xprt ? memcpy(&__entry->ss, &xprt->xpt_remote, sizeof(__entry->ss)) : memset(&__entry->ss, 0, sizeof(__entry->ss));
 		__entry->len = len;
-		__entry->flags = xprt ? xprt->xpt_flags : 0;
+		if (xprt) {
+			memcpy(__get_dynamic_array(addr),
+					&xprt->xpt_remote,
+					xprt->xpt_remotelen);
+			__entry->flags = xprt->xpt_flags;
+		} else
+			__entry->flags = 0;
 	),
 
 	TP_printk("xprt=0x%p addr=%pIScp len=%d flags=%s", __entry->xprt,
-		(struct sockaddr *)&__entry->ss,
+		__get_dynamic_array_len(addr) != 0 ?
+			(struct sockaddr *)__get_dynamic_array(addr) : NULL,
 		__entry->len, show_svc_xprt_flags(__entry->flags))
 );
 #endif /* _TRACE_SUNRPC_H */
-- 
2.7.4

