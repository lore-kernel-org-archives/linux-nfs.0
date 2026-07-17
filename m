Received: from fhigh-b3-smtp.messagingengine.com (fhigh-b3-smtp.messagingengine.com [202.12.124.154])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3426A26ED3C
	for <linux-nfs@vger.kernel.org>; Fri, 17 Jul 2026 04:44:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.154
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784263494; cv=none; b=WGQycz9snwLMKOOoqzcZjvY7CfDOumvqlzk/vxCj7lL8xQlSQnPrYvynxugTEGMS0WGNsqXOw0gtPpaO5SMlFQV7A77go8QX513tc/X3EHgi9XLXOaLd4pGiytRTySJiOBPrmvUojS0wtuhQigqq9jSAOy+l8nYxnN8mtQToXsc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784263494; c=relaxed/simple;
	bh=8Egc8Kg5oUjqSRWkSAR0uKpUQDsZOE1Naad8ymRlJTk=;
	h=Content-Type:MIME-Version:From:To:Cc:Subject:In-reply-to:
	 References:Date:Message-id; b=U+O8HvU2PTHVI8XRGy3/Yi0kcfz4P3j0YX49xxQCJKBWaiCPUwFe1Tqtx/uJ1p/a0EszzfMwbBopdi5Wo7psfX8UfMw5iEw0P7psWgl4DVhVFPp3T1GGcwIlyh7w7wapTBnAZjylQdx7US4WfaXldpOCeqmV4cQfAev5YDdzMwY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=mVWoMrM1; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=XhrAl2aP; arc=none smtp.client-ip=202.12.124.154
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="mVWoMrM1";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="XhrAl2aP"
Received: from phl-compute-04.internal (phl-compute-04.internal [10.202.2.44])
	by mailfhigh.stl.internal (Postfix) with ESMTP id 67ADB7A0103;
	Fri, 17 Jul 2026 00:44:52 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-04.internal (MEProxy); Fri, 17 Jul 2026 00:44:52 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to; s=fm2; t=
	1784263492; x=1784349892; bh=WvY3W2+Ewga0cG2Jw/dPgRizf/dOHSawYH4
	4ZtvM0is=; b=mVWoMrM1+pQs76DPmnxwD3FFdoihTTPjBi8aFxtudG3H+vO9Ex6
	NApCFn1u/OshFKPFVQOaQ4EIZfxHknfnCS2vTY+uABo2yXGZLuclhw8Izm0dAP3j
	AcrIyaWjolcBKxnMH5/KzaDHamed7jXlAzFHX95bD/JteRLUt49CcbJgUvgy0104
	dRpQ99PcFjBS7nik7qeL25YbzqSWV058KY+OPbXQt9RkJQd4GwWrGFEPUPhQk88m
	xpWt1xOSeOqSdeoxV1/uyIxpiYF2WMfYK6xaYmOFszhB6GlZf0arHS7FiNdVz1Yf
	cbzjLZLzAB9kuqxJGyOpa4/BsyFUWyXCX3g==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; t=1784263492; x=
	1784349892; bh=WvY3W2+Ewga0cG2Jw/dPgRizf/dOHSawYH44ZtvM0is=; b=X
	hrAl2aPWCJ16HFzKFsm6OumB6luVmg2LBJB3LROc/XJq4HGqj5fwZhYOSOMhY0sK
	nLxovuFjCbfCDQ0HJTZa1r9MOgAa67YHE5PBC/ZplcEwXxUVrp0/g8uQO5Uplhkw
	do8l/55LVxpoeTp7+HaSpWiJogTQ8bYA6j7a75Ji8sfZR09mylKs+wu3hZLx5/5t
	wjknZo/gcDjoYRxRJx6YlyCHEiwjSIZOKKWHg1ZQrDz6ocBFOxitCkh5dT8H7JZp
	Swd8dKxJCB6mwSTvmE2ujrIxlzb5YOSFVuk7M5l+voTDigOeht58jNdPDcsZMUGb
	cncDvg80HhHOgFanoMyEA==
X-ME-Sender: <xms:RLNZap-vZWK_meTjv_j6BCvIGXVHRum7KIAvGCQMDIVNFYkLKHoOjQ>
    <xme:RLNZahbiGQEWamdH6iGrEAQ0k63iw0-S9J8SmgGEbi3lCe32vcf3d-auOyDNZSLSD
    b-4FnfEa44DJEkBXuQKSTGIUp6K5oWpEG_mh5VDWkl3S0LP>
X-ME-Received: <xmr:RLNZag1iMIIV4j1CmHWnHmtgAhnbQQTipRIHsI9yFvLPCxTbYcuMd-_QFn3g0DZJwhSf4tYb07UUa9oSk0GaQplEKpQ9CKU>
X-ME-Proxy-Cause: dmFkZTGR5SrnF6hgE1g7Nu2C1+O0Cy4DI34P6sTcepDP86yTZEFZxbeTG//I+TH+dZl01Y
    jDxEHVl2eNsjAYa7BP9XmB3bn8kAQyfKzbfzTab1VJseJ8Ow4721fm6ykBG4YBUHHY642V
    MQ4jziNSjPvxbyRDGHkV86Ct7C5xJsGfSMcd7Qvxhn5FZkdZG+yI4pjJZBIHp3zOTlwrln
    l9Fo1UEJyZV3SFiqppoAPJw7Lse55b0VUaAAFX9Z4J2VsdDhUZeRTB12mkATyrPX6ZVxh0
    uYdd8faf83cSRuB3Kp3Qev3g/ujkZWLU20r4EcatJgyxtJPTrtVrM9we8BfnoMgGc3XPmJ
    5xejOl0FpH4/cofbVNT7NW4EA3nMNgzm5rs7FgX/ajSUz6kby5RTb8TKJlGpjIT4BF2TXP
    VVKMITFqmBk4j8gxDAT2KU/Eq/Kf626hdhu9TkmCIOznPko0h+ttnfot1FePgrQcr5g03N
    OyE5dTmW2xEpUdec2eYpk3NKCss/PJzJH9Qq8RyXuydwGAuKcwvKsBgSovwIak9rSt8vAR
    0VNeeeYv1gHHvL9dVpwCIWoaKjczSsHmPwTa0MQSfWwAaM4oPfPWF6zdMxYHUgNTIgFAQK
    QLckgG9naH9j3hHQskyzhQWeUVcaWmiimydFGxMYXmLVEWXPDifNRv9ZZpFw
X-ME-Proxy: <xmx:RLNZakbdmnRiSIqyrMQNUYHRg_UCcNJETHTaiOq8hOAsxyGmlwNiEw>
    <xmx:RLNZagLqut8ee5AMBTLzTTW6Yp6vPhOmciAmBtoDiFDwrzeFH0YHKQ>
    <xmx:RLNZarGN2zWz60azwTuJgo-I85hsfi-1kuV7-EZJsWgQz6Pz419d9w>
    <xmx:RLNZavvQ_FpYef9QAjq1pSPTipBO1ywlUYNTa3ZHjYDexEIfpBINrw>
    <xmx:RLNZaumMLFlcbys9gR0TRoIEbbe9wcfZbXHVYQb7Ye-jv_83BsSZ1lQ4>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Fri,
 17 Jul 2026 00:44:50 -0400 (EDT)
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
From: NeilBrown <neilb@ownmail.net>
To: "Chuck Lever" <cel@kernel.org>
Cc: "Jeff Layton" <jlayton@kernel.org>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <dai.ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/5] Minor NFSD global DRC clean-ups
In-reply-to: <20260717001232.438792-1-cel@kernel.org>
References: <20260717001232.438792-1-cel@kernel.org>
Date: Fri, 17 Jul 2026 14:44:46 +1000
Message-id: <178426348638.3371781.2716060745747771641@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>

On Fri, 17 Jul 2026, Chuck Lever wrote:
> I'm working on a series of global DRC improvements. A few minor
> clean-ups are ready for merge now.
> 
> Chuck Lever (5):
>   NFSD: Fix off-by-one in DRC bucket pruning limit
>   NFSD: Eliminate percpu counter contention in DRC memory accounting
>   NFSD: Eliminate percpu counter contention in reply cache statistics
>   NFSD: Eliminate percpu counter contention in IO byte accounting
>   NFSD: Document reply_cache_stats ABI
> 
>  .../ABI/testing/procfs-nfsd-reply_cache_stats | 38 +++++++++
>  fs/nfsd/nfscache.c                            |  2 +-
>  fs/nfsd/stats.h                               | 78 ++++++++++++++++---
>  3 files changed, 108 insertions(+), 10 deletions(-)
>  create mode 100644 Documentation/ABI/testing/procfs-nfsd-reply_cache_stats
> 
> -- 
> 2.54.0
> 
> 

All looks very sensible to me.
Reviewed-by: NeilBrown <neil@brown.name>

Thanks,
NeilBrown
