Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C8BB62116F4
	for <linux-nfs@vger.kernel.org>; Sun, 22 Feb 2026 20:31:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1771792304; cv=none; b=QTliEpwN3q+GaX2OSLCKps7frUmHDeIKW1d5vZoP8l1fjezjOfshz6hWtjLH3HmClZipmWKMov7D1SKY0T7xOcajfvECpFEdW67Ot4zDLSvPfr0tdEyEL4EzEebKuIsJUiBwEE9ElHwU7P9AaRkZKYcwtzmmGb4tyQVnk0VPdrs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1771792304; c=relaxed/simple;
	bh=WY/hRS0lvOxQMtY9XRDy1THFvIrVgZ4RmOMJNzWFAbk=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=RNwTiHzY8rbbHvD4VDaZy1BoeZjwiRobMqxPwtDYlw1vG9OIrFM+ltGP8UTeJ23AoFgT/RGgVxqN7ou9AeU/SFArbv4+o573slAZv+Df7pXgFA1Lj3JcmQVSgx1+VAFP+v1PA9w2peRzllPABtjDw7QHmrp34cT8m3y9eDH2SUk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=ai5RJH0p; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="ai5RJH0p"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6B9E2C19423
	for <linux-nfs@vger.kernel.org>; Sun, 22 Feb 2026 20:31:44 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1771792304;
	bh=WY/hRS0lvOxQMtY9XRDy1THFvIrVgZ4RmOMJNzWFAbk=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject:From;
	b=ai5RJH0pNVV7hVwQ/eILZB9EV27Q8uQkGnvJgq6UXAlxEkRkYgkfHPcoS+aXEoQlo
	 EI7yRT8vDGkIOI4PX5ODev9Ouou4Zm9lyVIalVqqYC1A85egAMoqQjbHOgcS/bb5Pg
	 O04Q9jspVJG2U/UQqaCuH4ddueheHuqn9BiWqF5V1isvx47uSkAzISgYhROxVY9vlN
	 da3IQEEkvTx7znStPplcp5QRXBKgFVdIInTZffjywyjzAJrSCy/bPTL/0v4xNxRZTi
	 nVq7lOR/nO7M5rFCslAhZGBgscBXIR/aVVVdQn2a/JDBO+s+fjdcgcZ5wo5zu9Eh6s
	 h3KORJYQaOqwg==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 5721AF40068;
	Sun, 22 Feb 2026 15:31:43 -0500 (EST)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Sun, 22 Feb 2026 15:31:43 -0500
X-ME-Sender: <xms:r2ebaagBVxP7JWr8lbJ2OlYLTzSbkJHLh58n34D-4uIRRbFwHuX8Ag>
    <xme:r2ebaV1493kMF7ApYdSwXolWCz6fwLCXkc9-eI6iPohT1jP1RCgKH9PUF8bBi78FC
    9VtMtzQj59M84-EB0RfZl2ujKSkzlCavgIU_Kx843ll8KTTgLUEJFY>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeefgedrtddtgddvfeehvdekucetufdoteggodetrf
    dotffvucfrrhhofhhilhgvmecuhfgrshhtofgrihhlpdfurfetoffkrfgpnffqhgenuceu
    rghilhhouhhtmecufedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmnecujf
    gurhepofggfffhvfevkfgjfhfutgfgsehtjeertdertddtnecuhfhrohhmpedfvehhuhgt
    khcunfgvvhgvrhdfuceotggvlheskhgvrhhnvghlrdhorhhgqeenucggtffrrghtthgvrh
    hnpeejvefhudehleetvdejhfejvefghfelgeejvedvgfduuefffeegtdejuefhiedukeen
    ucffohhmrghinhepkhgvrhhnvghlrdhorhhgnecuvehluhhsthgvrhfuihiivgeptdenuc
    frrghrrghmpehmrghilhhfrhhomheptghhuhgtkhhlvghvvghrodhmvghsmhhtphgruhht
    hhhpvghrshhonhgrlhhithihqdduieefgeelleelheelqdefvdelkeeggedvfedqtggvlh
    eppehkvghrnhgvlhdrohhrghesfhgrshhtmhgrihhlrdgtohhmpdhnsggprhgtphhtthho
    peeipdhmohguvgepshhmthhpohhuthdprhgtphhtthhopehtrhhonhgurdhmhihklhgvsg
    hushhtsehhrghmmhgvrhhsphgrtggvrdgtohhmpdhrtghpthhtohepjhhlrgihthhonhes
    khgvrhhnvghlrdhorhhgpdhrtghpthhtohepshhnihhtiigvrheskhgvrhhnvghlrdhorh
    hgpdhrtghpthhtoheprghnnhgrrdhstghhuhhmrghkvghrsehorhgrtghlvgdrtghomhdp
    rhgtphhtthhopegthhhutghkrdhlvghvvghrsehorhgrtghlvgdrtghomhdprhgtphhtth
    hopehlihhnuhigqdhnfhhssehvghgvrhdrkhgvrhhnvghlrdhorhhg
X-ME-Proxy: <xmx:r2ebaWOnljWueIM6zavWSHd99taUAn2E9x1APmQiMuP7trVWXUHlsQ>
    <xmx:r2ebaeSmuTh3V9Zgm_jOiqS7aYwR9DaBuZg1zRzYx7mgDW89J8lhIw>
    <xmx:r2ebaUi2ouurrUu5WD8c728W2dqbEfFKJIN4ClMPdcCX9h-N9QzrkA>
    <xmx:r2ebaX9rnI136jW6gx4plC1m4EiuXbEpc7q52UuuQE-hrQP6b9hVSg>
    <xmx:r2ebabFVSh3gIN3lEAL4473CUbDO7LJiJCQIG5zLA4A3PLYr6LS3Xq-8>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 322B8780070; Sun, 22 Feb 2026 15:31:43 -0500 (EST)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AlLi9g6u_Xmg
Date: Sun, 22 Feb 2026 15:31:23 -0500
From: "Chuck Lever" <cel@kernel.org>
To: "Mike Snitzer" <snitzer@kernel.org>
Cc: "Chuck Lever" <chuck.lever@oracle.com>,
 "Jeff Layton" <jlayton@kernel.org>,
 "Trond Myklebust" <trond.myklebust@hammerspace.com>,
 "Anna Schumaker" <anna.schumaker@oracle.com>, linux-nfs@vger.kernel.org
Message-Id: <7ee56c30-f635-4de9-a4c1-8a5eaf7e491b@app.fastmail.com>
In-Reply-To: <aZtbbJ-dxkw-V4NU@kernel.org>
References: <20260219221352.40554-1-snitzer@kernel.org>
 <fbdf4c2b-6d3b-45bc-ae2e-48316dd16eeb@app.fastmail.com>
 <aZtbbJ-dxkw-V4NU@kernel.org>
Subject: Re: [RFC PATCH 00/11] NFS/NFSD: nfs4_acl passthru for NFSv4 reexport
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Sun, Feb 22, 2026, at 2:39 PM, Mike Snitzer wrote:
> On Sun, Feb 22, 2026 at 12:53:14PM -0500, Chuck Lever wrote:
>> 
>> 
>> On Thu, Feb 19, 2026, at 5:13 PM, Mike Snitzer wrote:
>> > Hi,
>> >
>> > This patchset aims to enable NFS v4.1 ACLs to be fully supported from
>> > an NFS v4.1 client to an NFSD v4.1 export that reexports NFS v4.2
>> > filesystem which has full support for NFS v4.1 ACLs (DACL and SACL).
>> >
>> > The first 6 patches focus on nfs4_acl passthru enablement (primarily
>> > for NFSD), patch 7 adds 4.1 nfs4_acl passthru support (DACL and SACL),
>> > patch 8 optimizes particular nfs4_acl passthru implementation in NFSD
>> > to skip memcpy if nfs4_acl passthru isn't needed, patches 9-11 offer
>> > the corresponding required NFSv4 client changes.
>> >
>> > This work is based on the NFS and NFSD code that has been merged
>> > during the 7.0 merge window.
>> 
>> Hey Mike, do you have a particular commit hash on which this series
>> applies? I've tried Torvalds master and nfsd-testing, and patch 3/11
>> fails to apply to either of them.
>
> Sorry about that.
>
> It's closest baseline is nfsd-7.0 (but my tree is a frankenbeast
> starting at 6.12 sync'd all the way through to nfs-for-6.18-3 and
> nfsd-7.0), see:
> https://git.kernel.org/pub/scm/linux/kernel/git/snitzer/linux.git/log/?h=kernel-6.12.63/nfs4_acl-passthru
>
> Given what you found, I'm missing some of your latest conflicting
> changes. So it'll need a rebase.

Anything publicly available will work. Rebase, then just toss the
tag or commit hash in your next cover-letter.

-- 
Chuck Lever
