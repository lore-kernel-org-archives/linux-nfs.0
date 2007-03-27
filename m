From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH - try #2] sunrpc: fix typo in svc_udp_recvfrom
Date: Tue, 27 Mar 2007 12:07:50 -0400
Message-ID: <1175011670.6153.27.camel@heimdal.trondhjem.org>
References: <200703271651.13181.olaf.kirch@oracle.com>
	<1175008207.6153.12.camel@heimdal.trondhjem.org>
	<200703271739.43675.olaf.kirch@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net
To: Olaf Kirch <olaf.kirch@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HWEDM-0002sQ-Lc
	for nfs@lists.sourceforge.net; Tue, 27 Mar 2007 09:08:05 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX18DtgUNT7fktoMLnpSqOUwAg2UsMegdo8A=])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HWEDN-0004MK-ER
	for nfs@lists.sourceforge.net; Tue, 27 Mar 2007 09:08:07 -0700
In-Reply-To: <200703271739.43675.olaf.kirch@oracle.com>
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

On Tue, 2007-03-27 at 17:39 +0200, Olaf Kirch wrote:
> On Tuesday 27 March 2007 17:10, Trond Myklebust wrote:
> > Could you please rather move those assignments out of the while()? Good
> > coding style dictates that the above should be avoided. One of the
> > benefits is precisely to avoid the above ambiguities.
> 
> Okay, here we go:
> ----------------------
> Fix a typo in svc_udp_recvfrom
> 
> This patch corrects a small and harmless typo in svc_udp_recvfrom.
> 
> Signed-off-by: olaf.kirch@oracle.com
> ---
>  net/sunrpc/svcsock.c |   11 ++++++++---
>  1 file changed, 8 insertions(+), 3 deletions(-)
> 
> Index: linux-2.6/net/sunrpc/svcsock.c
> ===================================================================
> --- linux-2.6.orig/net/sunrpc/svcsock.c
> +++ linux-2.6/net/sunrpc/svcsock.c
> @@ -779,9 +779,14 @@ svc_udp_recvfrom(struct svc_rqst *rqstp)
>  	}
>  
>  	clear_bit(SK_DATA, &svsk->sk_flags);
> -	while ((err == kernel_recvmsg(svsk->sk_sock, &msg, NULL,
> -				      0, 0, MSG_PEEK | MSG_DONTWAIT)) < 0 ||
> -	       (skb = skb_recv_datagram(svsk->sk_sk, 0, 1, &err)) == NULL) {
> +	while (1) {
> +		err = kernel_recvmsg(svsk->sk_sock, &msg, NULL,
> +				      0, 0, MSG_PEEK | MSG_DONTWAIT);
> +		if (err >= 0) {
> +		       	skb = skb_recv_datagram(svsk->sk_sk, 0, 1, &err);
> +			if (skb)
> +				break;
> +		}
>  		if (err == -EAGAIN) {
>  			svc_sock_received(svsk);
>  			return err;
> 

Thanks! That looks good to me.

  Trond


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
