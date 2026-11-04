Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=213.95.11.211
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793783868;
	b=eosYFX2b9AM4DQUjndibgjf/wsFnp4CWZGUL2e/N1+g8wcTVhFU41pRQONoe3+jKYyzY
	 uZzYbix6IB7iGl8KC1JH8R66UfDBv7t/Fh/eOusRJDKtA9bZUTc1S4I4xaoH7N8Vl1W4n
	 QkBNll5CzVOB7cQ6Zo5sKFE6FhXenGJaZkmZLo94/lTbt0sVbGgszciXjKyBT+f9ZFOgi
	 yX7wI8JSUSBX/f9wNPFnFQVtGiEh9Is9DrwflRoCapjlxOs4KgI8hveO59m219wqD0ncT
	 tHg9eCiSPqp+ggUPygHLkzgsGjpKFfhew81EF8Hy/8pUj8JWJtI3JzfRlaMr29EOP/A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793783868;
	h=DMARC-Filter:Received:Date:From:To:Cc:Subject:Message-ID:References:
	 MIME-Version:Content-Type:Content-Disposition:In-Reply-To:User-Agent;
	bh=2j+fNl2kk6EUtKkWbcK+QC3SrWBZ1R/JSeRG1EGPR8o=;
	b=L4nBv+azvk68NACn3oUcwm6rC+1MonCuF3M7ZHG0pCdXf4jmpuPBrlr63bp1Z4ZOLs20
	 7F9r0Z/DFw4RSO2rV5yaIHitMVPatAu65npMOS36c3glNvYPIlnPvu/Us3m7I9/rLo4x8
	 pLBFD3u2vTn36AaPaTO3+MVjpr5+MYB4LVSdqAaSgLJcgmvzwEiyWKuPf5e12g/Fe8IpW
	 4XhnM64iDdy0BPIfsd0Q54ZpJyefiUkTew9TajYY6cR1sPb48HITBwaVpnNz+TGMHri+w
	 1a64gwgi5s97NQzmOfwmbb3kDuCPAhZzDCgNJe88850gfI1Qa5gTPGLnzFQHkxksCSw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=lst.de;
	spf=pass smtp.mailfrom=lst.de;
	arc=none smtp.remote-ip=213.95.11.211
Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	(using TLSv1.2 with cipher ECDHE-ECDSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CD367606A33F;
	Wed,  4 Nov 2026 09:17:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org CD367606A33F
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 5149E68BFE; Wed,  4 Nov 2026 10:17:41 +0100 (CET)
Date: Wed, 4 Nov 2026 10:17:40 +0100
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
Subject: Re: [PATCH v10 0/7] mm, iomap, NFSD: stop uncached writes reading
 back shared pages
Message-ID: <20261104091740.GB31130@lst.de>
References: <20261103211754.35352-1-snitzer@kernel.org>
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
In-Reply-To: <20261103211754.35352-1-snitzer@kernel.org>
User-Agent: Mutt/1.5.17 (2007-11-01)

On Tue, Nov 03, 2026 at 04:17:47PM -0500, Mike Snitzer wrote:
> Hi,
> 
> An uncached (RWF_DONTCACHE) buffered write drops each folio it writes
> once the folio is written back.  A folio that the write covers only
> partly is shared with the neighbouring write.  If it is dropped before
> the neighbour writes its part, the neighbour reads it back from disk
> first.  32 threads writing interleaved records to one XFS file, 4 KiB
> pages, before and after 5/7:

Very colourful terminology here.  Who is "the neighbour".  How do we
know a "neighbour" exists and what it wants to do?

In general if the user gave a very clear indication that the data
should not be cached, it is a bit awkward to second uess that.
Especially if the expectations are not very clearly documented.

