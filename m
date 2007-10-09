From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,
	PATCH 4/7] svc: Add a sockaddr length argument to the xpo_create
	function.
Date: Tue, 09 Oct 2007 10:37:16 -0500
Message-ID: <20071009153716.18846.36128.stgit@dell3.ogc.int>
References: <20071009153539.18846.33780.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, bfields@fieldses.org, gnb@sgi.com
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IfH94-0005fO-JB
	for nfs@lists.sourceforge.net; Tue, 09 Oct 2007 08:37:21 -0700
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IfH97-0000G1-H3
	for nfs@lists.sourceforge.net; Tue, 09 Oct 2007 08:37:21 -0700
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


The xpo_create function doesn't currently accept a sockaddr length.
Add this as a parameter to be consistent with other kernel interfaces
taking a sockaddr.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 include/linux/sunrpc/svc_xprt.h |    2 +-
 net/sunrpc/svc_xprt.c           |    4 +++-
 net/sunrpc/svcsock.c            |   10 ++++------
 3 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index a1a7d15..2f45327 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -12,7 +12,7 @@ #include <linux/module.h>
 
 struct svc_xprt_ops {
 	struct svc_xprt	*(*xpo_create)(struct svc_serv *,
-				       struct sockaddr *,
+				       struct sockaddr *, int,
 				       int);
 	struct svc_xprt	*(*xpo_accept)(struct svc_xprt *);
 	int		(*xpo_has_wspace)(struct svc_xprt *);
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 807795f..76036af 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -178,7 +178,9 @@ int svc_create_xprt(struct svc_serv *ser
 				struct svc_xprt *newxprt;
 				ret = 0;
 				newxprt = xcl->xcl_ops->xpo_create
-					(serv, (struct sockaddr *)&sin, flags);
+					(serv,
+					 (struct sockaddr *)&sin, sizeof(sin),
+					 flags);
 				if (IS_ERR(newxprt)) {
 					module_put(xcl->xcl_owner);
 					ret = PTR_ERR(newxprt);
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 07a6f42..ec834a7 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -655,10 +655,9 @@ svc_udp_accept(struct svc_xprt *xprt)
 }
 
 static struct svc_xprt *
-svc_udp_create(struct svc_serv *serv, struct sockaddr *sa, int flags)
+svc_udp_create(struct svc_serv *serv, struct sockaddr *sa, int alen, int flags)
 {
-	return svc_create_socket(serv, IPPROTO_UDP, sa,
-				 sizeof(struct sockaddr_in), flags);
+	return svc_create_socket(serv, IPPROTO_UDP, sa, alen, flags);
 }
 
 static struct svc_xprt_ops svc_udp_ops = {
@@ -1081,10 +1080,9 @@ svc_tcp_has_wspace(struct svc_xprt *xprt
 }
 
 static struct svc_xprt *
-svc_tcp_create(struct svc_serv *serv, struct sockaddr *sa, int flags)
+svc_tcp_create(struct svc_serv *serv, struct sockaddr *sa, int alen, int flags)
 {
-	return svc_create_socket(serv, IPPROTO_TCP, sa,
-				 sizeof(struct sockaddr_in), flags);
+	return svc_create_socket(serv, IPPROTO_TCP, sa, alen, flags);
 }
 
 static struct svc_xprt_ops svc_tcp_ops = {

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
