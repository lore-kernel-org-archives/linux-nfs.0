Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ob0-f182.google.com ([209.85.214.182]:36529 "EHLO
	mail-ob0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751168AbcBFBDF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Feb 2016 20:03:05 -0500
Received: by mail-ob0-f182.google.com with SMTP id ba1so103776902obb.3
        for <linux-nfs@vger.kernel.org>; Fri, 05 Feb 2016 17:03:04 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1454706518-4641-5-git-send-email-andros@netapp.com>
References: <1454706518-4641-1-git-send-email-andros@netapp.com>
	<1454706518-4641-5-git-send-email-andros@netapp.com>
Date: Fri, 5 Feb 2016 20:03:03 -0500
Message-ID: <CAHQdGtQGPD_+=UH7Bq=jjQKehd+fTO=UCff6ne=F9BS-1e_bQw@mail.gmail.com>
Subject: Re: [PATCH RFC Version 1 4/6] NFS session trunking support: add trunk
 xprt to nfs4.1 mount
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: William Andros Adamson <andros@netapp.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 5, 2016 at 4:08 PM,  <andros@netapp.com> wrote:
> From: Andy Adamson <andros@netapp.com>
>
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  fs/nfs/nfs4client.c        | 16 +++++++++++++++-
>  net/sunrpc/xprtmultipath.c |  2 ++
>  2 files changed, 17 insertions(+), 1 deletion(-)
>
> diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
> index 5f20acf..6736805 100644
> --- a/fs/nfs/nfs4client.c
> +++ b/fs/nfs/nfs4client.c
> @@ -412,8 +412,22 @@ struct nfs_client *nfs4_init_client(struct nfs_client *clp,
>         if (error < 0)
>                 goto error;
>
> -       if (clp != old)
> +       if (clp != old) {
> +               if (clp->cl_minorversion != 0) {
> +                       struct rpc_xprt *add = clp->cl_rpcclient->cl_xprt;
> +                       struct xprt_create xprt_args = {
> +                               .ident = XPRT_TRANSPORT_TCP,
> +                               .net = old->cl_net, /* clp->cl_net ??*/

We already know that old->cl_net == clp->cl_net. That has been
established in nfs41_walk_client_list().

> +                               .dstaddr = (struct sockaddr *)&add->addr,
> +                               .addrlen = add->addrlen,
> +                               .servername = clp->cl_hostname,
> +                       };
> +                       /* Add this address as an alias */
> +                       rpc_clnt_add_xprt(old->cl_rpcclient, &xprt_args,
> +                                       rpc_clnt_test_and_add_xprt, NULL);

You have to ascertain that the server supports session trunking before
you can do this. nfs41_walk_client_list() establishes that 'old' and
'clp' have the same owner major ID, but it does nothing to ensure that
the minor IDs match, nor does it ensure that the scope is the same.

> +               }
>                 clp->cl_preserve_clid = true;
> +       }
>         nfs_put_client(clp);
>         return old;
>
> diff --git a/net/sunrpc/xprtmultipath.c b/net/sunrpc/xprtmultipath.c
> index 7be5bd2..f13419e 100644
> --- a/net/sunrpc/xprtmultipath.c
> +++ b/net/sunrpc/xprtmultipath.c
> @@ -35,6 +35,8 @@ static void xprt_switch_add_xprt_locked(struct rpc_xprt_switch *xps,
>         if (xps->xps_nxprts == 0)
>                 xps->xps_net = xprt->xprt_net;
>         xps->xps_nxprts++;
> +       pr_info("RPC:  ADDED %s to xps %p xps_nxprts %d\n",
> +               xprt->servername, xps, xps->xps_nxprts);

Doesn't belong in this patch.

>  }
>
>  /**
> --
> 1.8.3.1
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
