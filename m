Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f178.google.com ([209.85.212.178]:35220 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754107Ab2IXOrm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 24 Sep 2012 10:47:42 -0400
Received: by wibhr14 with SMTP id hr14so4973508wib.1
        for <linux-nfs@vger.kernel.org>; Mon, 24 Sep 2012 07:47:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1348260621-10294-10-git-send-email-Trond.Myklebust@netapp.com>
References: <1348260621-10294-1-git-send-email-Trond.Myklebust@netapp.com>
	<1348260621-10294-2-git-send-email-Trond.Myklebust@netapp.com>
	<1348260621-10294-3-git-send-email-Trond.Myklebust@netapp.com>
	<1348260621-10294-4-git-send-email-Trond.Myklebust@netapp.com>
	<1348260621-10294-5-git-send-email-Trond.Myklebust@netapp.com>
	<1348260621-10294-6-git-send-email-Trond.Myklebust@netapp.com>
	<1348260621-10294-7-git-send-email-Trond.Myklebust@netapp.com>
	<1348260621-10294-8-git-send-email-Trond.Myklebust@netapp.com>
	<1348260621-10294-9-git-send-email-Trond.Myklebust@netapp.com>
	<1348260621-10294-10-git-send-email-Trond.Myklebust@netapp.com>
Date: Mon, 24 Sep 2012 10:47:41 -0400
Message-ID: <CAHVgHyVmAERb8ndXiUTG=6TBuCQOBWtn0h5ps0fix5aAcu2+WA@mail.gmail.com>
Subject: Re: [PATCH v2 10/26] NFSv4.1: pnfs_layout_io_test_failed must clear
 invalid lsegs before a retry
From: Andy Adamson <androsadamson@gmail.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 21, 2012 at 4:50 PM, Trond Myklebust
<Trond.Myklebust@netapp.com> wrote:
> If pnfs_layout_io_test_failed() authorises a retry of the failed layoutgets,
> it should first clear the existing layout segments so that we start afresh.
>
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
>  fs/nfs/pnfs.c | 8 ++++++--
>  1 file changed, 6 insertions(+), 2 deletions(-)
>
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index cbbb0fc..80aaaba 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -256,7 +256,8 @@ pnfs_layout_io_set_failed(struct pnfs_layout_hdr *lo, u32 iomode)
>  }
>
>  static bool
> -pnfs_layout_io_test_failed(struct pnfs_layout_hdr *lo, u32 iomode)
> +pnfs_layout_io_test_failed(struct pnfs_layout_hdr *lo, u32 iomode,
> +               struct list_head *head)
>  {
>         unsigned long start, end;
>         if (test_bit(pnfs_iomode_to_fail_bit(iomode), &lo->plh_flags) == 0)
> @@ -267,6 +268,7 @@ pnfs_layout_io_test_failed(struct pnfs_layout_hdr *lo, u32 iomode)
>                 /* It is time to retry the failed layoutgets */
>                 clear_bit(NFS_LAYOUT_RW_FAILED, &lo->plh_flags);
>                 clear_bit(NFS_LAYOUT_RO_FAILED, &lo->plh_flags);
> +               pnfs_mark_matching_lsegs_invalid(lo, head, NULL);

By clearing all iomode failed bits and passing a NULL as the
recall_range to pnfs_mark_matching_lsegs, you are discarding layouts
not authorized by the iomode passed into pnfs_layout_io_test_failed.
Why not clear just the failed bit and setup a pnfs_layout_range
structure (for the whole file) and pass the authorized failed iomode
to pnfs_mark_matching_lsegs so as to remove only the failed iomode
layout segments?

-->Andy


>                 return false;
>         }
>         return true;
> @@ -1058,6 +1060,7 @@ pnfs_update_layout(struct inode *ino,
>         struct nfs_client *clp = server->nfs_client;
>         struct pnfs_layout_hdr *lo;
>         struct pnfs_layout_segment *lseg = NULL;
> +       LIST_HEAD(tmp_list);
>         bool first = false;
>
>         if (!pnfs_enabled_sb(NFS_SERVER(ino)))
> @@ -1081,7 +1084,7 @@ pnfs_update_layout(struct inode *ino,
>         }
>
>         /* if LAYOUTGET already failed once we don't try again */
> -       if (pnfs_layout_io_test_failed(nfsi->layout, iomode))
> +       if (pnfs_layout_io_test_failed(nfsi->layout, iomode, &tmp_list))
>                 goto out_unlock;
>
>         /* Check to see if the layout for the given range already exists */
> @@ -1127,6 +1130,7 @@ pnfs_update_layout(struct inode *ino,
>         }
>         atomic_dec(&lo->plh_outstanding);
>  out:
> +       pnfs_free_lseg_list(&tmp_list);
>         pnfs_put_layout_hdr(lo);
>         dprintk("%s end, state 0x%lx lseg %p\n", __func__,
>                 nfsi->layout ? nfsi->layout->plh_flags : -1, lseg);
> --
> 1.7.11.4
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
