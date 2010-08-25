Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:43354 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752338Ab0HYQJ5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 Aug 2010 12:09:57 -0400
Date: Wed, 25 Aug 2010 12:09:48 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Neil Brown <neilb@suse.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/2] sunrpc: use monotonic time in expiry cache
Message-ID: <20100825160948.GC14440@fieldses.org>
References: <20100812064957.3408.44224.stgit@localhost.localdomain>
 <20100812065522.3408.25500.stgit@localhost.localdomain>
 <20100824181531.GE25706@fieldses.org>
 <20100825091226.5a68986d@notabene>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100825091226.5a68986d@notabene>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Aug 25, 2010 at 09:12:26AM +1000, Neil Brown wrote:
> Yes.... I think I developed this against 2.6.16 which has different naming
> conventions, and then forward-parted to -current without giving too much
> thought to the names.   seconds_since_boot() does sound better.
> 
> > 
> > Oh, and
> > 
> > 	get_seconds() - monotonic_seconds()
> > 
> > isn't the most intuitive way possible to say "boot time in seconds".  If
> > you want to fix either of those, fine, otherwise no big deal.)
> 
> To be fair, I don't use that exactly.  I use
> 
>       some_monotonic_based_value - monotonic_seconds() + get_seconds()
> 
> to turn a monotonic_based value to a wallclock based value.
> This makes sense to me - subtract the base I don't want, and add the base
> that I do.

Sure....

> I guess you could wrap that in convert_to_wallclock and use getboottime
> directly:
> 
> static inline time_t convert_to_wallclock(time_t sinceboot)
> {
> 	struct timespec boot;
> 	getboottime(&boot);
> 	return sinceboot + boot.tv_sec;
> }

....  But I think that makes the calculation truly, blindingly obvious.

> Following is only compile tested.

Merged into the previous patch (not pushed out yet pending some
testing).  Thanks!

--b.

> 
> Thanks,
> NeilBrown
> 
> -------
> 
> Rename monotonic_seconds to seconds_since_boot
> 
> monotonic has a meaning in Linux timekeeping slight different to what we
> use in sunrpc_cache, so change the name.
> 
> Also make the conversion from second_since_boot times to wallclock times less
> obscure.
> 
> Signed-off-by: NeilBrown <neilb@suse.de>
> 
> diff --git a/fs/nfs/dns_resolve.c b/fs/nfs/dns_resolve.c
> index 3e6aab2..97c03ca 100644
> --- a/fs/nfs/dns_resolve.c
> +++ b/fs/nfs/dns_resolve.c
> @@ -144,7 +144,7 @@ static int nfs_dns_show(struct seq_file *m, struct cache_detail *cd,
>  		return 0;
>  	}
>  	item = container_of(h, struct nfs_dns_ent, h);
> -	ttl = item->h.expiry_time - monotonic_seconds();
> +	ttl = item->h.expiry_time - seconds_since_boot();
>  	if (ttl < 0)
>  		ttl = 0;
>  
> @@ -216,7 +216,7 @@ static int nfs_dns_parse(struct cache_detail *cd, char *buf, int buflen)
>  	ttl = get_expiry(&buf);
>  	if (ttl == 0)
>  		goto out;
> -	key.h.expiry_time = ttl + monotonic_seconds();
> +	key.h.expiry_time = ttl + seconds_since_boot();
>  
>  	ret = -ENOMEM;
>  	item = nfs_dns_lookup(cd, &key);
> @@ -278,7 +278,7 @@ static int do_cache_lookup_nowait(struct cache_detail *cd,
>  		goto out_err;
>  	ret = -ETIMEDOUT;
>  	if (!test_bit(CACHE_VALID, &(*item)->h.flags)
> -			|| (*item)->h.expiry_time < monotonic_seconds()
> +			|| (*item)->h.expiry_time < seconds_since_boot()
>  			|| cd->flush_time > (*item)->h.last_refresh)
>  		goto out_put;
>  	ret = -ENOENT;
> diff --git a/fs/nfsd/nfs4idmap.c b/fs/nfsd/nfs4idmap.c
> index 6031a90..808b33a 100644
> --- a/fs/nfsd/nfs4idmap.c
> +++ b/fs/nfsd/nfs4idmap.c
> @@ -550,7 +550,7 @@ do_idmap_lookup_nowait(struct ent *(*lookup_fn)(struct ent *),
>  		goto out_err;
>  	ret = -ETIMEDOUT;
>  	if (!test_bit(CACHE_VALID, &(*item)->h.flags)
> -			|| (*item)->h.expiry_time < monotonic_seconds()
> +			|| (*item)->h.expiry_time < seconds_since_boot()
>  			|| detail->flush_time > (*item)->h.last_refresh)
>  		goto out_put;
>  	ret = -ENOENT;
> diff --git a/include/linux/sunrpc/cache.h b/include/linux/sunrpc/cache.h
> index df7c19b..ece432b 100644
> --- a/include/linux/sunrpc/cache.h
> +++ b/include/linux/sunrpc/cache.h
> @@ -223,13 +223,20 @@ static inline int get_int(char **bpp, int *anint)
>   * since boot.  This is the best for measuring differences in
>   * real time.
>   */
> -static inline time_t monotonic_seconds(void)
> +static inline time_t seconds_since_boot(void)
>  {
>  	struct timespec boot;
>  	getboottime(&boot);
>  	return get_seconds() - boot.tv_sec;
>  }
>  
> +static inline time_t convert_to_wallclock(time_t sinceboot)
> +{
> +	struct timespec boot;
> +	getboottime(&boot);
> +	return boot.tv_sec + sinceboot;
> +}
> +
>  static inline time_t get_expiry(char **bpp)
>  {
>  	int rv;
> @@ -246,7 +253,7 @@ static inline time_t get_expiry(char **bpp)
>  static inline void sunrpc_invalidate(struct cache_head *h,
>  				     struct cache_detail *detail)
>  {
> -	h->expiry_time = monotonic_seconds() - 1;
> -	detail->nextcheck = monotonic_seconds();
> +	h->expiry_time = seconds_since_boot() - 1;
> +	detail->nextcheck = seconds_since_boot();
>  }
>  #endif /*  _LINUX_SUNRPC_CACHE_H_ */
> diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
> index 99d852e..8dc1219 100644
> --- a/net/sunrpc/cache.c
> +++ b/net/sunrpc/cache.c
> @@ -42,7 +42,7 @@ static void cache_revisit_request(struct cache_head *item);
>  
>  static void cache_init(struct cache_head *h)
>  {
> -	time_t now = monotonic_seconds();
> +	time_t now = seconds_since_boot();
>  	h->next = NULL;
>  	h->flags = 0;
>  	kref_init(&h->ref);
> @@ -52,7 +52,7 @@ static void cache_init(struct cache_head *h)
>  
>  static inline int cache_is_expired(struct cache_detail *detail, struct cache_head *h)
>  {
> -	return  (h->expiry_time < monotonic_seconds()) ||
> +	return  (h->expiry_time < seconds_since_boot()) ||
>  		(detail->flush_time > h->last_refresh);
>  }
>  
> @@ -127,7 +127,7 @@ static void cache_dequeue(struct cache_detail *detail, struct cache_head *ch);
>  static void cache_fresh_locked(struct cache_head *head, time_t expiry)
>  {
>  	head->expiry_time = expiry;
> -	head->last_refresh = monotonic_seconds();
> +	head->last_refresh = seconds_since_boot();
>  	set_bit(CACHE_VALID, &head->flags);
>  }
>  
> @@ -238,7 +238,7 @@ int cache_check(struct cache_detail *detail,
>  
>  	/* now see if we want to start an upcall */
>  	refresh_age = (h->expiry_time - h->last_refresh);
> -	age = monotonic_seconds() - h->last_refresh;
> +	age = seconds_since_boot() - h->last_refresh;
>  
>  	if (rqstp == NULL) {
>  		if (rv == -EAGAIN)
> @@ -253,7 +253,7 @@ int cache_check(struct cache_detail *detail,
>  				cache_revisit_request(h);
>  				if (rv == -EAGAIN) {
>  					set_bit(CACHE_NEGATIVE, &h->flags);
> -					cache_fresh_locked(h, monotonic_seconds()+CACHE_NEW_EXPIRY);
> +					cache_fresh_locked(h, seconds_since_boot()+CACHE_NEW_EXPIRY);
>  					cache_fresh_unlocked(h, detail);
>  					rv = -ENOENT;
>  				}
> @@ -388,11 +388,11 @@ static int cache_clean(void)
>  			return -1;
>  		}
>  		current_detail = list_entry(next, struct cache_detail, others);
> -		if (current_detail->nextcheck > monotonic_seconds())
> +		if (current_detail->nextcheck > seconds_since_boot())
>  			current_index = current_detail->hash_size;
>  		else {
>  			current_index = 0;
> -			current_detail->nextcheck = monotonic_seconds()+30*60;
> +			current_detail->nextcheck = seconds_since_boot()+30*60;
>  		}
>  	}
>  
> @@ -477,7 +477,7 @@ EXPORT_SYMBOL_GPL(cache_flush);
>  void cache_purge(struct cache_detail *detail)
>  {
>  	detail->flush_time = LONG_MAX;
> -	detail->nextcheck = monotonic_seconds();
> +	detail->nextcheck = seconds_since_boot();
>  	cache_flush();
>  	detail->flush_time = 1;
>  }
> @@ -902,7 +902,7 @@ static int cache_release(struct inode *inode, struct file *filp,
>  		filp->private_data = NULL;
>  		kfree(rp);
>  
> -		cd->last_close = monotonic_seconds();
> +		cd->last_close = seconds_since_boot();
>  		atomic_dec(&cd->readers);
>  	}
>  	module_put(cd->owner);
> @@ -1034,7 +1034,7 @@ int sunrpc_cache_pipe_upcall(struct cache_detail *detail, struct cache_head *h,
>  	int len;
>  
>  	if (atomic_read(&detail->readers) == 0 &&
> -	    detail->last_close < monotonic_seconds() - 30) {
> +	    detail->last_close < seconds_since_boot() - 30) {
>  			warn_no_listener(detail);
>  			return -EINVAL;
>  	}
> @@ -1219,7 +1219,7 @@ static int c_show(struct seq_file *m, void *p)
>  
>  	ifdebug(CACHE)
>  		seq_printf(m, "# expiry=%ld refcnt=%d flags=%lx\n",
> -			   cp->expiry_time - monotonic_seconds() + get_seconds(),
> +			   convert_to_wallclock(cp->expiry_time),
>  			   atomic_read(&cp->ref.refcount), cp->flags);
>  	cache_get(cp);
>  	if (cache_check(cd, cp, NULL))
> @@ -1286,8 +1286,7 @@ static ssize_t read_flush(struct file *file, char __user *buf,
>  	unsigned long p = *ppos;
>  	size_t len;
>  
> -	sprintf(tbuf, "%lu\n", (cd->flush_time - monotonic_seconds()
> -				+ get_seconds()));
> +	sprintf(tbuf, "%lu\n", convert_to_wallclock(cd->flush_time));
>  	len = strlen(tbuf);
>  	if (p >= len)
>  		return 0;
> @@ -1318,7 +1317,7 @@ static ssize_t write_flush(struct file *file, const char __user *buf,
>  
>  	bp = tbuf;
>  	cd->flush_time = get_expiry(&bp);
> -	cd->nextcheck = monotonic_seconds();
> +	cd->nextcheck = seconds_since_boot();
>  	cache_flush();
>  
>  	*ppos += count;
