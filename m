Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793208136;
	b=lYWlytEcozdADwChXmVsKTuMgjCV17OEtRyfDsbYFqTPgvKSPIyAVhhiCs9zkpF3Jx/n
	 eIWcA3NI+fUBNVKsoshzoy2Bv5Ei20MPdHxNLrOQPfwUXlhtT2n8CSDQ+5BgY42NIMu7r
	 jSACv1rwPeTly2kAwrLMgVEqcRfMO2jeZOwcYdMkhquKqCXyuCUIzRCqorugVmig/JwPO
	 rJcpMzCdwq1GpYWYFKj11+Utcf6FjuKgvBwbOLnBff4D3ZBVh34TvlNvrjN4AXJHVvuAX
	 ++NAstu+h8rwAY4UUX3x4PKErSvD2d0pZ3j6ujbl5x9ucJeEXB11V9VdEdo9GiS4ZtQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793208136;
	h=Received:DKIM-Signature:Received:Received:X-ME-Sender:
	 X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:X-Mailer:
	 MIME-Version:X-ThreadId:Date:From:To:Cc:Message-Id:In-Reply-To:
	 References:Subject:Content-Type:Content-Transfer-Encoding;
	bh=WR/O8AvyY03PaP5y1SBXVJSRDclsFuXsSj/CXbqYE30=;
	b=CGLpzuUAwuYBqcrGOwBTQbRprUmNXwTT1hggbjvCGlNg1dZXLGl+0jca5iFOCI+8xf9y
	 sIt8z983RqLSSGh0JQEVr/ehb2Ne+mDtpKRj9I7ruLYJtok+G9nrZczNttluahySMWSxX
	 bpneEG+wgiSNhfTDY9X32hdtSOXtIEtB+1D3Xh2qdvuFItWDq3XLGOain5BlqQ94MW4Ys
	 m+z7hbYZvegP9TcrDcwAgIkJuLs+HIveFRCLjLUdj/HT6MnpAjEbHAfN2htoAEdudmXYG
	 EGevP8NjenDpVDrkx5+71M9mpFwz0N63G8Awi7ctRUERaukwTdPuI6T5wVbcasw1YLQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=aQfPgq+u;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 50A4D606A327;
	Wed, 28 Oct 2026 17:22:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=aQfPgq+u
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C298C1F01825;
	Wed, 28 Oct 2026 17:22:15 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793208136;
	bh=WR/O8AvyY03PaP5y1SBXVJSRDclsFuXsSj/CXbqYE30=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=aQfPgq+undaDVbOnax5u5lnfMc47l+sfT9MBAzG2XVAciyD1pJR5mvfX0f2w2cUpm
	 tX1QzFZAEjL9C1bUv1G37f/E73J1j00YuW8MkZKCr4wXBM6iXJ19OLneRM182S0hsk
	 MVJzPWNsuzWdTbWiGGhWX6AaDkzMLiwKpAFgmhzj7bF2jzwktB3D3+kmRg7Fqrf4Z9
	 wHZZBBJxGj3EEgBi9s0a2dqJdnrT2gr7MvNNszM5UnkRG9iiOH1dqU96iE8aHClHtB
	 M0Z9LdGpXIt3NUciMgO7mXtP46I5DBk/mfIVMnWBrvBljnrWUB1BU1Ly5hVLchWC0w
	 JAyiPw0qMZupA==
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailfauth.phl.internal (Postfix) with ESMTP id 06847F4006A;
	Wed, 28 Oct 2026 13:22:15 -0400 (EDT)
Received: from phl-imap-04 ([10.202.2.82])
  by phl-compute-02.internal (MEProxy); Wed, 28 Oct 2026 13:22:15 -0400
X-ME-Sender: <xms:Ri_iavgZ4gwmONBOj35X-VR-Y9-ckLvDrPUj27tMkVn14ht-camdRg>
    <xme:Ri_iam2yyHtkRttgUuHeBbBN6X-g4Gjq7pavNc8D84973ivjsy7F8Hx_iW-ITE6cV
    zlWRyzKfajU5cvswIJOS7TRaTOpRBpForaDS-S9klutEbcKVVRJiNFI>
X-ME-Proxy-Cause: dmFkZTGMFM9DlPooCt9VpMpix33tYU64y5OxOODDn78L4qDif9NOTckZVM+Yf7zd+2Cd8l
    KLF3nhxN1N8BpS7VlqbcCSkv9EREgHfRKBJu1bAt4kXlqeu8cFUa3aln/hqzbrmmIkENqG
    o76KSEMkMRfBaPi8j0Na5jTbKMv/6UDTev1EGF/YhoxGOaVGQenYzB4+t5vuMh6WFC4iD/
    GLMczG20MNRHMRqU/cu4Rx/vAT3KG9FhvcfZT+8ou6hkC5Xm6j8Mef45bqLIlMJFX6vW6i
    TvTrwQvo3hi4au/H7+UscF9kVGUHSOcyve4+A0ekr92I5asxMQK/pLg3kpZEoZWqP/4Xib
    dKO4oqcavmhhpemqNkp7j1bvW8sBNmZtRPpgfsQT7qyK2gYRpnjHs/cg7Wv/2lXNFJJTSO
    o5Q2cKUgtGUvLJAUi6OJ6ql3XXClFJCLmpy1GMckDtR4d8e6yqiOFzpYLqO2G55XarPyWk
    CaB71XwKFz96lTZTcreqwsMG5uxAx9/eAoxSOtYqEsfkabgzN9pSj5+BFYJp4Aq4nkDJcB
    sEIijmlt1zJbiLt6UkjP2CQZt26/maWZwmnrPx53G+LNCO2gCmSxGRuL7IswHwtN5fm1dP
    VQkAgH2WyRj0rWJLC4QGiEHEK9I8AbommayfnxPr6Bg+PNrbR0wEYERhDCBw
X-ME-Proxy: <xmx:Ri_iatHVCe2uAc8LcrINn0dh4VId-Dntllm9O_6OpIWkQOhSB360Mg>
    <xmx:Ri_iauOi2hRv_tCLN788gBMVdpDVCgvQu1zVHYm29F1BuqfpBktelw>
    <xmx:Ri_iasJnfiLtcfyzmYeQSZ5Aui1221hc0N2aF2zk1f87BW186-DCCw>
    <xmx:Ri_ian_kE-H7fSVd4Ti3S_O7g6hwoxaebc632wOc8zcpBoWrRGmsew>
    <xmx:Ri_iaoGdJ0SRPiZcVIoS3id9vldRnN2zSpqO6W6jplUpRnbiBFZK0lhE>
Feedback-ID: i20964851:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id DC870B6006E; Wed, 28 Oct 2026 13:22:14 -0400 (EDT)
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
X-ThreadId: AfRLXb2QfRls
Date: Wed, 28 Oct 2026 10:21:53 -0700
From: "Anna Schumaker" <anna@kernel.org>
To: NeilBrown <neil@brown.name>, "Trond Myklebust" <trondmy@kernel.org>,
 "Alexander Viro" <viro@zeniv.linux.org.uk>,
 "Christian Brauner" <brauner@kernel.org>,
 "Jonathan Flynn" <jonathan.flynn@hammerspace.com>
Cc: "Jeff Layton" <jlayton@kernel.org>, "Jan Kara" <jack@suse.cz>,
 linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
 linux-kernel@vger.kernel.org
Message-Id: <737705ca-a555-45fe-b225-d7232ebba3ec@app.fastmail.com>
In-Reply-To: <20261028041023.3738553-1-neilb@ownmail.net>
References: <20261028041023.3738553-1-neilb@ownmail.net>
Subject: Re: [PATCH v4 0/9] nfs: prepare for locking changes.
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Hi Neil,

On Tue, Oct 27, 2026, at 9:06 PM, NeilBrown wrote:
> Now that the requirement for this are upstream this could go via the NFS
> tree or the VFS tree.

Sounds good! I think we should plan to take this through the NFS tree.

Thanks,
Anna

>
> Thanks,
> NeilBrown
>
>
> This v4 fixes the problems with patch 1 which Jonathan Flynn helped me
> to understand.  And *actually* adds Anna's Acked-by.
>
> Before this v3 fixed three bugs found by Sashiko - all
> error-path related.
>
> 1/ patch 5 - make sure d_drop() gets called in all error cases
> 2/ patch 8 - dput() sdentry on all error paths
> 3/ patch 9 - check error return from d_duplicate() correctly.
>
> Original intro:
> I am working on changes to directory locking.  The medium term goal is
> to lift d_alloc_parallel() locking above i_rwsem, so d_alloc_paralle()
> can be run unlocked, and consequently cannot be called when ->i_rwsem is
> held.
>
> The requires:
>  1/ the d_alloc_parallel() not be called while i_rwsem is held.  NFS does
>     this in a few places. New interfaces d_alloc_trylock() and d_duplicate()
>     are now available and can be used instead.
>
>  2/ a dentry must not be d_drop()ed while an operation is ongoing, as an
>     unlocked d_alloc_parallel() would then be able to create a new
>     dentry with the same name.  In particular d_rehash() must be phased
>     out as it won't be safe.  Various techiniques are used to avoid the
>     need for d_drop(), particularly that d_splice_alias() is now able to
>     splice a hashed alias.
>
> Further, the first two patches here fixes bugs that I found while
> developing and reviewing these changes.
>
>
>  [PATCH v4 1/9] nfs: fix open-blocking with d_fsdata
>  [PATCH v4 2/9] nfs: fix nfs_call_unlink()
>  [PATCH v4 3/9] nfs: remove d_drop()/d_alloc_parallel() from
>  [PATCH v4 4/9] nfs: use d_splice_alias() in nfs_link()
>  [PATCH v4 5/9] nfs: don't d_drop() before d_splice_alias()
>  [PATCH v4 6/9] nfs: don't d_drop() before d_splice_alias() in
>  [PATCH v4 7/9] nfs: Use d_alloc_trylock() in nfs_prime_dcache()
>  [PATCH v4 8/9] nfs: use d_alloc_trylock() in silly-rename
>  [PATCH v4 9/9] nfs: use d_duplicate()
