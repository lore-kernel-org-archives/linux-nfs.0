Received: from fout-a6-smtp.messagingengine.com (fout-a6-smtp.messagingengine.com [103.168.172.149])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 290FA27A47F
	for <linux-nfs@vger.kernel.org>; Fri, 28 Aug 2026 22:36:42 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.149
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787956605; cv=none; b=l1yj+LFSoiZM7/y6vetDzqH3OyY7zrWAGSb/f3kVfeKr/QGrj+zeGlzH6lqFyeutcnPJgx5eC3LyVP/N280WFefrI+EmXOCS7Uc5EGhTSCBShTCQTaRemIki6kfYVdXJfIML7o13SqKjrf7TfBUoXIdx/nCyni5akJb9KSV3rsA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787956605; c=relaxed/simple;
	bh=JuN9AbhiRE29Zms/17ZeBGNMHUnfDEEI6WfbVdA4uAI=;
	h=Content-Type:MIME-Version:From:To:Cc:Subject:In-reply-to:
	 References:Date:Message-id; b=qi0fWttB+X8Z9IGboaofxW0sfij6zUYGjATLtP6lQoaQBJdRfXnqOIj0w3o8JffkNevFkYA1gMq2oc3RA3mFGwnPGT2L+QzVysqEAYuyUEvdsO/Bn2lwQ7lWWnfbU84ikAy0QTHGspak1ZRJ9JiR5hI+hEAlBzbyb8nXAtjhwu0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=eq+wa4H3; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=jg8ugREK; arc=none smtp.client-ip=103.168.172.149
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="eq+wa4H3";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="jg8ugREK"
Received: from phl-compute-04.internal (phl-compute-04.internal [10.202.2.44])
	by mailfout.phl.internal (Postfix) with ESMTP id 42925EC023C;
	Fri, 28 Aug 2026 18:36:42 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-04.internal (MEProxy); Fri, 28 Aug 2026 18:36:42 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to; s=fm3; t=
	1787956602; x=1788043002; bh=FCI4JDtsfiLYkeB7osnRz9rXvw+DqL/MmcC
	Cx1/1dEI=; b=eq+wa4H30MAw3xheYNr2QN8WbLiex2yf1wYnf+vb2M7hd5XydXJ
	ncG5tKcVz7FJlUkhD9SSd3OxIm9QyFguZC2j8RC7n8XI/iu2gOzfmsq6EQGfKl0n
	Qlvn1vaq+f6bWU9Vws6TMRu8YK4EAgiOU79tabxdwz97zhnaw3OOKl9EtCXOfxka
	UfqkFoBRAl05Tb8Rijo3NtQycZfZqUgMQWLAXQlTbbAhOiCtOg9Fg66yApZRW5Pf
	+W/KNAq7vOyNps711giWgcEIGwcvc4ysWwgPWKlCceve1FLf/Aphr+as82af9pbU
	p9RFu0+05rXknoJePDjHSiUV0buv3JgFvzg==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm3; t=1787956602; x=
	1788043002; bh=FCI4JDtsfiLYkeB7osnRz9rXvw+DqL/MmcCCx1/1dEI=; b=j
	g8ugREKUTR/PVVdJHy6eqIsSE1crXkgRYFVcSmqgVddnZaLys9DQLLrTBNspUzyZ
	OYpQ0HR2LISgy0Ix75rKv1kFobN7HdS46zOqrctHQu1P/A9ub/q5bGcbU/zWwX4N
	MeIVEKOkGSyEaemdTL/pnwhucY11Xo3HozFjy6MnbVKAmBEPyctcAdHLi1uKa6hI
	+1vUipHYaMmlQkbsMvaCdtqotKaUOrm0D6N+KXCo/WJjDOB2EVCFxcxSi/2tf+Ud
	7uOn+3adu4ag/QqF4MLmBU8QkGCp0UaqPTe0CsOSoTYddFcu+cwZdk4OjmnULoyI
	c0l2aNgCanJi9RrlNDZ5Q==
X-ME-Sender: <xms:eQ2Sap5PxwARU3nuUplOAKeJOMWL2h9lKCb-URNW6CFtPRwIfjJAUw>
    <xme:eQ2Sape6wALl3Bnt5fKzPpx-QYSP8oLkT0xQkdjcNENATQUvoyjoOdZFvBjcFpdkJ
    yREcSYn2ZFA4N1E3_Wt7CfoUvlG5RYgBt8oQqxI8_REO6LZX6I>
X-ME-Received: <xmr:eQ2SakHxBNBl3TVwbLGSNW4l7pjkkTrCVqimLcGi0GAQ8JdDoGj03dMnKPln86iC0wOUrQB-ZLTUSM36pyO4T0rVS_-xEto>
X-ME-Proxy-Cause: dmFkZTF3++Y4ujIQ+gxfDizbbKqJHoMa+TDeGyH5lP2mQZQOw8FLVZg8M33D0zJlGn8lIe
    4NPtkpVJUKBZHrOi5++YLhWSJgN/sVePnn+BAFKyUEzbpFwdE3FSKuHpRhaeTdRkp7vOz0
    6pq4kTIkYsNIWeh4qPu4y2lydXUzLAC0pmMuTuBOtNU/nvntVaROnEo58QTye8waHYtEmA
    ed9CMOJAVo+tY80GqM9Aj7yvzNlRKbykDM88V15w/m7J//aMCPPsnihHy+mbG/QhD6xiAy
    8HQLwcKuJcTX0FAJa6PoVXa9vVHILjcd3WAbDsBjOBuJ7nQZ2lWDDvLibYBQOfhmt3AsYe
    TTIdSveT0dFdAay524aL5ilMS0zepvJWudTD9UMzIyqjCDfoZRi2rwvCCk7VQYtpbmUGrh
    K7UAwifWJm6idToY8qFMwSmVPV6Y+QVX8PaEcOI+XBIUnYaCXrO1ZoGKSJyl5Zahb8d8AF
    c6reEsya3mMV8AzpxTOncWG1IHcr+qjbRLTTp73mP8R+/AbQWWOMTkCILIJzipF9dwZW+D
    jJ8wNHHSmPm1UdL61wVXptK0BUdGZyRFHoq6heGZpnb1z+D10p3lbuw7jh6bgtQUD8uGmr
    lwU3F/h9n/PmeQxsb1lPs8VQWFcQXdkTTA/C8Y5lkPc3PIMLhrBpoO8VgeTQ
X-ME-Proxy: <xmx:eQ2SaiTUU9bhJ3BbID2ChImSzQsWrEAzrVujxPIL1zaIy6VJ6Gygig>
    <xmx:eQ2Saibb-dxStQBCqWoUfADnodbpHuoBI9fWmcibp-AmsIrO_AuJwQ>
    <xmx:eQ2Sal0p8J3bFfFkM1ZDvRX3gOOCY4ZNdHavQwBY6cRlT1Fh1LMf0g>
    <xmx:eQ2SatomLpVfwVjjF5uiKQgN-adxCFIYwxBbCbXF8aCj6UFL0q6GfA>
    <xmx:eg2Sal6oxaDXnlhLIUy0m1Xpw_AhGF6Dagdrx3DXBbORPR9lGZuyu-yh>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Fri,
 28 Aug 2026 18:36:39 -0400 (EDT)
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
From: NeilBrown <neilb@ownmail.net>
To: "Chuck Lever" <cel@kernel.org>
Cc: "Tom Rini" <trini@konsulko.com>,
 =?utf-8?q?J=C3=B6rg?= Sommer <joerg@jo-so.de>,
 "Jeff Layton" <jlayton@kernel.org>, "Olga Kornievskaia" <okorniev@redhat.com>,
 "Dai Ngo" <dai.ngo@oracle.com>, "Tom Talpey" <tom@talpey.com>,
 linux-nfs@vger.kernel.org, "Chuck Lever" <chuck.lever@oracle.com>
Subject: Re: [PATCH 2/2] NFS: NFSERR_INVAL is not defined by NFSv2
In-reply-to: <a832bec6-fdcf-4405-b8ed-87418bc704cf@app.fastmail.com>
References: <20251210002850.318350-1-cel@kernel.org>
  <20251210002850.318350-3-cel@kernel.org>  <apE90ZRZB8IW_AiS@jo-so.de>
  <178791679053.3510150.70411349578293852@noble.neil.brown.name>
  <91e02ca3-e985-47fa-aed8-0b50a5d7a3c9@app.fastmail.com>
  <20260828205116.GA266670@bill-the-cat>
  <a9a48faa-2663-40d7-86c8-ec2eaa967cdf@app.fastmail.com>
  <20260828211855.GL3959812@bill-the-cat>
  <a832bec6-fdcf-4405-b8ed-87418bc704cf@app.fastmail.com>
Date: Sat, 29 Aug 2026 08:36:35 +1000
Message-id: <178795659577.3510150.12183147665128116121@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>

On Sat, 29 Aug 2026, Chuck Lever wrote:
>=20
> On Fri, Aug 28, 2026, at 5:18 PM, Tom Rini wrote:
> > On Fri, Aug 28, 2026 at 05:06:14PM -0400, Chuck Lever wrote:
> >>=20
> >>=20
> >> On Fri, Aug 28, 2026, at 4:51 PM, Tom Rini wrote:
> >> > On Fri, Aug 28, 2026 at 09:27:41AM -0400, Chuck Lever wrote:
> >> >>=20
> >> >>=20
> >> >> On Fri, Aug 28, 2026, at 7:33 AM, NeilBrown wrote:
>=20
> >> >> > U-boot has
> >> >> >
> >> >> > 		} else if ((rlen =3D=3D -NFSERR_ISDIR) || (rlen =3D=3D -NFSERR_IN=
VAL)) {
> >> >> > 			/* symbolic link */
> >> >> > 			nfs_state =3D STATE_READLINK_REQ;
> >> >> > 			nfs_send();
> >> >> >
>=20
> >> The "deployments can't be updated" also doesn't make sense: if
> >> they can't be updated, they won't be able to get the revert
> >> either.
> >
> > By deployments I mean U-Boot deployments. It's notoriously hard to
> > update firmwares most of the time. Some testing labs refuse to because
> > of the value in testing the firmware most people likely have deployed
> > rather than the latest and greatest. So most of the time, it's never
> > updated. Can newer systems take advantage of good and specification
> > following update mechanisms? Sure. In practice? Only maybe.
>=20
> I'm talking about changing NFSD to return NFSERR_ISDIR, which would
> be picked up by the first "if" check above, which already exists
> in U-Boot.

Good idea.
That matches what OpenSolaris does, which is the closest thing to a real
standard for NFSv2.

https://web.archive.org/web/20090216190827/http://src.opensolaris.org/source/=
xref/onnv/onnv-gate/usr/src/uts/common/fs/nfs/nfs_srv.c

lines 619-624.

Thanks,
NeilBrown


>=20
> That addresses the regression and can be backported into the LTS
> Linux kernels that have commit 0ac903d1bfdc [*]. It does not depend
> on making changes to U-Boot.
>=20
> Since the problem was reported on linux-nfs and refers to a
> specific Linux kernel commit hash, I assumed the only thing on
> the table is a code change in NFSD.
>=20
>=20
> --=20
> Chuck Lever
>=20
> [*] AFAICT, the only two LTS kernels that are affected are v6.12
>     and v6.18. The stable kernels (v7.1 and v7.2) would also be
>     impacted.
>=20

