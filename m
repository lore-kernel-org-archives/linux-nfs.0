Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=213.95.11.211
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793703048;
	b=ONj/c++VxA9Jo4Ayw5z81p2Q0VF+c4Gfuux3MS/X3hGS/B87kp+XDajbbAfLJIzieRcI
	 86XPq+kf2aOWlGTaBahHBLg9nut6eVtNYhNY88/KcUKGZ899meAguVIQncBKvvMRVvI19
	 0Ypg6Ato84hGkY1Xtayaz8XGOg15jt4c9+PnEIRC55XITJtbAksJ3SQ9kwSJBRE8kgiaG
	 NQ0F2z+K2KQGAHUeUNoZ+YIjIg+FFqV9IVuc4qHAY0ckasdWXOwWq6tBQfcOj1j9bOTXD
	 juavMCoF+aBUMSIkkJY1gSeArbvBqXwi/29hsMMKtZNGc5be2tM2Igt1XwB8NAq7H+w==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793703048;
	h=DMARC-Filter:Received:Date:From:To:Cc:Subject:Message-ID:References:
	 MIME-Version:Content-Type:Content-Disposition:In-Reply-To:User-Agent;
	bh=f/R88vgW0ovDUfLzxlud9DBVXC7y/E2SblSvUAHW808=;
	b=Ref3BQmNXjjhw7TeF1mvxZqd4IL0hT5zrBhzmQf6/6OMU6AkimEgFaMbckXksaP4DG1u
	 6asB8T1PUPKfG4a8wM5kMKjPWssWlgEd6bIaN9Ii62qNp7VLws5Dxr8hxXUnc8M0fZH37
	 0IglCpxHkoFq2I6chTnjjcha5+WmolXuNtM9O2Fov3/ABaRTabeoiQNbraWcQPqD3L1Xo
	 C7hVoaQeJrNWv7ZYXaarGc4UYUk6rrY0MpGbH5fLrjt4aygXrq1HG2rvwtc1yLQa1llBQ
	 Ym3ht3z489TRTZSJ/GSZ625V/1vH+1k+oAUgPuSgoZrHl7fWZo5Pf6wu85Bm1CuC49A==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=lst.de;
	spf=pass smtp.mailfrom=lst.de;
	arc=none smtp.remote-ip=213.95.11.211
Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	(using TLSv1.2 with cipher ECDHE-ECDSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CA66E606A32F;
	Tue,  3 Nov 2026 10:50:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org CA66E606A32F
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id CDEC168B05; Tue,  3 Nov 2026 11:50:42 +0100 (CET)
Date: Tue, 3 Nov 2026 11:50:42 +0100
From: Christoph Hellwig <hch@lst.de>
To: Mike Snitzer <snitzer@kernel.org>
Cc: Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org, Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>, linux-nfs@vger.kernel.org,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>,
	Christoph Hellwig <hch@lst.de>, Jens Axboe <axboe@kernel.dk>,
	Jonathan Corbet <corbet@lwn.net>
Subject: Re: [PATCH v9 4/6] mm, iomap: keep a partly covered page until an
 uncached write completes it
Message-ID: <20261103105042.GB7296@lst.de>
References: <20261024221152.6965-1-snitzer@kernel.org> <20261024221152.6965-5-snitzer@kernel.org>
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
In-Reply-To: <20261024221152.6965-5-snitzer@kernel.org>
User-Agent: Mutt/1.5.17 (2007-11-01)

On Sat, Oct 24, 2026 at 06:11:50PM -0400, Mike Snitzer wrote:
> An uncached (RWF_DONTCACHE) buffered write marks drop-behind every folio
> it creates, so writeback drops each one as soon as this write's data is
> on disk.

Please write proper commit message.  This sentence is absolutely
unreadable crap, and it gets worse from there.

If you can't state the problem you're fixing in your own words, you
really should not be touching this code.

> Measured locally on XFS (emulated 4Kn NVMe, 4 KiB pages), 32 threads

And avoid useless details.  What is emulated here, why does it matter?
Unlike SCSI/SATA nvme doesn't have the concept of native vs non-native
4k block sizses, and even for SCSI/SATA HDD that was purely a marketing
term which doesn't matter for code.

<snip pages and pages of irrelevant crap>

Do you really expect someone to read all this?  Please!

>  
>  	if (iter->flags & IOMAP_NOWAIT)
>  		fgp |= FGP_NOWAIT;
> -	if (iter->flags & IOMAP_DONTCACHE)
> +	if (iter->flags & IOMAP_DONTCACHE) {
> +		size_t unit = mapping_min_folio_nrbytes(mapping);
> +		size_t off = pos & (unit - 1);
> +
>  		fgp |= FGP_DONTCACHE;
> +		/*
> +		 * The smallest folio the mapping allows, a page or a block
> +		 * where the block is larger, that this write covers only
> +		 * partly is shared with a neighbouring write: get it as just
> +		 * that, which is kept until the write that completes it.

What the heck is this monster sentence supposed to mean?

> +	/*
> +	 * The page cache marks an edge it finds uptodate.  With blocks
> +	 * smaller than the folio, the edge this write completes is not
> +	 * uptodate yet: mark it if its other blocks are.
> +	 */

When did the page cache become an acting entity?

