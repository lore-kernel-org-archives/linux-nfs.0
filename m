Received: from fhigh-a5-smtp.messagingengine.com (fhigh-a5-smtp.messagingengine.com [103.168.172.156])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4313E3905EB;
	Thu, 20 Aug 2026 20:37:46 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.156
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787258268; cv=none; b=EpFo148rjsXpUKNRwTENmTPp72629sPgHxwvnIF8pbdlwxPrE7+vfbIMu/6pN2Ror91P/DK1mIXH0h21fTa1S9+GPEI2ZKP50reoUOnVWU5qs6zk0v43A8dDxV4FFNGWz/vfT3Sded6s+hvDijPHjDw+u/ycva2Vg0jP1ux+Vtw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787258268; c=relaxed/simple;
	bh=WdhUDV6hRQ1uGWJhV+dTJQtMWlxnY9p/U3HBYCxI6JQ=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=f8wK6G/vnIfeqMlAkXGCeUy8STR+UmmFn+wE/EAHGOrMe9i+EN9zfKZ0VG6aA2yr4l41fHZAUh9uQfBWQIP9Lm4ARHVp+3cmMtheKvJVMkzETU+fd8x9mJJ6bcDRi14/1I2NluFpuuL+ayfntD4cXAihlk2bCjZZ8WbgzhHFnfM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=bsbernd.com; spf=pass smtp.mailfrom=bsbernd.com; dkim=pass (2048-bit key) header.d=bsbernd.com header.i=@bsbernd.com header.b=NjudmpvQ; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=AhDnyHQP; arc=none smtp.client-ip=103.168.172.156
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=bsbernd.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=bsbernd.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=bsbernd.com header.i=@bsbernd.com header.b="NjudmpvQ";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="AhDnyHQP"
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailfhigh.phl.internal (Postfix) with ESMTP id 5AA1B14001A6;
	Thu, 20 Aug 2026 16:37:45 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-02.internal (MEProxy); Thu, 20 Aug 2026 16:37:45 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=bsbernd.com; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:subject:subject:to:to; s=fm2; t=1787258265;
	 x=1787344665; bh=6ucE+PuyD7hhDcJC9cnrveUi9RM10V2fUaIkxFbOn2s=; b=
	NjudmpvQylhyKYeYYmq6rJ7HABJFpvMbHedU2kh7K6DH+E5Wxuivg0H4yaT4P4NO
	kbo60xoea6v/A4BWjEhTErGw5QsWjX1sKqzAi9rSXprO4egiFQXL0IhIiHVR2STN
	mHGabMSWPp5IiEBJBWlnTmsQb6D3b+osKOvv2EBO7fhduGhazJX3FMEjniF/Kwt1
	UhIzTwqIRs9XBa9MazgWTpTxLiHtSfbtetmcwZ3RblbB9URInladeNBQ19SLxuPw
	Pz5hY0GfbyR+Lg40YHZMyT68BRJAbFfZQbrcPqgv+Cn/8tZ0kA6IBGGREBFhNSp7
	pg8e0sbNKWm6XWXf6X5Qgg==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm3; t=1787258265; x=
	1787344665; bh=6ucE+PuyD7hhDcJC9cnrveUi9RM10V2fUaIkxFbOn2s=; b=A
	hDnyHQP7VHFPMA6XkyQPPV+kxTuR63ACHUjsmyhgvH51uG+s2wH6nlUWZqrs6jvJ
	n5e6KMtadbw1BDevf9v8RjsyZXkuWlY2sigO5V0u//GGzEVmhFNddXq8JT3UNYfK
	t4u3l6ZzczbkXNW9udFW8J6IL3V3bd0VStzbU34XfA08OR+rclYBzttiRtM65mFK
	yw0cDD6skyjMmiRPv11aRWLl8CrZaVEaFdcCwvi/JAmR/Z9VRmH/kEwRHzKPrrn6
	rPGQyEBOaHps2JPgWOeLtHh93/x9Mn05WhIvMhaL02rf+seT1bMc3FwP2BqrNetI
	LOV2uEwEDCIaSGNArX0eg==
X-ME-Sender: <xms:l2WHanjw8UUSF-Hu9_ZW1tGRppoDHopFOAh_P3kMKAq6OEAQkImCeg>
    <xme:l2WHaiYdIjhPobaFh-W1_Q8ySjBmVZwmmzfQWAglglqmJFkkpGHcDPYAmET31Sdog
    KGJixJgR1kjCgGexWWnYjPexL3yM4ggJ8hmiL0UtSxsUN99LMdA>
X-ME-Received: <xmr:l2WHajFGKtsUDMPSEl1LMLMSwi8PnqkbWBl1eZitWS95vUmaxgTeAJ3MOSog9mgS0LWzVrENxO5ew4dzZIhFBYZOHq_VQGM-fpY2e-e30wdHPLE_RkU5sza33Q>
X-ME-Proxy-Cause: dmFkZTGHCMB3CGTM2Dwh8T0va7wncxs4WoVtY1MpbEKlWjdfXg+yWiMMKczX5wTbdMQFpW
    0ivrAkLMc1Gy9qLL4MiAG4RZaZ+TP0xTORRCYVOZMrrRQYSWD9kxoqy/BlIfNeKxR7Znzr
    h7HVMgFAz1lK+rTviqK6/+k2AfwXfxtFTIO2UHB7eZh0lzGsja0vb51ozmpUclzE3uezRD
    O4Fgyv2mXC0WaCT4M5kEGmc3gzCWB2Csic43ezC8XPNnQ2nUzHlPDv2aO8abJa33IjSuOU
    2uLUtu1tZMKYB/bL1YysHMEnw7Afccy+cP57ip8RoYSJi+nFnKs8qIE4cbhufgG9thy4fT
    w7f9qKyaZoBrVvtMVTO140ABivXiqNzzoRlqL726mRbzNUqJt1Vv20qzGDX3Spgr15oj95
    Ru+v8YQPrjiDiEevr9SLrWEWjtZluRp99GauM4sCfZdFTzO/d6pisCzRwKNmRt+7qJEG0U
    E+ubpwhYqBbZUgHmj9UKGiDCJrmqMxxX+pFuBOYCCKew4bJWNfJE07gutvf23p0pirIMPW
    nzFWD8FJkJwlU6Zmd7faQrApJeQr8ae8BpHVPYZV7WeowV3y+ivZ7Os1fS3jAr3a8aSwtE
    uGx43wID7Vf5alpRgI7PK+PCPgPZVmX6/6bIkz6kyCsqVNFCRiBAhsL1sWpg
X-ME-Proxy: <xmx:l2WHanZ_lz--3EQm87NGpIZZFX1EvBA2OF2WO1qCpTbmtlLKpbruOg>
    <xmx:l2WHas1qlw55cOfr13Mt_g2CaOxD3kxfBOJAz8_deh4qIYaZHtgUlw>
    <xmx:l2WHandbd0UltRmcNb7mGjIpyxyeNALZ1dWI2cMVdCJ_4ED8wjwicQ>
    <xmx:l2WHamDpbNIjLSoN-dQKAW7kmf-bbpEX263X3kd9-aAR-C3A8kAl1w>
    <xmx:mWWHaqAuBK6e5QVhbVrcAaIIi0Qvbclqy9FMbC9JrQnjloXk5iRuyviI>
Feedback-ID: i5c2e48a5:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Thu,
 20 Aug 2026 16:37:38 -0400 (EDT)
Message-ID: <075218ce-0c30-4f3a-b01d-6eb99094b7e8@bsbernd.com>
Date: Thu, 20 Aug 2026 22:37:35 +0200
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH 2/7] fuse: Use filemap_invalidate_pages()
To: "Matthew Wilcox (Oracle)" <willy@infradead.org>,
 Christian Brauner <brauner@kernel.org>
Cc: Jan Kara <jack@suse.cz>, Chris Mason <clm@fb.com>,
 David Sterba <dsterba@suse.com>, Miklos Szeredi <miklos@szeredi.hu>,
 Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>,
 Mike Marshall <hubcap@omnibond.com>, Martin Brandenburg
 <martin@omnibond.com>, Alexander Viro <viro@zeniv.linux.org.uk>,
 linux-fsdevel@vger.kernel.org, linux-mm@kvack.org,
 linux-block@vger.kernel.org, linux-btrfs@vger.kernel.org,
 fuse-devel@lists.linux.dev, linux-nfs@vger.kernel.org,
 devel@lists.orangefs.org, Pavel Begunkov <asml.silence@gmail.com>
References: <20260820193343.3852967-1-willy@infradead.org>
 <20260820193343.3852967-3-willy@infradead.org>
From: Bernd Schubert <bernd@bsbernd.com>
Content-Language: fr, en-US, de-DE, ru-RU
In-Reply-To: <20260820193343.3852967-3-willy@infradead.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit



On 8/20/26 21:33, Matthew Wilcox (Oracle) wrote:
> FUSE relies on invalidate_inode_pages2() / invalidate_inode_pages2_range()
> doing writeback by calling fuse_launder_folio().  While this works, it
> is inefficient as each page is written back and waited for individually.
> Far better to call filemap_invalidate_pages() which will do a bulk write
> first, then remove the page cache.
> 
> With this done, fuse_launder_folio() no longer needs to exist so
> delete it.
> 
> Signed-off-by: Matthew Wilcox (Oracle) <willy@infradead.org>
> ---
>  fs/fuse/dax.c   | 15 +++------------
>  fs/fuse/dir.c   | 12 +++++++-----
>  fs/fuse/file.c  | 46 ++++++----------------------------------------
>  fs/fuse/inode.c | 17 +++++------------
>  4 files changed, 21 insertions(+), 69 deletions(-)
> 
> diff --git a/fs/fuse/dax.c b/fs/fuse/dax.c
> index 8b53625ac7ab..45843975e28b 100644
> --- a/fs/fuse/dax.c
> +++ b/fs/fuse/dax.c
> @@ -835,19 +835,10 @@ static int dmap_writeback_invalidate(struct inode *inode,
>  	loff_t start_pos = dmap->itn.start << FUSE_DAX_SHIFT;
>  	loff_t end_pos = (start_pos + FUSE_DAX_SZ - 1);
>  
> -	ret = filemap_fdatawrite_range(inode->i_mapping, start_pos, end_pos);
> -	if (ret) {
> -		pr_debug("fuse: filemap_fdatawrite_range() failed. err=%d start_pos=0x%llx, end_pos=0x%llx\n",
> -			 ret, start_pos, end_pos);
> -		return ret;
> -	}
> -
> -	ret = invalidate_inode_pages2_range(inode->i_mapping,
> -					    start_pos >> PAGE_SHIFT,
> -					    end_pos >> PAGE_SHIFT);
> +	ret = filemap_invalidate_pages(inode->i_mapping, start_pos, end_pos);
>  	if (ret)
> -		pr_debug("fuse: invalidate_inode_pages2_range() failed err=%d\n",
> -			 ret);
> +		pr_debug("fuse: filemap_invalidate_pages() failed. err=%d start_pos=0x%llx, end_pos=0x%llx\n",
> +			 ret, start_pos, end_pos);
>  
>  	return ret;
>  }
> diff --git a/fs/fuse/dir.c b/fs/fuse/dir.c
> index 0e2a1039fa43..c6c72c0ee669 100644
> --- a/fs/fuse/dir.c
> +++ b/fs/fuse/dir.c
> @@ -913,7 +913,8 @@ static int fuse_create_open(struct mnt_idmap *idmap, struct inode *dir,
>  		if (fm->fc->atomic_o_trunc && trunc)
>  			truncate_pagecache(inode, 0);
>  		else if (!(ff->open_flags & FOPEN_KEEP_CACHE))
> -			invalidate_inode_pages2(inode->i_mapping);
> +			filemap_invalidate_pages(inode->i_mapping, 0,
> +					OFFSET_MAX);
>  	}
>  	return err;
>  
> @@ -1904,7 +1905,8 @@ static int fuse_dir_open(struct inode *inode, struct file *file)
>  		if (ff->open_flags & (FOPEN_STREAM | FOPEN_NONSEEKABLE))
>  			nonseekable_open(inode, file);
>  		if (!(ff->open_flags & FOPEN_KEEP_CACHE))
> -			invalidate_inode_pages2(inode->i_mapping);
> +			filemap_invalidate_pages(inode->i_mapping, 0,
> +					OFFSET_MAX);
>  	}
>  
>  	return err;
> @@ -2277,13 +2279,13 @@ int fuse_do_setattr(struct mnt_idmap *idmap, struct dentry *dentry,
>  	spin_unlock(&fi->lock);
>  
>  	/*
> -	 * Only call invalidate_inode_pages2() after removing
> -	 * FUSE_NOWRITE, otherwise fuse_launder_folio() would deadlock.
> +	 * Only call filemap_invalidate_pages() after removing
> +	 * FUSE_NOWRITE, otherwise it would deadlock.
>  	 */
>  	if ((is_truncate || !is_wb) &&
>  	    S_ISREG(inode->i_mode) && oldsize != outarg.attr.size) {
>  		truncate_pagecache(inode, outarg.attr.size);
> -		invalidate_inode_pages2(mapping);
> +		filemap_invalidate_pages(mapping, 0, OFFSET_MAX);
>  	}
>  
>  	clear_bit(FUSE_I_SIZE_UNSTABLE, &fi->state);
> diff --git a/fs/fuse/file.c b/fs/fuse/file.c
> index ceada75310b8..2496161f9298 100644
> --- a/fs/fuse/file.c
> +++ b/fs/fuse/file.c
> @@ -294,7 +294,8 @@ static int fuse_open(struct inode *inode, struct file *file)
>  		if (is_truncate)
>  			truncate_pagecache(inode, 0);
>  		else if (!(ff->open_flags & FOPEN_KEEP_CACHE))
> -			invalidate_inode_pages2(inode->i_mapping);
> +			filemap_invalidate_pages(inode->i_mapping, 0,
> +					OFFSET_MAX);
>  	}
>  	if (dax_truncate)
>  		filemap_invalidate_unlock(inode->i_mapping);
> @@ -644,10 +645,8 @@ static void fuse_aio_invalidate_worker(struct work_struct *work)
>  	struct fuse_io_priv *io = container_of(work, struct fuse_io_priv, work);
>  	struct address_space *mapping = io->iocb->ki_filp->f_mapping;
>  	ssize_t res = fuse_get_res_by_io(io);
> -	pgoff_t start = io->offset >> PAGE_SHIFT;
> -	pgoff_t end = (io->offset + res - 1) >> PAGE_SHIFT;
>  
> -	invalidate_inode_pages2_range(mapping, start, end);
> +	filemap_invalidate_pages(mapping, io->offset, io->offset + res - 1);
>  	io->iocb->ki_complete(io->iocb, res);
>  	kref_put(&io->refcnt, fuse_io_release);
>  }
> @@ -1675,8 +1674,6 @@ ssize_t fuse_direct_io(struct fuse_io_priv *io, struct iov_iter *iter,
>  	size_t nmax = write ? fc->max_write : fc->max_read;
>  	loff_t pos = *ppos;
>  	size_t count = iov_iter_count(iter);
> -	pgoff_t idx_from = pos >> PAGE_SHIFT;
> -	pgoff_t idx_to = (pos + count - 1) >> PAGE_SHIFT;
>  	ssize_t res = 0;
>  	int err = 0;
>  	struct fuse_io_args *ia;
> @@ -1689,7 +1686,7 @@ ssize_t fuse_direct_io(struct fuse_io_priv *io, struct iov_iter *iter,
>  		return -ENOMEM;
>  
>  	if (fopen_direct_io) {
> -		res = filemap_write_and_wait_range(mapping, pos, pos + count - 1);
> +		res = filemap_invalidate_pages(mapping, pos, pos + count - 1);
>  		if (res) {
>  			fuse_io_free(ia);
>  			return res;
> @@ -1703,14 +1700,6 @@ ssize_t fuse_direct_io(struct fuse_io_priv *io, struct iov_iter *iter,
>  			inode_unlock(inode);
>  	}
>  
> -	if (fopen_direct_io && write) {
> -		res = invalidate_inode_pages2_range(mapping, idx_from, idx_to);
> -		if (res) {
> -			fuse_io_free(ia);
> -			return res;
> -		}
> -	}
> -
>  	io->should_dirty = !write && user_backed_iter(iter);
>  	while (count) {
>  		ssize_t nres;
> @@ -1824,9 +1813,7 @@ static ssize_t fuse_direct_write_iter(struct kiocb *iocb, struct iov_iter *from)
>  			 * write, to invalidate read-ahead cache that may have
>  			 * with the write.
>  			 */
> -			invalidate_inode_pages2_range(mapping,
> -				pos >> PAGE_SHIFT,
> -				(pos + res - 1) >> PAGE_SHIFT);
> +			filemap_invalidate_pages(mapping, pos, pos + res - 1);
>  		}
>  	}
>  	fuse_dio_unlock(iocb, exclusive);
> @@ -2324,26 +2311,6 @@ static int fuse_writepages(struct address_space *mapping,
>  	return iomap_writepages(&wpc);
>  }
>  
> -static int fuse_launder_folio(struct folio *folio)
> -{
> -	int err = 0;
> -	struct fuse_fill_wb_data data = {};
> -	struct iomap_writepage_ctx wpc = {
> -		.inode = folio->mapping->host,
> -		.iomap.type = IOMAP_MAPPED,
> -		.ops = &fuse_writeback_ops,
> -		.wb_ctx	= &data,
> -	};
> -
> -	if (folio_clear_dirty_for_io(folio)) {
> -		err = iomap_writeback_folio(&wpc, folio);
> -		err = fuse_iomap_writeback_submit(&wpc, err);
> -		if (!err)
> -			folio_wait_writeback(folio);
> -	}
> -	return err;
> -}
> -
>  /*
>   * Write back dirty data/metadata now (there may not be any suitable
>   * open files later for data)
> @@ -2427,7 +2394,7 @@ static int fuse_file_mmap(struct file *file, struct vm_area_struct *vma)
>  		if ((vma->vm_flags & VM_MAYSHARE) && !fc->direct_io_allow_mmap)
>  			return -ENODEV;
>  
> -		invalidate_inode_pages2(file->f_mapping);
> +		filemap_invalidate_pages(file->f_mapping, 0, OFFSET_MAX);
>  
>  		if (!(vma->vm_flags & VM_MAYSHARE)) {
>  			/* MAP_PRIVATE */
> @@ -3102,7 +3069,6 @@ static const struct address_space_operations fuse_file_aops  = {
>  	.read_folio	= fuse_read_folio,
>  	.readahead	= fuse_readahead,
>  	.writepages	= fuse_writepages,
> -	.launder_folio	= fuse_launder_folio,
>  	.dirty_folio	= iomap_dirty_folio,
>  	.release_folio	= iomap_release_folio,
>  	.invalidate_folio = iomap_invalidate_folio,
> diff --git a/fs/fuse/inode.c b/fs/fuse/inode.c
> index d975073c6029..2c9a93a2173a 100644
> --- a/fs/fuse/inode.c
> +++ b/fs/fuse/inode.c
> @@ -382,7 +382,8 @@ static void fuse_change_attributes_i(struct inode *inode, struct fuse_attr *attr
>  		}
>  
>  		if (inval)
> -			invalidate_inode_pages2(inode->i_mapping);
> +			filemap_invalidate_pages(inode->i_mapping, 0,
> +					OFFSET_MAX);
>  	}
>  
>  	if (IS_ENABLED(CONFIG_FUSE_DAX))
> @@ -547,8 +548,6 @@ int fuse_reverse_inval_inode(struct fuse_conn *fc, u64 nodeid,
>  {
>  	struct fuse_inode *fi;
>  	struct inode *inode;
> -	pgoff_t pg_start;
> -	pgoff_t pg_end;
>  
>  	inode = fuse_ilookup(fc, nodeid, NULL);
>  	if (!inode)
> @@ -561,15 +560,9 @@ int fuse_reverse_inval_inode(struct fuse_conn *fc, u64 nodeid,
>  
>  	fuse_invalidate_attr(inode);
>  	forget_all_cached_acls(inode);
> -	if (offset >= 0) {
> -		pg_start = offset >> PAGE_SHIFT;
> -		if (len <= 0)
> -			pg_end = -1;
> -		else
> -			pg_end = (offset + len - 1) >> PAGE_SHIFT;
> -		invalidate_inode_pages2_range(inode->i_mapping,
> -					      pg_start, pg_end);
> -	}
> +	if (offset >= 0)
> +		filemap_invalidate_pages(inode->i_mapping, offset,
> +				offset + len - 1);
>  	iput(inode);
>  	return 0;
>  }

Please correct me if I'm wrong, but doesn't that changes behavior for
len <= 0? The logic to invalidate till the file end is lost, at least if
offset is != -1?  And incostent behavior for len < 1?
Note that the existing behavior is used by libfuse and heavily by some
fuse daemons.

Thanks,
Bernd



