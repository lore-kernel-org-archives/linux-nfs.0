Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f52.google.com ([209.85.192.52]:43115 "EHLO
	mail-qg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751974AbbBFDJo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Feb 2015 22:09:44 -0500
Received: by mail-qg0-f52.google.com with SMTP id h3so5443036qgf.11
        for <linux-nfs@vger.kernel.org>; Thu, 05 Feb 2015 19:09:44 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1423191577-72230-2-git-send-email-trond.myklebust@primarydata.com>
References: <1423191577-72230-1-git-send-email-trond.myklebust@primarydata.com>
 <1423191577-72230-2-git-send-email-trond.myklebust@primarydata.com>
From: Peng Tao <tao.peng@primarydata.com>
Date: Fri, 6 Feb 2015 11:09:23 +0800
Message-ID: <CAKVebiXt-r27v_p92QLOH-QmR+JZsc7qpdYho2md6+qtzv8uwQ@mail.gmail.com>
Subject: Re: [PATCH v2 2/5] NFSv4.1: Pin the inode and super block in
 asynchronous layoutcommit
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 6, 2015 at 10:59 AM, Trond Myklebust
<trond.myklebust@primarydata.com> wrote:
> If we're sending an asynchronous layoutcommit, then we need to ensure
> that the inode and the super block remain pinned.
>
Looks good.

Reviewed-by: Peng Tao <tao.peng@primarydata.com>
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  fs/nfs/nfs4proc.c       | 19 +++++++++++--------
>  include/linux/nfs_xdr.h |  1 +
>  2 files changed, 12 insertions(+), 8 deletions(-)
>
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index dd892a4e7eb3..e092b8540e2e 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -7989,6 +7989,7 @@ static void nfs4_layoutcommit_release(void *calldata)
>         nfs_post_op_update_inode_force_wcc(data->args.inode,
>                                            data->res.fattr);
>         put_rpccred(data->cred);
> +       nfs_iput_and_deactive(data->inode);
>         kfree(data);
>  }
>
> @@ -8013,7 +8014,6 @@ nfs4_proc_layoutcommit(struct nfs4_layoutcommit_data *data, bool sync)
>                 .rpc_message = &msg,
>                 .callback_ops = &nfs4_layoutcommit_ops,
>                 .callback_data = data,
> -               .flags = RPC_TASK_ASYNC,
>         };
>         struct rpc_task *task;
>         int status = 0;
> @@ -8024,18 +8024,21 @@ nfs4_proc_layoutcommit(struct nfs4_layoutcommit_data *data, bool sync)
>                 data->args.lastbytewritten,
>                 data->args.inode->i_ino);
>
> +       if (!sync) {
> +               data->inode = nfs_igrab_and_active(data->args.inode);
> +               if (data->inode == NULL) {
> +                       nfs4_layoutcommit_release(data);
> +                       return -EAGAIN;
> +               }
> +               task_setup_data.flags = RPC_TASK_ASYNC;
> +       }
>         nfs4_init_sequence(&data->args.seq_args, &data->res.seq_res, 1);
>         task = rpc_run_task(&task_setup_data);
>         if (IS_ERR(task))
>                 return PTR_ERR(task);
> -       if (sync == false)
> -               goto out;
> -       status = nfs4_wait_for_completion_rpc_task(task);
> -       if (status != 0)
> -               goto out;
> -       status = task->tk_status;
> +       if (sync)
> +               status = task->tk_status;
>         trace_nfs4_layoutcommit(data->args.inode, status);
> -out:
>         dprintk("%s: status %d\n", __func__, status);
>         rpc_put_task(task);
>         return status;
> diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
> index 2c35e2affa6f..bb0d56f737e0 100644
> --- a/include/linux/nfs_xdr.h
> +++ b/include/linux/nfs_xdr.h
> @@ -285,6 +285,7 @@ struct nfs4_layoutcommit_data {
>         struct nfs_fattr fattr;
>         struct list_head lseg_list;
>         struct rpc_cred *cred;
> +       struct inode *inode;
>         struct nfs4_layoutcommit_args args;
>         struct nfs4_layoutcommit_res res;
>  };
> --
> 2.1.0
>
