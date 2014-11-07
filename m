Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:39790 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753244AbaKGVyr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 7 Nov 2014 16:54:47 -0500
Date: Fri, 7 Nov 2014 16:54:40 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: hch@infradead.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2] nfsd: convert nfs4_file searches to use RCU
Message-ID: <20141107215440.GC5723@fieldses.org>
References: <1413541275-3884-1-git-send-email-jlayton@primarydata.com>
 <1414065662-23341-1-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1414065662-23341-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 23, 2014 at 08:01:02AM -0400, Jeff Layton wrote:
> The global state_lock protects the file_hashtbl, and that has the
> potential to be a scalability bottleneck.
> 
> Address this by making the file_hashtbl use RCU. Add a rcu_head to the
> nfs4_file and use that when freeing ones that have been hashed. In order
> to conserve space, we union the fi_rcu field with the fi_delegations
> list_head which must be clear by the time the last reference to the file
> is dropped.
> 
> Convert find_file_locked to use RCU lookup primitives and not to require
> that the state_lock be held, and convert find_file to do a lockless
> lookup. Convert find_or_add_file to attempt a lockless lookup first, and
> then fall back to doing a locked search and insert if that fails to find
> anything.
> 
> Also, minimize the number of times we need to calculate the hash value
> by passing it in as an argument to the search and insert functions, and
> optimize the order of arguments in nfsd4_init_file.

OK, looks fine, thanks.  Applying for 3.19.

In general though I'd like to see more evidence when we're making
changes for performance reasons.

--b.

> 
> Cc: Christoph Hellwig <hch@infradead.org>
> Signed-off-by: Jeff Layton <jlayton@primarydata.com>
> ---
>  fs/nfsd/nfs4state.c | 51 +++++++++++++++++++++++++++++----------------------
>  fs/nfsd/state.h     |  5 ++++-
>  2 files changed, 33 insertions(+), 23 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 1afd7d4420bd..1379d86f7b4f 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -275,9 +275,11 @@ opaque_hashval(const void *ptr, int nbytes)
>  	return x;
>  }
>  
> -static void nfsd4_free_file(struct nfs4_file *f)
> +static void nfsd4_free_file_rcu(struct rcu_head *rcu)
>  {
> -	kmem_cache_free(file_slab, f);
> +	struct nfs4_file *fp = container_of(rcu, struct nfs4_file, fi_rcu);
> +
> +	kmem_cache_free(file_slab, fp);
>  }
>  
>  static inline void
> @@ -286,9 +288,10 @@ put_nfs4_file(struct nfs4_file *fi)
>  	might_lock(&state_lock);
>  
>  	if (atomic_dec_and_lock(&fi->fi_ref, &state_lock)) {
> -		hlist_del(&fi->fi_hash);
> +		hlist_del_rcu(&fi->fi_hash);
>  		spin_unlock(&state_lock);
> -		nfsd4_free_file(fi);
> +		WARN_ON_ONCE(!list_empty(&fi->fi_delegations));
> +		call_rcu(&fi->fi_rcu, nfsd4_free_file_rcu);
>  	}
>  }
>  
> @@ -3057,10 +3060,9 @@ static struct nfs4_file *nfsd4_alloc_file(void)
>  }
>  
>  /* OPEN Share state helper functions */
> -static void nfsd4_init_file(struct nfs4_file *fp, struct knfsd_fh *fh)
> +static void nfsd4_init_file(struct knfsd_fh *fh, unsigned int hashval,
> +				struct nfs4_file *fp)
>  {
> -	unsigned int hashval = file_hashval(fh);
> -
>  	lockdep_assert_held(&state_lock);
>  
>  	atomic_set(&fp->fi_ref, 1);
> @@ -3073,7 +3075,7 @@ static void nfsd4_init_file(struct nfs4_file *fp, struct knfsd_fh *fh)
>  	fp->fi_share_deny = 0;
>  	memset(fp->fi_fds, 0, sizeof(fp->fi_fds));
>  	memset(fp->fi_access, 0, sizeof(fp->fi_access));
> -	hlist_add_head(&fp->fi_hash, &file_hashtbl[hashval]);
> +	hlist_add_head_rcu(&fp->fi_hash, &file_hashtbl[hashval]);
>  }
>  
>  void
> @@ -3294,17 +3296,14 @@ move_to_close_lru(struct nfs4_ol_stateid *s, struct net *net)
>  
>  /* search file_hashtbl[] for file */
>  static struct nfs4_file *
> -find_file_locked(struct knfsd_fh *fh)
> +find_file_locked(struct knfsd_fh *fh, unsigned int hashval)
>  {
> -	unsigned int hashval = file_hashval(fh);
>  	struct nfs4_file *fp;
>  
> -	lockdep_assert_held(&state_lock);
> -
> -	hlist_for_each_entry(fp, &file_hashtbl[hashval], fi_hash) {
> +	hlist_for_each_entry_rcu(fp, &file_hashtbl[hashval], fi_hash) {
>  		if (nfsd_fh_match(&fp->fi_fhandle, fh)) {
> -			get_nfs4_file(fp);
> -			return fp;
> +			if (atomic_inc_not_zero(&fp->fi_ref))
> +				return fp;
>  		}
>  	}
>  	return NULL;
> @@ -3314,10 +3313,11 @@ static struct nfs4_file *
>  find_file(struct knfsd_fh *fh)
>  {
>  	struct nfs4_file *fp;
> +	unsigned int hashval = file_hashval(fh);
>  
> -	spin_lock(&state_lock);
> -	fp = find_file_locked(fh);
> -	spin_unlock(&state_lock);
> +	rcu_read_lock();
> +	fp = find_file_locked(fh, hashval);
> +	rcu_read_unlock();
>  	return fp;
>  }
>  
> @@ -3325,11 +3325,18 @@ static struct nfs4_file *
>  find_or_add_file(struct nfs4_file *new, struct knfsd_fh *fh)
>  {
>  	struct nfs4_file *fp;
> +	unsigned int hashval = file_hashval(fh);
> +
> +	rcu_read_lock();
> +	fp = find_file_locked(fh, hashval);
> +	rcu_read_unlock();
> +	if (fp)
> +		return fp;
>  
>  	spin_lock(&state_lock);
> -	fp = find_file_locked(fh);
> -	if (fp == NULL) {
> -		nfsd4_init_file(new, fh);
> +	fp = find_file_locked(fh, hashval);
> +	if (likely(fp == NULL)) {
> +		nfsd4_init_file(fh, hashval, new);
>  		fp = new;
>  	}
>  	spin_unlock(&state_lock);
> @@ -4127,7 +4134,7 @@ void nfsd4_cleanup_open_state(struct nfsd4_compound_state *cstate,
>  		nfs4_put_stateowner(so);
>  	}
>  	if (open->op_file)
> -		nfsd4_free_file(open->op_file);
> +		kmem_cache_free(file_slab, open->op_file);
>  	if (open->op_stp)
>  		nfs4_put_stid(&open->op_stp->st_stid);
>  }
> diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
> index 8e85e07efce6..9d3be371240a 100644
> --- a/fs/nfsd/state.h
> +++ b/fs/nfsd/state.h
> @@ -477,7 +477,10 @@ struct nfs4_file {
>  	spinlock_t		fi_lock;
>  	struct hlist_node       fi_hash;	/* hash on fi_fhandle */
>  	struct list_head        fi_stateids;
> -	struct list_head	fi_delegations;
> +	union {
> +		struct list_head	fi_delegations;
> +		struct rcu_head		fi_rcu;
> +	};
>  	/* One each for O_RDONLY, O_WRONLY, O_RDWR: */
>  	struct file *		fi_fds[3];
>  	/*
> -- 
> 1.9.3
> 
