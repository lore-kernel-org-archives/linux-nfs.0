Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:34620 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756060Ab3C1N6e convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Mar 2013 09:58:34 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: chaoting fan <tingchaofan@gmail.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] sunrpc: the cache_detail in cache_is_valid is unused
 any more
Date: Thu, 28 Mar 2013 13:58:32 +0000
Message-ID: <1364479112.11160.0.camel@leira.trondhjem.org>
References: <CAK1jPnLSFxLwSbe14mMbrois6bwFzbG_Q1kudBuNyywj70s7LA@mail.gmail.com>
In-Reply-To: <CAK1jPnLSFxLwSbe14mMbrois6bwFzbG_Q1kudBuNyywj70s7LA@mail.gmail.com>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2013-03-28 at 21:53 +0800, chaoting fan wrote:
> the cache_detail(*detail) in function cache_is_valid is unused any more,
> mark it to be unused to avoid make warning.
> 
> Signed-off-by: fanchaoting <fanchaoting@cn.fujitsu.com>
> 
> ---
>  net/sunrpc/cache.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
> index 9afa439..efea2d9 100644
> --- a/net/sunrpc/cache.c
> +++ b/net/sunrpc/cache.c
> @@ -201,7 +201,7 @@ static int cache_make_upcall(struct cache_detail
> *cd, struct cache_head *h)
>  	return cd->cache_upcall(cd, h);
>  }
> 
> -static inline int cache_is_valid(struct cache_detail *detail, struct
> cache_head *h)
> +static inline int cache_is_valid(struct cache_detail *unused, struct
> cache_head *h)
>  {
>  	if (!test_bit(CACHE_VALID, &h->flags))
>  		return -EAGAIN;
> -- 1.7.10.4

Why not just remove it altogether? There are only 3 callers.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
