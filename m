Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793914895;
	b=JFLQf3zropcd72YccIsUYGWcqqmWKgosaWUcAyTNLgwtR9UNntj7QtSkp1+RwfY7E236
	 UOTLwgz/QxqHZ9tZgXX++stU4FMkJIfyD2rNujDundHCEDRnBlmWNLSK7RSrxsKfKUdjX
	 wDmCeOcbHACRPq4aKxEfgABbyw20/4IhohOxfk1LJFf5ZDYB8D2xiF7BeLRQbLHMqDy4r
	 ZOVucj0fQF07tPSGA6gry6u8iq4AtaIvit4IU7VFKYn+yXS8KvarticG/nypJj4RnHDmf
	 01Td4s/+5G++WxpCNkjv+uOiV1yeU0Wmu30J2wDXh370+iUetOtZfPaA2o4pTBmTqXQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793914895;
	h=Received:DKIM-Signature:Received:Received:X-ME-Sender:
	 X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:X-Mailer:
	 MIME-Version:X-ThreadId:Date:From:To:Cc:Message-Id:In-Reply-To:
	 References:Subject:Content-Type:Content-Transfer-Encoding;
	bh=H3ivgvaNMvv1gD2r+xpMiJAFdCsRCXUkzVwpwertxM8=;
	b=k1j3+wtXGoTXtfOHLTo8AVlp7Pf6qg7FHS2ufbnfcee/Wj8cGD9vwV9OyLVD1GbpMgPO
	 ZZ7YS1NUZ1i2SMWN0YIlypfswdLvbimx212W1X/U1WNmkJ9JRqyxd8kCD8XsgWRAxURSw
	 dpFbrjtF4V2VNOohws8wzNeZiX64yym6gUkoikSQc/5SY1M7ZKxBJZCrnyY4hCIaJJ5ot
	 GyNqcZpaHLdSzAKOhDrFHh6nMeKJbOwFuNWiVYtDrZYZmth7etOT9BjVgEsOzQAm2mMzR
	 RvX6CPFFeTAUzjexrPPcqmS9+v9YRAfdxmeW0cz5rtbO85oh78jbeGX/Sg43hb715ew==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=TQn9RMTC;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 65E1F606A328
	for <linux-nfs@vger.kernel.org>; Thu,  5 Nov 2026 21:41:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=TQn9RMTC
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B8D301F008A2;
	Thu,  5 Nov 2026 21:41:34 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793914895;
	bh=H3ivgvaNMvv1gD2r+xpMiJAFdCsRCXUkzVwpwertxM8=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=TQn9RMTCmhARDUlin3bOoS8ZLIgcAnX5kmqUK1S3JcS96TFIQ5pyIK16iUh7syWj4
	 jRcrEgYT+KJ1YJZjGLi4X5+VzhZvxzk4Cr0zTBCx8dvPRNYAZJi4NRSyLjW0qlxL9H
	 6Y+EEMPtD799PMq5k4aOd61p09nqiha+37bOwul7bW5RU0d1m+C/E9iGZPtcbGZpMQ
	 9AnbnB3bqVwnCTtCb3qFXS8UMa6I4pv3MlO8QjSMOFo5s/B+7vmZGfeU8XuYYLmvaK
	 O/fl+OgPhH45vKyjp8mhLp3+oJqT4Vmdwiu0TdjozUOzgRhKtApsqF2hgj420yeyDC
	 8e3Jrm4pSvfBQ==
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailfauth.phl.internal (Postfix) with ESMTP id 0D623F40066;
	Thu,  5 Nov 2026 16:41:34 -0500 (EST)
Received: from phl-imap-04 ([10.202.2.82])
  by phl-compute-02.internal (MEProxy); Thu, 05 Nov 2026 16:41:34 -0500
X-ME-Sender: <xms:Dfjsao3xnqGxTbxVkYJChIY90juFOVzSh2cZovfgEc0fXhlyJwRv8A>
    <xme:Dfjsat5aPG0OAPdrE4DzyI_jPce2oTErYCor8VtRvVML7EVDLLQxNrRlK5gHpkfhy
    hiG5_yJbG-fzwO7vI-IAeh-SgcmLF1s2xPUgig_gRsjhUfljCV8MctK>
X-ME-Proxy-Cause: dmFkZTEGt+wcswX+hiT5janCl/MKepeOX0IXo2BV+ChUqgQKldXCwZr8cej5Y4eGyqNvg5
    A2OiJVFmpP3aS3KM0ECwUJbqWgeaQZyfRSt0jeeV5pgaH36594oxpWvnfWeE5jw4zmTJcQ
    QxvING0ssh+Y7WJTYtQCG5fTf+FBxMnCNmNvJd/2kYsUcdrp3C4EFtIvOCRD3M9iKZh02n
    RMU88s+DfbSz2E4HSsPV7xGyQWSzT4FcMC7tUuzBkwRgyHFdDQj1ycKgbRZvnmKPk6zb3m
    YtlG25tEteWdo1j1kIIXr/RwYqms/vWmr3gQ+j0WmulzRwFSmBdA2ZNpLS7r8ulSC8hUEG
    0egoHNoGhaCrXA3plYoUJ/tzAn01lFZ+oU3IXTYcq5cuO52GbwtFqlgP/Rs+YIijPwthZp
    BHNLNe+Sh5k6uoZvpQA58BfmgZvWg5gt0VRH013ndNGxM/Gr3Td1dYUEjUMWKXOwfiguoI
    NdAHMWH0NJMQkFcrxwV46J0libif+RrpijWO8aV9NggmjRnvr4fE+WVmVV2Xosx+xoXMKX
    ALz0nfq0TIic5e9TI3WpI6tWfAJD/V4WDQW01rq2sgrw6YJ0sKEtJ0tnVzr7Cl6lsbCesD
    QjWxh9oKLn3j9jMba6dmRponC9nIYBKvMLsDUqbsKWabM4TsgOIoA6zFFdaA
X-ME-Proxy: <xmx:DvjsaueaebWKaBqC3YBBSr2NiNy0tasIyJ-ugSemgahXhlsrFHAPpA>
    <xmx:DvjsamCMBn6kW7dSDxsSvDH6RH_pclC-KjT0Q37t9bs1IsLtg_edTA>
    <xmx:Dvjsap86qeBFejaqSuv_lAGuCmXmaRtznt1MphAtDFHhDoROUjC_Vw>
    <xmx:DvjsapId4-03x9mQxdWGhXK8wqb-n0UNBLS33bN3mdGHT5aWWNgPmg>
    <xmx:DvjsaqjWx7ySAlMTOQmZJkbFmqkoxVzWaFRqCs5tWU-fU0YuE9iJ1yoX>
Feedback-ID: i20964851:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id E5223B6006E; Thu,  5 Nov 2026 16:41:33 -0500 (EST)
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
X-ThreadId: AR9fqhuuqVHc
Date: Thu, 05 Nov 2026 16:41:13 -0500
From: "Anna Schumaker" <anna@kernel.org>
To: "Mike Snitzer" <snitzer@kernel.org>,
 "Trond Myklebust" <trondmy@kernel.org>
Cc: linux-nfs@vger.kernel.org,
 "Jonathan Flynn" <jonathan.flynn@hammerspace.com>
Message-Id: <ba32777f-8f47-4c0a-9ade-af44928721da@app.fastmail.com>
In-Reply-To: <20261102191109.13470-11-snitzer@kernel.org>
References: <20261102191109.13470-1-snitzer@kernel.org>
 <20261102191109.13470-11-snitzer@kernel.org>
Subject: Re: [PATCH 10/11] NFSv4/flexfiles: rotate LAYOUTSTATS reporting across a
 mirror's stripes
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Hi Mike,

On Mon, Nov 2, 2026, at 2:11 PM, Mike Snitzer wrote:
> From: Mike Snitzer <snitzer@hammerspace.com>
>
> Both callers of ff_layout_mirror_prepare_stats() cap it at four
> ff_layoutupdate4 entries -- PNFS_LAYOUTSTATS_MAXDEV for LAYOUTSTATS and
> ARRAY_SIZE(ff_args->devinfo), which is FF_LAYOUTSTATS_MAXDEV, for
> LAYOUTRETURN.  The scan walks mirror->dss[] from index 0 every time and
> stops once the budget is spent.

Why does the commit message need to specify starting at index 0? That's
just standard looping over an array behavior.

>
>   What the server sees without this patch: for a mirror with more than
>   four busy stripes, the same low dss_ids every report, forever.  The
>   previous patch widened that from one stripe to four -- it did not stop
>   it being the same four.  On the 32-stripe RAID0 layout this series
>   targets, stripes 4..31 are reported only when the layout is returned,
>   so a data server that is only ever backing a high stripe index stays
>   invisible to the server's placement decisions no matter how much I/O it
>   does.

The "what the server sees" interludes seem randomly placed in this patch
and break the flow of what I'm reading. I don't think it's adding much.

>
> Remember where each mirror's scan stopped and resume there.  The cursor
> advances past each stripe that actually fills a slot, so a report picks
> up where its predecessor left off and idle stripes, which are skipped
> without consuming a slot, do not stall the rotation.
>
>   What the server sees with this patch: still up to four entries per
>   report, but rotating, so every busy stripe of a mirror is reported
>   within ceil(busy_stripes / 4) report intervals -- eight intervals, or
>   about eight minutes at the default 60 second interval, for 32 busy
>   stripes.  A given stripe's numbers therefore arrive less often than
>   before but, unlike before, they arrive.  The values are unchanged:
>   cumulative ops_completed and bytes_completed since the layout was
>   granted, so a server differencing successive reports for a stripe still
>   gets a correct delta, just over a longer window.  Nothing about the
>   encoding, the deviceid or the ordering within a report changes.
>
> The mirror loop gets the same dev_limit test as the stripe loop, so a
> full report stops scanning instead of walking the remaining mirrors to
> break immediately on each.
>
> [jonathan.flynn: read dss_report_start once per mirror, before the stripe
>  loop.  The loop advances it after each stripe it reports, so re-reading
>  it moved the index twice: stripes were skipped, and on a mirror with
>  stripes not yet written (and so skipped) the index wrapped back onto a
>  stripe already reported.  That put the same deviceid in one ff_iostats4
>  array twice with identical counters.]
> Signed-off-by: Jonathan Flynn <jonathan.flynn@hammerspace.com>
> Signed-off-by: Mike Snitzer <snitzer@hammerspace.com>
> ---
>  fs/nfs/flexfilelayout/flexfilelayout.c | 22 +++++++++++++++++++---
>  fs/nfs/flexfilelayout/flexfilelayout.h |  7 +++++++
>  2 files changed, 26 insertions(+), 3 deletions(-)
>
> diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c 
> b/fs/nfs/flexfilelayout/flexfilelayout.c
> index 670780bb3d353..591363e2cf460 100644
> --- a/fs/nfs/flexfilelayout/flexfilelayout.c
> +++ b/fs/nfs/flexfilelayout/flexfilelayout.c
> @@ -3153,14 +3153,28 @@ ff_layout_mirror_prepare_stats(struct 
> pnfs_layout_hdr *lo,
>  	struct nfs4_ff_layout_ds_stripe *dss_info;
>  	struct nfs4_ff_layout_ds *mirror_ds;
>  	__u64 read_count, read_bytes, write_count, write_bytes, ops;
> -	int i = 0, dss_id;
> +	u32 dss_id, scanned, base;
> +	int i = 0;
> 
>  	rcu_read_lock();
>  	list_for_each_entry(mirror, &ff_layout->mirrors, mirrors) {
> -		for (dss_id = 0; dss_id < mirror->dss_count; ++dss_id) {
> -			dss_info = &mirror->dss[dss_id];
> +		if (i >= dev_limit)
> +			break;
> +		base = mirror->dss_report_start;
> +		for (scanned = 0; scanned < mirror->dss_count; ++scanned) {
>  			if (i >= dev_limit)
>  				break;
> +			/* Resume where the last report of this mirror left
> +			 * off; one subtraction suffices to wrap, as both
> +			 * terms are below dss_count.  Use the start as it
> +			 * was on entry: this loop advances it for the next
> +			 * report, and re-reading it would skip stripes and
> +			 * wrap back onto one already reported.
> +			 */

The code is self-documenting enough to not need this comment.

> +			dss_id = base + scanned;
> +			if (dss_id >= mirror->dss_count)
> +				dss_id -= mirror->dss_count;
> +			dss_info = &mirror->dss[dss_id];
>  			mirror_ds = rcu_dereference(dss_info->mirror_ds);
>  			if (IS_ERR_OR_NULL(mirror_ds))
>  				continue;
> @@ -3189,6 +3203,8 @@ ff_layout_mirror_prepare_stats(struct 
> pnfs_layout_hdr *lo,
>  			if (!refcount_inc_not_zero(&mirror->ref))
>  				continue;
>  			dss_info->last_reported_ops = ops;
> +			mirror->dss_report_start =
> +				dss_id + 1 < mirror->dss_count ? dss_id + 1 : 0;
>  			/* The pin holds a reference; it is exchanged out only
>  			 * under i_lock.  Put in ff_layout_free_layoutstats().
>  			 */
> diff --git a/fs/nfs/flexfilelayout/flexfilelayout.h 
> b/fs/nfs/flexfilelayout/flexfilelayout.h
> index 743957cd12300..33724f2db5d62 100644
> --- a/fs/nfs/flexfilelayout/flexfilelayout.h
> +++ b/fs/nfs/flexfilelayout/flexfilelayout.h
> @@ -141,6 +141,13 @@ struct nfs4_ff_layout_mirror {
>  	struct nfs4_ff_layout_ds_stripe *dss;
>  	refcount_t			ref;
>  	u32				report_interval;
> +	/*
> +	 * dss[] index to begin the next LAYOUTSTATS scan of this mirror at,
> +	 * so that a mirror with more stripes than a report has room for
> +	 * rotates through them rather than always reporting the lowest.
> +	 * Serialised by the inode's i_lock, like last_reported_ops.
> +	 */
> +	u32				dss_report_start;

Can this be renamed to either dss_report_base or dss_report_index? Then
we can drop the wordy comment entirely.

Thanks,
Anna

>  };
> 
>  struct nfs4_ff_layout_segment {
> -- 
> 2.52.0
