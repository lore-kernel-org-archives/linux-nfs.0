From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 03/40] SUNRPC: Clean up svc_find_xprt() calling sequence
Date: Thu, 12 Mar 2009 12:07:21 -0400
Message-ID: <20090312160721.16019.89653.stgit@ingres.1015granger.net>
References: <20090312155609.16019.86499.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org, trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:46806 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754214AbZCLQIN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Mar 2009 12:08:13 -0400
In-Reply-To: <20090312155609.16019.86499.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: add documentating comment and use appropriate data types for
svc_find_xprt()'s arguments.

This also eliminates a mixed sign comparison: @port was an int, while
the return value of svc_xprt_local_port() is an unsigned short.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/sunrpc/svc_xprt.h |    3 ++-
 net/sunrpc/svc_xprt.c           |   16 +++++++++++-----
 2 files changed, 13 insertions(+), 6 deletions(-)

diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index ee21e8a..167e4b5 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -80,7 +80,8 @@ void	svc_close_xprt(struct svc_xprt *xprt);
 void	svc_delete_xprt(struct svc_xprt *xprt);
 int	svc_port_is_privileged(struct sockaddr *sin);
 int	svc_print_xprts(char *buf, int maxlen);
-struct	svc_xprt *svc_find_xprt(struct svc_serv *, char *, int, int);
+struct	svc_xprt *svc_find_xprt(struct svc_serv *serv, const char *xcl_name,
+			const sa_family_t af, const unsigned short port);
 int	svc_xprt_names(struct svc_serv *serv, char *buf, int buflen);
 
 static inline void svc_xprt_get(struct svc_xprt *xprt)
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index e588df5..c947c93 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -1033,7 +1033,13 @@ static struct svc_deferred_req *svc_deferred_dequeue(struct svc_xprt *xprt)
 	return dr;
 }
 
-/*
+/**
+ * svc_find_xprt - find an RPC transport instance
+ * @serv: pointer to svc_serv to search
+ * @xcl_name: C string containing transport's class name
+ * @af: Address family of transport's local address
+ * @port: transport's IP port number
+ *
  * Return the transport instance pointer for the endpoint accepting
  * connections/peer traffic from the specified transport class,
  * address family and port.
@@ -1042,14 +1048,14 @@ static struct svc_deferred_req *svc_deferred_dequeue(struct svc_xprt *xprt)
  * wild-card, and will result in matching the first transport in the
  * service's list that has a matching class name.
  */
-struct svc_xprt *svc_find_xprt(struct svc_serv *serv, char *xcl_name,
-			       int af, int port)
+struct svc_xprt *svc_find_xprt(struct svc_serv *serv, const char *xcl_name,
+			       const sa_family_t af, const unsigned short port)
 {
 	struct svc_xprt *xprt;
 	struct svc_xprt *found = NULL;
 
 	/* Sanity check the args */
-	if (!serv || !xcl_name)
+	if (serv == NULL || xcl_name == NULL)
 		return found;
 
 	spin_lock_bh(&serv->sv_lock);
@@ -1058,7 +1064,7 @@ struct svc_xprt *svc_find_xprt(struct svc_serv *serv, char *xcl_name,
 			continue;
 		if (af != AF_UNSPEC && af != xprt->xpt_local.ss_family)
 			continue;
-		if (port && port != svc_xprt_local_port(xprt))
+		if (port != 0 && port != svc_xprt_local_port(xprt))
 			continue;
 		found = xprt;
 		svc_xprt_get(xprt);

