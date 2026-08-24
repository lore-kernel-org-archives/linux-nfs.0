Received: from fhigh-a1-smtp.messagingengine.com (fhigh-a1-smtp.messagingengine.com [103.168.172.152])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CE2ED25A640;
	Mon, 24 Aug 2026 21:57:42 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.152
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787608664; cv=none; b=ad9OknWI4yOOR0CO7EnNdHIV4FRMbQBEO2HJCRxMgemBi0eW4Uoenk9BcLBeh44pYUtA/60J6KW8RteHFN8Xs2libiGxX+KMNzjXL20jCXapFpBm/IHG3QZbZJkSEhZa684HVn/AFdJ2c+iyJVtvyXo86uyqj/NugBUo7M+gVo0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787608664; c=relaxed/simple;
	bh=obWNPYJ7d66NWekxzUnb4y6BJax3a7wT1M2tWe2UTzQ=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=nCe/Ju6B98zPrq2Ogitk++ZjqcZmyJ45eIDx3gOX3M+jr6fDtQxAhvEyOk1G5fHUAzXz+MHmScl9dn15gYRNzm2n8vq/8cryTThp4IjBCWjUAfy3OrRjQDzuuIY88IryJmwKTADu6KV1+sEMTPKPKfJPrbNKi7EeADe4kT88QBo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=bur.io; spf=pass smtp.mailfrom=bur.io; dkim=pass (2048-bit key) header.d=bur.io header.i=@bur.io header.b=FNWWEQmz; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=lBGAw/I3; arc=none smtp.client-ip=103.168.172.152
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=bur.io
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=bur.io
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=bur.io header.i=@bur.io header.b="FNWWEQmz";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="lBGAw/I3"
Received: from phl-compute-04.internal (phl-compute-04.internal [10.202.2.44])
	by mailfhigh.phl.internal (Postfix) with ESMTP id EC0D11400077;
	Mon, 24 Aug 2026 17:57:41 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-04.internal (MEProxy); Mon, 24 Aug 2026 17:57:41 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=bur.io; h=cc:cc
	:content-type:content-type:date:date:from:from:in-reply-to
	:in-reply-to:message-id:mime-version:references:reply-to:subject
	:subject:to:to; s=fm1; t=1787608661; x=1787695061; bh=br0ZJAK4IX
	Iy8kwo/WXMM3d+veAzs8uRALVZi5vGptg=; b=FNWWEQmzEd1qyyWvePwgFcmcRh
	SdTDISybhfuzBDdmuAewb/cNV6JpywabKgINVGDt/mXC5iKLkoixZCqYTKSelNPv
	ID0CdT8x+xKk2a7u/Qz7eYSUC1zDP0YEjo9ovUSxa6Agb02107/i6t1pghkfTNo4
	S/aayMIdKpP+GmjCY2zjGCmLuzD+6jveuz9D6APJkZD7WgiXR6P1/8AEptFFgA4H
	6a4SUGB/lto+DQ4FZIn9jnXlxjpTtB+M/WYty/5vF23TL13CwGLIl6z3r+4pEq/h
	OO+CHgFFDFZlJhV1Y7ketuL1Mn3uDE5XqvQMVf7MH0ySgg/VH1g2AFw4lA0Q==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-type:content-type:date:date
	:feedback-id:feedback-id:from:from:in-reply-to:in-reply-to
	:message-id:mime-version:references:reply-to:subject:subject:to
	:to:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm3; t=
	1787608661; x=1787695061; bh=br0ZJAK4IXIy8kwo/WXMM3d+veAzs8uRALV
	Zi5vGptg=; b=lBGAw/I3t+Yi/Sa+CxZeHVLqcCILr01czD893qqjA/TQO2J4IIw
	gVRcqlfrl7adfTsSSDhyCO1z0e6UeRN8DBRx61Bt54/oL19d+wlImKQCzHpG4ebk
	bs2Hmwj3sjRVqC9i7JAMUtLpo5YDTmgvAg7Ty2DsT4SRlFRbtaV103OTSxps17F4
	1/jZhb8e1zOXuhkm3TfZkLF5t/I8ewYwJD/yl7H3N4GHyqrQ6dWrxKOMepJxtd+V
	iybomIDebQNbzDC8OYaoWtRaYf1STThFACe8GhfTsQrzhikbbeL7a8LKW+imudS9
	1lCaPnsW07m3pFu7NBbxZJe0TMVX0uW7yoQ==
X-ME-Sender: <xms:Vb6MalmfLtI5O3lhLKcjJBpP5ZQHMiyr9OdA7Tdj-KidFuypOQRBHg>
    <xme:Vb6MavO4gshkSaUOWeUmZCS4bIluvEcak3ALc9fEdVyoCGcxqoGBGkioGd7UY8MBB
    xPHx9kYhixyxOi2jblgox_CKME1Et5-33PT8HD5r7R41bhxXSJznvFw>
X-ME-Received: <xmr:Vb6ManrKQoe3zrAuft29csb52t9_1qGksWDUCPA2Uu3l_9rUI71v-dX0KmNRWFZRuvRlFSgmJqxOJbRQXzfh5Rl4OmY>
X-ME-Proxy-Cause: dmFkZTGqEyykA1sOnyeBdFBZbfPmYjAPXliUF3xVtonO1PONGbI/HUGTKz6CIcPE+ajJlB
    NRtYDck65qi3MRs/v8pzQmypGRsZnzqLrTPndbJdH0iMs1/XferK9Goja2IhbuucbvTeio
    8llUXcBogYs8jeock4al/vTTHwQMI8F20qW31IP7lUOqoxCtO1FlvbDi+N6vYBf0AtuHYC
    7T8hWs3larCSIVbNRk90Chci+p1tEbOw0kOHJBezbzGjy/LoOrwIv6fFy9Rt0gkFZYJr/+
    sVOYT9XIYiN/uRpl+moQAzWBuRCvhNb1BKtrEQ/nMKescxsUFQx3y6BtJY7woG1AyXyRY4
    WQrwGGkB4FAANePkMLJvqrgeghrxhIhk6yku5ckvUjzvWjULHY2tjiFr645hy4CRDoksui
    Ovyh6g9964Dx/QNTR67/D6ZfdRVVTCebqaSia7BlC/LYInTMZM6lVpuFZeU2JaJAovOMiJ
    eWvKOGHING1/fEtAQ3TZ44gRNp/N15HgZALUY6lVOcfoWxY7Yh4ZKUIAwNoL5cPX/yHNEI
    dZUIhEJHn4Idf1f+3nTmbYo9i+vVsCDQXL8o685j6dtPl7NtWPttejm8nImb+s4SsM5twl
    Y1L8+7Vfud+fozVFi4u8vSHoxFtG6LbO8WNNYIy2CY8fWyAEwN6FhC6esujA
X-ME-Proxy: <xmx:Vb6MaotoLc5Iylk5B3iqY4LVqkDX5waHOQx8_FVFV2BbPZ4X9WlamQ>
    <xmx:Vb6Mar6GMInl1Bg16G_pevTsi0NFwJQQShIEap_ntUGiPbZlqHwckQ>
    <xmx:Vb6MahTH7sc7AdPsKNDf2HLH7AIDMtgk9h5amFGI2sQf4kprdkaMpA>
    <xmx:Vb6MajnJsAQ4_iHX2Ra1JlfwYjgRLsPZJqYR60rbpMPkbBrOgbUeGw>
    <xmx:Vb6ManxzZpL2hhuKnDhTCvNtQwDsEsq-Do7OwmbG9vZbFUEUQzrwfIWi>
Feedback-ID: i083147f8:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Mon,
 24 Aug 2026 17:57:40 -0400 (EDT)
Date: Mon, 24 Aug 2026 14:57:13 -0700
From: Boris Burkov <boris@bur.io>
To: "Matthew Wilcox (Oracle)" <willy@infradead.org>
Cc: Christian Brauner <brauner@kernel.org>, Jan Kara <jack@suse.cz>,
	Chris Mason <clm@fb.com>, David Sterba <dsterba@suse.com>,
	Miklos Szeredi <miklos@szeredi.hu>,
	Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Mike Marshall <hubcap@omnibond.com>,
	Martin Brandenburg <martin@omnibond.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	linux-fsdevel@vger.kernel.org, linux-mm@kvack.org,
	linux-block@vger.kernel.org, linux-btrfs@vger.kernel.org,
	fuse-devel@lists.linux.dev, linux-nfs@vger.kernel.org,
	devel@lists.orangefs.org, Pavel Begunkov <asml.silence@gmail.com>
Subject: Re: [PATCH 3/7] btrfs: Use filemap_invalidate_pages()
Message-ID: <20260824215713.GB3664690@zen.localdomain>
References: <20260820193343.3852967-1-willy@infradead.org>
 <20260820193343.3852967-4-willy@infradead.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260820193343.3852967-4-willy@infradead.org>

On Thu, Aug 20, 2026 at 08:33:36PM +0100, Matthew Wilcox (Oracle) wrote:
> btrfs relies on invalidate_inode_pages2() /
> invalidate_inode_pages2_range() doing writeback by calling
> btrfs_launder_folio().  While this works, it is inefficient as each

I don't believe btrfs_launder_folio() is doing writeback, it is just
dropping otherwise leaked qgroup reservation. So this part of the
commit message feels inaccurate to me, at least.

> folio is written back and waited for individually.  Far better to call
> filemap_invalidate_pages() which will do a bulk write first, then remove
> the page cache.
> 
> With this done, btrfs_launder_folio() no longer needs to exist so
> delete it.
> 
> Signed-off-by: Matthew Wilcox (Oracle) <willy@infradead.org>
> ---
>  fs/btrfs/direct-io.c        |  2 +-
>  fs/btrfs/disk-io.c          | 11 +++++++----
>  fs/btrfs/free-space-cache.c |  4 ++--
>  fs/btrfs/inode.c            | 12 ++----------
>  fs/btrfs/volumes.c          |  4 ++--
>  5 files changed, 14 insertions(+), 19 deletions(-)
> 
> diff --git a/fs/btrfs/direct-io.c b/fs/btrfs/direct-io.c
> index 460326d34143..4bb5890d0898 100644
> --- a/fs/btrfs/direct-io.c
> +++ b/fs/btrfs/direct-io.c
> @@ -115,7 +115,7 @@ static int lock_extent_direct(struct inode *inode, u64 lockstart, u64 lockend,
>  			/*
>  			 * We could trigger writeback for this range (and wait
>  			 * for it to complete) and then invalidate the pages for
> -			 * this range (through invalidate_inode_pages2_range()),
> +			 * this range (through filemap_invalidate_pages()),
>  			 * but that can lead us to a deadlock with a concurrent
>  			 * call to readahead (a buffered read or a defrag call
>  			 * triggered a readahead) on a page lock due to an
> diff --git a/fs/btrfs/disk-io.c b/fs/btrfs/disk-io.c
> index 2f1666d9544e..2cf9189225c9 100644
> --- a/fs/btrfs/disk-io.c
> +++ b/fs/btrfs/disk-io.c
> @@ -3304,7 +3304,8 @@ static void invalidate_and_check_btree_folios(struct btrfs_fs_info *fs_info)
>  	struct extent_buffer *eb;
>  	int ret;
>  
> -	ret = invalidate_inode_pages2(fs_info->btree_inode->i_mapping);
> +	ret = filemap_invalidate_pages(fs_info->btree_inode->i_mapping, 0,
> +			OFFSET_MAX);
>  	if (likely(ret == 0))
>  		return;
>  
> @@ -3339,7 +3340,8 @@ static void invalidate_and_check_btree_folios(struct btrfs_fs_info *fs_info)
>  		rcu_read_lock();
>  	}
>  	rcu_read_unlock();
> -	invalidate_inode_pages2(fs_info->btree_inode->i_mapping);
> +	filemap_invalidate_pages(fs_info->btree_inode->i_mapping, 0,
> +			OFFSET_MAX);
>  }
>  
>  static u32 calc_block_max_order(u32 sectorsize_bits)
> @@ -4739,7 +4741,8 @@ static void btrfs_destroy_delalloc_inodes(struct btrfs_root *root)
>  			unsigned int nofs_flag;
>  
>  			nofs_flag = memalloc_nofs_save();
> -			invalidate_inode_pages2(inode->i_mapping);
> +			filemap_invalidate_pages(inode->i_mapping, 0,
> +					OFFSET_MAX);

I believe that this was the original motivating call to
invalidate_inode_pages2 that I cared about. The context it runs in is
when the filesystem has failed on a transaction and needs to invalidate
the remaining dirty pages that have delalloc associated with them.

I am trying to figure out if trying to force the writeback in this
semi-failed context will also result in freeing the reservation, and
also testing this patch series on the test that I originally fixed with
launder_folio().

With all that said, thank you for working on cleaning up the mess I made
by adding this "creative" usage of ->launder_folio(). Hopefully we can
figure this out cleanly.

Thanks,
Boris

>  			memalloc_nofs_restore(nofs_flag);
>  			iput(inode);
>  		}
> @@ -4837,7 +4840,7 @@ static void btrfs_cleanup_bg_io(struct btrfs_block_group *cache)
>  		unsigned int nofs_flag;
>  
>  		nofs_flag = memalloc_nofs_save();
> -		invalidate_inode_pages2(inode->i_mapping);
> +		filemap_invalidate_pages(inode->i_mapping, 0, OFFSET_MAX);
>  		memalloc_nofs_restore(nofs_flag);
>  
>  		BTRFS_I(inode)->generation = 0;
> diff --git a/fs/btrfs/free-space-cache.c b/fs/btrfs/free-space-cache.c
> index e2af75a205ea..a5d5eba2c85d 100644
> --- a/fs/btrfs/free-space-cache.c
> +++ b/fs/btrfs/free-space-cache.c
> @@ -1307,7 +1307,7 @@ static int __btrfs_wait_cache_io(struct btrfs_root *root,
>  				io_ctl->entries, io_ctl->bitmaps);
>  out:
>  	if (ret) {
> -		invalidate_inode_pages2(inode->i_mapping);
> +		filemap_invalidate_pages(inode->i_mapping, 0, OFFSET_MAX);
>  		BTRFS_I(inode)->generation = 0;
>  		if (block_group)
>  			btrfs_debug(root->fs_info,
> @@ -1500,7 +1500,7 @@ static int __btrfs_write_out_cache(struct inode *inode,
>  	io_ctl->inode = NULL;
>  	io_ctl_free(io_ctl);
>  	if (ret) {
> -		invalidate_inode_pages2(inode->i_mapping);
> +		filemap_invalidate_pages(inode->i_mapping, 0, OFFSET_MAX);
>  		BTRFS_I(inode)->generation = 0;
>  	}
>  	btrfs_update_inode(trans, BTRFS_I(inode));
> diff --git a/fs/btrfs/inode.c b/fs/btrfs/inode.c
> index 2534cd9284d5..a1bb73f083aa 100644
> --- a/fs/btrfs/inode.c
> +++ b/fs/btrfs/inode.c
> @@ -7616,12 +7616,6 @@ static void wait_subpage_spinlock(struct folio *folio)
>  	spin_unlock_irq(&bfs->lock);
>  }
>  
> -static int btrfs_launder_folio(struct folio *folio)
> -{
> -	return btrfs_qgroup_free_data(folio_to_inode(folio), NULL, folio_pos(folio),
> -				      folio_size(folio), NULL);
> -}
> -
>  static bool __btrfs_release_folio(struct folio *folio, gfp_t gfp_flags)
>  {
>  	if (try_release_extent_mapping(folio, gfp_flags)) {
> @@ -10027,9 +10021,8 @@ ssize_t btrfs_do_encoded_write(struct kiocb *iocb, struct iov_iter *from,
>  		ret = btrfs_wait_ordered_range(inode, start, num_bytes);
>  		if (ret)
>  			goto out_cb;
> -		ret = invalidate_inode_pages2_range(inode->vfs_inode.i_mapping,
> -						    start >> PAGE_SHIFT,
> -						    end >> PAGE_SHIFT);
> +		ret = filemap_invalidate_pages(inode->vfs_inode.i_mapping,
> +				start, end);
>  		if (ret)
>  			goto out_cb;
>  		btrfs_lock_extent(io_tree, start, end, &cached_state);
> @@ -10782,7 +10775,6 @@ static const struct address_space_operations btrfs_aops = {
>  	.writepages	= btrfs_writepages,
>  	.readahead	= btrfs_readahead,
>  	.invalidate_folio = btrfs_invalidate_folio,
> -	.launder_folio	= btrfs_launder_folio,
>  	.release_folio	= btrfs_release_folio,
>  	.migrate_folio	= btrfs_migrate_folio,
>  	.dirty_folio	= btrfs_data_dirty_folio,
> diff --git a/fs/btrfs/volumes.c b/fs/btrfs/volumes.c
> index 6eab4cc73ce4..0301465ab87f 100644
> --- a/fs/btrfs/volumes.c
> +++ b/fs/btrfs/volumes.c
> @@ -1370,8 +1370,8 @@ struct btrfs_super_block *btrfs_read_disk_super(struct block_device *bdev,
>  		 * Drop the page of the primary superblock, so later read will
>  		 * always read from the device.
>  		 */
> -		invalidate_inode_pages2_range(mapping, bytenr >> PAGE_SHIFT,
> -				      (bytenr + BTRFS_SUPER_INFO_SIZE) >> PAGE_SHIFT);
> +		filemap_invalidate_pages(mapping, bytenr,
> +				bytenr + BTRFS_SUPER_INFO_SIZE - 1);
>  	}
>  
>  	filemap_invalidate_lock_shared(mapping);
> -- 
> 2.47.3
> 
