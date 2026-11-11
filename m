Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794416880;
	b=L+h2VabZ2RSdSkJ0KaYJ7uemozF7yuWAdL9o5FRBEQEJC8qb7Caby6WJCMPDsyj6uZL3
	 cigvgPmsLU2BR1/IHdvG60jljrJ/5vEQBHf2vl4DB+5wbctXtQaN0JRR8mQWFBRx+R3kZ
	 dPTFGSojWofzTViPb3czB0x1awdtFDI4xxbH5/k8F+fVWSyFxAJVVLYg/w5Jl6K6W8bJ1
	 70fNspw2ee073bVKPIXrYCURJgggb0weHXtK0CtnJpov2pgEprtwNkwzWMcoacn3KI9sI
	 HCdQxYEC37jPoAE/dXIXZQcTf+GS8f1PlEGN81DZ93MCyWGAuQGjeft2N2YgEtVwIGQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794416880;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To;
	bh=EVjPfIhbegPkclow7z3LOCHRRvYAbwNHNHrxosLIJpc=;
	b=fCkkLCl/EoW2AEq5JqsgsS2w8maIV1BL85WtMIqpVmhUcfpg+9h8O5BV6dLt8E/PceP4
	 lX0wGScZLbqIkw5aygOGOr4r7XRffLD6OdQvPVp/mKRkUCzM0fn8YVYUSkfIw1NDrQ/LF
	 7jLxPnJMV5iVQpQL/qqweapY9g+YenlNFDfkdlEKZAGVqGSaQtg+KJ8LKjoDcoHVfAD/y
	 Zl2dPcsUxumfgzExY8tEkcOz4NQKce6taQ7anhsGjDDCSnjDJwCsVXQjgniQaQhelUVte
	 FsdfXsf5oodnZ0cwH0NJoJE9+Jkf0gBUt606iWrp2DvoL7qN+RDTVIE2WuzlqsQXjeA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Y4dnyaXl;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DA219606A324
	for <linux-nfs@vger.kernel.org>; Wed, 11 Nov 2026 17:08:00 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Y4dnyaXl
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 85C721F00A05;
	Wed, 11 Nov 2026 17:08:00 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794416880;
	bh=EVjPfIhbegPkclow7z3LOCHRRvYAbwNHNHrxosLIJpc=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=Y4dnyaXlARpJm7CqzQ3zlqVd3/mzVsIxAUt4J4ZEleYcACQZYG4GCKU6n3UJgRNhZ
	 lxK4dkKKhU42UGeoJTEQPK9GbLtTCNTZO0mfX9OExqX8wKnZDi0s5pJicKy5SgPfO+
	 74VJSD7nt+hNAabdNHo3p7ga+NyzWRGiaGxjMcngU6k6C3PeA25AEaiII54ThxfLsA
	 Uwvk6Ol05eVxjG15lw/gwbsZWpbkO/Dgy4vs7Z+FkOw8vz7NLXaaEAq67OTetaqdgz
	 duBFFlHI7CRBi5NEaydVMWVIeFE5BKbOykkGc7Da4mTPWBLtmFvwSDKETXBPm9rA94
	 Q1JiuvYhU3LJQ==
Date: Wed, 11 Nov 2026 12:07:59 -0500
From: Mike Snitzer <snitzer@kernel.org>
To: Chuck Lever <cel@kernel.org>
Cc: NeilBrown <neil@brown.name>, Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>, Tom Talpey <tom@talpey.com>,
	linux-nfs@vger.kernel.org, sashiko-bot <sashiko-bot@kernel.org>
Subject: Re: NFSD: Refuse a direct READ whose aligned range exceeds the reply
 pages
Message-ID: <avSg75nnYeR3t60Y@kernel.org>
References: <20261111152050.172047-1-cel@kernel.org>
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
In-Reply-To: <20261111152050.172047-1-cel@kernel.org>

On Wed, Nov 11, 2026 at 10:20:50AM -0500, Chuck Lever wrote:
> nfsd_direct_read() expands the READ's byte range to the file's direct
> I/O alignment, then maps reply pages until the range is covered or
> rq_page_end is reached. A block device whose logical block size
> exceeds PAGE_SIZE reports an alignment larger than PAGE_SIZE. With
> 16KB blocks and 4KB pages, a maximum-size READ at an offset that is
> not a multiple of 16KB needs one more page than the svc_rqst has.
> The loop stops at rq_page_end and passes a truncated iterator to the
> filesystem. iomap rejects the unaligned length with -EINVAL, and NFSD
> returns NFSERR_SERVERFAULT for a READ that a buffered read would have
> satisfied.
> 
> Check the aligned range against the reply pages in
> nfsd_direct_read_ok(), and fall back to a buffered read when the
> range does not fit.
> 
> Reported-by: sashiko-bot <sashiko-bot@kernel.org>
> Closes: https://sashiko.dev/#/patchset/20261109-xdr-page-base-v1-0-a4f4411d760d@kernel.org?part=11
> Fixes: d686e64e931c ("NFSD: Implement NFSD_IO_DIRECT for NFS READ")
> Signed-off-by: Chuck Lever <cel@kernel.org>

Reviewed-by: Mike Snitzer <snitzer@kernel.org>
