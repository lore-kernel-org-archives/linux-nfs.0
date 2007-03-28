From: Olaf Kirch <olaf.kirch@oracle.com>
Subject: Re: [PATCH - try #2] sunrpc: fix typo in svc_udp_recvfrom
Date: Wed, 28 Mar 2007 07:51:21 +0200
Message-ID: <200703280751.22646.olaf.kirch@oracle.com>
References: <200703271651.13181.olaf.kirch@oracle.com>
	<200703271739.43675.olaf.kirch@oracle.com>
	<17929.53216.475068.190958@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net,
	Trond Myklebust <trond.myklebust@fys.uio.no>
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HWR5X-00031H-W3
	for nfs@lists.sourceforge.net; Tue, 27 Mar 2007 22:52:52 -0700
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HWR5X-0006LU-3V
	for nfs@lists.sourceforge.net; Tue, 27 Mar 2007 22:52:54 -0700
In-Reply-To: <17929.53216.475068.190958@notabene.brown>
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

Hi Neil,

On Wednesday 28 March 2007 04:16, Neil Brown wrote:
> What about this (on top of current -mm).

Well, you just converted a while loop to an if. The old
code would pull any ICMP signalled error condition out
of the socket, and then try to get the data. The new
code will return if it hits an ICMP error, without
reasserting SK_DATA. Any pending UDP request will
be stuck until the client retransmits.

So I think you really need the loop here.

Olaf

> 
> Signed-off-by: Neil Brown <neilb@suse.de>
> 
> ### Diffstat output
>  ./net/sunrpc/svcsock.c |   21 +++++++++++++--------
>  1 file changed, 13 insertions(+), 8 deletions(-)
> 
> diff .prev/net/sunrpc/svcsock.c ./net/sunrpc/svcsock.c
> --- .prev/net/sunrpc/svcsock.c	2007-03-28 12:06:59.000000000 +1000
> +++ ./net/sunrpc/svcsock.c	2007-03-28 12:12:50.000000000 +1000
> @@ -779,15 +779,20 @@ svc_udp_recvfrom(struct svc_rqst *rqstp)
>  	}
>  
>  	clear_bit(SK_DATA, &svsk->sk_flags);
> -	while ((err = kernel_recvmsg(svsk->sk_sock, &msg, NULL,
> -				     0, 0, MSG_PEEK | MSG_DONTWAIT)) < 0 ||
> -	       (skb = skb_recv_datagram(svsk->sk_sk, 0, 1, &err)) == NULL) {
> -		if (err == -EAGAIN) {
> -			svc_sock_received(svsk);
> -			return err;
> +	skb = NULL;
> +	err = kernel_recvmsg(svsk->sk_sock, &msg, NULL,
> +			     0, 0, MSG_PEEK | MSG_DONTWAIT);
> +	if (err >= 0)
> +		skb = skb_recv_datagram(svsk->sk_sk, 0, 1, &err);
> +
> +	if (skb == NULL) {
> +		if (err != -EAGAIN) {
> +			/* possibly an icmp error */
> +			dprintk("svc: recvfrom returned error %d\n", -err);
> +			set_bit(SK_DATA, &svsk->sk_flags);
>  		}
> -		/* possibly an icmp error */
> -		dprintk("svc: recvfrom returned error %d\n", -err);
> +		svc_sock_received(svsk);
> +		return -EAGAIN;
>  	}
>  	rqstp->rq_addrlen = sizeof(rqstp->rq_addr);
>  	if (skb->tstamp.off_sec == 0) {
> 

-- 
Olaf Kirch  |  --- o --- Nous sommes du soleil we love when we play
okir@lst.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
