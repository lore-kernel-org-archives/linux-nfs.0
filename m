Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:47103 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758408Ab3BNWDk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 14 Feb 2013 17:03:40 -0500
Date: Thu, 14 Feb 2013 17:03:40 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/3] nfsd: fix comments on nfsd_cache_lookup
Message-ID: <20130214220339.GF8343@fieldses.org>
References: <1360878315-21578-1-git-send-email-jlayton@redhat.com>
 <1360878315-21578-2-git-send-email-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1360878315-21578-2-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 14, 2013 at 04:45:13PM -0500, Jeff Layton wrote:
> Signed-off-by: Jeff Layton <jlayton@redhat.com>

Applying, thanks.--b.

> ---
>  fs/nfsd/nfscache.c | 7 +++++--
>  1 file changed, 5 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
> index 40db57e..2f9c2d2 100644
> --- a/fs/nfsd/nfscache.c
> +++ b/fs/nfsd/nfscache.c
> @@ -302,8 +302,10 @@ nfsd_cache_search(struct svc_rqst *rqstp, __wsum csum)
>  
>  /*
>   * Try to find an entry matching the current call in the cache. When none
> - * is found, we grab the oldest unlocked entry off the LRU list.
> - * Note that no operation within the loop may sleep.
> + * is found, we try to grab the oldest expired entry off the LRU list. If
> + * a suitable one isn't there, then drop the cache_lock and allocate a
> + * new one, then search again in case one got inserted while this thread
> + * didn't hold the lock.
>   */
>  int
>  nfsd_cache_lookup(struct svc_rqst *rqstp)
> @@ -344,6 +346,7 @@ nfsd_cache_lookup(struct svc_rqst *rqstp)
>  		}
>  	}
>  
> +	/* Drop the lock and allocate a new entry */
>  	spin_unlock(&cache_lock);
>  	rp = nfsd_reply_cache_alloc();
>  	if (!rp) {
> -- 
> 1.7.11.7
> 
