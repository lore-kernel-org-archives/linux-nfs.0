From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,PATCH 17/20] svc: Add xpt_get_name service
Date: Mon, 20 Aug 2007 11:23:57 -0500
Message-ID: <20070820162357.15224.34084.stgit@dell3.ogc.int>
References: <20070820162000.15224.65524.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1INA2q-0006Pe-Id
	for nfs@lists.sourceforge.net; Mon, 20 Aug 2007 09:24:01 -0700
Received: from smtp.opengridcomputing.com ([71.42.183.126])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1INA2t-00046r-GQ
	for nfs@lists.sourceforge.net; Mon, 20 Aug 2007 09:24:04 -0700
Received: from dell3.ogc.int (localhost [127.0.0.1])
	by smtp.opengridcomputing.com (Postfix) with ESMTP id B23847C79C
	for <nfs@lists.sourceforge.net>; Mon, 20 Aug 2007 11:23:57 -0500 (CDT)
In-Reply-To: <20070820162000.15224.65524.stgit@dell3.ogc.int>
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


Add an transport function to return a formatted socket name. 
This is used by knfsd when satisfying reads to the portlist file.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 include/linux/sunrpc/svcsock.h |    1 +
 net/sunrpc/svcsock.c           |   17 ++++++++++++-----
 2 files changed, 13 insertions(+), 5 deletions(-)

diff --git a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/svcsock.h
index e2d0256..a920e9b 100644
--- a/include/linux/sunrpc/svcsock.h
+++ b/include/linux/sunrpc/svcsock.h
@@ -18,6 +18,7 @@ struct svc_xprt {
 	int			(*xpt_create_svc)(struct svc_serv *,
 						  struct sockaddr *,
 						  int);
+	int			(*xpt_get_name)(char *, struct svc_sock*);
 	int			(*xpt_recvfrom)(struct svc_rqst *rqstp);
 	int			(*xpt_sendto)(struct svc_rqst *rqstp);
 	/*
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 44d6484..03ce7e9 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -622,10 +622,7 @@ out:
 	return len;
 }
 
-/*
- * Report socket names for nfsdfs
- */
-static int one_sock_name(char *buf, struct svc_sock *svsk)
+static int svc_sock_get_name(char *buf, struct svc_sock *svsk)
 {
 	int len;
 
@@ -639,11 +636,19 @@ static int one_sock_name(char *buf, stru
 		break;
 	default:
 		len = sprintf(buf, "*unknown-%d*\n",
-			       svsk->sk_sk->sk_family);
+                              svsk->sk_sk->sk_family);
 	}
 	return len;
 }
 
+/*
+ * Report socket names for nfsdfs
+ */
+static int one_sock_name(char *buf, struct svc_sock *svsk)
+{
+	return svsk->sk_xprt->xpt_get_name(buf,svsk);
+}
+
 int
 svc_sock_names(char *buf, struct svc_serv *serv, char *toclose)
 {
@@ -975,6 +980,7 @@ static struct svc_xprt svc_udp_xprt = {
 	.xpt_name = "udp",
 	.xpt_owner = THIS_MODULE,
 	.xpt_create_svc = svc_udp_create_svc,
+	.xpt_get_name = svc_sock_get_name,
 	.xpt_recvfrom = svc_udp_recvfrom,
 	.xpt_sendto = svc_udp_sendto,
 	.xpt_detach = svc_sock_detach,
@@ -1443,6 +1449,7 @@ static struct svc_xprt svc_tcp_xprt = {
 	.xpt_name = "tcp",
 	.xpt_owner = THIS_MODULE,
 	.xpt_create_svc = svc_tcp_create_svc,
+	.xpt_get_name = svc_sock_get_name,
 	.xpt_recvfrom = svc_tcp_recvfrom,
 	.xpt_sendto = svc_tcp_sendto,
 	.xpt_detach = svc_sock_detach,

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
