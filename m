Return-Path: linux-nfs-owner@vger.kernel.org
Received: from order.stressinduktion.org ([87.106.68.36]:44329 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752571Ab3LUMom (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 21 Dec 2013 07:44:42 -0500
Date: Sat, 21 Dec 2013 13:44:40 +0100
From: Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Alexander Aring <alex.aring@gmail.com>
Cc: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org, werner@almesberger.net
Subject: Re: [PATCH] nfs: fix dead code of ipv6_addr_scope
Message-ID: <20131221124440.GG14073@order.stressinduktion.org>
References: <1387600744-11366-1-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <1387600744-11366-1-git-send-email-alex.aring@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Dec 21, 2013 at 05:39:04AM +0100, Alexander Aring wrote:
> The correct way to check on IPV6_ADDR_SCOPE_LINKLOCAL is to check with
> the ipv6_addr_src_scope function.
> 
> Currently this can't be work, because ipv6_addr_scope returns a int with
> a mask of IPV6_ADDR_SCOPE_MASK (0x00f0U) and IPV6_ADDR_SCOPE_LINKLOCAL
> is 0x02. So the condition is always false.
> 
> Signed-off-by: Alexander Aring <alex.aring@gmail.com>
> ---
> I think ipv6_addr_src_scope should be correct, can somebody from netdev ml
> confirm this please?
> I stumple over that and I did not compile and test it. Maybe this is something
> for stable?
> 
>  fs/nfs/nfs4filelayoutdev.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
> index c7c295e5..efac602 100644
> --- a/fs/nfs/nfs4filelayoutdev.c
> +++ b/fs/nfs/nfs4filelayoutdev.c
> @@ -95,7 +95,7 @@ same_sockaddr(struct sockaddr *addr1, struct sockaddr *addr2)
>  		b6 = (struct sockaddr_in6 *)addr2;
>  
>  		/* LINKLOCAL addresses must have matching scope_id */
> -		if (ipv6_addr_scope(&a6->sin6_addr) ==
> +		if (ipv6_addr_src_scope(&a6->sin6_addr) ==
>  		    IPV6_ADDR_SCOPE_LINKLOCAL &&
>  		    a6->sin6_scope_id != b6->sin6_scope_id)
>  			return false;

Good catch!

SCOPE_TYPE also can be compared and is no bitfield, so the patch is
good. Do you mind also proposing a patch for sctp?

Thanks,

  Hannes

