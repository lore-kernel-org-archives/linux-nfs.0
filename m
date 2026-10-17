Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 02D813E171B
	for <linux-nfs@vger.kernel.org>; Sat, 17 Oct 2026 18:50:47 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792263049; cv=none; b=TO5I5944JdYpaCuA4+GJCLzii/loqpJZ2isR0iaEYV2ZoI8/XJPN/7vtVY6BGoUqf3i916SD1cpF6KNLG+c9gghWdrXIYuQyFprVnzyZ+kbk8RisdSs8EVkIQxLxhe0YG8biJuvMvenYd13u6puS/jaHfAgmmixWb35SbZRsw6Q=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792263049; c=relaxed/simple;
	bh=GLIGXexu4OhDFaoZZT5BaDbcE2OoBAsrlQtfgB25I5M=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=lHczl+gheHxL7hWS9MAAh3e68iylKowLj3uqY1iQNfX+9o9wYCYZ4U6DX6WzDD4fdtkEf+n2aY8I+1yUFb5Bc44SnVLZEde3VZ+1POeKT/ROrkVvD6wNQNEciJ67Jt54kw3Pprw851rEOjAOfTZtVGCQhHRjwhgl9CF+a/YbsdA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=g5V3qfQL; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="g5V3qfQL"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 46E251F000C4;
	Sat, 17 Oct 2026 18:50:47 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792263047;
	bh=HRmpfEyl7ALg+ojzByVLMDgHoT/+5hYO8aHk7hFVTbw=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=g5V3qfQLwRTyTaLALqXAlk5deVyDyqO46ougZRpsy5EGtSM6R56hqjfC2keqlAEf3
	 l9bbiKrkhZM8n+7kzv5Vs9KVpOCko+Q75eh7brYwpm2hbmfbh/QUcklcNGJbVctJRS
	 C76P44n1Jw3vZakHzeLhiv3QyAphWGVOODjCS50JSbGBXJA+xYp3TIpqxaMymDWaU/
	 jN4LyxI3iPAb8wdYoGUx21GTkVcAS4PdeBaBFoueu9zJ0uVU0Uo4SjYrzA0G0joGh1
	 WdmujLpf65HUIcnLJ6xdvJV7UbCxYLpOHxiE4fPTEiuuvoRvduXwxg/2oK6xVKQW+E
	 YXhMoQsXai6Qw==
Date: Sat, 17 Oct 2026 14:50:46 -0400
From: Mike Snitzer <snitzer@kernel.org>
To: Chuck Lever <cel@kernel.org>
Cc: Jeff Layton <jlayton@kernel.org>, linux-nfs@vger.kernel.org,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>,
	Christoph Hellwig <hch@lst.de>, Jens Axboe <axboe@kernel.dk>,
	Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org
Subject: Re: [PATCH v4 0/10] NFSD: keep direct-mode I/O out of the page cache
Message-ID: <atPDhmfdneS-d5qM@kernel.org>
References: <20261015233309.42999-1-snitzer@kernel.org>
 <f60b0363-c4d5-4539-990c-1c6c7967f8f0@slotpi15m67>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f60b0363-c4d5-4539-990c-1c6c7967f8f0@slotpi15m67>

On Fri, Oct 16, 2026 at 03:23:27PM -0400, Chuck Lever wrote:
> On Thu, 15 Oct 2026 19:32:59 -0400, Mike Snitzer wrote:
> > 9/10 calls folio_mark_dropbehind() to keep the page two misaligned
> > WRITEs share until both have written it, with no state in NFSD: 704
> > device reads for 42895 WRITEs where there were 45144 for 45664
> > (47008-byte records, 32 interleaved writers, 4 KiB pages), and on a
> > four-server pNFS flexfiles rig 0.003 device reads per record instead of
> > 0.014-0.015, about 2.9 GiB of page-cache growth instead of 11 GiB, and
> > 2.4% to 4.9% more write throughput.
> 
> The direct-mode WRITE path started as one decision: aligned, go
> direct; otherwise split and go buffered for the ends. This series
> adds a page-boundary cut rule that depends on the relation between
> offset_align and PAGE_SIZE, a minimum middle size, a knob for
> whether the ends are DONTCACHE, a floor on READ size, a rule for
> when the sync is issued, and then the shared-page pairing in 9/10.
> Each is small and each has a measurement behind it. Taken together
> they make it hard to say, for a given WRITE, what I/O NFSD will
> issue and what the page cache will look like afterward, and that is
> the property we need to hold onto when a corruption or a performance
> report comes in. I'm not yet convinced that 1/10 through 6/10 buy
> enough to give that up.
> 
> 9/10 gives NFSD a semantic that DONTCACHE does not have: drop this
> page after the second writer, not the first. It builds that out of
> page-cache presence, with an unmarked folio standing in for "a
> partner is coming" and -EEXIST standing in for "the partner has
> been here".
> 
> Neither layer actually knows either of those things with certainty.
> mm cannot know another WRITE is on its way, and NFSD can only guess:
> a page left by a READ, by readahead, or by an earlier claim whose
> partner never arrived makes the first writer look like the second,
> and the description already lists the cases where a claimed page
> stays cached until reclaim because nobody comes to complete it.

I'll be posting a followup 11/10 patch, because your note ^ caused me
to revisit the handling of -EEXIST and I found concurrent receive of
the partner caused the code to be ineffective.  So yes, it wasn't
quite right.  More below.

> The 6000-byte numbers in 9/10 show the shared page is not a splitting
> problem. Those records are never split, and they still cost a read
> per record when the ends are DONTCACHE, because DONTCACHE drops the
> page after the first writer's writeback. So the choice is really
> between two things we already have: issue the ends and unsplit
> WRITEs DONTCACHE and pay a read-modify-write per boundary, or issue
> them as ordinary buffered I/O and let reclaim take the pages.

Agreed on the first part: the shared page is not a splitting problem.
Any buffered DONTCACHE write that covers a page only partly shares that
page with its neighbour, split or not, and 9/10 claims the partly
covered pages of an unsplit WRITE the same way, which is where the
6000-byte numbers come from.  The subject and opening paragraph of 9/10
frame it as a split-WRITE problem, and that is too narrow; v5 will say
what you said.

But I don't think the choice is only between those two.  Each pays for
one of the two things NFSD DIRECT is trying to avoid:

- DONTCACHE without 9/10 pays the read-modify-write: 45144 device reads
  for 45664 WRITEs of 47008-byte records, 196589 reads for the 6000-byte
  records.

- Ordinary buffered I/O (direct_misaligned_dontcache=N) avoids the
  reads, but every page the buffered segments touch stays in the page
  cache until reclaim.  On the pNFS rig in 9/10 that grew the page cache
  by about 630 GiB over the runs, against about 11 GiB with DONTCACHE
  ends.  For records too small to split, such as the 6000-byte ones,
  the whole WRITE is buffered, so every page written stays cached:
  NFSD DIRECT for those workloads becomes plain buffered I/O, which is
  what the DONTCACHE ends are there to avoid.

9/10 keeps each shared page only until both of its writers have written
it, and then drops it.  That gets the footprint of the first option and
the reads of the second together: 704 reads for the 47008-byte records,
385 for the 6000-byte ones, 81 of the file's 524066 pages left resident,
and on the rig 0.003 reads per record (from 0.014-0.015) with 2.9 GiB of
page-cache growth instead of 11 GiB, and write throughput up 2.4-4.9%.

More about patch 11/10 that bears on this: finding the folio already
in the page cache says only that the other WRITE has claimed the page,
not that it has written it.  Two WRITEs that arrive together, such as
the RPCs of one O_DIRECT write larger than the client's wsize, both
claim the page first, and the page could be dropped before the second
half was in it. With the fix, a page whose two writers arrive together
is simply not marked, so for that page alone 9/10 falls back to your
second option and reclaim takes it.  That is the cost I'd rather pay
where NFSD can't tell the order, but only there, not on every
boundary.

> If ordinary buffered ends turn out to cost throughput with flexfiles
> (or any NFSv3 I/O) other than just occupying memory, that is a
> reclaim or DONTCACHE result worth bringing to linux-mm on its own,
> and the right fix would be a DONTCACHE semantic that mm is willing
> to define, not special state in NFSD.
> 
> Consider splitting this into two series (which I already proposed
> for merge process-related reasons). 1-6 need careful scrutiny to
> understand the trade-offs between scalability gains and
> predictability. 7-9 need to be explored as an issue with DONTCACHE
> that should be resolved below NFSD, not within it.
> 
> I'll study 1-6 more.

Patch 10 too please, it improves tracing so we know precisely how each
segment is issued.

Thanks,
Mike
