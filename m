Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f171.google.com ([209.85.213.171]:57033 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754267AbaHGLFY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Aug 2014 07:05:24 -0400
Received: by mail-ig0-f171.google.com with SMTP id l13so10170797iga.16
        for <linux-nfs@vger.kernel.org>; Thu, 07 Aug 2014 04:05:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1407396229-4785-18-git-send-email-hch@lst.de>
References: <1407396229-4785-1-git-send-email-hch@lst.de> <1407396229-4785-18-git-send-email-hch@lst.de>
From: Peng Tao <bergwolf@gmail.com>
Date: Thu, 7 Aug 2014 19:05:03 +0800
Message-ID: <CA+a=Yy7EmafqPefCG=xNKz-is8h0FgKNSFJ23RshEcLwr5sZ9A@mail.gmail.com>
Subject: Re: [PATCH 17/17] pnfs/blocklayout: allocate separate pages for the
 layoutcommit payload
To: Christoph Hellwig <hch@lst.de>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        linuxnfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 7, 2014 at 3:23 PM, Christoph Hellwig <hch@lst.de> wrote:
> Instead of overflowing the XDR send buffer with our extent list allocate
> pages and pre-encode the layoutupdate payload into them.  We optimistically
> allocate a single page use alloc_page and only switch to vmalloc when we
> have more extents outstanding.  Currently there is only a single testcase
> (xfstests generic/113) which can reproduce large enough extent lists for
> this to occur.
>
depending on how badly the extents are fragmented, it might worth
starting an async layoutcommit within blocklayout client when bl_count
reaches certain limit, so that we don't send an unlimited amount of
extents in one layoutcommit.

Cheers,
Tao

> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  fs/nfs/blocklayout/blocklayout.c |  9 ++--
>  fs/nfs/blocklayout/blocklayout.h |  6 ++-
>  fs/nfs/blocklayout/extent_tree.c | 89 +++++++++++++++++++++++++++++++---------
>  3 files changed, 78 insertions(+), 26 deletions(-)
>
> diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
> index d5a2b87..fae8144 100644
> --- a/fs/nfs/blocklayout/blocklayout.c
> +++ b/fs/nfs/blocklayout/blocklayout.c
> @@ -498,12 +498,11 @@ bl_return_range(struct pnfs_layout_hdr *lo,
>         err = ext_tree_remove(bl, range->iomode & IOMODE_RW, offset, end);
>  }
>
> -static void
> -bl_encode_layoutcommit(struct pnfs_layout_hdr *lo, struct xdr_stream *xdr,
> -                      const struct nfs4_layoutcommit_args *arg)
> +static int
> +bl_prepare_layoutcommit(struct nfs4_layoutcommit_args *arg)
>  {
>         dprintk("%s enter\n", __func__);
> -       ext_tree_encode_commit(BLK_LO2EXT(lo), xdr);
> +       return ext_tree_prepare_commit(arg);
>  }
>
>  static void
> @@ -808,7 +807,7 @@ static struct pnfs_layoutdriver_type blocklayout_type = {
>         .alloc_lseg                     = bl_alloc_lseg,
>         .free_lseg                      = bl_free_lseg,
>         .return_range                   = bl_return_range,
> -       .encode_layoutcommit            = bl_encode_layoutcommit,
> +       .prepare_layoutcommit           = bl_prepare_layoutcommit,
>         .cleanup_layoutcommit           = bl_cleanup_layoutcommit,
>         .set_layoutdriver               = bl_set_layoutdriver,
>         .clear_layoutdriver             = bl_clear_layoutdriver,
> diff --git a/fs/nfs/blocklayout/blocklayout.h b/fs/nfs/blocklayout/blocklayout.h
> index b4f66d8..caae202 100644
> --- a/fs/nfs/blocklayout/blocklayout.h
> +++ b/fs/nfs/blocklayout/blocklayout.h
> @@ -80,6 +80,9 @@ struct pnfs_block_extent {
>         unsigned int    be_tag;
>  };
>
> +/* on the wire size of the extent */
> +#define BL_EXTENT_SIZE (7 * sizeof(__be32) + NFS4_DEVICEID4_SIZE)
> +
>  struct pnfs_block_layout {
>         struct pnfs_layout_hdr  bl_layout;
>         struct rb_root          bl_ext_rw;
> @@ -138,8 +141,7 @@ int ext_tree_mark_written(struct pnfs_block_layout *bl, sector_t start,
>                 sector_t len);
>  bool ext_tree_lookup(struct pnfs_block_layout *bl, sector_t isect,
>                 struct pnfs_block_extent *ret, bool rw);
> -int ext_tree_encode_commit(struct pnfs_block_layout *bl,
> -               struct xdr_stream *xdr);
> +int ext_tree_prepare_commit(struct nfs4_layoutcommit_args *arg);
>  void ext_tree_mark_committed(struct pnfs_block_layout *bl, int status);
>
>  #endif /* FS_NFS_NFS4BLOCKLAYOUT_H */
> diff --git a/fs/nfs/blocklayout/extent_tree.c b/fs/nfs/blocklayout/extent_tree.c
> index c7dacfa..3945221 100644
> --- a/fs/nfs/blocklayout/extent_tree.c
> +++ b/fs/nfs/blocklayout/extent_tree.c
> @@ -465,32 +465,23 @@ out:
>         return err;
>  }
>
> -int
> -ext_tree_encode_commit(struct pnfs_block_layout *bl, struct xdr_stream *xdr)
> +static int ext_tree_encode_commit(struct pnfs_block_layout *bl, __be32 *p,
> +               size_t buffer_size, size_t *count)
>  {
>         struct pnfs_block_extent *be;
> -       unsigned int count = 0;
> -       __be32 *p, *xdr_start;
>         int ret = 0;
>
> -       dprintk("%s enter\n", __func__);
> -
> -       xdr_start = xdr_reserve_space(xdr, 8);
> -       if (!xdr_start)
> -               return -ENOSPC;
> -
>         spin_lock(&bl->bl_ext_lock);
>         for (be = ext_tree_first(&bl->bl_ext_rw); be; be = ext_tree_next(be)) {
>                 if (be->be_state != PNFS_BLOCK_INVALID_DATA ||
>                     be->be_tag != EXTENT_WRITTEN)
>                         continue;
>
> -               p = xdr_reserve_space(xdr, 7 * sizeof(__be32) +
> -                                       NFS4_DEVICEID4_SIZE);
> -               if (!p) {
> -                       printk("%s: out of space for extent list\n", __func__);
> +               (*count)++;
> +               if (*count * BL_EXTENT_SIZE > buffer_size) {
> +                       /* keep counting.. */
>                         ret = -ENOSPC;
> -                       break;
> +                       continue;
>                 }
>
>                 p = xdr_encode_opaque_fixed(p, be->be_devid.data,
> @@ -501,15 +492,75 @@ ext_tree_encode_commit(struct pnfs_block_layout *bl, struct xdr_stream *xdr)
>                 *p++ = cpu_to_be32(PNFS_BLOCK_READWRITE_DATA);
>
>                 be->be_tag = EXTENT_COMMITTING;
> -               count++;
>         }
>         spin_unlock(&bl->bl_ext_lock);
>
> -       xdr_start[0] = cpu_to_be32((xdr->p - xdr_start - 1) * 4);
> -       xdr_start[1] = cpu_to_be32(count);
> +       return ret;
> +}
> +
> +int
> +ext_tree_prepare_commit(struct nfs4_layoutcommit_args *arg)
> +{
> +       struct pnfs_block_layout *bl = BLK_LO2EXT(NFS_I(arg->inode)->layout);
> +       size_t count = 0, buffer_size = PAGE_SIZE;
> +       __be32 *start_p;
> +       int ret;
> +
> +       dprintk("%s enter\n", __func__);
> +
> +       arg->layoutupdate_page = alloc_page(GFP_NOFS);
> +       if (!arg->layoutupdate_page)
> +               return -ENOMEM;
> +       start_p = page_address(arg->layoutupdate_page);
> +       arg->layoutupdate_pages = &arg->layoutupdate_page;
> +
> +retry:
> +       ret = ext_tree_encode_commit(bl, start_p + 1, buffer_size, &count);
> +       if (unlikely(ret)) {
> +               if (arg->layoutupdate_pages != &arg->layoutupdate_page) {
> +                       int nr_pages = DIV_ROUND_UP(buffer_size, PAGE_SIZE), i;
> +
> +                       for (i = 0; i < nr_pages; i++)
> +                               put_page(arg->layoutupdate_pages[i]);
> +                       kfree(arg->layoutupdate_pages);
> +               } else {
> +                       put_page(arg->layoutupdate_page);
> +               }
> +
> +               buffer_size = sizeof(__be32) + BL_EXTENT_SIZE * count;
> +               count = 0;
> +
> +               arg->layoutupdate_pages =
> +                       kcalloc(DIV_ROUND_UP(buffer_size, PAGE_SIZE),
> +                               sizeof(struct page *), GFP_NOFS);
> +               if (!arg->layoutupdate_pages)
> +                       return -ENOMEM;
> +
> +               start_p = __vmalloc(buffer_size, GFP_NOFS, PAGE_KERNEL);
> +               if (!start_p) {
> +                       kfree(arg->layoutupdate_pages);
> +                       return -ENOMEM;
> +               }
> +
> +               goto retry;
> +       }
> +
> +       *start_p = cpu_to_be32(count);
> +       arg->layoutupdate_len = sizeof(__be32) + BL_EXTENT_SIZE * count;
> +
> +       if (unlikely(arg->layoutupdate_pages != &arg->layoutupdate_page)) {
> +               __be32 *p = start_p;
> +               int i = 0;
> +
> +               for (p = start_p;
> +                    p < start_p + arg->layoutupdate_len;
> +                    p += PAGE_SIZE) {
> +                       arg->layoutupdate_pages[i++] = vmalloc_to_page(p);
> +               }
> +       }
>
>         dprintk("%s found %i ranges\n", __func__, count);
> -       return ret;
> +       return 0;
>  }
>
>  void
> --
> 1.9.1
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
