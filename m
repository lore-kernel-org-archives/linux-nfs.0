From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 4/7] SUNRPC: Use proper INADDR_ANY when setting up RPC
	services on IPv6
Date: Mon, 18 Aug 2008 19:33:52 -0400
Message-ID: <20080818233352.1214.54561.stgit@manray.1015granger.net>
References: <20080818233128.1214.48603.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org, trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:21583 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752742AbYHSMHB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Aug 2008 08:07:01 -0400
In-Reply-To: <20080818233128.1214.48603.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Choose the correct family for the ANY address when initializing RPC
services.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/svc_xprt.c |   37 ++++++++++++++++++++++++++++++-------
 1 files changed, 30 insertions(+), 7 deletions(-)

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index e46c825..96eda5f 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -159,16 +159,41 @@ void svc_xprt_init(struct svc_xprt_class *xcl, struct svc_xprt *xprt,
 }
 EXPORT_SYMBOL_GPL(svc_xprt_init);
 
-int svc_create_xprt(struct svc_serv *serv, char *xprt_name, unsigned short port,
-		    int flags)
+static struct svc_xprt *__svc_xpo_create(struct svc_xprt_class *xcl,
+					 struct svc_serv *serv,
+					 unsigned short port, int flags)
 {
-	struct svc_xprt_class *xcl;
 	struct sockaddr_in sin = {
 		.sin_family		= AF_INET,
 		.sin_addr.s_addr	= htonl(INADDR_ANY),
 		.sin_port		= htons(port),
 	};
-	dprintk("svc: creating transport %s[%d]\n", xprt_name, port);
+	struct sockaddr_in6 sin6 = {
+		.sin6_family		= AF_INET6,
+		.sin6_addr		= IN6ADDR_ANY_INIT,
+		.sin6_port		= htons(port),
+	};
+
+	switch (serv->sv_family) {
+	case AF_INET:
+		return xcl->xcl_ops->xpo_create(serv,
+						(struct sockaddr *)&sin,
+						sizeof(sin), flags);
+	case AF_INET6:
+		return xcl->xcl_ops->xpo_create(serv,
+						(struct sockaddr *)&sin6,
+						sizeof(sin6), flags);
+	}
+
+	return ERR_PTR(-EAFNOSUPPORT);
+}
+
+int svc_create_xprt(struct svc_serv *serv, char *xprt_name, unsigned short port,
+		    int flags)
+{
+	struct svc_xprt_class *xcl;
+
+	dprintk("svc: creating transport %s[%u]\n", xprt_name, port);
 	spin_lock(&svc_xprt_class_lock);
 	list_for_each_entry(xcl, &svc_xprt_class_list, xcl_list) {
 		struct svc_xprt *newxprt;
@@ -180,9 +205,7 @@ int svc_create_xprt(struct svc_serv *serv, char *xprt_name, unsigned short port,
 			goto err;
 
 		spin_unlock(&svc_xprt_class_lock);
-		newxprt = xcl->xcl_ops->
-			xpo_create(serv, (struct sockaddr *)&sin, sizeof(sin),
-				   flags);
+		newxprt = __svc_xpo_create(xcl, serv, port, flags);
 		if (IS_ERR(newxprt)) {
 			module_put(xcl->xcl_owner);
 			return PTR_ERR(newxprt);

