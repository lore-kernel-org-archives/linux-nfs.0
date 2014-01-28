Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:26261 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754684AbaA1Nid (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Jan 2014 08:38:33 -0500
Date: Tue, 28 Jan 2014 08:38:29 -0500
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFS: fix the handling of NFS_INO_INVALID_DATA flag in
 nfs_revalidate_mapping
Message-ID: <20140128083829.00538279@tlielax.poochiereds.net>
In-Reply-To: <1390848375-17034-1-git-send-email-jlayton@redhat.com>
References: <1390848375-17034-1-git-send-email-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 27 Jan 2014 13:46:15 -0500
Jeff Layton <jlayton@redhat.com> wrote:

> There is a possible race in how the nfs_invalidate_mapping function is
> handled.  Currently, we go and invalidate the pages in the file and then
> clear NFS_INO_INVALID_DATA.
> 
> The problem is that it's possible for a stale page to creep into the
> mapping after the page was invalidated (i.e., via readahead). If another
> writer comes along and sets the flag after that happens but before
> invalidate_inode_pages2 returns then we could clear the flag
> without the cache having been properly invalidated.
> 
> So, we must clear the flag first and then invalidate the pages. Doing
> this however, opens another race:
> 
> It's possible to have two concurrent read() calls that end up in
> nfs_revalidate_mapping at the same time. The first one clears the
> NFS_INO_INVALID_DATA flag and then goes to call nfs_invalidate_mapping.
> 
> Just before calling that though, the other task races in, checks the
> flag and finds it cleared. At that point, it trusts that the mapping is
> good and gets the lock on the page, allowing the read() to be satisfied
> from the cache even though the data is no longer valid.
> 
> These effects are easily manifested by running diotest3 from the LTP
> test suite on NFS. That program does a series of DIO writes and buffered
> reads. The operations are serialized and page-aligned but the existing
> code fails the test since it occasionally allows a read to come out of
> the cache incorrectly. While mixing direct and buffered I/O isn't
> recommended, I believe it's possible to hit this in other ways that just
> use buffered I/O, though that situation is much harder to reproduce.
> 
> The problem is that the checking/clearing of that flag and the
> invalidation of the mapping really need to be atomic. Fix this by
> serializing concurrent invalidations with a bitlock.
> 
> At the same time, we also need to allow other places that check
> NFS_INO_INVALID_DATA to check whether we might be in the middle of
> invalidating the file, so fix up a couple of places that do that
> to look for the new NFS_INO_INVALIDATING flag.
> 
> Doing this requires us to be careful not to set the bitlock
> unnecessarily, so this code only does that if it believes it will
> be doing an invalidation.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  fs/nfs/dir.c           |  3 ++-
>  fs/nfs/inode.c         | 42 ++++++++++++++++++++++++++++++++++++++----
>  fs/nfs/nfstrace.h      |  1 +
>  fs/nfs/write.c         |  6 +++++-
>  include/linux/nfs_fs.h |  1 +
>  5 files changed, 47 insertions(+), 6 deletions(-)
> 
> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> index b266f73..b39a046 100644
> --- a/fs/nfs/dir.c
> +++ b/fs/nfs/dir.c
> @@ -288,7 +288,8 @@ int nfs_readdir_search_for_cookie(struct nfs_cache_array *array, nfs_readdir_des
>  
>  			new_pos = desc->current_index + i;
>  			if (ctx->attr_gencount != nfsi->attr_gencount
> -			    || (nfsi->cache_validity & (NFS_INO_INVALID_ATTR|NFS_INO_INVALID_DATA))) {
> +			    || (nfsi->cache_validity & (NFS_INO_INVALID_ATTR|NFS_INO_INVALID_DATA))
> +			    || test_bit(NFS_INO_INVALIDATING, &nfsi->flags)) {
>  				ctx->duped = 0;
>  				ctx->attr_gencount = nfsi->attr_gencount;
>  			} else if (new_pos < desc->ctx->pos) {
> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index c63e152..0a972ee 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -977,11 +977,11 @@ static int nfs_invalidate_mapping(struct inode *inode, struct address_space *map
>  		if (ret < 0)
>  			return ret;
>  	}
> -	spin_lock(&inode->i_lock);
> -	nfsi->cache_validity &= ~NFS_INO_INVALID_DATA;
> -	if (S_ISDIR(inode->i_mode))
> +	if (S_ISDIR(inode->i_mode)) {
> +		spin_lock(&inode->i_lock);
>  		memset(nfsi->cookieverf, 0, sizeof(nfsi->cookieverf));
> -	spin_unlock(&inode->i_lock);
> +		spin_unlock(&inode->i_lock);
> +	}
>  	nfs_inc_stats(inode, NFSIOS_DATAINVALIDATE);
>  	nfs_fscache_wait_on_invalidate(inode);
>  
> @@ -1008,6 +1008,7 @@ static bool nfs_mapping_need_revalidate_inode(struct inode *inode)
>  int nfs_revalidate_mapping(struct inode *inode, struct address_space *mapping)
>  {
>  	struct nfs_inode *nfsi = NFS_I(inode);
> +	unsigned long *bitlock = &nfsi->flags;
>  	int ret = 0;
>  
>  	/* swapfiles are not supposed to be shared. */
> @@ -1019,12 +1020,45 @@ int nfs_revalidate_mapping(struct inode *inode, struct address_space *mapping)
>  		if (ret < 0)
>  			goto out;
>  	}
> +
> +	/*
> +	 * We must clear NFS_INO_INVALID_DATA first to ensure that
> +	 * invalidations that come in while we're shooting down the mappings
> +	 * are respected. But, that leaves a race window where one revalidator
> +	 * can clear the flag, and then another checks it before the mapping
> +	 * gets invalidated. Fix that by serializing access to this part of
> +	 * the function.
> +	 *
> +	 * At the same time, we need to allow other tasks to see whether we
> +	 * might be in the middle of invalidating the pages, so we only set
> +	 * the bit lock here if it looks like we're going to be doing that.
> +	 */
> +	for (;;) {
> +		ret = wait_on_bit(bitlock, NFS_INO_INVALIDATING,
> +				  nfs_wait_bit_killable, TASK_KILLABLE);
> +		if (ret)
> +			goto out;
> +		if (!(nfsi->cache_validity & NFS_INO_INVALID_DATA))
> +			goto out;
> +		if (!test_and_set_bit_lock(NFS_INO_INVALIDATING, bitlock))
> +			break;
> +	}
> +

So, I should mention that while the testcase does pass with this
patchset, I think there are still races in here.

I think it's possible for two tasks to enter this code nearly
simultaneously such that the bitlock is clear. One gets the lock and
then clears NFS_INO_INVALID_DATA, and the other then checks the flag,
finds it clear and exits the function before the pages were invalidated.

I wonder if we'd be better served with a new cache_validity flag
NFS_INO_INVALIDATING_DATA or something, and not have other functions
trying to peek at the bitlock.

> +	spin_lock(&inode->i_lock);
>  	if (nfsi->cache_validity & NFS_INO_INVALID_DATA) {
> +		nfsi->cache_validity &= ~NFS_INO_INVALID_DATA;
> +		spin_unlock(&inode->i_lock);
>  		trace_nfs_invalidate_mapping_enter(inode);
>  		ret = nfs_invalidate_mapping(inode, mapping);
>  		trace_nfs_invalidate_mapping_exit(inode, ret);
> +	} else {
> +		/* something raced in and cleared the flag */
> +		spin_unlock(&inode->i_lock);
>  	}
>  
> +	clear_bit_unlock(NFS_INO_INVALIDATING, bitlock);
> +	smp_mb__after_clear_bit();
> +	wake_up_bit(bitlock, NFS_INO_INVALIDATING);
>  out:
>  	return ret;
>  }
> diff --git a/fs/nfs/nfstrace.h b/fs/nfs/nfstrace.h
> index 89fe741..59f838c 100644
> --- a/fs/nfs/nfstrace.h
> +++ b/fs/nfs/nfstrace.h
> @@ -36,6 +36,7 @@
>  	__print_flags(v, "|", \
>  			{ 1 << NFS_INO_ADVISE_RDPLUS, "ADVISE_RDPLUS" }, \
>  			{ 1 << NFS_INO_STALE, "STALE" }, \
> +			{ 1 << NFS_INO_INVALIDATING, "INVALIDATING" }, \
>  			{ 1 << NFS_INO_FLUSHING, "FLUSHING" }, \
>  			{ 1 << NFS_INO_FSCACHE, "FSCACHE" }, \
>  			{ 1 << NFS_INO_COMMIT, "COMMIT" }, \
> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> index a44a872..5511a42 100644
> --- a/fs/nfs/write.c
> +++ b/fs/nfs/write.c
> @@ -909,9 +909,13 @@ bool nfs_ctx_key_to_expire(struct nfs_open_context *ctx)
>   */
>  static bool nfs_write_pageuptodate(struct page *page, struct inode *inode)
>  {
> +	struct nfs_inode *nfsi = NFS_I(inode);
> +
>  	if (nfs_have_delegated_attributes(inode))
>  		goto out;
> -	if (NFS_I(inode)->cache_validity & (NFS_INO_INVALID_DATA|NFS_INO_REVAL_PAGECACHE))
> +	if (nfsi->cache_validity & (NFS_INO_INVALID_DATA|NFS_INO_REVAL_PAGECACHE))
> +		return false;
> +	if (test_bit(NFS_INO_INVALIDATING, &nfsi->flags))
>  		return false;
>  out:
>  	return PageUptodate(page) != 0;
> diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
> index 4899737..18fb16f 100644
> --- a/include/linux/nfs_fs.h
> +++ b/include/linux/nfs_fs.h
> @@ -215,6 +215,7 @@ struct nfs_inode {
>  #define NFS_INO_ADVISE_RDPLUS	(0)		/* advise readdirplus */
>  #define NFS_INO_STALE		(1)		/* possible stale inode */
>  #define NFS_INO_ACL_LRU_SET	(2)		/* Inode is on the LRU list */
> +#define NFS_INO_INVALIDATING	(3)		/* inode is being invalidated */
>  #define NFS_INO_FLUSHING	(4)		/* inode is flushing out data */
>  #define NFS_INO_FSCACHE		(5)		/* inode can be cached by FS-Cache */
>  #define NFS_INO_FSCACHE_LOCK	(6)		/* FS-Cache cookie management lock */


-- 
Jeff Layton <jlayton@redhat.com>
