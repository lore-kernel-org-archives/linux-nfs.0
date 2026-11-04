Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793776357;
	b=s75KkmQj+3NS4nEeWW4pIrvRtTq8Jv42/ICwG0QSSJTRbYkl4EAsJPWt+Rm9okF0KPau
	 GFb0/1yaUB1JsLJJHPaXK0l1Jt+nxgJa7cmFXuqcEeDHRDMXBw6NRJA+5/E9J/h5fdhwS
	 lg2i8jso33+5Frp6xUPLLnMS8QGQDYomx3qbkY290rmLAbLSTf73bRTFH4zV4GCKUkQdG
	 Nrns7r14M4M8HZ3J9eI2h/MFzTghjDdS2FqwJh+r6hWQo3sR6dY3HlqdpVMNwP1NJ85in
	 WRHUpgvikUX7D3DfiQQqdeCdIw9iAd8v6ZV6Zp4boJhLFifmaOIQnUji0fNH9jEdiDw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793776357;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To;
	bh=IO5qcDZIccvQg7caNJP/uh/0uCikE1QDZcQnhFjAtlM=;
	b=ALFuyYVvXENqPX9DTeyc4qY+oTzAISxgLxbgjc1Ei7R2H7wbgeVVqK/OmpZUqEPiBB9g
	 dcWnEJuOii4rTKrhWH9zrlbBV8HlvdcHkT7+L3/K5ub5NyWkcMy+qI18TqytWjtva5uHv
	 86afeFxHe7r3E9Ww9IZi+Ql+oDbeWdPy/lDnXWk0WKLsuyqCUY/g6PKZTrF9ECuXrrg6h
	 IpQ3moTZXlzXSRFtI2yw9iVSDRxjeiQX0MdKSTfqluP5AOzUCu5LDfCeU4AOdN0PL9BtG
	 wfXn+ZQqDW1vCtZvfTb3rGrtDCSnwp9pZuHFDPZhY81YSGNJkGqtLUc4J1kGjvh19KQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=EhB6O6pV;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 814AB606A31B
	for <linux-nfs@vger.kernel.org>; Wed,  4 Nov 2026 07:12:37 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=EhB6O6pV
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9D81E1F000C1;
	Wed,  4 Nov 2026 07:12:36 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793776357;
	bh=IO5qcDZIccvQg7caNJP/uh/0uCikE1QDZcQnhFjAtlM=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=EhB6O6pVhUislB83XNjVc8q9v7SEnUzgdMZrTK6P1CRir+mPIIBQXatEt4KeUoZfd
	 6UQEkm5R1xLthYHMkxnf825W2Lh9wUR+mMVaaRN7S4yeg2EJpisc33FogLoJZvhrS5
	 ZwyNXaLyGAq7ozSj9hvQb/lOwFgbeKPrggh3vDIKznK7d0Wgtsyj2resxsV5tfi7X2
	 GLXq71IunwI9Uvzx7HpFKKRrCugnAg73h1UG6qrYVJ6Ky4P9lZ3JH0m2KXT7dq6dg6
	 6eHkkvn6bgvjjW99ZUwFqYoW7tGBkOJOb9hEt/71XdK7kN3CepWdL5cHsZhFnEwrcx
	 LTWoJarjgsCiw==
Date: Wed, 4 Nov 2026 08:12:34 +0100
From: Krzysztof Kozlowski <krzk@kernel.org>
To: Wentao Liang <vulab@iscas.ac.cn>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>, 
	NeilBrown <neil@brown.name>, Dai Ngo <Dai.Ngo@oracle.com>, Anna Schumaker <anna@kernel.org>, 
	Olga Kornievskaia <okorniev@redhat.com>, Trond Myklebust <trondmy@kernel.org>, 
	Tom Talpey <tom@talpey.com>, Jeff Layton <jlayton@kernel.org>
Subject: Re: [PATCH] lockd: drop the host reference if the reclaimer cannot
 be started
Message-ID: <20261104-noble-girlish-velociraptor-c3eb5c@quoll>
References: <20261104021540.1468799-1-vulab@iscas.ac.cn>
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
In-Reply-To: <20261104021540.1468799-1-vulab@iscas.ac.cn>


On Wed, 04 Nov 2026 02:15:40 +0000, Wentao Liang wrote:
> nlmclnt_recovery() takes a reference to the nlm_host before spawning the
> reclaimer thread, and the new thread releases it when it is done.  If
> kthread_run() fails there is no thread to do that, so the reference is
> leaked and h_reclaiming stays set.
> 
> Clear h_reclaiming and release the reference on that path, like the
> reclaimer does when it finishes, so that a later recovery attempt for
> the host can still be made.
> 
> Fixes: df94f000c46c ("lockd: convert reclaimer thread to kthread interface")
> Cc: stable@vger.kernel.org
> Assisted-by: DeepSeek-V4.1-Flash and OpenAI Codex
> Signed-off-by: Wentao Liang <vulab@iscas.ac.cn>
> ---
>  fs/lockd/clntlock.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
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




