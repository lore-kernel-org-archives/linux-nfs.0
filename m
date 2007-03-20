From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [2.6.21 patch] net/sunrpc/svcsock.c: fix a check
Date: Mon, 19 Mar 2007 23:38:37 -0800
Message-ID: <20070319233837.38f1aab7.akpm@linux-foundation.org>
References: <20070319093341.GS752@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
To: Adrian Bunk <bunk@stusta.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HTYvW-0005ho-TY
	for nfs@lists.sourceforge.net; Tue, 20 Mar 2007 00:38:39 -0700
Received: from smtp.osdl.org ([65.172.181.24])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HTYvX-0007Sd-UX
	for nfs@lists.sourceforge.net; Tue, 20 Mar 2007 00:38:41 -0700
In-Reply-To: <20070319093341.GS752@stusta.de>
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

On Mon, 19 Mar 2007 10:33:42 +0100 Adrian Bunk <bunk@stusta.de> wrote:

> The return value of kernel_recvmsg() should be assigned to "err", not 
> compared with the random value of a never initialized "err"
> (and the "< 0" check wrongly always returned false since == comparisons 
> never have a result < 0).
> 
> Spotted by the Coverity checker.
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>
> 
> ---
> --- linux-2.6.21-rc3-mm2/net/sunrpc/svcsock.c.old	2007-03-19 09:44:40.000000000 +0100
> +++ linux-2.6.21-rc3-mm2/net/sunrpc/svcsock.c	2007-03-19 09:45:18.000000000 +0100
> @@ -779,8 +779,8 @@ svc_udp_recvfrom(struct svc_rqst *rqstp)
>  	}
>  
>  	clear_bit(SK_DATA, &svsk->sk_flags);
> -	while ((err == kernel_recvmsg(svsk->sk_sock, &msg, NULL,
> -				      0, 0, MSG_PEEK | MSG_DONTWAIT)) < 0 ||
> +	while ((err = kernel_recvmsg(svsk->sk_sock, &msg, NULL,
> +				     0, 0, MSG_PEEK | MSG_DONTWAIT)) < 0 ||
>  	       (skb = skb_recv_datagram(svsk->sk_sk, 0, 1, &err)) == NULL) {
>  		if (err == -EAGAIN) {
>  			svc_sock_received(svsk);

Cute.  The compiler must have decided to apply the "(a==b) can never be
less than zero" optimisation before performing uninitialised variable
analysis.

Neil, this one needs runtime testing before we can apply it to 2.6.21, I
think.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
