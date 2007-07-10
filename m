From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,PATCH 17/20] svc: Add sko_get_name service
Date: Tue, 10 Jul 2007 00:34:56 -0500
Message-ID: <20070710053455.28979.52209.stgit@dell3.ogc.int>
References: <20070710052711.28979.70843.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I88NB-00075o-5F
	for nfs@lists.sourceforge.net; Mon, 09 Jul 2007 22:34:53 -0700
Received: from rrcs-71-42-183-126.sw.biz.rr.com ([71.42.183.126]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I88NE-0003Vg-7k
	for nfs@lists.sourceforge.net; Mon, 09 Jul 2007 22:34:56 -0700
Received: from dell3.ogc.int (localhost [127.0.0.1])
	by smtp.opengridcomputing.com (Postfix) with ESMTP id 1034B7C75F
	for <nfs@lists.sourceforge.net>; Tue, 10 Jul 2007 00:34:56 -0500 (CDT)
In-Reply-To: <20070710052711.28979.70843.stgit@dell3.ogc.int>
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


Add an sko function to return a formatted socket name. This is used
by knfsd when satisfying reads to the portlist file.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 include/linux/sunrpc/svcsock.h |    1 +
 net/sunrpc/svcsock.c           |   17 ++++++++++++-----
 2 files changed, 13 insertions(+), 5 deletions(-)

diff --git a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/svcsock.h
index 383ac4f..5c272db 100644
--- a/include/linux/sunrpc/svcsock.h
+++ b/include/linux/sunrpc/svcsock.h
@@ -18,6 +18,7 @@ struct svc_sock_ops {
 	int			(*sko_create_svc)(struct svc_serv *,
 						  struct sockaddr *,
 						  int);
+	int			(*sko_get_name)(char *, struct svc_sock*);
 	int			(*sko_recvfrom)(struct svc_rqst *rqstp);
 	int			(*sko_sendto)(struct svc_rqst *rqstp);
 	/*
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index b14dc46..6bd6169 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -622,10 +622,7 @@ out:
 	return len;
 }
 
-/*
- * Report socket names for nfsdfs
- */
-static int one_sock_name(char *buf, struct svc_sock *svsk)
+static int svc_tcpip_get_name(char *buf, struct svc_sock *svsk)
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
+	return svsk->sk_ops->sko_get_name(buf,svsk);
+}
+
 int
 svc_sock_names(char *buf, struct svc_serv *serv, char *toclose)
 {
@@ -975,6 +980,7 @@ static struct svc_sock_ops svc_udp_ops =
 	.sko_name = "udp",
 	.sko_owner = THIS_MODULE,
 	.sko_create_svc = svc_udp_create_svc,
+	.sko_get_name = svc_tcpip_get_name,
 	.sko_recvfrom = svc_udp_recvfrom,
 	.sko_sendto = svc_udp_sendto,
 	.sko_detach = svc_tcpip_detach,
@@ -1443,6 +1449,7 @@ static struct svc_sock_ops svc_tcp_ops =
 	.sko_name = "tcp",
 	.sko_owner = THIS_MODULE,
 	.sko_create_svc = svc_tcp_create_svc,
+	.sko_get_name = svc_tcpip_get_name,
 	.sko_recvfrom = svc_tcp_recvfrom,
 	.sko_sendto = svc_tcp_sendto,
 	.sko_detach = svc_tcpip_detach,

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
