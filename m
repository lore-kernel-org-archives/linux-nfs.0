From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/8] SUNRPC: Use proper INADDR_ANY when setting up RPC
	services on IPv6
Date: Mon, 30 Jun 2008 18:45:37 -0400
Message-ID: <20080630224537.24887.71813.stgit@ellison.1015granger.net>
References: <20080630224147.24887.18730.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com, bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:46769 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932351AbYF3Wp7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2008 18:45:59 -0400
In-Reply-To: <20080630224147.24887.18730.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Teach svc_create_xprt() to use the correct ANY address for AF_INET6 based
RPC services.

No caller uses AF_INET6 yet.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/svc_xprt.c |   39 +++++++++++++++++++++++++++++++++------
 1 files changed, 33 insertions(+), 6 deletions(-)


diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index e46c825..bf5b5cd 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -159,15 +159,44 @@ void svc_xprt_init(struct svc_xprt_class *xcl, struct svc_xprt *xprt,
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
+	struct sockaddr_in6 sin6 = {
+		.sin6_family		= AF_INET6,
+		.sin6_addr		= IN6ADDR_ANY_INIT,
+		.sin6_port		= htons(port),
+	};
+	struct sockaddr *sap;
+	size_t len;
+
+	switch (serv->sv_family) {
+	case AF_INET:
+		sap = (struct sockaddr *)&sin;
+		len = sizeof(sin);
+		break;
+	case AF_INET6:
+		sap = (struct sockaddr *)&sin6;
+		len = sizeof(sin6);
+		break;
+	default:
+		return ERR_PTR(-EAFNOSUPPORT);
+	}
+
+	return xcl->xcl_ops->xpo_create(serv, sap, len, flags);
+}
+
+int svc_create_xprt(struct svc_serv *serv, char *xprt_name, unsigned short port,
+		    int flags)
+{
+	struct svc_xprt_class *xcl;
+
 	dprintk("svc: creating transport %s[%d]\n", xprt_name, port);
 	spin_lock(&svc_xprt_class_lock);
 	list_for_each_entry(xcl, &svc_xprt_class_list, xcl_list) {
@@ -180,9 +209,7 @@ int svc_create_xprt(struct svc_serv *serv, char *xprt_name, unsigned short port,
 			goto err;
 
 		spin_unlock(&svc_xprt_class_lock);
-		newxprt = xcl->xcl_ops->
-			xpo_create(serv, (struct sockaddr *)&sin, sizeof(sin),
-				   flags);
+		newxprt = __svc_xpo_create(xcl, serv, port, flags);
 		if (IS_ERR(newxprt)) {
 			module_put(xcl->xcl_owner);
 			return PTR_ERR(newxprt);

