Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f172.google.com ([209.85.220.172]:33729 "EHLO
        mail-qk0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752295AbdBJVUt (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Feb 2017 16:20:49 -0500
Received: by mail-qk0-f172.google.com with SMTP id s140so53139903qke.0
        for <linux-nfs@vger.kernel.org>; Fri, 10 Feb 2017 13:20:37 -0800 (PST)
Subject: Re: question about current code in async op
To: Olga Kornievskaia <aglo@umich.edu>,
        linux-nfs <linux-nfs@vger.kernel.org>
References: <CAN-5tyEE3GnoUKGNiwiApKGpcP+5pj68nLAh9SLSTSJ=OuPcMw@mail.gmail.com>
From: Anna Schumaker <schumaker.anna@gmail.com>
Message-ID: <b3afb003-b0b2-8a15-7914-40674c6dffbb@gmail.com>
Date: Fri, 10 Feb 2017 16:20:35 -0500
MIME-Version: 1.0
In-Reply-To: <CAN-5tyEE3GnoUKGNiwiApKGpcP+5pj68nLAh9SLSTSJ=OuPcMw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Olga,

On 02/10/2017 04:11 PM, Olga Kornievskaia wrote:
> Hi folks,
> 
> As I was writing a new async operation I was looking at other async
> functions for guidance (i.e.., nfs4_do_close()) and I noticed what
> looks to me like a memory leak. Am I missing something?
> 
> I don’t see that “calldata” is freed if rpc_run_task() fails.

I think the current code is okay.  From what I can see, the only way rpc_run_task() can fail is if rpc_new_task() can't allocate the new task.  If this happens, then rpc_new_task() calls rpc_release_calldata() to free the calldata.

Am I missing something?

Anna

> 
> Thoughts?
> 
> Here’s what I have to fix it:
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index d293f06..408cb5b 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -3317,8 +3317,10 @@ int nfs4_do_close(struct nfs4_state *state,
> gfp_t gfp_mask, int wait)
>   msg.rpc_resp = &calldata->res;
>   task_setup_data.callback_data = calldata;
>   task = rpc_run_task(&task_setup_data);
> - if (IS_ERR(task))
> + if (IS_ERR(task)) {
> + kfree(calldata);
>   return PTR_ERR(task);

Isn't this handled by 

> + }
>   status = 0;
>   if (wait)
>   status = rpc_wait_for_completion_task(task);
> @@ -6023,6 +6025,7 @@ static struct rpc_task *nfs4_do_unlck(struct
> file_lock *fl,
>   .workqueue = nfsiod_workqueue,
>   .flags = RPC_TASK_ASYNC,
>   };
> + struct rpc_task *task;
> 
> 
> 
>   nfs4_state_protect(NFS_SERVER(lsp->ls_state->inode)->nfs_client,
>   NFS_SP4_MACH_CRED_CLEANUP, &task_setup_data.rpc_client, &msg);
> @@ -6042,7 +6045,10 @@ static struct rpc_task *nfs4_do_unlck(struct
> file_lock *fl,
>   msg.rpc_argp = &data->arg;
>   msg.rpc_resp = &data->res;
>   task_setup_data.callback_data = data;
> - return rpc_run_task(&task_setup_data);
> + task = rpc_run_task(&task_setup_data);
> + if (IS_ERR(task))
> + kfree(data);
> + return task;
>  }
> 
> 
> 
>  static int nfs4_proc_unlck(struct nfs4_state *state, int cmd, struct
> file_lock *request)
> @@ -6311,8 +6317,10 @@ static int _nfs4_do_setlk(struct nfs4_state
> *state, int cmd, struct file_lock *f
>   } else
>   data->arg.new_lock = 1;
>   task = rpc_run_task(&task_setup_data);
> - if (IS_ERR(task))
> + if (IS_ERR(task)) {
> + kfree(data);
>   return PTR_ERR(task);
> + }
>   ret = nfs4_wait_for_completion_rpc_task(task);
>   if (ret == 0) {
>   ret = data->rpc_status;
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
