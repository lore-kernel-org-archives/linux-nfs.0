Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794862070;
	b=PpEymHd0218FbNeqUjkWLZtXkSQdBaxW5PtQZulK7YbPtShNxENIuhpx/sXIpFfXC6CV
	 KRZi5Mucn1GWh9DV9fZbXUZJOeHzNRkXId73CFfiS2ANHVe90+Uwhmj2Viyx90vl79kKy
	 hru1S3FB5InuQ6DexgLLtZZP+O4hLxs5MXJAOjokOljvdGJCW92R6QwJ9JGtd/iY2NyQV
	 tfTLfpAPvpiheak8OaR/zFlcpMWPDmWNWZaGUCEX13kJYToG8HTerFkpGyrdwymiToE35
	 b35ysONfcFznd4e0VFfbeHpuMA1jXTNg0VJWkp8m/wkjn9HTKnRmvQerpxv41rDE8HQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794862070;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To;
	bh=OLiavxsDlBfdXBPQBNGT2FAhIOzho6noIQxZvnyUpp0=;
	b=2L3GNvKpfOYw9ElaIjw6fxNYmo7cbScXNKg6qf2VwCBJ0HMwlQChDpOTQVyiatlx9d9C
	 lqLUjTngreG6Tzg5MOOuEoq0QuZRfMHgcd0mONpTq0LLsj8D2zverYhAQMSi29K/YBjzu
	 IQ5dGZTCQEFXxF/ON0fX8YUUp34ylsKtDHjLamlVG5W+Qnh+MZ8Sn6MMY2lClA0KbFTRn
	 03MxtjZukKu+WeVfb+cqBMnqanG2gwbAHCV8k+jfhMXL22eLYcBErl2klqep4N3nhHgFA
	 imGsrxNKqCs8s0JXDczrRatVFVeEXE3Aby0wUjN2EJ5WVw++kyhyHkXSKTFw68vbC4w==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Q9snoCww;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AAFB8606A330;
	Mon, 16 Nov 2026 20:47:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Q9snoCww
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 33B241F000C4;
	Mon, 16 Nov 2026 20:47:50 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794862070;
	bh=OLiavxsDlBfdXBPQBNGT2FAhIOzho6noIQxZvnyUpp0=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=Q9snoCwwFCt1j8KTTj8fxvYElH/dBOlVcv7MgV+Vsx0xrnhaLBNPgFda6Sl8iQiBf
	 O9hNoPUTQMtR6CR7dyuIOc5Jfnhtao/pTx3wZ60Kjf6GM0JBpKzfh6xzmhTU+awkjy
	 N4sDv8gOJ0H59T/m+tZOfiMeRlwzfFcQckc6rBRYDcnycoaMEnAnzhui3UXMqBtUoS
	 9om4jA2rVPNbG7WfTwYdLYjVSoahFM36S1bjAG5zzn4XcrxTPrvAjfZ22wlNdcqFEO
	 yTDsDapCyAEuzkv//R6BGTvos7MaD5HQCkNP3EijpujpGTaEHGJTX3Ys8kN+UurRbW
	 ZjQ66SvnnKpgA==
Date: Mon, 16 Nov 2026 15:47:49 -0500
From: Mike Snitzer <snitzer@kernel.org>
To: Jan Kara <jack@suse.cz>
Cc: Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org,
	Christian Brauner <brauner@kernel.org>,
	linux-fsdevel@vger.kernel.org, Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v12 0/7] mm, iomap, NFSD: stop DONTCACHE writes reading
 back shared pages
Message-ID: <avtr9YaUNyjGHk4h@kernel.org>
References: <20261112190911.84702-1-snitzer@kernel.org>
 <iushs6l3mjqkq65srej4gevaf2oeazy5j5miaipy6yxscetzjd@d4ti4qgbhman>
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
In-Reply-To: <iushs6l3mjqkq65srej4gevaf2oeazy5j5miaipy6yxscetzjd@d4ti4qgbhman>

On Mon, Nov 16, 2026 at 12:02:20PM +0100, Jan Kara wrote:
> Hi!
> 
> On Thu 12-11-26 14:09:03, Mike Snitzer wrote:
> > An RWF_DONTCACHE write is buffered IO: its data goes through the page
> > cache, and writeback drops each folio once the folio is written back.
> > A write that starts or ends inside a folio covers that folio only
> > partially.  Usually another write covers the rest of the folio.  If
> > writeback drops the folio before the other write writes its part, the
> > other write must first read the folio back from disk.  32 threads
> > writing interleaved records to one XFS file, 4 KiB pages, before and
> > after 5/7:
> > 
> >   record  pwritev2() flags          4 KiB device       MiB/s
> >   bytes                             reads per write
> >                                     before   after     before  after
> >   47008   RWF_DONTCACHE             0.97     0.0005    831     2281
> >   47008   RWF_DONTCACHE|RWF_DSYNC   0.99     0.0005    601     1227
> >   6000    RWF_DONTCACHE             0.97     0.0001    121      488
> >   6000    RWF_DONTCACHE|RWF_DSYNC   0.99     0.0002     90      206
> > 
> > 47008 bytes is the transfer size of IO500's ior-hard, in which each
> > rank writes interleaved records to one shared file.  Any record size
> > that is not a multiple of the page size has the same problem.  6000
> > bytes is a second example.
> 
> OK, I understand the problem but frankly I hate the complexity this
> introduces. Patches 1-3 are good improvements, patch 4 is OK but 5 & 6 look
> too complex for too niche usecase to me. I didn't really pay attention to
> previous revisions of this patch set so I'm sorry if this was discussed but
> can't we just make iomap for unaligned RWF_DONTCACHE write ask for
> minimum-sized folios for the partial edges without FGP_DONTCACHE and
> use FGP_DONTCACHE only for folios fully within write? That will also solve
> the problem with the following write having to read again from the disk and
> it will be much simpler. Sure the edge folios will not be dropped after IO
> completion which may have smaller or larger effect (depending on the
> overall write size) but I'd say that's the cost of userspace making life
> hard for the kernel :-p

Thanks for looking, Jan.

On complexity: 5/7 and 6/7 add almost nothing to the fast path.  The
new code runs only at a partial edge.  Aligned IO, and IO that is not
RWF_DONTCACHE, pays for it with a few flag tests:

- IO that is not RWF_DONTCACHE (buffered, direct, reads): every new
  branch is behind IOMAP_DONTCACHE or FGP_DONTCACHE.  The cost is one
  flag test in the found-folio path of __filemap_get_folio(), one when
  a folio is created, and one per write call in
  iomap_file_buffered_write().
- An aligned RWF_DONTCACHE write: iomap_get_folio() tests whether the
  folio is partially covered, which is a mask and two compares per
  folio.  The test is false, so FGP_DONTCACHE_EDGE is not set, and the
  folio is created and marked dropbehind as before.
- No new locks, atomics, allocations, page flags or per-file state.
  The state of an edge is the uptodate state that the folio already
  has.  Writeback and reads do not change.
- folio_dontcache_edge_written() and the two 6/7 helpers run only at a
  partial edge, or for a caller that asks for IOCB_DONTCACHE_DEFER
  (NFSD).

So the complexity is all in the misaligned case, which needs it.  I'd
argue that if the kernel (MM) can handle userspace making life hard it
should, within reason.  I think my patchset nicely isolates the
complexity to userspace that makes life difficult.

The first part of what you describe is what 5/7 already does.  iomap
asks for a minimum-sized folio at each partial edge, and a new edge
folio is not marked dropbehind.  5/7 adds one more step: the write that
completes an edge marks it, so the writeback that cleans it drops it.

Without that step, every edge stays cached until reclaim.  For this
workload, that is a large part of what the writes put in the page
cache:

- With 4 KiB pages, each record leaves about one page cached.  Through
  LOCALIO with cached edges, 8.6% of the data stayed resident with
  47008-byte records, and 66% with 6000-byte records.  When the write
  that completes an edge drops it, 0% stayed resident.
- With 64 KiB pages, a 47008-byte record never covers a whole folio.
  So no folio is ever marked, and RWF_DONTCACHE caches as much as a
  normal buffered write.
- Jon Flynn measured cached edges through NFSD on four pNFS data servers
  with ior-hard.  The page cache grew by 622 GiB in a 318 s write phase.
  With this series it grew by 2.9 GiB.

So for this misaligned workload, cached edges keep from 9% to all of the
written data in the page cache, depending on the record size and the
page size. The reads stop, but the page cache fills until reclaim runs.

6/7 does not change what is cached.  A caller that syncs its own write
(NFSD, for a FILE_SYNC WRITE) uses it to mark the shared folios after
its sync.  Without it, each segment wakes the DONTCACHE writeback kick
for pages that the sync then writes.

Mike
