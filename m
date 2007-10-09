From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC, PATCH] svc: Modify svc_create_xprt to return local port
Date: Tue, 09 Oct 2007 17:52:53 -0500
Message-ID: <20071009225253.25816.36183.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, bfields@fieldses.org, gnb@sgi.com
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IfNwc-0001zu-Cj
	for nfs@lists.sourceforge.net; Tue, 09 Oct 2007 15:52:56 -0700
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IfNwh-0000DR-Bl
	for nfs@lists.sourceforge.net; Tue, 09 Oct 2007 15:52:59 -0700
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


Please take this version of the patch. The previous version has a
whitespace issue. Sorry for the inconvenience.

This patch fixes a regression introduced by the svc transport
switch as follows:

- Listening endpoints need to have their local address set properly. 

- svc_create_xprt needs to return the local port number since the
  the nfs4 callback service uses the return value to determine the 
  local port elected by the transport when binding to zero.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 net/sunrpc/svc_xprt.c |   19 ++++++++++++++++++-
 net/sunrpc/svcsock.c  |    8 ++++++++
 2 files changed, 26 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index b580d4c..d35195e 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -159,6 +159,23 @@ void svc_xprt_init(struct svc_xprt_class
 }
 EXPORT_SYMBOL_GPL(svc_xprt_init);
 
+static int svc_local_port(struct svc_xprt *xprt)
+{
+	int ret = 0;
+	switch (xprt->xpt_local.ss_family) {
+	case AF_INET:
+		ret = ntohs(((struct sockaddr_in *)
+			     &xprt->xpt_local)->sin_port);
+		break;
+	case AF_INET6:
+		ret = ntohs(((struct sockaddr_in6 *)
+			     &xprt->xpt_local)->sin6_port);
+		break;
+	}
+	dprintk("svc: local port for xprt %p is %d\n", xprt, ret);
+	return ret;
+}
+
 int svc_create_xprt(struct svc_serv *serv, char *xprt_name, unsigned short port,
 		    int flags)
 {
@@ -176,7 +193,6 @@ int svc_create_xprt(struct svc_serv *ser
 			spin_unlock(&svc_xprt_class_lock);
 			if (try_module_get(xcl->xcl_owner)) {
 				struct svc_xprt *newxprt;
-				ret = 0;
 				newxprt = xcl->xcl_ops->xpo_create
 					(serv,
 					 (struct sockaddr *)&sin, sizeof(sin),
@@ -191,6 +207,7 @@ int svc_create_xprt(struct svc_serv *ser
 					list_add(&newxprt->xpt_list,
 						 &serv->sv_permsocks);
 					spin_unlock_bh(&serv->sv_lock);
+					ret = svc_local_port(newxprt);
 				}
 			}
 			goto out;
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 7838b27..4bb2d57 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1278,6 +1278,8 @@ svc_create_socket(struct svc_serv *serv,
 	int		error;
 	int		type;
 	char		buf[RPC_MAX_ADDRBUFLEN];
+	struct sockaddr	newsin;
+	int		newlen;
 
 	dprintk("svc: svc_create_socket(%s, %d, %s)\n",
 			serv->sv_program->pg_name, protocol,
@@ -1302,12 +1304,18 @@ svc_create_socket(struct svc_serv *serv,
 	if (error < 0)
 		goto bummer;
 
+	newlen = len;
+	error = kernel_getsockname(sock, &newsin, &newlen);
+	if (error < 0)
+		goto bummer;
+
 	if (protocol == IPPROTO_TCP) {
 		if ((error = kernel_listen(sock, 64)) < 0)
 			goto bummer;
 	}
 
 	if ((svsk = svc_setup_socket(serv, sock, &error, flags)) != NULL) {
+		memcpy(&svsk->sk_xprt.xpt_local, &newsin, newlen);
 		svc_xprt_received(&svsk->sk_xprt);
 		return (struct svc_xprt *)svsk;
 	}

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
