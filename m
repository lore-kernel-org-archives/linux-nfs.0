From: Dean Hildebrand <seattleplus@gmail.com>
Subject: Re: [PATCH] NFSD: fix use of setsockopt
Date: Tue, 24 Jun 2008 17:50:31 -0700
Message-ID: <48619657.1030705@gmail.com>
References: <485A6033.3090301@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org
To: Olga Kornievskaia <aglo@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.175]:53657 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752991AbYFYAuf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Jun 2008 20:50:35 -0400
Received: by wf-out-1314.google.com with SMTP id 27so2684965wfd.4
        for <linux-nfs@vger.kernel.org>; Tue, 24 Jun 2008 17:50:35 -0700 (PDT)
In-Reply-To: <485A6033.3090301@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Olga,

This makes sense, if NFSD is going to ignore global Linux TCP settings 
and 'go it alone', then it shouldn't be constrained by them.

At least now we can increase the rcv buffer size by increasing the 
number of NFSDs.  I would still like to pursue my sysctl patch for the 
rcv and snd buffer though since we have seen situations where too many 
NFSDs can increase the randomness of requests to the underlying file 
system, reducing the effectiveness readahead/write gathering.

Dean

Olga Kornievskaia wrote:
> The following patch fixes NFS server's use of setsockopt. For this 
> function to take an effect it first needs be called after socket 
> creation but before sock binding.
>
> This patch also changes the size of the receive sock buffer to be same 
> as the send sock buffer. Both buffers are now a multiple of maxpayload 
> and number of nfsd threads.
>
> This patch fixes the problem that receive window never opens beyond 
> the default TCP receive window size set by the 2nd parameter of the 
> net.ipv4.tcp_rmem sysctl.
>
> Signed-off-by: Olga Kornievskaia <aglo@citi.umich.edu>
Signed-off-by: Olga Kornievskaia <aglo@citi.umich.edu>

------------------------------------------------------------------------

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

