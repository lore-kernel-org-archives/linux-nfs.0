Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48780 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932256AbcA0Qjg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 Jan 2016 11:39:36 -0500
Subject: Re: [Linux-cachefs] [PATCH] CacheFiles: Provide read-and-reset
 release counters for cachefilesd
To: David Howells <dhowells@redhat.com>, linux-cachefs@redhat.com
References: <20160125164111.9466.79976.stgit@warthog.procyon.org.uk>
Cc: linux-nfs@vger.kernel.org, fsdevel@vger.kernel.org, neilb@suse.de,
        jlayton@poochiereds.net, jsnow@redhat.com
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <56A8F2C6.6030703@RedHat.com>
Date: Wed, 27 Jan 2016 11:39:34 -0500
MIME-Version: 1.0
In-Reply-To: <20160125164111.9466.79976.stgit@warthog.procyon.org.uk>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 01/25/2016 11:41 AM, David Howells wrote:
> Provide read-and-reset objects- and blocks-released counters for cachefilesd
> to use to work out whether there's anything new that can be culled.
> 
> One of the problems cachefilesd has is that if all the objects in the cache
> are pinned by inodes lying dormant in the kernel inode cache, there isn't
> anything for it to cull.  In such a case, it just spins around walking the
> filesystem tree and scanning for something to cull.  This eats up a lot of
> CPU time.
> 
> By telling cachefilesd if there have been any releases, the daemon can
> sleep until there is the possibility of something to do.
> 
> cachefilesd finds this information by the following means:
> 
>  (1) When the control fd is read, the kernel presents a list of values of
>      interest.  "freleased=N" and "breleased=N" are added to this list to
>      indicate the number of files released and number of blocks released
>      since the last read call.  At this point the counters are reset.
> 
>  (2) POLLIN is signalled if the number of files released becomes greater
>      than 0.
> 
> Note that by 'released' it just means that the kernel has released its
> interest in those files for the moment, not necessarily that the files
> should be deleted from the cache.
> 
> Signed-off-by: David Howells <dhowells@redhat.com>
Reviewed-by: Steve Dickson <steved@redhat.com>

steved.

> ---
> 
>  fs/cachefiles/daemon.c    |   13 ++++++++++---
>  fs/cachefiles/interface.c |   11 ++---------
>  fs/cachefiles/internal.h  |    4 ++++
>  fs/cachefiles/namei.c     |   28 +++++++++++++++++++++++-----
>  4 files changed, 39 insertions(+), 17 deletions(-)
> 
> diff --git a/fs/cachefiles/daemon.c b/fs/cachefiles/daemon.c
> index 452e98dd7560..1ee54ffd3a24 100644
> --- a/fs/cachefiles/daemon.c
> +++ b/fs/cachefiles/daemon.c
> @@ -162,6 +162,8 @@ static ssize_t cachefiles_daemon_read(struct file *file, char __user *_buffer,
>  				      size_t buflen, loff_t *pos)
>  {
>  	struct cachefiles_cache *cache = file->private_data;
> +	unsigned long long b_released;
> +	unsigned f_released;
>  	char buffer[256];
>  	int n;
>  
> @@ -174,6 +176,8 @@ static ssize_t cachefiles_daemon_read(struct file *file, char __user *_buffer,
>  	cachefiles_has_space(cache, 0, 0);
>  
>  	/* summarise */
> +	f_released = atomic_xchg(&cache->f_released, 0);
> +	b_released = atomic_long_xchg(&cache->b_released, 0);
>  	clear_bit(CACHEFILES_STATE_CHANGED, &cache->flags);
>  
>  	n = snprintf(buffer, sizeof(buffer),
> @@ -183,15 +187,18 @@ static ssize_t cachefiles_daemon_read(struct file *file, char __user *_buffer,
>  		     " fstop=%llx"
>  		     " brun=%llx"
>  		     " bcull=%llx"
> -		     " bstop=%llx",
> +		     " bstop=%llx"
> +		     " freleased=%x"
> +		     " breleased=%llx",
>  		     test_bit(CACHEFILES_CULLING, &cache->flags) ? '1' : '0',
>  		     (unsigned long long) cache->frun,
>  		     (unsigned long long) cache->fcull,
>  		     (unsigned long long) cache->fstop,
>  		     (unsigned long long) cache->brun,
>  		     (unsigned long long) cache->bcull,
> -		     (unsigned long long) cache->bstop
> -		     );
> +		     (unsigned long long) cache->bstop,
> +		     f_released,
> +		     b_released);
>  
>  	if (n > buflen)
>  		return -EMSGSIZE;
> diff --git a/fs/cachefiles/interface.c b/fs/cachefiles/interface.c
> index afa023dded5b..ee0cb116ff40 100644
> --- a/fs/cachefiles/interface.c
> +++ b/fs/cachefiles/interface.c
> @@ -291,15 +291,8 @@ static void cachefiles_drop_object(struct fscache_object *_object)
>  	}
>  
>  	/* note that the object is now inactive */
> -	if (test_bit(CACHEFILES_OBJECT_ACTIVE, &object->flags)) {
> -		write_lock(&cache->active_lock);
> -		if (!test_and_clear_bit(CACHEFILES_OBJECT_ACTIVE,
> -					&object->flags))
> -			BUG();
> -		rb_erase(&object->active_node, &cache->active_nodes);
> -		wake_up_bit(&object->flags, CACHEFILES_OBJECT_ACTIVE);
> -		write_unlock(&cache->active_lock);
> -	}
> +	if (test_bit(CACHEFILES_OBJECT_ACTIVE, &object->flags))
> +		cachefiles_mark_object_inactive(cache, object);
>  
>  	dput(object->dentry);
>  	object->dentry = NULL;
> diff --git a/fs/cachefiles/internal.h b/fs/cachefiles/internal.h
> index 9c4b737a54df..2fcde1a34b7c 100644
> --- a/fs/cachefiles/internal.h
> +++ b/fs/cachefiles/internal.h
> @@ -66,6 +66,8 @@ struct cachefiles_cache {
>  	struct rb_root			active_nodes;	/* active nodes (can't be culled) */
>  	rwlock_t			active_lock;	/* lock for active_nodes */
>  	atomic_t			gravecounter;	/* graveyard uniquifier */
> +	atomic_t			f_released;	/* number of objects released lately */
> +	atomic_long_t			b_released;	/* number of blocks released lately */
>  	unsigned			frun_percent;	/* when to stop culling (% files) */
>  	unsigned			fcull_percent;	/* when to start culling (% files) */
>  	unsigned			fstop_percent;	/* when to stop allocating (% files) */
> @@ -157,6 +159,8 @@ extern char *cachefiles_cook_key(const u8 *raw, int keylen, uint8_t type);
>  /*
>   * namei.c
>   */
> +extern void cachefiles_mark_object_inactive(struct cachefiles_cache *cache,
> +					    struct cachefiles_object *object);
>  extern int cachefiles_delete_object(struct cachefiles_cache *cache,
>  				    struct cachefiles_object *object);
>  extern int cachefiles_walk_to_object(struct cachefiles_object *parent,
> diff --git a/fs/cachefiles/namei.c b/fs/cachefiles/namei.c
> index c4b893453e0e..1ad16ae7ab96 100644
> --- a/fs/cachefiles/namei.c
> +++ b/fs/cachefiles/namei.c
> @@ -258,6 +258,28 @@ requeue:
>  }
>  
>  /*
> + * Mark an object as being inactive.
> + */
> +void cachefiles_mark_object_inactive(struct cachefiles_cache *cache,
> +				     struct cachefiles_object *object)
> +{
> +	write_lock(&cache->active_lock);
> +	rb_erase(&object->active_node, &cache->active_nodes);
> +	clear_bit(CACHEFILES_OBJECT_ACTIVE, &object->flags);
> +	write_unlock(&cache->active_lock);
> +
> +	wake_up_bit(&object->flags, CACHEFILES_OBJECT_ACTIVE);
> +
> +	/* This object can now be culled, so we need to let the daemon know
> +	 * that there is something it can remove if it needs to.
> +	 */
> +	atomic_long_add(d_backing_inode(object->dentry)->i_blocks,
> +			&cache->b_released);
> +	if (atomic_inc_return(&cache->f_released))
> +		cachefiles_state_changed(cache);
> +}
> +
> +/*
>   * delete an object representation from the cache
>   * - file backed objects are unlinked
>   * - directory backed objects are stuffed into the graveyard for userspace to
> @@ -684,11 +706,7 @@ mark_active_timed_out:
>  
>  check_error:
>  	_debug("check error %d", ret);
> -	write_lock(&cache->active_lock);
> -	rb_erase(&object->active_node, &cache->active_nodes);
> -	clear_bit(CACHEFILES_OBJECT_ACTIVE, &object->flags);
> -	wake_up_bit(&object->flags, CACHEFILES_OBJECT_ACTIVE);
> -	write_unlock(&cache->active_lock);
> +	cachefiles_mark_object_inactive(cache, object);
>  release_dentry:
>  	dput(object->dentry);
>  	object->dentry = NULL;
> 
