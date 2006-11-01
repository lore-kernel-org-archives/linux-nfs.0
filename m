From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 09/12] SUNRPC: add a "generic" function to see if the
	peer uses a secure port
Date: Wed, 01 Nov 2006 13:08:51 -0500
Message-ID: <20061101180851.14581.93970.stgit@schiele.dsl.sfldmi.ameritech.net>
Reply-To: Chuck Lever <chucklever@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GfKWM-0006I6-OO
	for nfs@lists.sourceforge.net; Wed, 01 Nov 2006 10:09:02 -0800
Received: from flpvm23.prodigy.net ([207.115.20.53])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GfKWN-0002oT-Kn
	for nfs@lists.sourceforge.net; Wed, 01 Nov 2006 10:09:03 -0800
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

The only reason svcsock.c looks at a sockaddr's port is to check whether
the remote peer is connecting from a privileged port.  Refactor this check
to hide processing that is specific to address format.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Aurelien Charbon <aurelien.charbon@ext.bull.net>
---

 net/sunrpc/svcsock.c |   19 ++++++++++++++++---
 1 files changed, 16 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index ccb5ff3..a83d97f 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -894,6 +894,20 @@ svc_tcp_data_ready(struct sock *sk, int 
 		wake_up_interruptible(sk->sk_sleep);
 }
 
+static inline int svc_port_is_privileged(struct sockaddr *sin)
+{
+	switch (sin->sa_family) {
+	case AF_INET:
+		return ntohs(((struct sockaddr_in *)sin)->sin_port) < 1024;
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+	case AF_INET6:
+		return ntohs(((struct sockaddr_in6 *)sin)->sin6_port) < 1024;
+#endif
+	default:
+		return 0;
+	}
+}
+
 /*
  * Accept a TCP connection
  */
@@ -941,7 +955,7 @@ svc_tcp_accept(struct svc_sock *svsk)
 	 * tell us anything.  For now just warn about unpriv connections.
 	 */
 	__svc_print_addr((struct sockaddr *) &sin, buf, sizeof(buf));
-	if (ntohs(sin.sin_port) >= 1024) {
+	if (!svc_port_is_privileged((struct sockaddr *) &sin)) {
 		dprintk(KERN_WARNING
 			"%s: connect from unprivileged port: %s\n",
 			serv->sv_name, buf);
@@ -1278,7 +1292,6 @@ int
 svc_recv(struct svc_rqst *rqstp, long timeout)
 {
 	struct svc_sock		*svsk = NULL;
-	struct sockaddr_in	*sin = (struct sockaddr_in *) &rqstp->rq_addr;
 	struct svc_serv		*serv = rqstp->rq_server;
 	struct svc_pool		*pool = rqstp->rq_pool;
 	int			len, i;
@@ -1373,7 +1386,7 @@ svc_recv(struct svc_rqst *rqstp, long ti
 	svsk->sk_lastrecv = get_seconds();
 	clear_bit(SK_OLD, &svsk->sk_flags);
 
-	rqstp->rq_secure = ntohs(sin->sin_port) < 1024;
+	rqstp->rq_secure = svc_port_is_privileged((struct sockaddr *) &rqstp->rq_addr);
 	rqstp->rq_chandle.defer = svc_defer;
 
 	if (serv->sv_stats)

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
