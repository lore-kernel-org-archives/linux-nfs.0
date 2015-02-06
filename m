Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f51.google.com ([209.85.216.51]:59902 "EHLO
	mail-qa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753731AbbBFDNO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Feb 2015 22:13:14 -0500
Received: by mail-qa0-f51.google.com with SMTP id f12so8969113qad.10
        for <linux-nfs@vger.kernel.org>; Thu, 05 Feb 2015 19:13:13 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1423191577-72230-3-git-send-email-trond.myklebust@primarydata.com>
References: <1423191577-72230-1-git-send-email-trond.myklebust@primarydata.com>
 <1423191577-72230-2-git-send-email-trond.myklebust@primarydata.com> <1423191577-72230-3-git-send-email-trond.myklebust@primarydata.com>
From: Peng Tao <tao.peng@primarydata.com>
Date: Fri, 6 Feb 2015 11:12:53 +0800
Message-ID: <CAKVebiVeF_RZ7qs6BHP7RETnDQZa=04v5_n7xRw=55SUQr513Q@mail.gmail.com>
Subject: Re: [PATCH v2 3/5] NFSv4.1: Pin the inode and super block in
 asynchronous layoutreturns
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 6, 2015 at 10:59 AM, Trond Myklebust
<trond.myklebust@primarydata.com> wrote:
> If we're sending an asynchronous layoutreturn, then we need to ensure
> that the inode and the super block remain pinned.
>
Looks good.

Reviewed-by: Peng Tao <tao.peng@primarydata.com>
> Cc: Peng Tao <tao.peng@primarydata.com>
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  fs/nfs/nfs4proc.c       | 19 +++++++++++--------
>  include/linux/nfs_xdr.h |  1 +
>  2 files changed, 12 insertions(+), 8 deletions(-)
>
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index e092b8540e2e..2e7c9f7a6f7c 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -7856,6 +7856,7 @@ static void nfs4_layoutreturn_release(void *calldata)
>         lo->plh_block_lgets--;
>         spin_unlock(&lo->plh_inode->i_lock);
>         pnfs_put_layout_hdr(lrp->args.layout);
> +       nfs_iput_and_deactive(lrp->inode);
>         kfree(calldata);
>         dprintk("<-- %s\n", __func__);
>  }
> @@ -7880,23 +7881,25 @@ int nfs4_proc_layoutreturn(struct nfs4_layoutreturn *lrp, bool sync)
>                 .rpc_message = &msg,
>                 .callback_ops = &nfs4_layoutreturn_call_ops,
>                 .callback_data = lrp,
> -               .flags = RPC_TASK_ASYNC,
>         };
>         int status = 0;
>
>         dprintk("--> %s\n", __func__);
> +       if (!sync) {
> +               lrp->inode = nfs_igrab_and_active(lrp->args.inode);
> +               if (!lrp->inode) {
> +                       nfs4_layoutreturn_release(lrp);
> +                       return -EAGAIN;
> +               }
> +               task_setup_data.flags |= RPC_TASK_ASYNC;
> +       }
>         nfs4_init_sequence(&lrp->args.seq_args, &lrp->res.seq_res, 1);
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
>         trace_nfs4_layoutreturn(lrp->args.inode, status);
> -out:
>         dprintk("<-- %s status=%d\n", __func__, status);
>         rpc_put_task(task);
>         return status;
> diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
> index bb0d56f737e0..38d96ba935c2 100644
> --- a/include/linux/nfs_xdr.h
> +++ b/include/linux/nfs_xdr.h
> @@ -310,6 +310,7 @@ struct nfs4_layoutreturn {
>         struct nfs4_layoutreturn_res res;
>         struct rpc_cred *cred;
>         struct nfs_client *clp;
> +       struct inode *inode;
>         int rpc_status;
>  };
>
> --
> 2.1.0
>
