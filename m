Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793918975;
	b=PALXASzSuk8hH9CybqKAU7YJ8a4xJ70okWUvvGD5+4jJ8MvwbIurubKJ1ivyVrYeCH7B
	 de/szgMdB2sXXaJXVAMS9zmFYT9cNbsZZMNP6cHnnmd8vriUz/QXpRBoWwNs7DBM3lUms
	 w/QNfhG6dNN5WOY6dJJA9W5RgdHEc6WNbXliSOqLiCuqnQSaYZpZAE7WSgqufTKQowvUD
	 IrDX+dRAHO/aO6ox1MNJNinQkFVZezJmhmqQjFxER/VFAAdi7W/Dwsfh8vvme6mTqvqK9
	 K01+5HfCGwFCtSMg1Ww/dycCwOpq4m5HcrQL1VS/M4acFFlT9EyaMLxhcX7Y4qhNu4Q==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793918975;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To;
	bh=S+nYe4I8JfGZ8iq7Bvfptw+3SVmUNoB+MIDzTrsXpZc=;
	b=V9ybLqb6ZpdR0L3Ud6ifMldFekOW+f3YbHx/q98xpR9lVr7R0TekvqdR6LLdppw8nh8a
	 LNu+xdNM2DTw8LijH3IiN42QyomLOXzkqjzm6zAl9WtkKGekOwjIFxvlknl70dVS11rM/
	 WcvzL0nK1VDwcU6/5uutXltJD/IGfSDlJXrSAs95BxjWpP1I6+G9U0uXCgFC96j39q/WW
	 C6Gr+IuhDlEmM1UHzYJMwvoudDCHb9lTGRph+MRYG/Rk0+0P6vgXsb7oazKNQ5ffYSWy/
	 RszBDelaQA2Rx6av5qEoPeJl89QaMVUXaWQtf1o5r1bF8fxB5IebjKgYDBNlTx64/oQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=TgHZ7LH2;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6887B606A326;
	Thu,  5 Nov 2026 22:49:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=TgHZ7LH2
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D243F1F0089F;
	Thu,  5 Nov 2026 22:49:34 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793918975;
	bh=S+nYe4I8JfGZ8iq7Bvfptw+3SVmUNoB+MIDzTrsXpZc=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=TgHZ7LH2yAs2qyGTAyNNtl8frCxxpwAJZEf6PU2DcWnxnWy8Gwr2rY4WWscjskyEm
	 piib1sPyrp16ZX0SGTmaIsDb7pvL5paKi/uBo8avrLOrUUi1aOj/A7Z5bjfMQBMSjN
	 j4Eq9xsHFuM2pB920goI6zViijasUSIFu7KXGqFRJvCPeVMdAzEHY6fyhJDfuKuq+E
	 J58K9DIZLC3V7zC732nScfU/zhzvvw1oMRaZTKz8cZFFqEXg9rdDKXASjqjxeSqrtZ
	 ELHH8o3eXZWSf+wF68UCbIny6kkYndjaeDR7pwKDeuguD1MRYu20E2srlmlgMetBGp
	 cv4tnszSs4FrQ==
Date: Thu, 5 Nov 2026 17:49:33 -0500
From: Mike Snitzer <snitzer@kernel.org>
To: Chuck Lever <cel@kernel.org>
Cc: Christoph Hellwig <hch@lst.de>,
	"Matthew Wilcox (Oracle)" <willy@infradead.org>, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org, Jeff Layton <jlayton@kernel.org>,
	linux-nfs@vger.kernel.org, NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>,
	Jens Axboe <axboe@kernel.dk>, Jonathan Corbet <corbet@lwn.net>,
	Jonathan Flynn <jonathan.flynn@hammerspace.com>
Subject: Re: [PATCH v10 7/7] NFSD: drop a shared boundary page only once both
 WRITEs have written it
Message-ID: <au0H_TZCp1Snf_5U@kernel.org>
References: <20261103211754.35352-1-snitzer@kernel.org>
 <20261103211754.35352-8-snitzer@kernel.org>
 <20261104091543.GA31130@lst.de>
 <autk-osSQ8l2LKz1@kernel.org>
 <20261105075935.GA18069@lst.de>
 <29851456-2e7c-48a7-bf00-11a1f1a35024@app.fastmail.com>
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
In-Reply-To: <29851456-2e7c-48a7-bf00-11a1f1a35024@app.fastmail.com>

On Thu, Nov 05, 2026 at 08:33:34AM -0500, Chuck Lever wrote:
> 
> 
> On Thu, Nov 5, 2026, at 2:59 AM, Christoph Hellwig wrote:
> > On Wed, Nov 04, 2026 at 12:01:46PM -0500, Mike Snitzer wrote:
> >> It is the transfer size of IO500's ior-hard: every rank writes
> >> 47008-byte records, interleaved with the other ranks, into one shared
> >> file, with O_DIRECT.  It is meant as a hard case, and it is the
> >> workload that showed the problem on our servers.  The same happens
> >> with any record size that is not a multiple of the page size.  The
> >> cover letter also has 6000-byte records.
> >
> > So based on a bit googling your totally optimize this for an intentionally
> > stupid benchmarking workload.  And that's not been disclosed anywhere.

Why we're even debating this, like "IO500" is taboo or something, is
what's stupid.  Not a surprise: handling misaligned IO is "hard".

Public service announcement: Don't let Christoph taint others' work
with trivialities and needlessly hostile strawman arguments.

For would-be MM reviewers (and you too Jens), my previous reply to
Christoph in this thread [0] delivered a lot of useful context that
made this patchset instantly approachable and yet rather than
acknowledge that fact he attacked a misaligned IO benchmark as
irrelevant.
[0]: https://lore.kernel.org/linux-nfs/autk-osSQ8l2LKz1@kernel.org/

But anyone who is active in HPC filesystems development _knows_ that
"47008 bytes" is IOR-hard (part of IO500's benchmark suite).  And yes,
its aptly named as a "hard" workload to handle efficiently.

I have named "47008 bytes" and "IOR-hard" and "IO500" _to_ Christoph
and others multiple times before:
11 Jun 2025 https://lore.kernel.org/linux-nfs/aEl1RhqybSCAzv3H@kernel.org/
12 Jun 2025 https://lore.kernel.org/linux-nfs/aEs6gmTXzhzuDZOI@kernel.org/
29 Oct 2025 https://lore.kernel.org/linux-nfs/aQJG2LIuui08Bx3H@kernel.org/

Even in the context of this MM DONTCACHE patchset (now on v10)
Christoph's "not been disclosed anywhere" doesn't hold. IOR-hard was
named, with its 47008-byte record, on 22 October in a v7 reply he was
copied on, two weeks before v10:
https://lore.kernel.org/linux-nfs/atqCTLf42kkGZmSd@kernel.org/
But it was only in replies, never in a cover letter or commit message.

> > I guess everyone else was right and just ignored this bordline malicious
> > submission.
>
> It's not fair to ascribe that kind of intent. I think it's fairly
> well known that Mike and Jon are using IO500, and not mentioning it
> in the documentation for this series was a simple oversight.

Thanks Chuck.  If there is a need for v11 I will explicitly mention
IO500's ior-hard benchmark's use of misaligned IO of 47008 bytes.

Jeff Layton reviewed and provided his Reviewed-by.

I suspect MM engineers have just been busy with the merge window.
Hopefully Willy and/or Jens will give v10 the courtesy of fair review?

But as I mentioned in [0] any misaligned IO has this issue:
"The same happens with any record size that is not a multiple of the
page size.  The cover letter also has 6000-byte records."

> But IMO we do need a broader variety of benchmark results to
> understand the impact of these changes. IO500 on big hardware is
> an uncommon workload for NFSD.

IO500's IOR-hard reflects worst case, I understand the reluctance to
care about it BUT the reality is that not all IO is sized optimally.
So if steps can be taken to avoid pathological inefficiency during
worst case (misaligned IO) _without_ hurting the fast path (when IO is
sized properly) then why not take them?

This patchset doesn't hurt fast path at all.  But happy to take
direction for benchmarks others would like to see results for.

Mike
