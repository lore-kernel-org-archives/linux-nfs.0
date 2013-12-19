Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:46901 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753839Ab3LSSzQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 Dec 2013 13:55:16 -0500
Date: Thu, 19 Dec 2013 13:55:15 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: get rid of unused function definition
Message-ID: <20131219185515.GA6951@fieldses.org>
References: <52AE6A11.3020307@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <52AE6A11.3020307@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 16, 2013 at 10:48:49AM +0800, Kinglong Mee wrote:
> commit 557ce2646e775f6bda734dd92b10d4780874b9c7 
> "nfsd41: replace page based DRC with buffer based DRC"
> have remove unused nfsd4_set_statp, but miss the function definition.

Thanks, applying.  (May not actually get pushed out till the new year.)

--b.

> 
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  fs/nfsd/cache.h | 8 --------
>  1 file changed, 8 deletions(-)
> 
> diff --git a/fs/nfsd/cache.h b/fs/nfsd/cache.h
> index d5c5b3e..b582f9a 100644
> --- a/fs/nfsd/cache.h
> +++ b/fs/nfsd/cache.h
> @@ -84,12 +84,4 @@ int	nfsd_cache_lookup(struct svc_rqst *);
>  void	nfsd_cache_update(struct svc_rqst *, int, __be32 *);
>  int	nfsd_reply_cache_stats_open(struct inode *, struct file *);
>  
> -#ifdef CONFIG_NFSD_V4
> -void	nfsd4_set_statp(struct svc_rqst *rqstp, __be32 *statp);
> -#else  /* CONFIG_NFSD_V4 */
> -static inline void nfsd4_set_statp(struct svc_rqst *rqstp, __be32 *statp)
> -{
> -}
> -#endif /* CONFIG_NFSD_V4 */
> -
>  #endif /* NFSCACHE_H */
> -- 
> 1.8.4.2
