Received: from fout-b2-smtp.messagingengine.com (fout-b2-smtp.messagingengine.com [202.12.124.145])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9E7711FC0
	for <linux-nfs@vger.kernel.org>; Sun, 20 Sep 2026 10:37:54 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.145
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789900676; cv=none; b=ayNbyJBv6TRljxqZpctC0mfvs9mfo640SKjS1Un2S+8qgK90FWG9CYh9c/p6Qfws9cHx6haJenGmWFYTuxMbo4u1xzMnN5qOo78HF6CdFHc+5hWF8zpS3j9rmDaPJ14RxRWKMkjoHthruglHE1DADyj1Dgo/Hbo9RDPW2JTHGGA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789900676; c=relaxed/simple;
	bh=/Ehu2ZAuibKAjrfsEGJsOxRmydkER23uZaUqGU8MltY=;
	h=Content-Type:MIME-Version:From:To:Cc:Subject:In-reply-to:
	 References:Date:Message-id; b=YzUbBY4lPAg3+n9B19NE1vBvQ0PmDmYt4SvRE2O5XStnfronXCzko1EdZosiul5b5KGxOOIB4yIlzfxDZs3mcm5Ollqah142KZ86KRnM98o6b6q0DgphQi4ClwGUHuUGnVqLDuUHYcLS8BFLXPIa36VNEjmVw8uoivJHd2GI4wQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=K+/clTZh; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=eDONKNTz; arc=none smtp.client-ip=202.12.124.145
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="K+/clTZh";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="eDONKNTz"
Received: from phl-compute-08.internal (phl-compute-08.internal [10.202.2.48])
	by mailfout.stl.internal (Postfix) with ESMTP id AD44E1D0016D;
	Sun, 20 Sep 2026 06:37:53 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-08.internal (MEProxy); Sun, 20 Sep 2026 06:37:53 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to; s=fm1; t=
	1789900673; x=1789987073; bh=pTrsva+URYlYMrvte1VzU8InMm4lgfQllUb
	653FVOag=; b=K+/clTZhT2Rm64kSSIvS7VtFPOJHaxXhfaaqD8sidKXahzYbsji
	Sf3DVuCAQPewSQ3xnQ7aVHbI5GD9SUVuARa185Td2RCvoL1+wIn/3Qdrx9YXTkVG
	8CcGsN61MaevMxfbR/rgwReMl5bwNqbR1KQXjteSsBSbQtHywmdUD8H9voZ2oy7W
	HAFSuZMoA54FlgujFXtOXJzstK1O0sZqGXe8F7XYuluc3hxDoxzxQmb4nRl3y8gA
	vzn6FspcQhPzNBJKPlUsD8HtKqGhhvwcntAagupwOEyE7RXFNc1lXFqLaS+7w8Za
	qq5q1HqZDZpXoTQf3dL8ACwCZJh1BR4Z/Bg==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm1; t=1789900673; x=
	1789987073; bh=pTrsva+URYlYMrvte1VzU8InMm4lgfQllUb653FVOag=; b=e
	DONKNTz5eAOKq2HffvCqm7zhfL5Ucyxq09AQq/q7LyCIYcN0PGl1BwL4/fdin7HY
	8gsdTeOUDsxP8A0z3M+GnEHfxEkpx+C21Rg5gVc7q+Q6YemNHjt8AUbbUgxQTNs3
	636fRhRZlkQmja5iQmAZkuPhlw2ztOL3RJLIjOKeXd7tMC/q+mwdvKtgakBhA7Ix
	bG16KTE5lL0aX2mkInG3pR9lf/wxENd1Axeg4e7quxyZaRUMh2AT5bCezOu6np0h
	E4rpDnT0iZqfyv8mpuQ6Bo7LWJTnqU59wc1wTn2NgSg82in0boWMelC6MopYJLfR
	FBzC/A9CMDZ0Cl1gU5bng==
X-ME-Sender: <xms:fLevatAtpNwjV8v1IIRPID8czUslX9YJ-jld7RfPPVaKF1hUdPIq0g>
    <xme:fLevatxlng02Hph-2DsRVDemB-pOol9zZCMmICL5WyHrFa31qEZdcZ3CcFfXCWtpV
    3Bc_fT7DvwjyoC8CPMuCw0O6d6zEEq-8WWLNv-giCIyyey_KcI>
X-ME-Received: <xmr:fLevaq3iCLZjMq2CaJLdL17FOtAouOHtTq891ZgmzFAmRP-eIvO5Js4I53YcYPhjTwl4mS71MsEj5n8g8TKdfL_sayfrnx8>
X-ME-Proxy-Cause: dmFkZTE4wIdqTkjjG03RwoqjiFBibjHgix/nYcXUNvaTlmpxqLITX+LHJh6qmLOC5RB7dV
    QRUay/vETmr8b7lfoZtlqCO0qXT2hg3j0xtpW9eHHWOOq2yQWtE1r5HiK5YdrxfbgOaMLN
    xPz350jT7cNza32/KIMBbq7ZfVM9AK+FakLs1iQanJii6PLaaf2TbB06JOUEZtsE4I06uV
    Nho6n14L+GLqpDBUaGfe/YeyW79GnOawXr1CBXFP8ctnxzW9iuYYT7Fo21egf23AQP36U+
    ahdMPjDu9my7TMFeuynp7I8PZSEf/AH715poQwSq+sJwDkeMS6BeMQS0hBvwWpcJXpI8RW
    A6x91VtQOuOIvyTFFbzSPod632Ns40CgNnKgKd6MD7IDW9Nh/STR5MABm77O8X+7Bdsy96
    I9PmLF5TvUVZh4RhQy/PfSQ+NMoPWpYRktvckWbevYJG0UcUcdiH5AFTTF1VQx+6kBQiWH
    i+CSFKxAI2ozkR4Y7CdFd+RMQhJ181CSLFHiiIausBaioTkuBT44xKmz7Vz763jhZTM1Tq
    cOfxw+6GgQ/zcycUrYTDDq9vBCRrRAOU5j+cNjXxK3OWnDMvVBzVFdXYaMhAk9rfLKMyBn
    fZyNjCc3e1r9dstpVXYlYYUs75FLBVELp+YYo/aF6LrZDzCzssNJ8MI235kg
X-ME-Proxy: <xmx:fLevatxfmwnQCrfFoS5NmzRXl-8nDd3BlItGjVbslt3hXsp34M704w>
    <xmx:fLevahFNzB3jc9IK6SDyDQLcHTOaXhlicZQsAsfyEqieeMhvyMG4mw>
    <xmx:fLevagZ2M1moescsFCS-LmZpdqyjMUzRVPJfU1ey1N00ZmbUmrs1uQ>
    <xmx:fLevajAAVawq8ytMNTBgbh3NJERE7Cmak7HZ0cFJpnUT4w7wYpL1Hg>
    <xmx:gbevaheCP0kgY0OVY7GpVj2v0gPT_H7_1KSjdGaELaW3hWTW5fOM75lx>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Sun,
 20 Sep 2026 06:37:46 -0400 (EDT)
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
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, "Rick Macklem" <rmacklem@uoguelph.ca>,
 linux-nfs@vger.kernel.org
Subject:
 Re: [PATCH v5 11/11] NFSD: Remove DRC checksum and payload_misses stat
In-reply-to: <85a7313b-6c69-41bd-9a12-18ab4fec4b5b@app.fastmail.com>
References: <20260918-duplicate-reply-cache-v5-0-b6aba9ebf2f4@kernel.org>
  <20260918-duplicate-reply-cache-v5-11-b6aba9ebf2f4@kernel.org>
  <178977475436.207413.9806283444174908649@noble.neil.brown.name>
  <85a7313b-6c69-41bd-9a12-18ab4fec4b5b@app.fastmail.com>
Date: Sun, 20 Sep 2026 20:37:40 +1000
Message-id: <178990066075.37859.2365005183271933047@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>

On Sun, 20 Sep 2026, Chuck Lever wrote:
> 
> On Fri, Sep 18, 2026, at 7:39 PM, NeilBrown wrote:
> 
> > If we get a request on a particular transport and it is a good match
> > for a request that we recently replied to on the same transport, then
> > the chance of it being a timed-out retransmit is 100%.  A client that
> > re-uses xids that quickly is buggy, isn't it?
> > So if nfsd_cacherep_acked() then I think we can ignore the request.
> > In fact if the "found" reply was sent on the same xprt that we received
> > a new request on, I think we can ignore the new request even if the
> > reply hasn't been acked yet.
> 
> Just to be clear, by "ignore" do you mean "drop the request" or "reply
> with the cached reply" ?

I mean "RC_DROPIT".  If the connection we sent the reply on is still
active - active enough to get requests - and we haven't seen the ack
yet, then in a sense the request is in "RC_INPROG" and so RC_DROPIT
is appropriate.

Even if we *have* seen the ack, I think RC_DROPIT is appropriate.

NeilBrown



> 
> 
> > Everything else in the series is good and I really appreciate how
> > thoroughly you have explained the logic in a lot of places.
> 
> Thanks, your comments have made this a much better implementation.
> 
> -- 
> Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
> 

