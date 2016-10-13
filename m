Return-Path: <jlayton@redhat.com>
Message-ID: <1476372136.12134.12.camel@redhat.com>
Subject: Re: [PATCH 5/6] NFSv4: enhance nfs4_copy_lock_stateid to use a
 flock stateid if there is one
From: Jeff Layton <jlayton@redhat.com>
To: NeilBrown <neilb@suse.com>,
        Trond Myklebust
 <trond.myklebust@primarydata.com>,
        Anna Schumaker
 <anna.schumaker@netapp.com>
Cc: Benjamin Coddington <bcodding@redhat.com>,
        Linux NFS Mailing List
	 <linux-nfs@vger.kernel.org>
Date: Thu, 13 Oct 2016 11:22:16 -0400
In-Reply-To: <147633280755.766.16463067741350482818.stgit@noble>
References: <147633263771.766.17853370901003798934.stgit@noble>
	 <147633280755.766.16463067741350482818.stgit@noble>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2016-10-13 at 15:26 +1100, NeilBrown wrote:
> A process can have two possible lock owner for a given open file:
> a per-process Posix lock owner and a per-open-file flock owner
> Use both of these when searching for a suitable stateid to use.
> 
> With this patch, READ/WRITE requests will use the correct stateid
> if a flock lock is active.
> 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  fs/nfs/nfs4state.c |   14 +++++++++-----
>  1 file changed, 9 insertions(+), 5 deletions(-)
> 
> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
> index f25eee8202bf..ed39ee164f5f 100644
> --- a/fs/nfs/nfs4state.c
> +++ b/fs/nfs/nfs4state.c
> @@ -800,11 +800,13 @@ void nfs4_close_sync(struct nfs4_state *state, fmode_t fmode)
>   * that is compatible with current->files
>   */
>  static struct nfs4_lock_state *
> -__nfs4_find_lock_state(struct nfs4_state *state, fl_owner_t fl_owner)
> +__nfs4_find_lock_state(struct nfs4_state *state,
> +		       fl_owner_t fl_owner, fl_owner_t fl_owner2)
>  {
>  	struct nfs4_lock_state *pos;
>  	list_for_each_entry(pos, &state->lock_states, ls_locks) {
> -		if (pos->ls_owner != fl_owner)
> +		if (pos->ls_owner != fl_owner &&
> +		    pos->ls_owner != fl_owner2)
>  			continue;
>  		atomic_inc(&pos->ls_count);
>  		return pos;

Ok, so we end up getting whatever is first on the list here. That's
certainly fine when there are either flock/OFD locks or traditional
POSIX locks in use.

When there are both in use though, then things may be less predictable.
That said, mixing flock/OFD and POSIX locks on the same fds from the
same process is not a great idea in general, and I have a hard time
coming up with a valid use-case there.

So, I don't see that as a real problem, but it may be worth explaining
that rationale in the comment block above this function in case we need
to revisit it later.

> @@ -857,7 +859,7 @@ static struct nfs4_lock_state *nfs4_get_lock_state(struct nfs4_state *state, fl_
>  	
>  	for(;;) {
>  		spin_lock(&state->state_lock);
> -		lsp = __nfs4_find_lock_state(state, owner);
> +		lsp = __nfs4_find_lock_state(state, owner, 0);
>  		if (lsp != NULL)
>  			break;
>  		if (new != NULL) {
> @@ -942,7 +944,7 @@ static int nfs4_copy_lock_stateid(nfs4_stateid *dst,
>  		const struct nfs_lock_context *l_ctx)
>  {
>  	struct nfs4_lock_state *lsp;
> -	fl_owner_t fl_owner;
> +	fl_owner_t fl_owner, fl_flock_owner;
>  	int ret = -ENOENT;
>  
>  	if (l_ctx == NULL)
> @@ -952,8 +954,10 @@ static int nfs4_copy_lock_stateid(nfs4_stateid *dst,
>  		goto out;
>  
>  	fl_owner = l_ctx->lockowner.l_owner;
> +	fl_flock_owner = l_ctx->open_context->flock_owner;
> +
>  	spin_lock(&state->state_lock);
> -	lsp = __nfs4_find_lock_state(state, fl_owner);
> +	lsp = __nfs4_find_lock_state(state, fl_owner, fl_flock_owner);
>  	if (lsp && test_bit(NFS_LOCK_LOST, &lsp->ls_flags))
>  		ret = -EIO;
>  	else if (lsp != NULL && test_bit(NFS_LOCK_INITIALIZED, &lsp->ls_flags) != 0) {
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Jeff Layton <jlayton@redhat.com>
