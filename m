Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:41553 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932926Ab3DINJT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Apr 2013 09:09:19 -0400
Date: Tue, 9 Apr 2013 09:09:16 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Wei Yongjun <weiyj.lk@gmail.com>
Cc: yongjun_wei@trendmicro.com.cn, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: use kmem_cache_free() instead of kfree()
Message-ID: <20130409130916.GA24657@fieldses.org>
References: <CAPgLHd_A_6Za0rOZDdrrKSpB39MquPVgUrAgXO=57T6xYyjcKA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAPgLHd_A_6Za0rOZDdrrKSpB39MquPVgUrAgXO=57T6xYyjcKA@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 09, 2013 at 02:15:31PM +0800, Wei Yongjun wrote:
> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> memory allocated by kmem_cache_alloc() should be freed using
> kmem_cache_free(), not kfree().

Applying, thanks.--b.

> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> ---
>  fs/nfsd/nfs4state.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 2e27430..06a520b 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -267,7 +267,7 @@ kmem_cache *slab)
>  		min_stateid = 0;
>  	return stid;
>  out_free:
> -	kfree(stid);
> +	kmem_cache_free(slab, stid);
>  	return NULL;
>  }
>  
> 
