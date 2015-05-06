Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-lb0-f176.google.com ([209.85.217.176]:34558 "EHLO
	mail-lb0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751029AbbEFLhG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 May 2015 07:37:06 -0400
Received: by lbcga7 with SMTP id ga7so5245312lbc.1
        for <linux-nfs@vger.kernel.org>; Wed, 06 May 2015 04:37:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150504175700.3483.57728.stgit@manet.1015granger.net>
References: <20150504174626.3483.97639.stgit@manet.1015granger.net>
	<20150504175700.3483.57728.stgit@manet.1015granger.net>
Date: Wed, 6 May 2015 17:07:05 +0530
Message-ID: <CANjDDBicLDb7K=RZB5Gqv+oACaAG8DANJX3ML971jnXd_5KEuQ@mail.gmail.com>
Subject: Re: [PATCH v1 02/14] xprtrdma: Warn when there are orphaned IB objects
From: Devesh Sharma <devesh.sharma@avagotech.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, May 4, 2015 at 11:27 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>
> Print an error during transport destruction if ib_dealloc_pd()
> fails. This is a sign that xprtrdma orphaned one or more RDMA API
> objects at some point, which can pin lower layer kernel modules
> and cause shutdown to hang.
>
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>  net/sunrpc/xprtrdma/verbs.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
> index 4870d27..0cc4617 100644
> --- a/net/sunrpc/xprtrdma/verbs.c
> +++ b/net/sunrpc/xprtrdma/verbs.c
> @@ -710,8 +710,8 @@ rpcrdma_ia_close(struct rpcrdma_ia *ia)
>         }
>         if (ia->ri_pd != NULL && !IS_ERR(ia->ri_pd)) {
>                 rc = ib_dealloc_pd(ia->ri_pd);
> -               dprintk("RPC:       %s: ib_dealloc_pd returned %i\n",
> -                       __func__, rc);

Should we check for EBUSY explicitly? other then this is an error in
vendor specific ib_dealloc_pd()

> +               if (rc)
> +                       pr_warn("rpcrdma: ib_dealloc_pd status %i\n", rc);
>         }
>  }
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html




-- 
-Regards
Devesh
