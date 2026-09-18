Received: from fout-b7-smtp.messagingengine.com (fout-b7-smtp.messagingengine.com [202.12.124.150])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 132B43859C3
	for <linux-nfs@vger.kernel.org>; Fri, 18 Sep 2026 23:00:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.150
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789772455; cv=none; b=ZJwpNM2caWgZVVCZdl7bqBQgRFW38O98a8QT6UpbMAXcBUHLiR2dSlEvbqlxIY4tid5dFiqaKxADdIxXDqywqRFbLKJeP+3sBUDLUGQc07Xbf8ep8xtcXEfvhCcioFduQSY+WfyMovPP6e9wQhf5CeXRlQ9Ryxvx9LhNkO7QxzM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789772455; c=relaxed/simple;
	bh=bQj4CcfhsojpSRSdvXWc6rTII7rjGS2b6zE4mXHUk0A=;
	h=Content-Type:MIME-Version:From:To:Cc:Subject:In-reply-to:
	 References:Date:Message-id; b=WQnGwuX9NHNiOV0Iax1NlixTl+JhLFhT8sGmFYQvG09g0q8XnqKc4l4KCozLjAM3YVyVK39HUbo2aI+WCtFWHwD19pFJS1RfYDt7Xseg0K7VuGuLooYhS/eGqR3b2bRr6ZSPD9tVgvX2JKXuCDv1ks7OLbY2FNS+hZRue5wmxVg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=n0lJMKYU; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=SDtY8ux+; arc=none smtp.client-ip=202.12.124.150
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="n0lJMKYU";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="SDtY8ux+"
Received: from phl-compute-04.internal (phl-compute-04.internal [10.202.2.44])
	by mailfout.stl.internal (Postfix) with ESMTP id 0703E1D000F8;
	Fri, 18 Sep 2026 19:00:52 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-04.internal (MEProxy); Fri, 18 Sep 2026 19:00:52 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to; s=fm1; t=
	1789772451; x=1789858851; bh=nXFUCwmuJ0w+Bv2KYQ8HmjLlRnt+6c0xQOJ
	aNbz9wwA=; b=n0lJMKYUR5Fap/eEoR+EGN9b5X+3HwAg4uIgwG2yXZNB25Ljozw
	XYDymevVLfruv4umKo79VeK/qb6st5hvSQMZCH6MCwsjBpdFqkoj5uVNtGV0qNWG
	lPwcm+AP9KzyHpuQlf0G/oJS5QJA80kpPGmiUWf/0bRt+z9DUbK+FXRNk4LQkviC
	4nhuHY5H9ruq3a8ksTlYfqHCXFSDcp7MzG0wSBeVOepP5rrbCS9pAkb1YR9Sk64w
	lySJczjomkk+9VHIqEYCwsfd4hS7YcyrdX4zgztHBekh+ZGAG6kmAW5Ra6BjLXGI
	x+5aCfRC/pLqEVp7TF1zcZs6C8hxG2oyVBA==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm1; t=1789772451; x=
	1789858851; bh=nXFUCwmuJ0w+Bv2KYQ8HmjLlRnt+6c0xQOJaNbz9wwA=; b=S
	DtY8ux+btxR6Srkv1lcRuEwNb+EcmXtV3R2Vu5L8i30aNL50xuYP6nYkzOzQgQu0
	6jkL4Y3yY/61+gPZdrRa1PKhYFi3qUwab/s/rhjv1bwhjLeP/I3QN4XNHHgNmNQL
	QtcsVO5ZjVJwaFOg2+FkSmhDA3J5/OeBqM3DBG1YOtbC5JYQCogMbq1IR1FBw4eN
	tngLmMVWHCCT9ZS72bkhvPDWmBDTW46avwtj5EFkglr5UkuINsnVyyHF4MGRTZoO
	xKRG0LdA6m+pQKUHQWkPxagYghXSrSJ9jZFMdevS1KFXVzKNKE5EXsT7khis1Go0
	foHl5zBSG5r/JAN0oukcA==
X-ME-Sender: <xms:o8KtalIhqNglyd6Na3-WludZSlKr-E0JGbBu-iVGyqQRAmen-1UCLA>
    <xme:o8Ktajbg6x8ry3l5WGE2M8R81YarftNRTxQw54C7apuExFMOHCUKlCxLTO-CqzX3d
    lQqttwQgGNGBK7XtpWmdUg178LgSQcHiNhLBCSAafQL79oYb0FV>
X-ME-Received: <xmr:o8Ktav_W6vMfkSDiEzv6s-KzxflVoZLtDRtbO7ty1aXr38d8cah_g-22gzwB2HyExNgxBvLhTi0x16iRWOxsgFdmK71d1I4>
X-ME-Proxy-Cause: dmFkZTFcSpfTaKNQa7mlWhEN9c1BoeQKsiGoZOYhtbKJCKpE8AFLqZP5E66QS68lQ+Mbmh
    XyEbmrGGZUXgXGYeoBoy5wYVtsdR6YVloEwnFIo/kuhSkowpniiWItm1dbJMa1n0SkqCim
    qNKhEo+a3lBaA9/pyMtxwEJeiHACRR3CdYhGz4A7uYFrak8KLJxnkLboxNaIjsqSAJu9aF
    ZwvBMy33m2E38FxulbHND0QPtvycyYe3i4adpSqfuQrzSktmT+TeGRoqP1HJn3OF/1sn/5
    1UmFf0tibQtv7aLaaS5DClUuRoYn81nfUySUuNeama6TlpRnSbmny72E0qAJCyIQ1uM2Xh
    qxDeylqDUWogmCUQWn2irm/tkAxM49/3pXCEzxAxdL5MoDautksJ8rGRCZBs7p8FG7g/HH
    C3APaRrXeBPHbhiKePvDHxb2BOh9qgnf1Th8JPLOknrHbjXVcFLhrdXpYGB0K6VJxMG7aZ
    CNvoc1dAeVMt3niIFlXHPlXHOIkXB3HJdnQ0O5qgKn18pr4+52Tntw1XNbUC0tY99oI2ht
    Xn8smbfPFA7bCSK8VPIFNoUb3BuSMdXi1tr55rGHQD8lBZSFrK5Mg8kWzhjFmNA1eYUVVQ
    odUIWZnCCzZURHB/ukvFwp504RA49ZzqGUg+X+nGD7XqYMbMNqUnDzO9yUPQ
X-ME-Proxy: <xmx:o8KtasYS6rvNmAh0hzhjLK6aBF72YvaIG45mw34hX471FEfIDJoTjg>
    <xmx:o8KtarO2xJlZVWgNeP-f9SSn8LeFXEesLSZmlienl8kNA9s1Ldm3XQ>
    <xmx:o8KtagD8Ny54zYKJV-sLIVmY7IJ-UdEvbmapr03Zi3irXw8C1Pzu3A>
    <xmx:o8KtaqKnGL5hliF8WGFEByszesFQojxCKkMIVaUUv5POTzYz_fVA6A>
    <xmx:o8KtasGAmVlVM5bIBAd_SFv0DtbIhsyEBcoyzmEDwnL94fTWpLvZHJHQ>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Fri,
 18 Sep 2026 19:00:49 -0400 (EDT)
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
From: NeilBrown <neilb@ownmail.net>
To: "Chuck Lever" <cel@kernel.org>
Cc: "Jeff Layton" <jlayton@kernel.org>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, "Rick Macklem" <rmacklem@uoguelph.ca>,
 linux-nfs@vger.kernel.org, "Chuck Lever" <cel@kernel.org>
Subject:
 Re: [PATCH v5 01/11] NFSD: Remove hard cap on duplicate reply cache size
In-reply-to: <20260918-duplicate-reply-cache-v5-1-b6aba9ebf2f4@kernel.org>
References: <20260918-duplicate-reply-cache-v5-0-b6aba9ebf2f4@kernel.org>
  <20260918-duplicate-reply-cache-v5-1-b6aba9ebf2f4@kernel.org>
Date: Sat, 19 Sep 2026 09:00:45 +1000
Message-id: <178977244520.207413.3893450376967484226@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>

On Sat, 19 Sep 2026, Chuck Lever wrote:
> nfsd_cache_size_limit() scales the DRC entry limit with the square
> root of low memory, then clamps the result at 256k entries. The
> clamp binds on any host with more than 64 GB of low memory. Once
> the cache reaches max_drc_entries, nfsd_prune_bucket_locked()
> evicts oldest-first regardless of age, so on such a host the cap
> governs retention rather than RC_EXPIRE. A server that completes
> more than about 2200 calls per second fills 256k entries inside
> the 120 second RC_EXPIRE window, and from then on entries are
> evicted before they expire. Those are the entries a retransmit
> could still hit.
>=20
> Commit 0338dd157282 ("nfsd: dynamically allocate DRC entries")
> added the clamp in 2013, when the formula's worst case of 1 KB
> per entry made 256 MB a reasonable ceiling for the hosts of the
> day. The formula was already sized to memory; the clamp froze it
> at that generation of hardware.
>=20
> Remove the cap and let the square-root formula govern sizing. It
> scales sub-linearly with memory, and the hash table already uses
> kvzalloc, so larger sizes need no physical contiguity. The limit is
> unchanged at 64 GB and below. At 1 TB the formula yields 1048576
> entries, four times the old cap. Even at 1 KB per entry, the worst
> case the old comment assumed, a full cache is 1 GB, 0.1% of that
> host's memory. That memory is not reclaimable: the shrinker frees
> only entries older than RC_EXPIRE, and each net namespace sizes its
> own cache.
>=20
> Assisted-by: LLM
> Signed-off-by: Chuck Lever <cel@kernel.org>
> ---
>  fs/nfsd/nfscache.c | 33 ++++++++++++++++++---------------
>  1 file changed, 18 insertions(+), 15 deletions(-)
>=20
> diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
> index 80364b91331a..d0f65cc9c07a 100644
> --- a/fs/nfsd/nfscache.c
> +++ b/fs/nfsd/nfscache.c
> @@ -47,34 +47,37 @@ static unsigned long nfsd_reply_cache_scan(struct shrin=
ker *shrink,
>  					   struct shrink_control *sc);
> =20
>  /*
> - * Put a cap on the size of the DRC based on the amount of available
> - * low memory in the machine.
> + * Size the DRC by the amount of low memory in the machine. The
> + * limit scales with the square root of available pages; with 4 KB
> + * pages:
>   *
>   *  64MB:    8192
> - * 128MB:   11585
> + * 128MB:   11584
>   * 256MB:   16384
> - * 512MB:   23170
> + * 512MB:   23168
>   *   1GB:   32768
> - *   2GB:   46340
> + *   2GB:   46336
>   *   4GB:   65536
> - *   8GB:   92681
> + *   8GB:   92672
>   *  16GB:  131072
> + *  32GB:  185344
> + *  64GB:  262144
> + * 128GB:  370688
> + * 256GB:  524288
> + * 512GB:  741440
> + *   1TB: 1048576
>   *
> - * ...with a hard cap of 256k entries. In the worst case, each entry will =
be
> - * ~1k, so the above numbers should give a rough max of the amount of memo=
ry
> - * used in k.
> - *
> - * XXX: these limits are per-container, so memory used will increase
> - * linearly with number of containers.  Maybe that's OK.
> + * These limits are per-net-namespace, so memory used increases
> + * linearly with the number of namespaces. The shrinker frees only
> + * entries older than RC_EXPIRE, so a cache below its limit is not
> + * reclaimable under memory pressure.
>   */
>  static unsigned int
>  nfsd_cache_size_limit(void)
>  {
> -	unsigned int limit;
>  	unsigned long low_pages =3D totalram_pages() - totalhigh_pages();
> =20
> -	limit =3D (16 * int_sqrt(low_pages)) << (PAGE_SHIFT-10);
> -	return min_t(unsigned int, limit, 256*1024);
> +	return (16 * int_sqrt(low_pages)) << (PAGE_SHIFT - 10);
>  }

This patch looks good and does what it says on the tin....
But that formula at the end (which the patch doesn't change) looks weird.

As you note in the table above, 8GB on 4K pages results in 92681 target
cache entries.
8GB with 64K pages comes to 370727 cache entries - 4 times as many.
That doesn't seem justified.

If we made it

    32 * int_sqrt(low_pages << (PAGE_SHIFT-10))
or even
    int_sqrt(low_pages << PAGE_SHIFT)

it would be 92681 entries no matter the page size which is what the
original table says.

Does this need fixing?  Should we fix it now?

NeilBrown
