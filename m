Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:35724 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755523AbbIUBEK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 20 Sep 2015 21:04:10 -0400
Received: by pacfv12 with SMTP id fv12so102759304pac.2
        for <linux-nfs@vger.kernel.org>; Sun, 20 Sep 2015 18:04:09 -0700 (PDT)
Subject: Re: [PATCH] NFSv4: Recovery of recalled read delegations is broken
To: Trond Myklebust <trond.myklebust@primarydata.com>
References: <55FA8D22.2010003@gmail.com>
 <87fv294r5u.fsf@notabene.neil.brown.name> <55FE82D9.4040305@gmail.com>
 <1442766380-45695-1-git-send-email-trond.myklebust@primarydata.com>
Cc: NeilBrown <neilb@suse.com>, linux-nfs@vger.kernel.org,
        kinglongmee@gmail.com
From: Kinglong Mee <kinglongmee@gmail.com>
Message-ID: <55FF577F.9060302@gmail.com>
Date: Mon, 21 Sep 2015 09:03:59 +0800
MIME-Version: 1.0
In-Reply-To: <1442766380-45695-1-git-send-email-trond.myklebust@primarydata.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 9/21/2015 00:26, Trond Myklebust wrote:
> When a read delegation is being recalled, and we're reclaiming the
> cached opens, we need to make sure that we only reclaim read-only
> modes.
> A previous attempt to do this, relied on retrieving the delegation
> type from the nfs4_opendata structure. Unfortunately, as Kinglong
> pointed out, this field can only be set when performing reboot recovery.
> 
> Furthermore, if we call nfs4_open_recover(), then we end up clobbering
> the state->flags for all modes that we're not recovering...
> 
> The fix is to have the delegation recall code pass this information
> to the recovery call, and then refactor the recovery code so that
> nfs4_open_delegation_recall() does not need to call nfs4_open_recover().
> 
> Reported-by: Kinglong Mee <kinglongmee@gmail.com>
> Fixes: 39f897fdbd46 ("NFSv4: When returning a delegation, don't...")
> Cc: NeilBrown <neilb@suse.com>
> Cc: stable@vger.kernel.org # v4.2+
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>

Tested-by: Kinglong Mee <kinglongmee@gmail.com>

thanks,
Kinglong Mee

> ---
>  fs/nfs/delegation.c |  8 ++++--
>  fs/nfs/delegation.h |  2 +-
>  fs/nfs/nfs4proc.c   | 81 +++++++++++++++++++++++++++++++----------------------
>  3 files changed, 53 insertions(+), 38 deletions(-)
> 
> diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
> index 2714ef835bdd..be806ead7f4d 100644
> --- a/fs/nfs/delegation.c
> +++ b/fs/nfs/delegation.c
> @@ -113,7 +113,8 @@ out:
>  	return status;
>  }
>  
> -static int nfs_delegation_claim_opens(struct inode *inode, const nfs4_stateid *stateid)
> +static int nfs_delegation_claim_opens(struct inode *inode,
> +		const nfs4_stateid *stateid, fmode_t type)
>  {
>  	struct nfs_inode *nfsi = NFS_I(inode);
>  	struct nfs_open_context *ctx;
> @@ -140,7 +141,7 @@ again:
>  		/* Block nfs4_proc_unlck */
>  		mutex_lock(&sp->so_delegreturn_mutex);
>  		seq = raw_seqcount_begin(&sp->so_reclaim_seqcount);
> -		err = nfs4_open_delegation_recall(ctx, state, stateid);
> +		err = nfs4_open_delegation_recall(ctx, state, stateid, type);
>  		if (!err)
>  			err = nfs_delegation_claim_locks(ctx, state, stateid);
>  		if (!err && read_seqcount_retry(&sp->so_reclaim_seqcount, seq))
> @@ -411,7 +412,8 @@ static int nfs_end_delegation_return(struct inode *inode, struct nfs_delegation
>  	do {
>  		if (test_bit(NFS_DELEGATION_REVOKED, &delegation->flags))
>  			break;
> -		err = nfs_delegation_claim_opens(inode, &delegation->stateid);
> +		err = nfs_delegation_claim_opens(inode, &delegation->stateid,
> +				delegation->type);
>  		if (!issync || err != -EAGAIN)
>  			break;
>  		/*
> diff --git a/fs/nfs/delegation.h b/fs/nfs/delegation.h
> index a44829173e57..333063e032f0 100644
> --- a/fs/nfs/delegation.h
> +++ b/fs/nfs/delegation.h
> @@ -54,7 +54,7 @@ void nfs_delegation_reap_unclaimed(struct nfs_client *clp);
>  
>  /* NFSv4 delegation-related procedures */
>  int nfs4_proc_delegreturn(struct inode *inode, struct rpc_cred *cred, const nfs4_stateid *stateid, int issync);
> -int nfs4_open_delegation_recall(struct nfs_open_context *ctx, struct nfs4_state *state, const nfs4_stateid *stateid);
> +int nfs4_open_delegation_recall(struct nfs_open_context *ctx, struct nfs4_state *state, const nfs4_stateid *stateid, fmode_t type);
>  int nfs4_lock_delegation_recall(struct file_lock *fl, struct nfs4_state *state, const nfs4_stateid *stateid);
>  bool nfs4_copy_delegation_stateid(nfs4_stateid *dst, struct inode *inode, fmode_t flags);
>  
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 693b903b48bd..099a0a83ee8d 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -1127,6 +1127,21 @@ static int nfs4_wait_for_completion_rpc_task(struct rpc_task *task)
>  	return ret;
>  }
>  
> +static bool nfs4_mode_match_open_stateid(struct nfs4_state *state,
> +		fmode_t fmode)
> +{
> +	switch(fmode & (FMODE_READ|FMODE_WRITE)) {
> +	case FMODE_READ|FMODE_WRITE:
> +		return state->n_rdwr != 0;
> +	case FMODE_WRITE:
> +		return state->n_wronly != 0;
> +	case FMODE_READ:
> +		return state->n_rdonly != 0;
> +	}
> +	WARN_ON_ONCE(1);
> +	return false;
> +}
> +
>  static int can_open_cached(struct nfs4_state *state, fmode_t mode, int open_mode)
>  {
>  	int ret = 0;
> @@ -1571,17 +1586,13 @@ static struct nfs4_opendata *nfs4_open_recoverdata_alloc(struct nfs_open_context
>  	return opendata;
>  }
>  
> -static int nfs4_open_recover_helper(struct nfs4_opendata *opendata, fmode_t fmode, struct nfs4_state **res)
> +static int nfs4_open_recover_helper(struct nfs4_opendata *opendata,
> +		fmode_t fmode)
>  {
>  	struct nfs4_state *newstate;
>  	int ret;
>  
> -	if ((opendata->o_arg.claim == NFS4_OPEN_CLAIM_DELEGATE_CUR ||
> -	     opendata->o_arg.claim == NFS4_OPEN_CLAIM_DELEG_CUR_FH) &&
> -	    (opendata->o_arg.u.delegation_type & fmode) != fmode)
> -		/* This mode can't have been delegated, so we must have
> -		 * a valid open_stateid to cover it - not need to reclaim.
> -		 */
> +	if (!nfs4_mode_match_open_stateid(opendata->state, fmode))
>  		return 0;
>  	opendata->o_arg.open_flags = 0;
>  	opendata->o_arg.fmode = fmode;
> @@ -1597,14 +1608,14 @@ static int nfs4_open_recover_helper(struct nfs4_opendata *opendata, fmode_t fmod
>  	newstate = nfs4_opendata_to_nfs4_state(opendata);
>  	if (IS_ERR(newstate))
>  		return PTR_ERR(newstate);
> +	if (newstate != opendata->state)
> +		ret = -ESTALE;
>  	nfs4_close_state(newstate, fmode);
> -	*res = newstate;
> -	return 0;
> +	return ret;
>  }
>  
>  static int nfs4_open_recover(struct nfs4_opendata *opendata, struct nfs4_state *state)
>  {
> -	struct nfs4_state *newstate;
>  	int ret;
>  
>  	/* Don't trigger recovery in nfs_test_and_clear_all_open_stateid */
> @@ -1615,27 +1626,15 @@ static int nfs4_open_recover(struct nfs4_opendata *opendata, struct nfs4_state *
>  	clear_bit(NFS_DELEGATED_STATE, &state->flags);
>  	clear_bit(NFS_OPEN_STATE, &state->flags);
>  	smp_rmb();
> -	if (state->n_rdwr != 0) {
> -		ret = nfs4_open_recover_helper(opendata, FMODE_READ|FMODE_WRITE, &newstate);
> -		if (ret != 0)
> -			return ret;
> -		if (newstate != state)
> -			return -ESTALE;
> -	}
> -	if (state->n_wronly != 0) {
> -		ret = nfs4_open_recover_helper(opendata, FMODE_WRITE, &newstate);
> -		if (ret != 0)
> -			return ret;
> -		if (newstate != state)
> -			return -ESTALE;
> -	}
> -	if (state->n_rdonly != 0) {
> -		ret = nfs4_open_recover_helper(opendata, FMODE_READ, &newstate);
> -		if (ret != 0)
> -			return ret;
> -		if (newstate != state)
> -			return -ESTALE;
> -	}
> +	ret = nfs4_open_recover_helper(opendata, FMODE_READ|FMODE_WRITE);
> +	if (ret != 0)
> +		return ret;
> +	ret = nfs4_open_recover_helper(opendata, FMODE_WRITE);
> +	if (ret != 0)
> +		return ret;
> +	ret = nfs4_open_recover_helper(opendata, FMODE_READ);
> +	if (ret != 0)
> +		return ret;
>  	/*
>  	 * We may have performed cached opens for all three recoveries.
>  	 * Check if we need to update the current stateid.
> @@ -1759,18 +1758,32 @@ static int nfs4_handle_delegation_recall_error(struct nfs_server *server, struct
>  	return err;
>  }
>  
> -int nfs4_open_delegation_recall(struct nfs_open_context *ctx, struct nfs4_state *state, const nfs4_stateid *stateid)
> +int nfs4_open_delegation_recall(struct nfs_open_context *ctx,
> +		struct nfs4_state *state, const nfs4_stateid *stateid,
> +		fmode_t type)
>  {
>  	struct nfs_server *server = NFS_SERVER(state->inode);
>  	struct nfs4_opendata *opendata;
> -	int err;
> +	int err = 0;
>  
>  	opendata = nfs4_open_recoverdata_alloc(ctx, state,
>  			NFS4_OPEN_CLAIM_DELEG_CUR_FH);
>  	if (IS_ERR(opendata))
>  		return PTR_ERR(opendata);
>  	nfs4_stateid_copy(&opendata->o_arg.u.delegation, stateid);
> -	err = nfs4_open_recover(opendata, state);
> +	clear_bit(NFS_DELEGATED_STATE, &state->flags);
> +	switch (type & (FMODE_READ|FMODE_WRITE)) {
> +	case FMODE_READ|FMODE_WRITE:
> +	case FMODE_WRITE:
> +		err = nfs4_open_recover_helper(opendata, FMODE_READ|FMODE_WRITE);
> +		if (err)
> +			break;
> +		err = nfs4_open_recover_helper(opendata, FMODE_WRITE);
> +		if (err)
> +			break;
> +	case FMODE_READ:
> +		err = nfs4_open_recover_helper(opendata, FMODE_READ);
> +	}
>  	nfs4_opendata_put(opendata);
>  	return nfs4_handle_delegation_recall_error(server, state, stateid, err);
>  }
> 
