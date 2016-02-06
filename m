Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ob0-f182.google.com ([209.85.214.182]:36551 "EHLO
	mail-ob0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750808AbcBFBSF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Feb 2016 20:18:05 -0500
Received: by mail-ob0-f182.google.com with SMTP id ba1so103969903obb.3
        for <linux-nfs@vger.kernel.org>; Fri, 05 Feb 2016 17:18:05 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1454706518-4641-3-git-send-email-andros@netapp.com>
References: <1454706518-4641-1-git-send-email-andros@netapp.com>
	<1454706518-4641-3-git-send-email-andros@netapp.com>
Date: Fri, 5 Feb 2016 20:18:05 -0500
Message-ID: <CAHQdGtTj6KcXx5hqXOCvE2mF01gxg=NcjUrdXAjnT-g2Np3HVQ@mail.gmail.com>
Subject: Re: [PATCH RFC Version 1 2/6] SUNRPC fix rpc_clnt_xprt_iter_init
 infinite loop
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: William Andros Adamson <andros@netapp.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 5, 2016 at 4:08 PM,  <andros@netapp.com> wrote:
> From: Andy Adamson <andros@netapp.com>
>
> xprt_iter_get_next() will restart at top of list and never stop.
> Only process xps_nxprts xprts.
>
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  net/sunrpc/clnt.c | 11 +++++++----
>  1 file changed, 7 insertions(+), 4 deletions(-)
>
> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> index c0469d1..a56a44c8 100644
> --- a/net/sunrpc/clnt.c
> +++ b/net/sunrpc/clnt.c
> @@ -740,6 +740,7 @@ static
>  int rpc_clnt_xprt_iter_init(struct rpc_clnt *clnt, struct rpc_xprt_iter *xpi)
>  {
>         struct rpc_xprt_switch *xps;
> +       int nxprt;
>
>         rcu_read_lock();
>         xps = xprt_switch_get(rcu_dereference(clnt->cl_xpi.xpi_xpswitch));
> @@ -747,8 +748,9 @@ int rpc_clnt_xprt_iter_init(struct rpc_clnt *clnt, struct rpc_xprt_iter *xpi)
>         if (xps == NULL)
>                 return -EAGAIN;
>         xprt_iter_init_listall(xpi, xps);
> +       nxprt = xps->xps_nxprts;
>         xprt_switch_put(xps);
> -       return 0;
> +       return nxprt;
>  }
>
>  /**
> @@ -767,10 +769,11 @@ int rpc_clnt_iterate_for_each_xprt(struct rpc_clnt *clnt,
>                 void *data)
>  {
>         struct rpc_xprt_iter xpi;
> -       int ret;
> +       int ret = 0, nxprts, i;
>
> -       ret = rpc_clnt_xprt_iter_init(clnt, &xpi);
> -       for (;;) {
> +       nxprts = rpc_clnt_xprt_iter_init(clnt, &xpi);
> +       dprintk("RPC:   processing nxprts %d\n", nxprts);
> +       for (i = 0; i < nxprts; i++) {
>                 struct rpc_xprt *xprt = xprt_iter_get_next(&xpi);
>
>                 if (!xprt)
> --

I'd prefer not to export xps->xps_nxprts. It's not guaranteed to
remain stable unless you hold the spinlock.
Please see the change to xprt_switch_set_next_cursor().
