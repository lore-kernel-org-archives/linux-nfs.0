Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:34046 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752532AbeC0Ouw (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 27 Mar 2018 10:50:52 -0400
Received: by mail-io0-f193.google.com with SMTP id r18so27904222ioa.1
        for <linux-nfs@vger.kernel.org>; Tue, 27 Mar 2018 07:50:52 -0700 (PDT)
Subject: [PATCH v2 06/18] sunrpc: Simplify trace_svc_recv
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Date: Tue, 27 Mar 2018 10:50:42 -0400
Message-ID: <20180327145042.7710.2870.stgit@oracle-ib-101.nfsv4bat.org>
In-Reply-To: <20180327144420.7710.82288.stgit@oracle-ib-101.nfsv4bat.org>
References: <20180327144420.7710.82288.stgit@oracle-ib-101.nfsv4bat.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There doesn't seem to be a lot of value in calling trace_svc_recv
in the failing case.

1. There are two very common cases: one is the transport is not
ready, and the other is shutdown. Neither is terribly interesting.

2. The trace record for the failing case contains nothing but
the status code.

Therefore the trace point call site in the error exit is removed.
Since the trace point is now recording a length instead of a
status, rename the status field and remove the case that records a
zero XID.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/trace/events/sunrpc.h |   14 +++++++-------
 net/sunrpc/svc_xprt.c         |    1 -
 2 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
index 9bba307..5849bfb 100644
--- a/include/trace/events/sunrpc.h
+++ b/include/trace/events/sunrpc.h
@@ -485,28 +485,28 @@
 		{ (1UL << RQ_BUSY),		"RQ_BUSY"})
 
 TRACE_EVENT(svc_recv,
-	TP_PROTO(struct svc_rqst *rqst, int status),
+	TP_PROTO(struct svc_rqst *rqst, int len),
 
-	TP_ARGS(rqst, status),
+	TP_ARGS(rqst, len),
 
 	TP_STRUCT__entry(
 		__field(u32, xid)
-		__field(int, status)
+		__field(int, len)
 		__field(unsigned long, flags)
 		__dynamic_array(unsigned char, addr, rqst->rq_addrlen)
 	),
 
 	TP_fast_assign(
-		__entry->xid = status > 0 ? be32_to_cpu(rqst->rq_xid) : 0;
-		__entry->status = status;
+		__entry->xid = be32_to_cpu(rqst->rq_xid);
+		__entry->len = len;
 		__entry->flags = rqst->rq_flags;
 		memcpy(__get_dynamic_array(addr),
 			&rqst->rq_addr, rqst->rq_addrlen);
 	),
 
-	TP_printk("addr=%pIScp xid=0x%08x status=%d flags=%s",
+	TP_printk("addr=%pIScp xid=0x%08x len=%d flags=%s",
 			(struct sockaddr *)__get_dynamic_array(addr),
-			__entry->xid, __entry->status,
+			__entry->xid, __entry->len,
 			show_rqstp_flags(__entry->flags))
 );
 
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 5fe150c..47384d0 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -848,7 +848,6 @@ int svc_recv(struct svc_rqst *rqstp, long timeout)
 	rqstp->rq_res.len = 0;
 	svc_xprt_release(rqstp);
 out:
-	trace_svc_recv(rqstp, err);
 	return err;
 }
 EXPORT_SYMBOL_GPL(svc_recv);

