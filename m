From: Greg Banks <gnb@sgi.com>
Subject: [RFC,PATCH 5/14] knfsd: max_payload per transport
Date: Thu, 17 May 2007 05:23:06 +1000
Message-ID: <20070516192306.GK9626@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Thomas Talpey <Thomas.Talpey@netapp.com>,
	Peter Leckie <pleckie@melbourne.sgi.com>
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HoP5Y-0000RJ-91
	for nfs@lists.sourceforge.net; Wed, 16 May 2007 12:23:08 -0700
Received: from netops-testserver-4-out.sgi.com ([192.48.171.29]
	helo=relay.sgi.com) by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1HoP5a-0001ie-SL
	for nfs@lists.sourceforge.net; Wed, 16 May 2007 12:23:11 -0700
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


Make svc_max_payload() delegate to a new method in svc_sock_ops
instead of reaching into the socket (beause later the NFS/RDMA
transport will not even have a socket).

Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
Signed-off-by: Peter Leckie <pleckie@melbourne.sgi.com>
---

 include/linux/sunrpc/svcsock.h |    6 ++++++
 net/sunrpc/svc.c               |    5 ++---
 net/sunrpc/svcsock.c           |   16 ++++++++++++++--
 3 files changed, 22 insertions(+), 5 deletions(-)

Index: linux/include/linux/sunrpc/svcsock.h
===================================================================
--- linux.orig/include/linux/sunrpc/svcsock.h	2007-05-17 00:46:47.944827892 +1000
+++ linux/include/linux/sunrpc/svcsock.h	2007-05-17 01:28:41.131377156 +1000
@@ -37,6 +37,12 @@ struct svc_sock_ops {
 	 * Return 1 if sufficient space to write reply to network.
 	 */
 	int			(*sko_has_wspace)(struct svc_sock *);
+	/*
+	 * Return the largest payload (i.e. READ, WRITE or READDIR
+	 * data length not including NFS headers) supported by the
+	 * svc_sock.
+	 */
+	u32			(*sko_max_payload)(struct svc_sock *);
 };
 
 /*
Index: linux/net/sunrpc/svc.c
===================================================================
--- linux.orig/net/sunrpc/svc.c	2007-05-17 00:36:20.557193782 +1000
+++ linux/net/sunrpc/svc.c	2007-05-17 01:28:25.217367463 +1000
@@ -1020,10 +1020,9 @@ err_bad:
  */
 u32 svc_max_payload(const struct svc_rqst *rqstp)
 {
-	int max = RPCSVC_MAXPAYLOAD_TCP;
+	struct svc_sock *svsk = rqstp->rq_sock;
+	int max = svsk->sk_ops->sko_max_payload(svsk);
 
-	if (rqstp->rq_sock->sk_sock->type == SOCK_DGRAM)
-		max = RPCSVC_MAXPAYLOAD_UDP;
 	if (rqstp->rq_server->sv_max_payload < max)
 		max = rqstp->rq_server->sv_max_payload;
 	return max;
Index: linux/net/sunrpc/svcsock.c
===================================================================
--- linux.orig/net/sunrpc/svcsock.c	2007-05-17 00:49:50.820303639 +1000
+++ linux/net/sunrpc/svcsock.c	2007-05-17 01:28:25.221366963 +1000
@@ -910,6 +910,11 @@ svc_udp_has_wspace(struct svc_sock *svsk
 	return svc_sock_has_write_space(svsk, sock_wspace(svsk->sk_sk));
 }
 
+static u32 svc_udp_max_payload(struct svc_sock *svsk)
+{
+	return RPCSVC_MAXPAYLOAD_UDP;
+}
+
 static const struct svc_sock_ops svc_udp_ops = {
 	.sko_name = "udp",
 	.sko_recvfrom = svc_udp_recvfrom,
@@ -917,7 +922,8 @@ static const struct svc_sock_ops svc_udp
 	.sko_detach = svc_tcpip_detach,
 	.sko_free = svc_tcpip_free,
 	.sko_prepare_reply = svc_tcpip_prepare_reply,
-	.sko_has_wspace = svc_udp_has_wspace
+	.sko_has_wspace = svc_udp_has_wspace,
+	.sko_max_payload = svc_udp_max_payload
 };
 
 static void
@@ -1378,6 +1384,11 @@ svc_tcp_has_wspace(struct svc_sock *svsk
 	return svc_sock_has_write_space(svsk, sk_stream_wspace(svsk->sk_sk));
 }
 
+static u32 svc_tcp_max_payload(struct svc_sock *svsk)
+{
+	return RPCSVC_MAXPAYLOAD_TCP;
+}
+
 static const struct svc_sock_ops svc_tcp_ops = {
 	.sko_name = "tcp",
 	.sko_recvfrom = svc_tcp_recvfrom,
@@ -1385,7 +1396,8 @@ static const struct svc_sock_ops svc_tcp
 	.sko_detach = svc_tcpip_detach,
 	.sko_free = svc_tcpip_free,
 	.sko_prepare_reply = svc_tcp_prepare_reply,
-	.sko_has_wspace = svc_tcp_has_wspace
+	.sko_has_wspace = svc_tcp_has_wspace,
+	.sko_max_payload = svc_tcp_max_payload
 };
 
 static void
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
Apparently, I'm Bedevere.  Which MPHG character are you?
I don't speak for SGI.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
