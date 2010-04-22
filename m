From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [patch] nfs: fix some issues in nfs41_proc_reclaim_complete()
Date: Thu, 22 Apr 2010 16:21:42 +0300
Message-ID: <4BD04D66.80809@panasas.com>
References: <20100422092839.GI29647@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	Andy Adamson <andros@netapp.com>,
	Alexandros Batsakis <batsakis@netapp.com>,
	Ricardo Labiaga <Ricardo.Labiaga@netapp.com>,
	linux-nfs@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Dan Carpenter <error27@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:6047 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754602Ab0DVNVr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Apr 2010 09:21:47 -0400
In-Reply-To: <20100422092839.GI29647@bicker>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr. 22, 2010, 12:28 +0300, Dan Carpenter <error27@gmail.com> wrote:
> The original code passed an ERR_PTR() to rpc_put_task() and instead of
> returning zero on success it returned -ENOMEM.
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>
> ---
> This was found by smatch and I've only compile tested it.  Sorry.  :/
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 6380670..071fced 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -5218,9 +5218,12 @@ static int nfs41_proc_reclaim_complete(struct nfs_client *clp)
>  	msg.rpc_resp = &calldata->res;
>  	task_setup_data.callback_data = calldata;
>  	task = rpc_run_task(&task_setup_data);
> -	if (IS_ERR(task))
> +	if (IS_ERR(task)) {
>  		status = PTR_ERR(task);
> +		goto out;
> +	}
>  	rpc_put_task(task);
> +	return 0;
>  out:
>  	dprintk("<-- %s status=%d\n", __func__, status);
>  	return status;

Dan, thanks for sending the fix.
For the sake of dprintk, how about doing this instead:

git diff --stat -p -M
 fs/nfs/nfs4proc.c |   11 ++++++++---
 1 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 6380670..8671f7a 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5204,12 +5204,14 @@ static int nfs41_proc_reclaim_complete(struct nfs_client *clp)
 		.callback_ops = &nfs4_reclaim_complete_call_ops,
 		.flags = RPC_TASK_ASYNC,
 	};
-	int status = -ENOMEM;
+	int status;
 
 	dprintk("--> %s\n", __func__);
 	calldata = kzalloc(sizeof(*calldata), GFP_KERNEL);
-	if (calldata == NULL)
+	if (calldata == NULL) {
+		status = -ENOMEM;
 		goto out;
+	}
 	calldata->clp = clp;
 	calldata->arg.one_fs = 0;
 	calldata->res.seq_res.sr_slotid = NFS4_MAX_SLOT_TABLE;
@@ -5218,9 +5220,12 @@ static int nfs41_proc_reclaim_complete(struct nfs_client *clp)
 	msg.rpc_resp = &calldata->res;
 	task_setup_data.callback_data = calldata;
 	task = rpc_run_task(&task_setup_data);
-	if (IS_ERR(task))
+	if (IS_ERR(task)) {
 		status = PTR_ERR(task);
+		goto out;
+	}
 	rpc_put_task(task);
+	status = 0;
 out:
 	dprintk("<-- %s status=%d\n", __func__, status);
 	return status;
