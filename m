Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f169.google.com ([209.85.220.169]:61098 "EHLO
	mail-vc0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751077AbaIIEsE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Sep 2014 00:48:04 -0400
Received: by mail-vc0-f169.google.com with SMTP id hq11so16825819vcb.28
        for <linux-nfs@vger.kernel.org>; Mon, 08 Sep 2014 21:48:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1408637375-11343-16-git-send-email-hch@lst.de>
References: <1408637375-11343-1-git-send-email-hch@lst.de>
	<1408637375-11343-16-git-send-email-hch@lst.de>
Date: Mon, 8 Sep 2014 21:48:03 -0700
Message-ID: <CAHQdGtTOGYhYuULJA4eTZkv3ppgG2OH_K=wZ1RKpnkmj+hhgPg@mail.gmail.com>
Subject: Re: [PATCH 15/19] pnfs/blocklayout: don't set pages uptodate
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Christoph Hellwig <hch@lst.de>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 21, 2014 at 9:09 AM, Christoph Hellwig <hch@lst.de> wrote:
> The core nfs code handles setting pages uptodate on reads, no need to mess
> with the pageflags outselves.  Also remove a debug function to dump page
> flags.
>
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  fs/nfs/blocklayout/blocklayout.c | 24 +-----------------------
>  1 file changed, 1 insertion(+), 23 deletions(-)
>
> diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
> index 6484b9f..92be984 100644
> --- a/fs/nfs/blocklayout/blocklayout.c
> +++ b/fs/nfs/blocklayout/blocklayout.c
> @@ -49,20 +49,6 @@ MODULE_LICENSE("GPL");
>  MODULE_AUTHOR("Andy Adamson <andros@citi.umich.edu>");
>  MODULE_DESCRIPTION("The NFSv4.1 pNFS Block layout driver");
>
> -static void print_page(struct page *page)
> -{
> -       dprintk("PRINTPAGE page %p\n", page);
> -       dprintk("       PagePrivate %d\n", PagePrivate(page));
> -       dprintk("       PageUptodate %d\n", PageUptodate(page));
> -       dprintk("       PageError %d\n", PageError(page));
> -       dprintk("       PageDirty %d\n", PageDirty(page));
> -       dprintk("       PageReferenced %d\n", PageReferenced(page));
> -       dprintk("       PageLocked %d\n", PageLocked(page));
> -       dprintk("       PageWriteback %d\n", PageWriteback(page));
> -       dprintk("       PageMappedToDisk %d\n", PageMappedToDisk(page));
> -       dprintk("\n");
> -}
> -
>  /* Given the be associated with isect, determine if page data needs to be
>   * initialized.
>   */
> @@ -187,16 +173,9 @@ retry:
>         return bio;
>  }
>
> -/* This is basically copied from mpage_end_io_read */
>  static void bl_end_io_read(struct bio *bio, int err)
>  {
>         struct parallel_io *par = bio->bi_private;
> -       struct bio_vec *bvec;
> -       int i;
> -
> -       if (!err)
> -               bio_for_each_segment_all(bvec, bio, i)
> -                       SetPageUptodate(bvec->bv_page);
>
>         if (err) {
>                 struct nfs_pgio_header *header = par->data;
> @@ -205,6 +184,7 @@ static void bl_end_io_read(struct bio *bio, int err)
>                         header->pnfs_error = -EIO;
>                 pnfs_set_lo_fail(header->lseg);
>         }
> +
>         bio_put(bio);
>         put_parallel(par);
>  }
> @@ -304,8 +284,6 @@ bl_read_pagelist(struct nfs_pgio_header *hdr)
>                         /* Fill hole w/ zeroes w/o accessing device */
>                         dprintk("%s Zeroing page for hole\n", __func__);
>                         zero_user_segment(pages[i], pg_offset, pg_len);
> -                       print_page(pages[i]);
> -                       SetPageUptodate(pages[i]);
>                 } else {
>                         struct pnfs_block_extent *be_read;
>
> --
> 1.9.1
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Depends on "[PATCH 14/19] pnfs/blocklayout: remove read-modify-write
handling in bl_write_pagelist". Holding for now.

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
