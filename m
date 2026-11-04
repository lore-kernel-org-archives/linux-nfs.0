Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793776304;
	b=oVC0bppgf7vDcnyp4gEm4IzNVceGFmu/ltkWxfge0AqiPg9Vp8TywWbpXjxILQUvlAqC
	 BpPBZbKblbZtTuBqzgrB6EAx+2YzC73fIQ+3PXWOOUH87esQiY/BcZvvzWOoyh0v5/tx4
	 j8Kt6i/pb/TxUucR5YCRbX5eMOpMSFnwfrmkSLEYHSIPLbxF5cDsb26HZKnwkFMk/OPUk
	 s6N4smW2JcxVRMFCBli3eFCKgcglGWknXpYPfFhdoxsHZ1HMobSCDRlltN9/RQQtUCFkk
	 7EshvW6TFLbCvdSjU5aTsgxsWrL1j7HV6zn/PKS6b0i7cK6uOKB+FCHCsU1mB8Uw6kA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793776304;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To;
	bh=bec9RzTPLLmJAAb1t+Dt4YBUMgyTBx8NXKAJ/4cYHqk=;
	b=1Z5+9yWTlzuNGQDxF2cv4HKoiYz5FNDrsu9Af/XkV+MBNJqQwq5Ou760tCUHr5syrdzG
	 fk2m3rkUaEjVdmbEsnc/2Ps8ioAQKDyJslyymOglBY8OrLGHIjQNVU0/ptdot2/PXQgL6
	 W5pJX1JXJw7zWx/i8C2uyeeMtUyf2zcnMlRRXy9VXd8PofpFzYwVWFgJJgvTj6Bfag5iw
	 K+x/BIsmXKGgnr+MNgxWI0ocx6vyG+UiQcSV/8/U8TEChHJ+lx+FiB615njMnnAzGolyV
	 XVjzMl5aHmIQFNgMleFSNNNMIpjyPF7FQxf5ZsWE1zd5XyOPWLESq5FKF4moOg0vJow==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=ThlOQyHz;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 226E1606A31B;
	Wed,  4 Nov 2026 07:11:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=ThlOQyHz
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6B49A1F000C1;
	Wed,  4 Nov 2026 07:11:43 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793776304;
	bh=bec9RzTPLLmJAAb1t+Dt4YBUMgyTBx8NXKAJ/4cYHqk=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=ThlOQyHz/xayqNhXt2GKt4v6ZaPZccwwetPDz4uBCv+G89DcYedZFCVjSZQPmIp3z
	 ef+r5s3rIfP8zrML4glscx6rwfn7lWkxyQKLb8iMMk61qg6bNdXKXhl2ckWyqlS8W8
	 kpff/k6siaFoGJ56cil9ZycYJeAaQAKsPfiBsGap5YS4BLI0VfQXgCZ1cXH69G2R8p
	 ve6LRH7lUfQSwDVAg8AzzkWxdVaQfCpgSpplHOrZFsYiNLuxnfavqwb+GI28OYqCGj
	 5fyaixoNhRQ9faS649I0hVqsX2vUQMsQJYEDkSoF37Zpyt0X1GUixNu747iiFDULlZ
	 0zUfClrOZ910g==
Date: Wed, 4 Nov 2026 08:11:40 +0100
From: Krzysztof Kozlowski <krzk@kernel.org>
To: Wentao Liang <vulab@iscas.ac.cn>
Cc: Dai Ngo <Dai.Ngo@oracle.com>, Jeff Layton <jlayton@kernel.org>, 
	"David S. Miller" <davem@davemloft.net>, Paolo Abeni <pabeni@redhat.com>, 
	Anna Schumaker <anna@kernel.org>, Chuck Lever <cel@kernel.org>, 
	Olga Kornievskaia <okorniev@redhat.com>, Tom Talpey <tom@talpey.com>, netdev@vger.kernel.org, 
	Eric Dumazet <edumazet@kernel.org>, Jakub Kicinski <kuba@kernel.org>, linux-nfs@vger.kernel.org, 
	Simon Horman <horms@kernel.org>, Trond Myklebust <trondmy@kernel.org>, 
	NeilBrown <neil@brown.name>
Subject: Re: [PATCH] svcrdma: drop the extra reference on the backchannel
 transport
Message-ID: <20261104-colorful-rich-dinosaur-bfaeca@quoll>
References: <20261104022813.1484267-1-vulab@iscas.ac.cn>
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
In-Reply-To: <20261104022813.1484267-1-vulab@iscas.ac.cn>


On Wed, 04 Nov 2026 02:28:13 +0000, Wentao Liang wrote:
> xprt_setup_rdma_bc() takes two references on the new rpc_xprt: one for
> the xpt_bc_xprt link, which svc_xprt_free() drops, and a second one
> whose final put used to live in __svc_rdma_free().  That put was
> removed when svc_xprt_free() took over releasing the backchannel
> transport, but svc_xprt_free() only drops the reference belonging to
> the xpt_bc_xprt link.  The second reference is therefore never
> released: the rpc_xprt outlives the callback client and the
> connection, and the net namespace reference taken by xprt_alloc() is
> leaked with it.
> 
> Keep only the reference that svc_xprt_free() releases, the same way
> the TCP backchannel transport does, and drop the comment pointing at
> the function that no longer performs the put.
> 
> Fixes: 729580ddc53e ("svcrdma: xpt_bc_xprt is already clear in __svc_rdma_free()")
> Cc: stable@vger.kernel.org
> Assisted-by: DeepSeek-V4.1-Flash and OpenAI Codex
> Signed-off-by: Wentao Liang <vulab@iscas.ac.cn>
> ---
>  net/sunrpc/xprtrdma/svc_rdma_backchannel.c | 3 ---
>  1 file changed, 3 deletions(-)
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




