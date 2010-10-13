Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:44798 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751119Ab0JMTg5 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Oct 2010 15:36:57 -0400
Received: by bwz15 with SMTP id 15so27098bwz.19
        for <linux-nfs@vger.kernel.org>; Wed, 13 Oct 2010 12:36:55 -0700 (PDT)
In-Reply-To: <1286878408-10287-1-git-send-email-andros@netapp.com>
References: <1286878408-10287-1-git-send-email-andros@netapp.com>
Date: Wed, 13 Oct 2010 15:35:54 -0400
Message-ID: <AANLkTikvMAYg8OesTu+p12K6HYDgZrX6WEKGOxkUJurP@mail.gmail.com>
Subject: Re: [PATCH 1/2] pnfs_submit: fix layoutreturn layout stateid processing
From: Fred Isaman <iisaman@netapp.com>
To: andros@netapp.com
Cc: bhalevy@panasas.com, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Oct 12, 2010 at 6:13 AM,  <andros@netapp.com> wrote:
> From: Andy Adamson <andros@netapp.com>
>
> Add missing layoutreturn stateid update.
> This patch also enforces the following rfc 5661 requirement:
>
> section 12.5.4

Should this be 12.5.3?

>   "For LAYOUTRETURN results, the client MUST delete the range from its
>   record of what ranges of the file's layout it had before using the
>   seqid."
>
> Reported-by: P.B.Shelley <shelleypt@gmail.com>
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  fs/nfs/nfs4proc.c |   10 +++++-----
>  fs/nfs/pnfs.c     |    7 +++----
>  fs/nfs/pnfs.h     |    3 ++-
>  3 files changed, 10 insertions(+), 10 deletions(-)
>
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 7727f59..4c56d9b 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -5678,11 +5678,11 @@ static void nfs4_layoutreturn_release(void *calldata)
>        dprintk("--> %s return_type %d lo %p\n", __func__,
>                lrp->args.return_type, lo);
>
> -       if (lrp->args.return_type == RETURN_FILE) {
> -               if (!lrp->res.lrs_present)
> -                       pnfs_invalidate_layout_stateid(lo);
> -               pnfs_layoutreturn_release(lo, &lrp->args.range);
> -       }
> +       pnfs_layoutreturn_release(lo, &lrp->args.range);

args.range (and lo itself) only make sense in RETURN_FILE case.

> +       if (!lrp->res.lrs_present)
> +               pnfs_invalidate_layout_stateid(lo);
> +       else
> +               pnfs_set_layout_stateid(lo, &lrp->res.stateid);
>        kfree(calldata);
>        dprintk("<-- %s\n", __func__);
>  }
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index eb4dfdf..124d3ca 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -400,8 +400,7 @@ pnfs_layoutreturn_release(struct pnfs_layout_hdr *lo,
>        LIST_HEAD(tmp_list);
>
>        spin_lock(&nfsi->vfs_inode.i_lock);
> -       if (range)
> -               pnfs_clear_lseg_list(lo, &tmp_list, range);
> +       pnfs_clear_lseg_list(lo, &tmp_list, range);
>        put_layout_hdr_locked(lo); /* Matched in _pnfs_return_layout */
>        spin_unlock(&nfsi->vfs_inode.i_lock);
>        pnfs_free_lseg_list(&tmp_list);
> @@ -460,7 +459,7 @@ pnfs_destroy_all_layouts(struct nfs_client *clp)
>  *
>  * lo->stateid could be the open stateid, in which case we just use what given.
>  */
> -static void
> +void
>  pnfs_set_layout_stateid(struct pnfs_layout_hdr *lo,
>                        const nfs4_stateid *new)
>  {
> @@ -625,7 +624,7 @@ return_layout(struct inode *ino, struct pnfs_layout_range *range,
>        lrp = kzalloc(sizeof(*lrp), GFP_KERNEL);
>        if (lrp == NULL) {
>                if (lo && (type == RETURN_FILE))
> -                       pnfs_layoutreturn_release(lo, NULL);
> +                       put_layout_hdr(lo->inode);
>                goto out;
>        }
>        lrp->args.reclaim = 0;
> diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
> index 235709e..3fd2bc3 100644
> --- a/fs/nfs/pnfs.h
> +++ b/fs/nfs/pnfs.h
> @@ -210,7 +210,8 @@ void pnfs_destroy_all_layouts(struct nfs_client *);
>  void put_layout_hdr(struct inode *inode);
>  void pnfs_get_layout_stateid(nfs4_stateid *dst, struct pnfs_layout_hdr *lo,
>                             struct nfs4_state *open_state);
> -
> +void pnfs_set_layout_stateid(struct pnfs_layout_hdr *lo,
> +                                   const nfs4_stateid *new);
>
>  static inline bool
>  has_layout(struct nfs_inode *nfsi)
> --
> 1.6.6
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
