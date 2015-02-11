Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f180.google.com ([209.85.220.180]:48482 "EHLO
	mail-vc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752429AbbBKMzJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Feb 2015 07:55:09 -0500
Received: by mail-vc0-f180.google.com with SMTP id im6so1033624vcb.11
        for <linux-nfs@vger.kernel.org>; Wed, 11 Feb 2015 04:55:08 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20150211102240.GA18515@mwanda>
References: <20150211102240.GA18515@mwanda>
Date: Wed, 11 Feb 2015 07:55:08 -0500
Message-ID: <CAHQdGtThcmrcCg8oRQuxc_a97Y4sLK9+LN2+wFwi-KwU5H-RTw@mail.gmail.com>
Subject: Re: [patch] pnfs/flexfiles: move kfree() after the deference
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: Anna Schumaker <anna.schumaker@netapp.com>,
        Tao Peng <bergwolf@primarydata.com>,
        Weston Andros Adamson <dros@primarydata.com>,
        Tom Haynes <loghyr@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Kernel Janitors Mailing List
	<kernel-janitors@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Dan,

On Wed, Feb 11, 2015 at 5:22 AM, Dan Carpenter <dan.carpenter@oracle.com> wrote:
> We dereference "err" in the the debug printk so we have to move the
> kfree() down a couple lines.
>
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
>
> diff --git a/fs/nfs/flexfilelayout/flexfilelayoutdev.c b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
> index 3bbb16b..e2c01f2 100644
> --- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
> +++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
> @@ -515,10 +515,10 @@ int ff_layout_encode_ds_ioerr(struct nfs4_flexfile_layout *flo,
>                 *p++ = cpu_to_be32(err->opnum);
>                 *count += 1;
>                 list_del(&err->list);
> -               kfree(err);
>                 dprintk("%s: offset %llu length %llu status %d op %d count %d\n",
>                         __func__, err->offset, err->length, err->status,
>                         err->opnum, *count);
> +               kfree(err);
>         }
>
>         return 0;

I believe this is a fix for the same bug that was reported by Julia
Lawall a couple of days ago. There should be a fix for this already at
http://git.linux-nfs.org/?p=trondmy/linux-nfs.git;a=commitdiff;h=480486b4733d5bc7d9fe765b34bc6c2b72d5c12e

Cheers
  Trond
-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com
