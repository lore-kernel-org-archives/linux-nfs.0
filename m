Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:41566 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932171AbcFBUbH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 2 Jun 2016 16:31:07 -0400
Date: Thu, 2 Jun 2016 16:31:06 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.com>
Cc: NFS List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] sunrpc: remove 'inuse' flag from struct cache_detail.
Message-ID: <20160602203106.GB15621@fieldses.org>
References: <87inxsp0ew.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <87inxsp0ew.fsf@notabene.neil.brown.name>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 02, 2016 at 04:31:03PM +1000, NeilBrown wrote:
> 
> This field is not currently in use.

Hah.  OK, thanks.--b.

> 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
> 
> I recently noticed this and wondered what it was for. "Nothing" seems to
> be the answer..
> 
> NeilBrown
> 
> 
>  include/linux/sunrpc/cache.h | 2 --
>  net/sunrpc/cache.c           | 2 +-
>  2 files changed, 1 insertion(+), 3 deletions(-)
> 
> diff --git a/include/linux/sunrpc/cache.h b/include/linux/sunrpc/cache.h
> index ed03c9f7f908..62a60eeacb0a 100644
> --- a/include/linux/sunrpc/cache.h
> +++ b/include/linux/sunrpc/cache.h
> @@ -78,8 +78,6 @@ struct cache_detail {
>  	struct hlist_head *	hash_table;
>  	rwlock_t		hash_lock;
>  
> -	atomic_t		inuse; /* active user-space update or lookup */
> -
>  	char			*name;
>  	void			(*cache_put)(struct kref *);
>  
> diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
> index 553bf95f7003..4d8e11f94a35 100644
> --- a/net/sunrpc/cache.c
> +++ b/net/sunrpc/cache.c
> @@ -362,7 +362,7 @@ void sunrpc_destroy_cache_detail(struct cache_detail *cd)
>  	cache_purge(cd);
>  	spin_lock(&cache_list_lock);
>  	write_lock(&cd->hash_lock);
> -	if (cd->entries || atomic_read(&cd->inuse)) {
> +	if (cd->entries) {
>  		write_unlock(&cd->hash_lock);
>  		spin_unlock(&cache_list_lock);
>  		goto out;
> -- 
> 2.8.3
> 


