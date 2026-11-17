Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=202.12.124.157
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794945009;
	b=Pk7oKLM2GW8xvhqhxVRljom++1JmmMs257Xw8uowHM/lm54QySudSiM9ZMtjX0E2wqTz
	 q16+SxO/Jlb//0RI7Au8q3pTBOFS8RadqBkQDJAnmWiATiaExA9aan8NSJ+h4lrNoxuW0
	 eXoAB/NB2zOO0QNtQmvMeNHaK5RoMiXBufLtLYSeg26IPMCL9+XCaeT7uOUMcb+kjYebQ
	 8FKdBGAaCENeRswYJRgpMvSGGu+fjyHl2GWuwWaIjPTVPG2PDBnDxi+HKZ1iua8V5bgmB
	 1P3lo5KgDuVD6pim5LIgjtYpQJFGyrjRj63SjrIKSour76kwjI6r3C4X3g5DICwisZw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794945009;
	h=DMARC-Filter:Received:Received:DKIM-Signature:DKIM-Signature:
	 X-DKIM2-Info:DKIM2-Signature:X-DKIM2-Info:Message-Instance:
	 X-ME-Sender:X-ME-Received:X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:
	 Received:Content-Type:Content-Transfer-Encoding:MIME-Version:From:To:
	 Cc:Subject:In-reply-to:References:Date:Message-id:Reply-To;
	bh=aZZPkr9s+hnMo9UJNZO4fH8reOA5Plq3lerqxIn6Wfk=;
	b=DWhHtviX3Gex7yylPiIo8RzNETk5Y6v9M8gdQXUIDVwwTdvC//bbDrImGhZtufq7drfz
	 5H1blfCdgmIW6VmHrzopKMU0I0RrO2ehLf1Qeby0s0/IrdLoNN7xHhYWx/MBUHFIkvRMm
	 v3Unh+qwsMjvGZmk6NtxNC/4aqhznI1yFphIWhmbl/Z/IFDrButyLP9hJ7tgfhyzRHapU
	 OTyfghKmTQmPFf55Uynuay1qmMBhz5la7HWmUi5GD1pi04TG8IhKj1q0BB5YUwAT+CFTF
	 6yI2OFw29zQk2nIlKor1n6n18mTCxARo85MquqQMfeHgp3YFeyELPAM8j0qmg29ajlw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=ownmail.net;
	spf=pass smtp.mailfrom=ownmail.net;
	dkim=pass header.d=ownmail.net header.i=@ownmail.net header.a=rsa-sha256 header.s=fm3 header.b=eWEWB99u;
	dkim=pass header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm3 header.b=sD3K+s6i;
	arc=none smtp.remote-ip=202.12.124.157
Received: from fhigh-b6-smtp.messagingengine.com (fhigh-b6-smtp.messagingengine.com [202.12.124.157])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 535C5606A31C
	for <linux-nfs@vger.kernel.org>; Tue, 17 Nov 2026 19:50:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 535C5606A31C
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=ownmail.net header.i=@ownmail.net header.a=rsa-sha256 header.s=fm3 header.b=eWEWB99u;
	dkim=pass (2048-bit key, unprotected) header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm3 header.b=sD3K+s6i
Received: from phl-compute-01.internal (phl-compute-01.internal [10.202.2.41])
	by mailfhigh.stl.internal (Postfix) with ESMTP id 077217A01D6
	for <linux-nfs@vger.kernel.org>; Tue, 17 Nov 2026 14:50:08 -0500 (EST)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-01.internal (MEProxy); Tue, 17 Nov 2026 14:50:08 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to; s=fm3; t=
	1794945007; x=1795031407; bh=aZZPkr9s+hnMo9UJNZO4fH8reOA5Plq3ler
	qxIn6Wfk=; b=eWEWB99uGos9HGSisg0lAs82T2IegRWvMEF2lM7E4BlJ1eGpTmD
	JsjstCh/ZPiVrB4Luz62p0v0BdL8qM+zvuhYx/lMY93WfmRw+dIJbNZIPJ6e4gUv
	p6/y8px3kclhu8qGP94M1GtpSAk7n583Noy5ZfCAbYnh98VmldJc80BvILEIh42O
	wQrtFKPt/ktO8Tvlrl5JUdBbqTHiQw4S4+wmSwPmKHqyt3vD0iRFRSj69dTMKnXy
	5wmcCLEjmBrccjLjwzHhCH/hphTrgPbJchnmbt8ayduDmHY/i13QI6doSexmb8Ln
	ceM4ldEzfhOw995QdYuzKfbiQ+UHzSUtL/g==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm3; t=1794945007; x=
	1795031407; bh=aZZPkr9s+hnMo9UJNZO4fH8reOA5Plq3lerqxIn6Wfk=; b=s
	D3K+s6i+kqwJRonkUXZ5zbvZl70+MK7eNALTtlHWgbES0+MHYQ5pZVUoFT1P4cY7
	eLQvBo8kwrRbOzwK9PvFYLbXE/WHeEPoQ1Lr6WfdZ8TMtKu4HiaMek1XxdTRinG/
	qex8Jvj0nkMfNxRx69nJDvTi3faOfFPU8wAkE8tveuCgMt8L74DaBFFRKR+SEG+Z
	k7LAKRRJFBbnlm8MZVxPnkF/JYqwcVYT7vCLi4gg+6rVOq3xg0oTLe8Vspz7t5cp
	mG432WlykiBBbJ52i9jAzjALx0oFqNUAOiGRDAPqif/gvqdiwPBXncPj/s5FUv56
	XnqquzVqB5HILNW6TKKMg==
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-09;
	repo=github.com/dkim2wg/interop; date=2026-11-03; sw=lmtpprox;
	action=sign d=ownmail.net a=rsa-sha256;
DKIM2-Signature: i=1; m=1; t=1794945007; d=ownmail.net;
	mf=PG5laWxiQG93bm1haWwubmV0Pg==;
	rt=PGxpbnV4LW5mc0B2Z2VyLmtlcm5lbC5vcmc+;
	s=fm3:rsa-sha256:zfCglDaB8eReCz5XK6nTlPYjoDIRVn3m1hp1IXDnQy2MMNC
	guiyOUXz3qbulmwt0LArAvF56pvOXDAykNZcSUGgmD8jbpIYvf3eidQeVA30q5RE
	Ff7TL3C6hDED+lfgjUIBb5+MUF/DbIS1IbeIJwzi7bAr++KPrpDULVc0A0BIgv0f
	d3YY1tXD0JzZ78YflICKhZu8zu2TvbeJ++c0XS0oLoBhIh4Z9L9Lluben7zARjo3
	5vJbt4pNZVHQq+GVBp+9owkmTa+lcGrc8yiHbRWTiYiq1dgb2dgbY1sjKPEiJFC1
	/ZQZ0v54Q6lfzDn+d3mtIw6QMEo7BU4VXqvmM9g==;
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-09;
	repo=github.com/dkim2wg/interop; date=2026-11-03; sw=lmtpprox;
	action=mi-m=1; hc=13;
	hn=cc,content-transfer-encoding,content-type,date,feedback-id,
	from,in-reply-to,message-id,mime-version,references,reply-to,
	subject,to;
Message-Instance: m=1; h=sha256:jkpCQ8QcnvNnqh4nUNhDNIWlEqvDGTD+iiUBF0Osqpo=:dRi95JVrle14R748Ann1VFXmiKSv04iWYLGMInVrkf0=;
X-ME-Sender: <xms:76_8apporcRxhuxrPrdRtUrzOBxqemes3Vnu-l6HqfAaT-ncssEL1g>
    <xme:76_8aijM9J5rZZ9StPt3sEULHGgLHMUit4iJ73KWVf3zoeNl2hFvWGLHUWD1CplKi
    6KZjBfoyiW60RXNJ7AeRQTclu_4W-P_BCx9qsXqu01w29Dmhlc>
X-ME-Received: <xmr:76_8auhvmSWyclrFF_YMn4ejsKE6ZqcasW_FLp9HQ0Qotd6e0YvOcceyRTfwLLkei8ntvXaQ0nCVrrAyRhpbMlcObLl3ims>
X-ME-Proxy-Cause: dmFkZTEeV/GwJn8CTkyW4okRzJmP+mYc/4C5rjcycn8JJ2UIM7a5XJ0sJY6fZE6KB5hBCJ
    omGrqpe0VUSnphCz8jg1NifEYGzyJtEB0ou4fch266AbO/IKW45/uKzt9ybQxwN0NuIruk
    7RsQ5AipOc6mGAyo9KN9oCi5aak5IvqysYoH9wasgiMb+65bCjHJdwOR/O5qmLs8xmQbwF
    tSyF33AnnJ4ymx1wt+Y479PrfXY4jrQqrdvAP6rjL7/duoYn08u8ysnE5BHAeXAGanYi5o
    LZsdlrCsQTb0I3pmwR3yeTxuNyKoc53h4p5a51KvftfnfeJmEECqsMQkVWsToOVM1i+REb
    R13fuXwG4rGuL/o3cEOTm5UWadjc03Knty3HFmJsDtRne+gys5vsEar/Kc4LKFFT0gYY2J
    42m8yZULnKUO+/Fh/ezrbkvXbpDqd8ftt2sJFG1kS+qhyhIktc4O/o/jqRZkEgw/UVe5+s
    7iCFUanHx5OzlZ7aAuT/dWT9z8wVP35gaZaJYU6D2mgoZAKYoYE1d1ZySC+Bz2F02cSo9U
    HOEyL1aJchO1GEL8eQ5IxbeJ/omNbB1nugmfpxkSptiqqptgoNNogtncoLEnBSFUvsB8ps
    nABo9yNzzCzWeSsBiJBxY3Uxel9JPA0628D+T0F1q8CFjKQY8PQ047JgTEpA
X-ME-Proxy: <xmx:76_8aghAYLz0e0qWFdxhXH74RCT4OTrbP9DBJ0uIuNJ9qMKoJpGxcA>
    <xmx:76_8amIw-NqQl4auBvVAzH6GWQxKyS-76fbVpy7F05Rm3QOslpUCsQ>
    <xmx:76_8anH_eNEtsMHF0DQbGuds6ylBZj5WQbVuOpEIyXDxX-BWygkZOQ>
    <xmx:76_8aiSRabYblusGcC8naqhH5YRjrNnBcXVLJz9WvAYA6nmaZohvLQ>
    <xmx:76_8agtkH8XJYqsyyiwHYFya018dShLqUHXY1lG6GYi2bIMhkLyklhJj>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Tue,
 17 Nov 2026 14:50:05 -0500 (EST)
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: quoted-printable
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
From: NeilBrown <neilb@ownmail.net>
To: "Anna Schumaker" <anna@kernel.org>
Cc: "Trond Myklebust" <trondmy@kernel.org>, "Jeff Layton" <jlayton@kernel.org>,
 "Jonathan Flynn" <jonathan.flynn@hammerspace.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v5 0/8] nfs: prepare for locking changes.
In-reply-to: <759d7deb-f380-4094-bb6b-35a4db945d56@app.fastmail.com>
References: <20261109005504.1804605-1-neilb@ownmail.net>
  <179488445814.1728055.9049767251296971441@noble.neil.brown.name>
  <759d7deb-f380-4094-bb6b-35a4db945d56@app.fastmail.com>
Date: Wed, 18 Nov 2026 06:50:01 +1100
Message-id: <179494500179.1728055.16539025879082560214@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>

On Wed, 18 Nov 2026, Anna Schumaker wrote:
> Hi Neil,
>=20
> On Mon, Nov 16, 2026, at 10:00 PM, NeilBrown wrote:
> > Hi Anna/Trond,
> > is there any chance this series might land for the next merge window?
>=20
> That's what I was expecting. The patches looked okay to me!

Great - thanks.  I was expecting to see them in -next by now if you were
okay with them.  When did you think they might land there?

Thanks,
NeilBrown


>=20
> Anna
>=20
> >
> > Thanks,
> > NeilBrown
> >
> >
> > On Mon, 09 Nov 2026, NeilBrown wrote:
> >> In this v5 I've dropped "nfs: fix nfs_call_unlink()" because it enabled =
code that was
> >> buggy.  I have ideas how to fix this properly but it belongs in a separa=
te series.
> >>=20
> >> I've also revised the barriers in "nfs: fix open-blocking with d_fsdata"=
, thanks
> >> in part to Jonathan's input.
> >>=20
> >> I think the rest is unchanged.
> >>=20
> >> Thanks,
> >> NeilBrown
> >>=20
> >>  [PATCH v5 1/8] nfs: fix open-blocking with d_fsdata
> >>  [PATCH v5 2/8] nfs: remove d_drop()/d_alloc_parallel() from
> >>  [PATCH v5 3/8] nfs: use d_splice_alias() in nfs_link()
> >>  [PATCH v5 4/8] nfs: don't d_drop() before d_splice_alias()
> >>  [PATCH v5 5/8] nfs: don't d_drop() before d_splice_alias() in
> >>  [PATCH v5 6/8] nfs: Use d_alloc_trylock() in nfs_prime_dcache()
> >>  [PATCH v5 7/8] nfs: use d_alloc_trylock() in silly-rename
> >>  [PATCH v5 8/8] nfs: use d_duplicate()
> >>=20
> >>
>=20

