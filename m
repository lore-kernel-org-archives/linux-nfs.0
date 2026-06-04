Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D2E842C028F;
	Thu,  4 Jun 2026 20:51:11 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1780606272; cv=none; b=l6DALxhh1WulqYcNw3ncUUGnJEOWsqXJ7pOXpQ+G9lwxxwzKXKFKlEHc1OhtqkLZKikJVBvuH1mjddF6HQJxoMqU6xbcZdd3DHp+G7sm4vGcQpbsbaQwnf9MumMGGBMYP2X7c09HwPGqDd8zmrARmfjI7JZugzI+Go1h/ltR0ok=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1780606272; c=relaxed/simple;
	bh=aMbqVUk9DvoZADFh+25mb4uQrQ8RlJFWbKKdnj5xWH8=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=Sf6ak4JFKJLMK5Bgt7DDoao8q9DhobCdn84vuEZoaQ1J+P4sbWnUiKyfW0yEoYHE9rHV5TyKJ10CwhK2yfgb7b45TROLKumshp8Cb3Si2fN/ZNbKqqIqT6+MYodgTVH1Y/hYdZZvo+Z4YaWAUxeZsh+FXjbQ9OdrlWqD8/Pbdo4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=jJ68y1At; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="jJ68y1At"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 878281F00893;
	Thu,  4 Jun 2026 20:51:11 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1780606271;
	bh=3ahxQIXqgDmlkrlQ/LGz0defDftsvJ68ugjJloNqUC0=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=jJ68y1Atnn8EiY1TaS/H9Zeg9noD50eQeKcRiezEDMOhNus9ytb17wYiBHKxZoaol
	 pEF0T5ZWzA9fRCRUox8xSZLXUejjzrxW0accjxQum4cdc3qTWqq9iY+rfkcIipA3bs
	 bz1m+4oy7+231QJWXUa2nGx3wsLFGNS+8RLlpQqkCtqUTI+j570KLYMU1y57IDdN/K
	 +SQaWL0xCwODFimG6jU26PZ2BlHJYiUMfegyGDlCa3No5xxiAiBtiSuAEo1HoQgEYm
	 X0kyrHn3ah1EXTac4excGubd1wtYtBNinNbUbLJLkyJuFl7A7LyMwMubQQiFDGrqBV
	 PedIpsq+zFpzQ==
Date: Thu, 4 Jun 2026 16:51:10 -0400
From: Mike Snitzer <snitzer@kernel.org>
To: Chuck Lever <cel@kernel.org>,
	Jonathan Flynn <jonathan.flynn@hammerspace.com>
Cc: Leon Romanovsky <leon@kernel.org>, Christoph Hellwig <hch@lst.de>,
	NeilBrown <neilb@ownmail.net>, Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>, Tom Talpey <tom@talpey.com>,
	linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org,
	Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH v4] svcrdma: Use contiguous pages for RDMA Read sink
 buffers
Message-ID: <aiHlPmeZq3WgMwoJ@kernel.org>
References: <20260319133610.2556826-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260319133610.2556826-1-cel@kernel.org>

On Thu, Mar 19, 2026 at 09:36:10AM -0400, Chuck Lever wrote:
> From: Chuck Lever <chuck.lever@oracle.com>
> 
> svc_rdma_build_read_segment() constructs RDMA Read sink
> buffers by consuming pages one-at-a-time from rq_pages[]
> and building one bvec per page. A 64KB NFS READ payload
> produces 16 separate bvecs, 16 DMA mappings, and
> potentially multiple RDMA Read WRs (on platforms with
> 4KB pages).
> 
> A single higher-order allocation followed by split_page()
> yields physically contiguous memory while preserving
> per-page refcounts. A single bvec spanning the contiguous
> range causes rdma_rw_ctx_init_bvec() to take the
> rdma_rw_init_single_wr_bvec() fast path: one DMA mapping,
> one SGE, one WR.
> 
> The split sub-pages replace the original rq_pages[] entries,
> so all downstream page tracking, completion handling, and
> xdr_buf assembly remain unchanged.
> 
> Allocation uses __GFP_NORETRY | __GFP_NOWARN and falls back
> through decreasing orders. If even order-1 fails, the
> existing per-page path handles the segment.
> 
> When nr_pages is not a power of two, get_order() rounds up
> and the allocation yields more pages than needed. The extra
> split pages replace existing rq_pages[] entries (freed via
> put_page() first), so there is no net increase in per-
> request page consumption. Successive segments reuse the
> same padding slots, preventing accumulation. The
> rq_maxpages guard rejects any allocation that would
> overrun the array, falling back to the per-page path.
> Under memory pressure, __GFP_NORETRY causes the higher-
> order allocation to fail without stalling.
> 
> The contiguous path is attempted when the segment starts
> page-aligned (rc_pageoff == 0) and spans at least two
> pages. NFS WRITE segments carry application-modified byte
> ranges of arbitrary length, so the optimization is not
> restricted to power-of-two page counts.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> Changes since v3:
> - Drop 1/3 - 3/3, they have already been reviewed and queued
> - Incorporate hch's review comments
> - Remove the #ifdef SZ_64K -- the logic works on those systems too
> 
> 
>  net/sunrpc/xprtrdma/svc_rdma_rw.c | 213 ++++++++++++++++++++++++++++++
>  1 file changed, 213 insertions(+)

This patch, which landed during the 7.1 merge window as commit
18755b8c2f241 ("svcrdma: Use contiguous pages for RDMA Read sink
buffers"), severely hurts RDMA performance when testing on very fast
RDMA networking on x86_64.

With this commit WRITE performance is "only" 24.2GB/s.
Without this commit WRITE performance is 60.6GB/s.

The cpu burn due to spinlock dominates the flamegraph that was
collected. Chuck, I'll send you the flamegraph off-list (and can send
it to anyone else who might be interested).  Jon Flynn did the testing
and we can request more info from him.

We may have a window _now_ on the current Hammerspace testbed to try
an incremental fix, but as of now simply reverting commit
18755b8c2f241 is as far as we got.

Thanks,
Mike
