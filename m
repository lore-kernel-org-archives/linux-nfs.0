From: Josef Sipek <jsipek@fsl.cs.sunysb.edu>
Subject: Re: [PATCH 013 of 14] knfsd: SUNRPC: support IPv6 addresses
	in RPC server's UDP receive path.
Date: Sun, 4 Feb 2007 23:49:55 -0500
Message-ID: <20070205044955.GB1193@filer.fsl.cs.sunysb.edu>
References: <20070202153531.18622.patches@notabene>
	<1070202044044.19169@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Andrew Morton <akpm@osdl.org>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
To: NeilBrown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HDvnl-0002vl-AF
	for nfs@lists.sourceforge.net; Sun, 04 Feb 2007 20:50:01 -0800
Received: from filer.fsl.cs.sunysb.edu ([130.245.126.2])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HDvnm-00012T-SZ
	for nfs@lists.sourceforge.net; Sun, 04 Feb 2007 20:50:03 -0800
In-Reply-To: <1070202044044.19169@suse.de>
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

On Fri, Feb 02, 2007 at 03:40:44PM +1100, NeilBrown wrote:
...
> diff .prev/net/sunrpc/svcsock.c ./net/sunrpc/svcsock.c
> --- .prev/net/sunrpc/svcsock.c	2007-02-02 15:22:40.000000000 +1100
> +++ ./net/sunrpc/svcsock.c	2007-02-02 15:22:58.000000000 +1100
> @@ -715,13 +715,55 @@ svc_write_space(struct sock *sk)
>  	}
>  }
>  
> +static void svc_udp_get_sender_address(struct svc_rqst *rqstp,
> +					struct sk_buff *skb)
> +{
> +	switch (rqstp->rq_sock->sk_sk->sk_family) {
> +	case AF_INET:
> +		/* this seems to come from net/ipv4/udp.c:udp_recvmsg */
> +		do {
> +			struct sockaddr_in *sin = svc_addr_in(rqstp);
> +
> +			sin->sin_family = AF_INET;
> +			sin->sin_port = skb->h.uh->source;
> +			sin->sin_addr.s_addr = skb->nh.iph->saddr;
> +			rqstp->rq_addrlen = sizeof(struct sockaddr_in);
> +			/* Remember which interface received this request */
> +			rqstp->rq_daddr.addr.s_addr = skb->nh.iph->daddr;
> +		} while (0);
> +		break;

Why the while(0) ?

> +#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
> +	case AF_INET6:
> +		/* this is derived from net/ipv6/udp.c:udpv6_recvmesg */
> +		do {
> +			struct sockaddr_in6 *sin6 = svc_addr_in6(rqstp);
> +
> +			sin6->sin6_family = AF_INET6;
> +			sin6->sin6_port = skb->h.uh->source;
> +			sin6->sin6_flowinfo = 0;
> +			sin6->sin6_scope_id = 0;
> +			if (ipv6_addr_type(&sin6->sin6_addr) &
> +							IPV6_ADDR_LINKLOCAL)
> +				sin6->sin6_scope_id = IP6CB(skb)->iif;
> +			ipv6_addr_copy(&sin6->sin6_addr,
> +							&skb->nh.ipv6h->saddr);
> +			rqstp->rq_addrlen = sizeof(struct sockaddr_in);
> +			/* Remember which interface received this request */
> +			ipv6_addr_copy(&rqstp->rq_daddr.addr6,
> +							&skb->nh.ipv6h->saddr);
> +		} while (0);
> +		break;

Ditto.

Josef "Jeff" Sipek.

-- 
You measure democracy by the freedom it gives its dissidents, not the
freedom it gives its assimilated conformists.
		- Abbie Hoffman

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
