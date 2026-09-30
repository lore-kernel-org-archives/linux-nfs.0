Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 789E24CEE70
	for <linux-nfs@vger.kernel.org>; Wed, 30 Sep 2026 12:46:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790772418; cv=none; b=S/JRlYxj2nPLHW+QXZNEPEagFfMtWwUVlQFJFbo0ddCQ093xPDAWyaIey9DHDTRfmKfgJ8obvWOxw55nkRvzza1yT1t/eUhAOwu6WRUwgRTmCui4MXc4PfltP7UR8RDL+x0ld/yuG3/s8H+CZAUh7RveMvrD4gXZke5STaBnNrI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790772418; c=relaxed/simple;
	bh=qlxnA9e0nzSkzShYJJgc2p4g/oV9x9/5PFEuQDnGesA=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=OOdkmgSx0XSEtJ+/XajemRK+0TXlgw31Ag6bnnoGBTZGPbmokL+Z4oxhyhL7Ttx8MturuxYzQ1Tu9HswA6MTw7OBJjtL+R1uH/d+uYQNSkVywsOBAr5EL4oQjiTG0ZknkVxst7DXl8wCT8kval/nqLUvbQ+ZM6q9jS4jSmUXGX4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=jiOa7ksl; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="jiOa7ksl"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 8DD5F1F000FF;
	Wed, 30 Sep 2026 12:46:49 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790772409;
	bh=H8QNeZY2e28yB8DQ7gaPV8xdlg9APpaxDW+KxOf6suc=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=jiOa7ksloC6lzxLyY8urqjFtMmTkDQBX0+AjHblHNrY3D38W5xejSS7m49HejWoe6
	 Cia1Oke9l18A94ndLZeSbJaa3+10HXhoKCXdwO4cSEf13VNe9Qzz6yOphDxbm4uaW/
	 atwWJ5WTDm8Kn9P4i4K4+5BraeI3gGh3vmlUxvBoZyMQvKsmzrklbxDN0paseMp7PR
	 wE5eoGyYgfsDmEI6Nma3imS4zUWEjZfQ6mYwsHJ97iHwmfvZA4+Wb0GBOMcmqya3FY
	 CCV/AXRfyPde3kuzgZfdL5jToMSRWhLqRDMfJT/XoYC1bjNgF3HuW003Szitq5U2fd
	 AT8xFuq/NZFEA==
Date: Wed, 30 Sep 2026 08:46:48 -0400
From: Mike Snitzer <snitzer@kernel.org>
To: Chuck Lever <cel@kernel.org>
Cc: hch@lst.de, Jeff Layton <jlayton@kernel.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 01/10] NFSD: interlock the use of NFSD_IO_DIRECT for NFS
 READ and WRITE
Message-ID: <ar0EuAKO0VvD8kT4@kernel.org>
References: <20260929173423.16149-1-snitzer@kernel.org>
 <20260929173423.16149-2-snitzer@kernel.org>
 <37625d4e-9d86-4651-bbc8-73c1c589942d@app.fastmail.com>
 <arwYBaemyvLoG2sT@hammerspace.com>
 <d5d7635a-fe7a-4664-8797-b581c23cdf9c@app.fastmail.com>
 <arxKM8RkjwYaPzwL@kernel.org>
 <0cbfd399-45cd-4df2-888a-bdf8a2935ab0@app.fastmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0cbfd399-45cd-4df2-888a-bdf8a2935ab0@app.fastmail.com>

On Tue, Sep 29, 2026 at 05:20:03PM -0700, Chuck Lever wrote:
> 
> 
> On Tue, Sep 29, 2026, at 4:30 PM, Mike Snitzer wrote:
> > On Tue, Sep 29, 2026 at 04:17:50PM -0700, Chuck Lever wrote:
> >> 
> >> 
> >> On Tue, Sep 29, 2026, at 12:56 PM, Mike Snitzer wrote:
> >> > On Tue, Sep 29, 2026 at 11:27:05AM -0700, Chuck Lever wrote:
> >> >> 
> >> >> On Tue, Sep 29, 2026, at 10:34 AM, Mike Snitzer wrote:
> >> >> > Now that NFSD supports NFSD_IO_DIRECT for both READ and WRITE it is
> >> >> > much safer to avoid needless buffered vs direct contention if/when
> >> >> > only one of them has been configured to use NFSD_IO_DIRECT.
> >> >> >
> >> >> > Mixing direct and buffered I/O to the same file causes needless page
> >> >> > cache invalidation and writeback, so although io_cache_read and
> >> >> > io_cache_write remain separate interfaces, writing either one adjusts
> >> >> > the other so that READ and WRITE are never left on opposite sides of
> >> >> > the buffered/direct divide:
> >> >> 
> >> >> Jeff and I have been discussing making DIRECT the default for WRITEs and
> >> >> BUFFERED the default for READs. This patch takes us in the opposite
> >> >> direction.
> >> >> 
> >> >> Nothing here convinces me that mixing the modes is a bad thing to do.
> >> >> "Needless page cache invalidation" needs some demonstration, and it
> >> >> needs to show why the right thing to do is make it impossible to mix
> >> >> modes rather than explore the issue as one or more bugs that can be
> >> >> fixed. Or... why not let admins explore this for themselves? Where is
> >> >> the hazard and why does it need to be forbidden by the admin UI?
> >> >
> >> > The basis for the interlock is that O_DIRECT mode is intended to avoid
> >> > bloating memory with page cache and the excess CPU burn of managing
> >> > the page cache.  Using read caching in conjunction with O_DIRECT
> >> > writes knee-caps the wins of O_DIRECT.
> >> 
> >> Jeff and I have never seen that, and it's a counterintuitive result.
> >> Buffered READ with DIRECT WRITE seems to work very well and the server
> >> is easily capable of managing the page cache in this case, since
> >> reclaiming a clean page doesn't mean having to flush dirty data.
> >> Evicting clean pages is not slow.
> >> 
> >> So I'd like to see a quantification of the penalties in this mixed
> >> mode before adjudicating it as a hazard. That is, you might be right,
> >> but so far I've seen no direct evidence that having a substantial page
> >> cache presence is a general deficit for WRITEs. If there are certain
> >> cases where even caching READs is a problem, then by all means, set the
> >> READ IO mode to DIRECT too in those cases.
> >> 
> >> I don't see this as an argument for forcing the server's mode setting
> >> in every case.
> >
> > Yes, I understand and I've dropped the interlock patch in v2 (just posted).
> 
> Please give reviewers a chance to digest and review, as requested in
> Documentation/filesystems/nfs/nfsd-maintainer-entry-profile.rst :
> 
> "As always, please avoid reposting series revisions more than once
>  every 24 hours."
> 
> Trust me, it saves a lot of confusion.
> 
> 
> >> Based on this description, it seems to me the client has full visibility
> >> of the data to be pushed back and how it's sharded, it has information
> >> about the network RTT (that's where the real throughput impact is for
> >> COMMIT), and it has control over the selection of UNSTABLE vs. FILE_SYNC.
> >> 
> >> The problem here might be that when a large WRITE payload is sharded
> >> across multiple servers, the client still thinks it is sending them via
> >> UNSTABLE WRITES to one server, and plans for only one COMMIT after the
> >> server completes the WRITEs.
> >> 
> >> But for the pNFS scenario, the client sends one UNSTABLE WRITE followed
> >> by a COMMIT to each server. If the sharded WRITES are all single RPCs
> >> to distinct servers, then they should each be FILE_SYNC.
> >> 
> >> The client can be smarter about how it writes data back to multiple
> >> servers, can't it?
> >
> > When the server is operating in direct mode it isn't something exposed
> > to the client.  That the client could be smarter and/or already has
> > adequate controls to achieve the same FILE_SYNC result is besides the
> > point.  The point is, if the server has already done the work then it
> > should, within reason, convey as much back to the client to elide
> > COMMIT work that isn't needed.
> 
> Your point assumes the other patches in the series are applied to make
> DIRECT UNSTABLE WRITEs completely persistent.
> 
> The current IOCB flags do not include IOCB_DSYNC on a DIRECT UNSTABLE
> WRITE for a very good reason: that makes them slower and more expensive.
> The current server logic is working exactly as we designed it last year,
> and I'm not enthusiastic about changing that. I expect at least one
> other reviewer will have a similar reaction, once he sobers up from
> ALPSS.

You haven't reviewed the changes, yet you are passing judgement.

Please review.  I think you'll find I have only made things better.

And as for Mr ALPSS, the "NFSD: do not use direct I/O for a READ
smaller than its alignment" and "NFSD: only split a direct-mode WRITE
for a worthwhile direct middle" patches were motivated by his feedback
last year! (I have been carrying them since then, albeit in a less
polished form than I have now made available in this series).

> If the client wants to avoid the COMMIT, the standing rule is to send a
> FILE_SYNC WRITE. That benefits all WRITE I/O modes on the server.

I haven't precluded DIRECT UNSTABLE WRITE from operating as it does
now _at all_.

I've merely exposed additional optional controls that require opt-in.
And provided a natural evolution to what we have that has proven
beneficial.
