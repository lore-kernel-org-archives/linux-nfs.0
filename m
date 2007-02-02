From: NeilBrown <neilb@suse.de>
Subject: [PATCH 005 of 14] knfsd: SUNRPC: Don't set msg_name and msg_namelen when calling sock_recvmsg
Date: Fri, 2 Feb 2007 15:40:02 +1100
Message-ID: <1070202044002.19010@suse.de>
References: <20070202153531.18622.patches@notabene>
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@osdl.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1422933AbXBBElY@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>


From: Chuck Lever <chuck.lever@oracle.com>
Clean-up: msg_name and msg_namelen are not used by sock_recvmsg, so
don't bother to set them in svc_recvfrom.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./net/sunrpc/svcsock.c |   22 +++++++---------------
 1 file changed, 7 insertions(+), 15 deletions(-)

diff .prev/net/sunrpc/svcsock.c ./net/sunrpc/svcsock.c
--- .prev/net/sunrpc/svcsock.c	2007-02-02 15:21:55.000000000 +1100
+++ ./net/sunrpc/svcsock.c	2007-02-02 15:22:22.000000000 +1100
@@ -561,21 +561,13 @@ static int
 svc_recvfrom(struct svc_rqst *rqstp, struct kvec *iov, int nr, int buflen)
 {
 	struct svc_sock *svsk = rqstp->rq_sock;
-	struct msghdr	msg;
-	struct socket	*sock;
-	int		len;
-
-	rqstp->rq_addrlen = sizeof(rqstp->rq_addr);
-	sock = svsk->sk_sock;
-
-	msg.msg_name    = &rqstp->rq_addr;
-	msg.msg_namelen = sizeof(rqstp->rq_addr);
-	msg.msg_control = NULL;
-	msg.msg_controllen = 0;
-
-	msg.msg_flags	= MSG_DONTWAIT;
+	struct msghdr msg = {
+		.msg_flags	= MSG_DONTWAIT,
+	};
+	int len;
 
-	len = kernel_recvmsg(sock, &msg, iov, nr, buflen, MSG_DONTWAIT);
+	len = kernel_recvmsg(svsk->sk_sock, &msg, iov, nr, buflen,
+				msg.msg_flags);
 
 	/* sock_recvmsg doesn't fill in the name/namelen, so we must..
 	 */
@@ -583,7 +575,7 @@ svc_recvfrom(struct svc_rqst *rqstp, str
 	rqstp->rq_addrlen = svsk->sk_remotelen;
 
 	dprintk("svc: socket %p recvfrom(%p, %Zu) = %d\n",
-		rqstp->rq_sock, iov[0].iov_base, iov[0].iov_len, len);
+		svsk, iov[0].iov_base, iov[0].iov_len, len);
 
 	return len;
 }
