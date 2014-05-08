Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:35908 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754882AbaEHQsf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 May 2014 12:48:35 -0400
Date: Thu, 8 May 2014 12:48:34 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] SUNRPC: Fix printk that is not only for nfsd
Message-ID: <20140508164834.GE20976@fieldses.org>
References: <534CF854.30100@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <534CF854.30100@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks, applying.  By the way, your mail client seems to be corrupting
patches, e.g.:

On Tue, Apr 15, 2014 at 05:13:56PM +0800, Kinglong Mee wrote:
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  net/sunrpc/cache.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
> index ae333c1..0663621 100644
> --- a/net/sunrpc/cache.c
> +++ b/net/sunrpc/cache.c
> @@ -374,7 +374,7 @@ void sunrpc_destroy_cache_detail(struct cache_detail
> *cd)

... it wrapped that line.  So git-am complains and I have to fix up
things by hand.

Might check Documentation/email-clients.txt to see if there's any useful
tips there.

--b.

>  	}
>  	return;
>  out:
> -	printk(KERN_ERR "nfsd: failed to unregister %s cache\n", cd->name);
> +	printk(KERN_ERR "RPC: failed to unregister %s cache\n", cd->name);
>  }
>  EXPORT_SYMBOL_GPL(sunrpc_destroy_cache_detail);
> 
> -- 
> 1.9.0
> 
