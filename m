Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f48.google.com ([209.85.192.48]:36197 "EHLO
	mail-qg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752662AbaKMBEO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Nov 2014 20:04:14 -0500
Received: by mail-qg0-f48.google.com with SMTP id q108so9787750qgd.21
        for <linux-nfs@vger.kernel.org>; Wed, 12 Nov 2014 17:04:14 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1415812080-3033-1-git-send-email-dros@primarydata.com>
References: <1415812080-3033-1-git-send-email-dros@primarydata.com>
From: Peng Tao <bergwolf@primarydata.com>
Date: Thu, 13 Nov 2014 09:03:53 +0800
Message-ID: <CAKVebiX=mRJ7Psc8+FigNLRgGB8vH84vcKdv173HvuT20+eh=w@mail.gmail.com>
Subject: Re: [PATCH] NFS: fix subtle change in COMMIT behavior
To: Weston Andros Adamson <dros@primarydata.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Christoph Hellwig <hch@lst.de>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Nov 13, 2014 at 1:08 AM, Weston Andros Adamson
<dros@primarydata.com> wrote:
> Recent work in the pgio layer made it possible for there to be more than one
> request per page. This caused a subtle change in commit behavior, because
> write.c:nfs_commit_unstable_pages compares the number of *pages* waiting for
> writeback against the number of requests on a commit list to choose when to
> send a COMMIT in a non-blocking flush.
>
> This is probably hard to hit in normal operation - you have to be using
> rsize/wsize < PAGE_SIZE, or pnfs with lots of boundaries that are not page
> aligned to have a noticeable change in behavior.
>
> Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
> ---
>
> There is one portion of this patch that I'm not 100% on - the blocklayout
> portion. It seems to be using the (old) nfsi->npages as a count of how many
> contiguous *whole* pages are in use, but that's never been what nfsi->npages
> was counting -- it would be incremented if just one byte of a page was in use,
> but should be contiguous (as enforced by nfs_flush_incompatible).
>
The idea is to get an estimation on the length of layout that client
wants to use. So even if a single byte is used by client, client would
want to ask for a layout that covers the whole page.

> Trond things that simply using the new nfsi->nrequests is ok here, because
> the block layout should always be using requests > PAGE_SIZE. Any blocklayout
> experts have an opinion? CCing Christoph...
>
>  -dros
>
>  fs/nfs/blocklayout/blocklayout.c |  2 +-
>  fs/nfs/callback_proc.c           |  2 +-
>  fs/nfs/inode.c                   |  8 ++++----
>  fs/nfs/pagelist.c                | 11 ++++++++---
>  fs/nfs/write.c                   | 17 ++++++++++++-----
>  include/linux/nfs_fs.h           |  4 ++--
>  6 files changed, 28 insertions(+), 16 deletions(-)
>
> diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
> index b439edfda3ff..5cd836b415a9 100644
> --- a/fs/nfs/blocklayout/blocklayout.c
> +++ b/fs/nfs/blocklayout/blocklayout.c
> @@ -812,7 +812,7 @@ static u64 pnfs_num_cont_bytes(struct inode *inode, pgoff_t idx)
>
>         /* Optimize common case that writes from 0 to end of file */
>         end = DIV_ROUND_UP(i_size_read(inode), PAGE_CACHE_SIZE);
> -       if (end != NFS_I(inode)->npages) {
> +       if (end != NFS_I(inode)->nrequests) {
>                 rcu_read_lock();
>                 end = page_cache_next_hole(mapping, idx + 1, ULONG_MAX);
>                 rcu_read_unlock();
> diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
> index 9c3a07b48655..f4be136f02de 100644
> --- a/fs/nfs/callback_proc.c
> +++ b/fs/nfs/callback_proc.c
> @@ -49,7 +49,7 @@ __be32 nfs4_callback_getattr(struct cb_getattrargs *args,
>                 goto out_iput;
>         res->size = i_size_read(inode);
>         res->change_attr = delegation->change_attr;
> -       if (nfsi->npages != 0)
> +       if (nfsi->nrequests != 0)
>                 res->change_attr++;
>         res->ctime = inode->i_ctime;
>         res->mtime = inode->i_mtime;
> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index 6388a59f2add..90367d7e31a0 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -1149,7 +1149,7 @@ static unsigned long nfs_wcc_update_inode(struct inode *inode, struct nfs_fattr
>         if ((fattr->valid & NFS_ATTR_FATTR_PRESIZE)
>                         && (fattr->valid & NFS_ATTR_FATTR_SIZE)
>                         && i_size_read(inode) == nfs_size_to_loff_t(fattr->pre_size)
> -                       && nfsi->npages == 0) {
> +                       && nfsi->nrequests == 0) {
>                 i_size_write(inode, nfs_size_to_loff_t(fattr->size));
>                 ret |= NFS_INO_INVALID_ATTR;
>         }
> @@ -1192,7 +1192,7 @@ static int nfs_check_inode_attributes(struct inode *inode, struct nfs_fattr *fat
>         if (fattr->valid & NFS_ATTR_FATTR_SIZE) {
>                 cur_size = i_size_read(inode);
>                 new_isize = nfs_size_to_loff_t(fattr->size);
> -               if (cur_size != new_isize && nfsi->npages == 0)
> +               if (cur_size != new_isize && nfsi->nrequests == 0)
>                         invalid |= NFS_INO_INVALID_ATTR|NFS_INO_REVAL_PAGECACHE;
>         }
>
> @@ -1619,7 +1619,7 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
>                 if (new_isize != cur_isize) {
>                         /* Do we perhaps have any outstanding writes, or has
>                          * the file grown beyond our last write? */
> -                       if ((nfsi->npages == 0) || new_isize > cur_isize) {
> +                       if ((nfsi->nrequests == 0) || new_isize > cur_isize) {
>                                 i_size_write(inode, new_isize);
>                                 invalid |= NFS_INO_INVALID_ATTR|NFS_INO_INVALID_DATA;
>                                 invalid &= ~NFS_INO_REVAL_PAGECACHE;
> @@ -1784,7 +1784,7 @@ static void init_once(void *foo)
>         INIT_LIST_HEAD(&nfsi->access_cache_entry_lru);
>         INIT_LIST_HEAD(&nfsi->access_cache_inode_lru);
>         INIT_LIST_HEAD(&nfsi->commit_info.list);
> -       nfsi->npages = 0;
> +       nfsi->nrequests = 0;
>         nfsi->commit_info.ncommit = 0;
>         atomic_set(&nfsi->commit_info.rpcs_out, 0);
>         atomic_set(&nfsi->silly_count, 1);
> diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
> index fabb173f5f62..a2d8827f5975 100644
> --- a/fs/nfs/pagelist.c
> +++ b/fs/nfs/pagelist.c
> @@ -263,6 +263,7 @@ bool nfs_page_group_sync_on_bit(struct nfs_page *req, unsigned int bit)
>  static inline void
>  nfs_page_group_init(struct nfs_page *req, struct nfs_page *prev)
>  {
> +       struct inode *inode;
>         WARN_ON_ONCE(prev == req);
>
>         if (!prev) {
> @@ -281,12 +282,16 @@ nfs_page_group_init(struct nfs_page *req, struct nfs_page *prev)
>                  * nfs_page_group_destroy is called */
>                 kref_get(&req->wb_head->wb_kref);
>
> -               /* grab extra ref if head request has extra ref from
> -                * the write/commit path to handle handoff between write
> -                * and commit lists */
> +               /* grab extra ref and bump the request count if head request
> +                * has extra ref from the write/commit path to handle handoff
> +                * between write and commit lists. */
>                 if (test_bit(PG_INODE_REF, &prev->wb_head->wb_flags)) {
> +                       inode = page_file_mapping(req->wb_page)->host;
>                         set_bit(PG_INODE_REF, &req->wb_flags);
>                         kref_get(&req->wb_kref);
> +                       spin_lock(&inode->i_lock);
> +                       NFS_I(inode)->nrequests++;
> +                       spin_unlock(&inode->i_lock);
>                 }
>         }
>  }
> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> index 0bd0a5d07326..c31d479da159 100644
> --- a/fs/nfs/write.c
> +++ b/fs/nfs/write.c
> @@ -675,7 +675,8 @@ static void nfs_inode_add_request(struct inode *inode, struct nfs_page *req)
>         nfs_lock_request(req);
>
>         spin_lock(&inode->i_lock);
> -       if (!nfsi->npages && NFS_PROTO(inode)->have_delegation(inode, FMODE_WRITE))
> +       if (!nfsi->nrequests &&
> +           NFS_PROTO(inode)->have_delegation(inode, FMODE_WRITE))
>                 inode->i_version++;
>         /*
>          * Swap-space should not get truncated. Hence no need to plug the race
> @@ -686,9 +687,11 @@ static void nfs_inode_add_request(struct inode *inode, struct nfs_page *req)
>                 SetPagePrivate(req->wb_page);
>                 set_page_private(req->wb_page, (unsigned long)req);
>         }
> -       nfsi->npages++;
> +       nfsi->nrequests++;
>         /* this a head request for a page group - mark it as having an
> -        * extra reference so sub groups can follow suit */
> +        * extra reference so sub groups can follow suit.
> +        * This flag also informs pgio layer when to bump nrequests when
> +        * adding subrequests. */
>         WARN_ON(test_and_set_bit(PG_INODE_REF, &req->wb_flags));
>         kref_get(&req->wb_kref);
>         spin_unlock(&inode->i_lock);
> @@ -714,7 +717,11 @@ static void nfs_inode_remove_request(struct nfs_page *req)
>                         wake_up_page(head->wb_page, PG_private);
>                         clear_bit(PG_MAPPED, &head->wb_flags);
>                 }
> -               nfsi->npages--;
> +               nfsi->nrequests--;
> +               spin_unlock(&inode->i_lock);
> +       } else {
> +               spin_lock(&inode->i_lock);
> +               nfsi->nrequests--;
>                 spin_unlock(&inode->i_lock);
>         }
>
> @@ -1750,7 +1757,7 @@ static int nfs_commit_unstable_pages(struct inode *inode, struct writeback_contr
>                 /* Don't commit yet if this is a non-blocking flush and there
>                  * are a lot of outstanding writes for this mapping.
>                  */
> -               if (nfsi->commit_info.ncommit <= (nfsi->npages >> 1))
> +               if (nfsi->commit_info.ncommit <= (nfsi->nrequests >> 1))
>                         goto out_mark_dirty;
>
>                 /* don't wait for the COMMIT response */
> diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
> index c72d1ad41ad4..6d627b92df53 100644
> --- a/include/linux/nfs_fs.h
> +++ b/include/linux/nfs_fs.h
> @@ -163,7 +163,7 @@ struct nfs_inode {
>          */
>         __be32                  cookieverf[2];
>
> -       unsigned long           npages;
> +       unsigned long           nrequests;
>         struct nfs_mds_commit_info commit_info;
>
>         /* Open contexts for shared mmap writes */
> @@ -520,7 +520,7 @@ extern void nfs_commit_free(struct nfs_commit_data *data);
>  static inline int
>  nfs_have_writebacks(struct inode *inode)
>  {
> -       return NFS_I(inode)->npages != 0;
> +       return NFS_I(inode)->nrequests != 0;
>  }
>
>  /*
> --
> 1.9.3 (Apple Git-50)
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
