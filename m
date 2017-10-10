Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:45516 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756553AbdJJRbs (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Oct 2017 13:31:48 -0400
Received: by mail-it0-f67.google.com with SMTP id n195so3014364itg.0
        for <linux-nfs@vger.kernel.org>; Tue, 10 Oct 2017 10:31:48 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: bfields@redhat.com, jlayton@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] SUNRPC: Fix tracepoint storage issues with svc_recv and svc_rqst_status
Date: Tue, 10 Oct 2017 13:31:42 -0400
Message-Id: <20171010173143.106492-1-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There is no guarantee that either the request or the svc_xprt exist
by the time we get round to printing the trace message.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 include/trace/events/sunrpc.h | 17 ++++++++++-------
 1 file changed, 10 insertions(+), 7 deletions(-)

diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
index 8a707f8a41c3..8a13e3903839 100644
--- a/include/trace/events/sunrpc.h
+++ b/include/trace/events/sunrpc.h
@@ -455,20 +455,22 @@ TRACE_EVENT(svc_recv,
 	TP_ARGS(rqst, status),
 
 	TP_STRUCT__entry(
-		__field(struct sockaddr *, addr)
 		__field(__be32, xid)
 		__field(int, status)
 		__field(unsigned long, flags)
+		__dynamic_array(unsigned char, addr, rqst->rq_addrlen)
 	),
 
 	TP_fast_assign(
-		__entry->addr = (struct sockaddr *)&rqst->rq_addr;
 		__entry->xid = status > 0 ? rqst->rq_xid : 0;
 		__entry->status = status;
 		__entry->flags = rqst->rq_flags;
+		memcpy(__get_dynamic_array(addr),
+			&rqst->rq_addr, rqst->rq_addrlen);
 	),
 
-	TP_printk("addr=%pIScp xid=0x%x status=%d flags=%s", __entry->addr,
+	TP_printk("addr=%pIScp xid=0x%x status=%d flags=%s",
+			(struct sockaddr *)__get_dynamic_array(addr),
 			be32_to_cpu(__entry->xid), __entry->status,
 			show_rqstp_flags(__entry->flags))
 );
@@ -513,22 +515,23 @@ DECLARE_EVENT_CLASS(svc_rqst_status,
 	TP_ARGS(rqst, status),
 
 	TP_STRUCT__entry(
-		__field(struct sockaddr *, addr)
 		__field(__be32, xid)
-		__field(int, dropme)
 		__field(int, status)
 		__field(unsigned long, flags)
+		__dynamic_array(unsigned char, addr, rqst->rq_addrlen)
 	),
 
 	TP_fast_assign(
-		__entry->addr = (struct sockaddr *)&rqst->rq_addr;
 		__entry->xid = rqst->rq_xid;
 		__entry->status = status;
 		__entry->flags = rqst->rq_flags;
+		memcpy(__get_dynamic_array(addr),
+			&rqst->rq_addr, rqst->rq_addrlen);
 	),
 
 	TP_printk("addr=%pIScp rq_xid=0x%x status=%d flags=%s",
-		__entry->addr, be32_to_cpu(__entry->xid),
+		(struct sockaddr *)__get_dynamic_array(addr),
+		be32_to_cpu(__entry->xid),
 		__entry->status, show_rqstp_flags(__entry->flags))
 );
 
-- 
2.13.6

