Received: from fout-a5-smtp.messagingengine.com (fout-a5-smtp.messagingengine.com [103.168.172.148])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5075D3C1F4F;
	Tue, 22 Sep 2026 06:39:12 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.148
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790059154; cv=none; b=XewAZpJw0JGaVBdXwTIzstX4eduVBsMEgu0Q1qoX8pjRDR/NO7Zws9PO/ag1VnfvdtdxzhZdsNqF+IhJ2uTsp/d59M+nJFLwEGp0Rg1OWKd1ASy1fstF1NLAtgqC3o12jXrl8MSDcMHmbzHKmvTGwnYV7YwSQUeeR0LN1V4OUBU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790059154; c=relaxed/simple;
	bh=2QSchlkxCLW6fqAfy10nD+apB8rhLFt3uLBAXV9i4JE=;
	h=Content-Type:MIME-Version:From:To:Cc:Subject:In-reply-to:
	 References:Date:Message-id; b=Jbt15RdP3YMvu9AQT+W04Gx2giBpbjhOycov/Gjvj12CsxRVC5JiSzuyVHzqhBC0imKfPD4EGzY5iS9bdvWdjpbtzuxrzSj7VaIkPXiKfhevrrrrCdjkcDNG3UkEZWrm1ugRYpgZleINnXMPV7Mc7U5+aNkOy87PrFbdVwK1La4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=WkpdBYWv; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=owazOJLW; arc=none smtp.client-ip=103.168.172.148
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="WkpdBYWv";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="owazOJLW"
Received: from phl-compute-03.internal (phl-compute-03.internal [10.202.2.43])
	by mailfout.phl.internal (Postfix) with ESMTP id 892E4EC025A;
	Tue, 22 Sep 2026 02:39:11 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-03.internal (MEProxy); Tue, 22 Sep 2026 02:39:11 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to; s=fm1; t=
	1790059151; x=1790145551; bh=+8rvOv4oJzVQOCtsD5LzQbPmm1zllLvyfNu
	09tbGqIM=; b=WkpdBYWv6n8O1QGLW3Hf6u9M9IPIcLG5t2pLmySV/BSACvdqHMW
	i5ydcVrkCvXM1lDsnU9cTUENKaxitiojH7rT/vbUASQaCH4s2mNmmuJTQ4qpb580
	2ETjPdirR0v9EalacXxxvi4jkzN5olKfZLJEyfsutr/hVDscrWhruwJ6bXhe+llH
	N3SSor5qIG7abUXCpTL3ZoeMSbNMVS9TI4fJ94/3/fd6zzGzqBrKtbeCuv0oXYxA
	24jbdESgEzhHiOWpUPiv0CKwjaJvkW0h92wn1WIJZqX7TL1LLjhu1dG7OBNF3A7h
	DCLjEZAstZ2CnF7OEQ4dFgrTtUt93Brp4pA==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm1; t=1790059151; x=
	1790145551; bh=+8rvOv4oJzVQOCtsD5LzQbPmm1zllLvyfNu09tbGqIM=; b=o
	wazOJLWUo/Ym37TMzcsnrgfHLXrIyLhhMapP5e3uOMDGnrO/6WjdSK1gSGIsV/5F
	Kf/frOuvkfceTTGslyZ88JQvqTyUhoZCtdmdkcwx3j3YO+tUdJeMtihFRC5CmIm7
	LEb2/57UYyNlZRy9sTgkvxfmtoELjWleIH8Uc6MEmoZ6oAkAZ382qkXsjEXHE/pt
	d/ZWcPg5lG+WGyi9j/60FzhvgJXJBJIplG7RH+16+p5cFYNMjhKJ1k2o/J/Jtfy0
	mpQ7fpRxzHWkTLqTZT9QYe45UcBP/GGXcR40JGwKTNj3eTEAo2sn/KP3kmCpO3yD
	A08CCNDz2mjUp0zWmv5zg==
X-ME-Sender: <xms:jyKyaoxMrE_2APm7IqHU1V_h5txjp8tDob8Ce5D6MPNiDz1AoYAG0g>
    <xme:jyKyassV1MOJS7q5YzyPedtINLm2SwMsqexQDtznshDS9AmaTJapR5gT2z6-P5ubx
    D0Sb_quRFHVLuhlIKnfmNnshopwueRT3NBonE1DJ7dHed16Kw>
X-ME-Received: <xmr:jyKyarClDNeRM910MLNwAtLBZBVC-vCa1jOFtgjSwo32V1tlcI2SLU1OBEk1XF71_UlBNa-yeFaA8dzfP6zGa_U3PiWwBBE>
X-ME-Proxy-Cause: dmFkZTE2UsV6fzuS0xZ1a0qIg/rZx9Yr9yus3xrEBXIjhzSHggxp05Fja2/M7LIF1iZ1g+
    EwnVNvjY6xzm/M6XZfEryeeyoQwJBGawfIa8lX/xpYKRJ3kiwW3mvMxxtzvxihD54HP1yh
    uWoeZCxUE4TA1hUDmFwGzejtuBgHx24uArLjxhZTA2yRCNmjOW5TVDljUG0hSkIhmb8uvV
    FeCe9Z0znrAKBuC/zZe34IW3502mQB2rs3gZijMLxYJKCaOcGOEBDEqKebE6dgzUqvAX6m
    DaHyW+nWq+WqhceAQaBoPgnURlPa8kR2U4+OXpcdoMhl3l1qXUNF2xenEbpZWJL3+Fp0So
    M6GpNRLqvBU9k4vMsZzrnHaOWnBWZ/57TnW9r1o4QT11X0d5GX0tZDfqfZXekAZ7yFZI5Q
    d1XFb0jgPe/xxeo/Wtc/duvXyi4UfZEz/QOCyHqrHF/cgvXk8Mk/SBI3Urw4F97NYt3CBS
    qvJ73JBER3N1ZmePTwAQtvwPXpys1xRzdHL0PpykrbAy6T2J1sjtEdM3ml/raMYncdgHNu
    ERKXkP1ouQjZHcBz4aIKY4+lNLPmsBc1dyFpb8bVyArHxViCIkWQiBIQPWp5hkq5zFpWth
    z83sQX3hEOEhAS8Ij8uiBp9XBVsxfVqqIsQjeVzY5K8PiC3bTGP4Jp33EBPg
X-ME-Proxy: <xmx:jyKyauGSSsMFtBWYTAksLIq5WFzhkCwqWIrW4k7UXtauWZNKpHHT-g>
    <xmx:jyKyarDoyB9ZZ-3jSBqAhBrSFf41hsMnf-IoyseOoaVeEkjLS1PdNw>
    <xmx:jyKyakk0TlykrSX_AqsCI4ez_zrxRJQdYqo3Y3wMUA0ZvD5-iT61Bg>
    <xmx:jyKyahOxr221Up-ncqWdNFGYNxDCOD-aIOslyP9JDkid3nfGfZ-RpQ>
    <xmx:jyKyasXuTx2iBM_mUHQ1XyiR8esXhnAN-0ZOL5RHZ0JmYgTqEj3GcVLU>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Tue,
 22 Sep 2026 02:39:08 -0400 (EDT)
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
From: NeilBrown <neilb@ownmail.net>
To: "Jeff Layton" <jlayton@kernel.org>
Cc: "Chuck Lever" <cel@kernel.org>, "Olga Kornievskaia" <okorniev@redhat.com>,
 "Dai Ngo" <Dai.Ngo@oracle.com>, "Tom Talpey" <tom@talpey.com>,
 "Shuah Khan" <shuah@kernel.org>, linux-nfs@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-kselftest@vger.kernel.org,
 "Jeff Layton" <jlayton@kernel.org>
Subject: Re: [PATCH 0/8] nfsd: reduce the scope of the nfsd_mutex
In-reply-to: <20260921-nfsd-per-net-mutex-v1-0-4a7287f6504c@kernel.org>
References: <20260921-nfsd-per-net-mutex-v1-0-4a7287f6504c@kernel.org>
Date: Tue, 22 Sep 2026 16:39:06 +1000
Message-id: <179005914665.37859.6768755631378108574@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>

On Tue, 22 Sep 2026, Jeff Layton wrote:
> Currently much of nfsd's administration is serialized under the global
> nfsd_mutex, even though most of the objects managed under it are
> segregated by net namespace.
>=20
> This patchset does a couple of small cleanups and then adds a new
> per-net mutex and moves all of the appropriate per-net data structures
> to be protected by it instead of the global mutex. The filecache is
> given its own mutex, and the global mutex is renamed and left for
> managing just the few remaning global objects.
>=20
> I also had an LLM cook up some selftests so we can hopefully keep all of
> this working properly in the future.
>=20
> Please consider for v7.4.

Thanks for doing this Jeff - it is long past time :-)

It all looks good to me - except the selftests which I didn't look at.

Thanks,
NeilBrown



>=20
> Thanks,
> Jeff
>=20
> Signed-off-by: Jeff Layton <jlayton@kernel.org>
> ---
> Jeff Layton (8):
>       nfsd: clear NFSD_NET_UP before dropping the generic resource reference
>       nfsd: make max_blksize a per-namespace setting
>       nfsd: move the control plane to a per-namespace mutex
>       nfsd: rename nfsd_mutex to nfsd_global_mutex
>       nfsd: give the open file cache its own mutex
>       selftests/nfsd: factor the netlink plumbing into a shared header
>       selftests/nfsd: add cross-namespace isolation tests
>       selftests/nfsd: add a cross-namespace control-plane soak
>=20
>  fs/nfsd/export.c                                   |  22 +-
>  fs/nfsd/filecache.c                                |  36 +-
>  fs/nfsd/netns.h                                    |  16 +
>  fs/nfsd/nfs4proc.c                                 |   4 +-
>  fs/nfsd/nfs4state.c                                |   8 +-
>  fs/nfsd/nfsctl.c                                   | 129 ++---
>  fs/nfsd/nfsd.h                                     |   4 +-
>  fs/nfsd/nfssvc.c                                   | 146 ++++--
>  tools/testing/selftests/nfsd/Makefile              |   2 +
>  tools/testing/selftests/nfsd/config                |   6 +
>  tools/testing/selftests/nfsd/nfsd_netlink.h        | 319 ++++++++++++
>  .../testing/selftests/nfsd/nfsd_netlink_listener.c | 301 +----------
>  tools/testing/selftests/nfsd/nfsd_netns_isolation  | Bin 0 -> 49192 bytes
>  .../testing/selftests/nfsd/nfsd_netns_isolation.c  | 450 ++++++++++++++++
>  tools/testing/selftests/nfsd/nfsd_netns_stress     | Bin 0 -> 39232 bytes
>  tools/testing/selftests/nfsd/nfsd_netns_stress.c   | 572 +++++++++++++++++=
++++
>  tools/testing/selftests/nfsd/settings              |   2 +-
>  17 files changed, 1580 insertions(+), 437 deletions(-)
> ---
> base-commit: aeaddc6a3711283c09a9183068897d4fe1fb464f
> change-id: 20260918-nfsd-per-net-mutex-8655764940ac
>=20
> Best regards,
> --=20
> Jeff Layton <jlayton@kernel.org>
>=20
>=20

