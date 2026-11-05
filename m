Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793895187;
	b=3faaiD7HMRj3vdEuSUaRSEYtKXlrbL4THm6u0uRHam1PK02cQHnBmR2rQCbILG9T5dpm
	 W1ood/AjwspffcDHEk5zjKTPTLnxwmXBT39BM0TTOrmit3etv7qI6KAvxdwYwcdkKChgp
	 t8+r4qkSL+Ew+Ek2996Pd/ZxmO45Ho183cUC9SkR21JRk2TVKIBPRuPoUgFEbC4mu7G6v
	 70VmZXMkDFulgaYYYjriY5jNV8vlNzsOoCp9jLkjsMnmWTQprY9N3+Ps0cqFvn9UcAojn
	 HG31X6fPNuKVF9T5Se95/K4QQo7pUk7JKNuev3viJJXeMgux5vJtvz/QEcc0Yc7sB4Q==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793895187;
	h=Received:DKIM-Signature:Received:Received:X-ME-Sender:
	 X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:X-Mailer:
	 MIME-Version:X-ThreadId:Date:From:To:Cc:Message-Id:In-Reply-To:
	 References:Subject:Content-Type:Content-Transfer-Encoding;
	bh=q+hbVqD4O0/kasa0jxmVDi4OJuXSVItCGCxrwrEGgis=;
	b=iF9dTMtsQNUXWmwFiC47mLThJCUmTa9eYVmxwoYYekIcmAzee482eQmfCf7RE5Uo1+PW
	 Q2OqFE+P6i9OdROddUcaVQVvQ5Z72le6SfiacyF/0z/b0Jtk1rOdUyveSEhUtwMCpKnGH
	 +4rqS4XCpOLFyYimmFh7439pegz4RUUk2sSLwkT6YcAYAB51uyOXBNrVudxI5ugBZvjBm
	 pL5YBeCQBn02Nbo4n04QGQRWDVij09ebxg3LZeB/SkrL9vYQxZCa1ja6GsoSrb1keWXXU
	 ujG81mlf9FyjhqzhwcHHifklASy3VWhgkboYNLUbynwyBYFZxORoKCUDdIBK4VqhKEg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=DMt8Se4H;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 39A98606A32C
	for <linux-nfs@vger.kernel.org>; Thu,  5 Nov 2026 16:13:07 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=DMt8Se4H
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C50B61F00A02;
	Thu,  5 Nov 2026 16:13:06 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793895187;
	bh=q+hbVqD4O0/kasa0jxmVDi4OJuXSVItCGCxrwrEGgis=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=DMt8Se4HzdoLSpbWX/LcwTuv9i+knnDCZRWyNQNVs2zF1K5KmXuHIlJjcYYj21kP9
	 iGxdu5h/mkCwA46zkwYhACpg5F+xx8PP/lZR3vsIYGWP6IOHzEGxqhQfBN7aPG3Ddc
	 FL0y2gmv5ofQskpy12OFGxfNmhgq2/UkCdi326FujVGRzdVlkZEe2nemfak5DXVbAq
	 bOloPwJafz4CWbfwzBOxW1CSAlEXwAVz9ApOhgSDoGPVJ9hB7jRaF+WU+m/EVALMVU
	 s9G3zq1iUp9XRk82LcIyhux0n/off/srzxxILrRgHTsu/D0+NkXTaS3G6jKHY04Rvl
	 hZOrnJXCCLXRg==
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailfauth.phl.internal (Postfix) with ESMTP id 1C394F40066;
	Thu,  5 Nov 2026 11:13:06 -0500 (EST)
Received: from phl-imap-04 ([10.202.2.82])
  by phl-compute-02.internal (MEProxy); Thu, 05 Nov 2026 11:13:06 -0500
X-ME-Sender: <xms:EqvsavbtXZkYonQ-B_4g5tMOZQQzF4Rr1HXLBLC4I1etxkpy7jTe2Q>
    <xme:EqvsapMpID9YOpAJ3WB8b5hgJ45nyz9NS9RHbP_yBoGD0uYcCEEb86zc_2PBV5MhW
    oARh-x36gVkwcawuCkEC5X2iiAlSCBiuvTyN6PR55LyaU6rINVCGbgB>
X-ME-Proxy-Cause: dmFkZTEh7u2rjWKtJffJI+h+pn/eJsWKJugp6xbj7Ctk+KG6R/qZXpctH+cmxWi2/LJ2Bs
    vUjVZUuZ45WNGvtKsypjqg+YP+8hLnTM4ZFGLwQVRHL+DPcQ8NQl4oDY8tDuA7DRYFjdPq
    59aPm7cov7memHeL0sKNkYq6cXQG0gTA+QGzbYmPt4565AOGkWoJHL6NaQJKQ5iUXa5iOy
    ibA+onbvv4S6YUJxucd8udeoB8gbsun3rx9eAczBc0nzi3aF6WgWhO5i0RlI3pO8hycqnG
    FIRgV+hb+Vtqw4AnBR9uRQ5aBgSkIhMp8TEefCic15uMgLYeFRJawbJJbExXD7DfqjNyi2
    WyWpLSpW3jLwjNYqw0yR976J1vau7eThbRpdQWp3oG4hy6tWu06SXF7GfS+X/BX4seeXKr
    vpfcj0FNcELVXuQDmI6I4cJiZeD2LqFVqYg7v73h6jDHTdCAfP07JyLHgUTz4tVbQp+iPm
    YcRZ0RNJADs1IM06TY09pqRMZ7UMPnieIsaamKveNT7NtPBatez+3Nv5VinYORyHefhkJI
    79GzVGJiPBXAKVxb+0VWoBaryE1QR2aB+hZUjjN6oPEvkLCXbJyeSJI5UdTj+t+Lgf8Lfx
    gvwm+y7cRp7yPyzDmrLLWDvhdw6a1PAIDQw01pSNdHCotP5i9LH6yEvEqX7A
X-ME-Proxy: <xmx:EqvsakBzkYZA7UHWuHryZF44oRf12zUMnOocuWtYlnNpbXGQEXF6KA>
    <xmx:EqvsakWgmZGuys3FPTpzh6p3K2Wz9d-P6w25TuHZieEMl2Y2TYo1AQ>
    <xmx:EqvsaiBxREetMuiUv7kLQ3yRdoaBRTOpVYXlFj05GlMvWtW4TlqEMg>
    <xmx:Eqvsan843S114ZMfdXLO-LERUrL8-MLIcPNq1MpvfdB02fNfhfEl8A>
    <xmx:EqvsapE78gaRToW9wprJlYCBy5wrcj_pvVM5P9lQw9N2NDPOIrKTFDUI>
Feedback-ID: i20964851:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id F4072B6006E; Thu,  5 Nov 2026 11:13:05 -0500 (EST)
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
X-ThreadId: ACdRCq9gKPqs
Date: Thu, 05 Nov 2026 11:12:44 -0500
From: "Anna Schumaker" <anna@kernel.org>
To: "Mike Snitzer" <snitzer@kernel.org>,
 "Trond Myklebust" <trondmy@kernel.org>
Cc: linux-nfs@vger.kernel.org,
 "Jonathan Flynn" <jonathan.flynn@hammerspace.com>
Message-Id: <6fe7924c-dbd8-4121-a467-4645855b58ea@app.fastmail.com>
In-Reply-To: <20261102191109.13470-2-snitzer@kernel.org>
References: <20261102191109.13470-1-snitzer@kernel.org>
 <20261102191109.13470-2-snitzer@kernel.org>
Subject: Re: [PATCH 01/11] NFSv4/flexfiles: move layoutstats accounting to a per-stripe
 lock
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Hi Mike,

On Mon, Nov 2, 2026, at 2:10 PM, Mike Snitzer wrote:
> From: Jonathan Flynn <jonathan.flynn@hammerspace.com>
>
> Since striped layouts were introduced, a mirror owns an array of
> struct nfs4_ff_layout_ds_stripe and each stripe carries its own
> read_stat and write_stat.  The lock protecting those statistics stayed
> behind in the mirror, so every DS RPC in the layout serialises on the
> same spinlock twice: once in ff_layout_{read,write}_prepare_common()
> and again on completion in ff_layout_{read,write}_count_stats().
>
> For a RAID0-style layout (one mirror, many stripes) that lock is
> effectively per-file, and striping then multiplies RPC parallelism
> without multiplying lock parallelism.
>
> On a 64-core client reading a single file from a 32-stripe layout with
> a 128KiB stripe unit (2MB O_DIRECT reads, ~36.7 GB/s, ~275k NFSv3 READ
> RPCs/s, i.e. ~550k acquisitions/s of one lock), perf reports 45% of all
> CPU in native_queued_spin_lock_slowpath, and lock:contention_begin
> attributes 73% of the contention events to the two layoutstats paths:
>
>   36.4%  rpc_exit_task -> ff_layout_read_count_stats ->
>          ff_layout_read_record_layoutstats_done -> _raw_spin_lock
>   36.3%  ff_layout_read_prepare_v3 ->
>          ff_layout_read_record_layoutstats_start -> _raw_spin_lock
>
> Move the lock into struct nfs4_ff_layout_ds_stripe, next to the
> statistics it protects, so that I/O to different stripes no longer
> contends.  The reporting paths take the same per-stripe lock.
>
> NFS4_FF_MIRROR_STAT_AVAIL is a mirror-wide bit operation and does not
> need the lock; set it outside the critical section so the mirror's
> cacheline is not written under it.
>
> ffl->last_report_time is shared by every mirror and stripe of a layout
> and was already updated under different mirror locks, so it was never
> serialised.  Make that explicit with a cmpxchg(): whichever racer wins
> sends the LAYOUTSTATS report.
>
> Signed-off-by: Jonathan Flynn <jonathan.flynn@hammerspace.com>
> Signed-off-by: Mike Snitzer <snitzer@hammerspace.com>
> ---
>  fs/nfs/flexfilelayout/flexfilelayout.c | 45 +++++++++++++++-----------
>  fs/nfs/flexfilelayout/flexfilelayout.h |  2 ++
>  2 files changed, 28 insertions(+), 19 deletions(-)
>
> diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c 
> b/fs/nfs/flexfilelayout/flexfilelayout.c
> index 9492d6bc1d1a7..bac0b7f559201 100644
> --- a/fs/nfs/flexfilelayout/flexfilelayout.c
> +++ b/fs/nfs/flexfilelayout/flexfilelayout.c
> @@ -293,8 +293,10 @@ static struct nfs4_ff_layout_mirror 
> *ff_layout_alloc_mirror(u32 dss_count,
>  		return NULL;
>  	}
> 
> -	for (u32 dss_id = 0; dss_id < mirror->dss_count; dss_id++)
> +	for (u32 dss_id = 0; dss_id < mirror->dss_count; dss_id++) {
> +		spin_lock_init(&mirror->dss[dss_id].lock);
>  		nfs_localio_file_init(&mirror->dss[dss_id].nfl);
> +	}
> 
>  	return mirror;
>  }
> @@ -736,6 +738,7 @@ nfs4_ff_layoutstat_start_io(struct 
> nfs4_ff_layout_mirror *mirror,
>  {
>  	s64 report_interval = FF_LAYOUTSTATS_REPORT_INTERVAL;
>  	struct nfs4_flexfile_layout *ffl = FF_LAYOUT_FROM_HDR(mirror->layout);
> +	ktime_t last_report;
> 
>  	nfs4_ff_start_busy_timer(&layoutstat->busy_timer, now);
>  	if (!mirror->dss[dss_id].start_time)
> @@ -744,13 +747,17 @@ nfs4_ff_layoutstat_start_io(struct 
> nfs4_ff_layout_mirror *mirror,
>  		report_interval = (s64)mirror->report_interval * 1000LL;
>  	else if (layoutstats_timer != 0)
>  		report_interval = (s64)layoutstats_timer * 1000LL;
> -	if (ktime_to_ms(ktime_sub(now, ffl->last_report_time)) >=
> -			report_interval) {
> -		ffl->last_report_time = now;
> -		return true;
> -	}
> 
> -	return false;
> +	/*
> +	 * last_report_time is shared by every mirror and stripe of this
> +	 * layout, so it was never serialised by the mirror lock either.
> +	 * Make that explicit: whoever wins the cmpxchg() reports.
> +	 */
> +	last_report = READ_ONCE(ffl->last_report_time);
> +	if (ktime_to_ms(ktime_sub(now, last_report)) < report_interval)
> +		return false;
> +
> +	return try_cmpxchg64(&ffl->last_report_time, &last_report, now);

As far as I can tell, this is the first use of try_cmpxchg64 in any filesystem
code. This has me worried it's the wrong function to be calling here. Is there
any reason we can't use atomic64_try_cmpxchg(), which is what I see being used
by other filesystem code?

Thanks,
Anna

>  }
> 
>  static void
> @@ -794,13 +801,13 @@ nfs4_ff_layout_stat_io_start_read(struct inode *inode,
>  {
>  	bool report;
> 
> -	spin_lock(&mirror->lock);
> +	spin_lock(&mirror->dss[dss_id].lock);
>  	report = nfs4_ff_layoutstat_start_io(
>  		mirror, dss_id, &mirror->dss[dss_id].read_stat, now);
>  	nfs4_ff_layout_stat_io_update_requested(
>  		&mirror->dss[dss_id].read_stat, requested);
> +	spin_unlock(&mirror->dss[dss_id].lock);
>  	set_bit(NFS4_FF_MIRROR_STAT_AVAIL, &mirror->flags);
> -	spin_unlock(&mirror->lock);
> 
>  	if (report)
>  		pnfs_report_layoutstat(inode, nfs_io_gfp_mask());
> @@ -813,12 +820,12 @@ nfs4_ff_layout_stat_io_end_read(struct rpc_task *task,
>  		__u64 requested,
>  		__u64 completed)
>  {
> -	spin_lock(&mirror->lock);
> +	spin_lock(&mirror->dss[dss_id].lock);
>  	nfs4_ff_layout_stat_io_update_completed(&mirror->dss[dss_id].read_stat,
>  			requested, completed,
>  			ktime_get(), task->tk_start);
> +	spin_unlock(&mirror->dss[dss_id].lock);
>  	set_bit(NFS4_FF_MIRROR_STAT_AVAIL, &mirror->flags);
> -	spin_unlock(&mirror->lock);
>  }
> 
>  static void
> @@ -829,7 +836,7 @@ nfs4_ff_layout_stat_io_start_write(struct inode *inode,
>  {
>  	bool report;
> 
> -	spin_lock(&mirror->lock);
> +	spin_lock(&mirror->dss[dss_id].lock);
>  	report = nfs4_ff_layoutstat_start_io(
>  		mirror,
>  		dss_id,
> @@ -838,8 +845,8 @@ nfs4_ff_layout_stat_io_start_write(struct inode *inode,
>  	nfs4_ff_layout_stat_io_update_requested(
>  		&mirror->dss[dss_id].write_stat,
>  		requested);
> +	spin_unlock(&mirror->dss[dss_id].lock);
>  	set_bit(NFS4_FF_MIRROR_STAT_AVAIL, &mirror->flags);
> -	spin_unlock(&mirror->lock);
> 
>  	if (report)
>  		pnfs_report_layoutstat(inode, nfs_io_gfp_mask());
> @@ -856,11 +863,11 @@ nfs4_ff_layout_stat_io_end_write(struct rpc_task *task,
>  	if (committed == NFS_UNSTABLE)
>  		requested = completed = 0;
> 
> -	spin_lock(&mirror->lock);
> +	spin_lock(&mirror->dss[dss_id].lock);
>  	nfs4_ff_layout_stat_io_update_completed(&mirror->dss[dss_id].write_stat,
>  			requested, completed, ktime_get(), task->tk_start);
> +	spin_unlock(&mirror->dss[dss_id].lock);
>  	set_bit(NFS4_FF_MIRROR_STAT_AVAIL, &mirror->flags);
> -	spin_unlock(&mirror->lock);
>  }
> 
>  static struct nfs4_ff_layout_ds *
> @@ -3071,13 +3078,13 @@ ff_layout_encode_ff_layoutupdate(struct 
> xdr_stream *xdr,
>  	p = xdr_reserve_space(xdr, 4 + fh->size);
>  	xdr_encode_opaque(p, fh->data, fh->size);
>  	/* ff_io_latency4 read */
> -	spin_lock(&dss_info->mirror->lock);
> +	spin_lock(&dss_info->lock);
>  	ff_layout_encode_io_latency(xdr,
>  				    &dss_info->read_stat.io_stat);
>  	/* ff_io_latency4 write */
>  	ff_layout_encode_io_latency(xdr,
>  				    &dss_info->write_stat.io_stat);
> -	spin_unlock(&dss_info->mirror->lock);
> +	spin_unlock(&dss_info->lock);
>  	/* nfstime4 */
>  	ff_layout_encode_nfstime(xdr,
>  				 ktime_sub(ktime_get(),
> @@ -3153,7 +3160,7 @@ ff_layout_mirror_prepare_stats(struct 
> pnfs_layout_hdr *lo,
>  			       NFS4_DEVICEID4_SIZE);
>  			devinfo->offset = 0;
>  			devinfo->length = NFS4_MAX_UINT64;
> -			spin_lock(&mirror->lock);
> +			spin_lock(&dss_info->lock);
>  			devinfo->read_count =
>  			    dss_info->read_stat.io_stat.ops_completed;
>  			devinfo->read_bytes =
> @@ -3162,7 +3169,7 @@ ff_layout_mirror_prepare_stats(struct 
> pnfs_layout_hdr *lo,
>  			    dss_info->write_stat.io_stat.ops_completed;
>  			devinfo->write_bytes =
>  			    dss_info->write_stat.io_stat.bytes_completed;
> -			spin_unlock(&mirror->lock);
> +			spin_unlock(&dss_info->lock);
>  			devinfo->layout_type = LAYOUT_FLEX_FILES;
>  			devinfo->ld_private.ops = &layoutstat_ops;
>  			priv->dss_info = dss_info;
> diff --git a/fs/nfs/flexfilelayout/flexfilelayout.h 
> b/fs/nfs/flexfilelayout/flexfilelayout.h
> index 09c3cd6964fd6..54aa492bc0bac 100644
> --- a/fs/nfs/flexfilelayout/flexfilelayout.h
> +++ b/fs/nfs/flexfilelayout/flexfilelayout.h
> @@ -86,6 +86,8 @@ struct nfs4_ff_layout_ds_stripe {
>  	const struct cred __rcu		*ro_cred;
>  	const struct cred __rcu		*rw_cred;
>  	struct nfs_file_localio		nfl;
> +	/* Protects read_stat, write_stat and start_time below */
> +	spinlock_t			lock;
>  	struct nfs4_ff_layoutstat	read_stat;
>  	struct nfs4_ff_layoutstat	write_stat;
>  	ktime_t				start_time;
> -- 
> 2.52.0
