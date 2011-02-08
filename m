Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:45842 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751996Ab1BHXGt convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Feb 2011 18:06:49 -0500
Received: by bwz15 with SMTP id 15so350859bwz.19
        for <linux-nfs@vger.kernel.org>; Tue, 08 Feb 2011 15:06:48 -0800 (PST)
In-Reply-To: <1296855242-2592-37-git-send-email-andros@netapp.com>
References: <1296855242-2592-1-git-send-email-andros@netapp.com>
	<1296855242-2592-2-git-send-email-andros@netapp.com>
	<1296855242-2592-3-git-send-email-andros@netapp.com>
	<1296855242-2592-4-git-send-email-andros@netapp.com>
	<1296855242-2592-5-git-send-email-andros@netapp.com>
	<1296855242-2592-6-git-send-email-andros@netapp.com>
	<1296855242-2592-7-git-send-email-andros@netapp.com>
	<1296855242-2592-8-git-send-email-andros@netapp.com>
	<1296855242-2592-9-git-send-email-andros@netapp.com>
	<1296855242-2592-10-git-send-email-andros@netapp.com>
	<1296855242-2592-11-git-send-email-andros@netapp.com>
	<1296855242-2592-12-git-send-email-andros@netapp.com>
	<1296855242-2592-13-git-send-email-andros@netapp.com>
	<1296855242-2592-14-git-send-email-andros@netapp.com>
	<1296855242-2592-15-git-send-email-andros@netapp.com>
	<1296855242-2592-16-git-send-email-andros@netapp.com>
	<1296855242-2592-17-git-send-email-andros@netapp.com>
	<1296855242-2592-18-git-send-email-andros@netapp.com>
	<1296855242-2592-19-git-send-email-andros@netapp.com>
	<1296855242-2592-20-git-send-email-andros@netapp.com>
	<1296855242-2592-21-git-send-email-andros@netapp.com>
	<1296855242-2592-22-git-send-email-andros@netapp.com>
	<1296855242-2592-23-git-send-email-andros@netapp.com>
	<1296855242-2592-24-git-send-email-andros@netapp.com>
	<1296855242-2592-25-git-send-email-andros@netapp.com>
	<1296855242-2592-26-git-send-email-andros@netapp.com>
	<1296855242-2592-27-git-send-email-andros@netapp.com>
	<1296855242-2592-28-git-send-email-andros@netapp.com>
	<1296855242-2592-29-git-send-email-andros@netapp.com>
	<1296855242-2592-30-git-send-email-andros@netapp.com>
	<1296855242-2592-31-git-send-email-andros@netapp.com>
	<1296855242-2592-32-git-send-email-andros@netapp.com>
	<1296855242-2592-33-git-send-email-andros@netapp.com>
	<1296855242-2592-34-git-send-email-andros@netapp.com>
	<1296855242-2592-35-git-send-email-andros@netapp.com>
	<1296855242-2592-36-git-send-email-andros@netapp.com>
	<1296855242-2592-37-git-send-email-andros@netapp.com>
Date: Tue, 8 Feb 2011 18:06:43 -0500
Message-ID: <AANLkTimvmLJ8k6ALfV4-s5P8KTN7yxriCmDoNuWc9Y9X@mail.gmail.com>
Subject: Re: [PATCH 36/40] pnfs-submit wave3 filelayout read done
From: Fred Isaman <iisaman@netapp.com>
To: andros@netapp.com
Cc: bhalevy@panasas.com, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Feb 4, 2011 at 4:33 PM,  <andros@netapp.com> wrote:
> From: Andy Adamson <andros@netapp.com>
>
> Use our own async error handler.
> Mark the layout as failed and retry i/o through the MDS on specified errors.
>
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  fs/nfs/internal.h           |    1 +
>  fs/nfs/nfs4filelayout.c     |   86 +++++++++++++++++++++++++++++++++++++++++++
>  fs/nfs/nfs4proc.c           |   44 +++++++++++++--------
>  fs/nfs/nfs4state.c          |    1 +
>  fs/nfs/pnfs.h               |    1 -
>  include/linux/nfs_xdr.h     |    1 +
>  include/linux/sunrpc/clnt.h |    1 +
>  net/sunrpc/clnt.c           |    8 ++++
>  8 files changed, 125 insertions(+), 18 deletions(-)
>
> diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
> index 5518d61..f69a322 100644
> --- a/fs/nfs/internal.h
> +++ b/fs/nfs/internal.h
> @@ -281,6 +281,7 @@ extern int nfs_migrate_page(struct address_space *,
>  #endif
>
>  /* nfs4proc.c */
> +extern void nfs4_reset_read(struct rpc_task *task, struct nfs_read_data *data);
>  extern int _nfs4_call_sync(struct nfs_server *server,
>                           struct rpc_message *msg,
>                           struct nfs4_sequence_args *args,
> diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
> index 5fd8ed3..777d78b 100644
> --- a/fs/nfs/nfs4filelayout.c
> +++ b/fs/nfs/nfs4filelayout.c
> @@ -40,6 +40,8 @@ MODULE_LICENSE("GPL");
>  MODULE_AUTHOR("Dean Hildebrand <dhildebz@umich.edu>");
>  MODULE_DESCRIPTION("The NFSv4 file layout driver");
>
> +#define FILELAYOUT_POLL_RETRY_MAX     (15*HZ)
> +
>  static int
>  filelayout_set_layoutdriver(struct nfs_server *nfss)
>  {
> @@ -95,6 +97,88 @@ filelayout_get_dserver_offset(struct pnfs_layout_segment *lseg, loff_t offset)
>        BUG();
>  }
>
> +/* For data server errors we don't recover from */
> +static void
> +filelayout_set_lo_fail(struct pnfs_layout_segment *lseg, fmode_t mode)
> +{
> +       if (mode & FMODE_WRITE) {
> +               dprintk("%s Setting layout IOMODE_RW fail bit\n", __func__);
> +               set_bit(lo_fail_bit(IOMODE_RW), &lseg->pls_layout->plh_flags);
> +       } else if (mode & FMODE_READ) {
> +               dprintk("%s Setting layout IOMODE_READ fail bit\n", __func__);
> +               set_bit(lo_fail_bit(IOMODE_READ), &lseg->pls_layout->plh_flags);
> +       }
> +}
> +
> +/*
> + * Async I/O error handler.
> + *
> + * NFS4ERR_OLD_STATEID can not occur with a zero stateid seqid.
> + */
> +static int filelayout_async_handle_error(struct rpc_task *task,
> +                                        struct nfs4_state *state,
> +                                        struct nfs_client *clp,
> +                                        int *reset)
> +{
> +       if (task->tk_status >= 0)
> +               return 0;
> +       switch (task->tk_status) {
> +       case -NFS4ERR_BADSESSION:
> +       case -NFS4ERR_BADSLOT:
> +       case -NFS4ERR_BAD_HIGH_SLOT:
> +       case -NFS4ERR_DEADSESSION:
> +       case -NFS4ERR_CONN_NOT_BOUND_TO_SESSION:
> +       case -NFS4ERR_SEQ_FALSE_RETRY:
> +       case -NFS4ERR_SEQ_MISORDERED:
> +               dprintk("%s ERROR %d, Reset session. Exchangeid "
> +                       "flags 0x%x\n", __func__, task->tk_status,
> +                       clp->cl_exchange_flags);
> +               nfs4_schedule_state_recovery(clp);
> +               task->tk_status = 0;
> +               return -EAGAIN;
> +       case -NFS4ERR_DELAY:
> +       case -NFS4ERR_GRACE:
> +       case -EKEYEXPIRED:
> +               rpc_delay(task, FILELAYOUT_POLL_RETRY_MAX);
> +               task->tk_status = 0;
> +               return -EAGAIN;
> +       default:
> +               dprintk("%s DS error %d\n", __func__, task->tk_status);
> +               /* Layout marked as failed by pnfs_check_io_status.
> +                * Retry I/O through the MDS */
> +               *reset = 1;
> +               task->tk_status = 0;
> +               return -EAGAIN;
> +       }
> +}
> +
> +/* NFS_PROTO call done callback routines */
> +
> +static int filelayout_read_done_cb(struct rpc_task *task,
> +                               struct nfs_read_data *data)
> +{
> +       struct nfs_client *clp = data->ds_clp;
> +       int reset = 0;
> +
> +       dprintk("%s DS read\n", __func__);
> +
> +       if (filelayout_async_handle_error(task, data->args.context->state,
> +                                         data->ds_clp, &reset) == -EAGAIN) {
> +               dprintk("%s calling restart ds_clp %p ds_clp->cl_session %p\n",
> +                       __func__, data->ds_clp, data->ds_clp->cl_session);
> +               if (reset) {
> +                       nfs4_reset_read(task, data);
> +                       filelayout_set_lo_fail(data->lseg,
> +                                       data->args.context->state->state);

Why use the open context, instead of just failing read layouts? Do you
really want to prevent all future write layouts too?  Even worse is
the reverse case...if a write layout op fails do you want to prevent
all future read layouts just because the file happened to be open for
read?

If you answer is no, then just send a READ/WRITE bit.

If your answer is yes, then just remove the arg entirely and always
mark both modes as failing.

Fred

> +                       clp = NFS_SERVER(data->inode)->nfs_client;
> +               }
> +               nfs_restart_rpc(task, clp);
> +               return -EAGAIN;
> +       }
> +
> +       return 0;
> +}
> +
>  /*
>  * Call ops for the async read/write cases
>  * In the case of dense layouts, the offset needs to be reset to its
> @@ -104,6 +188,8 @@ static void filelayout_read_prepare(struct rpc_task *task, void *data)
>  {
>        struct nfs_read_data *rdata = (struct nfs_read_data *)data;
>
> +       rdata->read_done_cb = filelayout_read_done_cb;
> +
>        if (nfs41_setup_sequence(rdata->ds_clp->cl_session,
>                                &rdata->args.seq_args, &rdata->res.seq_res,
>                                0, task))
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 3fcf756..9dee49d 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -3075,41 +3075,51 @@ static int nfs4_proc_pathconf(struct nfs_server *server, struct nfs_fh *fhandle,
>        return err;
>  }
>
> -static int nfs4_read_done(struct rpc_task *task, struct nfs_read_data *data)
> +static int nfs4_read_done_cb(struct rpc_task *task, struct nfs_read_data *data)
>  {
>        struct nfs_server *server = NFS_SERVER(data->inode);
> -       struct nfs_client *clp = server->nfs_client;
> -
> -       dprintk("--> %s\n", __func__);
> -
> -#ifdef CONFIG_NFS_V4_1
> -       /* Is this a DS session */
> -       if (data->ds_clp) {
> -               dprintk("%s DS read\n", __func__);
> -               clp = data->ds_clp;
> -       }
> -#endif /* CONFIG_NFS_V4_1 */
> -
> -       if (!nfs4_sequence_done(task, &data->res.seq_res))
> -               return -EAGAIN;
>
>        if (nfs4_async_handle_error(task, server, data->args.context->state) == -EAGAIN) {
> -               nfs_restart_rpc(task, client);
> +               nfs_restart_rpc(task, server->nfs_client);
>                return -EAGAIN;
>        }
>
>        nfs_invalidate_atime(data->inode);
> -       if (task->tk_status > 0 && !data->ds_clp)
> +       if (task->tk_status > 0)
>                renew_lease(server, data->timestamp);
>        return 0;
>  }
>
> +static int nfs4_read_done(struct rpc_task *task, struct nfs_read_data *data)
> +{
> +
> +       dprintk("--> %s\n", __func__);
> +
> +       if (!nfs4_sequence_done(task, &data->res.seq_res))
> +               return -EAGAIN;
> +
> +       return data->read_done_cb(task, data);
> +}
> +
>  static void nfs4_proc_read_setup(struct nfs_read_data *data, struct rpc_message *msg)
>  {
>        data->timestamp   = jiffies;
> +       data->read_done_cb = nfs4_read_done_cb;
>        msg->rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_READ];
>  }
>
> +/* Reset the the nfs_read_data to send the read to another server. */
> +void nfs4_reset_read(struct rpc_task *task, struct nfs_read_data *data)
> +{
> +       dprintk("%s Reset task for i/o through \n", __func__);
> +       data->ds_clp = NULL;
> +       data->args.fh     = NFS_FH(data->inode);
> +       data->read_done_cb = nfs4_read_done_cb;
> +       task->tk_ops = data->call_ops;
> +       rpc_task_reset_client(task, NFS_CLIENT(data->inode));
> +}
> +EXPORT_SYMBOL_GPL(nfs4_reset_read);
> +
>  static int nfs4_write_done(struct rpc_task *task, struct nfs_write_data *data)
>  {
>        struct inode *inode = data->inode;
> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
> index 49433aa..346fb97 100644
> --- a/fs/nfs/nfs4state.c
> +++ b/fs/nfs/nfs4state.c
> @@ -1022,6 +1022,7 @@ void nfs4_schedule_state_recovery(struct nfs_client *clp)
>                set_bit(NFS4CLNT_CHECK_LEASE, &clp->cl_state);
>        nfs4_schedule_state_manager(clp);
>  }
> +EXPORT_SYMBOL_GPL(nfs4_schedule_state_recovery);
>
>  int nfs4_state_mark_reclaim_reboot(struct nfs_client *clp, struct nfs4_state *state)
>  {
> diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
> index 6a99c33..218cdfe 100644
> --- a/fs/nfs/pnfs.h
> +++ b/fs/nfs/pnfs.h
> @@ -198,7 +198,6 @@ void pnfs_roc_release(struct inode *ino);
>  void pnfs_roc_set_barrier(struct inode *ino, u32 barrier);
>  bool pnfs_roc_drain(struct inode *ino, u32 *barrier);
>
> -
>  static inline int lo_fail_bit(u32 iomode)
>  {
>        return iomode == IOMODE_RW ?
> diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
> index 1222aa9..c91f468 100644
> --- a/include/linux/nfs_xdr.h
> +++ b/include/linux/nfs_xdr.h
> @@ -1020,6 +1020,7 @@ struct nfs_read_data {
>        struct pnfs_layout_segment *lseg;
>        struct nfs_client       *ds_clp;        /* pNFS data server */
>        const struct rpc_call_ops *call_ops;    /* For pNFS recovery to MDS */
> +       int (*read_done_cb) (struct rpc_task *task, struct nfs_read_data *data);
>        __u64                   orig_offset;    /* Filelayout dense stripe */
>        struct page             *page_array[NFS_PAGEVEC_SIZE];
>  };
> diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
> index ef9476a..db7bcaf 100644
> --- a/include/linux/sunrpc/clnt.h
> +++ b/include/linux/sunrpc/clnt.h
> @@ -129,6 +129,7 @@ struct rpc_create_args {
>  struct rpc_clnt *rpc_create(struct rpc_create_args *args);
>  struct rpc_clnt        *rpc_bind_new_program(struct rpc_clnt *,
>                                struct rpc_program *, u32);
> +void rpc_task_reset_client(struct rpc_task *task, struct rpc_clnt *clnt);
>  struct rpc_clnt *rpc_clone_client(struct rpc_clnt *);
>  void           rpc_shutdown_client(struct rpc_clnt *);
>  void           rpc_release_client(struct rpc_clnt *);
> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> index 57d344c..5c4df70 100644
> --- a/net/sunrpc/clnt.c
> +++ b/net/sunrpc/clnt.c
> @@ -597,6 +597,14 @@ void rpc_task_set_client(struct rpc_task *task, struct rpc_clnt *clnt)
>        }
>  }
>
> +void rpc_task_reset_client(struct rpc_task *task, struct rpc_clnt *clnt)
> +{
> +       rpc_task_release_client(task);
> +       rpc_task_set_client(task, clnt);
> +}
> +EXPORT_SYMBOL_GPL(rpc_task_reset_client);
> +
> +
>  static void
>  rpc_task_set_rpc_message(struct rpc_task *task, const struct rpc_message *msg)
>  {
> --
> 1.6.6
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
