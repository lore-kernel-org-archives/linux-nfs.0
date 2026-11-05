Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=213.95.11.211
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793865580;
	b=LU9KW+jF6RuYCeaLZHnd+lGtLVgZ9Caj0jL4vJOzHwELaplb3X7QWA4hXlEm5/qHwPLK
	 d8/A/IbX2PXE7KwZYWfKfYl6369tJ/wPIHbGFBWc8xctkUo/PxMHs/pb/jM1a82mUW+cL
	 vcxeTX4RHW5vUgva9tdSoH7rUscW7Sai3GwqzqVn/J29APGC5pRZcYDin3BxL8woWzz/5
	 HXk4Kxy6gHsdiDto5FJf47CShp86r5bioWG4crET0RgQICSH6HpOZZklIBptnjfA/YFUt
	 0DLvOSvQDUJet7f4bl32KMlGd3lzZZgOSQFn6VJRD8GYmurx9f8CsZW6BPAdWimYvgA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793865580;
	h=DMARC-Filter:Received:Date:From:To:Cc:Subject:Message-ID:References:
	 MIME-Version:Content-Type:Content-Disposition:In-Reply-To:User-Agent;
	bh=Ln52JZJddcocWfl/gxFwMTgRR26+BYApy8AfhWYLYyY=;
	b=sQUcFbxbD4f6tpm5l13wNLgKSKUIS42wIpGvxv5R4+335UmnKWU1HXZBHnQ6oWz1t1JZ
	 aehJNT2dWaFq2zYKXWzVe1Vg/rCYS9aYiNui0nMSx9rnAOBMB0VB8foL/+wPk2L6MDCJi
	 MeRVZ6gn1OpcQcN/KTTEHHgNqv2+GW0q0+DZpSpxfnrmbNIzWRCTDXgr6+GEzB3tre4Uz
	 1TT8ifv3KneqzsNIFb5pd49VZambhHdj74RiImTGb8c8tbbvtLPCXVNFcaIZQh8hiqoeJ
	 vP013VmUV6YQ8ES/uunrThOEE/ztZX/TfZa+aeZqKhCdRNaygO8znv+N5IfnNJ++o6g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=lst.de;
	spf=pass smtp.mailfrom=lst.de;
	arc=none smtp.remote-ip=213.95.11.211
Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	(using TLSv1.2 with cipher ECDHE-ECDSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4D2FB606A31B;
	Thu,  5 Nov 2026 07:59:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 4D2FB606A31B
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 29D0C68BEB; Thu,  5 Nov 2026 08:59:36 +0100 (CET)
Date: Thu, 5 Nov 2026 08:59:35 +0100
From: Christoph Hellwig <hch@lst.de>
To: Mike Snitzer <snitzer@kernel.org>
Cc: Christoph Hellwig <hch@lst.de>, Matthew Wilcox <willy@infradead.org>,
	linux-mm@kvack.org, linux-fsdevel@vger.kernel.org,
	Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>,
	linux-nfs@vger.kernel.org, NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>,
	Jens Axboe <axboe@kernel.dk>, Jonathan Corbet <corbet@lwn.net>,
	Jonathan Flynn <jonathan.flynn@hammerspace.com>
Subject: Re: [PATCH v10 7/7] NFSD: drop a shared boundary page only once
 both WRITEs have written it
Message-ID: <20261105075935.GA18069@lst.de>
References: <20261103211754.35352-1-snitzer@kernel.org> <20261103211754.35352-8-snitzer@kernel.org> <20261104091543.GA31130@lst.de> <autk-osSQ8l2LKz1@kernel.org>
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
In-Reply-To: <autk-osSQ8l2LKz1@kernel.org>
User-Agent: Mutt/1.5.17 (2007-11-01)

On Wed, Nov 04, 2026 at 12:01:46PM -0500, Mike Snitzer wrote:
> It is the transfer size of IO500's ior-hard: every rank writes
> 47008-byte records, interleaved with the other ranks, into one shared
> file, with O_DIRECT.  It is meant as a hard case, and it is the
> workload that showed the problem on our servers.  The same happens
> with any record size that is not a multiple of the page size.  The
> cover letter also has 6000-byte records.

So based on a bit googling your totally optimize this for an intentionally
stupid benchmarking workload.  And that's not been disclosed anywhere.

I guess everyone else was right and just ignored this bordline malicious
submission.

