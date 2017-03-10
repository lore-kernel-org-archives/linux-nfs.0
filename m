Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:35486 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932789AbdCJV4j (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Mar 2017 16:56:39 -0500
Received: by mail-io0-f194.google.com with SMTP id f103so8218069ioi.2
        for <linux-nfs@vger.kernel.org>; Fri, 10 Mar 2017 13:56:38 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170310213509.38215-1-kolga@netapp.com>
References: <1489179088.3260.2.camel@primarydata.com> <20170310213509.38215-1-kolga@netapp.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Fri, 10 Mar 2017 16:56:37 -0500
Message-ID: <CAN-5tyEpUQB+Tz9p=GKB1XyaOnZO4Zbo+RWod+xUaVut_zkg=w@mail.gmail.com>
Subject: Re: [PATCH 1/1] NFS prevent double free in async nfs4_exchange_id
To: Olga Kornievskaia <kolga@netapp.com>
Cc: Trond Myklebust <Trond.Myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Mar 10, 2017 at 4:35 PM, Olga Kornievskaia <kolga@netapp.com> wrote:
> Since rpc_task is async, the release function should be called which
> will free the impl_id, scope, and owner.
>
> Trond pointed at 2 more problems:
> -- use of client pointer after free in the nfs4_exchangeid_release() function
> -- cl_count mismatch if rpc_run_task() isn't run
>
> Fixes: 8d89bd70bc9 ("NFS setup async exchange_id")
> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> ---
>  fs/nfs/nfs4proc.c | 10 +++++-----
>  1 file changed, 5 insertions(+), 5 deletions(-)
>
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 59be0f7..3a79d3a 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -7426,11 +7426,11 @@ static void nfs4_exchange_id_release(void *data)
>         struct nfs41_exchange_id_data *cdata =
>                                         (struct nfs41_exchange_id_data *)data;
>
> -       nfs_put_client(cdata->args.client);
>         if (cdata->xprt) {
>                 xprt_put(cdata->xprt);
>                 rpc_clnt_xprt_switch_put(cdata->args.client->cl_rpcclient);
>         }
> +       nfs_put_client(cdata->args.client);
>         kfree(cdata->res.impl_id);
>         kfree(cdata->res.server_scope);
>         kfree(cdata->res.server_owner);
> @@ -7537,10 +7537,8 @@ static int _nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred,
>         task_setup_data.callback_data = calldata;
>
>         task = rpc_run_task(&task_setup_data);
> -       if (IS_ERR(task)) {
> -       status = PTR_ERR(task);
> -               goto out_impl_id;
> -       }
> +       if (IS_ERR(task))
> +               return PTR_ERR(task);
>
>         if (!xprt) {
>                 status = rpc_wait_for_completion_task(task);
> @@ -7558,6 +7556,8 @@ static int _nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred,
>                         clp->cl_implid->date.seconds,
>                         clp->cl_implid->date.nseconds);
>         dprintk("NFS reply exchange_id: %d\n", status);
> +       if (status)
> +               nfs_put_client(clp);
>         return status;
>
>  out_impl_id:

Urgh. scratch this one, it's causing problems. Will try again.


> --
> 1.8.3.1
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
