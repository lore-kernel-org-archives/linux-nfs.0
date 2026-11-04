Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793778110;
	b=inPU3D1EHtxC4ysPMWLGt6NoePkjFrojEYGdiC2H02QINUMr+NcL+RqhoP+fzrSlS7jS
	 /6ROEUCSZn+I0V2q5syIX0CJ+WRDnVInLsKbqBUipWDc15YZq6XzX2toywnsg0DZrRN/H
	 3kXxYGtQXb5+mUP8G3nfxBIy+LATQHM6kte/SY01reEVAs0RxKHT1IjtBJ7YbJXvUIfUA
	 sqpyDWw/qYeE1ELT5XP7JAUVqQDCQa9QINNUpvuPrLjEFFVe9GyHeadmFHYfVAqcMk7/y
	 rQNHtcOfXYMECWoN348ZJppukQOitsJo8wqSxVetjQ2fQBG4zzO+8Z31BaFZX76Lf8A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793778110;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To;
	bh=EzxVUFR8YCm12cTcpaJ/tba3+hMl+DBqx15gU0oHmDw=;
	b=b5127pJSm9k0FvlNF6crLTf/GVjPtecSN9YmsjMYkufNYCRKJpl9pK++h0HoogX7TBDb
	 wSklCDo0cKrYEsPEJeFnzceD5FM1UVPNu5KmF/UlHXUexqU485NCiYNZgkIyKOqlhqxn8
	 6B3clAPdhv9TvzxWMfPUVUp0/tc0bqdP1So2Cl00Bli7e/mAwci9eFgG5gpl2w7GkHS40
	 iGC3lvzLnx9kqm7AFhC+oE/4rGZIb+GBBuA4YCXJKhwNSItDY7sRV7I6N1rj0QtspPCzd
	 yq18nwbazHBf9EiFSfOSg4l9EQhNwWfNh1E3yElqMqNjysZkNSenbDdaGGBQL1/KJ+g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="UkUO0/h5";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id ED84A606A335
	for <linux-nfs@vger.kernel.org>; Wed,  4 Nov 2026 07:41:49 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=UkUO0/h5
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B9C341F0093A;
	Wed,  4 Nov 2026 07:41:48 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793778109;
	bh=EzxVUFR8YCm12cTcpaJ/tba3+hMl+DBqx15gU0oHmDw=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=UkUO0/h5nq4yWOGDBcl0WCKB+upsbJurdi2Ipu0jdKxPeQWva2M+rhRuCTtMVVFh6
	 ci94mRPhGw4qUMEDtcu5kziE7OiNVVcHvXPyow8F3wgQ1JkI67ZMZdk8J4YZs8qKj2
	 2HWNSdBTIF+I5/J5+jqhLHlpswiz1mHMdYSnJAO4UBZdDwNVtk/n42R313symFTVZ8
	 UdS3p4NO19ukBstIXoiLyrLVvZmoIp6UZPMk+7f2/RRuxa074ZBwxxmso+iYs63gMf
	 xIex+McOIL2vU5DqUhmq6CNidLjX6ws8x7JaXGqWOyTUOeB+L7RhdqQ/5siBaYzscr
	 lAPzlzAOjuz2Q==
Date: Wed, 4 Nov 2026 08:41:46 +0100
From: Krzysztof Kozlowski <krzk@kernel.org>
To: Wentao Liang <vulab@iscas.ac.cn>
Cc: Chuck Lever <cel@kernel.org>, Tom Talpey <tom@talpey.com>, 
	Anna Schumaker <anna@kernel.org>, Olga Kornievskaia <okorniev@redhat.com>, 
	Dai Ngo <Dai.Ngo@oracle.com>, Jeff Layton <jlayton@kernel.org>, 
	Trond Myklebust <trondmy@kernel.org>, linux-nfs@vger.kernel.org, NeilBrown <neil@brown.name>
Subject: Re: [PATCH] nfs_common: release the decoded ACL when an entry is
 invalid
Message-ID: <20261104-kittiwake-of-authentic-tempest-5f3eaf@quoll>
References: <20261104022804.1484027-1-vulab@iscas.ac.cn>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20261104022804.1484027-1-vulab@iscas.ac.cn>


On Wed, 04 Nov 2026 02:28:04 +0000, Wentao Liang wrote:
> xdr_nfsace_decode() allocates the posix_acl lazily from the first ACE
> and stores it in the decode descriptor.  A later entry can still be
> rejected, for example on an unknown tag, extra permission bits, or an
> invalid uid/gid.  xdr_decode_array2() then returns the error to
> nfsacl_decode() and nfs_stream_decode_acl(), and both return without
> releasing the partially decoded ACL.
> 
> Release the descriptor's ACL on the decode error path in both callers.
> 
> Fixes: a257cdd0e217 ("[PATCH] NFSD: Add server support for NFSv3 ACLs.")
> Cc: stable@vger.kernel.org
> Assisted-by: DeepSeek-V4.1-Flash and OpenAI Codex
> Signed-off-by: Wentao Liang <vulab@iscas.ac.cn>
> ---
>  fs/nfs_common/nfsacl.c | 8 ++++++--
>  1 file changed, 6 insertions(+), 2 deletions(-)
> 

Multiple things here:
1. Your team ignored completely previous feedback. Multiple times.

2. You use multiple identities with this email address, thus I doubt that we
   speak with an actual person.

3. Your bot does not even bother running checkpatch, right?

4. Nothing of this was reproduced nor tested.

5. Finally, the same feedback:
You sent multiple independent patches, to multiple independent
subsystems. The amount of these patches clearly suggest this was
AI generated and most likely not tested.

More importantly, you sent all this work without properly organizing
relevant patches into patchsets. This makes reviewing difficult
and might cause multiple reviewers to address the same issue.
Replying to the entire set is impossible and requires handling each
patch independently, instead of applying or discarding the set.
Maintainers also won't see the bigger picture of your work. Quite
worrying.

This is on the verge of hostile patch: bomb us with so many
contributions, we won't be able to handle them in efficient manner,
like responding ONCE to ask you to slow down.  Considering all this
is untested and LLM generated, I have even more doubts whether this
should be considered for review.

Please read kernel documentation BEFORE posting more work. It will
explain you how to identify subsystems, how to organize your work per
subsystem (so a patchset grouping multiple patches with a short cover
letter), how to document the issue discovery method and what was
or was not tested.

Best regards,
Krzysztof




