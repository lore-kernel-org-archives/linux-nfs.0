From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 1/1] SQUASHME pnfs-submit pnfs operations use new nfs4_sequence_done
Date: Mon, 19 Jul 2010 11:46:11 +0300
Message-ID: <4C4410D3.3070900@panasas.com>
References: <1279295797-4113-1-git-send-email-andros@netapp.com> <1279295797-4113-2-git-send-email-andros@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: andros@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:26332 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1760216Ab0GSIqN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Jul 2010 04:46:13 -0400
In-Reply-To: <1279295797-4113-2-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Andy, I've fixed this already in my tree, but with additionaly
checking on nfs4_sequence_done's status:

if (!nfs4_sequence_done(task, &res))
	return 0;

Benny

On Jul. 16, 2010, 18:56 +0300, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  fs/nfs/nfs4proc.c |    6 +++---
>  1 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index f5779a1..17b0c31 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -5448,7 +5448,7 @@ static void nfs4_pnfs_layoutget_done(struct rpc_task *task, void *calldata)
>  
>  	dprintk("--> %s\n", __func__);
>  
> -	nfs4_sequence_done(server, &lgp->res.seq_res, task->tk_status);
> +	nfs4_sequence_done(task, &lgp->res.seq_res);
>  
>  	if (RPC_ASSASSINATED(task))
>  		return;
> @@ -5558,7 +5558,7 @@ pnfs_layoutcommit_done(struct rpc_task *task, void *calldata)
>  		(struct pnfs_layoutcommit_data *)calldata;
>  	struct nfs_server *server = NFS_SERVER(data->args.inode);
>  
> -	nfs4_sequence_done(server, &data->res.seq_res, task->tk_status);
> +	nfs4_sequence_done(task, &data->res.seq_res);
>  	if (RPC_ASSASSINATED(task))
>  		return;
>  
> @@ -5666,7 +5666,7 @@ static void nfs4_pnfs_layoutreturn_done(struct rpc_task *task, void *calldata)
>  
>  	dprintk("--> %s\n", __func__);
>  
> -	nfs4_sequence_done(server, &lrp->res.seq_res, task->tk_status);
> +	nfs4_sequence_done(task, &lrp->res.seq_res);
>  	if (RPC_ASSASSINATED(task))
>  		return;
>  
