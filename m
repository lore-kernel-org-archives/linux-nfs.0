From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] sunrpc: Use helper to set v4 mapped addr in
 ip_map_parse
Date: Mon, 11 Oct 2010 20:02:17 -0400
Message-ID: <20101012000217.GD16442@fieldses.org>
References: <4CAB56C2.3080801@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
To: Pavel Emelyanov <xemul@parallels.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:58175 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754937Ab0JLACS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 Oct 2010 20:02:18 -0400
In-Reply-To: <4CAB56C2.3080801@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 05, 2010 at 08:48:02PM +0400, Pavel Emelyanov wrote:
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Thanks, applying.

(Assuming someone else is testing for ipv6 regressions, though--I don't
have a setup for it currently.)

--b.

> ---
>  net/sunrpc/svcauth_unix.c |    5 ++---
>  1 files changed, 2 insertions(+), 3 deletions(-)
> 
> diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
> index 8b378f9..560677d 100644
> --- a/net/sunrpc/svcauth_unix.c
> +++ b/net/sunrpc/svcauth_unix.c
> @@ -220,10 +220,9 @@ static int ip_map_parse(struct cache_detail *cd,
>  	switch (address.sa.sa_family) {
>  	case AF_INET:
>  		/* Form a mapped IPv4 address in sin6 */
> -		memset(&sin6, 0, sizeof(sin6));
>  		sin6.sin6_family = AF_INET6;
> -		sin6.sin6_addr.s6_addr32[2] = htonl(0xffff);
> -		sin6.sin6_addr.s6_addr32[3] = address.s4.sin_addr.s_addr;
> +		ipv6_addr_set_v4mapped(address.s4.sin_addr.s_addr,
> +				&sin6.sin6_addr);
>  		break;
>  #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
>  	case AF_INET6:
> -- 
> 1.5.5.6
> 
