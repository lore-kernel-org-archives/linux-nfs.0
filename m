Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:30622 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964937Ab2CSOap (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 Mar 2012 10:30:45 -0400
Date: Mon, 19 Mar 2012 10:31:05 -0400
From: Jeff Layton <jlayton@redhat.com>
To: David Howells <dhowells@redhat.com>
Cc: steved@redhat.com, jmorris@namei.org,
        linux-security-module@vger.kernel.org, keyrings@linux-nfs.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [Keyrings] [PATCH 6/9] KEYS: Perform RCU synchronisation on
 keys prior to key destruction
Message-ID: <20120319103105.6a3a174c@redhat.com>
In-Reply-To: <20120208110349.4050.57462.stgit@warthog.procyon.org.uk>
References: <20120208110254.4050.8856.stgit@warthog.procyon.org.uk>
	<20120208110349.4050.57462.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 08 Feb 2012 11:03:49 +0000
David Howells <dhowells@redhat.com> wrote:

> Make the keys garbage collector invoke synchronize_rcu() prior to destroying
> keys with a zero usage count.  This means that a key can be examined under the
> RCU read lock in the safe knowledge that it won't get deallocated until after
> the lock is released - even if its usage count becomes zero whilst we're
> looking at it.
> 
> This is useful in keyring search vs key link.  Consider a keyring containing a
> link to a key.  That link can be replaced in-place in the keyring without
> requiring an RCU copy-and-replace on the keyring contents without breaking a
> search underway on that keyring when the displaced key is released, provided
> the key is actually destroyed only after the RCU read lock held by the search
> algorithm is released.
> 
> This permits __key_link() to replace a key without having to reallocate the key
> payload.  A key gets replaced if a new key being linked into a keyring has the
> same type and description.
> 
> Signed-off-by: David Howells <dhowells@redhat.com>
> ---
> 
>  include/linux/key.h |    5 +++
>  security/keys/gc.c  |   73 +++++++++++++++++++++++++++++++--------------------
>  2 files changed, 48 insertions(+), 30 deletions(-)
> 
> diff --git a/include/linux/key.h b/include/linux/key.h
> index 1600ebf..9832399 100644
> --- a/include/linux/key.h
> +++ b/include/linux/key.h
> @@ -124,7 +124,10 @@ static inline unsigned long is_key_possessed(const key_ref_t key_ref)
>  struct key {
>  	atomic_t		usage;		/* number of references */
>  	key_serial_t		serial;		/* key serial number */
> -	struct rb_node		serial_node;
> +	union {
> +		struct list_head graveyard_link;
> +		struct rb_node	serial_node;
> +	};
>  	struct key_type		*type;		/* type of key */
>  	struct rw_semaphore	sem;		/* change vs change sem */
>  	struct key_user		*user;		/* owner of this key */
> diff --git a/security/keys/gc.c b/security/keys/gc.c
> index a42b455..27610bf 100644
> --- a/security/keys/gc.c
> +++ b/security/keys/gc.c
> @@ -168,38 +168,45 @@ do_gc:
>  }
>  
>  /*
> - * Garbage collect an unreferenced, detached key
> + * Garbage collect a list of unreferenced, detached keys
>   */
> -static noinline void key_gc_unused_key(struct key *key)
> +static noinline void key_gc_unused_keys(struct list_head *keys)
>  {
> -	key_check(key);
> -
> -	security_key_free(key);
> -
> -	/* deal with the user's key tracking and quota */
> -	if (test_bit(KEY_FLAG_IN_QUOTA, &key->flags)) {
> -		spin_lock(&key->user->lock);
> -		key->user->qnkeys--;
> -		key->user->qnbytes -= key->quotalen;
> -		spin_unlock(&key->user->lock);
> -	}
> +	while (!list_empty(keys)) {
> +		struct key *key =
> +			list_entry(keys->next, struct key, graveyard_link);
> +		list_del(&key->graveyard_link);
> +
> +		kdebug("- %u", key->serial);
> +		key_check(key);
> +
> +		security_key_free(key);
> +
> +		/* deal with the user's key tracking and quota */
> +		if (test_bit(KEY_FLAG_IN_QUOTA, &key->flags)) {
> +			spin_lock(&key->user->lock);
> +			key->user->qnkeys--;
> +			key->user->qnbytes -= key->quotalen;
> +			spin_unlock(&key->user->lock);
> +		}
>  
> -	atomic_dec(&key->user->nkeys);
> -	if (test_bit(KEY_FLAG_INSTANTIATED, &key->flags))
> -		atomic_dec(&key->user->nikeys);
> +		atomic_dec(&key->user->nkeys);
> +		if (test_bit(KEY_FLAG_INSTANTIATED, &key->flags))
> +			atomic_dec(&key->user->nikeys);
>  
> -	key_user_put(key->user);
> +		key_user_put(key->user);
>  
> -	/* now throw away the key memory */
> -	if (key->type->destroy)
> -		key->type->destroy(key);
> +		/* now throw away the key memory */
> +		if (key->type->destroy)
> +			key->type->destroy(key);
>  
> -	kfree(key->description);
> +		kfree(key->description);
>  
>  #ifdef KEY_DEBUGGING
> -	key->magic = KEY_DEBUG_MAGIC_X;
> +		key->magic = KEY_DEBUG_MAGIC_X;
>  #endif
> -	kmem_cache_free(key_jar, key);
> +		kmem_cache_free(key_jar, key);
> +	}
>  }
>  
>  /*
> @@ -211,6 +218,7 @@ static noinline void key_gc_unused_key(struct key *key)
>   */
>  static void key_garbage_collector(struct work_struct *work)
>  {
> +	static LIST_HEAD(graveyard);
>  	static u8 gc_state;		/* Internal persistent state */
>  #define KEY_GC_REAP_AGAIN	0x01	/* - Need another cycle */
>  #define KEY_GC_REAPING_LINKS	0x02	/* - We need to reap links */
> @@ -316,15 +324,22 @@ maybe_resched:
>  		key_schedule_gc(new_timer);
>  	}
>  
> -	if (unlikely(gc_state & KEY_GC_REAPING_DEAD_2)) {
> -		/* Make sure everyone revalidates their keys if we marked a
> -		 * bunch as being dead and make sure all keyring ex-payloads
> -		 * are destroyed.
> +	if (unlikely(gc_state & KEY_GC_REAPING_DEAD_2) ||
> +	    !list_empty(&graveyard)) {
> +		/* Make sure that all pending keyring payload destructions are
> +		 * fulfilled and that people aren't now looking at dead or
> +		 * dying keys that they don't have a reference upon or a link
> +		 * to.
>  		 */
> -		kdebug("dead sync");
> +		kdebug("gc sync");
>  		synchronize_rcu();
>  	}
>  
> +	if (!list_empty(&graveyard)) {
> +		kdebug("gc keys");
> +		key_gc_unused_keys(&graveyard);
> +	}
> +
>  	if (unlikely(gc_state & (KEY_GC_REAPING_DEAD_1 |
>  				 KEY_GC_REAPING_DEAD_2))) {
>  		if (!(gc_state & KEY_GC_FOUND_DEAD_KEY)) {
> @@ -359,7 +374,7 @@ found_unreferenced_key:
>  	rb_erase(&key->serial_node, &key_serial_tree);
>  	spin_unlock(&key_serial_lock);
>  
> -	key_gc_unused_key(key);
> +	list_add_tail(&key->graveyard_link, &graveyard);
>  	gc_state |= KEY_GC_REAP_AGAIN;
>  	goto maybe_resched;
>  
> 
> _______________________________________________
> Keyrings mailing list
> Keyrings@linux-nfs.org
> To change your subscription to this list, please see http://linux-nfs.org/cgi-bin/mailman/listinfo/keyrings

Not what I'd call straightforward code, but I think it looks correct...

Acked-by: Jeff Layton <jlayton@redhat.com>
