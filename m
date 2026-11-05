Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793909878;
	b=sBrzEwKSrQ4nre3nnE3oW5CPR3Cb3qAUj12QsXSvS8CtTOTf4GrnXTW1XhV0xr4t1u8M
	 X5Xf3RCCF+aAZ7EgD4SVdWvQnCTOU2LkrqY9mMfGd//fZKE/QY5Q8+hPzWfH0+0SmeEag
	 HPeLw8ioSq37PJDcjbVeT9cZ80CbG1TpcJGJC31a8MtmYS8UmAmEDRxuXYT6q4RVwMi7b
	 c7/Gn4gN+SpH2WyIrS+caRWLR4MQ5+U5rSwkrWjBg/3mIZsyDyIO1CByFCBYqTgMQ1By5
	 gheECu58jF8ZgKqUHpfNkLC0/o/hEcDM48/fB92aKzN0aW8+pz37Js0egJodSGpCGXA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793909878;
	h=Received:DKIM-Signature:Received:Received:X-ME-Sender:
	 X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:X-Mailer:
	 MIME-Version:X-ThreadId:Date:From:To:Cc:Message-Id:In-Reply-To:
	 References:Subject:Content-Type:Content-Transfer-Encoding;
	bh=2NUXTatZ1IdgsWICJl6a5LN5D7xa7TyTNYSaN9iNn88=;
	b=dqB7RfEo4B4noEMvtoUlmxis0LhGo9GUW5qPEBlSVKBT0zCgDvSLo1DAKQoMBfOwubct
	 8IcgQjkHWrNt6BexvB5lVxH1yCBBoHrPgkLu+leKz7b5alDPaE18Gp/0HsRWLhhsBN0eO
	 KHkl5bX+j0P8s7HbSU6BbaA9tuXoiTiDFFIAhx3su0CVBmH+cRTJqOeRbYA2lQskTNkTg
	 oSKPJp9RpnzSmoRtyCs4A5I6eNBHvzYJv4bRb0FqFk45eEFCN2XBXbgbjLif4E0hurRze
	 IL/CuTKcKy7mL81GpHUKJ9nvnXZU6PxQIF7x/SFIENEEDun24I9n5wWVYfDXbpcdCxA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=KxOQ3asd;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 706F9606A31B
	for <linux-nfs@vger.kernel.org>; Thu,  5 Nov 2026 20:17:58 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=KxOQ3asd
Received: by smtp.kernel.org (Postfix) with ESMTPSA id DDE721F008A2;
	Thu,  5 Nov 2026 20:17:57 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793909878;
	bh=2NUXTatZ1IdgsWICJl6a5LN5D7xa7TyTNYSaN9iNn88=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=KxOQ3asdJvJibniJaZGP4EGduLqb3aN21LO9fHfRx+dlkQFDNe9aa3dQrLOuXYTr6
	 Oy8AiVu5Qe7r3zaZdeIE+ZJYuxKtWW/julQTUSIY7EzOCKwBg5v6BH1soVV8V6giPY
	 y4x78neQpPwpyHeqci0QU2xQI9lGHIm4Cw0z7on6zidD8pD0uLs9DJ+pur8Ingx2o8
	 rbAPnnlFgH5JNVcnVyW8iesWPDgNo/o5BnxgcA1/hMdT8x3OtJ2rElIWjGM+ir/tiR
	 vly+rEINCP/qPhwkYECfrBjUwQx8UOs5j+CcKpXESSsJ0rrZYmK2AXIQsd8x+jjJZO
	 sTpLUIPJiF7SQ==
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailfauth.phl.internal (Postfix) with ESMTP id 3574CF40068;
	Thu,  5 Nov 2026 15:17:57 -0500 (EST)
Received: from phl-imap-04 ([10.202.2.82])
  by phl-compute-02.internal (MEProxy); Thu, 05 Nov 2026 15:17:57 -0500
X-ME-Sender: <xms:deTsanVyjGIf_OKAQnWn7KQa0g6rs9NgHvsaQvz9wAMTynQNlUGu6g>
    <xme:deTsaqatDPomNVUR_Z5lBbSrqLfW_dNEqPj0Nmxab3tmgT59jc2zWk5LiVQGbTpw4
    lSaq9mLsSb7P7y9csRwIxScNrASmQAvJA6Bo6g5AuKMgYWm-b1gXfWJ>
X-ME-Proxy-Cause: dmFkZTEHb50C7C39FxVHeHqPZZru8q2xYoGTEXlwnKL6OgHHdBtLx+kXwegFr6imEaDa8r
    6Hxuj59QoildDJe95ENsaewpJekXnHxDQqv1S37IjmScZKiX8dkKfPRvNSnPqLitvcROMk
    TNdOcUsoEJSf42IRVAvSD2RXknEDINM+U/vpDwW9mfr2IWN1MtfgvvXJMWMrGo9+Bwt6dW
    kwJkq/iWkBJXLpr2fdDc02/JkBc4otmfFDl+OhgUxmvyt3Lvv4jvm4hdPEemy81IO2iXwn
    S0/hxCR8aLqTXqrRSykDtYV6o3QIm/340R/n3D27KDs89W3DrbkD6Lr8LZq3cbGz4eTRd5
    Bq3oIhLM6q4GyIMBhQjKfzf4jixSSPaLzq1TaWlpT1YV7msC0LBswNnqhu9xM89XfQRU1J
    pMa8pIrYMrl00qJmq83oppyFsFkdGUVKrxZMayYOeJN+absSu/s8fpNZZ8DbuYWgylkmmU
    4bPZqjsyjcU/fTo0/P94x4UKBwrGoPQ7naFHXBAQO9fn95/MU5HFl+X0nYTDY9D6mmz91W
    5bF0zGlqFGY1VXbMfplqr5yOMIPiwr8cRxD5qY/PJdBp0hxrvZkWtnxTqrE/dH9TMROZyS
    YWXmMui500bxAXvDi8gv+WtOQWzwtzbkklaRCd5M+rK5+4kOnsvPzc8EC/1g
X-ME-Proxy: <xmx:deTsak-xb85oqSvr1jSoSyjAKcnxgkyDZ1nSYlh23LbwKsYotDHv6g>
    <xmx:deTsaqiGzw5hQ5hmNzFBrv7o2LxlfRLRiz3NTmaQNMJvUMCQt9Ufig>
    <xmx:deTsakd7eEEsV1Pe_Z620pb0O0yQi1K8Enz9bHAuOsvPRv83EjvpEg>
    <xmx:deTsahqVGKWtJyDSLzFRRpDjU1x0KPu7Na4CfoQWS2IXsihmbvy6XQ>
    <xmx:deTsapDrT-mefzT8aH1Z7Q8mlyRWeLIwY3I9H7VMwIF7rJaqq3JcyUOj>
Feedback-ID: i20964851:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id B7216B6006E; Thu,  5 Nov 2026 15:17:56 -0500 (EST)
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
X-ThreadId: AvD4sRkv_1g-
Date: Thu, 05 Nov 2026 15:17:36 -0500
From: "Anna Schumaker" <anna@kernel.org>
To: "Mike Snitzer" <snitzer@kernel.org>,
 "Trond Myklebust" <trondmy@kernel.org>
Cc: linux-nfs@vger.kernel.org,
 "Jonathan Flynn" <jonathan.flynn@hammerspace.com>
Message-Id: <f1d8e0ac-3949-4def-a725-cbc1db988dee@app.fastmail.com>
In-Reply-To: <20261102191109.13470-10-snitzer@kernel.org>
References: <20261102191109.13470-1-snitzer@kernel.org>
 <20261102191109.13470-10-snitzer@kernel.org>
Subject: Re: [PATCH 09/11] NFSv4/flexfiles: drop NFS4_FF_MIRROR_STAT_AVAIL
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Hi Mike,

On Mon, Nov 2, 2026, at 2:11 PM, Mike Snitzer wrote:
> From: Mike Snitzer <snitzer@hammerspace.com>
>
> The "this needs reporting" hint was a bit in nfs4_ff_layout_mirror::flags,
> set on every DS RPC and consumed once per report interval.  It was wrong
> in both directions.
>
> It cost too much.  set_bit() ran twice per RPC -- once from
> nfs4_ff_layout_stat_io_start_{read,write}() and again from the matching
> _end_ -- on a mirror-wide cacheline that every stripe of the mirror
> shares.  That is the same false sharing the per-stripe lock was
> introduced to remove, and after the preceding patches gave each direction
> a line of its own it was the last write to the mirror's line left on the
> hot path.  Two unconditional atomic read-modify-writes per RPC, at the
> 275k-450k RPC/s this series was measured at, to set a hint read once
> every 60 seconds.

I have read this sentence 3 times and can't quite figure out what it's
trying to say.

>
> And it said too little.  The bit is per mirror, but the statistics it
> gates are per stripe, and ff_layout_mirror_prepare_stats() tests it
> inside the per-stripe loop.  The first stripe with a usable deviceid
> cleared it, so every other stripe of that mirror hit the test_and_clear
> and skipped.
>
>   What the server sees today: for a mirror with N stripes, a LAYOUTSTATS
>   report carries exactly one ff_layoutupdate4, for the lowest usable
>   dss_id, no matter how many stripes are busy or how the I/O is spread
>   across them.  Stripes 1..N-1 are reported only when the layout is
>   returned.  For the 32-stripe RAID0 layout this series targets, the
>   server is picking data servers on 1/32 of the picture, and always the
>   same 1/32 -- a stripe that is idle while the other 31 are saturated
>   reports zeros, and a stripe that is saturated while stripe 0 is idle
>   never reports at all.

I'm not sure we need the point-of-view change in the commit message. It
would be nice if the entire message could be rephrased to be more
concise and easier to follow.

>
> So drop the bit rather than fix it.  The reporting path already reads
> ops_completed for both directions under their locks; remember what it
> reported and skip a stripe whose count has not moved since.  That is
> strictly more accurate than the flag was -- it is per stripe by
> construction, and it cannot be left set by I/O that has already been
> reported -- and it costs the I/O paths nothing.
>
>   What the server sees after this patch: up to dev_limit
>   ff_layoutupdate4 entries, one per stripe that has completed I/O since
>   its own last report, in dss_id order.  The numbers themselves are
>   unchanged -- same cumulative ops_completed and bytes_completed, same
>   deviceid, same encoding -- there are just more of them, and they
>   describe the stripes that did the work.  A stripe with no completions
>   since its last report is now omitted rather than reported as an
>   unchanged repeat; a server differencing successive reports sees the
>   same thing either way.  LAYOUTRETURN still reports every stripe it can
>   fit, as before.
>
> nfs4_ff_layout_ds_stripe::last_reported_ops is deliberately out in the
> read-mostly region rather than in either nfs4_ff_layoutstat: it is
> touched only by ff_layout_mirror_prepare_stats(), about once per report
> interval, so it must not consume one of the 64 bytes an I/O dirties.  It
> lands in the existing hole ahead of read_stat, so sizeof is still 320.
> Both callers of ff_layout_mirror_prepare_stats() hold the inode's i_lock,
> which serialises it; no new lock is needed.
>
> NFS4_FF_MIRROR_STAT_AVAIL was the only bit ever defined on
> nfs4_ff_layout_mirror::flags, so the field goes too.
>
> Note that dev_limit is 4 in both callers, so N > 4 stripes still cannot
> all be reported at once; the next patch rotates which ones are.
>
> Signed-off-by: Mike Snitzer <snitzer@hammerspace.com>
> ---
>  fs/nfs/flexfilelayout/flexfilelayout.c | 43 +++++++++++++++-----------
>  fs/nfs/flexfilelayout/flexfilelayout.h | 12 +++++--
>  2 files changed, 34 insertions(+), 21 deletions(-)
>
> diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c 
> b/fs/nfs/flexfilelayout/flexfilelayout.c
> index 0b8562efabb24..670780bb3d353 100644
> --- a/fs/nfs/flexfilelayout/flexfilelayout.c
> +++ b/fs/nfs/flexfilelayout/flexfilelayout.c
> @@ -829,7 +829,6 @@ nfs4_ff_layout_stat_io_start_read(struct inode 
> *inode,
>  	report = nfs4_ff_layoutstat_start_io(dss_info, &dss_info->read_stat,
>  					     requested, now);
>  	spin_unlock(&dss_info->read_stat.lock);
> -	set_bit(NFS4_FF_MIRROR_STAT_AVAIL, &mirror->flags);
> 
>  	if (report)
>  		pnfs_report_layoutstat(inode, nfs_io_gfp_mask());
> @@ -849,7 +848,6 @@ nfs4_ff_layout_stat_io_end_read(struct rpc_task *task,
>  				  requested, completed,
>  				  ktime_get(), task->tk_start);
>  	spin_unlock(&dss_info->read_stat.lock);
> -	set_bit(NFS4_FF_MIRROR_STAT_AVAIL, &mirror->flags);
>  }
> 
>  static void
> @@ -865,7 +863,6 @@ nfs4_ff_layout_stat_io_start_write(struct inode *inode,
>  	report = nfs4_ff_layoutstat_start_io(dss_info, &dss_info->write_stat,
>  					     requested, now);
>  	spin_unlock(&dss_info->write_stat.lock);
> -	set_bit(NFS4_FF_MIRROR_STAT_AVAIL, &mirror->flags);
> 
>  	if (report)
>  		pnfs_report_layoutstat(inode, nfs_io_gfp_mask());
> @@ -889,7 +886,6 @@ nfs4_ff_layout_stat_io_end_write(struct rpc_task *task,
>  				  requested, completed,
>  				  ktime_get(), task->tk_start);
>  	spin_unlock(&dss_info->write_stat.lock);
> -	set_bit(NFS4_FF_MIRROR_STAT_AVAIL, &mirror->flags);
>  }
> 
>  static struct nfs4_ff_layout_ds *
> @@ -3156,6 +3152,7 @@ ff_layout_mirror_prepare_stats(struct pnfs_layout_hdr *lo,
>  	struct nfs4_ff_layout_mirror *mirror;
>  	struct nfs4_ff_layout_ds_stripe *dss_info;
>  	struct nfs4_ff_layout_ds *mirror_ds;
> +	__u64 read_count, read_bytes, write_count, write_bytes, ops;
>  	int i = 0, dss_id;
> 
>  	rcu_read_lock();
> @@ -3167,13 +3164,31 @@ ff_layout_mirror_prepare_stats(struct 
> pnfs_layout_hdr *lo,
>  			mirror_ds = rcu_dereference(dss_info->mirror_ds);
>  			if (IS_ERR_OR_NULL(mirror_ds))
>  				continue;
> -			if (!test_and_clear_bit(NFS4_FF_MIRROR_STAT_AVAIL,
> -						&mirror->flags) &&
> +
> +			spin_lock(&dss_info->read_stat.lock);
> +			read_count = dss_info->read_stat.io_stat.ops_completed;
> +			read_bytes = dss_info->read_stat.io_stat.bytes_completed;
> +			spin_unlock(&dss_info->read_stat.lock);
> +			spin_lock(&dss_info->write_stat.lock);
> +			write_count = dss_info->write_stat.io_stat.ops_completed;
> +			write_bytes = dss_info->write_stat.io_stat.bytes_completed;
> +			spin_unlock(&dss_info->write_stat.lock);
> +
> +			/*
> +			 * Nothing has completed on this stripe since it last
> +			 * reported, so do not spend one of the few devinfo
> +			 * slots on repeating those numbers.  A LAYOUTRETURN is
> +			 * the last chance to report and says everything.
> +			 */
> +			ops = read_count + write_count;
> +			if (ops == dss_info->last_reported_ops &&
>  			    type != NFS4_FF_OP_LAYOUTRETURN)
>  				continue;
> +
>  			/* mirror refcount put in cleanup_layoutstats */
>  			if (!refcount_inc_not_zero(&mirror->ref))
>  				continue;
> +			dss_info->last_reported_ops = ops;
>  			/* The pin holds a reference; it is exchanged out only
>  			 * under i_lock.  Put in ff_layout_free_layoutstats().
>  			 */
> @@ -3183,18 +3198,10 @@ ff_layout_mirror_prepare_stats(struct 
> pnfs_layout_hdr *lo,
>  			       NFS4_DEVICEID4_SIZE);
>  			devinfo->offset = 0;
>  			devinfo->length = NFS4_MAX_UINT64;
> -			spin_lock(&dss_info->read_stat.lock);
> -			devinfo->read_count =
> -			    dss_info->read_stat.io_stat.ops_completed;
> -			devinfo->read_bytes =
> -			    dss_info->read_stat.io_stat.bytes_completed;
> -			spin_unlock(&dss_info->read_stat.lock);
> -			spin_lock(&dss_info->write_stat.lock);
> -			devinfo->write_count =
> -			    dss_info->write_stat.io_stat.ops_completed;
> -			devinfo->write_bytes =
> -			    dss_info->write_stat.io_stat.bytes_completed;
> -			spin_unlock(&dss_info->write_stat.lock);
> +			devinfo->read_count = read_count;
> +			devinfo->read_bytes = read_bytes;
> +			devinfo->write_count = write_count;
> +			devinfo->write_bytes = write_bytes;
>  			devinfo->layout_type = LAYOUT_FLEX_FILES;
>  			devinfo->ld_private.ops = &layoutstat_ops;
>  			priv->dss_info = dss_info;
> diff --git a/fs/nfs/flexfilelayout/flexfilelayout.h 
> b/fs/nfs/flexfilelayout/flexfilelayout.h
> index 876fdb6999473..743957cd12300 100644
> --- a/fs/nfs/flexfilelayout/flexfilelayout.h
> +++ b/fs/nfs/flexfilelayout/flexfilelayout.h
> @@ -113,6 +113,15 @@ struct nfs4_ff_layout_ds_stripe {
>  	struct nfs_file_localio		nfl;
>  	/* Published once by the first I/O; see 
> nfs4_ff_layoutstat_set_start_time() */
>  	ktime_t				start_time;
> +	/*
> +	 * Completed ops, both directions, as of this stripe's last
> +	 * LAYOUTSTATS report.  Touched only by
> +	 * ff_layout_mirror_prepare_stats(), so roughly once per report
> +	 * interval, and serialised by the inode's i_lock, which both of its
> +	 * callers hold.  Deliberately out here rather than in either
> +	 * nfs4_ff_layoutstat: it must not cost the I/O paths a cacheline.
> +	 */

Cut all but the first sentence of this comment, please.

Otherwise, it looks okay.

Thanks,
Anna

> +	__u64				last_reported_ops;
>  	/*
>  	 * A line each, and each carrying its own lock, so that a read and a
>  	 * write to this stripe neither serialise against each other nor
> @@ -131,12 +140,9 @@ struct nfs4_ff_layout_mirror {
>  	u32				dss_count;
>  	struct nfs4_ff_layout_ds_stripe *dss;
>  	refcount_t			ref;
> -	unsigned long			flags;
>  	u32				report_interval;
>  };
> 
> -#define NFS4_FF_MIRROR_STAT_AVAIL	(0)
> -
>  struct nfs4_ff_layout_segment {
>  	struct pnfs_layout_segment	generic_hdr;
>  	u64				stripe_unit;
> -- 
> 2.52.0
