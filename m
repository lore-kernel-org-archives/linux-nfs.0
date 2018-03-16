Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:33854 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751548AbeCPO2b (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Mar 2018 10:28:31 -0400
Subject: [PATCH 2/2] xprtrdma: Add static trace point in post_recvs
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Fri, 16 Mar 2018 10:28:30 -0400
Message-ID: <20180316142829.14085.18725.stgit@manet.1015granger.net>
In-Reply-To: <20180316141927.14085.31012.stgit@manet.1015granger.net>
References: <20180316141927.14085.31012.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Enable humans to monitor Receive posting behavior.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/trace/events/rpcrdma.h |   33 +++++++++++++++++++++++++++++++++
 net/sunrpc/xprtrdma/verbs.c    |    1 +
 2 files changed, 34 insertions(+)

diff --git a/include/trace/events/rpcrdma.h b/include/trace/events/rpcrdma.h
index 91c89eb..ca59cf5 100644
--- a/include/trace/events/rpcrdma.h
+++ b/include/trace/events/rpcrdma.h
@@ -549,6 +549,39 @@
 	)
 );
 
+TRACE_EVENT(xprtrdma_post_recvs,
+	TP_PROTO(
+		const struct rpcrdma_xprt *r_xprt,
+		unsigned int count,
+		int status
+	),
+
+	TP_ARGS(r_xprt, count, status),
+
+	TP_STRUCT__entry(
+		__field(const void *, r_xprt)
+		__field(unsigned int, count)
+		__field(int, status)
+		__field(int, posted)
+		__string(addr, rpcrdma_addrstr(r_xprt))
+		__string(port, rpcrdma_portstr(r_xprt))
+	),
+
+	TP_fast_assign(
+		__entry->r_xprt = r_xprt;
+		__entry->count = count;
+		__entry->status = status;
+		__entry->posted = r_xprt->rx_buf.rb_posted_receives;
+		__assign_str(addr, rpcrdma_addrstr(r_xprt));
+		__assign_str(port, rpcrdma_portstr(r_xprt));
+	),
+
+	TP_printk("peer=[%s]:%s r_xprt=%p: %u new recvs, %d active (rc %d)",
+		__get_str(addr), __get_str(port), __entry->r_xprt,
+		__entry->count, __entry->posted, __entry->status
+	)
+);
+
 /**
  ** Completion events
  **/
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 201b4ad..fe518b3 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1603,4 +1603,5 @@ struct rpcrdma_regbuf *
 		}
 	}
 	buf->rb_posted_receives += count;
+	trace_xprtrdma_post_recvs(r_xprt, count, rc);
 }

