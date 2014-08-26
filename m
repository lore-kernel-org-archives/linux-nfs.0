Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:56286 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753081AbaHZULP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 26 Aug 2014 16:11:15 -0400
Message-ID: <53FCE9DF.1050407@Netapp.com>
Date: Tue, 26 Aug 2014 16:11:11 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        <linux-nfs@vger.kernel.org>
CC: James Drews <drews@engr.wisc.edu>, <jrs@world.std.com>
Subject: Re: [PATCH v2 1/2] NFSv4: Fix problems with close in the presence
 of a delegation
References: <1409077853-15680-1-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1409077853-15680-1-git-send-email-trond.myklebust@primarydata.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/26/2014 02:30 PM, Trond Myklebust wrote:
> In the presence of delegations, we can no longer assume that the
> state->n_rdwr, state->n_rdonly, state->n_wronly reflect the open
> stateid share mode, and so we need to need to calculate the initial
Nit:  Remove the duplicate "need to" (above).

> value for calldata->arg.fmode using the state->flags.
>
> Reported-by: James Drews <drews@engr.wisc.edu>
> Fixes: 88069f77e1ac5 (NFSv41: Fix a potential state leakage when...)
> Cc: stable@vger.kernel.org # 2.6.33+
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  fs/nfs/nfs4proc.c | 19 +++++++++++++------
>  1 file changed, 13 insertions(+), 6 deletions(-)
>
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 75ae8d22f067..7d67d5b332d4 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -2601,6 +2601,7 @@ static void nfs4_close_prepare(struct rpc_task *task, void *data)
>  	struct nfs4_closedata *calldata = data;
>  	struct nfs4_state *state = calldata->state;
>  	struct inode *inode = calldata->inode;
> +	bool is_rdonly, is_wronly, is_rdwr;
>  	int call_close = 0;
>  
>  	dprintk("%s: begin!\n", __func__);
> @@ -2608,24 +2609,30 @@ static void nfs4_close_prepare(struct rpc_task *task, void *data)
>  		goto out_wait;
>  
>  	task->tk_msg.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_OPEN_DOWNGRADE];
> -	calldata->arg.fmode = FMODE_READ|FMODE_WRITE;
>  	spin_lock(&state->owner->so_lock);
> +	is_rdwr = test_bit(NFS_O_RDWR_STATE, &state->flags);
> +	is_rdonly = test_bit(NFS_O_RDONLY_STATE, &state->flags);
> +	is_wronly = test_bit(NFS_O_WRONLY_STATE, &state->flags);
> +	spin_unlock(&state->owner->so_lock);
> +	/* Calculate the current open share mode */
> +	calldata->arg.fmode = 0;
> +	if (is_rdonly || is_rdwr)
> +		calldata->arg.fmode |= FMODE_READ;
> +	if (is_wronly || is_rdwr)
> +		calldata->arg.fmode |= FMODE_WRITE;
>  	/* Calculate the change in open mode */
>  	if (state->n_rdwr == 0) {
Do we need the owner lock for reading state->n_rdwr, n_rdonly, and n_wronly?

Anna
>  		if (state->n_rdonly == 0) {
> -			call_close |= test_bit(NFS_O_RDONLY_STATE, &state->flags);
> -			call_close |= test_bit(NFS_O_RDWR_STATE, &state->flags);
> +			call_close |= is_rdonly || is_rdwr;
>  			calldata->arg.fmode &= ~FMODE_READ;
>  		}
>  		if (state->n_wronly == 0) {
> -			call_close |= test_bit(NFS_O_WRONLY_STATE, &state->flags);
> -			call_close |= test_bit(NFS_O_RDWR_STATE, &state->flags);
> +			call_close |= is_wronly || is_rdwr;
>  			calldata->arg.fmode &= ~FMODE_WRITE;
>  		}
>  	}
>  	if (!nfs4_valid_open_stateid(state))
>  		call_close = 0;
> -	spin_unlock(&state->owner->so_lock);
>  
>  	if (!call_close) {
>  		/* Note: exit _without_ calling nfs4_close_done */

