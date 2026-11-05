Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793908755;
	b=jsxCHCj/+sIvroWFaq9VFHeM5FaXEKZEwtVOhZOhUWVJq2yXs1zV++5JMk/+WmS9EIHw
	 FXf00IElYmWZuguG9UVkhAtcN1UNxZT2OrxyqnLxq+KDPndp03PMriP5by5/0PvqkMLEw
	 cQ+b3pf6gFVM650Rn4P6AEaiSqVRbWuS1ftKfiz4Bgk9/Rbrtb5L8gKK58nln5qNEKzl4
	 jej4MF8zmPDhhoJq7tRmiOQpqHIAtQE6cjFEL+8+w/a/UiBEAKASQgC3/9DXKlOOwMze+
	 kWxoohwp9mSEHI1OI7gnR2qxn678AqHnZE2DVfXB2ThV1ZQtxIUz5A8TnBbYk5kH5nw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793908755;
	h=Received:DKIM-Signature:Received:Received:X-ME-Sender:
	 X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:X-Mailer:
	 MIME-Version:X-ThreadId:Date:From:To:Cc:Message-Id:In-Reply-To:
	 References:Subject:Content-Type:Content-Transfer-Encoding;
	bh=SH/NU635Jw9KqUBHpUBBLmUBM8Rnyg+rFvGXb8+z+WY=;
	b=eLJoVrcSTyswRhZYszCKIQ6k3FAkX9Ksu6P3xSQ650YDMi90sa592nBx8mpp05LCk+un
	 RSqMYW75cjBwq2yPFYEEk6/W/qJB2JW6n7KpQOXsazAADa1lZYD98sIF7dH0/NZPaHywm
	 Sc6Vh5kir3Gg+6pRt5pKd0YFPTmZfH+tYMNZMZHmInNMJwxZ5JfRs1OtSB6eo6W6mHzA4
	 Xm3ZLGd0YrzG4GoShzf0KQByqQi7LV/aPSC98WWKsQyfkeQta4kHaPjewaFXTnCnahvHn
	 av6W08vQMpm4mf88SsqnTm66NI7/ANmvgUmt/2zsOteqp30zhN16asGNu4j/t8vgZ6w==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=VWyOYm06;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 51928606A6CD
	for <linux-nfs@vger.kernel.org>; Thu,  5 Nov 2026 19:59:15 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=VWyOYm06
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 956251F0089F;
	Thu,  5 Nov 2026 19:59:14 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793908754;
	bh=SH/NU635Jw9KqUBHpUBBLmUBM8Rnyg+rFvGXb8+z+WY=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=VWyOYm06v8ZfWgNl4XCGRfFNi/MIgfdAkhObW+JpoOECc6s201CeCUjupc+F5e8K7
	 NH7O4JewQnOSv1Kr/SBe1An6mAykE02vu4vDE+pEu6JreNvHRuz/LqJ/ojZxsGSSmk
	 UWUQQHrskfTKaK0xg3z1sY3ZqE6twrKkIB1VxNG1tDGYUVpnaVOefab3Ta62Nlmib+
	 TbffeqXZ64brR5kyTz2hiqIzmCWWI4ibDwB9LgbYSV+XEcRWDXfzYxQQeBB4AF1DR2
	 bmcrBO7WdiG0kLLL5y3NrCLbHQe3niozM18UoQxvyK6SRZVI0WO3uSGrGNK0auMECp
	 YWpyjeJDCxQzA==
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailfauth.phl.internal (Postfix) with ESMTP id 0326CF40068;
	Thu,  5 Nov 2026 14:59:14 -0500 (EST)
Received: from phl-imap-04 ([10.202.2.82])
  by phl-compute-02.internal (MEProxy); Thu, 05 Nov 2026 14:59:14 -0500
X-ME-Sender: <xms:EeDsajqpueDXs8Y3zl0sf2VRWWgHLpT41d3YFM5zdUSiy0bDDoty8Q>
    <xme:EeDsaof9HaawBDANKUnrJ2xtrh2dzTWBNd7VFmLz0Ij1Yxl-Weu8rjoOyrMtVx7Wf
    6_K_VMa60yWhdR0ruBzIXzrUp62IAbolDss5Rkx_3J2sscNc2oKg9z_>
X-ME-Proxy-Cause: dmFkZTEx9Rtnwjj9/rw1+oQkNzxKPUdrzzle4BKdPiaEkE4oaLXYueWnQbzZ1vVMqrBPRh
    pVCuZguRO0NR4CNi8MBEgydLhKh9vMZUHY/85DoNQ35DLnxrlWONyUEvQmMGHJteeEuiaS
    UN45865ApuGrV9+UurMSdN5lxmbaXIfh30KkSNHDbcm3eWoIL/93unHIbITdBCoddTd560
    UaumSqhKD4a4gq4YsFBVskq5B2aSYqlJJnR6TzKLdyIqvPUWEAETlKxviWppFrrHUV+Vbn
    w5pbrTwEDr9Y/OaqtLB7xo67zCUhrPX8Hu2Uz2c23NCqnAsS+A/ot07xEqIN3ihrFMDVWf
    7RYAXeg0CWv9lCHkfcuLdBvh+3Xegxsm6o9A5jzM9sllHK7kBL8x761X3r3Og1i6PniojY
    ZqyPXKeZ7vy6uvY09zE8A/ey2/8m0zOrX2M6m2+cJ61fK4c0tN09HrPfLtfsERiRLHy03q
    5wZjpFb0SLq6oH+LVWxrdFs16UvTJSXNwlsM+ZXgTUvT5ImM8W2yK354Fe31gV51bZ5qwa
    xpVBYCAytd8XcI4SH/RBPntOe0kypmdWCSHz4M0lnqGgUZUs9NMkBIXc6JLNm7AE4rLpo+
    v6/7l3+HCmH4we2gEW4hTDJi/ppttTqxprsHBkQUewvqbk8LUViJq5fbXL7Q
X-ME-Proxy: <xmx:EeDsakSUrQGMSzqILEWU9-M201_uuJqH7offDNeu06sIkqt1hb5liw>
    <xmx:EeDsavlG7Sn2Zqq6EuvBp6q96Pw4LIe6utKD8IWjLR54yEZbKEGh2A>
    <xmx:EeDsasQjmBB0ufyp7UwXvan4dY-RrGOgiWFSndsuejCNH6alqDMxPw>
    <xmx:EeDsalOgLwApEyvPupuL_fOC3YiieYJCDlNiTbiafu8Auyih28er3w>
    <xmx:EeDsatXowCwmllImiEJ9BNPS3ctL06w0jZ3JdjP5-2KiD-lczNGpAun6>
Feedback-ID: i20964851:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id DC724B6006E; Thu,  5 Nov 2026 14:59:13 -0500 (EST)
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
X-ThreadId: AREQLkp0Btew
Date: Thu, 05 Nov 2026 14:58:53 -0500
From: "Anna Schumaker" <anna@kernel.org>
To: "Mike Snitzer" <snitzer@kernel.org>,
 "Trond Myklebust" <trondmy@kernel.org>
Cc: linux-nfs@vger.kernel.org,
 "Jonathan Flynn" <jonathan.flynn@hammerspace.com>
Message-Id: <b7dc838b-e8aa-4390-8391-ccb4c00fa2fa@app.fastmail.com>
In-Reply-To: <20261102191109.13470-9-snitzer@kernel.org>
References: <20261102191109.13470-1-snitzer@kernel.org>
 <20261102191109.13470-9-snitzer@kernel.org>
Subject: Re: [PATCH 08/11] NFSv4/flexfiles: give each direction its own lock and
 cacheline
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Hi Mike,

On Mon, Nov 2, 2026, at 2:11 PM, Mike Snitzer wrote:
> From: Mike Snitzer <snitzer@hammerspace.com>
>
> struct nfs4_ff_layout_ds_stripe shrinks from 384 bytes to 320, and an
> I/O to a stripe now dirties one cacheline instead of two.  The 384 was
> what "NFSv4/flexfiles: cacheline align the per-stripe layoutstats" had to
> pay to get the array stride line aligned; this gets that back and takes
> another 64 bytes off, on top of removing the last shared lock between the
> two I/O directions.
>
> Cacheline aligning the stripe's lock stopped stripes sharing lines with
> each other, but within a stripe an I/O still dirtied more than one line,
> and reads and writes still serialised on one spinlock.
>
> The set one RPC touches is not the whole guarded region.  A read takes
> the lock, bumps the in-flight count and updates every field of read_stat
> -- bytes_requested and the busy timer on the way out, ops_completed,
> bytes_completed, bytes_not_delivered and the two ktime_t sums on
> completion -- while write_stat stays untouched, and a write is the mirror
> image.  The two directions share nothing but the lock.
>
> So stop sharing the lock.  Move it into struct nfs4_ff_layoutstat,
> alongside the in-flight count and the statistics it guards, and fold
> nfs4_ff_busy_timer in as a bare ktime_t.  With ops_requested derived
> rather than stored, that comes to
>
> 	spinlock_t             lock              4
> 	int                    ops_in_flight     4
> 	struct nfs4_ff_io_stat io_stat          48
> 	ktime_t                busy_start_time   8
>
> which is 64 bytes with no padding.  Align the structure to a cacheline
> and each direction occupies one, exactly.
>
> An I/O now dirties a single line, and a read and a write to the same
> stripe touch neither the same lock nor the same line.  The two reporting
> paths, ff_layout_mirror_prepare_stats() and
> ff_layout_encode_ff_layoutupdate(), take each lock in turn; they need no
> atomicity across the pair, as the statistics are advisory and were never
> sampled atomically with respect to in-flight I/O anyway.
>
> pahole on flexfilelayout.o built with DWARF5, identical on x86_64, arm64
> 4K pages and arm64 64K pages:
>
>   struct nfs4_ff_layoutstat {
>           spinlock_t              lock;             /*    0     4 */
>           int                     ops_in_flight;    /*    4     4 */
>           struct nfs4_ff_io_stat  io_stat;          /*    8    48 */
>           ktime_t                 busy_start_time;  /*   56     8 */
>           /* size: 64, cachelines: 1, members: 4 */
>   } __attribute__((__aligned__(64)));
>
>   ktime_t                    start_time;  /*   136     8 */
>   /* XXX 48 bytes hole */
>   /* --- cacheline 3 boundary (192 bytes) --- */
>   struct nfs4_ff_layoutstat  read_stat;   /*   192    64 */
>   /* --- cacheline 4 boundary (256 bytes) --- */
>   struct nfs4_ff_layoutstat  write_stat;  /*   256    64 */
>   /* size: 320, cachelines: 5 */
>
> start_time stays out of both lines, since it neither fits nor needs to.
> "NFSv4/flexfiles: make dss_info->start_time write-once" removed its
> dependence on any lock, and nothing writes it after the stripe's first
> I/O, so its line never bounces; the same I/O already reads fh_versions,
> stateid and the creds from the lines around it.  In the hole ahead of
> read_stat it is free.
>
> The array stride stays a multiple of 64 and of 128, so stripes remain
> separated on implementations with a 128 byte coherency granule.
>
> Note that CONFIG_DEBUG_SPINLOCK or CONFIG_PROVE_LOCKING fatten spinlock_t
> enough to push nfs4_ff_layoutstat to 128 bytes and the stripe to 448.
> Correctness is unaffected; such kernels simply do not get the packing.
>
> Signed-off-by: Mike Snitzer <snitzer@hammerspace.com>
> ---
>  fs/nfs/flexfilelayout/flexfilelayout.c | 53 ++++++++++++++------------
>  fs/nfs/flexfilelayout/flexfilelayout.h | 46 +++++++++++-----------
>  2 files changed, 52 insertions(+), 47 deletions(-)
>
> diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c 
> b/fs/nfs/flexfilelayout/flexfilelayout.c
> index 846544977cf30..0b8562efabb24 100644
> --- a/fs/nfs/flexfilelayout/flexfilelayout.c
> +++ b/fs/nfs/flexfilelayout/flexfilelayout.c
> @@ -293,7 +293,8 @@ static struct nfs4_ff_layout_mirror 
> *ff_layout_alloc_mirror(u32 dss_count,
>  	}
> 
>  	for (u32 dss_id = 0; dss_id < mirror->dss_count; dss_id++) {
> -		spin_lock_init(&mirror->dss[dss_id].lock);
> +		spin_lock_init(&mirror->dss[dss_id].read_stat.lock);
> +		spin_lock_init(&mirror->dss[dss_id].write_stat.lock);
>  		nfs_localio_file_init(&mirror->dss[dss_id].nfl);
>  	}
> 
> @@ -708,22 +709,22 @@ static u32 calc_dss_id_from_commit(struct 
> pnfs_layout_segment *lseg,
>  }
> 
>  static void
> -nfs4_ff_start_busy_timer(struct nfs4_ff_busy_timer *timer, ktime_t now)
> +nfs4_ff_start_busy_timer(struct nfs4_ff_layoutstat *layoutstat, ktime_t now)
>  {
>  	/* first IO request? */
> -	if (++timer->ops_in_flight == 1)
> -		timer->start_time = now;
> +	if (++layoutstat->ops_in_flight == 1)
> +		layoutstat->busy_start_time = now;
>  }
> 
>  static ktime_t
> -nfs4_ff_end_busy_timer(struct nfs4_ff_busy_timer *timer, ktime_t now)
> +nfs4_ff_end_busy_timer(struct nfs4_ff_layoutstat *layoutstat, ktime_t now)
>  {
>  	ktime_t start;
> 
> -	WARN_ON_ONCE(--timer->ops_in_flight < 0);
> +	WARN_ON_ONCE(--layoutstat->ops_in_flight < 0);
> 
> -	start = timer->start_time;
> -	timer->start_time = now;
> +	start = layoutstat->busy_start_time;
> +	layoutstat->busy_start_time = now;
>  	return ktime_sub(now, start);
>  }
> 
> @@ -761,9 +762,9 @@ nfs4_ff_layoutstat_start_io(struct 
> nfs4_ff_layout_ds_stripe *dss_info,
>  	s64 report_interval = FF_LAYOUTSTATS_REPORT_INTERVAL;
>  	ktime_t last_report;
> 
> -	lockdep_assert_held(&dss_info->lock);
> +	lockdep_assert_held(&layoutstat->lock);
> 
> -	nfs4_ff_start_busy_timer(&layoutstat->busy_timer, now);
> +	nfs4_ff_start_busy_timer(layoutstat, now);
>  	layoutstat->io_stat.bytes_requested += requested;
> 
>  	nfs4_ff_layoutstat_set_start_time(dss_info, now);
> @@ -801,13 +802,13 @@ nfs4_ff_layoutstat_end_io(struct 
> nfs4_ff_layout_ds_stripe *dss_info,
>  	ktime_t completion_time = ktime_sub(time_completed, time_started);
>  	ktime_t timer;
> 
> -	lockdep_assert_held(&dss_info->lock);
> +	lockdep_assert_held(&layoutstat->lock);
> 
>  	iostat->ops_completed++;
>  	iostat->bytes_completed += completed;
>  	iostat->bytes_not_delivered += requested - completed;
> 
> -	timer = nfs4_ff_end_busy_timer(&layoutstat->busy_timer, time_completed);
> +	timer = nfs4_ff_end_busy_timer(layoutstat, time_completed);
>  	iostat->total_busy_time =
>  			ktime_add(iostat->total_busy_time, timer);
>  	iostat->aggregate_completion_time =
> @@ -824,10 +825,10 @@ nfs4_ff_layout_stat_io_start_read(struct inode *inode,
>  	struct nfs4_ff_layout_ds_stripe *dss_info = &mirror->dss[dss_id];
>  	bool report;
> 
> -	spin_lock(&dss_info->lock);
> +	spin_lock(&dss_info->read_stat.lock);
>  	report = nfs4_ff_layoutstat_start_io(dss_info, &dss_info->read_stat,
>  					     requested, now);
> -	spin_unlock(&dss_info->lock);
> +	spin_unlock(&dss_info->read_stat.lock);
>  	set_bit(NFS4_FF_MIRROR_STAT_AVAIL, &mirror->flags);
> 
>  	if (report)
> @@ -843,11 +844,11 @@ nfs4_ff_layout_stat_io_end_read(struct rpc_task *task,
>  {
>  	struct nfs4_ff_layout_ds_stripe *dss_info = &mirror->dss[dss_id];
> 
> -	spin_lock(&dss_info->lock);
> +	spin_lock(&dss_info->read_stat.lock);
>  	nfs4_ff_layoutstat_end_io(dss_info, &dss_info->read_stat,
>  				  requested, completed,
>  				  ktime_get(), task->tk_start);
> -	spin_unlock(&dss_info->lock);
> +	spin_unlock(&dss_info->read_stat.lock);
>  	set_bit(NFS4_FF_MIRROR_STAT_AVAIL, &mirror->flags);
>  }
> 
> @@ -860,10 +861,10 @@ nfs4_ff_layout_stat_io_start_write(struct inode *inode,
>  	struct nfs4_ff_layout_ds_stripe *dss_info = &mirror->dss[dss_id];
>  	bool report;
> 
> -	spin_lock(&dss_info->lock);
> +	spin_lock(&dss_info->write_stat.lock);
>  	report = nfs4_ff_layoutstat_start_io(dss_info, &dss_info->write_stat,
>  					     requested, now);
> -	spin_unlock(&dss_info->lock);
> +	spin_unlock(&dss_info->write_stat.lock);
>  	set_bit(NFS4_FF_MIRROR_STAT_AVAIL, &mirror->flags);
> 
>  	if (report)
> @@ -883,11 +884,11 @@ nfs4_ff_layout_stat_io_end_write(struct rpc_task *task,
>  	if (committed == NFS_UNSTABLE)
>  		requested = completed = 0;
> 
> -	spin_lock(&dss_info->lock);
> +	spin_lock(&dss_info->write_stat.lock);
>  	nfs4_ff_layoutstat_end_io(dss_info, &dss_info->write_stat,
>  				  requested, completed,
>  				  ktime_get(), task->tk_start);
> -	spin_unlock(&dss_info->lock);
> +	spin_unlock(&dss_info->write_stat.lock);
>  	set_bit(NFS4_FF_MIRROR_STAT_AVAIL, &mirror->flags);
>  }
> 
> @@ -3100,11 +3101,13 @@ ff_layout_encode_ff_layoutupdate(struct 
> xdr_stream *xdr,
>  	p = xdr_reserve_space(xdr, 4 + fh->size);
>  	xdr_encode_opaque(p, fh->data, fh->size);
>  	/* ff_io_latency4 read */
> -	spin_lock(&dss_info->lock);
> +	spin_lock(&dss_info->read_stat.lock);
>  	ff_layout_encode_io_latency(xdr, &dss_info->read_stat);
> +	spin_unlock(&dss_info->read_stat.lock);
>  	/* ff_io_latency4 write */
> +	spin_lock(&dss_info->write_stat.lock);
>  	ff_layout_encode_io_latency(xdr, &dss_info->write_stat);
> -	spin_unlock(&dss_info->lock);
> +	spin_unlock(&dss_info->write_stat.lock);
>  	/* nfstime4 */
>  	ff_layout_encode_nfstime(xdr,
>  				 ktime_sub(ktime_get(),
> @@ -3180,16 +3183,18 @@ ff_layout_mirror_prepare_stats(struct 
> pnfs_layout_hdr *lo,
>  			       NFS4_DEVICEID4_SIZE);
>  			devinfo->offset = 0;
>  			devinfo->length = NFS4_MAX_UINT64;
> -			spin_lock(&dss_info->lock);
> +			spin_lock(&dss_info->read_stat.lock);
>  			devinfo->read_count =
>  			    dss_info->read_stat.io_stat.ops_completed;
>  			devinfo->read_bytes =
>  			    dss_info->read_stat.io_stat.bytes_completed;
> +			spin_unlock(&dss_info->read_stat.lock);
> +			spin_lock(&dss_info->write_stat.lock);
>  			devinfo->write_count =
>  			    dss_info->write_stat.io_stat.ops_completed;
>  			devinfo->write_bytes =
>  			    dss_info->write_stat.io_stat.bytes_completed;
> -			spin_unlock(&dss_info->lock);
> +			spin_unlock(&dss_info->write_stat.lock);
>  			devinfo->layout_type = LAYOUT_FLEX_FILES;
>  			devinfo->ld_private.ops = &layoutstat_ops;
>  			priv->dss_info = dss_info;
> diff --git a/fs/nfs/flexfilelayout/flexfilelayout.h 
> b/fs/nfs/flexfilelayout/flexfilelayout.h
> index 23f665fef4985..876fdb6999473 100644
> --- a/fs/nfs/flexfilelayout/flexfilelayout.h
> +++ b/fs/nfs/flexfilelayout/flexfilelayout.h
> @@ -64,18 +64,22 @@ struct nfs4_ff_io_stat {
>  };
> 
>  /*
> - * Both members are serialised by the enclosing stripe's
> - * nfs4_ff_layout_ds_stripe::lock; see nfs4_ff_{start,end}_busy_timer().
> + * One direction's statistics for one stripe, with the lock that guards them.
> + *
> + * Exactly one cacheline, and aligned to one, so that an I/O dirties a single
> + * line: the lock, the in-flight count and every counter it touches are all in
> + * here, and the other direction's copy is in a line of its own.  Adding to
> + * this structure, or letting CONFIG_DEBUG_SPINLOCK or CONFIG_PROVE_LOCKING
> + * fatten spinlock_t, spills it into a second line.

Let's leave the cacheline talk to the commit message and not in the code.

>   */
> -struct nfs4_ff_busy_timer {
> -	ktime_t start_time;
> -	int ops_in_flight;
> -};
> -
>  struct nfs4_ff_layoutstat {
> -	struct nfs4_ff_io_stat io_stat;
> -	struct nfs4_ff_busy_timer busy_timer;
> -};
> +	/* Protects every other member of this structure */
> +	spinlock_t			lock;
> +	int				ops_in_flight;
> +	struct nfs4_ff_io_stat		io_stat;
> +	/* Start of the interval io_stat.total_busy_time accrues */
> +	ktime_t				busy_start_time;
> +} ____cacheline_aligned_in_smp;
> 
>  /*
>   * ffil_ops_requested is not stored.  An op is in flight from the moment it is
> @@ -91,8 +95,7 @@ struct nfs4_ff_layoutstat {
>  static inline __u64
>  nfs4_ff_ops_requested(const struct nfs4_ff_layoutstat *layoutstat)
>  {
> -	return layoutstat->io_stat.ops_completed +
> -	       layoutstat->busy_timer.ops_in_flight;
> +	return layoutstat->io_stat.ops_completed + layoutstat->ops_in_flight;
>  }
> 
>  struct nfs4_ff_layout_mirror;
> @@ -108,21 +111,18 @@ struct nfs4_ff_layout_ds_stripe {
>  	const struct cred __rcu		*ro_cred;
>  	const struct cred __rcu		*rw_cred;
>  	struct nfs_file_localio		nfl;
> +	/* Published once by the first I/O; see nfs4_ff_layoutstat_set_start_time() */
> +	ktime_t				start_time;
>  	/*
> -	 * Protects read_stat and write_stat below.
> -	 *
> -	 * Cacheline aligned so that the layoutstats accounting done on
> -	 * every I/O to this stripe does not share cachelines with the
> -	 * read-mostly members above, nor with the neighbouring stripes
> -	 * in mirror->dss[]: aligning the first member of the guarded
> -	 * set also rounds sizeof() up to a multiple of the cacheline,
> -	 * which is what makes the array stride line-aligned.
> +	 * A line each, and each carrying its own lock, so that a read and a
> +	 * write to this stripe neither serialise against each other nor
> +	 * share a line.  Their alignment also rounds this structure's
> +	 * sizeof() up to a multiple of the cacheline, which is what keeps
> +	 * the mirror->dss[] stride line-aligned and so stops stripe i
> +	 * sharing a line with stripe i+1.

Same here.

Anna

>  	 */
> -	spinlock_t			lock ____cacheline_aligned_in_smp;
>  	struct nfs4_ff_layoutstat	read_stat;
>  	struct nfs4_ff_layoutstat	write_stat;
> -	/* Published once by the first I/O; see nfs4_ff_layoutstat_set_start_time() */
> -	ktime_t				start_time;
>  };
> 
>  struct nfs4_ff_layout_mirror {
> -- 
> 2.52.0
