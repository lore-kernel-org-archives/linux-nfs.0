From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 04/13] SUNRPC: Don't set msg_name and msg_namelen when
	calling sock_recvmsg
Date: Thu, 18 Jan 2007 18:50:32 -0500
Message-ID: <20070118235032.24266.21720.stgit@localhost.localdomain>
References: <20070118234855.24266.37463.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H7h1j-000558-1i
	for nfs@lists.sourceforge.net; Thu, 18 Jan 2007 15:50:39 -0800
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1H7h1k-00017h-Md
	for nfs@lists.sourceforge.net; Thu, 18 Jan 2007 15:50:40 -0800
To: neilb@suse.de
In-Reply-To: <20070118234855.24266.37463.stgit@localhost.localdomain>
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

Clean-up: msg_name and msg_namelen are not used by sock_recvmsg, so
don't bother to set them in svc_recvfrom.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/svcsock.c |   22 +++++++---------------
 1 files changed, 7 insertions(+), 15 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 747fc5b..4bebb4d 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
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

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
