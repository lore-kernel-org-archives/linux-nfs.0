Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:37927 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751523Ab3AaVXD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 31 Jan 2013 16:23:03 -0500
Date: Thu, 31 Jan 2013 16:23:02 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1 02/16] nfsd: remove unneeded spinlock in
 nfsd_cache_update
Message-ID: <20130131212301.GD24252@fieldses.org>
References: <1359402082-29195-1-git-send-email-jlayton@redhat.com>
 <1359402082-29195-3-git-send-email-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1359402082-29195-3-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 28, 2013 at 02:41:08PM -0500, Jeff Layton wrote:
> The locking rules for cache entries say that locking the cache_lock
> isn't needed if you're just touching the current entry. Earlier
> in this function we set rp->c_state to RC_UNUSED without any locking,
> so I believe it's ok to do the same here.

Also, the previous assignment to cachv->iov_base is a write to the same
entry without a lock.

It's still a little odd to be writing to this entry without holding any
lock.  I have to stare at it for a while to convince myself it's OK, but
I guess it is: this entry is transitioning from RC_INUSE to RC_UNUSED,
but it's not modifying the entry otherwise (that cachv->iov_base
assignment was actually a no-op in this case since it had to be NULL
already).  So it shouldn't matter that there's no write barrier or
anything.  At worst another thread may be a little late to notice this
entry is free.

OK, applying.  Could use a comment or something though.

--b.

> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  fs/nfsd/nfscache.c | 2 --
>  1 file changed, 2 deletions(-)
> 
> diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
> index 5dd9ec2..972c14a 100644
> --- a/fs/nfsd/nfscache.c
> +++ b/fs/nfsd/nfscache.c
> @@ -286,9 +286,7 @@ nfsd_cache_update(struct svc_rqst *rqstp, int cachetype, __be32 *statp)
>  		cachv = &rp->c_replvec;
>  		cachv->iov_base = kmalloc(len << 2, GFP_KERNEL);
>  		if (!cachv->iov_base) {
> -			spin_lock(&cache_lock);
>  			rp->c_state = RC_UNUSED;
> -			spin_unlock(&cache_lock);
>  			return;
>  		}
>  		cachv->iov_len = len << 2;
> -- 
> 1.7.11.7
> 
