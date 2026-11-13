Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794579537;
	b=Wo1cSAslyQ2sgV4ttwv5xCwQxU2/8H/48v7tf6hK4GZpke6C0M2TGTUHT77WZHgTC7ZA
	 /iGrtHpP8eNfeZsx8IRvsEYEzPU4MWpkv0+1AN0JHQmivTKTGX4ABIr2i7fRZAryckjai
	 dvfasGpN6jpYJNjUXDRoD0ClAkunxEGKVfjFrrDwZ5dOhXp+0LDYjaFrfpnrjlX8fZatL
	 UistfKn3wV83S7AjZ3KfO99iqQQkRMwLCpAdzF42AykW7Lw+5TDlJLEvKnaqS5kWJkFp8
	 MiwJvRZVA+HrufzjxwrwMQVjKXJBZITq2n/q3cyS6G0ZWS8y/GwY8+EbZ8tqVrQDmIg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794579537;
	h=Received:DKIM-Signature:Received:Received:X-ME-Sender:
	 X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:X-Mailer:
	 MIME-Version:X-ThreadId:Date:From:To:Cc:Message-Id:In-Reply-To:
	 References:Subject:Content-Type:Content-Transfer-Encoding;
	bh=FEIuD14SIn5TBLbl63Y7OarvbI0QrJTPoHECymZUIE4=;
	b=JIVg4wAnjpSd3oTKC4Cu/q8jKVGn9qOtekUycrXAY5XGtVUfSU66hEcWriaaTkL9ijL5
	 BTCON+CSJNeGPP/B9aOEJTySDdmNCuHORN5oDWon6ray44p9OpuAbhfY1GHHMTg20hIkj
	 CBgmgQga5Zq4Abs25jpyTGTPP7FvBGlng+C2v/pfFtgB3CC64He90sRctAfMo4Di52KG0
	 ZGha5XZPG4SnN0u5dqf8LlP34VgzwO/oACH+De9J+z/hgug6TLKup/2PYQwiwk/ToIO+N
	 dvyliX9fKfyPELzlkpxbGz/RsCPFa11KpqSWsY5Fpg80lzdGo6PW8xtjzUwRB+PS5mg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="Xbs/pCsu";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A8C03606A323
	for <linux-nfs@vger.kernel.org>; Fri, 13 Nov 2026 14:18:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Xbs/pCsu
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 29E521F000C4;
	Fri, 13 Nov 2026 14:18:57 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794579537;
	bh=FEIuD14SIn5TBLbl63Y7OarvbI0QrJTPoHECymZUIE4=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=Xbs/pCsuamC1HjWegizEjm4JaLE/9nmEiJcx0+Iz+Ema4J+ehPaxNE2B32rSRJCRl
	 tCc0z6G8TxflWrx+nr2Ta6OKR+GICAHq12JxuuTg8U8NIWj0MrAEO0MyPV3bY9NL43
	 twbJbeyryw6MkTtoJuxnpwj8cA2ovZ6yw9f4V++X7watMDovt+g99WQnMQVEL38a8v
	 E6yqRc04VC9/BHtSd8gCc4lWrA/JEEsNqtiA1xvK2f1bpv/fIONwRD6XNQhewlauTz
	 j5IN/8vnN3OqD9uIQbkdbh48Vh9AdqRVZTC6mQJCSyXCUjPRUAjTvTDs8NgnDnC24w
	 YxpgC5dlZoavg==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 5D495F40068;
	Fri, 13 Nov 2026 09:18:56 -0500 (EST)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Fri, 13 Nov 2026 09:18:56 -0500
X-ME-Sender: <xms:UBz3ap3NOBMyCXLrwMV5_lstvl0Ie4e7z5xpV2pPWlKLxmyyzszbTA>
    <xme:UBz3aq5tNcZggOL9gIP8aSath2APCjcq8vzF76Y9Wsc64NLISNpN9Sp9kkKFqjT9H
    tRSne5Ibr1h_QdkjazOD9uvw5c-8LVIqfdt9UQTOpech1Vj_aiKGQ>
X-ME-Proxy-Cause: dmFkZTEsakpOAWApsrdxzxQI2TtjEx5gtV5wBtDIHNpBmE65EWpEgakQKA3Z3QJF0462gH
    ZrJ0zVni2SynA1xo9yJJm+93hOpG4JgyhTmOQn8N+gDy3sD6IC7hQLdC/jlXrGph8Knq7g
    RFkwo94JGMgTM6VDr/wie2OWcgOlG3XtSt00Ev2XLt1oxXv7AEiyYE9+64bAEZLK3Z9UWK
    vhGqBecqdsQqSqZ2Yf4vOjmA6/NMdaAZZT2WhKOZbp98AmWp6UNViLJdmWFxFfybaEFm09
    y7BMVPv1H/4NeLhLa5ZSKE0yAG5GGoD4idpYkdyx8SImCH505a1r+Y++P4fcLyz0gbJ7qC
    9PdM+jjD6nysxeEgEhYwDLWhFuSFmrh00+RATXocQZjpLHIkJv0xx18Lqdqw1pckLFonHs
    UjPYu6bDfvNqZPn7S3oa0nwci/Ryp1ams9Xu6NO2LLmPKmitUIc7FJBPLNk5nDyBOvUPP/
    EdfWJ4yCewKxkIHQaOmPAjfV2P8/+BVSotBTWnv9gyJo/A4SSZgbwwk0DCxv/IchkmPwRd
    B/PvFe8PUsEBKXiM648rJIly1DFtLMOHxEtmDQSTXxt6CnGxqrjf0/BFYf6C926sta7RNB
    /0Fn1Ta7M78PMbo6DCwPDw/go7zcalMv8qWom6b3MjQI1Zkx36/HIvgYQdnw
X-ME-Proxy: <xmx:UBz3ajA6Vj1GQCj4if94jdiSmuEPclC6fCRRQ-tl1s9TDdWf31Mcsg>
    <xmx:UBz3ai8cf4eCUWSfWiYmK-MgNJNQ4njmyrWG5SWvPhcWj6lX9EPLVw>
    <xmx:UBz3auKHW_CrB_26wEbZJRepP0aOrkaaXJG0w1g4SyzZVLx8qQ1kUw>
    <xmx:UBz3arj6UFt5mklZya-a_w9ClI8fBIp01gtD25HdJ1jV6Lv7loGLaQ>
    <xmx:UBz3au72iG99K1H-mLIh5ShO4xm2eljFQcqTg4IxCwMtrIDDWj3IqqO2>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 3CEC1780075; Fri, 13 Nov 2026 09:18:56 -0500 (EST)
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
X-ThreadId: AUDiM6dCfxUg
Date: Fri, 13 Nov 2026 09:18:36 -0500
From: "Chuck Lever" <cel@kernel.org>
To: "Mike Snitzer" <snitzer@kernel.org>,
 "Anna Schumaker" <anna.schumaker@oracle.com>
Cc: "Trond Myklebust" <trondmy@kernel.org>, linux-nfs@vger.kernel.org
Message-Id: <67be1870-8488-45f1-84e3-b047a75fa406@app.fastmail.com>
In-Reply-To: <20261113001611.90519-2-snitzer@kernel.org>
References: <20261113001611.90519-1-snitzer@kernel.org>
 <20261113001611.90519-2-snitzer@kernel.org>
Subject: Re: [PATCH 1/2] SUNRPC: Make rpciod and xprtiod visible in sysfs
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Thu, Nov 12, 2026, at 7:16 PM, Mike Snitzer wrote:
> rpciod and xprtiod are unbound workqueues.  An async task's work is
> queued to the affinity pod of the CPU that queues it, but an unbound
> workqueue's affinity is not strict by default, so the scheduler is free
> to run the worker on any CPU the workqueue allows.  On a two-node NFS
> client whose writers are pinned to the node local to their NIC, with
> the workqueues' affinity scope set to numa, 1.5% to 2.4% of the skbs
> sent on each port were still handed to the driver from the other
> node's CPUs: 97% of them from rpciod running rpc_async_schedule(), the
> rest from xprtiod.
>
> Neither workqueue can be made strict today, because neither is created
> with WQ_SYSFS and so neither has affinity_scope, affinity_strict or
> cpumask under /sys/devices/virtual/workqueue/.  Add WQ_SYSFS to both.
> Nothing changes until an administrator writes those attributes.
>
> With affinity_strict set to 1 on both, the same client sent nothing
> from the other node and spent about 1.7 fewer CPUs at the same
> throughput.
>
> Signed-off-by: Mike Snitzer <snitzer@kernel.org>
> ---
>  net/sunrpc/sched.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
> index 016f16ca57799..83e2974a44d9f 100644
> --- a/net/sunrpc/sched.c
> +++ b/net/sunrpc/sched.c
> @@ -1278,11 +1278,11 @@ static int rpciod_start(void)
>  	/*
>  	 * Create the rpciod thread and wait for it to start.
>  	 */
> -	wq = alloc_workqueue("rpciod", WQ_MEM_RECLAIM | WQ_UNBOUND, 0);
> +	wq = alloc_workqueue("rpciod", WQ_MEM_RECLAIM | WQ_UNBOUND | WQ_SYSFS, 0);
>  	if (!wq)
>  		goto out_failed;
>  	rpciod_workqueue = wq;
> -	wq = alloc_workqueue("xprtiod", WQ_UNBOUND | WQ_MEM_RECLAIM, 0);
> +	wq = alloc_workqueue("xprtiod", WQ_UNBOUND | WQ_MEM_RECLAIM | WQ_SYSFS, 0);
>  	if (!wq)
>  		goto free_rpciod;
>  	xprtiod_workqueue = wq;
> -- 
> 2.52.0

I already posted a patch for this back in September:

https://lore.kernel.org/linux-nfs/20260915-performance-v3-3-ae26d460bfd3@kernel.org/

Did it get rejected?

-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
