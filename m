Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C02E943CEE3
	for <linux-nfs@vger.kernel.org>; Wed,  1 Apr 2026 13:39:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1775050791; cv=none; b=Dsmuca/P5BPRKzzywGZNBdAu5b4cauDQ3ZJaYujltH6EJxMycQW8H6sDXJguWMbjVD+R1Isyz4+KdBhD8Zn1KpYZAth9O7/LqS4HhY+y89gKnw+FPSv1wTfyVbxsx+innZ0WjFob7aiwzXbvM1j2tJUpBHVrw4BGUiRRMF9g0+k=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1775050791; c=relaxed/simple;
	bh=CJDnYngsSZ5n1tU6NcHxkHmdD2lwVssaMMVh5DWEL/Q=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=I0MwgUwejOlbctaBT0jDHJcC5K12lybAmG1H+ocY3Y0s1q+Fhc3up9QIF1+7cH7v4ZQ7WSXG7PJYZPS6RNOv6lrr5XQWRHYSg7MMa2Hp5z5wggxe4t5lrzXnO6ZIFZMJG0O8nliDZy3WDD3IK7YXWNptueAS314SHLAwCUKDUVY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=ucJL/NR8; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="ucJL/NR8"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 1972DC4CEF7;
	Wed,  1 Apr 2026 13:39:51 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1775050791;
	bh=CJDnYngsSZ5n1tU6NcHxkHmdD2lwVssaMMVh5DWEL/Q=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject:From;
	b=ucJL/NR8LBHZVJG5lc+0BrAOF6csWetbWJNz1FuglYeQShFD4DbMar1DWU0VSSyuE
	 j5zAVH50Bl2X6WTupEpIltdigzi6zpS82ZJ0Le38rCA3DtPbLGMHWbFo3LYkNcwVx4
	 r42SfLLc4Zzp4pMPxxW0pXmOtcnxMeXDaIONLB9IbkwmJ63tdc9A9YSyc+E/qCnF2D
	 NrznmTtkb5R7kRChVQt1kk86aSmBRY9u0RXawug25Z/eBX3Uu39GY8FodGilJOBQbZ
	 gRX3+ZxRsYD1ER3bCgsT7Qp+lQPSuYLLVTWgDz75tCCkQwlUWNvkmP3uz0sYs3fkQA
	 p8/37hAcwOqig==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 2E536F40068;
	Wed,  1 Apr 2026 09:39:50 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Wed, 01 Apr 2026 09:39:50 -0400
X-ME-Sender: <xms:JiDNaWO7YGsZYgVmiGUsnwCLNaCW1r2FXSC-B-Tmn9IuKdbF_79a-w>
    <xme:JiDNafyOXRVaY6aQO8GlQ5m81SncsKIm3yOCQ8PeGtOluwtQiQ0wOcb1L0W_pWy3M
    2-B_xFxb-3NJW5cbOcimi3lhvTylOOgHO5RTnfflyMMV0PQWAcH2bax>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeefhedrtddtgdefvdeiucetufdoteggodetrfdotf
    fvucfrrhhofhhilhgvmecuhfgrshhtofgrihhlpdfurfetoffkrfgpnffqhgenuceurghi
    lhhouhhtmecufedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmnecujfgurh
    epofggfffhvfevkfgjfhfutgfgsehtjeertdertddtnecuhfhrohhmpedfvehhuhgtkhcu
    nfgvvhgvrhdfuceotggvlheskhgvrhhnvghlrdhorhhgqeenucggtffrrghtthgvrhhnpe
    fhffekffeftdfgheeiveekudeuhfdvjedvfedvueduvdegleekgeetgfduhfefleenucev
    lhhushhtvghrufhiiigvpedtnecurfgrrhgrmhepmhgrihhlfhhrohhmpegthhhutghklh
    gvvhgvrhdomhgvshhmthhprghuthhhphgvrhhsohhnrghlihhthidqudeifeegleelleeh
    ledqfedvleekgeegvdefqdgtvghlpeepkhgvrhhnvghlrdhorhhgsehfrghsthhmrghilh
    drtghomhdpnhgspghrtghpthhtohepuddtpdhmohguvgepshhmthhpohhuthdprhgtphht
    thhopehnvghilhessghrohifnhdrnhgrmhgvpdhrtghpthhtoheprghmihhrjeefihhlse
    hgmhgrihhlrdgtohhmpdhrtghpthhtohepjhhlrgihthhonheskhgvrhhnvghlrdhorhhg
    pdhrtghpthhtohephhgthheslhhsthdruggvpdhrtghpthhtohepuggrihdrnhhgohesoh
    hrrggtlhgvrdgtohhmpdhrtghpthhtoheptghhuhgtkhdrlhgvvhgvrhesohhrrggtlhgv
    rdgtohhmpdhrtghpthhtohepohhkohhrnhhivghvsehrvgguhhgrthdrtghomhdprhgtph
    htthhopehtohhmsehtrghlphgvhidrtghomhdprhgtphhtthhopehlihhnuhigqdhfshgu
    vghvvghlsehvghgvrhdrkhgvrhhnvghlrdhorhhg
X-ME-Proxy: <xmx:JiDNafaDBA7_kepu7M5ypjgPHN-m4EqdnlqEzsMIflNcPWWk4THK-Q>
    <xmx:JiDNaUarRdo8siXR_-RyMfOSeWrEJA3jrivrd6mPJD7NQEEsV9A_CQ>
    <xmx:JiDNacw507NZKhPDL-u9heN49OwqgqTROJt55Spy_26GcvxPXVwTpA>
    <xmx:JiDNaYf0XkkYLBS1EVsCAnvUk8VHLVhpg4WLA6dVvuuDqv-UhwtkdA>
    <xmx:JiDNaZ4pDpV5zTlnN6uRW7iQKHjkhQAMsaAoJdPxt9E66dz_FKevNBBH>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 0D436780075; Wed,  1 Apr 2026 09:39:50 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AoFadv7LPD5F
Date: Wed, 01 Apr 2026 09:39:29 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Christoph Hellwig" <hch@lst.de>
Cc: NeilBrown <neil@brown.name>, "Olga Kornievskaia" <okorniev@redhat.com>,
 "Dai Ngo" <Dai.Ngo@oracle.com>, "Tom Talpey" <tom@talpey.com>,
 linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
 "Chuck Lever" <chuck.lever@oracle.com>, "Jeff Layton" <jlayton@kernel.org>,
 "Amir Goldstein" <amir73il@gmail.com>
Message-Id: <e17dc8e1-1150-450b-b4d4-4ed5470d7511@app.fastmail.com>
In-Reply-To: <20260401061904.GB24293@lst.de>
References: <20260331153406.4049290-1-hch@lst.de>
 <df21ae49-c763-43d6-bdb2-c492f349a6cb@app.fastmail.com>
 <20260401061904.GB24293@lst.de>
Subject: Re: cleanup block-style layouts exports
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


On Wed, Apr 1, 2026, at 2:19 AM, Christoph Hellwig wrote:
> On Tue, Mar 31, 2026 at 01:33:11PM -0400, Chuck Lever wrote:
>> 
>> How do you see this getting merged? Do you want all of these
>> patches to go through the NFS tree? Or do you want this to
>> go through VFS?
>
> I don't really care.  But I traditionally see exportfs as a nfsd domain,
> even despite the added other uses of it.

Right, and I'm happy to take this series because it appears directly
related to pNFS. But recent exportfs changes have gone through one
of Christian's trees. Plus this is a cross-subsystem change.

(I'm not pushing back, I'd just like an above-board decision)

-- 
Chuck Lever
