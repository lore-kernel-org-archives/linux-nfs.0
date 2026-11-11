Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794356766;
	b=eMpepSPtchdRKXcjNOOF4U6iUVv7KGX+ng61C87v3SN0UCW/l+VR+so62vOxx7++b5W5
	 E4dx+2FycYy9DYq6AVp1t+KbSktPSzkYp/03mdgWkdBl7Igter61VAMxLCKtcJyVH+q5n
	 yqmXFHnxLF28fjpb/QbcBKFeGU0J3BYzI+5g9VpQj8UXqpKhN201pwWCttt1pZTdimo4x
	 M7Xs6LMd9UaXauxvM5+0KArMcKmRe+lw6CfsQlhGvk6RmwKhJNnP04Lgbk8X3niB7O8JL
	 oGC/XAhvF5nTuP/zTQW8j2MCBbHpmWH8OgdrIw1uccWa+BhDWkX8gT61AMfq7NY5iLQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794356766;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To;
	bh=x80Jur2dVbfsH8vBU7Ebsz2GwukQ6rj58JAuvqMVqv8=;
	b=rr6W6505pxzQTjwjjtwvGRG6irZ80jT2uEprWnCyTUxNYLGOJ3wY4JhPDLajdsaiWCKE
	 COfE00Zth/AIKCHALcnvK+wb/LsCS5plwP4uyGXR5HCkfLdS19QChc+tDDCOG7+WpGpzL
	 6j+iBqhj198VPHQnEp0FRsixsSOcTw2fZaUBBUbUqGkHg/BJoFxU2VdWkNNp1RzIzCuL8
	 ViXDz7WdhIQLxjW8lLbMOBb/VJ6+Ptkw7QVECxt48aFrZ+2qePcG6VisoYRDNPXAIhGAZ
	 pPX/Uj8/MCF7Mbaw0rUtwLisGQj+4Tc5RQLJ8FyZv60hcoE/zMILP6vCB4Dk2MrOjNg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=P4vULWk7;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 33028606A332;
	Wed, 11 Nov 2026 00:26:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=P4vULWk7
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 8D40E1F0089F;
	Wed, 11 Nov 2026 00:26:05 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794356765;
	bh=x80Jur2dVbfsH8vBU7Ebsz2GwukQ6rj58JAuvqMVqv8=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=P4vULWk7Lz3JxWoQ1fFiZ1BhFF6mP3QT8MUkw0nM1uczi2dCWxzwTj2/3jymz8p1p
	 WkU4wHtcNekWZctiFGEwKCWtRaf2gf4zmkF2KtMeiGjvKTlp0fHztgrDb+UHAgtyEM
	 r+68HkuvbDNZb0WK/EMleuT9LsEO2jaMGfns2vx0CVBBvhgnkT4Lxpg2kFWieUKuPA
	 9x5WccVA1+oUhvF9GGaXM/xclcu8uBRMaMrf8F22f7F2YjbZH7vKHFRLYDsb9jeWSB
	 feB66WMI12AvuO+ctXjGtq2FFS8NHRPKneG0GhXjrHn1ddE0aABWamvGuQYlP8evjl
	 1oJGe+gP4rwOQ==
Date: Tue, 10 Nov 2026 19:26:04 -0500
From: Mike Snitzer <snitzer@kernel.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org, Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>, linux-nfs@vger.kernel.org,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>,
	Jens Axboe <axboe@kernel.dk>, Jonathan Corbet <corbet@lwn.net>
Subject: Re: [PATCH v10 0/7] mm, iomap, NFSD: stop uncached writes reading
 back shared pages
Message-ID: <avO2HG8_m4v-NYYM@kernel.org>
References: <20261103211754.35352-1-snitzer@kernel.org>
 <20261104091740.GB31130@lst.de>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20261104091740.GB31130@lst.de>

[against my better judgement I'm replying, hoping technical discussion
wins out.. usually does]

On Wed, Nov 04, 2026 at 10:17:40AM +0100, Christoph Hellwig wrote:
> On Tue, Nov 03, 2026 at 04:17:47PM -0500, Mike Snitzer wrote:
> > Hi,
> > 
> > An uncached (RWF_DONTCACHE) buffered write drops each folio it writes
> > once the folio is written back.  A folio that the write covers only
> > partly is shared with the neighbouring write.  If it is dropped before
> > the neighbour writes its part, the neighbour reads it back from disk
> > first.  32 threads writing interleaved records to one XFS file, 4 KiB
> > pages, before and after 5/7:
> 
> Very colourful terminology here.  Who is "the neighbour".  How do we
> know a "neighbour" exists and what it wants to do?

"the neighbour" was meant to convey the other write that covers the
rest of a page that another write covers only partly.  For example,
with 4 KiB pages, a write of bytes 0 to 5999 covers bytes 4096 to 5999
of the second page.  A write that starts at byte 6000 covers the rest
of that page.

We do not know that such a write will come, and patch 5/7 does not
assume it.  5/7 looks only at the state of the page:

- If the page is not uptodate, it is not fully written.  5/7 does not
  mark it dropbehind.  It stays in the page cache, like a page from a
  normal buffered write, until a write completes it or reclaim drops
  it.
- If the page is uptodate, it already holds the other part, and this
  write completes it.  5/7 marks it dropbehind, and the writeback that
  cleans it drops it.

So if no other write comes, at most the first and last page of each
write stay cached.  If one comes, writeback drops the page after both
writes, and the second write does not read it from disk.

> In general if the user gave a very clear indication that the data
> should not be cached, it is a bit awkward to second [g]uess that.

RWF_DONTCACHE does not keep data out of the page cache.  It is buffered
IO, so all of the data goes through the page cache.  The flag only asks
the kernel to drop the pages after writeback: "buffered IO that drops
the cache after reading or writing data" (include/uapi/linux/fs.h).  It
is also best effort today: an RWF_DONTCACHE write drops only the pages
that it creates, not the pages that it finds in the cache.

5/7 does not change whether the data goes through the page cache.  It
changes only when the kernel drops a partially written page.  Today the
kernel drops the page before another write might get to it.  That write
must then read the page back from disk into the page cache, to merge its
own bytes.  So the page cache does not hold less: it holds the same page
twice, with a disk read between.  In the cover letter test, that is 0.97
device reads per write, and 831 MiB/s instead of 2281 MiB/s.  The user
asked for less page cache use, not for a read-modify-write of each
misaligned write.

> Especially if the expectations are not very clearly documented.

The 5/7 commit message states it: "An edge whose neighbour never writes,
such as the last page of a file, stays cached until reclaim."  So the
only change to what the user sees is: an RWF_DONTCACHE write can leave
the first and last page of the write in the page cache, if no other
write completes them.  Writeback drops all other pages of the write,
as before.

Mike

ps. I'll reduce the "colourful terminology" in v11 (e.g. drop
"neighbour" jargon) and also address the 2 issues sashiko raised
against v10's 6/7.
