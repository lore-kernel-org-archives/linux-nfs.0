Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:43070 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1730125AbeG3Umc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 30 Jul 2018 16:42:32 -0400
Message-ID: <8f54af2c943de6e54df41e5c706d71137d3f55b8.camel@kernel.org>
Subject: Re: [PATCH] NFSv4: Fix _nfs4_do_setlk()
From: Jeff Layton <jlayton@kernel.org>
To: Trond Myklebust <trondmy@gmail.com>, linux-nfs@vger.kernel.org
Cc: Kenneth Johansson <ken@kenjo.org>,
        Benjamin Coddington <bcodding@redhat.com>
Date: Mon, 30 Jul 2018 15:06:06 -0400
In-Reply-To: <20180730024052.28026-1-trond.myklebust@hammerspace.com>
References: <20180730024052.28026-1-trond.myklebust@hammerspace.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 2018-07-29 at 22:40 -0400, Trond Myklebust wrote:
> The patch to fix the case where a lock request was interrupted ended up
> changing default handling of errors such as NFS4ERR_DENIED and caused the
> client to immediately resend the lock request. Let's do a partial revert
> of that request so that the default is now to exit, but change the way
> we handle resends to take into account the fact that the user may have
> interrupted the request.
> 
> Reported-by: Kenneth Johansson <ken@kenjo.org>
> Fixes: a3cf9bca2ace ("NFSv4: Don't add a new lock on an interrupted wait..")
> Cc: Benjamin Coddington <bcodding@redhat.com>
> Cc: Jeff Layton <jlayton@kernel.org>
> Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
> ---
>  fs/nfs/nfs4proc.c | 26 +++++++++++++-------------
>  1 file changed, 13 insertions(+), 13 deletions(-)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index f73a8315933f..8e482f634d60 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -6501,34 +6501,34 @@ static void nfs4_lock_done(struct rpc_task *task, void *calldata)
>  		if (data->arg.new_lock && !data->cancelled) {

Not specific to your patch, but I wonder if avoiding setting a lock
record after we've successfully issued a LOCK is the right thing to do
here.

Suppose we issue a LOCK request and it's successful, but the wait for it
is canceled before the reply comes in. The reply then comes in and
data->cancelled is now true and now we don't set the lock.

Eventually we end up calling locks_remove_posix but now there's not a
lock on the local list so we skip sending a LOCKU. Is that a potential
problem?

>  			data->fl.fl_flags &= ~(FL_SLEEP | FL_ACCESS);
>  			if (locks_lock_inode_wait(lsp->ls_state->inode, &data->fl) < 0)
> -				break;
> +				goto out_restart;
>  		}
> -
>  		if (data->arg.new_lock_owner != 0) {
>  			nfs_confirm_seqid(&lsp->ls_seqid, 0);
>  			nfs4_stateid_copy(&lsp->ls_stateid, &data->res.stateid);
>  			set_bit(NFS_LOCK_INITIALIZED, &lsp->ls_flags);
> -			goto out_done;
> -		} else if (nfs4_update_lock_stateid(lsp, &data->res.stateid))
> -			goto out_done;
> -
> +		} else if (!nfs4_update_lock_stateid(lsp, &data->res.stateid))
> +			goto out_restart;
>  		break;
>  	case -NFS4ERR_BAD_STATEID:
>  	case -NFS4ERR_OLD_STATEID:
>  	case -NFS4ERR_STALE_STATEID:
>  	case -NFS4ERR_EXPIRED:
>  		if (data->arg.new_lock_owner != 0) {
> -			if (nfs4_stateid_match(&data->arg.open_stateid,
> +			if (!nfs4_stateid_match(&data->arg.open_stateid,
>  						&lsp->ls_state->open_stateid))
> -				goto out_done;
> -		} else if (nfs4_stateid_match(&data->arg.lock_stateid,
> +				goto out_restart;
> +		} else if (!nfs4_stateid_match(&data->arg.lock_stateid,
>  						&lsp->ls_stateid))
> -				goto out_done;
> +				goto out_restart;
>  	}
> -	if (!data->cancelled)
> -		rpc_restart_call_prepare(task);
>  out_done:
>  	dprintk("%s: done, ret = %d!\n", __func__, data->rpc_status);
> +	return;
> +out_restart:
> +	if (!data->cancelled)
> +		rpc_restart_call_prepare(task);
> +	goto out_done;
>  }
>  
>  static void nfs4_lock_release(void *calldata)
> @@ -6537,7 +6537,7 @@ static void nfs4_lock_release(void *calldata)
>  
>  	dprintk("%s: begin!\n", __func__);
>  	nfs_free_seqid(data->arg.open_seqid);
> -	if (data->cancelled) {
> +	if (data->cancelled && data->rpc_status == 0) {
>  		struct rpc_task *task;
>  		task = nfs4_do_unlck(&data->fl, data->ctx, data->lsp,
>  				data->arg.lock_seqid);

Regardless of the question above, this should fix the most recent
regression, so let's take it for now and we can look at that bit more
closely later.

Reviewed-by: Jeff Layton <jlayton@kernel.org>

