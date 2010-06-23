From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 7/8] SQUASHME pnfs-submit: add error handlers to layout
 get
Date: Wed, 23 Jun 2010 10:41:28 +0300
Message-ID: <4C21BAA8.7030900@panasas.com>
References: <1277243798-8181-1-git-send-email-andros@netapp.com> <1277243798-8181-2-git-send-email-andros@netapp.com> <1277243798-8181-3-git-send-email-andros@netapp.com> <1277243798-8181-4-git-send-email-andros@netapp.com> <1277243798-8181-5-git-send-email-andros@netapp.com> <1277243798-8181-6-git-send-email-andros@netapp.com> <1277243798-8181-7-git-send-email-andros@netapp.com> <1277243798-8181-8-git-send-email-andros@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: andros@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:43413 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751493Ab0FWHlh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Jun 2010 03:41:37 -0400
Received: by wwc33 with SMTP id 33so738854wwc.19
        for <linux-nfs@vger.kernel.org>; Wed, 23 Jun 2010 00:41:35 -0700 (PDT)
In-Reply-To: <1277243798-8181-8-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jun. 23, 2010, 0:56 +0300, andros@netapp.com wrote:
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

This will bypass the dprintk.
How about adding a out_no_task label after the call to rpc_put_task?

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

ditto.

Benny

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

