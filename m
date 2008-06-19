From: Olga Kornievskaia <aglo@citi.umich.edu>
Subject: [PATCH] NFSD: fix use of setsockopt
Date: Thu, 19 Jun 2008 09:33:39 -0400
Message-ID: <485A6033.3090301@citi.umich.edu>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030208010303000304010402"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.211.133.111]:1611 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752960AbYFSNdl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 Jun 2008 09:33:41 -0400
Received: from yoga.citi.umich.edu (yoga.citi.umich.edu [141.211.133.26])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(Client CN "aglo", Issuer "CITI Production KCA" (verified OK))
	by citi.umich.edu (Postfix) with ESMTP id 666D642AE
	for <linux-nfs@vger.kernel.org>; Thu, 19 Jun 2008 09:33:40 -0400 (EDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.
--------------030208010303000304010402
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

The following patch fixes NFS server's use of setsockopt. For this 
function to take an effect it first needs be called after socket 
creation but before sock binding.

This patch also changes the size of the receive sock buffer to be same 
as the send sock buffer. Both buffers are now a multiple of maxpayload 
and number of nfsd threads.

This patch fixes the problem that receive window never opens beyond the 
default TCP receive window size set by the 2nd parameter of the 
net.ipv4.tcp_rmem sysctl.

Signed-off-by: Olga Kornievskaia <aglo@citi.umich.edu>

--------------030208010303000304010402
Content-Type: text/x-patch;
 name="nfsd-fix-sockopt-7.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="nfsd-fix-sockopt-7.patch"

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index c75bffe..178b397 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1191,7 +1191,7 @@ svc_tcp_recvfrom(struct svc_rqst *rqstp)
 		 */
 		svc_sock_setbufsize(svsk->sk_sock,
 				    (serv->sv_nrthreads+3) * serv->sv_max_mesg,
-				    3 * serv->sv_max_mesg);
+				    (serv->sv_nrthreads+3) * serv->sv_max_mesg);
 
 	clear_bit(SK_DATA, &svsk->sk_flags);
 
@@ -1372,11 +1372,6 @@ svc_tcp_init(struct svc_sock *svsk)
 		 * receive and respond to one request.
 		 * svc_tcp_recvfrom will re-adjust if necessary
 		 */
-		svc_sock_setbufsize(svsk->sk_sock,
-				    3 * svsk->sk_server->sv_max_mesg,
-				    3 * svsk->sk_server->sv_max_mesg);
-
-		set_bit(SK_CHNGBUF, &svsk->sk_flags);
 		set_bit(SK_DATA, &svsk->sk_flags);
 		if (sk->sk_state != TCP_ESTABLISHED)
 			set_bit(SK_CLOSE, &svsk->sk_flags);
@@ -1761,6 +1756,8 @@ static int svc_create_socket(struct svc_serv *serv, int protocol,
 
 	if (type == SOCK_STREAM)
 		sock->sk->sk_reuse = 1;		/* allow address reuse */
+	svc_sock_setbufsize(sock, (serv->sv_nrthreads+3) * serv->sv_max_mesg,
+				(serv->sv_nrthreads+3) * serv->sv_max_mesg);
 	error = kernel_bind(sock, sin, len);
 	if (error < 0)
 		goto bummer;

--------------030208010303000304010402--
