Return-Path: <jlayton@redhat.com>
Message-ID: <1501618320.4702.14.camel@redhat.com>
Subject: Re: [PATCH] NFSv4: Don't add a new lock on an interrupted wait for
 LOCK
From: Jeff Layton <jlayton@redhat.com>
To: Benjamin Coddington <bcodding@redhat.com>, Trond Myklebust
 <trond.myklebust@primarydata.com>, Anna Schumaker
 <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Date: Tue, 01 Aug 2017 16:12:00 -0400
In-Reply-To: <52d3e3b1547ca33b59349c40ae5236bbb8993729.1500658655.git.bcodding@redhat.com>
References: 
	<52d3e3b1547ca33b59349c40ae5236bbb8993729.1500658655.git.bcodding@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2017-07-21 at 13:38 -0400, Benjamin Coddington wrote:
> If the wait for a LOCK operation is interrupted, and then the file is
> closed, the locks cleanup code will assume that no new locks will be added
> to the inode after it has completed.  We already have a mechanism to detect
> if there was an interrupt, so let's use that to avoid recreating the local
> lock once the RPC completes.
> 

nit: "if there was a signal"

> Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
> ---
>  fs/nfs/nfs4proc.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index dbfa18900e25..5256f429c268 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -6100,7 +6100,7 @@ static void nfs4_lock_done(struct rpc_task *task, void *calldata)
>  	case 0:
>  		renew_lease(NFS_SERVER(d_inode(data->ctx->dentry)),
>  				data->timestamp);
> -		if (data->arg.new_lock) {
> +		if (data->arg.new_lock && !data->cancelled) {
>  			data->fl.fl_flags &= ~(FL_SLEEP | FL_ACCESS);
>  			if (locks_lock_inode_wait(lsp->ls_state->inode, &data->fl) < 0) {
>  				rpc_restart_call_prepare(task);

Patch looks fine though:

Reviewed-by: Jeff Layton <jlayton@redhat.com>
