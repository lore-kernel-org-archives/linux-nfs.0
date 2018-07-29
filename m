Return-Path: <jlayton@kernel.org>
Message-ID: <e5e82e872c115e0be5f7ce5df7d2afd2f8a7416a.camel@kernel.org>
Subject: Re: [PATCH] NFSv4: Don't add a new lock on an interrupted wait for
 LOCK
From: Jeff Layton <jlayton@kernel.org>
To: Benjamin Coddington <bcodding@redhat.com>, Trond Myklebust
 <trond.myklebust@primarydata.com>, Anna Schumaker
 <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org, Kenneth Johansson <ken@kenjo.org>
Date: Sun, 29 Jul 2018 10:33:29 -0400
In-Reply-To: <1e2732518f990acac47ef20d936ac8a1200d7a79.1525345895.git.bcodding@redhat.com>
References: 
	<1e2732518f990acac47ef20d936ac8a1200d7a79.1525345895.git.bcodding@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2018-05-03 at 07:12 -0400, Benjamin Coddington wrote:
> If the wait for a LOCK operation is interrupted, and then the file is
> closed, the locks cleanup code will assume that no new locks will be added
> to the inode after it has completed.  We already have a mechanism to detect
> if there was signal, so let's use that to avoid recreating the local lock
> once the RPC completes.  Also skip re-sending the LOCK operation for the
> various error cases if we were signaled.
> 
> Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
> ---
>  fs/nfs/nfs4proc.c | 24 ++++++++++++++----------
>  1 file changed, 14 insertions(+), 10 deletions(-)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 47f3c273245e..1aba009a5ef8 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -6345,32 +6345,36 @@ static void nfs4_lock_done(struct rpc_task *task, void *calldata)
>  	case 0:
>  		renew_lease(NFS_SERVER(d_inode(data->ctx->dentry)),
>  				data->timestamp);
> -		if (data->arg.new_lock) {
> +		if (data->arg.new_lock && !data->cancelled) {
>  			data->fl.fl_flags &= ~(FL_SLEEP | FL_ACCESS);
> -			if (locks_lock_inode_wait(lsp->ls_state->inode, &data->fl) < 0) {
> -				rpc_restart_call_prepare(task);
> +			if (locks_lock_inode_wait(lsp->ls_state->inode, &data->fl) > 0)
>  				break;

It turns out that this patch is causing a problem with non-blocking lock
requests. The issue is that it doesn't handle NFS4ERR_DENIED correctly,
so we just end up requeueing the request over and over again on a non-
blocking lock.

As Trond had pointed out, the sense of the if statement is wrong here,
but there's a different issue as well. In the event that we do race in
the way you're concerned about, we'll end up with a lock set on the
server and no local record of that lock.

What's going to release that lock on the server at that point? AFAICT,
the assumption we've always had is that closing the file will end up
releasing them (via locks_remove_file) in the case where the process is
signaled, but this commit will change that.

If the concern is locks being set on the inode after the filp has
already been closed, then I think we'll need to come up with some other
way to synchronize this.

> -			}
>  		}
> +
>  		if (data->arg.new_lock_owner != 0) {
>  			nfs_confirm_seqid(&lsp->ls_seqid, 0);
>  			nfs4_stateid_copy(&lsp->ls_stateid, &data->res.stateid);
>  			set_bit(NFS_LOCK_INITIALIZED, &lsp->ls_flags);
> -		} else if (!nfs4_update_lock_stateid(lsp, &data->res.stateid))
> -			rpc_restart_call_prepare(task);
> +			goto out_done;
> +		} else if (nfs4_update_lock_stateid(lsp, &data->res.stateid))
> +			goto out_done;
> +
>  		break;
>  	case -NFS4ERR_BAD_STATEID:
>  	case -NFS4ERR_OLD_STATEID:
>  	case -NFS4ERR_STALE_STATEID:
>  	case -NFS4ERR_EXPIRED:
>  		if (data->arg.new_lock_owner != 0) {
> -			if (!nfs4_stateid_match(&data->arg.open_stateid,
> +			if (nfs4_stateid_match(&data->arg.open_stateid,
>  						&lsp->ls_state->open_stateid))
> -				rpc_restart_call_prepare(task);
> -		} else if (!nfs4_stateid_match(&data->arg.lock_stateid,
> +				goto out_done;
> +		} else if (nfs4_stateid_match(&data->arg.lock_stateid,
>  						&lsp->ls_stateid))
> -				rpc_restart_call_prepare(task);
> +				goto out_done;
>  	}
> +	if (!data->cancelled)
> +		rpc_restart_call_prepare(task);


Restarting the task should only be done when we want to poll again for
the lock immediately. In the case of something like NFS4ERR_DENIED, we
don't want to do that right away -- we'd rather the upper layer redrive
a new RPC after it has finished waiting.

> +out_done:
>  	dprintk("%s: done, ret = %d!\n", __func__, data->rpc_status);
>  }
>  

-- 
Jeff Layton <jlayton@kernel.org>
