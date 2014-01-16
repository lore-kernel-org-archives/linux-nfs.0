Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f174.google.com ([74.125.82.174]:61333 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752018AbaAPPtX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Jan 2014 10:49:23 -0500
MIME-Version: 1.0
In-Reply-To: <1389638751-16173-2-git-send-email-trond.myklebust@primarydata.com>
References: <395EC1ED-E67E-4666-B170-5C5F00264496@primarydata.com>
 <1389638751-16173-1-git-send-email-trond.myklebust@primarydata.com> <1389638751-16173-2-git-send-email-trond.myklebust@primarydata.com>
From: Peng Tao <bergwolf@gmail.com>
Date: Thu, 16 Jan 2014 23:49:02 +0800
Message-ID: <CA+a=Yy6uf73Y=F5-Jp+2VrzMmbTYZXqDaEj-EHX335M3ZCvEZA@mail.gmail.com>
Subject: Re: [PATCH 2/2] NFSv4.1: Fix a race in nfs4_write_inode
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: shaobingqing <shaobingqing@bwstor.com.cn>,
        linuxnfs <linux-nfs@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 14, 2014 at 2:45 AM, Trond Myklebust
<trond.myklebust@primarydata.com> wrote:
> nfs4_write_inode() must not be allowed to exit until the layoutcommit
> is done. That means that both NFS_INO_LAYOUTCOMMIT and
> NFS_INO_LAYOUTCOMMITTING have to be cleared.
>
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  fs/nfs/nfs4super.c | 14 +++---------
>  fs/nfs/pnfs.c      | 67 ++++++++++++++++++++++++++++--------------------------
>  2 files changed, 38 insertions(+), 43 deletions(-)
>
> diff --git a/fs/nfs/nfs4super.c b/fs/nfs/nfs4super.c
> index 65ab0a0ca1c4..808f29574412 100644
> --- a/fs/nfs/nfs4super.c
> +++ b/fs/nfs/nfs4super.c
> @@ -77,17 +77,9 @@ static int nfs4_write_inode(struct inode *inode, struct writeback_control *wbc)
>  {
>         int ret = nfs_write_inode(inode, wbc);
>
> -       if (ret >= 0 && test_bit(NFS_INO_LAYOUTCOMMIT, &NFS_I(inode)->flags)) {
> -               int status;
> -               bool sync = true;!test_and_clear_bit
> -
> -               if (wbc->sync_mode == WB_SYNC_NONE)
> -                       sync = false;
> -
> -               status = pnfs_layoutcommit_inode(inode, sync);
> -               if (status < 0)
> -                       return status;
> -       }
> +       if (ret == 0)
> +               ret = pnfs_layoutcommit_inode(inode,
> +                               wbc->sync_mode == WB_SYNC_ALL);
>         return ret;
>  }
>
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index d75d938d36cb..4755858e37a0 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -1790,6 +1790,15 @@ pnfs_generic_pg_readpages(struct nfs_pageio_descriptor *desc)
>  }
>  EXPORT_SYMBOL_GPL(pnfs_generic_pg_readpages);
>
> +static void pnfs_clear_layoutcommitting(struct inode *inode)
> +{
> +       unsigned long *bitlock = &NFS_I(inode)->flags;
> +
> +       clear_bit_unlock(NFS_INO_LAYOUTCOMMITTING, bitlock);
> +       smp_mb__after_clear_bit();
> +       wake_up_bit(bitlock, NFS_INO_LAYOUTCOMMITTING);
> +}
> +
>  /*
>   * There can be multiple RW segments.
>   */
> @@ -1807,7 +1816,6 @@ static void pnfs_list_write_lseg(struct inode *inode, struct list_head *listp)
>  static void pnfs_list_write_lseg_done(struct inode *inode, struct list_head *listp)
>  {
>         struct pnfs_layout_segment *lseg, *tmp;
> -       unsigned long *bitlock = &NFS_I(inode)->flags;
>
>         /* Matched by references in pnfs_set_layoutcommit */
>         list_for_each_entry_safe(lseg, tmp, listp, pls_lc_list) {
> @@ -1815,9 +1823,7 @@ static void pnfs_list_write_lseg_done(struct inode *inode, struct list_head *lis
>                 pnfs_put_lseg(lseg);
>         }
>
> -       clear_bit_unlock(NFS_INO_LAYOUTCOMMITTING, bitlock);
> -       smp_mb__after_clear_bit();
> -       wake_up_bit(bitlock, NFS_INO_LAYOUTCOMMITTING);
> +       pnfs_clear_layoutcommitting(inode);
>  }
>
>  void pnfs_set_lo_fail(struct pnfs_layout_segment *lseg)
> @@ -1881,43 +1887,37 @@ pnfs_layoutcommit_inode(struct inode *inode, bool sync)
>         struct nfs4_layoutcommit_data *data;
>         struct nfs_inode *nfsi = NFS_I(inode);
>         loff_t end_pos;
> -       int status = 0;
> +       int status;
>
> -       dprintk("--> %s inode %lu\n", __func__, inode->i_ino);
> -
> -       if (!test_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->flags))
> +       if (!pnfs_layoutcommit_outstanding(inode))
This might be a problem. If nfsi->flags has !NFS_INO_LAYOUTCOMMIT and
NFS_INO_LAYOUTCOMMITTING, client cannot issue a new layoutcommit after
the inflight one finishes. It might not be an issue for file layout as
long as we only use layoutcommit to update time, but it can cause data
corruption for block layout.

Thanks,
Tao
