Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:59637 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760225Ab2DKOQP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Apr 2012 10:16:15 -0400
Date: Wed, 11 Apr 2012 10:16:14 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, devel@openvz.org
Subject: Re: [PATCH 4/8] nfsd: use exp_put() for svc_export_cache put
Message-ID: <20120411141614.GB27751@fieldses.org>
References: <20120328150152.2646.33607.stgit@localhost6.localdomain6>
 <20120328150921.2646.46229.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120328150921.2646.46229.stgit@localhost6.localdomain6>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 28, 2012 at 07:09:22PM +0400, Stanislav Kinsbursky wrote:
> This patch replaces cache_put() call for svc_export_cache by exp_put() call.

Patch looks fine.  Minor peeve: the changelog doesn't tell me anything I
couldn't figure out immediately from reading the patch.  Tell me *why*
we're doing this ("Removing another hard-coded svc_export_cache will
simplify adding per-export caches later"), or if it's really totally
obvious I'd rather have an empty changelog than a useless one....

--b.

> 
> Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
> 
> Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
> 
> ---
>  fs/nfsd/export.c |    2 +-
>  fs/nfsd/nfsfh.c  |    2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
> index 99ea4c0..c20a405 100644
> --- a/fs/nfsd/export.c
> +++ b/fs/nfsd/export.c
> @@ -1205,7 +1205,7 @@ static int e_show(struct seq_file *m, void *p)
>  	cache_get(&exp->h);
>  	if (cache_check(&svc_export_cache, &exp->h, NULL))
>  		return 0;
> -	cache_put(&exp->h, &svc_export_cache);
> +	exp_put(exp);
>  	return svc_export_show(m, &svc_export_cache, cp);
>  }
>  
> diff --git a/fs/nfsd/nfsfh.c b/fs/nfsd/nfsfh.c
> index 68454e7..cc79300 100644
> --- a/fs/nfsd/nfsfh.c
> +++ b/fs/nfsd/nfsfh.c
> @@ -636,7 +636,7 @@ fh_put(struct svc_fh *fhp)
>  #endif
>  	}
>  	if (exp) {
> -		cache_put(&exp->h, &svc_export_cache);
> +		exp_put(exp);
>  		fhp->fh_export = NULL;
>  	}
>  	return;
> 
