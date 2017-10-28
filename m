Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:51093 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750788AbdJ1HhC (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 28 Oct 2017 03:37:02 -0400
Received: by mail-wr0-f195.google.com with SMTP id p96so7969661wrb.7
        for <linux-nfs@vger.kernel.org>; Sat, 28 Oct 2017 00:37:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171027164410.10826.94955.stgit@manet.1015granger.net>
References: <20171027164014.10826.10151.stgit@manet.1015granger.net> <20171027164410.10826.94955.stgit@manet.1015granger.net>
From: Devesh Sharma <devesh.sharma@broadcom.com>
Date: Sat, 28 Oct 2017 13:06:20 +0530
Message-ID: <CANjDDBj0vq+FPFNgHU2DdMUpkJx8ho_jjjW-ur_Gt6wL03h7GA@mail.gmail.com>
Subject: Re: [PATCH 3/4] xprtrdma: Remove include for linux/prefetch.h
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Anna Schumaker <anna.schumaker@netapp.com>,
        linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

looks good,

Reveiwed-By: Devesh Sharma <devesh.sharma@broadcom.com>

On Fri, Oct 27, 2017 at 10:14 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
> Clean up. This include should have been removed by
> commit 23826c7aeac7 ("xprtrdma: Serialize credit accounting again").
>
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>  net/sunrpc/xprtrdma/verbs.c |    1 -
>  1 file changed, 1 deletion(-)
>
> diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
> index 4cfa893..be61c29 100644
> --- a/net/sunrpc/xprtrdma/verbs.c
> +++ b/net/sunrpc/xprtrdma/verbs.c
> @@ -49,7 +49,6 @@
>
>  #include <linux/interrupt.h>
>  #include <linux/slab.h>
> -#include <linux/prefetch.h>
>  #include <linux/sunrpc/addr.h>
>  #include <linux/sunrpc/svc_rdma.h>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
