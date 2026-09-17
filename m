Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 171584E3249
	for <linux-nfs@vger.kernel.org>; Thu, 17 Sep 2026 15:04:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789657487; cv=none; b=MU28cEiLzYiF27+PphlSwOvLATB702GfgPWyKMO8kxv6XmMT2SA92k3W9ta30ZSXLidq0Bfb4WBo2MEPh5sSeb6VVl4ZlVJwB0748EwT/e4X+6/Q0GCaWM7B4nMBM4nfCCgMmWUJOWcUsya0Z6pcPDhvo/Qcg8v/yxbIpRIAxy8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789657487; c=relaxed/simple;
	bh=e3EXMGHCGASNw66iRvSWGJd2/GVpv3UgoFkGTUng/z8=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=FBsCni33WywxiW9YqUmdFbY3G/WG+9pFXtTuXDSBV0ACmZdyscyw25euknMoEBedmPGcrfOYMH7yCACsNO9QpPU2P7VPp0S4CKY4LA4jAVy2hXuG2qs7fOV55u9SqAe1i8T2qX2qwmnMJdJDpGWMQtlmgqsFAlHyPw1ShrHTizw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=XRdTPCaB; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="XRdTPCaB"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E0EC11F000FF;
	Thu, 17 Sep 2026 15:04:33 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789657474;
	bh=HRGo5RYhGuwaq89fXBR29vUlBlDn1tgTwt9A/PFyHZY=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=XRdTPCaB3HfAB3ZfD/LH0UVwrT1d5mjDao7nFlpdBxyFMrDMmATEs5by447XklAJj
	 pFXP6twHHO/KxPIG+QuR2Gg9ti3oEnEkcL3+eKPp5giZALiWP4TKLk0Y1IPZyG5uIK
	 2tzMUim0tyNcvh4od/aLhKJ59IFujY5telO8xBXLRvxg11zQ3MFwo1Vtx/J9g+CEmE
	 tZUfQmExAEUt9soOSFHZJoLAV1+KqpKwaVXnGSZzOd/yS2eX5CZmgAxGBd6bdU1URs
	 EaMcBjZAS7Aywgqg6pP0pjTceQZHwzhXzgXvPwQcdr82GsUNBsScm85UFGT6Zl/7zf
	 qgb1kSZ5at32g==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 26CDBF4006E;
	Thu, 17 Sep 2026 11:04:33 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Thu, 17 Sep 2026 11:04:33 -0400
X-ME-Sender: <xms:gQGsahvhFxtF6egqcEY5NtOUgueF4Vz-zBUSxAkd2Oti6S1CU5VcgQ>
    <xme:gQGsalTu28fCRMASJuqNXUkjWKCOGnSfBJRUxyX18H9cuyLgQM-qi1eUwBYoJHfzx
    iTA0gUIj3tqFtt9jOl3kHsLqjpP_cJJbs80qHySdpv2vmnodDa7EMKW>
X-ME-Proxy-Cause: dmFkZTEN0kZmriTB04PbsqzER2iLAza95Id6Pd4yuCmW2kuVIsktoUInk84TgEKOGwayPw
    XYa+NRzEVDh+2jr+kpZfxd3kewCEPSfA2XT973wq7XvUQYB6ZupV19X6/wOBEU+oYG5/XR
    DmaUI6jrhE/E8bjjwIgZc/QTz2xvqN0psxpAzWEiv0FWABYDolXhQ4qtDzAx+5yQsR2DnE
    l1BqxbU6QKO5lXDKs0k/qjVJLwoDV4LrEBy7vEKD6lq+I/uTcO8harW4MfSzK+HKNSQvvB
    p5Jek9NuBlSOV0CBEpTSWnNGK+SyqlUdcgv6iCNDSdU8KUvSSA+OYtY30RPyV5ifNtHWUo
    jfDPMo72P6/suizry3cjBcjMw81eBs92Bel8150SR6uclznqUFA9mHzKfIbF9frp/nW+2c
    oKRmFd+rzbbd04Q2YfyDwTsSMtat4h8dF0VoTHPg4xUxk/YsrUapv+AJQhNG4c5SMlPCtN
    msCvG3mqpn23B8CTTbCKdKULeLBdesWXvyrrb3IF7YObm8nt9K4dGEh53nhXUFApjjZWmN
    8yOs711JvYymsi9ZWDtLB+rLgkoTq4cvHvSOWDdD4GynOmvWvL6KkmYoaT2Wf3QCIy8yut
    UZZ138EKI3wcZk/XY4Nir/cD+XbPzUx/L9xEQUkwB8NQDOIVnK2Eje6FHNRQ
X-ME-Proxy: <xmx:gQGsarGdxyxHK4T6EzANTL8dFAT8RT5AvJHLgINwPemN_52kwN18Lg>
    <xmx:gQGsapCYhtRXfQ5iCe0tzR03RG_wz1Zttgek-2_ZsKQsvxCQ2MPTuA>
    <xmx:gQGsarUp1TalWIfVTulBYPeiolUHQtu-9fZl7K4qjo42FOhnRpkl4Q>
    <xmx:gQGsatq_ZJc6Ga0zbWaNL6PZLUcJf0xxjG2mVsqKYcJ6v9seM0YclQ>
    <xmx:gQGsanTnFVdcDtmB6AMATdRBYud8Gzl7QlRQjwy6L9Q3XM_S_deNRIcC>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 0A4E6780070; Thu, 17 Sep 2026 11:04:33 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: Aiyhdl_yIhBk
Date: Thu, 17 Sep 2026 11:04:06 -0400
From: "Chuck Lever" <cel@kernel.org>
To: NeilBrown <neil@brown.name>
Cc: "Jeff Layton" <jlayton@kernel.org>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, "Rick Macklem" <rmacklem@uoguelph.ca>,
 linux-nfs@vger.kernel.org
Message-Id: <4aa8dccd-256f-4f6a-8be3-dc832ffdaccf@app.fastmail.com>
In-Reply-To: <178959882426.207413.6596745257975294056@noble.neil.brown.name>
References: <20260914-duplicate-reply-cache-v4-0-bcf9d2628a94@kernel.org>
 <178945353329.207413.1555757673936041397@noble.neil.brown.name>
 <038f948f-64d7-434d-ae51-2e692c3b71b9@slotpi15m67>
 <178959882426.207413.6596745257975294056@noble.neil.brown.name>
Subject: Re: [PATCH v4 00/11] Improve the scalability of NFSD's classic DRC
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Wed, Sep 16, 2026, at 6:47 PM, NeilBrown wrote:
> On Wed, 16 Sep 2026, Chuck Lever wrote:
>> On Tue, 15 Sep 2026, NeilBrown wrote:
>> > In any case, There is zero chance an NFS server will get a
>> > retransmission of an NFS request over TCP within 120 seconds unless the
>> > admin has significantly reduced the timeo / retrans options.
>> > So maybe there is no point caching these at all???
>> 
>> Agreed that 120 seconds serves nobody on TCP. But the retransmit that
>> matters arrives on a new connection, after a partition or a client
>> timeout, and by then the old connection's send buffer is gone. The
>> DRC is the only mechanism that can handle it.
>> 
>> 
>> > Or maybe once we get this more efficient pruning working, we can extend
>> > the lifetime for cached TCP replies to something potentially useful,
>> > like 15 minutes.  Or more.
>> 
>> That's the direction I would prefer to take. We spent a lot of effort
>> on the courteous server so NFSv4 state survives partitions that might
>> last hours. The DRC should cover the same window for NFSv3, if that is
>> at all feasible.
>
> Thanks - this is useful context and feeds into the design I think.
> Particularly the LRU and pruning.
>
> I imagine having 3 separate LRUs for cache entries.
> 1/ the current per-bucket LRU - entries on this are prune after
>    a timeout and when the size gets too big, exactly as present.
> 2/ a new per-xprt LRU which tracks all the request on that xprt
>    which are awating an ack.  Entries are removed when the ack 
>    arrives.  This means a per-xprt lock for the queue, and taking a per
>    bucket lock for each entry we need to remove.
>    When the xprt closes, everything needs to be moved to the third
>    queue.
> 3/ a second per-bucket LRU much like the first one but with a much
>    longer timeout - several hours.  This is where entries go when
>    the xprt is closed.  If a new request arrives which matches the
>    entry, it is moved to the relevant per-xprt LRU.  Probably it is
>    removed from this LRU, then added to the per-xprt one when it is
>    sent ... maybe.
>
> I had concerns about the changes you made to the LRU code - not a
> concrete sense of a problem, but more a sense that I couldn't understand
> what was happening enough to know if there was a problem.
> I think the above design, particularly keeping the old LRU as-is and
> adding new LRUs for new needs, addresses those concerns.

You're jumping ahead of me a little. The next series I have in
this area implements per-xprt DRCs for connected transports,
and it provides some of what you describe above.

So shall I post a v5 that includes that work, or do you think
merging the v4 work now (with adjustments) is acceptable?


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
