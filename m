From: Tom Tucker <tom@opengridcomputing.com>
Subject: [PATCH 38/40] svc: Add svc API that queries for a transport instance
Date: Sun, 30 Dec 2007 21:08:33 -0600
Message-ID: <20071231030833.8430.22392.stgit@dell3.ogc.int>
References: <20071231030712.8430.45576.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]:41603 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753083AbXLaDId (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 30 Dec 2007 22:08:33 -0500
In-Reply-To: <20071231030712.8430.45576.stgit-gUwIgmpLGaKNDNWfRnPdfg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Add a new svc function that allows a service to query whether a 
transport instance has already been created. This is used in lockd 
to determine whether or not a transport needs to be created when
a lockd instance is brought up. 

Specifying 0 for the address family or port is effectively a wild-card,
and will result in matching the first transport in the service's list
that has a matching class name.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 fs/lockd/svc.c                  |   16 ++--------------
 include/linux/sunrpc/svc_xprt.h |    1 +
 net/sunrpc/svc_xprt.c           |   35 +++++++++++++++++++++++++++++++++++
 3 files changed, 38 insertions(+), 14 deletions(-)

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index a8e79a9..470af01 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -219,18 +219,6 @@ lockd(struct svc_rqst *rqstp)
 	module_put_and_exit(0);
 }
 
-static int find_xprt(struct svc_serv *serv, char *proto)
-{
-	struct svc_xprt *xprt;
-	int found = 0;
-	list_for_each_entry(xprt, &serv->sv_permsocks, xpt_list)
-		if (strcmp(xprt->xpt_class->xcl_name, proto) == 0) {
-			found = 1;
-			break;
-		}
-	return found;
-}
-
 /*
  * Make any sockets that are needed but not present.
  * If nlm_udpport or nlm_tcpport were set as module
@@ -242,11 +230,11 @@ static int make_socks(struct svc_serv *serv, int proto)
 	int err = 0;
 
 	if (proto == IPPROTO_UDP || nlm_udpport)
-		if (!find_xprt(serv, "udp"))
+		if (!svc_find_xprt(serv, "udp", 0, 0))
 			err = svc_create_xprt(serv, "udp", nlm_udpport,
 					      SVC_SOCK_DEFAULTS);
 	if (err >= 0 && (proto == IPPROTO_TCP || nlm_tcpport))
-		if (!find_xprt(serv, "tcp"))
+		if (!svc_find_xprt(serv, "tcp", 0, 0))
 			err = svc_create_xprt(serv, "tcp", nlm_tcpport,
 					      SVC_SOCK_DEFAULTS);
 
diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index 01e71b7..68862d5 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -80,6 +80,7 @@ void	svc_close_xprt(struct svc_xprt *xprt);
 void	svc_delete_xprt(struct svc_xprt *xprt);
 int	svc_port_is_privileged(struct sockaddr *sin);
 int	svc_print_xprts(char *buf, int maxlen);
+struct	svc_xprt *svc_find_xprt(struct svc_serv *, char *, int, int);
 
 static inline void svc_xprt_get(struct svc_xprt *xprt)
 {
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 2e5b92a..512c10f 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -977,3 +977,38 @@ static struct svc_deferred_req *svc_deferred_dequeue(struct svc_xprt *xprt)
 	spin_unlock(&xprt->xpt_lock);
 	return dr;
 }
+
+/*
+ * Return the transport instance pointer for the endpoint accepting
+ * connections/peer traffic from the specified transport class,
+ * address family and port.
+ *
+ * Specifying 0 for the address family or port is effectively a
+ * wild-card, and will result in matching the first transport in the
+ * service's list that has a matching class name.
+ */
+struct svc_xprt *svc_find_xprt(struct svc_serv *serv, char *xcl_name,
+			       int af, int port)
+{
+	struct svc_xprt *xprt;
+	struct svc_xprt *found = NULL;
+
+	/* Sanity check the args */
+	if (!serv || !xcl_name)
+		return found;
+
+	spin_lock_bh(&serv->sv_lock);
+	list_for_each_entry(xprt, &serv->sv_permsocks, xpt_list) {
+		if (strcmp(xprt->xpt_class->xcl_name, xcl_name))
+			continue;
+		if (af != AF_UNSPEC && af != xprt->xpt_local.ss_family)
+			continue;
+		if (port && port != svc_xprt_local_port(xprt))
+			continue;
+		found = xprt;
+		break;
+	}
+	spin_unlock_bh(&serv->sv_lock);
+	return found;
+}
+EXPORT_SYMBOL_GPL(svc_find_xprt);
