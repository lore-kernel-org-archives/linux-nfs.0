Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:35612 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757805Ab1ELOlm convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 May 2011 10:41:42 -0400
Received: by iwn34 with SMTP id 34so1464123iwn.19
        for <linux-nfs@vger.kernel.org>; Thu, 12 May 2011 07:41:41 -0700 (PDT)
In-Reply-To: <1304960798-3826-1-git-send-email-bhalevy@panasas.com>
References: <4DC81E8C.6040901@panasas.com>
	<1304960798-3826-1-git-send-email-bhalevy@panasas.com>
Date: Thu, 12 May 2011 10:41:41 -0400
Message-ID: <BANLkTikZGWBOr=MG+ipKoPSaZ4bo20kD7A@mail.gmail.com>
Subject: Re: [PATCH v2 02/29] pnfs: direct i/o
From: Fred Isaman <iisaman@netapp.com>
To: Benny Halevy <bhalevy@panasas.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Boaz Harrosh <bharrosh@panasas.com>, linux-nfs@vger.kernel.org,
        Andy Adamson <andros@netapp.com>, Dean Hildebrand <dhildeb@us.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Note this does not seem to change any functionality, just rearranges
the code.  Is this patch needed?

Fred

On Mon, May 9, 2011 at 1:06 PM, Benny Halevy <bhalevy@panasas.com> wrote:
> From: Andy Adamson <andros@netapp.com>
>
> Signed-off-by: Dean Hildebrand <dhildeb@us.ibm.com>
> Signed-off-by: Fred Isaman <iisaman@netapp.com>
> Signed-off-by: Andy Adamson <andros@netapp.com>
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfs/direct.c |  160 +++++++++++++++++++++++++++++++-----------------------
>  1 files changed, 92 insertions(+), 68 deletions(-)
>
> diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
> index 8eea253..55dffb7 100644
> --- a/fs/nfs/direct.c
> +++ b/fs/nfs/direct.c
> @@ -272,6 +272,38 @@ static const struct rpc_call_ops nfs_read_direct_ops = {
>        .rpc_release = nfs_direct_read_release,
>  };
>
> +static long nfs_direct_read_execute(struct nfs_read_data *data,
> +                                   struct rpc_task_setup *task_setup_data,
> +                                   struct rpc_message *msg)
> +{
> +       struct inode *inode = data->inode;
> +       struct rpc_task *task;
> +
> +       nfs_fattr_init(&data->fattr);
> +       msg->rpc_argp = &data->args;
> +       msg->rpc_resp = &data->res;
> +
> +       task_setup_data->task = &data->task;
> +       task_setup_data->callback_data = data;
> +       NFS_PROTO(inode)->read_setup(data, msg);
> +
> +       task = rpc_run_task(task_setup_data);
> +       if (IS_ERR(task))
> +               return PTR_ERR(task);
> +
> +       rpc_put_task(task);
> +
> +       dprintk("NFS: %5u initiated direct read call "
> +               "(req %s/%lld, %u bytes @ offset %llu)\n",
> +               data->task.tk_pid,
> +               inode->i_sb->s_id,
> +               (long long)NFS_FILEID(inode),
> +               data->args.count,
> +               (unsigned long long)data->args.offset);
> +
> +       return 0;
> +}
> +
>  /*
>  * For each rsize'd chunk of the user's buffer, dispatch an NFS READ
>  * operation.  If nfs_readdata_alloc() or get_user_pages() fails,
> @@ -288,7 +320,6 @@ static ssize_t nfs_direct_read_schedule_segment(struct nfs_direct_req *dreq,
>        unsigned long user_addr = (unsigned long)iov->iov_base;
>        size_t count = iov->iov_len;
>        size_t rsize = NFS_SERVER(inode)->rsize;
> -       struct rpc_task *task;
>        struct rpc_message msg = {
>                .rpc_cred = ctx->cred,
>        };
> @@ -349,26 +380,9 @@ static ssize_t nfs_direct_read_schedule_segment(struct nfs_direct_req *dreq,
>                data->res.fattr = &data->fattr;
>                data->res.eof = 0;
>                data->res.count = bytes;
> -               nfs_fattr_init(&data->fattr);
> -               msg.rpc_argp = &data->args;
> -               msg.rpc_resp = &data->res;
>
> -               task_setup_data.task = &data->task;
> -               task_setup_data.callback_data = data;
> -               NFS_PROTO(inode)->read_setup(data, &msg);
> -
> -               task = rpc_run_task(&task_setup_data);
> -               if (IS_ERR(task))
> +               if (nfs_direct_read_execute(data, &task_setup_data, &msg))
>                        break;
> -               rpc_put_task(task);
> -
> -               dprintk("NFS: %5u initiated direct read call "
> -                       "(req %s/%Ld, %zu bytes @ offset %Lu)\n",
> -                               data->task.tk_pid,
> -                               inode->i_sb->s_id,
> -                               (long long)NFS_FILEID(inode),
> -                               bytes,
> -                               (unsigned long long)data->args.offset);
>
>                started += bytes;
>                user_addr += bytes;
> @@ -461,12 +475,15 @@ static void nfs_direct_free_writedata(struct nfs_direct_req *dreq)
>  }
>
>  #if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
> +static long nfs_direct_write_execute(struct nfs_write_data *data,
> +                                    struct rpc_task_setup *task_setup_data,
> +                                    struct rpc_message *msg);
> +
>  static void nfs_direct_write_reschedule(struct nfs_direct_req *dreq)
>  {
>        struct inode *inode = dreq->inode;
>        struct list_head *p;
>        struct nfs_write_data *data;
> -       struct rpc_task *task;
>        struct rpc_message msg = {
>                .rpc_cred = dreq->ctx->cred,
>        };
> @@ -500,25 +517,7 @@ static void nfs_direct_write_reschedule(struct nfs_direct_req *dreq)
>                 * Reuse data->task; data->args should not have changed
>                 * since the original request was sent.
>                 */
> -               task_setup_data.task = &data->task;
> -               task_setup_data.callback_data = data;
> -               msg.rpc_argp = &data->args;
> -               msg.rpc_resp = &data->res;
> -               NFS_PROTO(inode)->write_setup(data, &msg);
> -
> -               /*
> -                * We're called via an RPC callback, so BKL is already held.
> -                */
> -               task = rpc_run_task(&task_setup_data);
> -               if (!IS_ERR(task))
> -                       rpc_put_task(task);
> -
> -               dprintk("NFS: %5u rescheduled direct write call (req %s/%Ld, %u bytes @ offset %Lu)\n",
> -                               data->task.tk_pid,
> -                               inode->i_sb->s_id,
> -                               (long long)NFS_FILEID(inode),
> -                               data->args.count,
> -                               (unsigned long long)data->args.offset);
> +               nfs_direct_write_execute(data, &task_setup_data, &msg);
>        }
>
>        if (put_dreq(dreq))
> @@ -561,10 +560,31 @@ static const struct rpc_call_ops nfs_commit_direct_ops = {
>        .rpc_release = nfs_direct_commit_release,
>  };
>
> +static long nfs_direct_commit_execute(struct nfs_direct_req *dreq,
> +                                     struct nfs_write_data *data,
> +                                     struct rpc_task_setup *task_setup_data,
> +                                     struct rpc_message *msg)
> +{
> +       struct rpc_task *task;
> +
> +       NFS_PROTO(data->inode)->commit_setup(data, msg);
> +
> +       /* Note: task.tk_ops->rpc_release will free dreq->commit_data */
> +       dreq->commit_data = NULL;
> +
> +       dprintk("NFS: %5u initiated commit call\n", data->task.tk_pid);
> +
> +       task = rpc_run_task(task_setup_data);
> +       if (IS_ERR(task))
> +               return PTR_ERR(task);
> +
> +       rpc_put_task(task);
> +       return 0;
> +}
> +
>  static void nfs_direct_commit_schedule(struct nfs_direct_req *dreq)
>  {
>        struct nfs_write_data *data = dreq->commit_data;
> -       struct rpc_task *task;
>        struct rpc_message msg = {
>                .rpc_argp = &data->args,
>                .rpc_resp = &data->res,
> @@ -593,16 +613,7 @@ static void nfs_direct_commit_schedule(struct nfs_direct_req *dreq)
>        data->res.verf = &data->verf;
>        nfs_fattr_init(&data->fattr);
>
> -       NFS_PROTO(data->inode)->commit_setup(data, &msg);
> -
> -       /* Note: task.tk_ops->rpc_release will free dreq->commit_data */
> -       dreq->commit_data = NULL;
> -
> -       dprintk("NFS: %5u initiated commit call\n", data->task.tk_pid);
> -
> -       task = rpc_run_task(&task_setup_data);
> -       if (!IS_ERR(task))
> -               rpc_put_task(task);
> +       nfs_direct_commit_execute(dreq, data, &task_setup_data, &msg);
>  }
>
>  static void nfs_direct_write_complete(struct nfs_direct_req *dreq, struct inode *inode)
> @@ -703,6 +714,36 @@ static const struct rpc_call_ops nfs_write_direct_ops = {
>        .rpc_release = nfs_direct_write_release,
>  };
>
> +static long nfs_direct_write_execute(struct nfs_write_data *data,
> +                                    struct rpc_task_setup *task_setup_data,
> +                                    struct rpc_message *msg)
> +{
> +       struct inode *inode = data->inode;
> +       struct rpc_task *task;
> +
> +       task_setup_data->task = &data->task;
> +       task_setup_data->callback_data = data;
> +       msg->rpc_argp = &data->args;
> +       msg->rpc_resp = &data->res;
> +       NFS_PROTO(inode)->write_setup(data, msg);
> +
> +       task = rpc_run_task(task_setup_data);
> +       if (IS_ERR(task))
> +               return PTR_ERR(task);
> +
> +       rpc_put_task(task);
> +
> +       dprintk("NFS: %5u initiated direct write call "
> +               "(req %s/%lld, %u bytes @ offset %llu)\n",
> +               data->task.tk_pid,
> +               inode->i_sb->s_id,
> +               (long long)NFS_FILEID(inode),
> +               data->args.count,
> +               (unsigned long long)data->args.offset);
> +
> +       return 0;
> +}
> +
>  /*
>  * For each wsize'd chunk of the user's buffer, dispatch an NFS WRITE
>  * operation.  If nfs_writedata_alloc() or get_user_pages() fails,
> @@ -718,7 +759,6 @@ static ssize_t nfs_direct_write_schedule_segment(struct nfs_direct_req *dreq,
>        struct inode *inode = ctx->path.dentry->d_inode;
>        unsigned long user_addr = (unsigned long)iov->iov_base;
>        size_t count = iov->iov_len;
> -       struct rpc_task *task;
>        struct rpc_message msg = {
>                .rpc_cred = ctx->cred,
>        };
> @@ -785,24 +825,8 @@ static ssize_t nfs_direct_write_schedule_segment(struct nfs_direct_req *dreq,
>                data->res.verf = &data->verf;
>                nfs_fattr_init(&data->fattr);
>
> -               task_setup_data.task = &data->task;
> -               task_setup_data.callback_data = data;
> -               msg.rpc_argp = &data->args;
> -               msg.rpc_resp = &data->res;
> -               NFS_PROTO(inode)->write_setup(data, &msg);
> -
> -               task = rpc_run_task(&task_setup_data);
> -               if (IS_ERR(task))
> +               if (nfs_direct_write_execute(data, &task_setup_data, &msg))
>                        break;
> -               rpc_put_task(task);
> -
> -               dprintk("NFS: %5u initiated direct write call "
> -                       "(req %s/%Ld, %zu bytes @ offset %Lu)\n",
> -                               data->task.tk_pid,
> -                               inode->i_sb->s_id,
> -                               (long long)NFS_FILEID(inode),
> -                               bytes,
> -                               (unsigned long long)data->args.offset);
>
>                started += bytes;
>                user_addr += bytes;
> --
> 1.7.3.4
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
