Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5A6653BBFB6
	for <linux-nfs@vger.kernel.org>; Fri, 28 Aug 2026 18:59:26 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787943568; cv=none; b=MlRjfMOjv4aXtyonloCA9yxufyEDNHoIJeXU04hIm6kGopYq2KsuLC/HfbBU/bt4ZOwb5fX6RFidiDWxJ7HbwEhfXGJFcoQ6USuK71VffNXxHf4WuOw/IQ+mfVzBeXLKsjV0H7JYMtFow3QrvMeqY4o65C76maGjBbbqHWiMpxw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787943568; c=relaxed/simple;
	bh=OjB4vUrsxVvlRaerFFMGtt3SS7AJQxPLeIOnH6V9yzo=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=BqZTQwdcZf6tcMLQL7kBfCMcIKKv27HjHpX8dpFBMccDzbpPq9MFHGs8jYUShrwpxgUcMRWxqR8QUMkmKULh3ZNuwCSPNkAzp+flvCLCE1jpK3N/MfEdwM2nYa4/Y/MLwWDWDqi+JfnwxQ4P+8wcu7TmIwbG5Kdd7IEgn1XFd1s=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=WM+GorZI; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="WM+GorZI"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 929811F000E9;
	Fri, 28 Aug 2026 18:59:25 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787943566;
	bh=R5g8u4snP1B+1pK4tZp0Vs1T/psQ5CW5xiVSdPjR+Mk=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=WM+GorZIUEjNoOQwK6CrLua3hcl4rYyodF6SopFbkLZJTsEgsUGEJkXLENuAlfqN6
	 ZfCRm37cMUMVFfyRZ1KTHevfl8G19TehkSS6VqpVwdIlraD0Sve9UODei/k5yhnfbh
	 0vPnjVE/Z3naLGugfigP+gInT92xOa7WD4P6XqJszrdBxR7NyYoDEGFdq0Qimaq69s
	 ddEIOhHlS0inTlCcuN1dfAzb52IsWL2xN49UWfTMHlR6xm+k0z+XV1AgpztAVgvA9p
	 bSdW/TFuoS4tl2wK4byh9waAGS1miin5cUWyZ3FJFkmeTRcT9FuMVH5wsL7oCBlQS8
	 yJnyB8VExVahg==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id AAC67F4006A;
	Fri, 28 Aug 2026 14:59:24 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Fri, 28 Aug 2026 14:59:24 -0400
X-ME-Sender: <xms:jNqRapnMPn9J68uk6fGYKturkJxO8r7BdquXPE1br1THNqAn4KgmvA>
    <xme:jNqRavpmKcDc29yCsCp9u5R3ISCFkVDbQouhOYtObaz5G55RNkdrbR4Bw55C2Exmx
    s7zcoePZ47i7QltoUM6ndwzDK-1mlV82HRZyt4acjDolsUTcwXTlRw>
X-ME-Proxy-Cause: dmFkZTFhQ1hBwdGal5RyVrHDpOGkKkC4lSaw2PHoaH9lTtDiPrwxad9Amn8ydKNmVnChJ3
    GLHJcMIfkQVLqwnMTqbJuXNk4bXd3XqAzP3g2SsHhufx4CBEXG9vWqmZjd2HmgaFAuJOhk
    SeD4AFa9jlm0gQS5NJwHOMmijn68lkbuBlW3U5tDP1dIDjiZF+tvdAgcTTCa92zSU3/DW2
    PHjz1etBKTxnQXUpm45vPFzOch6LaEM4R8QvIrrFOcYCtzAIwStifR6gOFgY8fm3wrs6OR
    vlb407LGUwnpUGUFqTGW7LydxN5Hl3KPjez7pTC6vxkEyix5cUpJ0LGcMzeLJhOn2z0gr3
    t4PUSQrTBkgIKfrtMyQNVDobE/CVIq4q290AOnwaCoAGXR2OC9IQmQq630dKDLmGHjTEDE
    WxSBQDW2h4a3CFakR8I6MF5A+VsF+7VKHjEhJLJa4TC1c7Wq47yrVtebPYEDCzfv0oRbJw
    WnYV8/Fhu7t1+ysLvbCicwpN7oIvxWoCn+Ns8eEmJlq2xFUog65IXAXf/oN5+u3jV86KuT
    5fWXejMJCTn9EMCWqqco98CjzvjOUnvQ2m3/n2CKgfUPqGKRGTQZ7Ne/NiMvc/t1H9w/pE
    HhD22bv/a6Mvdh+XTQpS8h6mPUlf3Hdh/0IYC+Xxr1ie+oPSDS6qw6D4/+YQ
X-ME-Proxy: <xmx:jNqRav-_4IdXd1Y33tPIKfcoXSiEhs4HeGUjVJmP0B0wbZlUu6_RVA>
    <xmx:jNqRasZH9HZ75KQVF3srG6IicMwL5YQC1Lz8bpTD2MUiNv9r6FJz6g>
    <xmx:jNqRarNHu0QFD06jMkBa4UG4WMYIHuJVlry7hjrI3jr41nf8Uojcvw>
    <xmx:jNqRagC5eStLY5RIiu8ysR6UWBEp9iWo7P4FX1xmGTR8YvJlrUYJvQ>
    <xmx:jNqRaqIg5N5hINzNpUv9ZuSgTApYVgYnjVSzHUNvpY4zg_Oqv0xt-3mv>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 8EBB97811F0; Fri, 28 Aug 2026 14:59:24 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: ASVo6Y-fM8_J
Date: Fri, 28 Aug 2026 14:59:07 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Jeff Layton" <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>
Cc: "Rick Macklem" <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org
Message-Id: <10c97c34-1061-4aa2-a5b5-234e4d01e894@app.fastmail.com>
In-Reply-To: <85acfa01848e5d7829ca18ad8864410fbb5e12b7.camel@kernel.org>
References: <20260828-duplicate-reply-cache-v2-0-25069e660a7b@kernel.org>
 <20260828-duplicate-reply-cache-v2-5-25069e660a7b@kernel.org>
 <85acfa01848e5d7829ca18ad8864410fbb5e12b7.camel@kernel.org>
Subject: Re: [PATCH v2 5/7] NFSD: Evict completed DRC entries via implied ACK
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


On Fri, Aug 28, 2026, at 2:38 PM, Jeff Layton wrote:
> On Fri, 2026-08-28 at 12:17 -0400, Chuck Lever wrote:
>> A completed DRC entry stays in its bucket until RC_EXPIRE elapses or
>> the cache exceeds max_drc_entries. Entries whose replies the client
>> already holds lengthen the bucket and slow every lookup that hashes
>> there.
>> 
>> RFC 1813 Section 4.5 observes that on a connection-oriented transport
>> a duplicate request arises from reconnection, not from within a live
>> connection. A fresh request on a live TCP or RDMA connection therefore
>> means the client is not retransmitting an earlier one. UDP clients
>> retransmit on timeout over a shared svc_xprt, so eviction is
>> restricted to transports marked XPT_ORDERED. Even there the evidence
>> is not conclusive, since a client with several requests outstanding
>> sends the next before the previous reply arrives. The cache is
>> advisory: a premature eviction costs a miss and re-execution, the same
>> outcome memory pressure and RC_EXPIRE already produce.
>
> No, it's not. The DRC is necessary for proper function, and if we drop
> non-idempotent requests prematurely, then that could cause spurious
> errors.
>
> Or am I misunderstanding what you mean by "The cache" here?

Not talking about the NFSv4.1 session cache. The old DRC has
always been best-effort. It cannot be relied upon for proper
function, since the DRC is non-deterministic.

The point I'm making here is that items already get evicted
due to memory pressure or because the DRC size is capped.

In particular, if you are actively removing items that are
very unlikely to be hit, that *reduces* the likelihood that
other, perhaps more valuable, items will be evicted due to
memory pressure.


-- 
Chuck Lever
