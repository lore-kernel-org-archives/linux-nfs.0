From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: [PATCH] kNFSd - 4 of 4 - Make sure an early close on a nfs/tcp connection is handled properly.
Date: Wed, 18 Jun 2003 10:52:34 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16111.47058.510470.572613@gargle.gargle.HOWL>
References: <E19SQq4-0000XC-00@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19SR7h-0005bO-00
	for <nfs@lists.sourceforge.net>; Tue, 17 Jun 2003 17:48:25 -0700
Received: From notabene ([129.94.172.124] == notabene.cse.unsw.EDU.AU)
	(for <marcelo@conectiva.com.br>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Wed, 18 Jun 2003 10:48:01 +1000
To: Marcelo Tosatti <marcelo@conectiva.com.br>,
    nfs@lists.sourceforge.net
In-Reply-To: message from NeilBrown on Wednesday June 18
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Wednesday June 18, neilb@cse.unsw.edu.au wrote:
> +		if (sk->sk_state != TCP_ESTABLISHED) 
> +			set_bit(SK_CLOSE, &svsk->sk_flags);

Whoops.  sk_state is in 2.5. It is state in 2.4.  Please add following
patch.


diff ./net/sunrpc/svcsock.c~current~ ./net/sunrpc/svcsock.c
--- ./net/sunrpc/svcsock.c~current~	2003-06-18 10:19:20.000000000 +1000
+++ ./net/sunrpc/svcsock.c	2003-06-18 10:39:37.000000000 +1000
@@ -826,7 +826,7 @@ svc_tcp_recvfrom(struct svc_rqst *rqstp)
 			goto error;
 		svsk->sk_tcplen += len;
 		if (len < want) {
-			dprintk("svc: short recvfrom while reading record length (%d of %d)\n",
+			dprintk("svc: short recvfrom while reading record length (%d of %ld)\n",
 			        len, want);
 			svc_sock_received(svsk);
 			return -EAGAIN; /* record header not complete */
@@ -973,7 +973,7 @@ svc_tcp_init(struct svc_sock *svsk)
 				    3 * svsk->sk_server->sv_bufsz);
 
 		set_bit(SK_CHNGBUF, &svsk->sk_flags);
-		if (sk->sk_state != TCP_ESTABLISHED) 
+		if (sk->state != TCP_ESTABLISHED) 
 			set_bit(SK_CLOSE, &svsk->sk_flags);
 	}
 


-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
