Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0ADA929992B
	for <linux-nfs@vger.kernel.org>; Sat, 12 Sep 2026 16:22:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789230155; cv=none; b=tLqeM3V6hKRm/96DpyI1eDuj0hv3wX7nTJ6V5BkNjvVRNY2Ew60hq4UtDQCBX8Mob8J5Tz44TEPSKT3aOFEWnT7Mw2KD405TG/j6w//Ogd4ebkS4cRyMI7vwfCuWLqy9A2A3U432DH8o09qZrNk4jnjP0rni+KrvN6NGzXNS7Hs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789230155; c=relaxed/simple;
	bh=ty1oTuIhWyfYJq9im7BgfkTSxTZIzRTmrfc6YPXAPxM=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=pwLl1h6JWuvHrn/0hs9beyQEwmRwQsHNQyDXGKyOTJYIpfbqAtNVTWJn0xy5ECvbcRaJZ3IANd5YfBniOyrfKFTxo6HdAXb1NZmYHaPGAG+TJhQwTDcDIEju48C/1EntmoygK5MWGtuF/OpW628IViMmJkUtyPvlVRA4GnxTubk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=gzpdl5qW; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="gzpdl5qW"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 797E31F00893;
	Sat, 12 Sep 2026 16:22:33 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789230153;
	bh=mC494RNCXrNNmg/2W3A/mUCS62LoCv9xQl44oxacO/g=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=gzpdl5qWu9dA7pQV9gVaowaNFru+iUlXNTERv3wpuDy56EWT49ueB2gqBJfDz1TFH
	 XQAqnjI2709d6t3geammq8toxu30hX2TlbkkZD93TF+Llr8Z8H3jb4STeTsfLnQEiu
	 CjhOr3Y3Fje3Vug1dNs7psKxCFthuUCu2pKtZhlWE+fxnVsyKY7rOYImycBonZEwYO
	 piQWOyf518x3lnCSx+DXAhR+/6rR9hduW+cqyrzTTRFJIO7KeKK9Sgjo/qJAbLD8I0
	 6zTP5wwy+1qzNJmVj0+zCHKObFyJ9uWEQ1nGCzcqr5X8hr+u8mOd7XYUOVL7Sn05U3
	 KRkafOLaqhLfQ==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id A3ABFF40066;
	Sat, 12 Sep 2026 12:22:32 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Sat, 12 Sep 2026 12:22:32 -0400
X-ME-Sender: <xms:SHylakSzUy1PeFm4bU7Dju4PT6-kfAmeF74EnDs6WlYi8BV37sePcA>
    <xme:SHylask_8ZVGacDDcbM-i1d80S9SrOFu6nodcCHkT_qU6up_DukKP7a5zfo5az_P8
    GALi7HhDWmQ9u45uzsrglamzFxZV4e22URgTOvqIsDqDP3WXrkDIUU>
X-ME-Proxy-Cause: dmFkZTEmHOCxqxUiPyomvazu/RN9tX15LrGQtoEx5KHkyteOsrW+/0DFl3zOz9zBKN5xQt
    z9six/gDDZ49GhxmujD8t6k52FpA5OH+pp6HM7ogfKJ+V6ZrLqAXVrmA4RX3uuamCqsFwm
    r/dwt1GkvNr58pbX9KsrUS0nJ8/e2Lcs4qyUYZUUlPh+0/YBqOud7Uo3/QFWoFg8jr1n5h
    246SRsRRS/oV2Bk1rZw0QM4C8V0YVnBloQWlWjoDHRZm9cCqNXxljalNgaC8NnnkePVGBE
    aBJ3K9H9AAqXgS6vr0Pok+GIoMCD/6z9a6LALbId/hT3IHt21vcTSLowCdpF+q5CTGE7E5
    YWMg2H7sWAcH9W/qc8V6rLZpWTvcnS/gekW0CHgdMkd3lKtkqlOm+EP5xWX2z46XZtGKJH
    B79GyAkzLjnAWg1zm66i0no8OvhwZ1iI2UmeoM3/BHMF23DBRl7rRtKJFIRVp6vAsgSwVr
    fDz1ddRZtP8qAIs7wxqem1mFa9ICJtOBPRTXVrjL3lJ8veslgUqFKTg5PNOSnjaM78ZD+o
    51wUZ6Lu7EwOcaHLwItX6Vi/Ygj06VfxCHOIdAZXpG+T0LoO+ZDvQCidVsmSR8ab9Z4bnK
    0VjHd+x/S8Lao+yMCbE3xWgbyMVrkZL9YwCtbzcywwDg+wAlMuFLAsQgbclA
X-ME-Proxy: <xmx:SHylan3tztsFl5kuAEXuwmeCcWotpC3xjavmDF7Lqa0bM-IH1YAMqQ>
    <xmx:SHylap5Aah0zt5Ucwt3QRbXMuvHtLCBkNEE3f5jsPnUZID-KAq9PjA>
    <xmx:SHylag_XQOQ17Us_O2ryA45Iglwsyh7JMAE77jybkWunUWLhlUXZQw>
    <xmx:SHylagVngShFjyUsHTPrMyJcyWDIFknD5cLVvjKmY0GGndfh_fHW1g>
    <xmx:SHylajpWrF7JBSfw1vN-cTJTLuhD22t5EAlD0TcWyqHGZyovJDbcqa7f>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 866D3780070; Sat, 12 Sep 2026 12:22:32 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AJxlnPHrJ3iN
Date: Sat, 12 Sep 2026 12:22:08 -0400
From: "Chuck Lever" <cel@kernel.org>
To: NeilBrown <neil@brown.name>
Cc: "Jeff Layton" <jlayton@kernel.org>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, "Rick Macklem" <rmacklem@uoguelph.ca>,
 linux-nfs@vger.kernel.org
Message-Id: <6293796e-8a68-4032-90f3-2adfc1386e55@app.fastmail.com>
In-Reply-To: <178916883696.207413.18145968545647470391@noble.neil.brown.name>
References: <20260910-duplicate-reply-cache-v3-0-31532a4c7449@kernel.org>
 <178908135551.207413.11072935643340240963@noble.neil.brown.name>
 <f5e4a7ef-43fb-4209-a2ef-34135c1333cb@slotpi15m67>
 <178916883696.207413.18145968545647470391@noble.neil.brown.name>
Subject: Re: [PATCH v3 00/12] Improve the scalability of NFSD's classic DRC
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Fri, Sep 11, 2026, at 7:20 PM, NeilBrown wrote:
> On Sat, 12 Sep 2026, Chuck Lever wrote:
>> On Fri, 11 Sep 2026, NeilBrown wrote:
>> > On Thu, 10 Sep 2026, Chuck Lever wrote:
>> > > 1. The transport reports delivery outright where it can. TCP now
>> > >    reports when snd_una passes the reply's sequence number, and RDMA
>> > >    reports on each Send completion.
>> >
>> > As you note in the relevant patch, the TCP ack can arrive before the NFS
>> > client has seen the reply.  But I don't think you drop the cached reply
>> > immediately, so that probably don't matter.
>> 
>> Right. The ACK marks the entry, and the next prune of that bucket
>> evicts it.
>> 
>> 
>> > > 2. Where no report will come, a later request on the same connection
>> > >    stands in as an implied ACK, since a client on a live TCP or RDMA
>> > >    connection does not retransmit within it (RFC 1813 Section 4.5).
>> >
>> > I don't follow this.  Why would no report come?  TCP will always send
>> > and ACK.
>> 
>> The cover letter was unclear. TCP always ACKs, but svc_tcp_sendto()
>> does not always track the reply. The per-socket ring is fixed-size,
>> so a burst overflows it. A kTLS send that leaves part of the record
>> unsent is not recorded, and neither is a failed send. Each of those
>> is reported as untracked right away, so the DRC entry has no report
>> to wait for.
>
> I don't see the need for the per-socket ring.
> When a reply is sent - record the TCP sequence number in the DRC.
> When pruning the DRC, get the TCP ack number first and compare it
> against sequence numbers.
> Do this often enough that that entries are pruned before the sequence
> wraps past them.
>
> kTLS is clearly more subtle but there must be some way record an
> approximate seq number for an incomplete send ..  maybe current seq +
> header-size + queued size ??
>
> Unsent replies will never get an ack, but presumably the client will
> resend, be answered using the cached reply, and we can then get an ack
> on the new connection.  I think it would be wrong to drop an unsent
> reply before the timeout, unless it gets re-sent and transport-acked
> before then.
>
> I think the opaque cookie aspect of the design is a mistake.  Everything
> is fully sequenced over a network connection so a sequence number
> (clearly paired with xpt_id) makes more sense...
> Or does RDMA not sequence replies?  If so then it can only ack a single
> reply at a time, not a range of replies.  But that needn't be a barrier.
>
> When a message is transmitted the transport hands a seq-number (and
> xpt_id) to the cache.  When it gets an ack it hands a range of
> seq-numbers to the cache.  For a transport that had out-of-order acks,
> this range would always be of length one (that transport might need a
> private atomic_t to generate the sequence numbers).  For a transport
> that batches acks (like TCP) the range could be much longer.
>
> Also, I wonder if the xpt_id should be 64bit assigned sequentially with no
> xa keeping track of used one.  64bits never wraps.
>
> I think that with this design the implied ACK would add no value.

Thanks, all makes sense to me and reduces code complexity.


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
