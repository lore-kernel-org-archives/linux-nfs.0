Return-Path: <jlayton@redhat.com>
Message-ID: <1476275602.2541.20.camel@redhat.com>
Subject: Re: [PATCH 3/5] NFSv4: change nfs4_select_rw_stateid to take a
 lock_context inplace of lock_owner
From: Jeff Layton <jlayton@redhat.com>
To: NeilBrown <neilb@suse.com>,
        Trond Myklebust
 <trond.myklebust@primarydata.com>,
        Anna Schumaker
 <anna.schumaker@netapp.com>
Cc: Benjamin Coddington <bcodding@redhat.com>,
        Linux NFS Mailing List
	 <linux-nfs@vger.kernel.org>
Date: Wed, 12 Oct 2016 08:33:22 -0400
In-Reply-To: <147623995856.19592.8461168656619949864.stgit@noble>
References: <147623977637.19592.12766016823334433969.stgit@noble>
	 <147623995856.19592.8461168656619949864.stgit@noble>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2016-10-12 at 13:39 +1100, NeilBrown wrote:
> The only time that a lock_context is not available is in setattr.
> In this case, we want to find a lock context relevant to the process if there is one.
> The fallback can easily be handled at a lower level.
> 
> So change nfs4_select_rw_stateid to take a lock_context, passing NULL from _nfs4_do_setattr.
> nfs4_copy_lock_state() also now takes a lock_context, and falls back to searching
> for "owner == current->files" if not lock_context is given.
> 
> Note that nfs4_set_rw_stateid is *always* passed a non-NULL l_ctx, so the
> fact that we remove the NULL test there does not change correctness.
> 
> This change is preparation for correctly support flock stateids.
> 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  fs/nfs/nfs4_fs.h   |    2 +-
>  fs/nfs/nfs4proc.c  |   11 ++---------
>  fs/nfs/nfs4state.c |   19 +++++++++++--------
>  3 files changed, 14 insertions(+), 18 deletions(-)
> 
> diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
> index 9bf64eacba5b..3f0e459f2499 100644
> --- a/fs/nfs/nfs4_fs.h
> +++ b/fs/nfs/nfs4_fs.h
> @@ -445,7 +445,7 @@ extern void nfs41_handle_server_scope(struct nfs_client *,
>  extern void nfs4_put_lock_state(struct nfs4_lock_state *lsp);
>  extern int nfs4_set_lock_state(struct nfs4_state *state, struct file_lock *fl);
>  extern int nfs4_select_rw_stateid(struct nfs4_state *, fmode_t,
> -		const struct nfs_lockowner *, nfs4_stateid *,
> +		const struct nfs_lock_context *, nfs4_stateid *,
>  		struct rpc_cred **);
>  
>  extern struct nfs_seqid *nfs_alloc_seqid(struct nfs_seqid_counter *counter, gfp_t gfp_mask);
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 422ed5ac4efe..6820c44aebe4 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -2764,12 +2764,9 @@ static int _nfs4_do_setattr(struct inode *inode,
>  	if (nfs4_copy_delegation_stateid(inode, fmode, &arg->stateid, &delegation_cred)) {
>  		/* Use that stateid */
>  	} else if (truncate && state != NULL) {
> -		struct nfs_lockowner lockowner = {
> -			.l_owner = current->files,
> -		};
>  		if (!nfs4_valid_open_stateid(state))
>  			return -EBADF;
> -		if (nfs4_select_rw_stateid(state, FMODE_WRITE, &lockowner,
> +		if (nfs4_select_rw_stateid(state, FMODE_WRITE, NULL,
>  				&arg->stateid, &delegation_cred) == -EIO)
>  			return -EBADF;
>  	} else
> @@ -4362,11 +4359,7 @@ int nfs4_set_rw_stateid(nfs4_stateid *stateid,
>  		const struct nfs_lock_context *l_ctx,
>  		fmode_t fmode)
>  {
> -	const struct nfs_lockowner *lockowner = NULL;
> -
> -	if (l_ctx != NULL)
> -		lockowner = &l_ctx->lockowner;
> -	return nfs4_select_rw_stateid(ctx->state, fmode, lockowner, stateid, NULL);
> +	return nfs4_select_rw_stateid(ctx->state, fmode, l_ctx, stateid, NULL);
>  }
>  EXPORT_SYMBOL_GPL(nfs4_set_rw_stateid);
>  
> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
> index cada00aa5096..94a6631e7938 100644
> --- a/fs/nfs/nfs4state.c
> +++ b/fs/nfs/nfs4state.c
> @@ -939,20 +939,23 @@ int nfs4_set_lock_state(struct nfs4_state *state, struct file_lock *fl)
>  
>  static int nfs4_copy_lock_stateid(nfs4_stateid *dst,
>  		struct nfs4_state *state,
> -		const struct nfs_lockowner *lockowner)
> +		const struct nfs_lock_context *l_ctx)
>  {
> +	/*
> +	 * If l_ctx is NULL, then this request comes from setattr
> +	 * and we can choose a lock context relevant for the current process
> +	 */
>  	struct nfs4_lock_state *lsp;
>  	fl_owner_t fl_owner;
>  	int ret = -ENOENT;
>  
> -
> -	if (lockowner == NULL)
> -		goto out;
> -
>  	if (test_bit(LK_STATE_IN_USE, &state->flags) == 0)
>  		goto out;
>  
> -	fl_owner = lockowner->l_owner;
> +	if (l_ctx == NULL)
> +		fl_owner = current->files;
> +	else
> +		fl_owner = l_ctx->lockowner.l_owner;


This I'm less sure of. Suppose we have only a flock lock on a file and
then truncate it. This is going to miss finding that stateid, no?

I wonder if we need to look harder at the state to determine which owner to use in this case?


>  	spin_lock(&state->state_lock);
>  	lsp = __nfs4_find_lock_state(state, fl_owner);
>  	if (lsp && test_bit(NFS_LOCK_LOST, &lsp->ls_flags))
> @@ -986,14 +989,14 @@ static void nfs4_copy_open_stateid(nfs4_stateid *dst, struct nfs4_state *state)
>   * requests.
>   */
>  int nfs4_select_rw_stateid(struct nfs4_state *state,
> -		fmode_t fmode, const struct nfs_lockowner *lockowner,
> +		fmode_t fmode, const struct nfs_lock_context *l_ctx,
>  		nfs4_stateid *dst, struct rpc_cred **cred)
>  {
>  	int ret;
>  
>  	if (cred != NULL)
>  		*cred = NULL;
> -	ret = nfs4_copy_lock_stateid(dst, state, lockowner);
> +	ret = nfs4_copy_lock_stateid(dst, state, l_ctx);
>  	if (ret == -EIO)
>  		/* A lost lock - don't even consider delegations */
>  		goto out;
> 
> 

Also, as a side note: There were some changes around the NFS file
locking code that went into the CB_NOTIFY_LOCK patches. Those are in
linux-next now, and I _think_ Anna is going to merge them for v4.9. I
don't see any obvious conflicts here, but you may want to ensure that
you're basing this on top of linux-next to minimize them.

-- 
Jeff Layton <jlayton@redhat.com>
