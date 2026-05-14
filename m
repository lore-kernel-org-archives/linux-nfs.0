Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DC8C1239562
	for <linux-nfs@vger.kernel.org>; Thu, 14 May 2026 17:54:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1778781242; cv=none; b=lXCKUNbsY09KnFIjAj82AWuxTIJCm+lL7n5KEcczq3oeqdtTGrBSbS8AcZA94Jt6XnMj5q6u/K3ymFCe0k8XVsdA3SWXXBloP+8cptpJKZOdeh3RdimleKsH4jrc5FW/FuEX2dhnRe2KFEf6k1Nv4koo5v8GzIAWxa6pOEBBpdY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1778781242; c=relaxed/simple;
	bh=SUZYypCTAgKgxxSA5auSnuJDryYmw79lodzRmAT5gdk=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=jIvNKHPDP36nYEFcZSXbJASMZ6JwMVP6bG9VF6A8ys9O+rVJFWkvgUNAdyYJM5ult9AX6Imc8437FOdx6LpaqGhvKxV9MIpO+GN0yJPvPpKUoGOs+m0dkz5T+LUUfXniNU4udLRcVrR9oeErBjEdFmYq+gBO5GB0ImklsZ2u8Ug=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Pj+GJXBa; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Pj+GJXBa"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 4FB87C2BCB3;
	Thu, 14 May 2026 17:54:02 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1778781242;
	bh=SUZYypCTAgKgxxSA5auSnuJDryYmw79lodzRmAT5gdk=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject:From;
	b=Pj+GJXBa/q1k83yIBEoVUaYanLVGkJlGtuoSBBB9r2pLKcXMQVfFNeotwvthkU2io
	 8xKHpxDJsgYzLC9NlKdyC0ZTzgsXn8T9t2NGKWCTi+nv6e3gddRwcz+I+8HUVAvjO5
	 N3+ypUokfhQ174XtDPxx9qNjD/WOAIf4hS/3B5MjtnYaUwHPAMsBQQydfxfLqErxGx
	 g2jBXepPQ99z6ob4wdjSPiPIW+wt1YSocwVKkaz6DKKeG7i3HD57LsdnTc6k++S3sH
	 kMhrzuBgrbg3kQxhq6cv2sBLfw1mX55qoeBbONekO69tOvUpukvRCZTHCuWeyv5rnt
	 uYG+R9dHaJP1Q==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 66F9EF40083;
	Thu, 14 May 2026 13:54:01 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Thu, 14 May 2026 13:54:01 -0400
X-ME-Sender: <xms:OQwGaoXYD0ELPc-OCd0ti6dMOlQdnVZZmJYyY21ZXFpikga9gedl7g>
    <xme:OQwGanaCcbzYOjRdFawDZvcwhyhIk3aR-pYJqIhb15IUAWZ0P0XYLOOkuEJZSEA0i
    wBRWTpXvcrtmSshZYuCuZquiCKh3EPSa7PFeP2kPTlzWmTUvDLZZaVw>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeefhedrtddtgdduvdekudejucetufdoteggodetrf
    dotffvucfrrhhofhhilhgvmecuhfgrshhtofgrihhlpdfurfetoffkrfgpnffqhgenuceu
    rghilhhouhhtmecufedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmnecujf
    gurhepofggfffhvfevkfgjfhfutgfgsehtqhertdertdejnecuhfhrohhmpedfvehhuhgt
    khcunfgvvhgvrhdfuceotggvlheskhgvrhhnvghlrdhorhhgqeenucggtffrrghtthgvrh
    hnpefghfeguedtieeiveeugfevtdejfedukeevgfeggfeugfetgfeltdetueelleelteen
    ucevlhhushhtvghrufhiiigvpedtnecurfgrrhgrmhepmhgrihhlfhhrohhmpegthhhutg
    hklhgvvhgvrhdomhgvshhmthhprghuthhhphgvrhhsohhnrghlihhthidqudeifeegleel
    leehledqfedvleekgeegvdefqdgtvghlpeepkhgvrhhnvghlrdhorhhgsehfrghsthhmrg
    hilhdrtghomhdpnhgspghrtghpthhtohepledpmhhouggvpehsmhhtphhouhhtpdhrtghp
    thhtohepnhgvihhlsegsrhhofihnrdhnrghmvgdprhgtphhtthhopegrnhhnrgeskhgvrh
    hnvghlrdhorhhgpdhrtghpthhtohepjhhlrgihthhonheskhgvrhhnvghlrdhorhhgpdhr
    tghpthhtohepthhrohhnughmhieskhgvrhhnvghlrdhorhhgpdhrtghpthhtohepuggrih
    drnhhgohesohhrrggtlhgvrdgtohhmpdhrtghpthhtoheptghhuhgtkhdrlhgvvhgvrhes
    ohhrrggtlhgvrdgtohhmpdhrtghpthhtohepohhkohhrnhhivghvsehrvgguhhgrthdrtg
    homhdprhgtphhtthhopehtohhmsehtrghlphgvhidrtghomhdprhgtphhtthhopehlihhn
    uhigqdhnfhhssehvghgvrhdrkhgvrhhnvghlrdhorhhg
X-ME-Proxy: <xmx:OQwGauz4yZVmsjcvAztCRy3JvTU59m3jq8Jh4JVI1lO1g7ug44CKpg>
    <xmx:OQwGavO5v2uqlSCWttnYAvjNd7qq7D_LTtiZDinEI_ZzHH9Xb01Mqw>
    <xmx:OQwGakmuNskznXEYhsv5C4eGhJmWsbxRUIEs4XN9DZ_g9BV2z_0J-A>
    <xmx:OQwGakSBy9fgQibXBLsJg3xjVbTPfEv2l-96eDC7b7FdBaKMUNK14g>
    <xmx:OQwGajUegKOV4o7mFalZEVV-khOJDd8KmbyWWCFyYJK7YPKL4uOroi9Z>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 461C8780070; Thu, 14 May 2026 13:54:01 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: A-ccox8Ms4A7
Date: Thu, 14 May 2026 13:53:40 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Jeff Layton" <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, "Trond Myklebust" <trondmy@kernel.org>,
 "Anna Schumaker" <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org, "Chuck Lever" <chuck.lever@oracle.com>
Message-Id: <86782884-747e-4796-9961-3407e9fd759f@app.fastmail.com>
In-Reply-To: <5229a9746d723a3f830120c0b966510f75badfc2.camel@kernel.org>
References: <20260512-nlm4-xdrgen-v1-0-19d99b2634b4@oracle.com>
 <5229a9746d723a3f830120c0b966510f75badfc2.camel@kernel.org>
Subject: Re: [PATCH 00/38] lockd: Convert NLMv3 server-side procedures to xdrgen
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable


On Thu, May 14, 2026, at 12:52 PM, Jeff Layton wrote:

> I got a sketchy review from Gemini that I had Claude validate that
> looks valid. You may want to add the memset() it recommends:
>
> --------------8<---------------
>
>   Analysis complete. The previous review (against b201ce7af2a2
> FREE_ALL) identified the right underlying bug but attributed it to the
> wrong commit. Here's the corrected analysis:
>
>   Correct commit: 3de744ee4e45 =E2=80=94 "lockd: Use xdrgen XDR functi=
ons for
> the NLMv4 TEST procedure"
>
>   The regression: nlm4svc_lookup_file() (introduced in this commit)
> copies only fh.len bytes of the file handle without zeroing the
> remainder. Combined with .pc_argzero =3D 0 removing the
>   defensive memset of the argument buffer, bytes beyond fh.len in lock-
>>fh.data contain stale data from previous RPC calls. file_hash() in
> fs/lockd/svcsubs.c reads a fixed 32 bytes (NFS2_FHSIZE)
>    regardless of actual handle length, so for handles shorter than 32
> bytes the hash is non-deterministic =E2=80=94 the same file handle can=
 hash to
> different buckets on different calls, causing lock
>   state lookup failures.

This appears to be a regression introduced by the (previous) NLMv4
series, and does not affect the current NLMv3 xdrgen conversion.

I can post a fix for this later today. Note that memset() was
removed as part of the xdrgen conversion because it zeroes much
more memory than actually needs to be initialized.


--=20
Chuck Lever
