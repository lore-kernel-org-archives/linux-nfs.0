Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ob0-f177.google.com ([209.85.214.177]:34526 "EHLO
	mail-ob0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750729AbcBFBFw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Feb 2016 20:05:52 -0500
Received: by mail-ob0-f177.google.com with SMTP id wb13so104867215obb.1
        for <linux-nfs@vger.kernel.org>; Fri, 05 Feb 2016 17:05:52 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1454706518-4641-6-git-send-email-andros@netapp.com>
References: <1454706518-4641-1-git-send-email-andros@netapp.com>
	<1454706518-4641-6-git-send-email-andros@netapp.com>
Date: Fri, 5 Feb 2016 20:05:52 -0500
Message-ID: <CAHQdGtQfdCW8XG5ZO0aFs52uJbSFXhzZ-JT+eHtyo7a0S4p2Ww@mail.gmail.com>
Subject: Re: [PATCH RFC Version 1 5/6] NFS add callback_ops to nfs4_proc_bind_conn_to_session_callback
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: William Andros Adamson <andros@netapp.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 5, 2016 at 4:08 PM,  <andros@netapp.com> wrote:
> From: Andy Adamson <andros@netapp.com>
>
> Fix oops when NULL callback_ops pointer accessed in rpc_init_task
>
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  fs/nfs/nfs4proc.c | 10 ++++++++++
>  1 file changed, 10 insertions(+)
>
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index a2da473..ea07707 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -6782,6 +6782,15 @@ nfs41_same_server_scope(struct nfs41_server_scope *a,
>         return false;
>  }
>
> +static void
> +nfs4_bind_one_conn_to_session_done(struct rpc_task *task, void *calldata)
> +{
> +}
> +
> +static const struct rpc_call_ops nfs4_bind_one_conn_to_session_ops = {
> +       .rpc_call_done =  &nfs4_bind_one_conn_to_session_done,
> +};
> +
>  /*
>   * nfs4_proc_bind_one_conn_to_session()
>   *
> @@ -6810,6 +6819,7 @@ int nfs4_proc_bind_one_conn_to_session(struct rpc_clnt *clnt,
>         struct rpc_task_setup task_setup_data = {
>                 .rpc_client = clnt,
>                 .rpc_xprt = xprt,
> +               .callback_ops = &nfs4_bind_one_conn_to_session_ops,
>                 .rpc_message = &msg,
>                 .flags = RPC_TASK_TIMEOUT,
>         };

Thanks! Applied to the series.
