Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793900682;
	b=DavjcKDha+PK7RQftcToFYT/PTItSS2KezaBCgwy3aDwf1WOTGyu8hlzWFqoY8To58h5
	 w0yAPyxi8bKyJbCsb9orORnPRKiNRLZLPEhnJzzXkAlAPDBWNC4rsvrGQdF17FOuIQxzs
	 5ThGgEaeNExL/AQqjBgpVPZ4SZ8XQPEk98eOtgcTjGsF/RQd/GZVffC9IcLLr7thgiS55
	 7ZGOTZDooKlT4h17adEyLfwIX6SDVi9JgK6UAM/Iex/vA0krEZsJiv1iSaAi4UNWCwmjY
	 CTdxwGPI2WoLiiQRYKh7SyU7lxYJzl1xmNQB9UvwuyUVTiEH+lQ0a0yXrTdv2sXFx/Q==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793900682;
	h=Received:DKIM-Signature:Received:Received:X-ME-Sender:
	 X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:X-Mailer:
	 MIME-Version:X-ThreadId:Date:From:To:Cc:Message-Id:In-Reply-To:
	 References:Subject:Content-Type:Content-Transfer-Encoding;
	bh=auQzEt43FXWDZiekdNqinox6nHqmw0kwClS/UWBUz3c=;
	b=1GpjKIIC1QDS0gfYspG7c+x+7GMEU7NUwZ2yCNpMsULzWRO0u8sScR0S+eBdKaTpDPWj
	 ZgXqSqlMu0DWsS03etwMwh9/ZpX81BAa7m23Wlq9ZjTNDF85vg/yrpoDCgEBpWgDciZKy
	 JNSD6CWYIszCbQ7Ps7ULiOKiVfq3S8HXi4TOV8ZSCJQSmRl3SCiwNMyobr/Glnlqz+5R/
	 pZ0K0GI14wh9m4v4k8Xb/T2lpVyCWWajI9io5OYYJf0Dofgqk5+A9En9Iyb/gKnXcpZUy
	 V1R9iuF2zfAslEAT99Pm0X++pXEgEoXSEJkce6dFnrLB76XrCP1xc1S3ae4almxmPBA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=meKA+uAJ;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9B9A5606A32E
	for <linux-nfs@vger.kernel.org>; Thu,  5 Nov 2026 17:44:42 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=meKA+uAJ
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 058391F00919
	for <linux-nfs@vger.kernel.org>; Thu,  5 Nov 2026 17:44:41 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793900682;
	bh=auQzEt43FXWDZiekdNqinox6nHqmw0kwClS/UWBUz3c=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=meKA+uAJPllS6lONzwiopjWWKawXW8pvxR/uqJHwBnzhAujGDLtpOXtNlDbiDVU2s
	 koWey3ECXzm15TQB0cd6t7GzYbm4laasnfEw4WZDU2cZkPyYoz7/j838FjktJdkAvD
	 f9ULaF2gHAqWO4ACDeGiJxut7VFihc1SoD5zstJEQ5UwhnSZK1VV95zqKAMMxPg6wG
	 KzRvc9LHbxgKxJ4tbqc7pyoiuj2QnNKlN5/V/0wDSvZoqlDme52GgN5RYpOErCWbmS
	 5Y8lEY33vLBH36P5BHA8iDN5s35y6RzvNKBS5mbBPaqP0zO86L25CO9yBhIJxZ6+Sq
	 yCaYEKNhukSFw==
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailfauth.phl.internal (Postfix) with ESMTP id 34819F4006A;
	Thu,  5 Nov 2026 12:44:41 -0500 (EST)
Received: from phl-imap-04 ([10.202.2.82])
  by phl-compute-02.internal (MEProxy); Thu, 05 Nov 2026 12:44:41 -0500
X-ME-Sender: <xms:icDsaoPs_0ze-Z6SxA0XTYGBT8xL7D4iQvoLDhKCMPxjQ6I-U--grg>
    <xme:icDsapw5yDU9JBMfSmgd6JrFoWvViYkApg1dsrDuGoqcIIKnVdZkD4hoZ_NShRsSm
    ixCiWKmjoDWwzBFf8oe_DMFx7vAFtCCdwr6AM_4MNPKLBr8E4HDUDqj>
X-ME-Proxy-Cause: dmFkZTETDpa/HILfC6Oth9fKrVbOfk9CZNX3da2CNiMqErLe0dNfZzv3EqhrSdzni45/Ld
    RyVJ1RF5ymV+Dp77sxUJlYCh1SIA8iwlnhuSkazKw1Tm04O5wIFRM7BXpEoUimmjNaWI5s
    kt37MmjME7NB452R2W1q0PSCGOFp3RrO+Pl0mdJfZZwM2itHPM/UJSnfdGNw4fYl4NDQVp
    5jE/rCBpZZgYz20c6hmuSPTwJ77KuBydFGXfZ1Xz51XWQcbrEn5PVF4Qp9B46OqZ5CWG/r
    ubGfLaTriQYOYlGPPfyW0sPCDPV9YuRaXnwrE797afWjgB5nnSIJq58bXdBwQ1fETry3Vc
    DSAHtB/TQKgh1dwM1P9DVqChTM/6pbVRr6guYGoPYpPjkQdFTfiVuc7LIIxNlwy7KP9aAY
    oTF2r+8FiHRqh8V8w1pnhfNaSAG2KEjmNxOVrwKbYQBFEkwf9e2HLNQJlLRyjXOHcKpBjh
    t+SPkZZt5x60COL6xcQJSlc+rC+G4wznqrSxEgbs12cfHAF+tkorQUHN1pWTUPESCFKyGl
    uBIAg1fQdF5hXvQzN3vLAgniaJeC6aHCB/hp7uk+fSF/uENKHPmBVFgq57Zp6B/AWJ3T5m
    Aadu+28nkjVbE1pb0zYGlHCqB1m+gB5WlplURrb9K6DsNPziyS89ub4zUWAg
X-ME-Proxy: <xmx:icDsan31hUQ62Yk0hRtQxEovOMgDi4AByXM-mAZqmyGq1nyaLwIliA>
    <xmx:icDsaj7i8xWLAKBeyvkklAt5Uip_F4yL4TbWC6Dpq1OXKXB5sib2DA>
    <xmx:icDsaiU-hHjktv_299pSBHWJ-FVUF4LXB_gMi7NbBuR-9kI_K2GvUg>
    <xmx:icDsaqAB1s52eL50YO5b0_avQbjyqXXLbz7TNPojXMXGGkdxE_9vBQ>
    <xmx:icDsap6E_x3Iz0qjmnzByZVRE5eJXAGno1JQVpruhCXNlHjHxu41pnIv>
Feedback-ID: i20964851:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 17157B6006E; Thu,  5 Nov 2026 12:44:41 -0500 (EST)
X-Mailer: MessagingEngine.com Webmail Interface
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
X-ThreadId: AanSU5p_fP17
Date: Thu, 05 Nov 2026 12:44:19 -0500
From: "Anna Schumaker" <anna@kernel.org>
To: "Mike Snitzer" <snitzer@kernel.org>,
 "Trond Myklebust" <trondmy@kernel.org>
Cc: linux-nfs@vger.kernel.org,
 "Jonathan Flynn" <jonathan.flynn@hammerspace.com>
Message-Id: <be94aec3-41a1-4e48-8ab7-86ad45c78fa2@app.fastmail.com>
In-Reply-To: <20261102191109.13470-7-snitzer@kernel.org>
References: <20261102191109.13470-1-snitzer@kernel.org>
 <20261102191109.13470-7-snitzer@kernel.org>
Subject: Re: [PATCH 06/11] NFSv4/flexfiles: pair the in-flight count with the
 layoutstats updates
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Hi Mike,

On Mon, Nov 2, 2026, at 2:11 PM, Mike Snitzer wrote:
> From: Mike Snitzer <snitzer@hammerspace.com>
>
> The busy timer's in-flight op count and the requested-side statistics are
> two halves of the same accounting, but they lived in two helpers that the
> callers invoked back to back.  Nothing stopped a new requested-side path
> from updating one and missing the other.
>
> Fold nfs4_ff_layout_stat_io_update_requested() into
> nfs4_ff_layoutstat_start_io() so both happen in one place, and rename
> nfs4_ff_layout_stat_io_update_completed() to nfs4_ff_layoutstat_end_io()
> for symmetry -- it already dropped the in-flight count alongside the
> completed-side statistics.
>
> Rename nfs4_ff_busy_timer::n_ops to ops_in_flight while here.  It is what
> the field holds, and it makes its relationship to the op counters legible
> at the point of use.
>
> Both helpers now take the stripe rather than mirror + dss_id, which lets
> them assert the lock they run under.  Since the previous patch made
> ops_in_flight a plain int, that lock is the only thing keeping it
> consistent, so assert it rather than document it; lockdep_assert_held()
> compiles out without CONFIG_PROVE_LOCKING.  The callers get a dss_info
> local, which is what they were open coding.
>
> No functional change.
>
> Signed-off-by: Mike Snitzer <snitzer@hammerspace.com>
> ---
>  fs/nfs/flexfilelayout/flexfilelayout.c | 104 ++++++++++++++-----------
>  fs/nfs/flexfilelayout/flexfilelayout.h |   2 +-
>  2 files changed, 58 insertions(+), 48 deletions(-)
>
> diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c 
> b/fs/nfs/flexfilelayout/flexfilelayout.c
> index 6a474fa7b0446..bfe8288a14a08 100644
> --- a/fs/nfs/flexfilelayout/flexfilelayout.c
> +++ b/fs/nfs/flexfilelayout/flexfilelayout.c
> @@ -711,7 +711,7 @@ static void
>  nfs4_ff_start_busy_timer(struct nfs4_ff_busy_timer *timer, ktime_t now)
>  {
>  	/* first IO request? */
> -	if (++timer->n_ops == 1)
> +	if (++timer->ops_in_flight == 1)
>  		timer->start_time = now;
>  }
> 
> @@ -720,7 +720,7 @@ nfs4_ff_end_busy_timer(struct nfs4_ff_busy_timer 
> *timer, ktime_t now)
>  {
>  	ktime_t start;
> 
> -	WARN_ON_ONCE(--timer->n_ops < 0);
> +	WARN_ON_ONCE(--timer->ops_in_flight < 0);
> 
>  	start = timer->start_time;
>  	timer->start_time = now;
> @@ -743,18 +743,31 @@ nfs4_ff_layoutstat_set_start_time(struct 
> nfs4_ff_layout_ds_stripe *dss_info,
>  		try_cmpxchg64(&dss_info->start_time, &unset, now);
>  }
> 
> +/*
> + * Account for an I/O about to be sent to this stripe, and return true if a
> + * LAYOUTSTATS report is due.
> + *
> + * The in-flight count and the requested-side counters are bumped here
> + * together, so a new requested-side path cannot update one and miss the
> + * other.
> + */
>  static bool
> -nfs4_ff_layoutstat_start_io(struct nfs4_ff_layout_mirror *mirror,
> -			    u32 dss_id,
> +nfs4_ff_layoutstat_start_io(struct nfs4_ff_layout_ds_stripe *dss_info,
>  			    struct nfs4_ff_layoutstat *layoutstat,
> -			    ktime_t now)
> +			    __u64 requested, ktime_t now)
>  {
> -	s64 report_interval = FF_LAYOUTSTATS_REPORT_INTERVAL;
> +	struct nfs4_ff_layout_mirror *mirror = dss_info->mirror;
>  	struct nfs4_flexfile_layout *ffl = FF_LAYOUT_FROM_HDR(mirror->layout);
> +	s64 report_interval = FF_LAYOUTSTATS_REPORT_INTERVAL;
>  	ktime_t last_report;
> 
> +	lockdep_assert_held(&dss_info->lock);
> +
>  	nfs4_ff_start_busy_timer(&layoutstat->busy_timer, now);
> -	nfs4_ff_layoutstat_set_start_time(&mirror->dss[dss_id], now);
> +	layoutstat->io_stat.ops_requested++;
> +	layoutstat->io_stat.bytes_requested += requested;
> +
> +	nfs4_ff_layoutstat_set_start_time(dss_info, now);
>  	if (mirror->report_interval != 0)
>  		report_interval = (s64)mirror->report_interval * 1000LL;
>  	else if (layoutstats_timer != 0)
> @@ -772,27 +785,25 @@ nfs4_ff_layoutstat_start_io(struct 
> nfs4_ff_layout_mirror *mirror,
>  	return try_cmpxchg64(&ffl->last_report_time, &last_report, now);
>  }
> 
> +/*
> + * Account for an I/O that has completed on this stripe.  The in-flight count
> + * is dropped here, alongside the completed-side counters, for the same reason
> + * it is bumped in nfs4_ff_layoutstat_start_io().
> + */
>  static void
> -nfs4_ff_layout_stat_io_update_requested(struct nfs4_ff_layoutstat *layoutstat,
> -		__u64 requested)
> -{
> -	struct nfs4_ff_io_stat *iostat = &layoutstat->io_stat;
> -
> -	iostat->ops_requested++;
> -	iostat->bytes_requested += requested;
> -}
> -
> -static void
> -nfs4_ff_layout_stat_io_update_completed(struct nfs4_ff_layoutstat *layoutstat,
> -		__u64 requested,
> -		__u64 completed,
> -		ktime_t time_completed,
> -		ktime_t time_started)
> +nfs4_ff_layoutstat_end_io(struct nfs4_ff_layout_ds_stripe *dss_info,
> +			  struct nfs4_ff_layoutstat *layoutstat,
> +			  __u64 requested,
> +			  __u64 completed,
> +			  ktime_t time_completed,
> +			  ktime_t time_started)
>  {
>  	struct nfs4_ff_io_stat *iostat = &layoutstat->io_stat;
>  	ktime_t completion_time = ktime_sub(time_completed, time_started);
>  	ktime_t timer;
> 
> +	lockdep_assert_held(&dss_info->lock);
> +
>  	iostat->ops_completed++;
>  	iostat->bytes_completed += completed;
>  	iostat->bytes_not_delivered += requested - completed;
> @@ -811,14 +822,13 @@ nfs4_ff_layout_stat_io_start_read(struct inode *inode,
>  		u32 dss_id,
>  		__u64 requested, ktime_t now)
>  {
> +	struct nfs4_ff_layout_ds_stripe *dss_info = &mirror->dss[dss_id];
>  	bool report;
> 
> -	spin_lock(&mirror->dss[dss_id].lock);
> -	report = nfs4_ff_layoutstat_start_io(
> -		mirror, dss_id, &mirror->dss[dss_id].read_stat, now);
> -	nfs4_ff_layout_stat_io_update_requested(
> -		&mirror->dss[dss_id].read_stat, requested);
> -	spin_unlock(&mirror->dss[dss_id].lock);
> +	spin_lock(&dss_info->lock);
> +	report = nfs4_ff_layoutstat_start_io(dss_info, &dss_info->read_stat,
> +					     requested, now);
> +	spin_unlock(&dss_info->lock);

I noticed that this function and nfs4_ff_layout_stat_io_start_write() are
almost identical (the only difference being read_stat vs write_stat). I
was wondering if it might be possible to combine them in the future to
reduce code duplication?

Thanks,
Anna

>  	set_bit(NFS4_FF_MIRROR_STAT_AVAIL, &mirror->flags);
> 
>  	if (report)
> @@ -832,11 +842,13 @@ nfs4_ff_layout_stat_io_end_read(struct rpc_task *task,
>  		__u64 requested,
>  		__u64 completed)
>  {
> -	spin_lock(&mirror->dss[dss_id].lock);
> -	nfs4_ff_layout_stat_io_update_completed(&mirror->dss[dss_id].read_stat,
> -			requested, completed,
> -			ktime_get(), task->tk_start);
> -	spin_unlock(&mirror->dss[dss_id].lock);
> +	struct nfs4_ff_layout_ds_stripe *dss_info = &mirror->dss[dss_id];
> +
> +	spin_lock(&dss_info->lock);
> +	nfs4_ff_layoutstat_end_io(dss_info, &dss_info->read_stat,
> +				  requested, completed,
> +				  ktime_get(), task->tk_start);
> +	spin_unlock(&dss_info->lock);
>  	set_bit(NFS4_FF_MIRROR_STAT_AVAIL, &mirror->flags);
>  }
> 
> @@ -846,18 +858,13 @@ nfs4_ff_layout_stat_io_start_write(struct inode *inode,
>  		u32 dss_id,
>  		__u64 requested, ktime_t now)
>  {
> +	struct nfs4_ff_layout_ds_stripe *dss_info = &mirror->dss[dss_id];
>  	bool report;
> 
> -	spin_lock(&mirror->dss[dss_id].lock);
> -	report = nfs4_ff_layoutstat_start_io(
> -		mirror,
> -		dss_id,
> -		&mirror->dss[dss_id].write_stat,
> -		now);
> -	nfs4_ff_layout_stat_io_update_requested(
> -		&mirror->dss[dss_id].write_stat,
> -		requested);
> -	spin_unlock(&mirror->dss[dss_id].lock);
> +	spin_lock(&dss_info->lock);
> +	report = nfs4_ff_layoutstat_start_io(dss_info, &dss_info->write_stat,
> +					     requested, now);
> +	spin_unlock(&dss_info->lock);
>  	set_bit(NFS4_FF_MIRROR_STAT_AVAIL, &mirror->flags);
> 
>  	if (report)
> @@ -872,13 +879,16 @@ nfs4_ff_layout_stat_io_end_write(struct rpc_task *task,
>  		__u64 completed,
>  		enum nfs3_stable_how committed)
>  {
> +	struct nfs4_ff_layout_ds_stripe *dss_info = &mirror->dss[dss_id];
> +
>  	if (committed == NFS_UNSTABLE)
>  		requested = completed = 0;
> 
> -	spin_lock(&mirror->dss[dss_id].lock);
> -	nfs4_ff_layout_stat_io_update_completed(&mirror->dss[dss_id].write_stat,
> -			requested, completed, ktime_get(), task->tk_start);
> -	spin_unlock(&mirror->dss[dss_id].lock);
> +	spin_lock(&dss_info->lock);
> +	nfs4_ff_layoutstat_end_io(dss_info, &dss_info->write_stat,
> +				  requested, completed,
> +				  ktime_get(), task->tk_start);
> +	spin_unlock(&dss_info->lock);
>  	set_bit(NFS4_FF_MIRROR_STAT_AVAIL, &mirror->flags);
>  }
> 
> diff --git a/fs/nfs/flexfilelayout/flexfilelayout.h 
> b/fs/nfs/flexfilelayout/flexfilelayout.h
> index d97001abc0d22..b0653a652d3b8 100644
> --- a/fs/nfs/flexfilelayout/flexfilelayout.h
> +++ b/fs/nfs/flexfilelayout/flexfilelayout.h
> @@ -70,7 +70,7 @@ struct nfs4_ff_io_stat {
>   */
>  struct nfs4_ff_busy_timer {
>  	ktime_t start_time;
> -	int n_ops;
> +	int ops_in_flight;
>  };
> 
>  struct nfs4_ff_layoutstat {
> -- 
> 2.52.0
