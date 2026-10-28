Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793164376;
	b=3edL4KXozAQsWPx0DlNDzwH2Aun4S5Tbnf56/iAQ6tdrWsFRxvbyN614125/gJWKExz/
	 nrcRdd67r/ebuCHwywxYXh1KhPvDmwDLr60/KyMWFa+nJIQKBO5Q00EAEJJtC6FBJMJrS
	 h+csfxke347LvsnzFfjxdMcBt0vp/PgwGw1zfG1ibp2mJ8JeyTgj/wwwQo+laULIlm5St
	 nLkIMyDNNWMxKwM9NAipUcZyxj/4QfAAIobiCbWZEwrTvk4Qe04Bp42OECCl9cRc8W/5k
	 4d86onPDbZ2BFZlVQJDDoJRlBSvKo7hiDYYdi9Fjj1Oa8PrB8xAYwrhhcUpZY5YPT1A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793164376;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To;
	bh=NHqc2iluLzBkHlrPz5vi8Qhq+QGWsc1OSshMmigJpRY=;
	b=TCahruJpbxR+NMfpq31koCxh4leQPB036ADQ14uU5fc+eSfmRaGFozQ8Xm3Xt9dAPO7I
	 QM0qto8zsrUSpMIQMnbuETmEiHCbUc8X/vmabjB/wU7G1QZXzmkpgAVE9EouIN4vrfi93
	 ad3DhUkW4YCLlmsKXW8xihgEhBGaojP+/KXGzAriq0Ixt24s/rpFsaRtAuSfNgpCQfVOQ
	 5NAxrMZEbqzjVJcYg9QEs4zyu3cK/He5mSEXNfdJYfAMQwBXTSdQEJVccBpHZqFer7nYr
	 41cWecETr9QsXjOzFtqRBj2LpZ6zeU2X3ZdgAaBuIgb8ETMqPFiksx/pce3UHACYKgA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=gPhJibQl;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 875AC606A31D;
	Wed, 28 Oct 2026 05:12:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=gPhJibQl
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 045CD1F01829;
	Wed, 28 Oct 2026 05:12:55 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793164376;
	bh=NHqc2iluLzBkHlrPz5vi8Qhq+QGWsc1OSshMmigJpRY=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=gPhJibQlhr66uy40ZULtu24Lm5U8ODdpfi+3/4UEoEqT/2XInnndDjW3NbMUyAgGe
	 oU9+2/D0FZnfr+0F7/GdT/dJ/XkvxfvGK09PiTiVAHzs5pgoGo0g+QwlEO/NEMJz0b
	 MqwO5uMj80ITxyZf/bx6m58zhOCu/zKVqw65+fkxHb9c5l4CbNbVKjYeML/st7hS62
	 MKBtWXPdswocV5FGa9dB77/o52Evz1Dr3um7H+T1T26w72FdJ/KtuoxoxsGhS5dOER
	 Z2n15c/bv+trMAU94e5JXXLwgoSrSe6C4B1jjaGVcZImVbxl25L1n6+Z0/RK3w0MrC
	 6RsVy91S7eUrA==
Date: Wed, 28 Oct 2026 01:12:55 -0400
From: Mike Snitzer <snitzer@kernel.org>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>,
	"Matthew Wilcox (Oracle)" <willy@infradead.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org, NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>,
	Christoph Hellwig <hch@lst.de>, Jens Axboe <axboe@kernel.dk>,
	Jonathan Corbet <corbet@lwn.net>
Subject: Re: [PATCH v9 0/6] mm, iomap, NFSD: stop uncached writes reading
 back shared pages
Message-ID: <auGEV03MkzR2W85B@kernel.org>
References: <20261024221152.6965-1-snitzer@kernel.org>
 <fc2ea8d6f2cd9ae83d38941f90386aac6638a497.camel@kernel.org>
 <70ef3172-9631-4e19-9b8e-4722427a5a83@app.fastmail.com>
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
In-Reply-To: <70ef3172-9631-4e19-9b8e-4722427a5a83@app.fastmail.com>

On Tue, Oct 27, 2026 at 11:36:44AM -0400, Chuck Lever wrote:
> 
> 
> On Tue, Oct 27, 2026, at 10:31 AM, Jeff Layton wrote:
> > On Sat, 2026-10-24 at 18:11 -0400, Mike Snitzer wrote:
> >> Hi,
> >> 
> >> Please consider this v9 for the v7.5 development cycle, so that it can
> >> go upstream in the v7.5 merge window.
> >> 
> >> An uncached (RWF_DONTCACHE) buffered write drops each page it writes
> >> once that page is written back.  A page the write covers only partly is
> >> shared with the neighbouring write.  Once the first of the two is
> >> written back, the second reads the page back from disk before it writes
> >> its part.  32 threads wrote interleaved records to one file on
> >> XFS (emulated 4Kn NVMe, 4 KiB pages).  Before and after 4/6:
> >> 
> >>   record  pwritev2() flags          4 KiB device       MiB/s
> >>   bytes                             reads per write
> >>                                     before   after     before  after
> >>   47008   RWF_DONTCACHE             0.97     0.0005    831     2281
> >>   47008   RWF_DONTCACHE|RWF_DSYNC   0.99     0.0005    601     1227
> >>   6000    RWF_DONTCACHE             0.97     0.0001    121      488
> >>   6000    RWF_DONTCACHE|RWF_DSYNC   0.99     0.0002     90      206
> >> 
> >> What is left after is metadata.  49152-byte records cover only whole
> >> pages, and they read 0.0005 per write either way.  The test program and
> >> script that produced this table, and how to run them, are in:
> >> https://lore.kernel.org/linux-nfs/atqJBS8MlYfeUU-t@kernel.org/
> >> 
> >> 4/6 has the page cache keep such a page for the write that completes
> >> it.  5/6 lets a writer that syncs its own write complete those pages
> >> itself once the sync is done.  NFSD does that for a stable WRITE.  6/6
> >> is the NFSD change that uses it.  2/6 reports the DONTCACHE dirty count
> >> in the bdi debugfs stats.  3/6 adds folio_mark_dropbehind(), which 4/6
> >> and 5/6 use.

<snip>

> >
> > This all looks good to me at this point. This is a mixed mm and nfsd
> > set though. How do you envision this being merged?
> >
> > Reviewed-by: Jeff Layton <jlayton@kernel.org>

Thanks for the review Jeff

> My recommendation was take all of this through the MM tree, since
> the NFSD patch looks like the first consumer of the work, and it
> depends on how the MM API is changed during review.

Chuck, I agree, the mm changes would certainly do well to go through
the mm tree.  But the 6/6 NFSD patch that makes use of the preceding
mm dontcache interface changes requires 4 of the 6 prerequisite
changes to NFSD DIRECT that have have staged in cel/nfsd-testing.

So I think we might need a post-merge NFSD tree for 7.5 that applies
the 6/6 NFSD change ontop of the changes that would land through mm.

Willy, I would like to work with you (and others in mm if they are
interested), Jeff and Chuck between now and April 2027 to see these
changes accepted for the 7.5 merge window. And if that were to happen
I cannot wait to celebrate with all of you at LSF/MM in Portugal!

Thanks,
Mike
