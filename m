From: Frank van Maarseveen <frankvm@frankvm.com>
Subject: [PATCH 1/3] SUNRPC server: record the destination address of
	a request
Date: Thu, 5 Jul 2007 17:25:42 +0200
Message-ID: <20070705152542.GB6603@janus>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: Linux NFS mailing list <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I6TDB-0002uy-QT
	for nfs@lists.sourceforge.net; Thu, 05 Jul 2007 08:25:42 -0700
Received: from frankvm.xs4all.nl ([80.126.170.174] helo=janus.localdomain)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I6TDF-0007Y9-1z
	for nfs@lists.sourceforge.net; Thu, 05 Jul 2007 08:25:45 -0700
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

Save the destination address of an incoming request over TCP like is
done already for UDP. It is necessary later for callbacks by the server.

Signed-off-by: Frank van Maarseveen <frankvm@frankvm.com>
---

This patch is IPv6 clean.

diff -urp a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/svcsock.h
--- a/include/linux/sunrpc/svcsock.h	2007-04-27 18:05:33.000000000 +0200
+++ b/include/linux/sunrpc/svcsock.h	2007-07-05 15:33:11.000000000 +0200
@@ -58,6 +58,7 @@ struct svc_sock {
 	/* cache of various info for TCP sockets */
 	void			*sk_info_authunix;
 
+	struct sockaddr_storage	sk_local;	/* local address */
 	struct sockaddr_storage	sk_remote;	/* remote peer's address */
 	int			sk_remotelen;	/* length of address */
 };
diff -urp a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
--- a/net/sunrpc/svcsock.c	2007-04-27 18:05:39.000000000 +0200
+++ b/net/sunrpc/svcsock.c	2007-07-05 15:33:11.000000000 +0200
@@ -643,6 +643,7 @@ svc_recvfrom(struct svc_rqst *rqstp, str
 	struct msghdr msg = {
 		.msg_flags	= MSG_DONTWAIT,
 	};
+	struct sockaddr *sin;
 	int len;
 
 	len = kernel_recvmsg(svsk->sk_sock, &msg, iov, nr, buflen,
@@ -653,6 +654,19 @@ svc_recvfrom(struct svc_rqst *rqstp, str
 	memcpy(&rqstp->rq_addr, &svsk->sk_remote, svsk->sk_remotelen);
 	rqstp->rq_addrlen = svsk->sk_remotelen;
 
+	/* Destination address in request is needed for binding the
+	 * source address in RPC callbacks later.
+	 */
+	sin = (struct sockaddr *)&svsk->sk_local;
+	switch (sin->sa_family) {
+	case AF_INET:
+		rqstp->rq_daddr.addr = ((struct sockaddr_in *)sin)->sin_addr;
+		break;
+	case AF_INET6:
+		rqstp->rq_daddr.addr6 = ((struct sockaddr_in6 *)sin)->sin6_addr;
+		break;
+	}
+
 	dprintk("svc: socket %p recvfrom(%p, %Zu) = %d\n",
 		svsk, iov[0].iov_base, iov[0].iov_len, len);
 
@@ -1062,6 +1076,12 @@ svc_tcp_accept(struct svc_sock *svsk)
 		goto failed;
 	memcpy(&newsvsk->sk_remote, sin, slen);
 	newsvsk->sk_remotelen = slen;
+	err = kernel_getsockname(newsock, sin, &slen);
+	if (unlikely(err < 0)) {
+		dprintk("svc_tcp_accept: kernel_getsockname error %d\n", -err);
+		slen = offsetof(struct sockaddr, sa_data);
+	}
+	memcpy(&newsvsk->sk_local, sin, slen);
 
 	svc_sock_received(newsvsk);
 

-- 
Frank

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
