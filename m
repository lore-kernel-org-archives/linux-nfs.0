From: NeilBrown <neilb@suse.de>
Subject: [PATCH 004 of 14] knfsd: SUNRPC: Don't set msg_name and
	msg_namelen when calling sock_recvmsg
Date: Wed, 13 Dec 2006 10:58:55 +1100
Message-ID: <1061212235855.21396@suse.de>
References: <20061213105528.21128.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GuHWB-0002RX-Ha
	for nfs@lists.sourceforge.net; Tue, 12 Dec 2006 15:58:39 -0800
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GuHWC-0006Pw-D4
	for nfs@lists.sourceforge.net; Tue, 12 Dec 2006 15:58:41 -0800
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
Clean-up: msg_name and msg_namelen are not used by sock_recvmsg, so
don't bother to set them in svc_recvfrom.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./net/sunrpc/svcsock.c |   23 ++++++++---------------
 1 file changed, 8 insertions(+), 15 deletions(-)

diff .prev/net/sunrpc/svcsock.c ./net/sunrpc/svcsock.c
--- .prev/net/sunrpc/svcsock.c	2006-12-13 10:29:13.000000000 +1100
+++ ./net/sunrpc/svcsock.c	2006-12-13 10:29:15.000000000 +1100
@@ -560,21 +560,14 @@ svc_recv_available(struct svc_sock *svsk
 static int
 svc_recvfrom(struct svc_rqst *rqstp, struct kvec *iov, int nr, int buflen)
 {
-	struct msghdr	msg;
-	struct socket	*sock;
-	int		len, alen;
-
-	rqstp->rq_addrlen = sizeof(rqstp->rq_addr);
-	sock = rqstp->rq_sock->sk_sock;
-
-	msg.msg_name    = &rqstp->rq_addr;
-	msg.msg_namelen = sizeof(rqstp->rq_addr);
-	msg.msg_control = NULL;
-	msg.msg_controllen = 0;
-
-	msg.msg_flags	= MSG_DONTWAIT;
+	struct svc_sock	*svsk = rqstp->rq_sock;
+	struct msghdr msg = {
+		.msg_flags	= MSG_DONTWAIT,
+	};
+	int len;
 
-	len = kernel_recvmsg(sock, &msg, iov, nr, buflen, MSG_DONTWAIT);
+	len = kernel_recvmsg(svsk->sk_sock, &msg, iov, nr, buflen,
+				msg.msg_flags);
 
 	/* sock_recvmsg doesn't fill in the name/namelen, so we must..
 	 */
@@ -582,7 +575,7 @@ svc_recvfrom(struct svc_rqst *rqstp, str
 	rqstp->rq_addrlen = svsk->sk_remotelen;
 
 	dprintk("svc: socket %p recvfrom(%p, %Zu) = %d\n",
-		rqstp->rq_sock, iov[0].iov_base, iov[0].iov_len, len);
+		svsk, iov[0].iov_base, iov[0].iov_len, len);
 
 	return len;
 }

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
