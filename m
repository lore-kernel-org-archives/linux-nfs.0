From: Jeff Layton <jlayton@redhat.com>
Subject: [RFC PATCH 4/9] sunrpc: move rpc_xdr_buf_init to clnt.h
Date: Sun, 27 Sep 2009 12:50:25 -0400
Message-ID: <1254070230-13125-5-git-send-email-jlayton@redhat.com>
References: <1254070230-13125-1-git-send-email-jlayton@redhat.com>
To: linux-nfs@vger.kernel.org, linux-cifs-client@lists.samba.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cdptpa-omtalb.mail.rr.com ([75.180.132.123]:37637 "EHLO
	cdptpa-omtalb.mail.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751812AbZI0Q5M (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 27 Sep 2009 12:57:12 -0400
In-Reply-To: <1254070230-13125-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

...so that it can be used elsewhere.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 include/linux/sunrpc/clnt.h |   13 ++++++++++++-
 net/sunrpc/clnt.c           |   12 ------------
 2 files changed, 12 insertions(+), 13 deletions(-)

diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 00afedc..307a3ec 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -165,7 +165,6 @@ size_t		rpc_max_payload(struct rpc_clnt *);
 void		rpc_force_rebind(struct rpc_clnt *);
 size_t		rpc_peeraddr(struct rpc_clnt *, struct sockaddr *, size_t);
 const char	*rpc_peeraddr2str(struct rpc_clnt *, enum rpc_display_format_t);
-
 size_t		rpc_ntop(const struct sockaddr *, char *, const size_t);
 size_t		rpc_pton(const char *, const size_t,
 			 struct sockaddr *, const size_t);
@@ -197,6 +196,18 @@ static inline void rpc_set_port(struct sockaddr *sap,
 	}
 }
 
+static inline void
+rpc_xdr_buf_init(struct xdr_buf *buf, void *start, size_t len)
+{
+	buf->head[0].iov_base = start;
+	buf->head[0].iov_len = len;
+	buf->tail[0].iov_len = 0;
+	buf->page_len = 0;
+	buf->flags = 0;
+	buf->len = 0;
+	buf->buflen = len;
+}
+
 #define IPV6_SCOPE_DELIMITER		'%'
 #define IPV6_SCOPE_ID_LEN		sizeof("%nnnnnnnnnn")
 
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index f05d289..42688af 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -966,18 +966,6 @@ rpc_task_force_reencode(struct rpc_task *task)
 	task->tk_rqstp->rq_bytes_sent = 0;
 }
 
-static inline void
-rpc_xdr_buf_init(struct xdr_buf *buf, void *start, size_t len)
-{
-	buf->head[0].iov_base = start;
-	buf->head[0].iov_len = len;
-	buf->tail[0].iov_len = 0;
-	buf->page_len = 0;
-	buf->flags = 0;
-	buf->len = 0;
-	buf->buflen = len;
-}
-
 /*
  * 3.	Encode arguments of an RPC call
  */
-- 
1.6.0.6

