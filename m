Received: from fhigh-b5-smtp.messagingengine.com (fhigh-b5-smtp.messagingengine.com [202.12.124.156])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A159B420482
	for <linux-nfs@vger.kernel.org>; Wed, 16 Sep 2026 22:47:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.156
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789598841; cv=none; b=cuoMgSwcov2xkp0t2Jd4zQEBQAYen9prXSJ6vHuesCC0/t5KPKsMwk0XfmCrE0jTmhG55udeHgFDjzRZDqbQUz53trrTNwFmyhiPVItmd8Eji5KCbY5S1MBJyGjeHu+wwLrTYRwneA1sk/FUtBfAB5mPjY/Oj+2yJt8jaSnaj1M=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789598841; c=relaxed/simple;
	bh=Ks/wz0RhhewGPpEG+Ev6ELYv9aIyMHZx6iOjjFEVGlo=;
	h=Content-Type:MIME-Version:From:To:Cc:Subject:In-reply-to:
	 References:Date:Message-id; b=POczeYLr7DVvQZv75NSR2i65U6bZF3wKB/bje3ih2y80x6F2SkAvheFFfKyJs1qGZc7qum568GT1WBs1N7T3h1qW6KQ8Joz88/CosxOJsB+64Kwl4pbmiT12WE+15OISJ6wGXLlpna24i5J3s/g+Afo8AZ1d8R+E+oLqQpaXMFM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=VExDXEeI; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=b8TXiF8/; arc=none smtp.client-ip=202.12.124.156
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="VExDXEeI";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="b8TXiF8/"
Received: from phl-compute-07.internal (phl-compute-07.internal [10.202.2.47])
	by mailfhigh.stl.internal (Postfix) with ESMTP id 41A997A0103;
	Wed, 16 Sep 2026 18:47:11 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-07.internal (MEProxy); Wed, 16 Sep 2026 18:47:11 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to; s=fm1; t=
	1789598831; x=1789685231; bh=nyFQN+RhbZ1Touz23AfQFmRcFjoNN2S0fix
	O2SBsX9I=; b=VExDXEeIn0JsPD9TbpQcCb73jPvrXognhpNcFA2ehS0RtFKhUKp
	1Cqs9cumUHoijH728V+EzllwvuPVegEiiugTvOK3QJIdsGmgWX852PKwMNMsjTYU
	ey61FnnZ4RUy0pMkAuFxUChFsEeLTFcwJt1F5znKT0YwMU8Jr2cqCsYO1P6sDZlG
	IUtLOJz0ZejuaWxozqyxc17Ng/qZNL2emrr5tZFh0DiOU/QMtz29/x2EwHTMxLU/
	mp2Jrmxns+k28XffecrUx7x0t0z6klN3wBIY0TBujxT5aGjRg4vfBF0e2Ut1eCW6
	xsYEeDfp4FZLqce2Eukf+lpqLHCglB5kXuw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm1; t=1789598831; x=
	1789685231; bh=nyFQN+RhbZ1Touz23AfQFmRcFjoNN2S0fixO2SBsX9I=; b=b
	8TXiF8/a7upa/uBvwBjn1OQsrIEJ6JQ3g2Q1MxMDeM/HRlCs3CKbEBXXi51pgZF8
	Q9ziUI55BZEOtehcJ7dY1BsxaKIW9aEQpq1lRUknTxYweQKuy2l1hVi6Uy/3QuCm
	9VY17Z8xexO/V87pD3m7nhTuUq+82pOYOZYzuH0Uux6YhVZ44pKi6SyP53mKforU
	NyhlaP3u5KnSGjFaYm0R1ZCukdmo2qJ9RClv0cD81oPKfLMCpUyebJBOeks4nSdv
	mgIEG2xS6/9PsxrzaszxG5ywuIu3sqwaTPJEUPz7S3ZnFOVdq0SO9CbZDgYy1urO
	Y3VepkvBUQeouDDGebHLw==
X-ME-Sender: <xms:bhyrajn6TlQ2Kon5wyEwbW5Z6NJh2nq-wIlwTH0EQ8XIJhb1cdlZEQ>
    <xme:bhyrapHEyfPxHYgNr-ff2F1jKZv91ByKho1cwPLCIAZXenvP6vLLk2fKC_7X9_6y7
    Ir5hAfCNM-DdNOLozEbZGFeoKNqfLgm15LReWR5MTJNQNfJKdY>
X-ME-Received: <xmr:bhyrar7TcvK2kQFXYt6vkWliZGJoyhoev7yF8Ip27bnRH44OPx_vEHPd2nNL-WOz_jggXrJ4zdXa48Ay-YEuTRvw2TMKXRM>
X-ME-Proxy-Cause: dmFkZTGFM83m9KAjWKJn4vz1kmj5Rym/bx30F9TCiyIlwG5yGZeWx+lnrkoFnG+ESnm2Di
    mqaWKKqCd2SE58JH85MOwvVKFJJKs4eRhcFHEx9vM7o7PSViVOZbMV3UpENgPTPK1GPusP
    RatclzNQPRyaJGThyZIA42KMhO0QdFgSPSnAZTVCnAWEkv2wqTRTvlWb7cMG6LeA/9wI05
    3Tw8IIdZNdFDojqO4MNQRSBBce9cJz74vrDa2zKihu4nAvdHhMF0Ba4cxSKtUdjHgNdMnP
    jwhqqUI6I7pFz9wmSNMUHeo3jb5RCCqJ6AcMuQnt/k1M1GS5D8Rdh6xZjFj83xwuUCGgdY
    G5lwT9RYgGbW4I4YLC4MAUESAOzwFeXBpDNL9KBIqKjV8uJxNGJdAwKBgTftIvRT1S/9mk
    hROtztSekzlYPjH+zDlbLfHNULq+DZ+lBP2PipQBJMyRzmc0fhVws35iwTgqwdwzO5BqDS
    bdybVanV3D10Mmt99j9e2Gw9c/vOBm19w8vVntNAR6Y6vG5g9ZIbstI883ZDUA0GsphSng
    hsGeisYkU9HcgT6O2JJ1bydalfRdG4AOl05ptD0I/XAwPkB8HjrqU0KgwVAYHQFvJh+AQ6
    EFq4qEB4dkAExbaY6PJPLIRTctv12diM9U4Eb+U0fUz1S3UD24k6KYuusdjw
X-ME-Proxy: <xmx:bhyrahlK-OriMGlDw38qi5UEWjQAAC0pMjUpaAh6-mkyOpWXeKERDg>
    <xmx:bhyragrXCmO3IPOqtmE0eEAUPA8WLatI7HUQIcka4ZgNcfTr4wFWAA>
    <xmx:bhyragvrVSTvgd1IpuHb5aJ75qxMlrimgXUiFyUPUJXdxNA0am7X8w>
    <xmx:bhyralFRv1VlwdbBb4S-NeyFwoLq9dmCe9aZUj75P2e4JeJFGRxMdA>
    <xmx:bxyrajRtYYiPwbF0nCIfv7JfS5a0qpMzkyhNHa_xlLy7VhHYie0fQPsA>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Wed,
 16 Sep 2026 18:47:08 -0400 (EDT)
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
Subject: Re: [PATCH v4 00/11] Improve the scalability of NFSD's classic DRC
In-reply-to: <038f948f-64d7-434d-ae51-2e692c3b71b9@slotpi15m67>
References: <20260914-duplicate-reply-cache-v4-0-bcf9d2628a94@kernel.org>
  <178945353329.207413.1555757673936041397@noble.neil.brown.name>
  <038f948f-64d7-434d-ae51-2e692c3b71b9@slotpi15m67>
Date: Thu, 17 Sep 2026 08:47:04 +1000
Message-id: <178959882426.207413.6596745257975294056@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>

On Wed, 16 Sep 2026, Chuck Lever wrote:
> On Tue, 15 Sep 2026, NeilBrown wrote:
> > In any case, There is zero chance an NFS server will get a
> > retransmission of an NFS request over TCP within 120 seconds unless the
> > admin has significantly reduced the timeo / retrans options.
> > So maybe there is no point caching these at all???
> 
> Agreed that 120 seconds serves nobody on TCP. But the retransmit that
> matters arrives on a new connection, after a partition or a client
> timeout, and by then the old connection's send buffer is gone. The
> DRC is the only mechanism that can handle it.
> 
> 
> > Or maybe once we get this more efficient pruning working, we can extend
> > the lifetime for cached TCP replies to something potentially useful,
> > like 15 minutes.  Or more.
> 
> That's the direction I would prefer to take. We spent a lot of effort
> on the courteous server so NFSv4 state survives partitions that might
> last hours. The DRC should cover the same window for NFSv3, if that is
> at all feasible.

Thanks - this is useful context and feeds into the design I think.
Particularly the LRU and pruning.

I imagine having 3 separate LRUs for cache entries.
1/ the current per-bucket LRU - entries on this are prune after
   a timeout and when the size gets too big, exactly as present.
2/ a new per-xprt LRU which tracks all the request on that xprt
   which are awating an ack.  Entries are removed when the ack 
   arrives.  This means a per-xprt lock for the queue, and taking a per
   bucket lock for each entry we need to remove.
   When the xprt closes, everything needs to be moved to the third
   queue.
3/ a second per-bucket LRU much like the first one but with a much
   longer timeout - several hours.  This is where entries go when
   the xprt is closed.  If a new request arrives which matches the
   entry, it is moved to the relevant per-xprt LRU.  Probably it is
   removed from this LRU, then added to the per-xprt one when it is
   sent ... maybe.

I had concerns about the changes you made to the LRU code - not a
concrete sense of a problem, but more a sense that I couldn't understand
what was happening enough to know if there was a problem.
I think the above design, particularly keeping the old LRU as-is and
adding new LRUs for new needs, addresses those concerns.

> 
> With acknowledged entries retired, that costs only the entries whose
> reply the peer never acknowledged, which is the set a retransmit can
> still hit, and the shrinker still bounds the total. UDP, being
> unconnected, would keep the short timer, since nothing else constrains
> it.
> 
> TLS will need some attention, since a TLS session does not publish
> an acknowledged receive position. That will have to be follow-on work.

That is reasonable.  There must some way to get the detail out, but
leaving it for follow-on seems a good choice.

Thanks,
NeilBrown
