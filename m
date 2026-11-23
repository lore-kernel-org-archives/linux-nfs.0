Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795443670;
	b=FTUcqZ2RPadms3cPK6ButwGQ22xLiS/R/NrEsX+ywQWnfcbzKHBqlS/u6HkdrwUK9f4e
	 PCNwlzd4KbJwUcoqBWUJ4vnUAYHxdb28VNXhFgxwSVvUz7//aI8p+1nvb3HGX7zbAo60T
	 p2jZDgjeLXEI7Fnqjj8Ch+Z0JHZOONAChlJlHc+uM0QygSj3iTdHeKwh44PrgJUEW9A18
	 2c+4RszI7Krbck6hGRv7r8DPt3KVQ7pTLQm9c95qisvIXz0XOK7oYhsYjXnaF1E2bBzDj
	 Eh3bB+JCil/VA+Asip//WctD6GBLmX7Y17q/2tZb49MMvG0yyPRM9O+CMrxo7Z8NG2g==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795443670;
	h=Received:DKIM-Signature:Received:Received:X-ME-Sender:
	 X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:X-Mailer:
	 MIME-Version:X-ThreadId:Date:From:To:Cc:Message-Id:In-Reply-To:
	 References:Subject:Content-Type:Content-Transfer-Encoding;
	bh=FvuHniw7RrrhKeEtdqXkVtXzYPUDA+QCWRHb2+7rHRY=;
	b=TmvSrZv2RdJCJ3BQYNf14DEpW3OPQ40P+TESShnBpcYwfLzF6Hau9W4rYYId9hAJ2qbA
	 h/rR9jj5zFYrpm0ZZxY9uC3tMq7PdXs5Pi03cVGZ8jQe9tdzprei5z2SQ6zFuLAm2ua/V
	 2usMNzpVxfwGGKxhpeRp+ZYKfZ7CaG85xLd6/S36DVqlxCg+r2HQcCHHV7d8btx80tpcW
	 Qgkq6evjGNQDbFHZ3a6keg925fpyOLY6lxEB54tnP0w68FR3Q/xO6spEdm8Gkdfw04nqY
	 iphPayybeebZdXcsOJ8v6oBLVrsfJAXwd1bxx2DICUjn34ijpmASf9a3cx1vyMTiggw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="Fn1TG/qM";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7E321606A327
	for <linux-nfs@vger.kernel.org>; Mon, 23 Nov 2026 14:21:10 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Fn1TG/qM
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 458D61F000CF
	for <linux-nfs@vger.kernel.org>; Mon, 23 Nov 2026 14:21:09 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795443669;
	bh=FvuHniw7RrrhKeEtdqXkVtXzYPUDA+QCWRHb2+7rHRY=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=Fn1TG/qMU+JV6i0JnIL1S0UW+Hi/RF47HjDNbTZt2xh20E1s9YmgaxDkn/iMAHTfU
	 Nd0+onObX6U72Sza/FVWuUKyjTLVLy4LIluG77un4pLMSBvJO4icG5Wk8Pnr+a0hsX
	 Wfh9RROk51RafJAosqAbIXEdVRY3sYU0xgVfVAVLchCyE8AmXy22+3+D8tot1Zx3cf
	 PJwZ5ojHLW6dbtFNKJzmBA03Q48NBUidlST+CNKGj0PUy3NvY9XpPW77WY/MiP6qWO
	 EamlMyD/93dA+eChrwDBfngDca+3Ihz2mdmap6t+zVji2kg/YR/NrxZBfITS5ZpaV2
	 pTL+H4+WU8MGg==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 6EC06F40066;
	Mon, 23 Nov 2026 09:21:08 -0500 (EST)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Mon, 23 Nov 2026 09:21:08 -0500
X-ME-Sender: <xms:1EsEa7fFpfrhhQCpuEqIbEs6S0q1KfhLZ-yeou4zkS1Ve7GK9pXGzQ>
    <xme:1EsEa8Bsenr77dMOCKdz3x2WY619IKVWY2yVs4lFPNDAaA69MIdVvcNv_CQZb4Llh
    yPHPkArvqmsv1VujrCqaUMReqTSXZmuUpzYRg79sx6lpKX5PjfD1Q>
X-ME-Proxy-Cause: dmFkZTFyETTFTmX5UBR/sVb9A3kRSCbgXkPQGt2uJMOAM7VkLGuakSEK+lWA2672iko7NM
    1zyhCp1h7qmtyouVUKAKTfEKAGgJlO1Uk0V0XTjqVinFiKwysDww03EjYDk+rNHNgBBafJ
    FPZq43KqdIzP9WXhsDPoC04ySUb3DLRpPPX/2qf+K5XjdJVWVBvocjINJ3k8H+/JQnufNu
    7tpVb5OrO9dz9poq/Ig9QlN9NNHY/JBY23Q97OgF3pErAA1X3Qsd511t2zhQVWjIGLoKiW
    stdZg2cyVm7B6GRBekN191lC3diAzZUFDm4++x/GdSvYSJLnIWAidlpCO6ow7XTIadmQnl
    1sQKee9m76k5HTTjLUfcpqhyqXvREJB1Ykf2jyuSs2GZMa0fKM2ZE+qidveALieR9nYvsr
    5upqHduqn5yyvMzM6x5jE7fCAQh1H/AIpQILS3u1p3UdX2HJlfXakqblg+4rAsnherznaN
    itFldBFQFqOXXCOoWzPEFYRON2hMg5TRrvQD4WWoIRD9zYKxgHNALa/EpJj44aflTTBaBy
    89GmPPVi4ToNmYh48aTN6H6EO/10al6szJ7k4B0LALlH5po0TLLe5B0tgl6RSjc15FIId7
    1/CY+H5KJAehtoGNl9XxavlLG6B6FcrdiIV+cmNKxyeGhfv9p2Q908wuYVnw
X-ME-Proxy: <xmx:1EsEa3DYBc8MjP0jEJ7g6S0ckin-TQIargOgsi-Qg4dvFJ6rqSz4oA>
    <xmx:1EsEa9pIwxdTXuOjPRvR2vQBPznQQpAh483yd06X-2uYlBUl1BUhnQ>
    <xmx:1EsEa6jqZDRuWAwb3sfx-EwMTWNBPN8KpdFTgdBFOQOUz2SJid883Q>
    <xmx:1EsEayCa2V-OWGE6npvDmA03spOgNoZOzQ-tj1Hg_c97azU8Q2_9wQ>
    <xmx:1EsEa3FtiZNcr_UyaPtjNMKvPmqAYqU6ZybL7o5Z5oQqFQACOXLiYomn>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 4DF18780075; Mon, 23 Nov 2026 09:21:08 -0500 (EST)
X-Mailer: MessagingEngine.com Webmail Interface
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
X-ThreadId: AAoF7yJtL20o
Date: Mon, 23 Nov 2026 09:20:48 -0500
From: "Chuck Lever" <cel@kernel.org>
To: "Fredrik Tolf" <fredrik@dolda2000.com>, linux-nfs@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Message-Id: <9f8f700f-a10f-4aff-a385-4300c8164f1b@app.fastmail.com>
In-Reply-To: <20261123005648.29562-1-fredrik@dolda2000.com>
References: <20261123005648.29562-1-fredrik@dolda2000.com>
Subject: Re: [PATCH] SUNRPC: Make svcauth_gss sequence-number window size tunable
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Sun, Nov 22, 2026, at 7:56 PM, Fredrik Tolf wrote:
> The concrete problem that I seek to resolve with this is an issue where MIC
> verification, due to being schedulable, may sometimes delay the checking of
> sequence number so long that the sequence window in the meantime has drifted
> beyond the sequence number being verified. This causes the NFS server to
> disconnect the client in question despite it having done nothing wrong, making
> the client do 15-second timeouts before reconnecting and retrying, killing
> performance.
>
> Now, I would of course like to fix this *properly*, since the client, indeed, is
> doing nothing wrong, but as far as I can tell, I am not sure there is a way to
> fix this properly in a TCP context without serializing the entire authentication
> process, which in turn seems that it would require a full rewrite of the sunrpc
> servicing threading model, since it seems made to be intrinsically asynchronous.
> This makes sense given its past UDP primacy, where also the occasional dropping
> of a packet due to transient authentication failures like these would not be an
> issue since the request would just be treated as lost and retransmitted by the
> client, but in a TCP context, clearly, retransmission is left to the network
> layer and the client just terminates the whole connection on an authentication
> failure instead.
>
> Due to this difficulty in developing a proper fix, probably better done by
> someone actually familiar with the NFS/sunrpc code, I'm just making the window
> size tunable, so that I tune myself out of the problem. I considered a number of
> other heuristics along the way, but since they weren't really technically more
> correct, I figured this was the simplest and therefore best.
>
> The default window size was also inreased from 128 to 1024, due to 128 being
> clearly too small.
>
> This also relates to <https://bugzilla.linux-nfs.org/show_bug.cgi?id=416>
>
> Signed-off-by: Fredrik Tolf <fredrik@dolda2000.com>

As you noted in the bugzilla, this is a long-standing problem that is
difficult to address. Your sequence number misordering diagnosis is
correct.

However, just to be clear about the standing of the proposed fix: NACK

o  Our usual upstream policy is to avoid adding tunables where the system
   should be automatic. Tunables increase the size of the testing matrix,
   add documentation requirements, and are difficult to remove when they
   become outdated.

o  Our usual upstream policy is to root-cause and fix the underlying
   problem.

o  Increasing the GSS sequence number window size does not actually make
   this problem go away. It only makes it less frequent.

I don't think this is a SunRPC scheduling problem. Rather it's that the
crypto handling sometimes takes a while (and I don't know why that is)
and that delays one RPC just enough to trigger the sequence number
window check.


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
