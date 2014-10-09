Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f175.google.com ([209.85.216.175]:36898 "EHLO
	mail-qc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750875AbaJICLb convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Oct 2014 22:11:31 -0400
Received: by mail-qc0-f175.google.com with SMTP id x13so276586qcv.6
        for <linux-nfs@vger.kernel.org>; Wed, 08 Oct 2014 19:11:30 -0700 (PDT)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [PATCH] NFSv4.1/pnfs: replace broken pnfs_put_lseg_async
From: Weston Andros Adamson <dros@primarydata.com>
In-Reply-To: <1412801200-17936-1-git-send-email-trond.myklebust@primarydata.com>
Date: Wed, 8 Oct 2014 22:11:28 -0400
Cc: linux-nfs list <linux-nfs@vger.kernel.org>
Message-Id: <875DA1C9-2FD0-4176-9C63-7306CE4D2B53@primarydata.com>
References: <1412801200-17936-1-git-send-email-trond.myklebust@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Oct 8, 2014, at 4:46 PM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:

> You cannot call pnfs_put_lseg_async() more than once per lseg, so it
> is really an inappropriate way to deal with a refcount issue.

You’re absolutely right!

> Instead, replace it with a function that decrements the refcount, and
> puts the final 'free' operation (which is incompatible with locks) on
> the work queue.

Thanks, this looks like the right solution.

The good news is that nobody should have been hitting this, as the only file layout
server (that I know of) does stable writes, thus doesn’t use the commit path.

-dros

> 
> Cc: Weston Andros Adamson <dros@primarydata.com>
> Fixes: e6cf82d1830f: pnfs: add pnfs_put_lseg_async
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
> fs/nfs/filelayout/filelayout.c |  2 +-
> fs/nfs/pnfs.c                  | 33 +++++++++++++++++++++++++++------
> fs/nfs/pnfs.h                  |  6 +-----
> 3 files changed, 29 insertions(+), 12 deletions(-)
> 
> diff --git a/fs/nfs/filelayout/filelayout.c b/fs/nfs/filelayout/filelayout.c
> index abc5056999d6..46fab1cb455a 100644
> --- a/fs/nfs/filelayout/filelayout.c
> +++ b/fs/nfs/filelayout/filelayout.c
> @@ -1031,7 +1031,7 @@ filelayout_clear_request_commit(struct nfs_page *req,
> 	}
> out:
> 	nfs_request_remove_commit_list(req, cinfo);
> -	pnfs_put_lseg_async(freeme);
> +	pnfs_put_lseg_locked(freeme);
> }
> 
> static void
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index 76de7f568119..0a5dda4d85c2 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -361,22 +361,43 @@ pnfs_put_lseg(struct pnfs_layout_segment *lseg)
> }
> EXPORT_SYMBOL_GPL(pnfs_put_lseg);
> 
> -static void pnfs_put_lseg_async_work(struct work_struct *work)
> +static void pnfs_free_lseg_async_work(struct work_struct *work)
> {
> 	struct pnfs_layout_segment *lseg;
> +	struct pnfs_layout_hdr *lo;
> 
> 	lseg = container_of(work, struct pnfs_layout_segment, pls_work);
> +	lo = lseg->pls_layout;
> 
> -	pnfs_put_lseg(lseg);
> +	pnfs_free_lseg(lseg);
> +	pnfs_put_layout_hdr(lo);
> }
> 
> -void
> -pnfs_put_lseg_async(struct pnfs_layout_segment *lseg)
> +static void pnfs_free_lseg_async(struct pnfs_layout_segment *lseg)
> {
> -	INIT_WORK(&lseg->pls_work, pnfs_put_lseg_async_work);
> +	INIT_WORK(&lseg->pls_work, pnfs_free_lseg_async_work);
> 	schedule_work(&lseg->pls_work);
> }
> -EXPORT_SYMBOL_GPL(pnfs_put_lseg_async);
> +
> +void
> +pnfs_put_lseg_locked(struct pnfs_layout_segment *lseg)
> +{
> +	if (!lseg)
> +		return;
> +
> +	assert_spin_locked(&lseg->pls_layout->plh_inode->i_lock);
> +
> +	dprintk("%s: lseg %p ref %d valid %d\n", __func__, lseg,
> +		atomic_read(&lseg->pls_refcount),
> +		test_bit(NFS_LSEG_VALID, &lseg->pls_flags));
> +	if (atomic_dec_and_test(&lseg->pls_refcount)) {
> +		struct pnfs_layout_hdr *lo = lseg->pls_layout;
> +		pnfs_get_layout_hdr(lo);
> +		pnfs_layout_remove_lseg(lo, lseg);
> +		pnfs_free_lseg_async(lseg);
> +	}
> +}
> +EXPORT_SYMBOL_GPL(pnfs_put_lseg_locked);
> 
> static u64
> end_offset(u64 start, u64 len)
> diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
> index 509a710148ba..9ae5b765b073 100644
> --- a/fs/nfs/pnfs.h
> +++ b/fs/nfs/pnfs.h
> @@ -190,7 +190,7 @@ extern int nfs4_proc_layoutreturn(struct nfs4_layoutreturn *lrp);
> /* pnfs.c */
> void pnfs_get_layout_hdr(struct pnfs_layout_hdr *lo);
> void pnfs_put_lseg(struct pnfs_layout_segment *lseg);
> -void pnfs_put_lseg_async(struct pnfs_layout_segment *lseg);
> +void pnfs_put_lseg_locked(struct pnfs_layout_segment *lseg);
> 
> void set_pnfs_layoutdriver(struct nfs_server *, const struct nfs_fh *, u32);
> void unset_pnfs_layoutdriver(struct nfs_server *);
> @@ -445,10 +445,6 @@ static inline void pnfs_put_lseg(struct pnfs_layout_segment *lseg)
> {
> }
> 
> -static inline void pnfs_put_lseg_async(struct pnfs_layout_segment *lseg)
> -{
> -}
> -
> static inline int pnfs_return_layout(struct inode *ino)
> {
> 	return 0;
> -- 
> 1.9.3
> 

