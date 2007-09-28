From: Neil Brown <neilb@suse.de>
Subject: Re: [RFC,
	PATCH 09/33] svc: Add a transport function that checks for write
	space
Date: Fri, 28 Sep 2007 13:03:46 +1000
Message-ID: <18172.28434.751796.240775@notabene.brown>
References: <20070927045751.12677.98896.stgit@dell3.ogc.int>
	<20070927050153.12677.18487.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, gnb@sgi.com
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Ib68r-00070Q-LE
	for nfs@lists.sourceforge.net; Thu, 27 Sep 2007 20:03:50 -0700
Received: from ns1.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Ib68w-0005uF-62
	for nfs@lists.sourceforge.net; Thu, 27 Sep 2007 20:03:54 -0700
In-Reply-To: message from Tom Tucker on Thursday September 27
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Thursday September 27, tom@opengridcomputing.com wrote:
> @@ -898,6 +900,25 @@ svc_udp_prep_reply_hdr(struct svc_rqst *
>  {
>  }
>  
> +static int
> +svc_udp_has_wspace(struct svc_xprt *xprt)
> +{
> +	struct svc_sock *svsk = (struct svc_sock*)xprt;
> +	struct svc_serv	*serv = svsk->sk_server;
> +	int required;
> +
> +	/*
> +	 * Set the SOCK_NOSPACE flag before checking the available
> +	 * sock space.
> +	 */
> +	set_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
> +	required = atomic_read(&svsk->sk_reserved) + serv->sv_max_mesg;
> +	if (required*2 > sock_wspace(svsk->sk_sk))
> +		return 0;
> +	clear_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
> +	return 1;
> +}
> +
>  static struct svc_xprt_ops svc_udp_ops = {
>  	.xpo_recvfrom = svc_udp_recvfrom,
>  	.xpo_sendto = svc_udp_sendto,
> @@ -1368,6 +1390,25 @@ svc_tcp_prep_reply_hdr(struct svc_rqst *
>  	svc_putnl(resv, 0);
>  }
>  
> +static int
> +svc_tcp_has_wspace(struct svc_xprt *xprt)
> +{
> +	struct svc_sock *svsk = (struct svc_sock*)xprt;
> +	struct svc_serv	*serv = svsk->sk_server;
> +	int required;
> +
> +	/*
> +	 * Set the SOCK_NOSPACE flag before checking the available
> +	 * sock space.
> +	 */
> +	set_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
> +	required = atomic_read(&svsk->sk_reserved) + serv->sv_max_mesg;
> +	if (required*2 > sk_stream_wspace(svsk->sk_sk))
> +		return 0;
> +	clear_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
> +	return 1;
> +}
> +
>  static struct svc_xprt_ops svc_tcp_ops = {
>  	.xpo_recvfrom = svc_tcp_recvfrom,
>  	.xpo_sendto = svc_tcp_sendto,

As these two functions are identical, could we just have one called
"svc_sock_has_wspace" or similar?

Makes maintenance a little easier.

NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
