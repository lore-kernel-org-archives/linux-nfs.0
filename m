From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] sunrpc: fix typo in svc_udp_recvfrom
Date: Tue, 27 Mar 2007 11:10:07 -0400
Message-ID: <1175008207.6153.12.camel@heimdal.trondhjem.org>
References: <200703271651.13181.olaf.kirch@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net
To: Olaf Kirch <olaf.kirch@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HWDJR-0004Rq-C8
	for nfs@lists.sourceforge.net; Tue, 27 Mar 2007 08:10:17 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1+7kiqFPIPKyGod9QSYuuP6PcCdNIPnKoA=])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HWDJS-0006y4-52
	for nfs@lists.sourceforge.net; Tue, 27 Mar 2007 08:10:19 -0700
In-Reply-To: <200703271651.13181.olaf.kirch@oracle.com>
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

On Tue, 2007-03-27 at 16:51 +0200, Olaf Kirch wrote:
> I'm not sure whether this has been brought up already - I came
> across this today when poking around the code...
> 
> Olaf
> 
> --[ cut here ]--
> Fix a typo in svc_udp_recvfrom
> 
> This patch corrects a small and hamless typo in svc_udp_recvfrom.
> 
> Signed-off-by: olaf.kirch@oracle.com
> ---
>  net/sunrpc/svcsock.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> Index: linux-2.6/net/sunrpc/svcsock.c
> ===================================================================
> --- linux-2.6.orig/net/sunrpc/svcsock.c
> +++ linux-2.6/net/sunrpc/svcsock.c
> @@ -779,7 +779,7 @@ svc_udp_recvfrom(struct svc_rqst *rqstp)
>  	}
>  
>  	clear_bit(SK_DATA, &svsk->sk_flags);
> -	while ((err == kernel_recvmsg(svsk->sk_sock, &msg, NULL,
> +	while ((err = kernel_recvmsg(svsk->sk_sock, &msg, NULL,
>  				      0, 0, MSG_PEEK | MSG_DONTWAIT)) < 0 ||
>  	       (skb = skb_recv_datagram(svsk->sk_sk, 0, 1, &err)) == NULL) {
>  		if (err == -EAGAIN) {

Could you please rather move those assignments out of the while()? Good
coding style dictates that the above should be avoided. One of the
benefits is precisely to avoid the above ambiguities.

Something like

	for (;;) {
		err = kernel_recvmsg(svsk->sk_sock, &msg, NULL, 0, 0, MSG_PEEK|MSG_DONTWAIT);
		if (err == 0) {
			skb = skb_recv_datagram(svsk->sk_sk, 0, 1, &err);
			if (skb != NULL)
				break;
		}
		if (err == -EAGAIN) {
			svc_sock_received(svsk);
			return err;
		}
		/* possibly an icmp error */
		dprintk("svc: recvfrom returned error %d\n", -err);
	}

Cheers,
  Trond


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
