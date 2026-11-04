Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=213.95.11.211
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793783751;
	b=OssKobp25zAM1uF5m8uyHytB6WQ+TRLNAd41A/VOOWJoWlXs7gEMjOX4aoV9WFX3nuR1
	 hkSBvxcjboCNuydjGPCmDOyhQ9aUTfB4PmqS9FcAAfSsqL1MQaEmSFOhYxovZ6+DiZ4p7
	 0+ueeXAA/3WKQ+utgHwPmnQ5hriLNVwjGfCOMexdQRJkUj/rwM+bNqEYkE/eY3s6OH+OG
	 wsRJmgxlgy8pvDZoBkrfxRQFiOFOD0Pa6jLpfxPlvPY7Qd6cnvMcaXwLBC8F8PxezhBcA
	 Yg7t4vxCYzAdjwWO0eH4Gl7PkthUi6OmWj64jpeSWkqAVhkJglkPoZvLwOTaBx2Slrg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793783751;
	h=DMARC-Filter:Received:Date:From:To:Cc:Subject:Message-ID:References:
	 MIME-Version:Content-Type:Content-Disposition:In-Reply-To:User-Agent;
	bh=b2dMElOQFbRVtowHgZXN+VNpS2AR+GYKqef8wfoWtBE=;
	b=QWLha9FXLSJEsolisMgkK7fe7W3G1YnMKImsrS8T7gfzRzLo3obPYcT8t0RV3f95Vt7l
	 2NTE6iggKZOX+RjdNrmQpFH7skRJNte3LLn/Hs+nOha01fItMYR3xxUziF/QyJuZXkCM+
	 6nFbBPK1etmF/KtoAVMgpjtt3/reWaFnyX3XpArNxzujf6RMMjeTo2jr0ZNgpZ8HPBuzk
	 fdS0uCOROBJoA/Qj6w0mj4iQ+Z+Q9vSS82Lx/PPLzxcY/zOZ6NnukMatHLb/lfiQKXAXy
	 dd2QW7axsEIE/fh8vDewPYXVGiYrCPtlsiTXLH45ilktQ3aIdDCW3ONVKcDp8ID8R9A==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=lst.de;
	spf=pass smtp.mailfrom=lst.de;
	arc=none smtp.remote-ip=213.95.11.211
Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	(using TLSv1.2 with cipher ECDHE-ECDSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B53E3606A336;
	Wed,  4 Nov 2026 09:15:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org B53E3606A336
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id C108C68BEB; Wed,  4 Nov 2026 10:15:43 +0100 (CET)
Date: Wed, 4 Nov 2026 10:15:43 +0100
From: Christoph Hellwig <hch@lst.de>
To: Mike Snitzer <snitzer@kernel.org>
Cc: Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org, Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>, linux-nfs@vger.kernel.org,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>,
	Christoph Hellwig <hch@lst.de>, Jens Axboe <axboe@kernel.dk>,
	Jonathan Corbet <corbet@lwn.net>,
	Jonathan Flynn <jonathan.flynn@hammerspace.com>
Subject: Re: [PATCH v10 7/7] NFSD: drop a shared boundary page only once
 both WRITEs have written it
Message-ID: <20261104091543.GA31130@lst.de>
References: <20261103211754.35352-1-snitzer@kernel.org> <20261103211754.35352-8-snitzer@kernel.org>
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
In-Reply-To: <20261103211754.35352-8-snitzer@kernel.org>
User-Agent: Mutt/1.5.17 (2007-11-01)

On Tue, Nov 03, 2026 at 04:17:54PM -0500, Mike Snitzer wrote:
> NFSD splits a misaligned direct-mode WRITE into a direct middle and
> buffered DONTCACHE ends.  Each end covers its first or last unit, the
> smallest folio the mapping allows, only partly, and shares that unit
> with the neighbouring WRITE.
> 
> Issue the buffered ends with IOCB_DONTCACHE_DEFER.  Before writing an
> end, ask filemap_dontcache_edge_completes() whether the neighbouring
> WRITE has written its part of each shared unit.  Once the WRITE, its
> fsync included, is done, complete those units with

Why does the write include an fsync?  Are these STABLE writes, and
if yes, why?

> filemap_dontcache_edge_complete().  A short write completes a unit only
> if it wrote its own part of it.
> 
> With this commit, 32 interleaved writers of 47008-byte records through

Can you explain where this very odd number comes from.  Is that just a
worst case?  Or for some reason actually relevant?

> NFSD DIRECT read 0.0001 to 0.0002 blocks per WRITE, instead of reading
> 0.99 blocks per WRITE.  FILE_SYNC WRITEs no longer wake the DONTCACHE
> writeback kick, where they woke it 23,000 to 65,000 times a run without
> IOCB_DONTCACHE_DEFER.  On a four-server pNFS flexfiles rig, the page
> cache grew by 2.9 GiB during the write phase instead of about 11 GiB.

How does this compare to just not using DONTCACHE at all for unaligned
tails (and maybe heads, if for some reason they I/O you care about
reordered writes).  And how does it compare to that plus manual
sync_file_range calls to micro-manage the I/O?

In general I'm not in favour of so many core hacks for
very nfsd-specific behavior.

