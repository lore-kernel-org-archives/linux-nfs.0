Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792708280;
	b=GXI0GU0lhjAS2eDF3RH77sI/bKmM78azpHnUAHIoaOjYvO7CLfWdqEX5pWi9g6WuZyJJ
	 kxBPdGbYeiDss8Ynx0BU5kIjvXPhYTQT7ils2IfEhEnySwK5M9GSa5q5/GF85sanVGar9
	 PFcpfMSc7xLVzL4K71b4eXgNnSD4SqYawr+ZwSaRObQ2PTK+TU4R6mSLS9biCSRpYzEUG
	 omZSh1kyAe/Je3KPzhvK/D2yqzHuMdAykHKxNa4aBUeo9ZP4nnf6lsLoiViJ5BTtqDR3r
	 pwGDIHeSIGErnyjoXg6NonqFYKb5qJYR9bf3wMswh1xQCquxc+s1gnJsjiMvs/qLs9Q==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792708280;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To;
	bh=S6ItmhQmV+wqX2MpWL8c5Yttc4aPWEpi/wAss+677D8=;
	b=g3hWOQffkI2MNYWt4lKM63iS/W3yWC8zsznRyglRZg9qN3thg1NZ6rzfde6l8iccR3K4
	 ug3QKZDZt6Sl36D5uHbtAX+ImpgjPR3/ksaMgp0oTtKhilEWfQMaly27gOSEr9mFYZN4Q
	 iJ0dLNZxRgZnevI39Z15/E9kUjrGF/7PCysLXE1VgxOpttKX1ptp8FA7v/54w8GqGthX5
	 Y4hF/WXpGkZGWMMKwebaRXx3XqagBEaiKjhr16Vs+HWh8z1Bia2X50aw15/QnT5IGtokB
	 sJxDqrzdVvPeEudQeEjxWsa3GMBKsZGq6UVJ7B4vTk9eXsCquxQe/UOzoHYUIuujn0A==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=cNINS75x;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7FD85606A321;
	Thu, 22 Oct 2026 22:31:20 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=cNINS75x
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E24CE1F01825;
	Thu, 22 Oct 2026 22:31:19 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792708280;
	bh=S6ItmhQmV+wqX2MpWL8c5Yttc4aPWEpi/wAss+677D8=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=cNINS75xd5z+a3HR344LN34/HXl5PH0//AlhRP2yTNnunWu8M3d7ff06ib5JtDq3m
	 kjSLPtVghAJmWu7KH3QGsynw+x9DyLWUYE4Cg83B/otaxto9CCwb0Mpo1vze2eKGmN
	 /g9SqYPp4WU8onhFVZOSWwdFFStB//8ACNEHlMI9Jm/C0K/8/aawzkuA/dxi93ApEy
	 4aRpstEfkmXSnJ+NJguTOKCftxGiK6f9dIYJ0W3t/R0f0WQ9bhfcs0/sKrgqG4ppSe
	 /aym6feIyigq3/SICiESMNZJmxYa7W1dHL/NxhzYMUjKEG6W/uT/QEu1zSHsAmvHt+
	 yer4hVCOeemBg==
Date: Thu, 22 Oct 2026 18:31:19 -0400
From: Mike Snitzer <snitzer@kernel.org>
To: Jeff Layton <jlayton@kernel.org>
Cc: Mike Snitzer <snitzer@hammerspace.com>, Chuck Lever <cel@kernel.org>,
	linux-nfs@vger.kernel.org, NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>,
	Christoph Hellwig <hch@lst.de>, Jens Axboe <axboe@kernel.dk>,
	Matthew Wilcox <willy@infradead.org>,
	Jonathan Corbet <corbet@lwn.net>, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH v7 1/5] mm: expose WB_DONTCACHE_DIRTY in bdi debugfs stats
Message-ID: <atqOtyegOnvw45G0@kernel.org>
References: <20261020220346.28020-1-snitzer@kernel.org>
 <20261020220346.28020-2-snitzer@kernel.org>
 <1315c1dda358121708d6b007dcfa959653988218.camel@kernel.org>
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
In-Reply-To: <1315c1dda358121708d6b007dcfa959653988218.camel@kernel.org>

On Wed, Oct 21, 2026 at 06:50:47AM -0400, Jeff Layton wrote:
> On Tue, 2026-10-20 at 18:03 -0400, Mike Snitzer wrote:
> > The per-bdi_writeback WB_DONTCACHE_DIRTY counter drives how much the
> > flusher writes back in response to an IOCB_DONTCACHE kick, but it is
> > not reported anywhere, so the DONTCACHE dirty backlog can only be
> > inferred from MemFree/Cached movement.
> > 
> > Report it as BdiDontcacheDirty in /sys/kernel/debug/bdi/<dev>/stats
> > and as WbDontcacheDirty in the per-wb stats, next to the
> > Reclaimable line.  Use wb_stat_sum() rather than wb_stat() to fold in
> > the per-cpu batches: the flusher targets the summed value and small
> > backlogs would otherwise read as zero.
> > 
> > Fixes: 88d6f128d06d ("mm: track DONTCACHE dirty pages per bdi_writeback")
> > Cc: Jeff Layton <jlayton@kernel.org>
> > Cc: Jens Axboe <axboe@kernel.dk>
> > Cc: Matthew Wilcox (Oracle) <willy@infradead.org>
> > Cc: linux-mm@kvack.org
> > Assisted-by: LLM
> > Signed-off-by: Mike Snitzer <snitzer@kernel.org>
> > ---
> >  mm/backing-dev.c | 11 +++++++++++
> >  1 file changed, 11 insertions(+)
> > 
> > diff --git a/mm/backing-dev.c b/mm/backing-dev.c
> > index 18e999053bae..b8a2c27e07fa 100644
> > --- a/mm/backing-dev.c
> > +++ b/mm/backing-dev.c
> > @@ -46,6 +46,7 @@ struct wb_stats {
> >  	unsigned long nr_dirty_time;
> >  	unsigned long nr_writeback;
> >  	unsigned long nr_reclaimable;
> > +	unsigned long nr_dontcache_dirty;
> >  	unsigned long nr_dirtied;
> >  	unsigned long nr_written;
> >  	unsigned long dirty_thresh;
> > @@ -78,6 +79,12 @@ static void collect_wb_stats(struct wb_stats *stats,
> >  
> >  	stats->nr_writeback += wb_stat(wb, WB_WRITEBACK);
> >  	stats->nr_reclaimable += wb_stat(wb, WB_RECLAIMABLE);
> > +	/*
> > +	 * Sum the per-cpu batches: the dontcache flusher targets this
> > +	 * counter via wb_stat_sum() and small backlogs would otherwise
> > +	 * read as zero here.
> > +	 */
> 
> nit: I don't personally find this comment very helpful.

Meant to address "why not just use wb_stat()?". But will drop it (and
leave it to commit header to explain).

> > +	stats->nr_dontcache_dirty += wb_stat_sum(wb, WB_DONTCACHE_DIRTY);
> >  	stats->nr_dirtied += wb_stat(wb, WB_DIRTIED);
> >  	stats->nr_written += wb_stat(wb, WB_WRITTEN);
> >  	stats->wb_thresh += wb_calc_thresh(wb, stats->dirty_thresh);
> > @@ -125,6 +132,7 @@ static int bdi_debug_stats_show(struct seq_file *m, void *v)
> >  	seq_printf(m,
> >  		   "BdiWriteback:       %10lu kB\n"
> >  		   "BdiReclaimable:     %10lu kB\n"
> > +		   "BdiDontcacheDirty:  %10lu kB\n"
> >  		   "BdiDirtyThresh:     %10lu kB\n"
> >  		   "DirtyThresh:        %10lu kB\n"
> >  		   "BackgroundThresh:   %10lu kB\n"
> > @@ -139,6 +147,7 @@ static int bdi_debug_stats_show(struct seq_file *m, void *v)
> >  		   "state:              %10lx\n",
> >  		   K(stats.nr_writeback),
> >  		   K(stats.nr_reclaimable),
> > +		   K(stats.nr_dontcache_dirty),
> >  		   K(stats.wb_thresh),
> >  		   K(dirty_thresh),
> >  		   K(background_thresh),
> > @@ -163,6 +172,7 @@ static void wb_stats_show(struct seq_file *m, struct bdi_writeback *wb,
> >  		   "WbCgIno:           %10lu\n"
> >  		   "WbWriteback:       %10lu kB\n"
> >  		   "WbReclaimable:     %10lu kB\n"
> > +		   "WbDontcacheDirty:  %10lu kB\n"
> >  		   "WbDirtyThresh:     %10lu kB\n"
> >  		   "WbDirtied:         %10lu kB\n"
> >  		   "WbWritten:         %10lu kB\n"
> > @@ -179,6 +189,7 @@ static void wb_stats_show(struct seq_file *m, struct bdi_writeback *wb,
> >  #endif
> >  		   K(stats->nr_writeback),
> >  		   K(stats->nr_reclaimable),
> > +		   K(stats->nr_dontcache_dirty),
> >  		   K(stats->wb_thresh),
> >  		   K(stats->nr_dirtied),
> >  		   K(stats->nr_written),
> 
> Patch looks fine though:
> 
> Reviewed-by: Jeff Layton <jlayton@kernel.org>

Thanks! 
