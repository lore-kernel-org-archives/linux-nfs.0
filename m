Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:36138 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751884Ab3CRO5D (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 Mar 2013 10:57:03 -0400
Date: Mon, 18 Mar 2013 10:57:02 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: only unhash DRC entries that are in the hashtable
Message-ID: <20130318145702.GC6350@fieldses.org>
References: <1363618147-24676-1-git-send-email-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1363618147-24676-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 18, 2013 at 10:49:07AM -0400, Jeff Layton wrote:
> It's not safe to call hlist_del() on a newly initialized hlist_node.
> That leads to a NULL pointer dereference. Only do that if the entry
> is hashed.

Thanks!  Applying for 3.9.--b.

> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  fs/nfsd/nfscache.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
> index f5ad28e..ca05f6d 100644
> --- a/fs/nfsd/nfscache.c
> +++ b/fs/nfsd/nfscache.c
> @@ -102,7 +102,8 @@ nfsd_reply_cache_free_locked(struct svc_cacherep *rp)
>  {
>  	if (rp->c_type == RC_REPLBUFF)
>  		kfree(rp->c_replvec.iov_base);
> -	hlist_del(&rp->c_hash);
> +	if (!hlist_unhashed(&rp->c_hash))
> +		hlist_del(&rp->c_hash);
>  	list_del(&rp->c_lru);
>  	--num_drc_entries;
>  	kmem_cache_free(drc_slab, rp);
> -- 
> 1.7.11.7
> 
