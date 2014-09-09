Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f177.google.com ([209.85.220.177]:38294 "EHLO
	mail-vc0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751556AbaIIEJF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Sep 2014 00:09:05 -0400
Received: by mail-vc0-f177.google.com with SMTP id hq11so16077198vcb.8
        for <linux-nfs@vger.kernel.org>; Mon, 08 Sep 2014 21:09:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1408637375-11343-19-git-send-email-hch@lst.de>
References: <1408637375-11343-1-git-send-email-hch@lst.de>
	<1408637375-11343-19-git-send-email-hch@lst.de>
Date: Mon, 8 Sep 2014 21:09:04 -0700
Message-ID: <CAHQdGtSz3odr0iXvUPv80r9khmEBu9jmgO8wVk96A8yZJLC5Og@mail.gmail.com>
Subject: Re: [PATCH 18/19] pnfs/blocklayout: return layouts on setattr
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Christoph Hellwig <hch@lst.de>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 21, 2014 at 9:09 AM, Christoph Hellwig <hch@lst.de> wrote:
> This speads up truncate-heavy workloads like fsx by multiple orders of
> magnitude.
>
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  fs/nfs/blocklayout/blocklayout.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
> index a7524c4..d5a2b87 100644
> --- a/fs/nfs/blocklayout/blocklayout.c
> +++ b/fs/nfs/blocklayout/blocklayout.c
> @@ -799,7 +799,8 @@ static struct pnfs_layoutdriver_type blocklayout_type = {
>         .id                             = LAYOUT_BLOCK_VOLUME,
>         .name                           = "LAYOUT_BLOCK_VOLUME",
>         .owner                          = THIS_MODULE,
> -       .flags                          = PNFS_READ_WHOLE_PAGE,
> +       .flags                          = PNFS_LAYOUTRET_ON_SETATTR |
> +                                         PNFS_READ_WHOLE_PAGE,
>         .read_pagelist                  = bl_read_pagelist,
>         .write_pagelist                 = bl_write_pagelist,
>         .alloc_layout_hdr               = bl_alloc_layout_hdr,
> --


Holding this pending resolution of issues with "[PATCH 07/19] pnfs:
add flag to force read-modify-write in ->write_begin" on which there
is a dependency.

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
