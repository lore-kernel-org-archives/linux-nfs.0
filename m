Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 66C1738F930
	for <linux-nfs@vger.kernel.org>; Fri, 28 Aug 2026 20:37:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787949480; cv=none; b=ceYUSR+18WdViUvSDtOVT3pa+nKxNcionGdmtJyhUE176KVtoPr6CIkep4SHCW1J2Ca6LHpZSMToSOceyfdavyqR57stTh4kX5ohIVUZtj4aMJ7OAePv6VJ3fJXueQmYlYd/2AHEHNjubZdhx2f/Vzg4zY6lmFodL6e3JfxBp7I=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787949480; c=relaxed/simple;
	bh=dZ8AdAUfkVT0+N9y4enHUj+R1+IseGL19arSpvxirPE=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=G7Ayibh8eINBI4D3s4Q3BujXRKrYSCHhvI2mmHUU2pi2cVrOSQSCnCSyoXe6X5gabBG3ex4FUzDxprrqpAdwQV49RzXIAICr8qYswQJfGBWKskskiLffHuOgO253pIFTLLXyzftDP77tjsYHaDxGK6RdsCu9resQfmP39dOe4Zo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=QxS7PJuh; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="QxS7PJuh"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id AD9681F000E9;
	Fri, 28 Aug 2026 20:37:58 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787949478;
	bh=Y6aOxu/rMALnvS2YWUVO6FxdZbDhZJXCoJ4CNO3Pb6M=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=QxS7PJuhHSkfU+z7RYfW0IwOTPdE85gucWJdt8T2EdVaW7AWxpByOpQiiE/Cqehy1
	 l1C9y9H8MaY4VHeY+/nMY7QqDFkG7RHw0QviArJQrVP1D3prZo9OmgAciT3GWU9Grd
	 Kok2WNyG/t0LGE6LKyGsBAiZb70nbFejZBj0wUKoWvRtZ1tGRF+ZeeFXqS2B2SPDrI
	 qxbkbbakXFt+NrMUlLBuTEBQUJkKa0InZ2Fy0LV2dvyETUJzIHKnFeBxyz0/izsvSP
	 4N85ahkKNp5MA66oP44GxqVbsiMjIqE2krqskA7zRGKH4oVfSzFRyrbM4T+imZMks2
	 zrrgZyJJpb+XQ==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 9ADD2F40068;
	Fri, 28 Aug 2026 16:37:57 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Fri, 28 Aug 2026 16:37:57 -0400
X-ME-Sender: <xms:pfGRaqgPtFnkgsVV3ESn30JAdxpI5Gehag2FqAQMeX94OE9O0BRwGQ>
    <xme:pfGRal1uKvJIP5JmcykCiMr-3GYeZukasdgmpOaox4M8foI2TmRFZW7j62e54fIHm
    7zvufRSixmNzNt5xkkZqqZB2SUmDzs6p0t9A2A7OGStatUaElS1_iZK>
X-ME-Proxy-Cause: dmFkZTGbTBtTBVmFWnjxoqN9wZqAOMP0d3I7ALvTBDjn/vk6VROJc3gA9yJ7mauR0GKMLi
    gwMg9BZ5U+wBxtR1140Pkdbvllb0ToP8eGVw7UcKtZrg2nWAMEbJ7HNcf3wbLhSIT8IvaM
    JcImfLeTq6F/fghtFWK8iY65+JL7PSofKFb8oEhBUj63uEQaMSKgSXD751MyLRIRipxWKJ
    8zNoBa1UGWl8fXaE/VJpoWbOwIcplpbYM6ql1RVfmxjIq+AUDXPJHiyCII80HtG3NoVP7V
    sisH3wqb24La1oP5R+hCPTN8hmVYrcbFUsJUCVCuon0oSm5g4e+Y1FuUftvIz79rGFw1a4
    tvnPuTErCml/5tp0gzYVsY3nnGbtechBjvyBQSteZh8G3HCzjsXsU7EvO8+uZltaQbfDs0
    R68TmdS83AmU5MDO9bV3KOSPTCJpDJog6WbkcyIdJoZbh7rdx+y4mpAvls3QCz7AhEemDH
    3R27TjJlKcPzT6dQA2rPFGqsdbfhZl2Vk9D+8XzmnE1fkQEnDIH6oJBA/ITDVFRPOPnPq+
    hgs5FRVJMYtvFftQyEV2dL1lSQaWQt2kLuSUAqjWEiKoSPqX4SNHdwiqyn1bv5V9SiSC7n
    7l6SEAICLPJkurf4tNL/VhLF9k5dXeKJW0KV2/CK2tX3BDMnKjx2J5fnP4ow
X-ME-Proxy: <xmx:pfGRavZl_y2ae4dPsTMMjTKLN_Apw-hf1h_hZ1gmsCJScBIjtYeMZA>
    <xmx:pfGRavHb0Oxw_ktvC3tY23-USvk3ILTdsBIltLKpsItmcBGiH-Vluw>
    <xmx:pfGRagIAaYJ6-0DI8aR8mHymC4SUeK4-0Rlr0BalTOWhikLQD7YVmw>
    <xmx:pfGRaqMs3OyOwXup5DDBXOgbU15S60gzWr91ZtHSZCtEOBUoMkrdSA>
    <xmx:pfGRagnP951ryJiU_VWCeOCMjCSSuyVzMMXmzQFirVB6gFFgYFfjJKtK>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 767A77811F3; Fri, 28 Aug 2026 16:37:57 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: ASVo6Y-fM8_J
Date: Fri, 28 Aug 2026 16:37:39 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Jeff Layton" <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>
Cc: "Rick Macklem" <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org
Message-Id: <56384440-7fae-4e40-9c0b-fb2162828522@app.fastmail.com>
In-Reply-To: <a99df73fc1db0f976da665cfb4ea39682f680118.camel@kernel.org>
References: <20260828-duplicate-reply-cache-v2-0-25069e660a7b@kernel.org>
 <20260828-duplicate-reply-cache-v2-5-25069e660a7b@kernel.org>
 <85acfa01848e5d7829ca18ad8864410fbb5e12b7.camel@kernel.org>
 <10c97c34-1061-4aa2-a5b5-234e4d01e894@app.fastmail.com>
 <a99df73fc1db0f976da665cfb4ea39682f680118.camel@kernel.org>
Subject: Re: [PATCH v2 5/7] NFSD: Evict completed DRC entries via implied ACK
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Fri, Aug 28, 2026, at 3:15 PM, Jeff Layton wrote:
> On Fri, 2026-08-28 at 14:59 -0400, Chuck Lever wrote:
>> On Fri, Aug 28, 2026, at 2:38 PM, Jeff Layton wrote:
>> > On Fri, 2026-08-28 at 12:17 -0400, Chuck Lever wrote:
>> > > A completed DRC entry stays in its bucket until RC_EXPIRE elapses or
>> > > the cache exceeds max_drc_entries. Entries whose replies the client
>> > > already holds lengthen the bucket and slow every lookup that hashes
>> > > there.
>> > > 
>> > > RFC 1813 Section 4.5 observes that on a connection-oriented transport
>> > > a duplicate request arises from reconnection, not from within a live
>> > > connection. A fresh request on a live TCP or RDMA connection therefore
>> > > means the client is not retransmitting an earlier one. UDP clients
>> > > retransmit on timeout over a shared svc_xprt, so eviction is
>> > > restricted to transports marked XPT_ORDERED. Even there the evidence
>> > > is not conclusive, since a client with several requests outstanding
>> > > sends the next before the previous reply arrives. The cache is
>> > > advisory: a premature eviction costs a miss and re-execution, the same
>> > > outcome memory pressure and RC_EXPIRE already produce.
>> > 
>> > No, it's not. The DRC is necessary for proper function, and if we drop
>> > non-idempotent requests prematurely, then that could cause spurious
>> > errors.
>> > 
>> > Or am I misunderstanding what you mean by "The cache" here?
>> 
>> Not talking about the NFSv4.1 session cache. The old DRC has
>> always been best-effort. It cannot be relied upon for proper
>> function, since the DRC is non-deterministic.
>> 
>
> Yes, but in this case you can potentially evict this thing well before
> you actually need it:
>
> - client does a v3 RENAME (anything non-idempotent, really)
> - reply to the RENAME goes out just before a new call comes in (WRITE
> or something maybe). The RENAME DRC entry's timestamp is a few jiffies
> earlier so we evict it.
> - connection drops before client gets the reply and client reconnects
> and retransmits the v3 RENAME
>
> ...hilarity ensues? Maybe this sort of bad luck never happens in
> practice, but I don't see what would prevent it.

The same thing can happen if NFSD is handling a thousand chatty
clients. With fast networks and fast storage, overrunning the DRC
is more likely than it ever has been.

I've got more patches that moderate this behavior some. I could
post those as well... I was hoping to keep the patch sets narrow
to avoid overwhelming reviewers.


>> The point I'm making here is that items already get evicted
>> due to memory pressure or because the DRC size is capped.
>> 
>> In particular, if you are actively removing items that are
>> very unlikely to be hit, that *reduces* the likelihood that
>> other, perhaps more valuable, items will be evicted due to
>> memory pressure.
>> 
>
> Sure, but usually we evict the oldest stuff first, and we generally
> keep a big enough cache to get past the point where retransmissions
> occur. This patchset changes that and will evict things earlier.
>
> Maybe that's OK in practice.

The reconnect case is the only one I'm really concerned about.
I'm not brushing aside your concern, but missing a non-idempotent
reply during a reconnect storm is somewhat rare, and is already
not 100% deterministic.

And we have NFSv4.1 now. For anyone who is deeply concerned
about this race, NFSv4.1 is the only total answer.

-- 
Chuck Lever
