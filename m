Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:32937 "EHLO
	mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751209AbcFXO4Y (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Jun 2016 10:56:24 -0400
Received: by mail-io0-f195.google.com with SMTP id t74so15637264ioi.0
        for <linux-nfs@vger.kernel.org>; Fri, 24 Jun 2016 07:56:24 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 03/10] SUNRPC: Add a tracepoint for server socket out-of-space conditions
Date: Fri, 24 Jun 2016 10:55:45 -0400
Message-Id: <1466780152-7154-3-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1466780152-7154-2-git-send-email-trond.myklebust@primarydata.com>
References: <1466780152-7154-1-git-send-email-trond.myklebust@primarydata.com>
 <1466780152-7154-2-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add a tracepoint to track when the processing of incoming RPC data gets
deferred due to out-of-space issues on the outgoing transport.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 include/trace/events/sunrpc.h | 10 +++++++++-
 net/sunrpc/svc_xprt.c         |  8 ++++++--
 2 files changed, 15 insertions(+), 3 deletions(-)

diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
index a01a076ea060..f06701b3235c 100644
--- a/include/trace/events/sunrpc.h
+++ b/include/trace/events/sunrpc.h
@@ -556,7 +556,7 @@ TRACE_EVENT(svc_xprt_do_enqueue,
 		__entry->pid, show_svc_xprt_flags(__entry->flags))
 );
 
-TRACE_EVENT(svc_xprt_dequeue,
+DECLARE_EVENT_CLASS(svc_xprt_event,
 	TP_PROTO(struct svc_xprt *xprt),
 
 	TP_ARGS(xprt),
@@ -585,6 +585,14 @@ TRACE_EVENT(svc_xprt_dequeue,
 		show_svc_xprt_flags(__entry->flags))
 );
 
+DEFINE_EVENT(svc_xprt_event, svc_xprt_dequeue,
+	TP_PROTO(struct svc_xprt *xprt),
+	TP_ARGS(xprt));
+
+DEFINE_EVENT(svc_xprt_event, svc_xprt_no_write_space,
+	TP_PROTO(struct svc_xprt *xprt),
+	TP_ARGS(xprt));
+
 TRACE_EVENT(svc_wake_up,
 	TP_PROTO(int pid),
 
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index f5572e31d518..58372076a41a 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -331,8 +331,12 @@ static bool svc_xprt_has_something_to_do(struct svc_xprt *xprt)
 {
 	if (xprt->xpt_flags & ((1<<XPT_CONN)|(1<<XPT_CLOSE)))
 		return true;
-	if (xprt->xpt_flags & ((1<<XPT_DATA)|(1<<XPT_DEFERRED)))
-		return xprt->xpt_ops->xpo_has_wspace(xprt);
+	if (xprt->xpt_flags & ((1<<XPT_DATA)|(1<<XPT_DEFERRED))) {
+		if (xprt->xpt_ops->xpo_has_wspace(xprt))
+			return true;
+		trace_svc_xprt_no_write_space(xprt);
+		return false;
+	}
 	return false;
 }
 
-- 
2.7.4

