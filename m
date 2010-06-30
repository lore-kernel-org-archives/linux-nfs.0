From: Boaz Harrosh <bharrosh@panasas.com>
Subject: Re: [PATCH 07/10] SQUASHME pnfs-submit: add error handlers to layout
 get
Date: Wed, 30 Jun 2010 18:19:51 +0300
Message-ID: <4C2B6097.2000909@panasas.com>
References: <1277320878-3726-1-git-send-email-andros@netapp.com> <1277320878-3726-2-git-send-email-andros@netapp.com> <1277320878-3726-3-git-send-email-andros@netapp.com> <1277320878-3726-4-git-send-email-andros@netapp.com> <1277320878-3726-5-git-send-email-andros@netapp.com> <1277320878-3726-6-git-send-email-andros@netapp.com> <1277320878-3726-7-git-send-email-andros@netapp.com> <1277320878-3726-8-git-send-email-andros@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: bhalevy@panasas.com, linux-nfs@vger.kernel.org
To: andros@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:64143 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753377Ab0F3PTy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Jun 2010 11:19:54 -0400
In-Reply-To: <1277320878-3726-8-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/23/2010 10:21 PM, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> Redo pnfs4_proc_layoutget() logic to match the other async operations that call
> nfs4_wait_for_completion_rpc_task.
> 
> pnfs_get_layout_done passes session and delay errors. Handle them with the
> generic error handlers.
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  fs/nfs/nfs4proc.c |   45 +++++++++++++++++++++++++++++----------------
>  1 files changed, 29 insertions(+), 16 deletions(-)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 35e8a56..6283996 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -5446,6 +5446,10 @@ static void nfs4_pnfs_layoutget_done(struct rpc_task *task, void *calldata)
>  		return;
>  
>  	pnfs_get_layout_done(lgp, task->tk_status);
> +
> +	if (nfs4_async_handle_error(task, server, NULL, NULL) == -EAGAIN)
> +		nfs_restart_rpc(task, server->nfs_client);
> +

Andy high.

In pnfs_get_layout_done() it is working hard to do "lgp->status = XXX"

I never understood, what gets to look at that later on?

Thanks
Boaz

>  	dprintk("<-- %s\n", __func__);
>  }
>  
> @@ -5471,10 +5475,9 @@ static const struct rpc_call_ops nfs4_pnfs_layoutget_call_ops = {
>   * and deal with retries.
>   * Currently we can't since we release lgp and its contents.
>   */
> -int pnfs4_proc_layoutget(struct nfs4_pnfs_layoutget *lgp)
> +static int _pnfs4_proc_layoutget(struct nfs4_pnfs_layoutget *lgp)
>  {
> -	struct inode *ino = lgp->args.inode;
> -	struct nfs_server *server = NFS_SERVER(ino);
> +	struct nfs_server *server = NFS_SERVER(lgp->args.inode);
>  	struct rpc_task *task;
>  	struct rpc_message msg = {
>  		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_PNFS_LAYOUTGET],
> @@ -5488,35 +5491,45 @@ int pnfs4_proc_layoutget(struct nfs4_pnfs_layoutget *lgp)
>  		.callback_data = lgp,
>  		.flags = RPC_TASK_ASYNC,
>  	};
> -	int status;
> +	int status = 0;
>  
>  	dprintk("--> %s\n", __func__);
>  
>  	lgp->res.layout.buf = (void *)__get_free_page(GFP_NOFS);
>  	if (lgp->res.layout.buf == NULL) {
>  		nfs4_pnfs_layoutget_release(lgp);
> -		status = -ENOMEM;
> -		goto out;
> +		return -ENOMEM;
>  	}
>  
>  	lgp->res.seq_res.sr_slotid = NFS4_MAX_SLOT_TABLE;
>  	task = rpc_run_task(&task_setup_data);
> -	if (IS_ERR(task)) {
> -		status = PTR_ERR(task);
> -		goto out;
> -	}
> +	if (IS_ERR(task))
> +		return PTR_ERR(task);
>  	status = nfs4_wait_for_completion_rpc_task(task);
> -	if (status == 0) {
> -		status = lgp->status;
> -		if (status == 0)
> -			status = pnfs_layout_process(lgp);
> -	}
> -	rpc_put_task(task);
> +	if (status != 0)
> +		goto out;
> +	status = lgp->status;
> +	if (status != 0)
> +		goto out;
> +	status = pnfs_layout_process(lgp);
>  out:
> +	rpc_put_task(task);
>  	dprintk("<-- %s status=%d\n", __func__, status);
>  	return status;
>  }
>  
> +int pnfs4_proc_layoutget(struct nfs4_pnfs_layoutget *lgp)
> +{
> +	struct nfs_server *server = NFS_SERVER(lgp->args.inode);
> +	struct nfs4_exception exception = { };
> +	int err;
> +	do {
> +		err = nfs4_handle_exception(server, _pnfs4_proc_layoutget(lgp),
> +					    &exception);
> +	} while (exception.retry);
> +	return err;
> +}
> +
>  static void pnfs_layoutcommit_prepare(struct rpc_task *task, void *data)
>  {
>  	struct pnfs_layoutcommit_data *ldata =

