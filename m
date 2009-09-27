From: Jeff Layton <jlayton@redhat.com>
Subject: [RFC PATCH 5/9] sunrpc: make call_bind non-static
Date: Sun, 27 Sep 2009 12:50:26 -0400
Message-ID: <1254070230-13125-6-git-send-email-jlayton@redhat.com>
References: <1254070230-13125-1-git-send-email-jlayton@redhat.com>
To: linux-nfs@vger.kernel.org, linux-cifs-client@lists.samba.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cdptpa-omtalb.mail.rr.com ([75.180.132.123]:54612 "EHLO
	cdptpa-omtalb.mail.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752873AbZI0Q5N (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 27 Sep 2009 12:57:13 -0400
In-Reply-To: <1254070230-13125-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

...is there a better way to do this?

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 include/linux/sunrpc/clnt.h |    1 +
 net/sunrpc/clnt.c           |    4 ++--
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 307a3ec..92ff85d 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -171,6 +171,7 @@ size_t		rpc_pton(const char *, const size_t,
 char *		rpc_sockaddr2uaddr(const struct sockaddr *);
 size_t		rpc_uaddr2sockaddr(const char *, const size_t,
 				   struct sockaddr *, const size_t);
+void		call_bind(struct rpc_task *task);
 
 static inline unsigned short rpc_get_port(const struct sockaddr *sap)
 {
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 42688af..f2b0815 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -63,7 +63,6 @@ static void	call_reserve(struct rpc_task *task);
 static void	call_reserveresult(struct rpc_task *task);
 static void	call_allocate(struct rpc_task *task);
 static void	call_decode(struct rpc_task *task);
-static void	call_bind(struct rpc_task *task);
 static void	call_bind_status(struct rpc_task *task);
 static void	call_transmit(struct rpc_task *task);
 #if defined(CONFIG_NFS_V4_1)
@@ -1004,7 +1003,7 @@ EXPORT_SYMBOL_GPL(rpc_xdr_encode);
 /*
  * 4.	Get the server port number if not yet set
  */
-static void
+void
 call_bind(struct rpc_task *task)
 {
 	struct rpc_xprt *xprt = task->tk_xprt;
@@ -1018,6 +1017,7 @@ call_bind(struct rpc_task *task)
 		xprt->ops->rpcbind(task);
 	}
 }
+EXPORT_SYMBOL_GPL(call_bind);
 
 /*
  * 4a.	Sort out bind result
-- 
1.6.0.6

