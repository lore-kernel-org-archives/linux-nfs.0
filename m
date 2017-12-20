Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:42646 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756589AbdLTVbr (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Dec 2017 16:31:47 -0500
Subject: [PATCH v1 11/12] xprtrdma: Add trace points to instrument QP and CQ
 access upcalls
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Wed, 20 Dec 2017 16:31:45 -0500
Message-ID: <20171220213145.29321.82361.stgit@manet.1015granger.net>
In-Reply-To: <20171220210236.29321.59307.stgit@manet.1015granger.net>
References: <20171220210236.29321.59307.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/trace/events/rpcrdma.h |   31 +++++++++++++++++++++++++++++++
 net/sunrpc/xprtrdma/verbs.c    |    3 +++
 2 files changed, 34 insertions(+)

diff --git a/include/trace/events/rpcrdma.h b/include/trace/events/rpcrdma.h
index 16ac4d4..5aa3ec7 100644
--- a/include/trace/events/rpcrdma.h
+++ b/include/trace/events/rpcrdma.h
@@ -374,6 +374,37 @@
 DEFINE_RXPRT_EVENT(xprtrdma_reconnect);
 DEFINE_RXPRT_EVENT(xprtrdma_inject_dsc);
 
+TRACE_EVENT(xprtrdma_qp_error,
+	TP_PROTO(
+		const struct rpcrdma_xprt *r_xprt,
+		const struct ib_event *event
+	),
+
+	TP_ARGS(r_xprt, event),
+
+	TP_STRUCT__entry(
+		__field(const void *, r_xprt)
+		__field(unsigned int, event)
+		__string(name, event->device->name)
+		__string(addr, rpcrdma_addrstr(r_xprt))
+		__string(port, rpcrdma_portstr(r_xprt))
+	),
+
+	TP_fast_assign(
+		__entry->r_xprt = r_xprt;
+		__entry->event = event->event;
+		__assign_str(name, event->device->name);
+		__assign_str(addr, rpcrdma_addrstr(r_xprt));
+		__assign_str(port, rpcrdma_portstr(r_xprt));
+	),
+
+	TP_printk("peer=[%s]:%s r_xprt=%p: dev %s: %s (%u)",
+		__get_str(addr), __get_str(port), __entry->r_xprt,
+		__get_str(name), rdma_show_ib_event(__entry->event),
+		__entry->event
+	)
+);
+
 /**
  ** Call events
  **/
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 7f9e902..fb81d3a 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -108,7 +108,10 @@
 rpcrdma_qp_async_error_upcall(struct ib_event *event, void *context)
 {
 	struct rpcrdma_ep *ep = context;
+	struct rpcrdma_xprt *r_xprt = container_of(ep, struct rpcrdma_xprt,
+						   rx_ep);
 
+	trace_xprtrdma_qp_error(r_xprt, event);
 	pr_err("rpcrdma: %s on device %s ep %p\n",
 	       ib_event_msg(event->event), event->device->name, context);
 

