Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:50274 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751302AbbINQG7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Sep 2015 12:06:59 -0400
Date: Mon, 14 Sep 2015 12:06:57 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Julia Lawall <Julia.Lawall@lip6.fr>
Cc: sergey.senozhatsky@gmail.com, kernel-janitors@vger.kernel.org,
        Jeff Layton <jlayton@poochiereds.net>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH 22/39] nfsd: drop null test before destroy functions
Message-ID: <20150914160657.GA5338@fieldses.org>
References: <1442146532-9100-1-git-send-email-Julia.Lawall@lip6.fr>
 <1442146532-9100-23-git-send-email-Julia.Lawall@lip6.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1442146532-9100-23-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks, applying.--b.

On Sun, Sep 13, 2015 at 02:15:15PM +0200, Julia Lawall wrote:
> Remove unneeded NULL test.
> 
> The semantic patch that makes this change is as follows:
> (http://coccinelle.lip6.fr/)
> 
> // <smpl>
> @@ expression x; @@
> -if (x != NULL) {
>   \(kmem_cache_destroy\|mempool_destroy\|dma_pool_destroy\)(x);
>   x = NULL;
> -}
> // </smpl>
> 
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>
> 
> ---
>  fs/nfsd/nfscache.c |    6 ++----
>  1 file changed, 2 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
> index 46ec934..116940c 100644
> --- a/fs/nfsd/nfscache.c
> +++ b/fs/nfsd/nfscache.c
> @@ -217,10 +217,8 @@ void nfsd_reply_cache_shutdown(void)
>  	drc_hashtbl = NULL;
>  	drc_hashsize = 0;
>  
> -	if (drc_slab) {
> -		kmem_cache_destroy(drc_slab);
> -		drc_slab = NULL;
> -	}
> +	kmem_cache_destroy(drc_slab);
> +	drc_slab = NULL;
>  }
>  
>  /*
