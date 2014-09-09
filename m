Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f175.google.com ([209.85.220.175]:47259 "EHLO
	mail-vc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755461AbaIIAho (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Sep 2014 20:37:44 -0400
Received: by mail-vc0-f175.google.com with SMTP id lf12so16058019vcb.6
        for <linux-nfs@vger.kernel.org>; Mon, 08 Sep 2014 17:37:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1408637375-11343-4-git-send-email-hch@lst.de>
References: <1408637375-11343-1-git-send-email-hch@lst.de>
	<1408637375-11343-4-git-send-email-hch@lst.de>
Date: Mon, 8 Sep 2014 17:37:42 -0700
Message-ID: <CAHQdGtQ5--A4_NJpJZ=VEkomCbFYM=6AitSEdexShvBk=aJsPQ@mail.gmail.com>
Subject: Re: [PATCH 03/19] pnfs: force a layout commit when encountering busy
 segments during recall
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Christoph Hellwig <hch@lst.de>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 21, 2014 at 9:09 AM, Christoph Hellwig <hch@lst.de> wrote:
> Expedite layout recall processing by forcing a layout commit when
> we see busy segments.  Without it the layout recall might have to wait
> until the VM decided to start writeback for the file, which can introduce
> long delays.
>
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  fs/nfs/callback_proc.c | 16 +++++++++++-----
>  fs/nfs/pnfs.c          |  3 +++
>  2 files changed, 14 insertions(+), 5 deletions(-)
>
> diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
> index 41db525..bf017b0 100644
> --- a/fs/nfs/callback_proc.c
> +++ b/fs/nfs/callback_proc.c
> @@ -164,6 +164,7 @@ static u32 initiate_file_draining(struct nfs_client *clp,
>         struct inode *ino;
>         struct pnfs_layout_hdr *lo;
>         u32 rv = NFS4ERR_NOMATCHING_LAYOUT;
> +       bool need_commit = false;
>         LIST_HEAD(free_me_list);
>
>         lo = get_layout_by_fh(clp, &args->cbl_fh, &args->cbl_stateid);
> @@ -172,16 +173,21 @@ static u32 initiate_file_draining(struct nfs_client *clp,
>
>         ino = lo->plh_inode;
>         spin_lock(&ino->i_lock);
> -       if (test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags) ||
> -           pnfs_mark_matching_lsegs_invalid(lo, &free_me_list,
> -                                       &args->cbl_range))
> +       if (test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags)) {
>                 rv = NFS4ERR_DELAY;
> -       else
> -               rv = NFS4ERR_NOMATCHING_LAYOUT;
> +       } else if (pnfs_mark_matching_lsegs_invalid(lo, &free_me_list,
> +                       &args->cbl_range)) {
> +               need_commit = true;
> +               rv = NFS4ERR_DELAY;
> +       }
> +
>         pnfs_set_layout_stateid(lo, &args->cbl_stateid, true);
>         spin_unlock(&ino->i_lock);
>         pnfs_free_lseg_list(&free_me_list);
>         pnfs_put_layout_hdr(lo);
> +
> +       if (need_commit)
> +               pnfs_layoutcommit_inode(ino, false);

Why wouldn't it make more sense to call pnfs_layoutcommit_inode()
unconditionally before the call to pnfs_mark_matching_lsegs_invalid()?

>         iput(ino);
>  out:
>         return rv;
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index 6e0fa71..242e73f 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -604,6 +604,9 @@ pnfs_layout_free_bulk_destroy_list(struct list_head *layout_list,
>                 spin_unlock(&inode->i_lock);
>                 pnfs_free_lseg_list(&lseg_list);
>                 pnfs_put_layout_hdr(lo);
> +
> +               if (ret)
> +                       pnfs_layoutcommit_inode(inode, false);

Ditto. The test for 'ret' here is particularly confusing given that it
can get set in a previous iteration of the loop.

>                 iput(inode);
>         }
>         return ret;
> --
> 1.9.1
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
