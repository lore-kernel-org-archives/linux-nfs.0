Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ob0-f182.google.com ([209.85.214.182]:35636 "EHLO
	mail-ob0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750699AbcBEXVE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Feb 2016 18:21:04 -0500
Received: by mail-ob0-f182.google.com with SMTP id xk3so102069582obc.2
        for <linux-nfs@vger.kernel.org>; Fri, 05 Feb 2016 15:21:04 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1454706518-4641-2-git-send-email-andros@netapp.com>
References: <1454706518-4641-1-git-send-email-andros@netapp.com>
	<1454706518-4641-2-git-send-email-andros@netapp.com>
Date: Fri, 5 Feb 2016 18:21:04 -0500
Message-ID: <CAHQdGtQpqRc_oqxq4myCrmP7-f=42iae3sQmuGMYzjCb5zROkA@mail.gmail.com>
Subject: Re: [PATCH RFC Version 1 1/6] SUNRPC fix rpc_clnt_add_xprt setup return
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: William Andros Adamson <andros@netapp.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 5, 2016 at 4:08 PM,  <andros@netapp.com> wrote:
> From: Andy Adamson <andros@netapp.com>
>
> Caller rpc_clnt_add_xprt() expects zero on success.
>
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  net/sunrpc/clnt.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> index efd6ffc..c0469d1 100644
> --- a/net/sunrpc/clnt.c
> +++ b/net/sunrpc/clnt.c
> @@ -2573,7 +2573,7 @@ int rpc_clnt_test_and_add_xprt(struct rpc_clnt *clnt,
>         if (IS_ERR(task))
>                 return PTR_ERR(task);
>         rpc_put_task(task);
> -       return 1;
> +       return 0;
>  }
>  EXPORT_SYMBOL_GPL(rpc_clnt_test_and_add_xprt);


Which is why we return 1. :-)

The point of doing so is to ensure we do not add the xprt until the
connection has been tested.

Cheers
  Trond
