From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 1/2] sunrpc: extract some common sunrpc_cache code from
 nfsd
Date: Fri, 20 Aug 2010 18:18:18 -0400
Message-ID: <20100820221818.GE26698@fieldses.org>
References: <20100812064957.3408.44224.stgit@localhost.localdomain>
 <20100812065522.3408.34827.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: NeilBrown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:54836 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751878Ab0HTWU2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Aug 2010 18:20:28 -0400
In-Reply-To: <20100812065522.3408.34827.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 12, 2010 at 04:55:22PM +1000, NeilBrown wrote:
> Rather can duplicating this idiom twice, put it in an inline function.
> This reduces the usage of 'expiry_time' out side the sunrpc/cache.c
> code and thus the impact of a change that is about to be made to that
> field.

Thanks, applying for 2.6.37.

--b.

> 
> Signed-off-by: NeilBrown <neilb@suse.de>
> ---
>  fs/nfsd/export.c             |    9 +++------
>  include/linux/sunrpc/cache.h |    6 ++++++
>  2 files changed, 9 insertions(+), 6 deletions(-)
> 
> diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
> index c2a4f71..e56827b 100644
> --- a/fs/nfsd/export.c
> +++ b/fs/nfsd/export.c
> @@ -935,10 +935,9 @@ static void exp_fsid_unhash(struct svc_export *exp)
>  
>  	ek = exp_get_fsid_key(exp->ex_client, exp->ex_fsid);
>  	if (!IS_ERR(ek)) {
> -		ek->h.expiry_time = get_seconds()-1;
> +		sunrpc_invalidate(&ek->h, &svc_expkey_cache);
>  		cache_put(&ek->h, &svc_expkey_cache);
>  	}
> -	svc_expkey_cache.nextcheck = get_seconds();
>  }
>  
>  static int exp_fsid_hash(svc_client *clp, struct svc_export *exp)
> @@ -973,10 +972,9 @@ static void exp_unhash(struct svc_export *exp)
>  
>  	ek = exp_get_key(exp->ex_client, inode->i_sb->s_dev, inode->i_ino);
>  	if (!IS_ERR(ek)) {
> -		ek->h.expiry_time = get_seconds()-1;
> +		sunrpc_invalidate(&ek->h, &svc_expkey_cache);
>  		cache_put(&ek->h, &svc_expkey_cache);
>  	}
> -	svc_expkey_cache.nextcheck = get_seconds();
>  }
>  	
>  /*
> @@ -1097,8 +1095,7 @@ out:
>  static void
>  exp_do_unexport(svc_export *unexp)
>  {
> -	unexp->h.expiry_time = get_seconds()-1;
> -	svc_export_cache.nextcheck = get_seconds();
> +	sunrpc_invalidate(&unexp->h, &svc_export_cache);
>  	exp_unhash(unexp);
>  	exp_fsid_unhash(unexp);
>  }
> diff --git a/include/linux/sunrpc/cache.h b/include/linux/sunrpc/cache.h
> index 7bf3e84..0e1febf 100644
> --- a/include/linux/sunrpc/cache.h
> +++ b/include/linux/sunrpc/cache.h
> @@ -228,4 +228,10 @@ static inline time_t get_expiry(char **bpp)
>  	return rv;
>  }
>  
> +static inline void sunrpc_invalidate(struct cache_head *h,
> +				     struct cache_detail *detail)
> +{
> +	h->expiry_time = get_seconds() - 1;
> +	detail->nextcheck = get_seconds();
> +}
>  #endif /*  _LINUX_SUNRPC_CACHE_H_ */
> 
> 
