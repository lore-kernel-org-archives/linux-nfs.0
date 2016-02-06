Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ob0-f175.google.com ([209.85.214.175]:35628 "EHLO
	mail-ob0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750748AbcBFBEt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Feb 2016 20:04:49 -0500
Received: by mail-ob0-f175.google.com with SMTP id xk3so103524622obc.2
        for <linux-nfs@vger.kernel.org>; Fri, 05 Feb 2016 17:04:48 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1454706518-4641-7-git-send-email-andros@netapp.com>
References: <1454706518-4641-1-git-send-email-andros@netapp.com>
	<1454706518-4641-7-git-send-email-andros@netapp.com>
Date: Fri, 5 Feb 2016 20:04:48 -0500
Message-ID: <CAHQdGtS1+yQp1bPEHYt9Po7GNe7Hv2O4dtRSae-fTsKySv1v0A@mail.gmail.com>
Subject: Re: [PATCH RFC Version 1 6/6] NFS schedule bind_conn_to_session for
 new NFSv4.1 transport
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: William Andros Adamson <andros@netapp.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 5, 2016 at 4:08 PM,  <andros@netapp.com> wrote:
> From: Andy Adamson <andros@netapp.com>
>
> Complete session trunking with the BIND_CONN_TO_SESSION call.
> NFS cleanup after session trunking transport added
>
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  fs/nfs/nfs4client.c | 13 +++++++++++--
>  1 file changed, 11 insertions(+), 2 deletions(-)
>
> diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
> index 6736805..b0423f7 100644
> --- a/fs/nfs/nfs4client.c
> +++ b/fs/nfs/nfs4client.c
> @@ -423,8 +423,17 @@ struct nfs_client *nfs4_init_client(struct nfs_client *clp,
>                                 .servername = clp->cl_hostname,
>                         };
>                         /* Add this address as an alias */
> -                       rpc_clnt_add_xprt(old->cl_rpcclient, &xprt_args,
> -                                       rpc_clnt_test_and_add_xprt, NULL);
> +                       error = rpc_clnt_add_xprt(old->cl_rpcclient, &xprt_args,
> +                                            rpc_clnt_test_and_add_xprt, NULL);
> +                       if (!error) {
> +                               nfs4_schedule_session_recovery(old->cl_session,
> +                                       -NFS4ERR_CONN_NOT_BOUND_TO_SESSION);
> +
> +                               /** Cancel the 2nd mount */
> +                               pr_info("NFS:  Session trunk. CANCEL MOUNT\n");
> +                               error = -EINVAL;

You can't do this. What if we're not mounting the same path?

> +                               goto error;
> +                       }
>                 }
>                 clp->cl_preserve_clid = true;
>         }
> --
> 1.8.3.1
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
