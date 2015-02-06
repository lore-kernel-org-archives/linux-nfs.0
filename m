Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f54.google.com ([209.85.216.54]:65189 "EHLO
	mail-qa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750795AbbBFCEM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Feb 2015 21:04:12 -0500
Received: by mail-qa0-f54.google.com with SMTP id w8so8815206qac.13
        for <linux-nfs@vger.kernel.org>; Thu, 05 Feb 2015 18:04:10 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1423175831-54558-2-git-send-email-trond.myklebust@primarydata.com>
References: <1423175831-54558-1-git-send-email-trond.myklebust@primarydata.com>
 <1423175831-54558-2-git-send-email-trond.myklebust@primarydata.com>
From: Peng Tao <tao.peng@primarydata.com>
Date: Fri, 6 Feb 2015 10:03:50 +0800
Message-ID: <CAKVebiVyWhQc2_ucE+sgJ7AWi1w89Y3i1o1PwGA7L59b57OfjA@mail.gmail.com>
Subject: Re: [PATCH 2/5] NFSv4.1: Pin the inode and super block in
 asynchronous layoutcommit
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 6, 2015 at 6:37 AM, Trond Myklebust
<trond.myklebust@primarydata.com> wrote:
> If we're sending an asynchronous layoutcommit, then we need to ensure
> that the inode and the super block remain pinned.
>
same thing here. I guess what we should do is to pin inode and super
block in the layout header, except for the case that we ROC bit is
set, which means layout segments cannot live after file is closed.
Then we are ensured not to allow lsegs to pass the life cycle of inode
and super block. Does it make sense?

Cheers,
Tao

> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  fs/nfs/internal.h       | 18 ++++++++++++++++++
>  fs/nfs/nfs4proc.c       | 19 +++++++++++--------
>  include/linux/nfs_xdr.h |  1 +
>  3 files changed, 30 insertions(+), 8 deletions(-)
>
> diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
> index a98cf2006179..d65f693c013b 100644
> --- a/fs/nfs/internal.h
> +++ b/fs/nfs/internal.h
> @@ -514,6 +514,24 @@ extern int nfs41_walk_client_list(struct nfs_client *clp,
>                                 struct nfs_client **result,
>                                 struct rpc_cred *cred);
>
> +static inline struct inode *nfs_igrab_and_active(struct inode *inode)
> +{
> +       if (igrab(inode) == NULL)
> +               return NULL;
> +       nfs_sb_active(inode->i_sb);
> +       return inode;
> +}
> +
> +static inline void nfs_iput_and_deactive(struct inode *inode)
> +{
> +       if (!inode) {
> +               struct super_block *sb = inode->i_sb;
> +
> +               iput(inode);
> +               nfs_sb_deactive(sb);
> +       }
> +}
> +
>  /*
>   * Determine the device name as a string
>   */
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index b803c1d363e7..770495bcd525 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -7994,6 +7994,7 @@ static void nfs4_layoutcommit_release(void *calldata)
>         nfs_post_op_update_inode_force_wcc(data->args.inode,
>                                            data->res.fattr);
>         put_rpccred(data->cred);
> +       nfs_iput_and_deactive(data->inode);
>         kfree(data);
>  }
>
> @@ -8018,7 +8019,6 @@ nfs4_proc_layoutcommit(struct nfs4_layoutcommit_data *data, bool sync)
>                 .rpc_message = &msg,
>                 .callback_ops = &nfs4_layoutcommit_ops,
>                 .callback_data = data,
> -               .flags = RPC_TASK_ASYNC,
>         };
>         struct rpc_task *task;
>         int status = 0;
> @@ -8029,18 +8029,21 @@ nfs4_proc_layoutcommit(struct nfs4_layoutcommit_data *data, bool sync)
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
