From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH resend] net/sunrpc: Remove uses of NIPQUAD, use %pI4
Date: Mon, 08 Mar 2010 10:46:56 -0500
Message-ID: <4B951BF0.9050403@oracle.com>
References: <1267857980.849.22.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	linux-nfs <linux-nfs@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:34193 "EHLO
	rcsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753861Ab0CHPsd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Mar 2010 10:48:33 -0500
In-Reply-To: <1267857980.849.22.camel-AkRN8/LKpobuYGix6ZUp1Q@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/06/2010 01:46 AM, Joe Perches wrote:
> Originally submitted Jan 1, 2010
> http://patchwork.kernel.org/patch/71221/
>
> Convert NIPQUAD to the %pI4 format extension where possible
> Convert %02x%02x%02x%02x/NIPQUAD to %08x/ntohl
>
> Signed-off-by: Joe Perches<joe@perches.com>
> ---
>   net/sunrpc/xprtrdma/transport.c |    3 +--
>   net/sunrpc/xprtsock.c           |    5 ++---
>   2 files changed, 3 insertions(+), 5 deletions(-)
>
> diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
> index 7018eef..83d339f 100644
> --- a/net/sunrpc/xprtrdma/transport.c
> +++ b/net/sunrpc/xprtrdma/transport.c
> @@ -165,8 +165,7 @@ xprt_rdma_format_addresses(struct rpc_xprt *xprt)
>
>   	xprt->address_strings[RPC_DISPLAY_PROTO] = "rdma";
>
> -	(void)snprintf(buf, sizeof(buf), "%02x%02x%02x%02x",
> -				NIPQUAD(sin->sin_addr.s_addr));
> +	(void)snprintf(buf, sizeof(buf), "%08x", ntohl(sin->sin_addr.s_addr));
>   	xprt->address_strings[RPC_DISPLAY_HEX_ADDR] = kstrdup(buf, GFP_KERNEL);
>
>   	(void)snprintf(buf, sizeof(buf), "%4hx", rpc_get_port(sap));
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index 3d739e5..86234bc 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -297,12 +297,11 @@ static void xs_format_common_peer_addresses(struct rpc_xprt *xprt)
>   	switch (sap->sa_family) {
>   	case AF_INET:
>   		sin = xs_addr_in(xprt);
> -		(void)snprintf(buf, sizeof(buf), "%02x%02x%02x%02x",
> -					NIPQUAD(sin->sin_addr.s_addr));
> +		snprintf(buf, sizeof(buf), "%08x", ntohl(sin->sin_addr.s_addr));
>   		break;
>   	case AF_INET6:
>   		sin6 = xs_addr_in6(xprt);
> -		(void)snprintf(buf, sizeof(buf), "%pi6",&sin6->sin6_addr);
> +		snprintf(buf, sizeof(buf), "%pi6",&sin6->sin6_addr);

Why remove the (void) here, but not in xprtrdma/transport.c?  IMO the 
(void) cast should be left in place at all three call sites.

>   		break;
>   	default:
>   		BUG();
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


-- 
chuck[dot]lever[at]oracle[dot]com
