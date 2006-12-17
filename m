From: Ingo Oeser <ioe-lkml@rameria.de>
Subject: Re: [PATCH 009 of 14] knfsd: SUNRPC: teach svc_sendto() to
	deal with IPv6 addresses
Date: Sun, 17 Dec 2006 16:15:40 +0100
Message-ID: <200612171615.41972.ioe-lkml@rameria.de>
References: <20061213105528.21128.patches@notabene>
	<1061212235922.21469@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Andrew Morton <akpm@osdl.org>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gvxjy-00048J-DS
	for nfs@lists.sourceforge.net; Sun, 17 Dec 2006 07:15:50 -0800
Received: from smtprelay01.ispgateway.de ([80.67.18.13])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Gvxjz-00037d-E1
	for nfs@lists.sourceforge.net; Sun, 17 Dec 2006 07:15:51 -0800
To: NeilBrown <neilb@suse.de>
In-Reply-To: <1061212235922.21469@suse.de>
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

On Wednesday, 13. December 2006 00:59, NeilBrown wrote:
> diff .prev/net/sunrpc/svcsock.c ./net/sunrpc/svcsock.c
> --- .prev/net/sunrpc/svcsock.c	2006-12-13 10:31:39.000000000 +1100
> +++ ./net/sunrpc/svcsock.c	2006-12-13 10:32:15.000000000 +1100
> @@ -438,6 +439,47 @@ svc_wake_up(struct svc_serv *serv)
>  	}
>  }
>  
> +union svc_pktinfo_u {
> +	struct in_pktinfo pkti;
> +#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
> +	struct in6_pktinfo pkti6;
> +#endif
> +};
> +
> +static void svc_set_cmsg_data(struct svc_rqst *rqstp, struct cmsghdr *cmh)
> +{
> +	switch (rqstp->rq_sock->sk_sk->sk_family) {
> +	case AF_INET:
> +		do {
> +			struct in_pktinfo *pki =
> +					(struct in_pktinfo *) CMSG_DATA(cmh);

			struct in_pktinfo *pki = CMSG_DATA(cmh);

Ugly casting not needed here, since CMSG_DATA should return "void *",
which can be casted to any pointer.

> +
> +			cmh->cmsg_level = SOL_IP;
> +			cmh->cmsg_type = IP_PKTINFO;
> +			pki->ipi_ifindex = 0;
> +			pki->ipi_spec_dst.s_addr = rqstp->rq_daddr.addr.s_addr;
> +			cmh->cmsg_len = CMSG_LEN(sizeof(*pki));
> +		} while (0);
> +		break;
> +#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
> +	case AF_INET6:
> +		do {
> +			struct in6_pktinfo *pki =
> +					(struct in6_pktinfo *) CMSG_DATA(cmh);
> +

No casting needed, so:

			struct in6_pktinfo *pki = CMSG_DATA(cmh);


Regards

Ingo Oeser

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
