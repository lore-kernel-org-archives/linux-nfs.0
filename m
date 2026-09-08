Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 87B0B585967;
	Tue,  8 Sep 2026 16:36:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788885420; cv=none; b=S8w/WDFFE8AOQCgZYFYN6wlGmbYEKYfPbaenGYu7I6wYv4hoWSIoeDBTBjHBS7G9jz01GFaPi5rCldBZ0b/xd5dgG4z9io9GtlEyk0LHpZFON/altDb5CQ92G61r/wj0H4nmwlG12u2p50eiNASVQjv9trAwrXFQ/aTtFTM3Rd0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788885420; c=relaxed/simple;
	bh=HYDZU2/iTa5ubD4rljD/dlSHA2NuKBuiLDZd2cOaWhE=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=eAWMZObsfkHMob9iH8ndqfsxL7lifVMCYPBAFGgOTvgMInWIXXK4fTgxnO1CZzPdypVib3nBSSSkD588F4QEBqZAwOqJPhqgGTOeTeEP0Rysvvmfk22cNnXLuEX8CCTQVFyBy4lyPKGat2g7IxCGCyW0qtYbawuacvRwYGYotf0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=O/4ITD2X; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="O/4ITD2X"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E3D3F1F00A3A;
	Tue,  8 Sep 2026 16:36:58 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788885419;
	bh=BrM/U9qmGTHJ1Pwg7TvkGKP2TAsjnsUeAcw1ca0oVdE=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=O/4ITD2Xdk3JWjg5Dp0CM5PUgZnw5bm0aEiG+iKjzTRIIu1FO7Pwvnadrb+YG9YF7
	 0jynXXmFYQAzPzxgKZw0EMu30JJ+MY/rSSHqF8+I9N/ytKMKAzKRBSYCBi5ubHJ0Zc
	 kTTGhiGzrW4hDO0MtkxHrhzKvKUgXATO7lUWZB+8MDUKy6wgOwn1do9KhqfVPoMJSh
	 76PTvbdTdxgvoGodY9QG4PEwyFsfE607M27YW1spQIqawxNU+DOXAkLH8LmooInvvN
	 9urXVS/hYvr4Tm6dzM0ui9GuGjhNf4o9zK6x8dBt3NYnFb0S/xYx0ll0woebE+pX0J
	 +38Do5xkco6Cw==
Date: Tue, 8 Sep 2026 12:36:58 -0400
From: Mike Snitzer <snitzer@kernel.org>
To: linux-nfs@vger.kernel.org, linux-block@vger.kernel.org
Cc: dm-devel@lists.linux.dev, axboe@kernel.dk, cel@kernel.org,
	jlayton@kernel.org, david.flynn@hammerspace.com
Subject: Re: [PATCH 0/4] block, nfsd: fixes for sub-sector bvec direct I/O
Message-ID: <aqA5qgfUTbNi0nHJ@kernel.org>
References: <20260908163232.30774-1-snitzer@kernel.org>
 <20260908163448.30841-1-snitzer@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260908163448.30841-1-snitzer@kernel.org>

Apologies for the git-send-email misfire.. still not sure what
happened, but will sort it out for future.

On Tue, Sep 08, 2026 at 12:34:35PM -0400, Mike Snitzer wrote:
> While qualifying NFSD's NFSD_IO_DIRECT write path with byte-level data
> verification, it was found that the ITER_BVEC payloads nfsd submits 
> expose silent data corruption in two bio-based block drivers and
> two defects in nfsd itself. Example problematic payloads is the first
> fragment starts mid-page because the RPC header precedes it in the
> receive buffer, and fragment lengths need not be sector multiples.
> bio_iov_bvec_set() passes such an array to the queue as-is; nothing
> below it validates per-bvec sector alignment.
> 
> Patches 1-2 fix silent corruption (write completes successfully, data
> lands wrong) and are stable candidates:
> 
> - brd re-derives each segment's device position from
>   bio->bi_iter.bi_sector, which bio_advance_iter_single() advances by
>   whole sectors only, so a sub-sector segment length skews everything
>   that follows.
> 
> - zram hardwires is_partial_io() to false on 4K-page kernels, sending
>   sub-page bvecs down a whole-page path that ignores bv_offset/bv_len
>   entirely, and has the same sector-cursor skew.
> 
> Both are verified with a synthetic-bio reproducer (stamped pattern,
> write, read back, compare) across mid-page and page-aligned
> geometries.
> 
> Patches 3-4 fix nfsd: the filecache never fetches DIO alignment
> attributes on the supplied-file acquire branch, so every WRITE to a
> file created via NFSv4 OPEN(CREATE) is refused direct I/O for the
> file's cached lifetime; and nfsd's statx-based DIO gate is weaker than
> bio_split_io_at()'s split-time checks, so an admitted iterator can
> still be rejected by the block layer -- retry the segment buffered
> instead of failing a valid WRITE with NFS4ERR_INVAL.
> 
> One open question for the iomap/block maintainers: should ITER_BVEC
> direct I/O with sub-sector bvec boundaries be validated or bounced
> centrally rather than trusted to every driver's iteration?  An audit
> of in-tree bio-based drivers found the same bi_sector-derived position
> pattern in dm-io, dm-log-writes, dm-writecache (pmem path) and
> dm-integrity -- unreachable through nfsd today only because dm queues
> advertise dma_alignment >= 511, which nfsd's alignment gate refuses.
> 
> Tested with the reproducer matrix on brd, zram and nvme-loop at 4K and
> 16K page size (aarch64) and 4K (x86_64), plus 30-connection NFS write
> rigs comparing source against export byte-for-byte: clean with the
> fixes, corrupting or erroring without them.
> 
> Mike Snitzer (3):
>   brd: iterate the bio by byte position, not bi_sector
>   zram: handle sub-page bvec segments without corrupting data
>   nfsd: fall back to buffered I/O when a direct write gets -EINVAL
> 
> David Flynn (1):
>   nfsd: fetch direct I/O alignment for files handed to the filecache
> 
>  drivers/block/brd.c           | 29 +++++++++++++++++++++++------
>  drivers/block/zram/zram_drv.c | 36 +++++++++++++++++------------------
>  fs/nfsd/filecache.c           |  4 ++--
>  fs/nfsd/vfs.c                 | 29 +++++++++++++++++++++++++++++
>  4 files changed, 77 insertions(+), 31 deletions(-)
> 
> --
> 2.52.0
