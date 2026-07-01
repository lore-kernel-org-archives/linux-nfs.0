Received: from fhigh-b3-smtp.messagingengine.com (fhigh-b3-smtp.messagingengine.com [202.12.124.154])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D455239E9AD;
	Wed,  1 Jul 2026 22:38:43 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.154
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1782945525; cv=none; b=qCTrja8+4273H/LvnaWusaYeW1Hl9zuucuemtSQuVSE1/7dCg0BVmPjQ5QPioQ/qcSo8KpA5hf/gmBqlnRGTKg82gUbgdBz58eUYDq7g6QBp+aE9VE5tfr07Yr87BO27JL6hlXS3dmCainZEscIjxiJi5Dg5V3ma7jbAOhHBTew=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1782945525; c=relaxed/simple;
	bh=3DWWjKZIVwC1oOeo/xPx54UWdicy8whQRHJXszDuLQ4=;
	h=Content-Type:MIME-Version:From:To:Cc:Subject:In-reply-to:
	 References:Date:Message-id; b=rCqiXDuYdpOJcKzh0KRSdy9PXcIpEJc2/NsQOacavqGZFrd6tBNZimALm1cd3IiHm3g4vcT75eWt0VoCgpBnjGbNFi80UVVf1shBEF7Z/ld9w/uXFaK/au46AzlNURMcHBkVup73pcKVeTcGR0MKyUYVdVjPmYTQTHM6fvc77TI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=HZ2/vWlB; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=fhHhuSnm; arc=none smtp.client-ip=202.12.124.154
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="HZ2/vWlB";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="fhHhuSnm"
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailfhigh.stl.internal (Postfix) with ESMTP id 087B17A00D9;
	Wed,  1 Jul 2026 18:38:43 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-02.internal (MEProxy); Wed, 01 Jul 2026 18:38:43 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to; s=fm1; t=
	1782945522; x=1783031922; bh=go25CzODMeFeDwvZbngEMyQWaG9eKMpRzsU
	kuJ7SNs8=; b=HZ2/vWlBLj5pnpVpGNt8ehQJBS37pZv1Mv6SM6K5I5ue2c+oK61
	OGH/F2dlO9pDG17U5t9wIDdYjaye3wEK8ZVeDiyUSCRRpoAxhw1qKGHsd2tgDTea
	e3/ocT2t0M/rNoM6ii4ks/iJMKM98W/nbQ9is2s/UlS6XscpVWLopjgvHPTAglgI
	suxhG6IF5GpMbmwJdpLF9uU7AfjSOBqQmBcUUkOrMUIA/J8VF/JWK0rfY3fsh3XP
	X6waZfJUBcIvyDsHtz0GGkOM1XIJk/sBIk+cxDiltbm1eYtps/jl1+QGdmyxVbcm
	gOShrJiv8QFbyBA3pn5xgBGXKjp+ocpKNqA==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm1; t=1782945522; x=
	1783031922; bh=go25CzODMeFeDwvZbngEMyQWaG9eKMpRzsUkuJ7SNs8=; b=f
	hHhuSnmnQtSbmOsv2O1Ck5bbWS5AaJoXCBWLe9PD2r3lIewb/ncwsW5WsuO4yHok
	OAfMIakVVncK60rKS8peMBqQXi8f5+apFA9hBn5X/iHm5W1+91IQVNmSquwmWrF9
	/LPlCAGrv8TgPwtkmbR1/4+yq6ma79ZBnaRtZKV3QTHUYu6BfomoVxTsgRabpWqX
	eUm5KHULXZyvYODj9U9dIG7OyntTaZ7Xm551eWIvnomf6eLQp3xq7BQNVqRSJ5YN
	5vuNv/lfOh1De+2su1DXv1BH3wt/B2g6W1bPeTNqJH3D9p0qdkmiB1SUd9UCA4qw
	/cmwsbMujUysq4McQ3L+g==
X-ME-Sender: <xms:8pZFamuv31lalUngi5v6C3NBmq_C10_QLzFQqq_FbwPGakzN8CRUHA>
    <xme:8pZFagaICMqx3E7zk-_Lxu2hTKKGk2TafJkmi14PugPO5OLKFqHTaorwThGC4-Xcu
    e_jBpqKpNAwAuUjd2L56ARXq2JIgmZBE2Y4dfBHZY0M8kDazrg>
X-ME-Received: <xmr:8pZFamB-38pkvZPYNFrWvffHrfI_FvqnrR4_rw9XsjbtZMKSYGNk5U02TpC6tZA1OvYpjd-iRHxBN6TjNU6gj_axJOPgUf8>
X-ME-Proxy-Cause: dmFkZTFk+GKr9bqLoZuRBgZ6HGaT4NCrWkNhUefNdNfbdQdKUVbcfs06fiaiZ2/30wQqso
    xC8Mv8/wOHRa8jHbQaA8rG+l1xKjCA63Fvq1JRdxq+2G/8HZ3yWdgml7bEETpvO73P8sxF
    V5LHcCMSDernun0YOMN7HiuwNvADC0KroyE/5RYiC12fmQ8Hglg6kFb4uA9vmAiz5pij1d
    j8Al0wYbFxipR00ugwsHiv8Mfo1ou6I1HDppTDr/BI0ZIK1ecoeY1KwbYmv4ettGUrPs+W
    MRY58ShgP/+iv6aHVgy1civrAHMzZK3driK4gn3CdoYsTnNUE47xhpUyB0hUrquITZhwb/
    K+2dzVsjPFT1FyhP37M1QedKd2mWqzKbs/O5bc71f6AKJ2qepSv4KiMop7PE4rj50SeQMK
    BtBQaqNM8VfyQKo/JYq2SG6hv6VPsQTf1bMxq2OZtLPodjDOTO4/R/0ib1jl4v/LOShkux
    D9axFbX5bDzvMt2JnbyhieZUD7l0RuzHTkyvw1D5vHvgP17nfREsxNcF2+O2/fqJm+BlIH
    O+Vzdda3VX2ua0WW09n3bm4VMuovTX5MPR7VABGIZwG/vH2LnP8yfG/Qmr0rhtifZsHUsn
    mw4gaj7MfflKiEx9w51GEPylXm3rJRofZFLViO+LlPbwfQCGZ28P080GACuQ
X-ME-Proxy: <xmx:8pZFag_F1P6mKoHOdS8KNjomUnDRGzW2CETDBa1rTAJ5cY5Uv8w3Jw>
    <xmx:8pZFaqRdfh6Fija8iWTnQyXudAbIeUz36F1awEXg8wE1FwBSyTOxMw>
    <xmx:8pZFasUd64YOrPCDGiLw2Ygxf_roqAZHp_Co9iMZxOeyPpsqBcueug>
    <xmx:8pZFasTjHGrQM9oX3HWjbL0k4qTShk1qvRxS39lDiOIRE_15j9kUFQ>
    <xmx:8pZFald7EsxMT3WdWdgd8AfGy-ttUaTS_iE0vHrpfngTnu-e_6uaWrbG>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Wed,
 1 Jul 2026 18:38:39 -0400 (EDT)
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
From: NeilBrown <neilb@ownmail.net>
To: "Jeff Layton" <jlayton@kernel.org>
Cc: "Trond Myklebust" <trondmy@kernel.org>, "Anna Schumaker" <anna@kernel.org>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, "Chuck Lever" <cel@kernel.org>,
 linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
 "Jeff Layton" <jlayton@kernel.org>
Subject: Re: [PATCH v4 4/4] sunrpc: eliminate a modulus operation from the
 enqueueing codepath
In-reply-to: <20260701-sunrpc-pool-mode-v4-4-b3d867e4c8f9@kernel.org>
References: <20260701-sunrpc-pool-mode-v4-0-b3d867e4c8f9@kernel.org>
  <20260701-sunrpc-pool-mode-v4-4-b3d867e4c8f9@kernel.org>
Date: Thu, 02 Jul 2026 08:38:38 +1000
Message-id: <178294551803.27465.10105848443096838211@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>

On Thu, 02 Jul 2026, Jeff Layton wrote:
> Currently we do this to determine the pool to enqueue on:
>=20
>     pidx =3D m->to_pool[cpu_to_node(raw_smp_processor_id())] % serv->sv_nrp=
ools;
>=20
> ...but a modulus is rather expensive. Replace this instead with an
> explicit check for running off the end of the array.
>=20
> This situation should never occur, but if it does, just fall back to
> pool 0.
>=20
> This trades a ~20-30 cycle operation that isn't pipelined and
> monopolizes the divider for a ~1 cycle well-predicted branch.

I would rather discard ->sv_nrpools as described in previous reply, then
this modulus would disappear as it isn't needed.

Thanks,
NeilBrown


>=20
> Signed-off-by: Jeff Layton <jlayton@kernel.org>
> ---
>  net/sunrpc/svc.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
>=20
> diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
> index ae93a6f51087..ed841ea09079 100644
> --- a/net/sunrpc/svc.c
> +++ b/net/sunrpc/svc.c
> @@ -252,7 +252,9 @@ struct svc_pool *svc_pool_for_cpu(struct svc_serv *serv)
>  	if (serv->sv_nrpools <=3D 1)
>  		return serv->sv_pools;
> =20
> -	pidx =3D m->to_pool[cpu_to_node(raw_smp_processor_id())] % serv->sv_nrpoo=
ls;
> +	pidx =3D m->to_pool[cpu_to_node(raw_smp_processor_id())];
> +	if (pidx >=3D serv->sv_nrpools)
> +		pidx =3D 0;
> =20
>  	/*
>  	 * Threads are spread evenly across the pools, but when there are
>=20
> --=20
> 2.54.0
>=20
>=20

