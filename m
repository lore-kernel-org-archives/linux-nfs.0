Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f170.google.com ([209.85.212.170]:42283 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753546Ab2IXOrb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 24 Sep 2012 10:47:31 -0400
Received: by wibhm2 with SMTP id hm2so207825wib.1
        for <linux-nfs@vger.kernel.org>; Mon, 24 Sep 2012 07:47:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1348260621-10294-6-git-send-email-Trond.Myklebust@netapp.com>
References: <1348260621-10294-1-git-send-email-Trond.Myklebust@netapp.com>
	<1348260621-10294-2-git-send-email-Trond.Myklebust@netapp.com>
	<1348260621-10294-3-git-send-email-Trond.Myklebust@netapp.com>
	<1348260621-10294-4-git-send-email-Trond.Myklebust@netapp.com>
	<1348260621-10294-5-git-send-email-Trond.Myklebust@netapp.com>
	<1348260621-10294-6-git-send-email-Trond.Myklebust@netapp.com>
Date: Mon, 24 Sep 2012 10:47:30 -0400
Message-ID: <CAHVgHyW3UmkvH_p_RMqKS6pBFMkbqgAbGrDtLRx=fiicU1OGGA@mail.gmail.com>
Subject: Re: [PATCH v2 06/26] NFSv4.1: Add helpers for setting/reading the I/O
 fail bit
From: Andy Adamson <androsadamson@gmail.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 21, 2012 at 4:50 PM, Trond Myklebust
<Trond.Myklebust@netapp.com> wrote:
> ...and make them local to the pnfs.c file.
>
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
>  fs/nfs/pnfs.c | 37 ++++++++++++++++++++++++++-----------
>  fs/nfs/pnfs.h |  6 ------
>  2 files changed, 26 insertions(+), 17 deletions(-)
>
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index 498af87..f85cc4c 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -238,6 +238,27 @@ pnfs_put_layout_hdr(struct pnfs_layout_hdr *lo)
>         }
>  }
>
> +static int
> +pnfs_iomode_to_fail_bit(u32 iomode)
> +{
> +       return iomode == IOMODE_RW ?
> +               NFS_LAYOUT_RW_FAILED : NFS_LAYOUT_RO_FAILED;
> +}
> +
> +static void
> +pnfs_layout_io_set_failed(struct pnfs_layout_hdr *lo, u32 iomode)
> +{
> +       set_bit(pnfs_iomode_to_fail_bit(iomode), &lo->plh_flags);
> +       dprintk("%s Setting layout IOMODE_%s fail bit\n", __func__,
> +                       iomode == IOMODE_RW ?  "RW" : "READ");
> +}
> +
> +static bool
> +pnfs_layout_io_test_failed(struct pnfs_layout_hdr *lo, u32 iomode)


Nit - this is a bad name. These bits test if LAYOUTGET succeeds or
not. They do not test whether IO succeeded or failed. I suggest
pnfs_layoutget_test_failed.

-->Andy

> +{
> +       return test_bit(pnfs_iomode_to_fail_bit(iomode), &lo->plh_flags) != 0;
> +}
> +
>  static void
>  init_lseg(struct pnfs_layout_hdr *lo, struct pnfs_layout_segment *lseg)
>  {
> @@ -612,7 +633,7 @@ send_layoutget(struct pnfs_layout_hdr *lo,
>                         break;
>                 default:
>                         /* remember that LAYOUTGET failed and suspend trying */
> -                       set_bit(lo_fail_bit(range->iomode), &lo->plh_flags);
> +                       pnfs_layout_io_set_failed(lo, range->iomode);
>                 }
>                 return NULL;
>         }
> @@ -669,8 +690,8 @@ _pnfs_return_layout(struct inode *ino)
>         lrp = kzalloc(sizeof(*lrp), GFP_KERNEL);
>         if (unlikely(lrp == NULL)) {
>                 status = -ENOMEM;
> -               set_bit(NFS_LAYOUT_RW_FAILED, &lo->plh_flags);
> -               set_bit(NFS_LAYOUT_RO_FAILED, &lo->plh_flags);
> +               pnfs_layout_io_set_failed(lo, IOMODE_RW);
> +               pnfs_layout_io_set_failed(lo, IOMODE_READ);
>                 pnfs_clear_layout_returned(lo);
>                 pnfs_put_layout_hdr(lo);
>                 goto out;
> @@ -1046,7 +1067,7 @@ pnfs_update_layout(struct inode *ino,
>         }
>
>         /* if LAYOUTGET already failed once we don't try again */
> -       if (test_bit(lo_fail_bit(iomode), &nfsi->layout->plh_flags))
> +       if (pnfs_layout_io_test_failed(nfsi->layout, iomode))
>                 goto out_unlock;
>
>         /* Check to see if the layout for the given range already exists */
> @@ -1581,13 +1602,7 @@ static void pnfs_list_write_lseg(struct inode *inode, struct list_head *listp)
>
>  void pnfs_set_lo_fail(struct pnfs_layout_segment *lseg)
>  {
> -       if (lseg->pls_range.iomode == IOMODE_RW) {
> -               dprintk("%s Setting layout IOMODE_RW fail bit\n", __func__);
> -               set_bit(lo_fail_bit(IOMODE_RW), &lseg->pls_layout->plh_flags);
> -       } else {
> -               dprintk("%s Setting layout IOMODE_READ fail bit\n", __func__);
> -               set_bit(lo_fail_bit(IOMODE_READ), &lseg->pls_layout->plh_flags);
> -       }
> +       pnfs_layout_io_set_failed(lseg->pls_layout, lseg->pls_range.iomode);
>  }
>  EXPORT_SYMBOL_GPL(pnfs_set_lo_fail);
>
> diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
> index 0495879..e3eb7d1 100644
> --- a/fs/nfs/pnfs.h
> +++ b/fs/nfs/pnfs.h
> @@ -274,12 +274,6 @@ pnfs_test_layout_returned(struct pnfs_layout_hdr *lo)
>         return test_bit(NFS_LAYOUT_RETURNED, &lo->plh_flags);
>  }
>
> -static inline int lo_fail_bit(u32 iomode)
> -{
> -       return iomode == IOMODE_RW ?
> -                        NFS_LAYOUT_RW_FAILED : NFS_LAYOUT_RO_FAILED;
> -}
> -
>  static inline struct pnfs_layout_segment *
>  pnfs_get_lseg(struct pnfs_layout_segment *lseg)
>  {
> --
> 1.7.11.4
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
