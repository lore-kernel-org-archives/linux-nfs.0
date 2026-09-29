Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D413B41B8EE
	for <linux-nfs@vger.kernel.org>; Tue, 29 Sep 2026 23:31:00 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790724662; cv=none; b=QtrcwZSqxBciOrJu6bhyUJbpdoapPWfJzVovqUGL/0eVSmpytp0YzK/PrXg5H6tE38zz5g5U/XT5Lf7ZIxpUnLQ0kM/rkCxn8NH+8ANCgkQ95Vht3MzbxBapsyZO3xhiJGP0jgTGOMMW+bT++dTOSRtvRo99JeFhkF0a0hztnzY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790724662; c=relaxed/simple;
	bh=/zEM8Dn/nRhiR6XUAL1SY/p9xSOKxwWxUZcntGljssM=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=nzvfa1O0GzBX2vVJMHwttz0P1Vq4DQtA7M1r9YPFlvgRJ84nXvKBQtSw2yWIXI/dQVfpV0QYz/O72wYpxJuSy7lRUN12nOxX7fBvXEOFOM1GvzPFjno4KqBKhtZXU7iQiJWg0ZQ2e3BJIV3Gow1tngcYDsaV6SmBeuDHdkort1Y=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=GOeIANMJ; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="GOeIANMJ"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 7B34F1F000FF;
	Tue, 29 Sep 2026 23:31:00 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790724660;
	bh=fJ/Ue64ei1G7r/954GEBMcUe2Il8MmYiuP9SVxYL2S0=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=GOeIANMJ0fCgSckjWa41KQyW0rpCnGNqUXF1efp9tL82R+XnviLGVvQbhCMQ/N8yr
	 MIJKiootbT7F4I+dtpNzCgnDp/wVdWUKlG2Q1r9Xpn0RO7eYbIS1ZE0hX5vuvDXGAy
	 g/UQ69NcAo1hvZNmQFZrPbqJ2JNeIs4FVJ4l3TMaoI9f/1T8huVMFGEad8tQ95tdgJ
	 jUwWMhhLknTybm+9/fHKAWevnHvX21OFHz1CptgEwrSXd3kuFLRAsq7TU0lcFIu0HG
	 v0ZzXA4+xSBanmernzaAUImPZkadYwYjH0/e2/CiO5hvHxwsMXO/6oG7n7sfsViSek
	 oO5v6BlzM7wpA==
Date: Tue, 29 Sep 2026 19:30:59 -0400
From: Mike Snitzer <snitzer@kernel.org>
To: Chuck Lever <cel@kernel.org>
Cc: Mike Snitzer <snitzer@hammerspace.com>,
	Jeff Layton <jlayton@kernel.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 01/10] NFSD: interlock the use of NFSD_IO_DIRECT for NFS
 READ and WRITE
Message-ID: <arxKM8RkjwYaPzwL@kernel.org>
References: <20260929173423.16149-1-snitzer@kernel.org>
 <20260929173423.16149-2-snitzer@kernel.org>
 <37625d4e-9d86-4651-bbc8-73c1c589942d@app.fastmail.com>
 <arwYBaemyvLoG2sT@hammerspace.com>
 <d5d7635a-fe7a-4664-8797-b581c23cdf9c@app.fastmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d5d7635a-fe7a-4664-8797-b581c23cdf9c@app.fastmail.com>

On Tue, Sep 29, 2026 at 04:17:50PM -0700, Chuck Lever wrote:
> 
> 
> On Tue, Sep 29, 2026, at 12:56 PM, Mike Snitzer wrote:
> > On Tue, Sep 29, 2026 at 11:27:05AM -0700, Chuck Lever wrote:
> >> 
> >> On Tue, Sep 29, 2026, at 10:34 AM, Mike Snitzer wrote:
> >> > Now that NFSD supports NFSD_IO_DIRECT for both READ and WRITE it is
> >> > much safer to avoid needless buffered vs direct contention if/when
> >> > only one of them has been configured to use NFSD_IO_DIRECT.
> >> >
> >> > Mixing direct and buffered I/O to the same file causes needless page
> >> > cache invalidation and writeback, so although io_cache_read and
> >> > io_cache_write remain separate interfaces, writing either one adjusts
> >> > the other so that READ and WRITE are never left on opposite sides of
> >> > the buffered/direct divide:
> >> 
> >> Jeff and I have been discussing making DIRECT the default for WRITEs and
> >> BUFFERED the default for READs. This patch takes us in the opposite
> >> direction.
> >> 
> >> Nothing here convinces me that mixing the modes is a bad thing to do.
> >> "Needless page cache invalidation" needs some demonstration, and it
> >> needs to show why the right thing to do is make it impossible to mix
> >> modes rather than explore the issue as one or more bugs that can be
> >> fixed. Or... why not let admins explore this for themselves? Where is
> >> the hazard and why does it need to be forbidden by the admin UI?
> >
> > The basis for the interlock is that O_DIRECT mode is intended to avoid
> > bloating memory with page cache and the excess CPU burn of managing
> > the page cache.  Using read caching in conjunction with O_DIRECT
> > writes knee-caps the wins of O_DIRECT.
> 
> Jeff and I have never seen that, and it's a counterintuitive result.
> Buffered READ with DIRECT WRITE seems to work very well and the server
> is easily capable of managing the page cache in this case, since
> reclaiming a clean page doesn't mean having to flush dirty data.
> Evicting clean pages is not slow.
> 
> So I'd like to see a quantification of the penalties in this mixed
> mode before adjudicating it as a hazard. That is, you might be right,
> but so far I've seen no direct evidence that having a substantial page
> cache presence is a general deficit for WRITEs. If there are certain
> cases where even caching READs is a problem, then by all means, set the
> READ IO mode to DIRECT too in those cases.
> 
> I don't see this as an argument for forcing the server's mode setting
> in every case.

Yes, I understand and I've dropped the interlock patch in v2 (just posted).

> > But sure, you can do it.. and
> > I suppose the freedom of choice (and enough rope to hang) is perfectly
> > fine.
> 
> "Enough rope to hang" is the usual approach for Linux tunables. I
> should also point out that both of these settings are still debugfs,
> not the final shape of the administrative UI. It doesn't seem sensible
> to me to restrict them at this point, but I'll keep this idea in mind
> as we continue to develop our thinking about what the eventual non-
> debug admin UI will look like.

Ack.
 
> > I can drop the interlock and send v2 after more time for review
> > of the other patches (but there were some real bugs fixed in the
> > interlock patch so will require some care to adjust).
> 
> The usual policy for "real bugs" is that those need to be fixed in
> separate, backport-able patches before making behavioral changes.
> Stable wants the fixes, and does not want the behavior changes, so
> these need to be separable.
> 
> You can send the bug fixes any time without waiting for a v2.

The bug was something I found and fixed in code I had been carrying
privately.  So not applicable to upstream, sorry for the noise.

> >> As I recall, even a direct WRITE needs a subsequent COMMIT. Have you
> >> demonstrated that the client COMMIT is a latency problem or that
> >> the memory that is pinned on the client has a noticeable impact?
> >> 
> >> We suspect that it might, but every time I've measured, avoiding
> >> COMMIT with NFSD has shown no impact on throughput, which is why
> >> NFSD doesn't already do this optimization.
> >
> > Yes, in the header for "NFSD: let a direct-mode WRITE raise stable_how
> > and elide the client's COMMIT":
> >
> >     What this removes is the COMMIT traffic, and it is worth most where a
> >     client's writes are carved into several WRITE RPCs, because each piece
> >     is then committed separately.  Measured on a pNFS flexfiles share where
> >     every write straddles two data servers, so every write becomes two WRITE
> >     RPCs and, under NFSD_IO_DIRECT, two COMMITs: the two modes do identical
> >     durability work, one fsync per COMMIT against one fsync per WRITE on
> >     identical WRITE counts, and the COMMIT RPCs alone cost NFSD_IO_DIRECT
> >     31% more server CPU and 42% more client CPU for the same bytes, about
> >     20 us of server CPU per COMMIT plus a client cost that grows with the
> >     range committed.  Where only one write in 22 is split the same effect
> >     is a couple of cores on each side and no resolvable throughput
> >     difference, and writes that fit a single RPC send no COMMIT in either
> >     mode.
> 
> I asked about latency, above. This paragraph is about CPU utilization.

Fair point, latency wasn't measured.

> Based on this description, it seems to me the client has full visibility
> of the data to be pushed back and how it's sharded, it has information
> about the network RTT (that's where the real throughput impact is for
> COMMIT), and it has control over the selection of UNSTABLE vs. FILE_SYNC.
> 
> The problem here might be that when a large WRITE payload is sharded
> across multiple servers, the client still thinks it is sending them via
> UNSTABLE WRITES to one server, and plans for only one COMMIT after the
> server completes the WRITEs.
> 
> But for the pNFS scenario, the client sends one UNSTABLE WRITE followed
> by a COMMIT to each server. If the sharded WRITES are all single RPCs
> to distinct servers, then they should each be FILE_SYNC.
> 
> The client can be smarter about how it writes data back to multiple
> servers, can't it?

When the server is operating in direct mode it isn't something exposed
to the client.  That the client could be smarter and/or already has
adequate controls to achieve the same FILE_SYNC result is besides the
point.  The point is, if the server has already done the work then it
should, within reason, convey as much back to the client to elide
COMMIT work that isn't needed.

Mike
