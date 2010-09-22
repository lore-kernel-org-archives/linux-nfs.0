Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:52836 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750830Ab0IVDBL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Sep 2010 23:01:11 -0400
Date: Tue, 21 Sep 2010 22:59:44 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/7] sunrpc/cache: change deferred-request hash table
 to use hlist.
Message-ID: <20100922025944.GC22021@fieldses.org>
References: <20100922025009.31745.98237.stgit@localhost.localdomain>
 <20100922025506.31745.9409.stgit@localhost.localdomain>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100922025506.31745.9409.stgit@localhost.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Sep 22, 2010 at 12:55:07PM +1000, NeilBrown wrote:
> Being a hash table, hlist is the best option.
> 
> There is currently some ugliness were we treat "->next == NULL" as
> a special case to avoid having to initialise the whole array.
> This change nicely gets rid of that case.

This (or some hopefully correct variant!) should already be applied;
could you check that it looks right?

--b.

> 
> Signed-off-by: NeilBrown <neilb@suse.de>
> ---
>  include/linux/sunrpc/cache.h |    2 +-
>  net/sunrpc/cache.c           |   22 ++++++++--------------
>  2 files changed, 9 insertions(+), 15 deletions(-)
> 
> diff --git a/include/linux/sunrpc/cache.h b/include/linux/sunrpc/cache.h
> index 52a7d72..0349635 100644
> --- a/include/linux/sunrpc/cache.h
> +++ b/include/linux/sunrpc/cache.h
> @@ -133,7 +133,7 @@ struct cache_req {
>   * delayed awaiting cache-fill
>   */
>  struct cache_deferred_req {
> -	struct list_head	hash;	/* on hash chain */
> +	struct hlist_node	hash;	/* on hash chain */
>  	struct list_head	recent; /* on fifo */
>  	struct cache_head	*item;  /* cache item we wait on */
>  	void			*owner; /* we might need to discard all defered requests
> diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
> index a9e850e..466f65c 100644
> --- a/net/sunrpc/cache.c
> +++ b/net/sunrpc/cache.c
> @@ -506,13 +506,13 @@ EXPORT_SYMBOL_GPL(cache_purge);
>  
>  static DEFINE_SPINLOCK(cache_defer_lock);
>  static LIST_HEAD(cache_defer_list);
> -static struct list_head cache_defer_hash[DFR_HASHSIZE];
> +static struct hlist_head cache_defer_hash[DFR_HASHSIZE];
>  static int cache_defer_cnt;
>  
>  static void __unhash_deferred_req(struct cache_deferred_req *dreq)
>  {
>  	list_del_init(&dreq->recent);
> -	list_del_init(&dreq->hash);
> +	hlist_del_init(&dreq->hash);
>  	cache_defer_cnt--;
>  }
>  
> @@ -521,9 +521,7 @@ static void __hash_deferred_req(struct cache_deferred_req *dreq, struct cache_he
>  	int hash = DFR_HASH(item);
>  
>  	list_add(&dreq->recent, &cache_defer_list);
> -	if (cache_defer_hash[hash].next == NULL)
> -		INIT_LIST_HEAD(&cache_defer_hash[hash]);
> -	list_add(&dreq->hash, &cache_defer_hash[hash]);
> +	hlist_add_head(&dreq->hash, &cache_defer_hash[hash]);
>  }
>  
>  static int setup_deferral(struct cache_deferred_req *dreq, struct cache_head *item)
> @@ -587,7 +585,7 @@ static int cache_wait_req(struct cache_req *req, struct cache_head *item)
>  		 * to clean up
>  		 */
>  		spin_lock(&cache_defer_lock);
> -		if (!list_empty(&sleeper.handle.hash)) {
> +		if (!hlist_unhashed(&sleeper.handle.hash)) {
>  			__unhash_deferred_req(&sleeper.handle);
>  			spin_unlock(&cache_defer_lock);
>  		} else {
> @@ -642,23 +640,19 @@ static void cache_revisit_request(struct cache_head *item)
>  	struct cache_deferred_req *dreq;
>  	struct list_head pending;
>  
> -	struct list_head *lp;
> +	struct hlist_node *lp, *tmp;
>  	int hash = DFR_HASH(item);
>  
>  	INIT_LIST_HEAD(&pending);
>  	spin_lock(&cache_defer_lock);
>  
> -	lp = cache_defer_hash[hash].next;
> -	if (lp) {
> -		while (lp != &cache_defer_hash[hash]) {
> -			dreq = list_entry(lp, struct cache_deferred_req, hash);
> -			lp = lp->next;
> +	hlist_for_each_entry_safe(dreq, lp, tmp,
> +				  &cache_defer_hash[hash], hash)
>  			if (dreq->item == item) {
>  				__unhash_deferred_req(dreq);
>  				list_add(&dreq->recent, &pending);
>  			}
> -		}
> -	}
> +
>  	spin_unlock(&cache_defer_lock);
>  
>  	while (!list_empty(&pending)) {
> 
> 
