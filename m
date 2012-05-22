Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f172.google.com ([209.85.212.172]:39861 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754575Ab2EVQMQ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 May 2012 12:12:16 -0400
Received: by wibhj8 with SMTP id hj8so3641610wib.1
        for <linux-nfs@vger.kernel.org>; Tue, 22 May 2012 09:12:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1337688569-1515-2-git-send-email-andros@netapp.com>
References: <1337688569-1515-1-git-send-email-andros@netapp.com>
	<1337688569-1515-2-git-send-email-andros@netapp.com>
Date: Tue, 22 May 2012 12:12:14 -0400
Message-ID: <CAHVgHyUC6RvOEbW67xX0ANgXjk4kbVZiFUYGcqfq72_hJ5NNpw@mail.gmail.com>
Subject: Re: [PATCH 1/4] NFSv4.1 Just use nfs_put_client in filelayout release
From: Andy Adamson <androsadamson@gmail.com>
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Sorry - this is a repeat...

-->Andy

On Tue, May 22, 2012 at 8:09 AM,  <andros@netapp.com> wrote:
> From: Andy Adamson <andros@netapp.com>
>
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  fs/nfs/nfs4filelayout.c |   12 ++----------
>  1 files changed, 2 insertions(+), 10 deletions(-)
>
> diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
> index 474c630..8df91be 100644
> --- a/fs/nfs/nfs4filelayout.c
> +++ b/fs/nfs/nfs4filelayout.c
> @@ -101,9 +101,6 @@ static void filelayout_reset_write(struct nfs_write_data *data)
>                                                        &hdr->pages,
>                                                        hdr->completion_ops);
>        }
> -       /* balance nfs_get_client in filelayout_write_pagelist */
> -       nfs_put_client(data->ds_clp);
> -       data->ds_clp     = NULL;
>  }
>
>  static void filelayout_reset_read(struct nfs_read_data *data)
> @@ -125,9 +122,6 @@ static void filelayout_reset_read(struct nfs_read_data *data)
>                                                        &hdr->pages,
>                                                        hdr->completion_ops);
>        }
> -       /* balance nfs_get_client in filelayout_read_pagelist */
> -       nfs_put_client(data->ds_clp);
> -       data->ds_clp = NULL;
>  }
>
>  static int filelayout_async_handle_error(struct rpc_task *task,
> @@ -326,8 +320,7 @@ static void filelayout_read_release(void *data)
>  {
>        struct nfs_read_data *rdata = data;
>
> -       if (!test_bit(NFS_IOHDR_REDO, &rdata->header->flags))
> -               nfs_put_client(rdata->ds_clp);
> +       nfs_put_client(rdata->ds_clp);
>        rdata->header->mds_ops->rpc_release(data);
>  }
>
> @@ -424,8 +417,7 @@ static void filelayout_write_release(void *data)
>  {
>        struct nfs_write_data *wdata = data;
>
> -       if (!test_bit(NFS_IOHDR_REDO, &wdata->header->flags))
> -               nfs_put_client(wdata->ds_clp);
> +       nfs_put_client(wdata->ds_clp);
>        wdata->header->mds_ops->rpc_release(data);
>  }
>
> --
> 1.7.7.6
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
