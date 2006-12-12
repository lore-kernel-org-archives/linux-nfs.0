From: NeilBrown <neilb@suse.de>
Subject: [PATCH 010 of 14] knfsd: SUNRPC: add a "generic" function to
	see if the peer uses a secure port
Date: Wed, 13 Dec 2006 10:59:27 +1100
Message-ID: <1061212235927.21484@suse.de>
References: <20061213105528.21128.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GuHWi-0002Xp-W2
	for nfs@lists.sourceforge.net; Tue, 12 Dec 2006 15:59:13 -0800
Received: from ns.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GuHWi-0004uu-Sx
	for nfs@lists.sourceforge.net; Tue, 12 Dec 2006 15:59:14 -0800
To: Andrew Morton <akpm@osdl.org>
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


From: Chuck Lever <chuck.lever@oracle.com>
The only reason svcsock.c looks at a sockaddr's port is to check whether
the remote peer is connecting from a privileged port.  Refactor this check
to hide processing that is specific to address format.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Aurelien Charbon <aurelien.charbon@ext.bull.net>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./net/sunrpc/svcsock.c |   20 +++++++++++++++++---
 1 file changed, 17 insertions(+), 3 deletions(-)

diff .prev/net/sunrpc/svcsock.c ./net/sunrpc/svcsock.c
--- .prev/net/sunrpc/svcsock.c	2006-12-13 10:32:15.000000000 +1100
+++ ./net/sunrpc/svcsock.c	2006-12-13 10:32:17.000000000 +1100
@@ -926,6 +926,20 @@ svc_tcp_data_ready(struct sock *sk, int 
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
@@ -972,7 +986,7 @@ svc_tcp_accept(struct svc_sock *svsk)
 	 * hosts here, but when we get encryption, the IP of the host won't
 	 * tell us anything.  For now just warn about unpriv connections.
 	 */
-	if (ntohs(sin.sin_port) >= 1024) {
+	if (!svc_port_is_privileged((struct sockaddr *) &sin)) {
 		dprintk(KERN_WARNING
 			"%s: connect from unprivileged port: %s\n",
 			serv->sv_name,
@@ -1313,7 +1327,6 @@ int
 svc_recv(struct svc_rqst *rqstp, long timeout)
 {
 	struct svc_sock		*svsk = NULL;
-	struct sockaddr_in	*sin = svc_addr_in(rqstp);
 	struct svc_serv		*serv = rqstp->rq_server;
 	struct svc_pool		*pool = rqstp->rq_pool;
 	int			len, i;
@@ -1408,7 +1421,8 @@ svc_recv(struct svc_rqst *rqstp, long ti
 	svsk->sk_lastrecv = get_seconds();
 	clear_bit(SK_OLD, &svsk->sk_flags);
 
-	rqstp->rq_secure = ntohs(sin->sin_port) < 1024;
+	rqstp->rq_secure =
+		svc_port_is_privileged(svc_addr(rqstp));
 	rqstp->rq_chandle.defer = svc_defer;
 
 	if (serv->sv_stats)

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
