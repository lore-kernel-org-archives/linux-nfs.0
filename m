From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,PATCH 2/3] svc: Fix bugs in svc_find_xprt
Date: Wed, 10 Oct 2007 21:28:59 -0500
Message-ID: <20071011022859.3501.12076.stgit@dell3.ogc.int>
References: <20071011022356.3501.63859.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: bfields@fieldses.org, neilb@suse.de, gnb@sgi.com
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IfnnJ-00078Q-9r
	for nfs@lists.sourceforge.net; Wed, 10 Oct 2007 19:29:01 -0700
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IfnnN-0007df-9p
	for nfs@lists.sourceforge.net; Wed, 10 Oct 2007 19:29:06 -0700
In-Reply-To: <20071011022356.3501.63859.stgit@dell3.ogc.int>
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


The bug fixes are as follows:

- Verify the required arguments to the function.
- Change the address family wildcard to the more type-friendly AF_UNSPEC.
- Properly handle the address family when comparing ports
- The svc_find_xprt service needs a lock on the sv_permsocks list

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 fs/lockd/svc.c        |    4 ++--
 net/sunrpc/svc_xprt.c |   26 ++++++++++++++++----------
 2 files changed, 18 insertions(+), 12 deletions(-)

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index 470af01..ee4a9bc 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -230,11 +230,11 @@ static int make_socks(struct svc_serv *s
 	int err = 0;
 
 	if (proto == IPPROTO_UDP || nlm_udpport)
-		if (!svc_find_xprt(serv, "udp", 0, 0))
+		if (!svc_find_xprt(serv, "udp", AF_UNSPEC, 0))
 			err = svc_create_xprt(serv, "udp", nlm_udpport,
 					      SVC_SOCK_DEFAULTS);
 	if (err >= 0 && (proto == IPPROTO_TCP || nlm_tcpport))
-		if (!svc_find_xprt(serv, "tcp", 0, 0))
+		if (!svc_find_xprt(serv, "tcp", AF_UNSPEC, 0))
 			err = svc_create_xprt(serv, "tcp", nlm_tcpport,
 					      SVC_SOCK_DEFAULTS);
 
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index d35195e..5fc8d41 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -960,25 +960,31 @@ static struct svc_deferred_req *svc_defe
  * connections/peer traffic from the specified transport class,
  * address family and port.
  *
- * Specifying 0 for the address family or port is a wildcard and will
- * match any transport with the firt transport with the same class
- * name active for the service.
+ * AF_UNSPEC for the address family or zero for a port
+ * number are wild cards.
  */
 struct svc_xprt *svc_find_xprt(struct svc_serv *serv, char *xcl_name,
 			       int af, int port)
 {
-	struct svc_xprt *xprt = NULL;
+	struct svc_xprt *xprt;
+	struct svc_xprt *found = NULL;
+
+	/* Sanity check args */
+	if (!serv || !xcl_name)
+		return found;
+
+	spin_lock_bh(&serv->sv_lock);
 	list_for_each_entry(xprt, &serv->sv_permsocks, xpt_list) {
-		struct sockaddr_in *sin;
 		if (strcmp(xprt->xpt_class->xcl_name, xcl_name))
 			continue;
-		sin = (struct sockaddr_in *)&xprt->xpt_local;
-		if (af && sin->sin_family != af)
+		if (af != AF_UNSPEC && af != xprt->xpt_local.ss_family)
 			continue;
-		if (port && (sin->sin_port != port))
+		if (port && port != svc_local_port(xprt))
 			continue;
-		return xprt;
+		found = xprt;
+		break;
 	}
-	return NULL;
+	spin_unlock_bh(&serv->sv_lock);
+	return found;
 }
 EXPORT_SYMBOL_GPL(svc_find_xprt);

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
