Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793895272;
	b=ddUOnkcnn1kzaMxLzCZBVnV74MMRQ+ghH/q+U1OG0t2YKtSGV0NpLiXeGKG+8VD1csRK
	 WPk1UJ7DevdB1EmQZpISJDoofKxPq+dlnx7GZs+Hz0fE/XC5aoK7N4d/sRHiKquzJHtvs
	 KB8PnriLJijOVoLMh44V7ldseJh/x0ndg1jGhzFJXIsY4J8aePyYg34yZ05TUtSGt3V2h
	 12TzU2dkyWSREEQI2mfhNGoCgMaiNa7GWLPN+gWy63u/VEKYZISsQDoMH7yemtQd+o26N
	 kIKs1BLx4HvWQ1m2O87x9HigdwiBMJNX2tPtmAjhGK89dimarxK2TLS9IiyaGi+HkSA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793895272;
	h=Received:DKIM-Signature:Received:Received:X-ME-Sender:
	 X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:X-Mailer:
	 MIME-Version:X-ThreadId:Date:From:To:Cc:Message-Id:In-Reply-To:
	 References:Subject:Content-Type:Content-Transfer-Encoding;
	bh=ZM6WrHJqCi8zB89al/XQllwJYnou67OIT/3BYUArvkM=;
	b=Pj5FxTpxIaubJoeMCqBCTVEqcLLmNW4lgw+cq2wIj3zvgusrnq/uyqux3BoIYNn9ILzz
	 O5omcMoHhoKuU1lNop/gMzPQOuki1DTsBoUBkyH0vLkxWkwRRU1WM5NZO22JAwKgrl6xI
	 1jWe7u06K/18jco1q6RsJI8KilyjR4JGKDlcHqGb9mv4VzprgmG6RTHa0YnAWQqvsjLm/
	 N0eH9RTJ2E0gqXCB+Hg+Lgfl+5mtsB6SNfi6g/uqG6cEhwV0+eSSGuhEMiabQ6MycOEMC
	 3a1afzF2lexbBuKEmd/MKd219cbXWtU/JlWzG86q+UaWrwACABdMa4f8Kap9bpudw7A==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=XV4kdvIf;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D1A09606A31B
	for <linux-nfs@vger.kernel.org>; Thu,  5 Nov 2026 16:14:31 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=XV4kdvIf
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 1930D1F00919;
	Thu,  5 Nov 2026 16:14:31 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793895271;
	bh=ZM6WrHJqCi8zB89al/XQllwJYnou67OIT/3BYUArvkM=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=XV4kdvIfY1uhsydoWG24ONHVqqA9M12KW6xj1bck1lYGMh7EHxOgvgdkfYSPkGiev
	 zkRF/LaV/24Hp2lZV+xePg1IBYAZEZAqnWoOqgW7uy5KTIJACHsKhInnFHzjNGO/HV
	 eXQOBBcoCq4Su87IC8c508vLAk54UtoCDBHgNbQf/TO42Mb1xzOsuv5DRgqz6jhXjq
	 kLrasrvWLFTuy/jfvSHNlS3q0a9vbJGbUMkFsitDOWWPE9muFkYd2j4d8AO03hnFFN
	 H79H6Q7zsQB0rv50SVXFkbWvW/DizKfoZhqTelaT4D72giapewKzsaAWsMQLvzL/HU
	 OG2o0PyRvNE+Q==
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailfauth.phl.internal (Postfix) with ESMTP id 6848FF40066;
	Thu,  5 Nov 2026 11:14:30 -0500 (EST)
Received: from phl-imap-04 ([10.202.2.82])
  by phl-compute-02.internal (MEProxy); Thu, 05 Nov 2026 11:14:30 -0500
X-ME-Sender: <xms:ZqvsakH20G-bgkK1YvLqcuXwbs79NNeDuuRLgEhTC24bmoLOkIlKuw>
    <xme:ZqvsaoITspavbZirNv5vYIQfl-ZvQZl2OuyK3X45-Z98khcuJcw3dVSN2w5ZLWPTg
    oRp931fTz5TasWSLmijtwQ-n8-BZBNrae-jRsDE9gYuVZtouv2zIquf>
X-ME-Proxy-Cause: dmFkZTFQIFd3Ch6qWDsBj2xOUa0ICzpeRSC3lf9ozlGqfZMLf4acmoq+bIrDNJlLZO7ucK
    3yKPKlym2RX3KA/kqIDFoM+VQGuUJDvvvdNthh7A0GosWcQKymevpvAFoDDsrlwWNZnl/Y
    iaTlW27o7YLeK3LSZTszxmLrk/9vbxwXWOgqgX/b9HeUnbY7n/biPX5bN/gvfI1s/0PeYF
    BSYUCjGRNarX59tV/ozQ6qSGkbmCsxrmu4f/1ykuhpiySU/JfVWWj76SoJGouBjgW60zbL
    5S6TOfkneuH7rgIyf9JHhZVUiJX2b2usuFnZG5Vub7nRRlz71JyE+J3FDtNaJA6umrKISb
    7WmBNh6X2HNpuAeZ7JVQqJtCHa3S6/JGSIUqN2WHew6s0hxaENW8gtLZiY3nDKXD3+FZyj
    zoM+CLv26SYxo8ESfUOzWNyeaQuJ22ClZBlnY+mnbn4CTbluGIxdrUCTzhV9Tqrn88LDqq
    yoKJOdkKv8eogMlZnAmehH360R3+OcZDV86hUXSdBWnujaBPD7nx60Bkcz/p/YLPa9nXKp
    lcjU3N2GzbVmtB1EvIzRcc2WcO02bm+IrVWe7cUdrcfRNrFVXc65jUlKlLzAucsBVfGQwm
    OY80juP7mAiC5iWRZwxoEyf+JLeXJxGIMh+Dq3r76tUZKo+4VeU+Xcw/8iwg
X-ME-Proxy: <xmx:ZqvsaltGZWAgSdO02xtnpIkiRDaCKTBGU6gJsIIthP3IkJDvjV_gww>
    <xmx:ZqvsasTEWKe8h9Ett7LDKiWrP6KZkXC-uW1OBk01fqjNr7yi2Q6lZQ>
    <xmx:ZqvsajMVhQs8dTS-8XjiD6kCGqfkq5Dw1mu7OSIawaQZ6Hj3b3ZFlQ>
    <xmx:ZqvsapYmUIwPXJCQKnif1_I741PxOI3gSetwiqObeW5wJ9pddpK3hA>
    <xmx:ZqvsalxF_u4n_tvNoBwkE8aFGTmVfYMDhXJur8ZMFMYtLdMu0lKMhdUQ>
Feedback-ID: i20964851:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 52E59B60071; Thu,  5 Nov 2026 11:14:30 -0500 (EST)
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
X-ThreadId: AzF6jBGjfWOR
Date: Thu, 05 Nov 2026 11:14:10 -0500
From: "Anna Schumaker" <anna@kernel.org>
To: "Mike Snitzer" <snitzer@kernel.org>,
 "Trond Myklebust" <trondmy@kernel.org>
Cc: linux-nfs@vger.kernel.org,
 "Jonathan Flynn" <jonathan.flynn@hammerspace.com>
Message-Id: <2e7ab5bd-11dc-4b02-827f-7a4983f755c0@app.fastmail.com>
In-Reply-To: <20261102191109.13470-5-snitzer@kernel.org>
References: <20261102191109.13470-1-snitzer@kernel.org>
 <20261102191109.13470-5-snitzer@kernel.org>
Subject: Re: [PATCH 04/11] NFSv4/flexfiles: make dss_info->start_time write-once
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Hi MIke,

On Mon, Nov 2, 2026, at 2:11 PM, Mike Snitzer wrote:
> From: Mike Snitzer <snitzer@hammerspace.com>
>
> start_time was written under the stripe lock in
> nfs4_ff_layoutstat_start_io() and read outside it in
> ff_layout_encode_ff_layoutupdate().  Pre-existing -- mirror->lock had the
> same shape -- and benign, since it is a single naturally aligned 8 byte
> value, but it is an unannotated race either way.

We can probably drop this last sentence.

>
> The lock is the wrong tool for it.  ffl_duration is measured from this
> stripe's first I/O, so the field is written once and read-only for the
> rest of the stripe's life.  Say that instead: publish it with

This portion needs editing too. My brain tripped over "Say that instead"
while reading.

> try_cmpxchg64() and let the first I/O win, and read it with READ_ONCE().
> Only the first I/O to a stripe pays the read-modify-write; every one
> after it short circuits on the READ_ONCE().

This sentence is just rewording the previous sentence.

>
> ffl->last_report_time two lines away is already published this way, so
> the pattern is not new to this file.
>
> This also stops start_time depending on there being exactly one lock per
> stripe, which a later patch changes.
>
> Signed-off-by: Mike Snitzer <snitzer@hammerspace.com>
> ---
>  fs/nfs/flexfilelayout/flexfilelayout.c | 21 ++++++++++++++++++---
>  fs/nfs/flexfilelayout/flexfilelayout.h |  3 ++-
>  2 files changed, 20 insertions(+), 4 deletions(-)
>
> diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c 
> b/fs/nfs/flexfilelayout/flexfilelayout.c
> index 7fc1369df8439..7c328f2ec900d 100644
> --- a/fs/nfs/flexfilelayout/flexfilelayout.c
> +++ b/fs/nfs/flexfilelayout/flexfilelayout.c
> @@ -729,6 +729,22 @@ nfs4_ff_end_busy_timer(struct nfs4_ff_busy_timer 
> *timer, ktime_t now)
>  	return ktime_sub(now, start);
>  }
> 
> +/*
> + * ffl_duration is measured from this stripe's first I/O, so 
> start_time is
> + * written once and read-only for the rest of the stripe's life.  
> Publish it
> + * with a cmpxchg and let the first I/O win, rather than depending on 
> a lock
> + * that every reader would then have to take.
> + */
> +static void
> +nfs4_ff_layoutstat_set_start_time(struct nfs4_ff_layout_ds_stripe 
> *dss_info,
> +				  ktime_t now)
> +{
> +	ktime_t unset = 0;
> +
> +	if (!READ_ONCE(dss_info->start_time))
> +		try_cmpxchg64(&dss_info->start_time, &unset, now);

I have the same atomic64_try_cmpxchg() question as in patch 1 here.

Thanks,
Anna

> +}
> +
>  static bool
>  nfs4_ff_layoutstat_start_io(struct nfs4_ff_layout_mirror *mirror,
>  			    u32 dss_id,
> @@ -740,8 +756,7 @@ nfs4_ff_layoutstat_start_io(struct 
> nfs4_ff_layout_mirror *mirror,
>  	ktime_t last_report;
> 
>  	nfs4_ff_start_busy_timer(&layoutstat->busy_timer, now);
> -	if (!mirror->dss[dss_id].start_time)
> -		mirror->dss[dss_id].start_time = now;
> +	nfs4_ff_layoutstat_set_start_time(&mirror->dss[dss_id], now);
>  	if (mirror->report_interval != 0)
>  		report_interval = (s64)mirror->report_interval * 1000LL;
>  	else if (layoutstats_timer != 0)
> @@ -3087,7 +3102,7 @@ ff_layout_encode_ff_layoutupdate(struct 
> xdr_stream *xdr,
>  	/* nfstime4 */
>  	ff_layout_encode_nfstime(xdr,
>  				 ktime_sub(ktime_get(),
> -					   dss_info->start_time));
> +					   READ_ONCE(dss_info->start_time)));
>  	/* bool */
>  	p = xdr_reserve_space(xdr, 4);
>  	*p = cpu_to_be32(false);
> diff --git a/fs/nfs/flexfilelayout/flexfilelayout.h 
> b/fs/nfs/flexfilelayout/flexfilelayout.h
> index f48860450cf28..658940979883a 100644
> --- a/fs/nfs/flexfilelayout/flexfilelayout.h
> +++ b/fs/nfs/flexfilelayout/flexfilelayout.h
> @@ -88,7 +88,7 @@ struct nfs4_ff_layout_ds_stripe {
>  	const struct cred __rcu		*rw_cred;
>  	struct nfs_file_localio		nfl;
>  	/*
> -	 * Protects read_stat, write_stat and start_time below.
> +	 * Protects read_stat and write_stat below.
>  	 *
>  	 * Cacheline aligned so that the layoutstats accounting done on
>  	 * every I/O to this stripe does not share cachelines with the
> @@ -100,6 +100,7 @@ struct nfs4_ff_layout_ds_stripe {
>  	spinlock_t			lock ____cacheline_aligned_in_smp;
>  	struct nfs4_ff_layoutstat	read_stat;
>  	struct nfs4_ff_layoutstat	write_stat;
> +	/* Published once by the first I/O; see 
> nfs4_ff_layoutstat_set_start_time() */
>  	ktime_t				start_time;
>  };
> 
> -- 
> 2.52.0
