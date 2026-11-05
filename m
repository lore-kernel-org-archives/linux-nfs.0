Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793913573;
	b=wc7+Ohn8/oTztnAZjV/pr/vUxDZuJ//9N1CUYL+pmMhJP2bNiOso4wiyga17c+9f7QJu
	 fCHLoJLjHWGr6/7FIbl30DHLx5hOvCiG5tu9/bmecpFe3I6HTm/Eoa4GDyMopfsomjyj1
	 dsdBu2h15Q+EVuEG+nExEbV3xlbkiOLSH9P/5WEgmtOjXPgYJbvDQ1zBAKblflmRgZ+E4
	 QO7udyndPAbDHQXo1x2mZFFNGordGvMeCoFRmEMvHVG/YxraCFc03KUamwLesta22zGDQ
	 LaE4MThqcv9uE4CJJfB4DLtVjQhU7ya2o9TzV/UolSkK+cW9GEBGBB5uaRlbp4uEmjQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793913573;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To;
	bh=ad0K9MxXeRoXa7eArWOLsAmwLaFZowA1m9nSCEjlJh0=;
	b=jdoFDoaNsgLmsuqmyWc3dirbmOW/A3mElwbzglPS6MpGDGdPlpuDjlecgCGNwjosX0Ha
	 +tRVhQ3Ut73Gz+GKh7DOI7IU5XAPoPJqnG/dk1VE7o+entOv4TkthI/bXQIQd3Cc59a2I
	 f/KTZ4AvyCobz9EgQrnnHA78bPdsKVfokdsdJDjNfDW7Cg22k/j9TWnReeCcEQSyl55ST
	 D1Sp/AqOzeyBE8yPD6vTOoxS6q3DnGTMCcpOhWPyM6g9iF1iQsGoU6Aly0JOBc9lfSo/W
	 uz6h4r1TSUms6F23p6YOEk7owYvb4WKbe4OPyma64GaxJ/oII1Ihx41HRdCb7TBqTgQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=E2WjA3gq;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 39C20606A329
	for <linux-nfs@vger.kernel.org>; Thu,  5 Nov 2026 21:19:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=E2WjA3gq
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 0D4891F008A1;
	Thu,  5 Nov 2026 21:19:31 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793913572;
	bh=ad0K9MxXeRoXa7eArWOLsAmwLaFZowA1m9nSCEjlJh0=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=E2WjA3gqGE16LI3kFIAglokCZGlQjrEBKNgncatr4JcoLuyBgg/d8gx3ZJwV66Edg
	 nR/GPdohx5Of1Aojn8CtGxvJ7OC5fvxBrq/SbyWttm6J74BBZKy0mNYcqQC6YJKMC0
	 k8TOM7JUTi09crHEuWyGRzUnT2ZDKuzBS9bQgAxoTa66exjVxsZlWiHx9YCbz5f7wF
	 XFgk4nAvCrhbSvI+sXfHgBvBwvFKp4vpC/PW5NSKxG00kAlHqF3MFA6lAiqfqDQHj4
	 HXy9qRxYd9YOpiY56ERFqiVdDFpXPFR6pFnQA0AREUp4TgJTh2c0reazxr7b2G9PHK
	 TANOI9lBEWxKw==
Date: Thu, 5 Nov 2026 16:19:31 -0500
From: Mike Snitzer <snitzer@kernel.org>
To: Anna Schumaker <anna@kernel.org>
Cc: Trond Myklebust <trondmy@kernel.org>, linux-nfs@vger.kernel.org,
	Jonathan Flynn <jonathan.flynn@hammerspace.com>
Subject: Re: [PATCH 01/11] NFSv4/flexfiles: move layoutstats accounting to a
 per-stripe lock
Message-ID: <auzy4-viIAkPoUVA@kernel.org>
References: <20261102191109.13470-1-snitzer@kernel.org>
 <20261102191109.13470-2-snitzer@kernel.org>
 <6fe7924c-dbd8-4121-a467-4645855b58ea@app.fastmail.com>
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
In-Reply-To: <6fe7924c-dbd8-4121-a467-4645855b58ea@app.fastmail.com>

On Thu, Nov 05, 2026 at 11:12:44AM -0500, Anna Schumaker wrote:
> Hi Mike,
> 
> On Mon, Nov 2, 2026, at 2:10 PM, Mike Snitzer wrote:
> > From: Jonathan Flynn <jonathan.flynn@hammerspace.com>
> >
> > Since striped layouts were introduced, a mirror owns an array of
> > struct nfs4_ff_layout_ds_stripe and each stripe carries its own
> > read_stat and write_stat.  The lock protecting those statistics stayed
> > behind in the mirror, so every DS RPC in the layout serialises on the
> > same spinlock twice: once in ff_layout_{read,write}_prepare_common()
> > and again on completion in ff_layout_{read,write}_count_stats().
> >
> > For a RAID0-style layout (one mirror, many stripes) that lock is
> > effectively per-file, and striping then multiplies RPC parallelism
> > without multiplying lock parallelism.
> >
> > On a 64-core client reading a single file from a 32-stripe layout with
> > a 128KiB stripe unit (2MB O_DIRECT reads, ~36.7 GB/s, ~275k NFSv3 READ
> > RPCs/s, i.e. ~550k acquisitions/s of one lock), perf reports 45% of all
> > CPU in native_queued_spin_lock_slowpath, and lock:contention_begin
> > attributes 73% of the contention events to the two layoutstats paths:
> >
> >   36.4%  rpc_exit_task -> ff_layout_read_count_stats ->
> >          ff_layout_read_record_layoutstats_done -> _raw_spin_lock
> >   36.3%  ff_layout_read_prepare_v3 ->
> >          ff_layout_read_record_layoutstats_start -> _raw_spin_lock
> >
> > Move the lock into struct nfs4_ff_layout_ds_stripe, next to the
> > statistics it protects, so that I/O to different stripes no longer
> > contends.  The reporting paths take the same per-stripe lock.
> >
> > NFS4_FF_MIRROR_STAT_AVAIL is a mirror-wide bit operation and does not
> > need the lock; set it outside the critical section so the mirror's
> > cacheline is not written under it.
> >
> > ffl->last_report_time is shared by every mirror and stripe of a layout
> > and was already updated under different mirror locks, so it was never
> > serialised.  Make that explicit with a cmpxchg(): whichever racer wins
> > sends the LAYOUTSTATS report.
> >
> > Signed-off-by: Jonathan Flynn <jonathan.flynn@hammerspace.com>
> > Signed-off-by: Mike Snitzer <snitzer@hammerspace.com>
> > ---
> >  fs/nfs/flexfilelayout/flexfilelayout.c | 45 +++++++++++++++-----------
> >  fs/nfs/flexfilelayout/flexfilelayout.h |  2 ++
> >  2 files changed, 28 insertions(+), 19 deletions(-)
> >
> > diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c 
> > b/fs/nfs/flexfilelayout/flexfilelayout.c
> > index 9492d6bc1d1a7..bac0b7f559201 100644
> > --- a/fs/nfs/flexfilelayout/flexfilelayout.c
> > +++ b/fs/nfs/flexfilelayout/flexfilelayout.c
> > @@ -744,13 +747,17 @@ nfs4_ff_layoutstat_start_io(struct 
> > nfs4_ff_layout_mirror *mirror,
> >  		report_interval = (s64)mirror->report_interval * 1000LL;
> >  	else if (layoutstats_timer != 0)
> >  		report_interval = (s64)layoutstats_timer * 1000LL;
> > -	if (ktime_to_ms(ktime_sub(now, ffl->last_report_time)) >=
> > -			report_interval) {
> > -		ffl->last_report_time = now;
> > -		return true;
> > -	}
> > 
> > -	return false;
> > +	/*
> > +	 * last_report_time is shared by every mirror and stripe of this
> > +	 * layout, so it was never serialised by the mirror lock either.
> > +	 * Make that explicit: whoever wins the cmpxchg() reports.
> > +	 */
> > +	last_report = READ_ONCE(ffl->last_report_time);
> > +	if (ktime_to_ms(ktime_sub(now, last_report)) < report_interval)
> > +		return false;
> > +
> > +	return try_cmpxchg64(&ffl->last_report_time, &last_report, now);
> 
> As far as I can tell, this is the first use of try_cmpxchg64 in any filesystem
> code. This has me worried it's the wrong function to be calling here. Is there
> any reason we can't use atomic64_try_cmpxchg(), which is what I see being used
> by other filesystem code?

Not seeing any other caller of atomic64_try_cmpxchg() that isn't using
atomic64_t.

nfs4_flexfile_layout's last_report_time datatype is s64 (ktime_t), not
atomic64_t.

Later in this series nfs4_ff_layoutstat_set_start_time() also uses it
with nfs4_ff_layout_mirror's start_time.
