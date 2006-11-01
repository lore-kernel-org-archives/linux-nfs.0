From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 02/12] SUNRPC: Cache remote peer's address in svc_sock.
Date: Wed, 01 Nov 2006 13:08:14 -0500
Message-ID: <20061101180813.14581.55456.stgit@schiele.dsl.sfldmi.ameritech.net>
Reply-To: Chuck Lever <chucklever@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GfKVm-0006EJ-HJ
	for nfs@lists.sourceforge.net; Wed, 01 Nov 2006 10:08:27 -0800
Received: from flpvm23.prodigy.net ([207.115.20.53])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GfKVl-0002br-Ua
	for nfs@lists.sourceforge.net; Wed, 01 Nov 2006 10:08:27 -0800
To: neilb@suse.de
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

The remote peer's address won't change after the socket has been
accepted.  We don't need to call ->getname on every incoming request.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Aurelien Charbon <aurelien.charbon@ext.bull.net>
---

 include/linux/sunrpc/svcsock.h |    3 +++
 net/sunrpc/svcsock.c           |   11 +++++------
 2 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/svcsock.h
index dbcbfff..e260ba7 100644
--- a/include/linux/sunrpc/svcsock.h
+++ b/include/linux/sunrpc/svcsock.h
@@ -57,6 +57,9 @@ #define	SK_DETACHED	10			/* detached fro
 
 	/* cache of various info for TCP sockets */
 	void			*sk_info_authunix;
+
+	struct sockaddr_storage	sk_remote;	/* remote peer's address */
+	int			sk_remotelen;	/* length of address */
 };
 
 /*
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 0868b26..13b37a8 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -547,11 +547,9 @@ svc_recvfrom(struct svc_rqst *rqstp, str
 	len = kernel_recvmsg(sock, &msg, iov, nr, buflen, MSG_DONTWAIT);
 
 	/* sock_recvmsg doesn't fill in the name/namelen, so we must..
-	 * possibly we should cache this in the svc_sock structure
-	 * at accept time. FIXME
 	 */
-	alen = sizeof(rqstp->rq_addr);
-	kernel_getpeername(sock, (struct sockaddr *)&rqstp->rq_addr, &alen);
+	memcpy(&rqstp->rq_addr, &svsk->sk_remote, svsk->sk_remotelen);
+	rqstp->rq_addrlen = svsk->sk_remotelen;
 
 	dprintk("svc: socket %p recvfrom(%p, %Zu) = %d\n",
 		rqstp->rq_sock, iov[0].iov_base, iov[0].iov_len, len);
@@ -843,7 +841,7 @@ svc_tcp_accept(struct svc_sock *svsk)
 	struct socket	*sock = svsk->sk_sock;
 	struct socket	*newsock;
 	struct svc_sock	*newsvsk;
-	int		err, slen;
+	int		err, slen = 0;
 
 	dprintk("svc: tcp_accept %p sock %p\n", svsk, sock);
 	if (!sock)
@@ -894,7 +892,8 @@ svc_tcp_accept(struct svc_sock *svsk)
 
 	if (!(newsvsk = svc_setup_socket(serv, newsock, &err, 0)))
 		goto failed;
-
+	memcpy(&newsvsk->sk_remote, &sin, slen);
+	newsvsk->sk_remotelen = slen;
 
 	/* make sure that we don't have too many active connections.
 	 * If we have, something must be dropped.

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
