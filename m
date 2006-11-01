From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 12/12] SUNRPC: fix up svc_create_socket() to take a
	sockaddr struct + length
Date: Wed, 01 Nov 2006 13:09:07 -0500
Message-ID: <20061101180907.14581.87314.stgit@schiele.dsl.sfldmi.ameritech.net>
Reply-To: Chuck Lever <chucklever@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GfKWc-0006NO-44
	for nfs@lists.sourceforge.net; Wed, 01 Nov 2006 10:09:18 -0800
Received: from flpvm23.prodigy.net ([207.115.20.53])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GfKWZ-0003Sa-QP
	for nfs@lists.sourceforge.net; Wed, 01 Nov 2006 10:09:19 -0800
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

Replace existing svc_create_socket() API to allow callers to pass addresses
larger than a sockaddr_in.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Aurelien Charbon <aurelien.charbon@ext.bull.net>
---

 net/sunrpc/svcsock.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index daac4a2..64f2e2f 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1637,8 +1637,7 @@ EXPORT_SYMBOL_GPL(svc_addsock);
 /*
  * Create socket for RPC service.
  */
-static int
-svc_create_socket(struct svc_serv *serv, int protocol, struct sockaddr_in *sin, int pmap_register)
+static int svc_create_socket(struct svc_serv *serv, int protocol, struct sockaddr *sin, int len, int pmap_register)
 {
 	struct svc_sock	*svsk;
 	struct socket	*sock;
@@ -1646,7 +1645,7 @@ svc_create_socket(struct svc_serv *serv,
 	int		type;
 	char		buf[RPC_MAX_ADDRBUFLEN];
 
-	__svc_print_addr((struct sockaddr *) sin, buf, sizeof(buf));
+	__svc_print_addr(sin, buf, sizeof(buf));
 	dprintk("svc: svc_create_socket(%s, %d, %s)\n",
 				serv->sv_program->pg_name, protocol, buf);
 
@@ -1657,13 +1656,12 @@ svc_create_socket(struct svc_serv *serv,
 	}
 	type = (protocol == IPPROTO_UDP)? SOCK_DGRAM : SOCK_STREAM;
 
-	if ((error = sock_create_kern(PF_INET, type, protocol, &sock)) < 0)
+	if ((error = sock_create_kern(sin->sa_family, type, protocol, &sock)) < 0)
 		return error;
 
 	if (type == SOCK_STREAM)
-		sock->sk->sk_reuse = 1; /* allow address reuse */
-	error = kernel_bind(sock, (struct sockaddr *) sin,
-					sizeof(*sin));
+		sock->sk->sk_reuse = 1;		/* allow address reuse */
+	error = kernel_bind(sock, sin, len);
 	if (error < 0)
 		goto bummer;
 
@@ -1731,7 +1729,9 @@ static inline int __svc_makesock(struct 
 	sin.sin_family      = AF_INET;
 	sin.sin_addr.s_addr = INADDR_ANY;
 	sin.sin_port        = htons(port);
-	return svc_create_socket(serv, protocol, &sin, pmap_register);
+
+	return svc_create_socket(serv, protocol, (struct sockaddr *) &sin,
+					sizeof(sin), pmap_register);
 }
 
 /**

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
