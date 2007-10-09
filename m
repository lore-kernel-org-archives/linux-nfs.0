From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,
	PATCH 6/7] svc: Add svc API that queries for a transport instance
Date: Tue, 09 Oct 2007 10:37:20 -0500
Message-ID: <20071009153720.18846.88361.stgit@dell3.ogc.int>
References: <20071009153539.18846.33780.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, bfields@fieldses.org, gnb@sgi.com
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IfH96-0005fb-QF
	for nfs@lists.sourceforge.net; Tue, 09 Oct 2007 08:37:21 -0700
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IfH9B-0008Ao-OK
	for nfs@lists.sourceforge.net; Tue, 09 Oct 2007 08:37:26 -0700
In-Reply-To: <20071009153539.18846.33780.stgit@dell3.ogc.int>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


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
 include/linux/sunrpc/svc_xprt.h |    2 ++
 net/sunrpc/svc_xprt.c           |   30 ++++++++++++++++++++++++++++++
 3 files changed, 34 insertions(+), 14 deletions(-)

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
@@ -242,11 +230,11 @@ static int make_socks(struct svc_serv *s
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
index 2f45327..5dba9a5 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -82,4 +82,6 @@ static inline void svc_xprt_get(struct s
 void	svc_delete_xprt(struct svc_xprt *xprt);
 void	svc_close_xprt(struct svc_xprt *xprt);
 int	svc_print_xprts(char *buf, int maxlen);
+struct svc_xprt *
+svc_find_xprt(struct svc_serv *serv, char *xprt_class, int af, int port);
 #endif /* SUNRPC_SVC_XPRT_H */
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 323977a..4841c4b 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -950,3 +950,33 @@ static struct svc_deferred_req *svc_defe
 	spin_unlock(&xprt->xpt_lock);
 	return dr;
 }
+
+/*
+ * Return the transport instance pointer for the endpoint accepting
+ * connections/peer traffic from the specified transport class,
+ * address family and port.
+ *
+ * Specifying 0 for the address family or port is a wildcard and will
+ * match any transport with the firt transport with the same class
+ * name active for the service.
+ */
+struct svc_xprt *svc_find_xprt(struct svc_serv *serv, char *xcl_name,
+			       int af, int port)
+{
+	struct svc_xprt *xprt = NULL;
+	list_for_each_entry(xprt, &serv->sv_permsocks, xpt_list) {
+		struct sockaddr_in *sin;
+		if (strcmp(xprt->xpt_class->xcl_name, xcl_name))
+			continue;
+		sin = (struct sockaddr_in *)&xprt->xpt_local;
+		if (af && sin->sin_family != af)
+			continue;
+
+		if (port && (sin->sin_port != port))
+			continue;
+
+		break;
+	}
+	return xprt;
+}
+EXPORT_SYMBOL_GPL(svc_find_xprt);

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
