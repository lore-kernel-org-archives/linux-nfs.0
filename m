From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: NFSv4.1: Handle NFS4ERR_DELAY on SEQUENCE correctly
Date: Thu, 15 Jul 2010 16:51:00 +0300
Message-ID: <4C3F1244.9060600@panasas.com>
References: <1278971575.14605.5.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jim Rees <rees@umich.edu>, linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:56717 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S933231Ab0GONvG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Jul 2010 09:51:06 -0400
In-Reply-To: <1278971575.14605.5.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jul. 13, 2010, 0:52 +0300, Trond Myklebust <Trond.Myklebust@netapp.com> wrote:
> From: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> In RFC5661, an NFS4ERR_DELAY error on a SEQUENCE operation has the special
> meaning that the server is not finished processing the request. In this
> case we want to just retry the request without touching the slot.
> 
> Also fix a bug whereby we would fail to update the sequence id if the
> server returned any error other than NFS_OK/NFS4ERR_DELAY.
> 
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

Thanks Trond!
I also merged it into the linux-pnfs tree so it gets some more testing
there too.
I'm not sure how exactly the hack I previously had actually worked,
but we did see the warning and nothing seemed to be blocked after that
or gone bad in any other way.

Benny

> ---
> 
>  fs/nfs/nfs4proc.c |   92 ++++++++++++++++++++++++++++++++++++-----------------
>  1 files changed, 62 insertions(+), 30 deletions(-)
> 
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index d6413b4..ba79c0e 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -389,11 +389,12 @@ static void nfs41_sequence_free_slot(struct nfs4_sequence_res *res)
>  	res->sr_slotid = NFS4_MAX_SLOT_TABLE;
>  }
>  
> -static void nfs41_sequence_done(struct nfs4_sequence_res *res)
> +static int nfs41_sequence_done(struct rpc_task *task, struct nfs4_sequence_res *res)
>  {
>  	unsigned long timestamp;
>  	struct nfs4_slot_table *tbl;
>  	struct nfs4_slot *slot;
> +	struct nfs_client *clp;
>  
>  	/*
>  	 * sr_status remains 1 if an RPC level error occurred. The server
> @@ -408,14 +409,16 @@ static void nfs41_sequence_done(struct nfs4_sequence_res *res)
>  	if (res->sr_slotid == NFS4_MAX_SLOT_TABLE)
>  		goto out;
>  
> +	tbl = &res->sr_session->fc_slot_table;
> +	slot = tbl->slots + res->sr_slotid;
> +
>  	/* Check the SEQUENCE operation status */
> -	if (res->sr_status == 0) {
> -		struct nfs_client *clp = res->sr_session->clp;
> -		tbl = &res->sr_session->fc_slot_table;
> -		slot = tbl->slots + res->sr_slotid;
> +	switch (res->sr_status) {
> +	case 0:
>  		/* Update the slot's sequence and clientid lease timer */
>  		++slot->seq_nr;
>  		timestamp = res->sr_renewal_time;
> +		clp = res->sr_session->clp;
>  		spin_lock(&clp->cl_lock);
>  		if (time_before(clp->cl_last_renewal, timestamp))
>  			clp->cl_last_renewal = timestamp;
> @@ -423,18 +426,39 @@ static void nfs41_sequence_done(struct nfs4_sequence_res *res)
>  		/* Check sequence flags */
>  		if (atomic_read(&clp->cl_count) > 1)
>  			nfs41_handle_sequence_flag_errors(clp, res->sr_status_flags);
> +		break;
> +	case -NFS4ERR_DELAY:
> +		/* The server detected a resend of the RPC call and
> +		 * returned NFS4ERR_DELAY as per Section 2.10.6.2
> +		 * of RFC5661.
> +		 */
> +		dprintk("%s: slot=%d seq=%d: Operation in progress\n",
> +				__func__, res->sr_slotid, slot->seq_nr);
> +		goto out_retry;
> +	default:
> +		/* Just update the slot sequence no. */
> +		++slot->seq_nr;
>  	}
>  out:
>  	/* The session may be reset by one of the error handlers. */
>  	dprintk("%s: Error %d free the slot \n", __func__, res->sr_status);
>  	nfs41_sequence_free_slot(res);
> +	return 1;
> +out_retry:
> +	rpc_delay(task, NFS4_POLL_RETRY_MAX);
> +	rpc_restart_call(task);
> +	/* FIXME: rpc_restart_call() should be made to return success/fail */
> +	if (RPC_ASSASSINATED(task))
> +		goto out;
> +	return 0;
>  }
>  
> -static void nfs4_sequence_done(const struct nfs_server *server,
> -			       struct nfs4_sequence_res *res, int rpc_status)
> +static int nfs4_sequence_done(struct rpc_task *task,
> +			       struct nfs4_sequence_res *res)
>  {
> -	if (res->sr_session != NULL)
> -		nfs41_sequence_done(res);
> +	if (res->sr_session == NULL)
> +		return 1;
> +	return nfs41_sequence_done(task, res);
>  }
>  
>  /*
> @@ -592,7 +616,7 @@ static void nfs41_call_sync_done(struct rpc_task *task, void *calldata)
>  {
>  	struct nfs41_call_sync_data *data = calldata;
>  
> -	nfs41_sequence_done(data->seq_res);
> +	nfs41_sequence_done(task, data->seq_res);
>  }
>  
>  struct rpc_call_ops nfs41_call_sync_ops = {
> @@ -650,9 +674,10 @@ int _nfs4_call_sync_session(struct nfs_server *server,
>  }
>  
>  #else
> -static void nfs4_sequence_done(const struct nfs_server *server,
> -			       struct nfs4_sequence_res *res, int rpc_status)
> +static int nfs4_sequence_done(struct rpc_task *task,
> +			       struct nfs4_sequence_res *res)
>  {
> +	return 1;
>  }
>  #endif /* CONFIG_NFS_V4_1 */
>  
> @@ -1379,8 +1404,8 @@ static void nfs4_open_done(struct rpc_task *task, void *calldata)
>  
>  	data->rpc_status = task->tk_status;
>  
> -	nfs4_sequence_done(data->o_arg.server, &data->o_res.seq_res,
> -			task->tk_status);
> +	if (!nfs4_sequence_done(task, &data->o_res.seq_res))
> +		return;
>  
>  	if (RPC_ASSASSINATED(task))
>  		return;
> @@ -1832,7 +1857,8 @@ static void nfs4_close_done(struct rpc_task *task, void *data)
>  	struct nfs4_state *state = calldata->state;
>  	struct nfs_server *server = NFS_SERVER(calldata->inode);
>  
> -	nfs4_sequence_done(server, &calldata->res.seq_res, task->tk_status);
> +	if (!nfs4_sequence_done(task, &calldata->res.seq_res))
> +		return;
>  	if (RPC_ASSASSINATED(task))
>  		return;
>          /* hmm. we are done with the inode, and in the process of freeing
> @@ -2642,7 +2668,8 @@ static int nfs4_proc_unlink_done(struct rpc_task *task, struct inode *dir)
>  {
>  	struct nfs_removeres *res = task->tk_msg.rpc_resp;
>  
> -	nfs4_sequence_done(res->server, &res->seq_res, task->tk_status);
> +	if (!nfs4_sequence_done(task, &res->seq_res))
> +		return 0;
>  	if (nfs4_async_handle_error(task, res->server, NULL) == -EAGAIN)
>  		return 0;
>  	update_changeattr(dir, &res->cinfo);
> @@ -3087,7 +3114,8 @@ static int nfs4_read_done(struct rpc_task *task, struct nfs_read_data *data)
>  
>  	dprintk("--> %s\n", __func__);
>  
> -	nfs4_sequence_done(server, &data->res.seq_res, task->tk_status);
> +	if (!nfs4_sequence_done(task, &data->res.seq_res))
> +		return -EAGAIN;
>  
>  	if (nfs4_async_handle_error(task, server, data->args.context->state) == -EAGAIN) {
>  		nfs_restart_rpc(task, server->nfs_client);
> @@ -3110,8 +3138,8 @@ static int nfs4_write_done(struct rpc_task *task, struct nfs_write_data *data)
>  {
>  	struct inode *inode = data->inode;
>  	
> -	nfs4_sequence_done(NFS_SERVER(inode), &data->res.seq_res,
> -			   task->tk_status);
> +	if (!nfs4_sequence_done(task, &data->res.seq_res))
> +		return -EAGAIN;
>  
>  	if (nfs4_async_handle_error(task, NFS_SERVER(inode), data->args.context->state) == -EAGAIN) {
>  		nfs_restart_rpc(task, NFS_SERVER(inode)->nfs_client);
> @@ -3139,8 +3167,9 @@ static int nfs4_commit_done(struct rpc_task *task, struct nfs_write_data *data)
>  {
>  	struct inode *inode = data->inode;
>  	
> -	nfs4_sequence_done(NFS_SERVER(inode), &data->res.seq_res,
> -			   task->tk_status);
> +	if (!nfs4_sequence_done(task, &data->res.seq_res))
> +		return -EAGAIN;
> +
>  	if (nfs4_async_handle_error(task, NFS_SERVER(inode), NULL) == -EAGAIN) {
>  		nfs_restart_rpc(task, NFS_SERVER(inode)->nfs_client);
>  		return -EAGAIN;
> @@ -3630,8 +3659,8 @@ static void nfs4_delegreturn_done(struct rpc_task *task, void *calldata)
>  {
>  	struct nfs4_delegreturndata *data = calldata;
>  
> -	nfs4_sequence_done(data->res.server, &data->res.seq_res,
> -			task->tk_status);
> +	if (!nfs4_sequence_done(task, &data->res.seq_res))
> +		return;
>  
>  	switch (task->tk_status) {
>  	case -NFS4ERR_STALE_STATEID:
> @@ -3881,8 +3910,8 @@ static void nfs4_locku_done(struct rpc_task *task, void *data)
>  {
>  	struct nfs4_unlockdata *calldata = data;
>  
> -	nfs4_sequence_done(calldata->server, &calldata->res.seq_res,
> -			   task->tk_status);
> +	if (!nfs4_sequence_done(task, &calldata->res.seq_res))
> +		return;
>  	if (RPC_ASSASSINATED(task))
>  		return;
>  	switch (task->tk_status) {
> @@ -4091,8 +4120,8 @@ static void nfs4_lock_done(struct rpc_task *task, void *calldata)
>  
>  	dprintk("%s: begin!\n", __func__);
>  
> -	nfs4_sequence_done(data->server, &data->res.seq_res,
> -			task->tk_status);
> +	if (!nfs4_sequence_done(task, &data->res.seq_res))
> +		return;
>  
>  	data->rpc_status = task->tk_status;
>  	if (RPC_ASSASSINATED(task))
> @@ -4629,7 +4658,8 @@ static void nfs4_get_lease_time_done(struct rpc_task *task, void *calldata)
>  			(struct nfs4_get_lease_time_data *)calldata;
>  
>  	dprintk("--> %s\n", __func__);
> -	nfs41_sequence_done(&data->res->lr_seq_res);
> +	if (!nfs41_sequence_done(task, &data->res->lr_seq_res))
> +		return;
>  	switch (task->tk_status) {
>  	case -NFS4ERR_DELAY:
>  	case -NFS4ERR_GRACE:
> @@ -5111,7 +5141,8 @@ static void nfs41_sequence_call_done(struct rpc_task *task, void *data)
>  	struct nfs4_sequence_data *calldata = data;
>  	struct nfs_client *clp = calldata->clp;
>  
> -	nfs41_sequence_done(task->tk_msg.rpc_resp);
> +	if (!nfs41_sequence_done(task, task->tk_msg.rpc_resp))
> +		return;
>  
>  	if (task->tk_status < 0) {
>  		dprintk("%s ERROR %d\n", __func__, task->tk_status);
> @@ -5255,7 +5286,8 @@ static void nfs4_reclaim_complete_done(struct rpc_task *task, void *data)
>  	struct nfs4_sequence_res *res = &calldata->res.seq_res;
>  
>  	dprintk("--> %s\n", __func__);
> -	nfs41_sequence_done(res);
> +	if (!nfs41_sequence_done(task, res))
> +		return;
>  
>  	if (nfs41_reclaim_complete_handle_errors(task, clp) == -EAGAIN) {
>  		rpc_restart_call_prepare(task);
> 
