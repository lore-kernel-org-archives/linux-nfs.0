Received: from fhigh-a8-smtp.messagingengine.com (fhigh-a8-smtp.messagingengine.com [103.168.172.159])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 93330377EC5
	for <linux-nfs@vger.kernel.org>; Fri, 11 Sep 2026 23:20:45 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.159
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789168848; cv=none; b=XarJe3GMs0g0J0ZUcaGbNccUUZQHTByTkULLo971PEYEQVeAKJHClJCzrZRuKhu3YXkOPDjvzB0GJmZftUs6c9SNPhEIEMsPW001fI+h5EbFMb1mluoAJ/LTONJVnb77bKYIQLELDX4ZVZbsP1YP2BpBYR3AvKZMj2T2zMXRPfs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789168848; c=relaxed/simple;
	bh=85gRERJPlEN4Fp0NSep077tXdIZ4JTDlbw2OQgGtuqc=;
	h=Content-Type:MIME-Version:From:To:Cc:Subject:In-reply-to:
	 References:Date:Message-id; b=nEkL/hegpBAfV6w/R/vsyqfSFaAj7qAasjI/IzKWERvixv8BCRj54OjPJQja0DomX2w3SGDq3XHMq2xuzkMUiYeBQvHp05VeO+cur8z1b7/EJxf0MNd52XFmrXcfATLIc25F26rcDeoTaPQ2rDL/LQVxybeoVVNhuWSJfXUtRaA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=OxCcTwiw; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=xt+5aU1w; arc=none smtp.client-ip=103.168.172.159
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="OxCcTwiw";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="xt+5aU1w"
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailfhigh.phl.internal (Postfix) with ESMTP id 041F41400182;
	Fri, 11 Sep 2026 19:20:44 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-02.internal (MEProxy); Fri, 11 Sep 2026 19:20:44 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to; s=fm1; t=
	1789168844; x=1789255244; bh=OKoJIQy0M+Jl3STOAk9+1WJzRj9VWM9hYmg
	315gjhvo=; b=OxCcTwiwPz7Ay5YvYe5OzgiagerRYg5fMSEGJOhlGTp8lPqhxXE
	mAoFfORzIYGqxjwbQ2o6XcxdKKnaEiLZwAkDpl7NYNvRlzYd77NDvtzuyc5WWYn5
	gLFi58vf2+7uirLm6X/fqi3C3jcuRBSqeqzu5m9UWZ7GiA3xPUQVjXWfRW0ntmJY
	y3tjOzWoZc3aXAqKNEl228GeNCJp63b99vQ6sW4i9HYdz9o2H3j1D1OCdmExfCur
	mXLcSudD3K8S5Fja5Y0HQdMeBodCQ38xl7KsZ+IhR7zf3Bj5C/aBzFf+R+ysn5va
	QCmvxqQBgjk+3K1Hr44on7f2ILo9OJLDtPg==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm1; t=1789168844; x=
	1789255244; bh=OKoJIQy0M+Jl3STOAk9+1WJzRj9VWM9hYmg315gjhvo=; b=x
	t+5aU1wY+eaeBs8JmNtYPhLSfyz/lEsY7XZ8I7dn3U+YKmUoKtSt6PqybzU7G1xs
	wdqIjpOICVOlUzOT0wdFHLovNDxHHG7aL8dSTObCAnWqDQrHeZVRD2Z7yRZfQqvL
	i2Mex8/jvwk6LRxGENhfmY44pVqun4Cxy8r5DnVN1oWqd85EeqsTujJoCmg3gIh2
	Y0Gzs8tbTN/le5HZqoPUyRhlkuY5cYsTEkAKgkUHutDvwoNWl0Yl844cOcZOSkov
	R9mZzaWL7ilpP8YlSq9nUYgUxizV47n7XRq5Uy7CWKG43NyySAeyoUE2SWE/V1Bp
	HX1BcbF4ZelgjZ0fG7Zhg==
X-ME-Sender: <xms:y4ykapeNqfERcOrYLGZtmclaSTL-g_yJKWdAV9cbyfUkHB9EqZ_A-A>
    <xme:y4ykapf3aLJrVVXJneJTXTpur82Gu6LcY3tgGjmChJ95MYf3we1Rm9WriyVUFKQWx
    Kn7T4MQqGjDxRsL0EGol6gUhOM7GrPvg-tm7RHLvH08nwalA0Y>
X-ME-Received: <xmr:y4ykakzxmmFAl9OxEOv28FiPuv6ZfT9CELTYCDnwg1b0miLL3Tam_DsU1YtTeFQO92ATZ9Su2crpCEKkd3J9mma6s8sx7Xk>
X-ME-Proxy-Cause: dmFkZTFZkAVqykqDYySgAa1y/Ir0DqGT+0QH1jQha6XzvrsRuzHz6EIjHYfYAyxCLT6uP8
    oa2e93IIiqxGghs1PIgi2Yq1QIQNVogFZyG28XYQfQZEvb+/sY9gNCRl3SRKt4034O5a7e
    dashHFxPPUR3b/o1Ky2A623kCK7Th9YY/k+b+ph16LcKc28m5Dg3CgC/ox3CdPCfJ2AoL4
    Lh3CP4nZf5iueeRCsIx2Veb5k9m2K4OgbmuZi/uGpgvCj+YM9Um0771eqHnOQa3deFAT99
    5ULGBjRW3oRjb3HpscSHJLO6DlP+4keDD0Go6vtcj66RS+aW+wkf1QSAkiEKfLCBzNguXg
    aIKSQ5ZpMosHbqtW9QE/XYS55ueElvjaN/GIbsPTu/b0pQ4iRs9OsBvw4OaS9hG3n+SSjH
    btSs4wCUuG07cOy3UIyS6sNY2XeXFib0Aoe2nWhIwGcH5N6rDT320ya3yt/bgLUyl+Ati5
    IRiqt1vPB3DfIK8+958DBMfikxdSJMgfqnrLA8hfDeyQRSUi5rntIj8uLq3Gq4sbxhMGQX
    gIIvFWc0aZNPEsKLdSkpAQl0C7YlXF5Rj/oSZ3nXfiofJCIDkWvlf2MRWnKhLfASJ09R8C
    XuYJalR5zuVJ25h+04hzOh+l0Gme5VXqZ4v4CuyZIooRM0Ge6QCU4jos05Qg
X-ME-Proxy: <xmx:y4ykao9zgqzliQJpTqcCgwzzLSeUxkMAvhDsDjo_-lhwiU7SAKpJtQ>
    <xmx:y4ykakiC5niSugZLj2fpcryrfd5h8dV9e1fYeC5p9AoqV5Oj16-gKg>
    <xmx:y4ykanGI32-cfrxOUnLkBEgfoKsfp9032d2R5wTBc0ZLfVpd8HpLSw>
    <xmx:y4ykar_5yLA9abeg0FyXFxktXYGzvcCVLykpgxqfcB4rQc8kBNsZhw>
    <xmx:zIykauqulTPtFFBtxUdklsao0HXBzMLIg93t7k2oYbWmiYJCzviQzkR4>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Fri,
 11 Sep 2026 19:20:41 -0400 (EDT)
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
Subject: Re: [PATCH v3 00/12] Improve the scalability of NFSD's classic DRC
In-reply-to: <f5e4a7ef-43fb-4209-a2ef-34135c1333cb@slotpi15m67>
References: <20260910-duplicate-reply-cache-v3-0-31532a4c7449@kernel.org>
  <178908135551.207413.11072935643340240963@noble.neil.brown.name>
  <f5e4a7ef-43fb-4209-a2ef-34135c1333cb@slotpi15m67>
Date: Sat, 12 Sep 2026 09:20:36 +1000
Message-id: <178916883696.207413.18145968545647470391@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>

On Sat, 12 Sep 2026, Chuck Lever wrote:
> On Fri, 11 Sep 2026, NeilBrown wrote:
> > On Thu, 10 Sep 2026, Chuck Lever wrote:
> > > 1. The transport reports delivery outright where it can. TCP now
> > >    reports when snd_una passes the reply's sequence number, and RDMA
> > >    reports on each Send completion.
> >
> > As you note in the relevant patch, the TCP ack can arrive before the NFS
> > client has seen the reply.  But I don't think you drop the cached reply
> > immediately, so that probably don't matter.
> 
> Right. The ACK marks the entry, and the next prune of that bucket
> evicts it.
> 
> 
> > > 2. Where no report will come, a later request on the same connection
> > >    stands in as an implied ACK, since a client on a live TCP or RDMA
> > >    connection does not retransmit within it (RFC 1813 Section 4.5).
> >
> > I don't follow this.  Why would no report come?  TCP will always send
> > and ACK.
> 
> The cover letter was unclear. TCP always ACKs, but svc_tcp_sendto()
> does not always track the reply. The per-socket ring is fixed-size,
> so a burst overflows it. A kTLS send that leaves part of the record
> unsent is not recorded, and neither is a failed send. Each of those
> is reported as untracked right away, so the DRC entry has no report
> to wait for.

I don't see the need for the per-socket ring.
When a reply is sent - record the TCP sequence number in the DRC.
When pruning the DRC, get the TCP ack number first and compare it
against sequence numbers.
Do this often enough that that entries are pruned before the sequence
wraps past them.

kTLS is clearly more subtle but there must be some way record an
approximate seq number for an incomplete send ..  maybe current seq +
header-size + queued size ??

Unsent replies will never get an ack, but presumably the client will
resend, be answered using the cached reply, and we can then get an ack
on the new connection.  I think it would be wrong to drop an unsent
reply before the timeout, unless it gets re-sent and transport-acked
before then.

I think the opaque cookie aspect of the design is a mistake.  Everything
is fully sequenced over a network connection so a sequence number
(clearly paired with xpt_id) makes more sense...
Or does RDMA not sequence replies?  If so then it can only ack a single
reply at a time, not a range of replies.  But that needn't be a barrier.

When a message is transmitted the transport hands a seq-number (and
xpt_id) to the cache.  When it gets an ack it hands a range of
seq-numbers to the cache.  For a transport that had out-of-order acks,
this range would always be of length one (that transport might need a
private atomic_t to generate the sequence numbers).  For a transport
that batches acks (like TCP) the range could be much longer.

Also, I wonder if the xpt_id should be 64bit assigned sequentially with no
xa keeping track of used one.  64bits never wraps.

I think that with this design the implied ACK would add no value.

Thanks,
NeilBrown

