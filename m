Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ua0-f173.google.com ([209.85.217.173]:48838 "EHLO
        mail-ua0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753421AbdJTT7p (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 20 Oct 2017 15:59:45 -0400
Received: by mail-ua0-f173.google.com with SMTP id z4so9106202uaz.5
        for <linux-nfs@vger.kernel.org>; Fri, 20 Oct 2017 12:59:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171019194645.76041-1-trond.myklebust@primarydata.com>
References: <20171019194645.76041-1-trond.myklebust@primarydata.com>
From: Olga Kornievskaia <olga.kornievskaia@gmail.com>
Date: Fri, 20 Oct 2017 15:59:43 -0400
Message-ID: <CAN-5tyHFtdWAG1xF9O94tAyHk33YJC-PqY-pREQs3bqSJmU85Q@mail.gmail.com>
Subject: Re: [PATCH v3] NFSv4.1: Fix up replays of interrupted requests
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 19, 2017 at 3:46 PM, Trond Myklebust
<trond.myklebust@primarydata.com> wrote:
> If the previous request on a slot was interrupted before it was
> processed by the server, then our slot sequence number may be out of whack,
> and so we try the next operation using the old sequence number.
>
> The problem with this, is that not all servers check to see that the
> client is replaying the same operations as previously when they decide
> to go to the replay cache, and so instead of the expected error of
> NFS4ERR_SEQ_FALSE_RETRY, we get a replay of the old reply, which could
> (if the operations match up) be mistaken by the client for a new reply.
>
> To fix this, we attempt to send a COMPOUND containing only the SEQUENCE op
> in order to resync our slot sequence number.
>
> Cc: Olga Kornievskaia <olga.kornievskaia@gmail.com>
> [olga.kornievskaia@gmail.com: fix an Oops]
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>

Tested-by: Olga Kornievskaia <kolga@netapp.com>

> ---
>  fs/nfs/nfs4_fs.h  |   2 +-
>  fs/nfs/nfs4proc.c | 148 +++++++++++++++++++++++++++++++++++++-----------------
>  2 files changed, 103 insertions(+), 47 deletions(-)
>
> diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
> index ac4f10b7f6c1..b547d935aaf0 100644
> --- a/fs/nfs/nfs4_fs.h
> +++ b/fs/nfs/nfs4_fs.h
> @@ -464,7 +464,7 @@ extern void nfs_increment_open_seqid(int status, struct nfs_seqid *seqid);
>  extern void nfs_increment_lock_seqid(int status, struct nfs_seqid *seqid);
>  extern void nfs_release_seqid(struct nfs_seqid *seqid);
>  extern void nfs_free_seqid(struct nfs_seqid *seqid);
> -extern int nfs4_setup_sequence(const struct nfs_client *client,
> +extern int nfs4_setup_sequence(struct nfs_client *client,
>                                 struct nfs4_sequence_args *args,
>                                 struct nfs4_sequence_res *res,
>                                 struct rpc_task *task);
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index f90090e8c959..96b2077e691d 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -96,6 +96,10 @@ static int nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
>                             struct nfs_open_context *ctx, struct nfs4_label *ilabel,
>                             struct nfs4_label *olabel);
>  #ifdef CONFIG_NFS_V4_1
> +static struct rpc_task *_nfs41_proc_sequence(struct nfs_client *clp,
> +               struct rpc_cred *cred,
> +               struct nfs4_slot *slot,
> +               bool is_privileged);
>  static int nfs41_test_stateid(struct nfs_server *, nfs4_stateid *,
>                 struct rpc_cred *);
>  static int nfs41_free_stateid(struct nfs_server *, const nfs4_stateid *,
> @@ -644,13 +648,14 @@ static int nfs40_sequence_done(struct rpc_task *task,
>
>  #if defined(CONFIG_NFS_V4_1)
>
> -static void nfs41_sequence_free_slot(struct nfs4_sequence_res *res)
> +static void nfs41_release_slot(struct nfs4_slot *slot)
>  {
>         struct nfs4_session *session;
>         struct nfs4_slot_table *tbl;
> -       struct nfs4_slot *slot = res->sr_slot;
>         bool send_new_highest_used_slotid = false;
>
> +       if (!slot)
> +               return;
>         tbl = slot->table;
>         session = tbl->session;
>
> @@ -676,13 +681,18 @@ static void nfs41_sequence_free_slot(struct nfs4_sequence_res *res)
>                 send_new_highest_used_slotid = false;
>  out_unlock:
>         spin_unlock(&tbl->slot_tbl_lock);
> -       res->sr_slot = NULL;
>         if (send_new_highest_used_slotid)
>                 nfs41_notify_server(session->clp);
>         if (waitqueue_active(&tbl->slot_waitq))
>                 wake_up_all(&tbl->slot_waitq);
>  }
>
> +static void nfs41_sequence_free_slot(struct nfs4_sequence_res *res)
> +{
> +       nfs41_release_slot(res->sr_slot);
> +       res->sr_slot = NULL;
> +}
> +
>  static int nfs41_sequence_process(struct rpc_task *task,
>                 struct nfs4_sequence_res *res)
>  {
> @@ -710,13 +720,6 @@ static int nfs41_sequence_process(struct rpc_task *task,
>         /* Check the SEQUENCE operation status */
>         switch (res->sr_status) {
>         case 0:
> -               /* If previous op on slot was interrupted and we reused
> -                * the seq# and got a reply from the cache, then retry
> -                */
> -               if (task->tk_status == -EREMOTEIO && interrupted) {
> -                       ++slot->seq_nr;
> -                       goto retry_nowait;
> -               }
>                 /* Update the slot's sequence and clientid lease timer */
>                 slot->seq_done = 1;
>                 clp = session->clp;
> @@ -750,16 +753,16 @@ static int nfs41_sequence_process(struct rpc_task *task,
>                  * The slot id we used was probably retired. Try again
>                  * using a different slot id.
>                  */
> +               if (slot->seq_nr < slot->table->target_highest_slotid)
> +                       goto session_recover;
>                 goto retry_nowait;
>         case -NFS4ERR_SEQ_MISORDERED:
>                 /*
>                  * Was the last operation on this sequence interrupted?
>                  * If so, retry after bumping the sequence number.
>                  */
> -               if (interrupted) {
> -                       ++slot->seq_nr;
> -                       goto retry_nowait;
> -               }
> +               if (interrupted)
> +                       goto retry_new_seq;
>                 /*
>                  * Could this slot have been previously retired?
>                  * If so, then the server may be expecting seq_nr = 1!
> @@ -768,10 +771,11 @@ static int nfs41_sequence_process(struct rpc_task *task,
>                         slot->seq_nr = 1;
>                         goto retry_nowait;
>                 }
> -               break;
> +               goto session_recover;
>         case -NFS4ERR_SEQ_FALSE_RETRY:
> -               ++slot->seq_nr;
> -               goto retry_nowait;
> +               if (interrupted)
> +                       goto retry_new_seq;
> +               goto session_recover;
>         default:
>                 /* Just update the slot sequence no. */
>                 slot->seq_done = 1;
> @@ -781,6 +785,11 @@ static int nfs41_sequence_process(struct rpc_task *task,
>         dprintk("%s: Error %d free the slot \n", __func__, res->sr_status);
>  out_noaction:
>         return ret;
> +session_recover:
> +       nfs4_schedule_session_recovery(session, res->sr_status);
> +       goto retry_nowait;
> +retry_new_seq:
> +       ++slot->seq_nr;
>  retry_nowait:
>         if (rpc_restart_call_prepare(task)) {
>                 nfs41_sequence_free_slot(res);
> @@ -857,6 +866,17 @@ static const struct rpc_call_ops nfs41_call_sync_ops = {
>         .rpc_call_done = nfs41_call_sync_done,
>  };
>
> +static void
> +nfs4_sequence_process_interrupted(struct nfs_client *client,
> +               struct nfs4_slot *slot, struct rpc_cred *cred)
> +{
> +       struct rpc_task *task;
> +
> +       task = _nfs41_proc_sequence(client, cred, slot, true);
> +       if (!IS_ERR(task))
> +               rpc_put_task_async(task);
> +}
> +
>  #else  /* !CONFIG_NFS_V4_1 */
>
>  static int nfs4_sequence_process(struct rpc_task *task, struct nfs4_sequence_res *res)
> @@ -877,9 +897,34 @@ int nfs4_sequence_done(struct rpc_task *task,
>  }
>  EXPORT_SYMBOL_GPL(nfs4_sequence_done);
>
> +static void
> +nfs4_sequence_process_interrupted(struct nfs_client *client,
> +               struct nfs4_slot *slot, struct rpc_cred *cred)
> +{
> +       WARN_ON_ONCE(1);
> +       slot->interrupted = 0;
> +}
> +
>  #endif /* !CONFIG_NFS_V4_1 */
>
> -int nfs4_setup_sequence(const struct nfs_client *client,
> +static
> +void nfs4_sequence_attach_slot(struct nfs4_sequence_args *args,
> +               struct nfs4_sequence_res *res,
> +               struct nfs4_slot *slot)
> +{
> +       if (!slot)
> +               return;
> +       slot->privileged = args->sa_privileged ? 1 : 0;
> +       args->sa_slot = slot;
> +
> +       res->sr_slot = slot;
> +       res->sr_timestamp = jiffies;
> +       res->sr_status_flags = 0;
> +       res->sr_status = 1;
> +
> +}
> +
> +int nfs4_setup_sequence(struct nfs_client *client,
>                         struct nfs4_sequence_args *args,
>                         struct nfs4_sequence_res *res,
>                         struct rpc_task *task)
> @@ -897,29 +942,28 @@ int nfs4_setup_sequence(const struct nfs_client *client,
>                 task->tk_timeout = 0;
>         }
>
> -       spin_lock(&tbl->slot_tbl_lock);
> -       /* The state manager will wait until the slot table is empty */
> -       if (nfs4_slot_tbl_draining(tbl) && !args->sa_privileged)
> -               goto out_sleep;
> +       for (;;) {
> +               spin_lock(&tbl->slot_tbl_lock);
> +               /* The state manager will wait until the slot table is empty */
> +               if (nfs4_slot_tbl_draining(tbl) && !args->sa_privileged)
> +                       goto out_sleep;
> +
> +               slot = nfs4_alloc_slot(tbl);
> +               if (IS_ERR(slot)) {
> +                       /* Try again in 1/4 second */
> +                       if (slot == ERR_PTR(-ENOMEM))
> +                               task->tk_timeout = HZ >> 2;
> +                       goto out_sleep;
> +               }
> +               spin_unlock(&tbl->slot_tbl_lock);
>
> -       slot = nfs4_alloc_slot(tbl);
> -       if (IS_ERR(slot)) {
> -               /* Try again in 1/4 second */
> -               if (slot == ERR_PTR(-ENOMEM))
> -                       task->tk_timeout = HZ >> 2;
> -               goto out_sleep;
> +               if (likely(!slot->interrupted))
> +                       break;
> +               nfs4_sequence_process_interrupted(client,
> +                               slot, task->tk_msg.rpc_cred);
>         }
> -       spin_unlock(&tbl->slot_tbl_lock);
> -
> -       slot->privileged = args->sa_privileged ? 1 : 0;
> -       args->sa_slot = slot;
>
> -       res->sr_slot = slot;
> -       if (session) {
> -               res->sr_timestamp = jiffies;
> -               res->sr_status_flags = 0;
> -               res->sr_status = 1;
> -       }
> +       nfs4_sequence_attach_slot(args, res, slot);
>
>         trace_nfs4_setup_sequence(session, args);
>  out_start:
> @@ -8135,6 +8179,7 @@ static const struct rpc_call_ops nfs41_sequence_ops = {
>
>  static struct rpc_task *_nfs41_proc_sequence(struct nfs_client *clp,
>                 struct rpc_cred *cred,
> +               struct nfs4_slot *slot,
>                 bool is_privileged)
>  {
>         struct nfs4_sequence_data *calldata;
> @@ -8148,15 +8193,18 @@ static struct rpc_task *_nfs41_proc_sequence(struct nfs_client *clp,
>                 .callback_ops = &nfs41_sequence_ops,
>                 .flags = RPC_TASK_ASYNC | RPC_TASK_TIMEOUT,
>         };
> +       struct rpc_task *ret;
>
> +       ret = ERR_PTR(-EIO);
>         if (!atomic_inc_not_zero(&clp->cl_count))
> -               return ERR_PTR(-EIO);
> +               goto out_err;
> +
> +       ret = ERR_PTR(-ENOMEM);
>         calldata = kzalloc(sizeof(*calldata), GFP_NOFS);
> -       if (calldata == NULL) {
> -               nfs_put_client(clp);
> -               return ERR_PTR(-ENOMEM);
> -       }
> +       if (calldata == NULL)
> +               goto out_put_clp;
>         nfs4_init_sequence(&calldata->args, &calldata->res, 0);
> +       nfs4_sequence_attach_slot(&calldata->args, &calldata->res, slot);
>         if (is_privileged)
>                 nfs4_set_sequence_privileged(&calldata->args);
>         msg.rpc_argp = &calldata->args;
> @@ -8164,7 +8212,15 @@ static struct rpc_task *_nfs41_proc_sequence(struct nfs_client *clp,
>         calldata->clp = clp;
>         task_setup_data.callback_data = calldata;
>
> -       return rpc_run_task(&task_setup_data);
> +       ret = rpc_run_task(&task_setup_data);
> +       if (IS_ERR(ret))
> +               goto out_err;
> +       return ret;
> +out_put_clp:
> +       nfs_put_client(clp);
> +out_err:
> +       nfs41_release_slot(slot);
> +       return ret;
>  }
>
>  static int nfs41_proc_async_sequence(struct nfs_client *clp, struct rpc_cred *cred, unsigned renew_flags)
> @@ -8174,7 +8230,7 @@ static int nfs41_proc_async_sequence(struct nfs_client *clp, struct rpc_cred *cr
>
>         if ((renew_flags & NFS4_RENEW_TIMEOUT) == 0)
>                 return -EAGAIN;
> -       task = _nfs41_proc_sequence(clp, cred, false);
> +       task = _nfs41_proc_sequence(clp, cred, NULL, false);
>         if (IS_ERR(task))
>                 ret = PTR_ERR(task);
>         else
> @@ -8188,7 +8244,7 @@ static int nfs4_proc_sequence(struct nfs_client *clp, struct rpc_cred *cred)
>         struct rpc_task *task;
>         int ret;
>
> -       task = _nfs41_proc_sequence(clp, cred, true);
> +       task = _nfs41_proc_sequence(clp, cred, NULL, true);
>         if (IS_ERR(task)) {
>                 ret = PTR_ERR(task);
>                 goto out;
> --
> 2.13.6
>
