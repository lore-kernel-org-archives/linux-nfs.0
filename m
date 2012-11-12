Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f172.google.com ([209.85.212.172]:61977 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752217Ab2KLUWU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Nov 2012 15:22:20 -0500
Received: by mail-wi0-f172.google.com with SMTP id hm6so2862842wib.1
        for <linux-nfs@vger.kernel.org>; Mon, 12 Nov 2012 12:22:18 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1352745355-31157-1-git-send-email-bjschuma@netapp.com>
References: <1352745355-31157-1-git-send-email-bjschuma@netapp.com>
Date: Mon, 12 Nov 2012 15:22:18 -0500
Message-ID: <CAHVgHyWyKhjOc4AFY3LvK57k8JK5zNJDkRGwUjqNA4LMYcSzdw@mail.gmail.com>
Subject: Re: [PATCH 1/2] NFS: Add sequence_priviliged_ops for nfs4_proc_sequence()
From: Andy Adamson <androsadamson@gmail.com>
To: bjschuma@netapp.com
Cc: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 12, 2012 at 1:35 PM,  <bjschuma@netapp.com> wrote:
> From: Bryan Schumaker <bjschuma@netapp.com>
>
> During recovery the NFS4_SESSION_DRAINING flag might be set on the
> client structure.  This can cause lease renewal to abort when
> nfs41_setup_sequence sees that we are doing recovery.  As a result, the
> client never recovers and all activity with the NFS server halts.


When does this happen? Say the session is draining, and an RPC returns
from one of the compounds such as nfs_open, nfs_locku etc whose
rpc_call_done routine calls renew_lease after freeing it's slot.  Like
all calls on a draining session, the renew_lease sleeps on the session
slot_tbl_waitq - is this what you mean by "causes lease renewal to
abort"? How does this cause the client to never recover?

The only other call to renew_lease is from the state manager itself
which runs one function at a time, and will not call renew_lease until
the recovery is over....

What am I missing....?
-->Andy


>
> Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
> ---
>  fs/nfs/nfs4proc.c | 21 +++++++++++++++++----
>  1 file changed, 17 insertions(+), 4 deletions(-)
>
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 5eec442..537181c 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -6138,13 +6138,26 @@ static void nfs41_sequence_prepare(struct rpc_task *task, void *data)
>         rpc_call_start(task);
>  }
>
> +static void nfs41_sequence_prepare_privileged(struct rpc_task *task, void *data)
> +{
> +       rpc_task_set_priority(task, RPC_PRIORITY_PRIVILEGED);
> +       nfs41_sequence_prepare(task, data);
> +}
> +
>  static const struct rpc_call_ops nfs41_sequence_ops = {
>         .rpc_call_done = nfs41_sequence_call_done,
>         .rpc_call_prepare = nfs41_sequence_prepare,
>         .rpc_release = nfs41_sequence_release,
>  };
>
> -static struct rpc_task *_nfs41_proc_sequence(struct nfs_client *clp, struct rpc_cred *cred)
> +static const struct rpc_call_ops nfs41_sequence_privileged_ops = {
> +       .rpc_call_done = nfs41_sequence_call_done,
> +       .rpc_call_prepare = nfs41_sequence_prepare_privileged,
> +       .rpc_release = nfs41_sequence_release,
> +};
> +
> +static struct rpc_task *_nfs41_proc_sequence(struct nfs_client *clp, struct rpc_cred *cred,
> +                                            const struct rpc_call_ops *seq_ops)
>  {
>         struct nfs4_sequence_data *calldata;
>         struct rpc_message msg = {
> @@ -6154,7 +6167,7 @@ static struct rpc_task *_nfs41_proc_sequence(struct nfs_client *clp, struct rpc_
>         struct rpc_task_setup task_setup_data = {
>                 .rpc_client = clp->cl_rpcclient,
>                 .rpc_message = &msg,
> -               .callback_ops = &nfs41_sequence_ops,
> +               .callback_ops = seq_ops,
>                 .flags = RPC_TASK_ASYNC | RPC_TASK_SOFT,
>         };
>
> @@ -6181,7 +6194,7 @@ static int nfs41_proc_async_sequence(struct nfs_client *clp, struct rpc_cred *cr
>
>         if ((renew_flags & NFS4_RENEW_TIMEOUT) == 0)
>                 return 0;
> -       task = _nfs41_proc_sequence(clp, cred);
> +       task = _nfs41_proc_sequence(clp, cred, &nfs41_sequence_ops);
>         if (IS_ERR(task))
>                 ret = PTR_ERR(task);
>         else
> @@ -6195,7 +6208,7 @@ static int nfs4_proc_sequence(struct nfs_client *clp, struct rpc_cred *cred)
>         struct rpc_task *task;
>         int ret;
>
> -       task = _nfs41_proc_sequence(clp, cred);
> +       task = _nfs41_proc_sequence(clp, cred, &nfs41_sequence_privileged_ops);
>         if (IS_ERR(task)) {
>                 ret = PTR_ERR(task);
>                 goto out;
> --
> 1.8.0
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
