Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f45.google.com ([209.85.216.45]:35140 "EHLO
	mail-qa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751054AbaIKORT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Sep 2014 10:17:19 -0400
Received: by mail-qa0-f45.google.com with SMTP id s7so3425395qap.18
        for <linux-nfs@vger.kernel.org>; Thu, 11 Sep 2014 07:17:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1410362617-28018-8-git-send-email-hch@lst.de>
References: <1410362617-28018-1-git-send-email-hch@lst.de> <1410362617-28018-8-git-send-email-hch@lst.de>
From: Peng Tao <bergwolf@primarydata.com>
Date: Thu, 11 Sep 2014 22:16:56 +0800
Message-ID: <CAKVebiWGsuHTFbCdfQ+=tYakwok5-KPWK7A=zaWmnuJewS+fGg@mail.gmail.com>
Subject: Re: [PATCH 7/9] pnfs/blocklayout: implement the return_range method
To: Christoph Hellwig <hch@lst.de>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 10, 2014 at 11:23 PM, Christoph Hellwig <hch@lst.de> wrote:
> This allows removing extents from the extent tree especially on truncate
> operations, and thus fixing reads from truncated and re-extended that
> previously returned stale data.
>
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  fs/nfs/blocklayout/blocklayout.c | 30 ++++++++++++++++++++++++++++++
>  1 file changed, 30 insertions(+)
>
> diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
> index 42b6f9c..a7524c4 100644
> --- a/fs/nfs/blocklayout/blocklayout.c
> +++ b/fs/nfs/blocklayout/blocklayout.c
> @@ -470,6 +470,35 @@ static struct pnfs_layout_segment *bl_alloc_lseg(struct pnfs_layout_hdr *lo,
>  }
>
>  static void
> +bl_return_range(struct pnfs_layout_hdr *lo,
> +               struct pnfs_layout_range *range)
> +{
> +       struct pnfs_block_layout *bl = BLK_LO2EXT(lo);
> +       sector_t offset = range->offset >> SECTOR_SHIFT, end;
> +       int err;
> +
> +       if (range->offset % 8) {
why arbitrary block size? You should be able to use the blocksize
returned by server, right?

btw, did you test your patchset with smaller block size such as 2K/1K?
Did it work?

> +               dprintk("%s: offset %lld not block size aligned\n",
> +                       __func__, range->offset);
> +               return;
> +       }
> +
> +       if (range->length != NFS4_MAX_UINT64) {
> +               if (range->length % 8) {
ditto here.

Cheers,
Tao
