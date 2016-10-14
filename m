Return-Path: <jlayton@redhat.com>
Message-ID: <1476442146.2546.1.camel@redhat.com>
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
Date: Fri, 14 Oct 2016 06:49:06 -0400
In-Reply-To: <87shrzzsnq.fsf@notabene.neil.brown.name>
References: <147633263771.766.17853370901003798934.stgit@noble>
	 <147633280755.766.16463067741350482818.stgit@noble>
	 <1476372136.12134.12.camel@redhat.com>
	 <87shrzzsnq.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2016-10-14 at 11:22 +1100, NeilBrown wrote:
> On Fri, Oct 14 2016, Jeff Layton wrote:
> 
> > 
> > On Thu, 2016-10-13 at 15:26 +1100, NeilBrown wrote:
> > > 
> > > A process can have two possible lock owner for a given open file:
> > > a per-process Posix lock owner and a per-open-file flock owner
> > > Use both of these when searching for a suitable stateid to use.
> > > 
> > > With this patch, READ/WRITE requests will use the correct stateid
> > > if a flock lock is active.
> > > 
> > > Signed-off-by: NeilBrown <neilb@suse.com>
> > > ---
> > >  fs/nfs/nfs4state.c |   14 +++++++++-----
> > >  1 file changed, 9 insertions(+), 5 deletions(-)
> > > 
> > > diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
> > > index f25eee8202bf..ed39ee164f5f 100644
> > > --- a/fs/nfs/nfs4state.c
> > > +++ b/fs/nfs/nfs4state.c
> > > @@ -800,11 +800,13 @@ void nfs4_close_sync(struct nfs4_state *state, fmode_t fmode)
> > >   * that is compatible with current->files
> > >   */
> > >  static struct nfs4_lock_state *
> > > -__nfs4_find_lock_state(struct nfs4_state *state, fl_owner_t fl_owner)
> > > +__nfs4_find_lock_state(struct nfs4_state *state,
> > > +		       fl_owner_t fl_owner, fl_owner_t fl_owner2)
> > >  {
> > >  	struct nfs4_lock_state *pos;
> > >  	list_for_each_entry(pos, &state->lock_states, ls_locks) {
> > > -		if (pos->ls_owner != fl_owner)
> > > +		if (pos->ls_owner != fl_owner &&
> > > +		    pos->ls_owner != fl_owner2)
> > >  			continue;
> > >  		atomic_inc(&pos->ls_count);
> > >  		return pos;
> > 
> > Ok, so we end up getting whatever is first on the list here. That's
> > certainly fine when there are either flock/OFD locks or traditional
> > POSIX locks in use.
> > 
> > When there are both in use though, then things may be less predictable.
> > That said, mixing flock/OFD and POSIX locks on the same fds from the
> > same process is not a great idea in general, and I have a hard time
> > coming up with a valid use-case there.
> 
> Using two types of locks in the one application would be ... unusual.
> I wouldn't want to spend much of addressing any issues, but not being
> predictable isn't good.  Intermittent problems are so hard to debug.
> 
> We should probably make sure it consistently chooses on or the other.
> As flock locks are always whole-file, it is always safe to choose the
> flock lock over the posix lock as you can be sure the IO is covered by
> the lock. OFD locks make that a little be less of a clear choice.
> 
> On the other hand, NFS locks were originally only Posix locks and flock
> locks were only supported much later.  So for historical consistency we
> should probably choose the Posix stateid preferentially.
> 
> I find the second argument more convincing.   Here is the updated patch.
> 
> Thanks,
> NeilBrown
> 
> From: NeilBrown <neilb@suse.com>
> Subject: [PATCH] NFSv4: enhance nfs4_copy_lock_stateid to use a flock stateid
>  if there is one
> 
> A process can have two possible lock owner for a given open file:
> a per-process Posix lock owner and a per-open-file flock owner
> Use both of these when searching for a suitable stateid to use.
> 
> With this patch, READ/WRITE requests will use the correct stateid
> if a flock lock is active.
> 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  fs/nfs/nfs4state.c | 38 +++++++++++++++++++++++++++-----------
>  1 file changed, 27 insertions(+), 11 deletions(-)
> 
> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
> index f25eee8202bf..bd29d4360660 100644
> --- a/fs/nfs/nfs4state.c
> +++ b/fs/nfs/nfs4state.c
> @@ -797,19 +797,33 @@ void nfs4_close_sync(struct nfs4_state *state, fmode_t fmode)
>  
>  /*
>   * Search the state->lock_states for an existing lock_owner
> - * that is compatible with current->files
> + * that is compatible with either of the given owners.
> + * If the second is non-zero, then the first refers to a Posix-lock
> + * owner (current->files) and the second refers to a flock/OFD
> + * owner (struct file*).  In that case, prefer a match for the first
> + * owner.
> + * If both sorts of locks are held on the one file we cannot know
> + * which stateid was intended to be used, so a "correct" choice cannot
> + * be made.  Failing that, a "consistent" choice is preferable.  The
> + * consistent choice we make is to prefer the first owner, that of a
> + * Posix lock.
>   */
>  static struct nfs4_lock_state *
> -__nfs4_find_lock_state(struct nfs4_state *state, fl_owner_t fl_owner)
> +__nfs4_find_lock_state(struct nfs4_state *state,
> +		       fl_owner_t fl_owner, fl_owner_t fl_owner2)
>  {
> -	struct nfs4_lock_state *pos;
> +	struct nfs4_lock_state *pos, *ret = NULL;
>  	list_for_each_entry(pos, &state->lock_states, ls_locks) {
> -		if (pos->ls_owner != fl_owner)
> -			continue;
> -		atomic_inc(&pos->ls_count);
> -		return pos;
> +		if (pos->ls_owner == fl_owner) {
> +			ret = pos;
> +			break;
> +		}
> +		if (pos->ls_owner == fl_owner2)
> +			ret = pos;
>  	}
> -	return NULL;
> +	if (ret)
> +		atomic_inc(&ret->ls_count);
> +	return ret;
>  }
>  
>  /*
> @@ -857,7 +871,7 @@ static struct nfs4_lock_state *nfs4_get_lock_state(struct nfs4_state *state, fl_
>  	
>  	for(;;) {
>  		spin_lock(&state->state_lock);
> -		lsp = __nfs4_find_lock_state(state, owner);
> +		lsp = __nfs4_find_lock_state(state, owner, 0);
>  		if (lsp != NULL)
>  			break;
>  		if (new != NULL) {
> @@ -942,7 +956,7 @@ static int nfs4_copy_lock_stateid(nfs4_stateid *dst,
>  		const struct nfs_lock_context *l_ctx)
>  {
>  	struct nfs4_lock_state *lsp;
> -	fl_owner_t fl_owner;
> +	fl_owner_t fl_owner, fl_flock_owner;
>  	int ret = -ENOENT;
>  
>  	if (l_ctx == NULL)
> @@ -952,8 +966,10 @@ static int nfs4_copy_lock_stateid(nfs4_stateid *dst,
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

Predictable behavior is even better there, and I agree that picking
POSIX locks over flock/OFD makes more sense for historical reasons.

Reviewed-by: Jeff Layton <jlayton@redhat.com>
