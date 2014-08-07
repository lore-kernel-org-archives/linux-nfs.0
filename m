Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f179.google.com ([209.85.213.179]:60688 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754597AbaHGKnf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Aug 2014 06:43:35 -0400
Received: by mail-ig0-f179.google.com with SMTP id h18so4293746igc.12
        for <linux-nfs@vger.kernel.org>; Thu, 07 Aug 2014 03:43:34 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1407396229-4785-9-git-send-email-hch@lst.de>
References: <1407396229-4785-1-git-send-email-hch@lst.de> <1407396229-4785-9-git-send-email-hch@lst.de>
From: Peng Tao <bergwolf@gmail.com>
Date: Thu, 7 Aug 2014 18:43:14 +0800
Message-ID: <CA+a=Yy42e46zA+X-VQQj9RAzZ4T+A7dOOrjUMVONsh8Pt8QdcQ@mail.gmail.com>
Subject: Re: [PATCH 08/17] pnfs/blocklayout: reject pnfs blocksize larger than
 page size
To: Christoph Hellwig <hch@lst.de>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        linuxnfs <linux-nfs@vger.kernel.org>,
        "faibish, sorin" <faibish_sorin@emc.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 7, 2014 at 3:23 PM, Christoph Hellwig <hch@lst.de> wrote:
> The Linux VM subsystem can't support block sizes larger than page size
> for block based filesystems very well.  While this can be hacked around
> to some extent for simple filesystems the read-modify-write cycles
> required for pnfs block invalid extents are extremly deadlock prone
> when operating on multiple pages.  Reject this case early on instead
> of pretending to support it (badly).
>
So this kills EMC server support. Can you please share what kind of
badly deadlock you saw with large block size support?

Thanks,
Tao

> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  fs/nfs/blocklayout/blocklayout.c | 6 ++++++
>  1 file changed, 6 insertions(+)
>
> diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
> index cbb1797..6c1a421 100644
> --- a/fs/nfs/blocklayout/blocklayout.c
> +++ b/fs/nfs/blocklayout/blocklayout.c
> @@ -1115,6 +1115,12 @@ bl_set_layoutdriver(struct nfs_server *server, const struct nfs_fh *fh)
>                 dprintk("%s Server did not return blksize\n", __func__);
>                 return -EINVAL;
>         }
> +       if (server->pnfs_blksize > PAGE_SIZE) {
> +               printk(KERN_ERR "%s: pNFS blksize %d not supported.\n",
> +                       __func__, server->pnfs_blksize);
> +               return -EINVAL;
> +       }
> +
>         b_mt_id = kzalloc(sizeof(struct block_mount_id), GFP_NOFS);
>         if (!b_mt_id) {
>                 status = -ENOMEM;
> --
> 1.9.1
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
