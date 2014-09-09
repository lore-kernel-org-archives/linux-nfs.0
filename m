Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f181.google.com ([209.85.220.181]:59631 "EHLO
	mail-vc0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750972AbaIIEDc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Sep 2014 00:03:32 -0400
Received: by mail-vc0-f181.google.com with SMTP id ij19so2703691vcb.40
        for <linux-nfs@vger.kernel.org>; Mon, 08 Sep 2014 21:03:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1408637375-11343-18-git-send-email-hch@lst.de>
References: <1408637375-11343-1-git-send-email-hch@lst.de>
	<1408637375-11343-18-git-send-email-hch@lst.de>
Date: Mon, 8 Sep 2014 21:03:31 -0700
Message-ID: <CAHQdGtQpDs+oGpwmOgFxx=Yk8N=6cFd_Wmcrr-OYLo4GeXsVUA@mail.gmail.com>
Subject: Re: [PATCH 17/19] pnfs/blocklayout: implement the return_range method
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Christoph Hellwig <hch@lst.de>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 21, 2014 at 9:09 AM, Christoph Hellwig <hch@lst.de> wrote:
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
> +               dprintk("%s: offset %lld not block size aligned\n",
> +                       __func__, range->offset);
> +               return;
> +       }
> +
> +       if (range->length != NFS4_MAX_UINT64) {
> +               if (range->length % 8) {
> +                       dprintk("%s: length %lld not block size aligned\n",
> +                               __func__, range->length);
> +                       return;
> +               }
> +
> +               end = offset + (range->length >> SECTOR_SHIFT);
> +       } else {
> +               end = round_down(NFS4_MAX_UINT64, PAGE_SIZE);
> +       }
> +
> +       err = ext_tree_remove(bl, range->iomode & IOMODE_RW, offset, end);
> +}
> +
> +static void
>  bl_encode_layoutcommit(struct pnfs_layout_hdr *lo, struct xdr_stream *xdr,
>                        const struct nfs4_layoutcommit_args *arg)
>  {
> @@ -777,6 +806,7 @@ static struct pnfs_layoutdriver_type blocklayout_type = {
>         .free_layout_hdr                = bl_free_layout_hdr,
>         .alloc_lseg                     = bl_alloc_lseg,
>         .free_lseg                      = bl_free_lseg,
> +       .return_range                   = bl_return_range,
>         .encode_layoutcommit            = bl_encode_layoutcommit,
>         .cleanup_layoutcommit           = bl_cleanup_layoutcommit,
>         .set_layoutdriver               = bl_set_layoutdriver,
> --
> 1.9.1
>

Again, holding until we resolve [3/19] and apply the patch that
introduces ->return_range()

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
