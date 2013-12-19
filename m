Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:47862 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755798Ab3LSTc1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 Dec 2013 14:32:27 -0500
Date: Thu, 19 Dec 2013 14:32:25 -0500
To: Benny Halevy <bhalevy@primarydata.com>
Cc: bfields@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 1/2] nfsd4: break from inner lookup loop in
 nfsd4_release_lockowner on first match
Message-ID: <20131219193225.GC6951@fieldses.org>
References: <52ADCFC2.7060504@gmail.com>
 <1387122710-23603-1-git-send-email-bhalevy@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1387122710-23603-1-git-send-email-bhalevy@primarydata.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Dec 15, 2013 at 05:51:50PM +0200, Benny Halevy wrote:
> Otherwise the lockowner may by added to "matches" more than once.
> 
> Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
> ---
>  fs/nfsd/nfs4state.c | 17 +++++++++++------
>  1 file changed, 11 insertions(+), 6 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 0874998..b04f765 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -4192,6 +4192,7 @@ alloc_init_lock_stateowner(unsigned int strhashval, struct nfs4_client *clp, str
>  	/* It is the openowner seqid that will be incremented in encode in the
>  	 * case of new lockowners; so increment the lock seqid manually: */
>  	lo->lo_owner.so_seqid = lock->lk_new_lock_seqid + 1;
> +	INIT_LIST_HEAD(&lo->lo_list);

This doesn't really fix any bug--we don't depend on this list head being
initialized anywhere as far as I can see.  If you think it's useful
anyway fo rdebugging purposes or something, that's fine, but stick this
in a separate patch from the actual bugfix.

>  	hash_lockowner(lo, strhashval, clp, open_stp);
>  	return lo;
>  }
> @@ -4646,7 +4647,6 @@ nfsd4_release_lockowner(struct svc_rqst *rqstp,
>  	if (status)
>  		goto out;
>  
> -	status = nfserr_locks_held;
>  	INIT_LIST_HEAD(&matches);
>  
>  	list_for_each_entry(sop, &nn->ownerstr_hashtbl[hashval], so_strhash) {
> @@ -4654,25 +4654,30 @@ nfsd4_release_lockowner(struct svc_rqst *rqstp,
>  			continue;
>  		if (!same_owner_str(sop, owner, clid))
>  			continue;
> +		lo = lockowner(sop);
>  		list_for_each_entry(stp, &sop->so_stateids,
>  				st_perstateowner) {
> -			lo = lockowner(sop);
> -			if (check_for_locks(stp->st_file, lo))
> -				goto out;
> +			if (check_for_locks(stp->st_file, lo)) {
> +				status = nfserr_locks_held;
> +				goto locks_held;
> +			}
>  			list_add(&lo->lo_list, &matches);
> +			break;

I'm a little lost here: it looks like if sop->so_stateids has more than
one entry, then we'll decide to release lo just because the first entry
doesn't have any associated locks (when subsequent entries still might).

Instead of breaking at the end I think you just want to move the
list_add after the loop, to ensure that we check all the stateid's.

>  		}
>  	}
>  	/* Clients probably won't expect us to return with some (but not all)
>  	 * of the lockowner state released; so don't release any until all
>  	 * have been checked. */
>  	status = nfs_ok;
> +locks_held:
>  	while (!list_empty(&matches)) {
> -		lo = list_entry(matches.next, struct nfs4_lockowner,
> +		lo = list_first_entry(&matches, struct nfs4_lockowner,
>  								lo_list);
>  		/* unhash_stateowner deletes so_perclient only
>  		 * for openowners. */
>  		list_del(&lo->lo_list);
> -		release_lockowner(lo);
> +		if (status == nfs_ok)
> +			release_lockowner(lo);

Again, we don't depend on lo_list being initialized anywhere, so this is
really a sort of cleanup unrelated to this bugfix.

And if you think it may be asking for trouble to leave lo_list on a list
that doesn't exist any more, OK, but make that argument in a separate
patch.

--b.

>  	}
>  out:
>  	nfs4_unlock_state();
> -- 
> 1.8.3.1
> 
