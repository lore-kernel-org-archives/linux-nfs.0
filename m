Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792534315;
	b=lZHj0akjM+Li1503AuKrO8TiPcj194Kg9lzCZH7QjoSneI5Ww+U8QfLiekdsalcvoqSi
	 8jExMxEYM9dsZsg1m3vhqh8R946LcqDzCERHjdP73Jil3/Z9QgD+4tBnmwx7A2H71pzif
	 7UdkETkJRkPW3/FrF0wWQLtWeHR8xR+TbvT3+uXuCcIT657D3uiLtPWQSVYB0HOkRIM2e
	 5ZstnytLLjCP0nzmn+UKae93/mBfEyrXGpkgugKnIXgYWQp9Uaa/FRHJ2RsHkVg2EcR85
	 sIUKSi9BS7G/zTH7XJykNfw9PchpOkOV2hquaxNzqrhm1BVwMlySu2Uxzruvd9uhqyA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792534315;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To;
	bh=NpFLan+/UuwgnzMCO1yKW0YhIn6YvxfWrSCdFI7nkSg=;
	b=wjX/jsmkgO7EZ9HohDPPf2OFGkGu64zVKGRP7oVf4kJIvc6UheOceO7T6bXkUlYWcOc/
	 jolpuQUPBHW/B4eBvhIrvzldLCeaicUUeQkeDkIfBMK2ph3YiLAjhumvqptc6NPVnhYBM
	 VU3AgkfYRO/sa0Yz+RAC1x35cIjWmi7gVRfYAddNQxSSQxdkJSTFjelpeDwKix6pThnsP
	 0Al0MrbQl0EbXJk6Y6vmJEfE6pB9455eD2vhVdH8TKpGEiRgguLSf7u7cuLl0GnoJr4u8
	 b+gAgKNyz2m2k2deUJpgftfFa17Bq4hlZIURP/YNRGYXaXNCFlWKLykS13o3ixCYMsA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="N1/nEJWO";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 62AF0606A319;
	Tue, 20 Oct 2026 22:11:55 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=N1/nEJWO
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C52651F000C9;
	Tue, 20 Oct 2026 22:11:54 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792534315;
	bh=NpFLan+/UuwgnzMCO1yKW0YhIn6YvxfWrSCdFI7nkSg=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=N1/nEJWOj9GL0Tc5obFWdlcWohS41ITXgsBTMTdVcUdZ3M00ZixvCMaMTMsT+OwuD
	 g+ycxH/HAME4S/LIjYo4Kd1fXkJ9oXBw5XyrL07bK8TqBU9/bmJBrSqTQD+z8WMqqt
	 6XE1bszg5xZjnxqWX/Mj+fra/ygDz3ypMGHygi7DlO35STxFgn0c+Z7lzr5hJIFh71
	 MQg8Ov3kzBbxTKTQHk4DyH2htibCiDlwcpufA9EdsVjApsDhlrKxmZTukgkryU/TW0
	 34qnmroxipBVxkKxhm8too4dCWsX2bRYOffBv9HSWUA13VZjpGo8WJ6nzNTYAZ2D41
	 Xxh5crpem99iw==
Date: Tue, 20 Oct 2026 18:11:53 -0400
From: Mike Snitzer <snitzer@kernel.org>
To: Mike Snitzer <snitzer@hammerspace.com>
Cc: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>,
	linux-nfs@vger.kernel.org, NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>,
	Christoph Hellwig <hch@lst.de>, Jens Axboe <axboe@kernel.dk>,
	Matthew Wilcox <willy@infradead.org>,
	Jonathan Corbet <corbet@lwn.net>, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH v7 1/5] mm: expose WB_DONTCACHE_DIRTY in bdi debugfs stats
Message-ID: <atfnKRbYfnwwi_Tb@kernel.org>
References: <20261020220346.28020-1-snitzer@kernel.org>
 <20261020220346.28020-2-snitzer@kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20261020220346.28020-2-snitzer@kernel.org>

On Tue, Oct 20, 2026 at 06:03:42PM -0400, Mike Snitzer wrote:
> The per-bdi_writeback WB_DONTCACHE_DIRTY counter drives how much the
> flusher writes back in response to an IOCB_DONTCACHE kick, but it is
> not reported anywhere, so the DONTCACHE dirty backlog can only be
> inferred from MemFree/Cached movement.
> 
> Report it as BdiDontcacheDirty in /sys/kernel/debug/bdi/<dev>/stats
> and as WbDontcacheDirty in the per-wb stats, next to the
> Reclaimable line.  Use wb_stat_sum() rather than wb_stat() to fold in
> the per-cpu batches: the flusher targets the summed value and small
> backlogs would otherwise read as zero.
> 
> Fixes: 88d6f128d06d ("mm: track DONTCACHE dirty pages per bdi_writeback")
> Cc: Jeff Layton <jlayton@kernel.org>

FYI, I forgot to pick up Jeff's provided review tag for this patch:

Reviewed-by: Jeff Layton <jlayton@kernel.org>

see: https://lore.kernel.org/linux-nfs/2bee53783a2372b8dc715350b6f6d2ad5d8770ff.camel@kernel.org/

Thanks,
Mike

> Cc: Jens Axboe <axboe@kernel.dk>
> Cc: Matthew Wilcox (Oracle) <willy@infradead.org>
> Cc: linux-mm@kvack.org
> Assisted-by: LLM
> Signed-off-by: Mike Snitzer <snitzer@kernel.org>
> ---
>  mm/backing-dev.c | 11 +++++++++++
>  1 file changed, 11 insertions(+)
> 
> diff --git a/mm/backing-dev.c b/mm/backing-dev.c
> index 18e999053bae..b8a2c27e07fa 100644
> --- a/mm/backing-dev.c
> +++ b/mm/backing-dev.c
> @@ -46,6 +46,7 @@ struct wb_stats {
>  	unsigned long nr_dirty_time;
>  	unsigned long nr_writeback;
>  	unsigned long nr_reclaimable;
> +	unsigned long nr_dontcache_dirty;
>  	unsigned long nr_dirtied;
>  	unsigned long nr_written;
>  	unsigned long dirty_thresh;
> @@ -78,6 +79,12 @@ static void collect_wb_stats(struct wb_stats *stats,
>  
>  	stats->nr_writeback += wb_stat(wb, WB_WRITEBACK);
>  	stats->nr_reclaimable += wb_stat(wb, WB_RECLAIMABLE);
> +	/*
> +	 * Sum the per-cpu batches: the dontcache flusher targets this
> +	 * counter via wb_stat_sum() and small backlogs would otherwise
> +	 * read as zero here.
> +	 */
> +	stats->nr_dontcache_dirty += wb_stat_sum(wb, WB_DONTCACHE_DIRTY);
>  	stats->nr_dirtied += wb_stat(wb, WB_DIRTIED);
>  	stats->nr_written += wb_stat(wb, WB_WRITTEN);
>  	stats->wb_thresh += wb_calc_thresh(wb, stats->dirty_thresh);
> @@ -125,6 +132,7 @@ static int bdi_debug_stats_show(struct seq_file *m, void *v)
>  	seq_printf(m,
>  		   "BdiWriteback:       %10lu kB\n"
>  		   "BdiReclaimable:     %10lu kB\n"
> +		   "BdiDontcacheDirty:  %10lu kB\n"
>  		   "BdiDirtyThresh:     %10lu kB\n"
>  		   "DirtyThresh:        %10lu kB\n"
>  		   "BackgroundThresh:   %10lu kB\n"
> @@ -139,6 +147,7 @@ static int bdi_debug_stats_show(struct seq_file *m, void *v)
>  		   "state:              %10lx\n",
>  		   K(stats.nr_writeback),
>  		   K(stats.nr_reclaimable),
> +		   K(stats.nr_dontcache_dirty),
>  		   K(stats.wb_thresh),
>  		   K(dirty_thresh),
>  		   K(background_thresh),
> @@ -163,6 +172,7 @@ static void wb_stats_show(struct seq_file *m, struct bdi_writeback *wb,
>  		   "WbCgIno:           %10lu\n"
>  		   "WbWriteback:       %10lu kB\n"
>  		   "WbReclaimable:     %10lu kB\n"
> +		   "WbDontcacheDirty:  %10lu kB\n"
>  		   "WbDirtyThresh:     %10lu kB\n"
>  		   "WbDirtied:         %10lu kB\n"
>  		   "WbWritten:         %10lu kB\n"
> @@ -179,6 +189,7 @@ static void wb_stats_show(struct seq_file *m, struct bdi_writeback *wb,
>  #endif
>  		   K(stats->nr_writeback),
>  		   K(stats->nr_reclaimable),
> +		   K(stats->nr_dontcache_dirty),
>  		   K(stats->wb_thresh),
>  		   K(stats->nr_dirtied),
>  		   K(stats->nr_written),
> -- 
> 2.52.0
> 
