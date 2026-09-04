Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0DBFC4AA401
	for <linux-nfs@vger.kernel.org>; Fri,  4 Sep 2026 14:15:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788531354; cv=none; b=AjcI7cW8mw30KxBzJheV+HtZuC76DyZPES3uqTl28BQFz4AfNXA2ie9ew+5e1tWMXOVHRuFcst21fxtklShS8II6SpQog42gduYCaGxLko+QYVLv/jeHl6MqPeOLRJr+N9Hw5IEBpAO7wVfsrwoNxsXXkUxZBFxBxbSqypyYZtQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788531354; c=relaxed/simple;
	bh=Y/W3TWPx95jZBbhUBhpg3FGIwP8Rw4ur/nYBL4qJIOI=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=bWBDGgJYVvxrClYazO4KSBkecbVNwkbdvGnourzSH4UaT+rj/L3dId/0FGSmRb7SKCcgrKaSFccJlIa9t4N1kbJRD0uXQwaVi+Jh/xTFvgrgQHW/s1Tq+QVG5jZu/qIXCz7ftajMkKnMG0TmTwOG3FfiLuV3W7qqWb1IAh8FsU0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=e/9f2ctB; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="e/9f2ctB"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 1A6471F00A3F;
	Fri,  4 Sep 2026 14:15:52 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788531352;
	bh=Y/W3TWPx95jZBbhUBhpg3FGIwP8Rw4ur/nYBL4qJIOI=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=e/9f2ctBdNDFmNlrbUVqMvqwV1R7iW3zo4EBvlZRWDjhFWEYyRxG65VXon1GkRPOE
	 arvsbSVaPiR/tB1qc54eG1lJ5056mUaLiquQMqTwYnOir9BnRZBw9hJ2r2BBTHW1SZ
	 h2Rvqr+1rwi0Vd0e2Ai6YGh7Z3c79TtCHhJgwUJq7lbs3L2jWaJs9k/4WseVRHzoW2
	 qFdgcTa2EqeohEwKANuaiRAW/8nPo3RpFF0+b8z6GxNs/1/5c89cEJQInIKyQnN2v/
	 pcHFMHg7HjK93q0S/xGYt7rFUxzZnVpTFX8MggfLu//3FRTfn96KLz2wGcjVAO42Ld
	 bKVxnMzZOeR1A==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 453A2F40066;
	Fri,  4 Sep 2026 10:15:51 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Fri, 04 Sep 2026 10:15:51 -0400
X-ME-Sender: <xms:l9KaasNWpkxY7IaIfyA0mCut2Ur4xJ64GdkEmwScMKBlJ2d1Bd_jiA>
    <xme:l9Kaatz2GAZdh4wdt2V8m47bWAt0X1QkbWVCzmMOgd7LMJtSHn3our_CsMwqazZfh
    oIZNyDLC8XEKpOhIsEgrqZYpfSTD2O6CG-aCCfRmVqG3SDTJ0cdxEg>
X-ME-Proxy-Cause: dmFkZTGBuHo94Owsf0jMLwBUIj8on3xhoWTDTzMoyfhv2WWzLhu/CabtXjM343h2Il9CzS
    PVWURteTRvGTvLUTAuDbrD121xgqsjXqcCi/5aUqea8PQcqhu9xtuyhN4zvO/mGKjcAiWl
    Q/LREL6w618GxkPBUL7+5QdSYWi+pnnf2J2NQciKg2xdwnswL+RXQpU8joFDRqiR7NS6Xh
    j84/QMSYlG+4uGmJG3oDMOqbyU4aniQjQqp3c7UK+mCusbuqEpvad0EAy13nIxmKCwJJCG
    p3TtuXLuG7WJ/SG0Hr5axovFN9Sj+OoV4ENZftepxQhU2EtEZ/YGkAmgYPkutiC26jj4j/
    zdLYMAp+fFKn4UkJ2UVXfsXOk+zfrDKK/mxKhrnfceV/DB7gWGmrmp7he2c4xNhpPRH2v5
    fJI6f146jevcNcS2JCr3yyhpJ1TR8U+MC6k2/BjX/Asgkx9iUrDCKgMGpJmSaNx7umreWs
    8n7PVKfpe42R+FgjJ1l3apPB8AeC8hbF/1saCq9c9VEOQZlKtCGsxmBUbNvyT5H5+HpBIj
    H2wNtJPpZ63xDUKUSnDRMwzcE5hVXZuMlgZV98d9zJVNQ36YnnLtdfMEo9cp4tELfzkXVo
    4fflE5T+pt14E5xp4kGVpMTSZSjvswsXjiilrSOo0m5k6qJuXn7u90QBh12g
X-ME-Proxy: <xmx:l9Kaakilz_SIZHzGWzAlqofFzkuaLMPp15WV3Quayg5UGSAYoJZ4eA>
    <xmx:l9KaagtRuZD1Tb3Uc9ANtI8Pomi2pO1dS3DRuxakI0IKLXdsLBuSHg>
    <xmx:l9Kaal6-nqY-81O1V2pLJlyzsMszmSR8ubTRmgxjbY7EAaY4HEhXIw>
    <xmx:l9KaasPxNHc5AIYvF4u3SsN8iwp8kwUJ2y69uKuujK7Hc-tsKZw32g>
    <xmx:l9Kaajvx-bI4I23PCJ9xonPjhnuwEHpyf0iezm6CLEOfbV7HbyuLk4wF>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 28BFF7811F3; Fri,  4 Sep 2026 10:15:51 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AXS_LISVHZGo
Date: Fri, 04 Sep 2026 10:15:30 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Jeff Layton" <jlayton@kernel.org>, "Benji Wiebe" <itsme@benjiwiebe.com>
Cc: "Linux kernel regressions list" <regressions@lists.linux.dev>,
 linux-nfs@vger.kernel.org, stable@vger.kernel.org
Message-Id: <b1a6d878-31f3-4168-b6f2-b8de0311a854@app.fastmail.com>
In-Reply-To: <52ddb3307fcc0893cc20ed63c4dc924f6bcaa8fd.camel@kernel.org>
References: <c26ff09f-48d6-4ef3-9feb-8a8e6d6f37ba@benjiwiebe.com>
 <c3d06b9f-7da5-479f-be4f-9c0136631ce9@oracle.com>
 <c734eeb8-8486-4491-bb4d-b9656cbaffbe@app.fastmail.com>
 <52ddb3307fcc0893cc20ed63c4dc924f6bcaa8fd.camel@kernel.org>
Subject: Re: [REGRESSION] reads and writes hang if NFS server has v3 disabled
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable



On Fri, Sep 4, 2026, at 9:45 AM, Jeff Layton wrote:
> On Fri, 2026-09-04 at 09:09 -0400, Chuck Lever wrote:
>> [ Adding correct addresses from MAINTAINERS ]
>>=20
>> On Fri, Sep 4, 2026, at 9:05 AM, Chuck Lever wrote:
>> > I'm using a minimal Fedora 45 VM (kvm) for testing.=E2=80=8A=C2=A0 =
I export a
>> > directory with rw and mount it from my personal computer running Fe=
dora
>> > 45 as well. If /etc/nfs.=E2=80=8Aconf has vers3=3Dn, then reads and=
 writes hang in
>> > D+ state, and there's a continuous
>> >=20
>> >=20
>> > I'm using a minimal Fedora 45 VM (kvm) for testing.=C2=A0 I export =
a=20
>> > directory with rw and mount it from my personal computer running Fe=
dora=20
>> > 45 as well.
>> > If /etc/nfs.conf has vers3=3Dn, then reads and writes hang in D+ st=
ate,=20
>> > and there's a continuous loop of V3 NULL calls, with the server rep=
lying=20
>> > that it only supports v4.
>> > If nfs.conf has vers3=3Dy, then the reads and writes succeed.
>> > Introduced in 70b7e3526c53d9dd, still present in the latest=20
>> > mainline/master (841e384b841a).
>> >=20
>> > The hung state can be rescued by changing the setting and restartin=
g=20
>> > nfs-server, at which point the read/write will complete.
>> >=20
>> > I can do more testing / get more information as needed.
>> >=20
>> > Here's links to pcap files with it working/bugged:
>> > http://grepper.net/lkml-files/nfs-working.pcap
>> > http://grepper.net/lkml-files/nfs-bugged.pcap
>> > http://grepper.net/lkml-files/nfs-bug-kernel.config
>> >=20
>> > #regzbot introduced:=C2=A0 70b7e3526c53d9dd7caccdbeff5b0485640d8cf1
>>=20
>> It's not immediately obvious to me why 70b7e3526c53d9dd should
>> cause this kind of behavior regression.
>>=20
>> Jeff, it's a netlink change. Can you triage?
>>=20
>
> Sure.
>
> Looking at the captures, it looks like the server is handing out a
> flexfiles v3 pNFS layout for the trivial server, and that's (of course)
> failing in this situation.
>
> So we have at least one server bug there -- it shouldn't advertise a
> flexfiles v3 layout when it's not serving v3! I'll plan to fix that
> soon.
>
> That doesn't seem to have anything to do with commit 70b7e3526c53d9dd
> though. I'm not sure why a bisect would have landed there.
>
> What does the /etc/exports entry for this export look like? Disabling
> pnfs should work around this for now too if you have it explicitly
> enabled here.

Could be:

https://git.kernel.org/pub/scm/linux/kernel/git/cel/linux.git/commit/?h=3D=
nfsd-testing&id=3D89225ab5f186ed80b7044cdf3b50902f4c1ee024

--=20
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
