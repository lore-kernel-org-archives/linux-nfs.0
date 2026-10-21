Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=202.12.124.151
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792578513;
	b=0n3v3/qf1McnImjdexfODlUO6IdzRZpNPV/boCz1btd1OHRdl0Q4DtAPeU8Z0j+hLRkY
	 R0fV96MHZq8I2O40wTtNbArvEVu3ugKG14CB8G7jutUzHNAaDOcKWQL6lUACYfxRMBiva
	 PeOxEPtBYNVYbGy82vCw3qFRfHke0nK+RsBQsdLBdym+kBRbcXnnwIPan2dq57usb4a9V
	 2Vww1XnIMSrV6iBcH0xNIc+qQ7UGI4hsNgKQ0cNW/6AC/oB5kmDWRvReClfw+it3KcGg8
	 qTvOMHtHlx/MWERG69bEBJ39IV4/FhqJZSNE2aJa5ipdD4i+3SPZ+dl45wCSun+prWg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792578513;
	h=DMARC-Filter:Received:Received:DKIM-Signature:DKIM-Signature:
	 X-DKIM2-Info:DKIM2-Signature:X-DKIM2-Info:Message-Instance:
	 X-ME-Sender:X-ME-Received:X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:
	 Received:Content-Type:Content-Transfer-Encoding:MIME-Version:From:To:
	 Cc:Subject:In-reply-to:References:Date:Message-id:Reply-To;
	bh=TTOT2RHpdTNw/iL/eyTILsE04DtZ3hMxAYiwMsVpaqg=;
	b=qOnCd5rZpXFgMRILM3qgQSwcyxy5y3vlfUNn2Yvh7JuBlsTXWf/k23DCYKL81eGxHJ6r
	 5PzBhWL9AiDBHI/ApMV2JG0ZyEyFKIrG74aKXIPasj55PUIIZNg36JyoMG9PhiRY4BM0H
	 laN6lZZc1GtRI4/ROmXfPHN6mQOYsmw2Ceo1kpn00MvBl4pNGM5d6yTJuhe26+FY0UJkA
	 A/5CV2RQf7/sDITYuNRBcGNI92TABrRRoRZ+JUiduO4Zy/qDdpxBXw8Q+d8kGd58uj0db
	 mB2FP2ryLIbIBNTJuZv6F5Xa+iUztW5HjnDEuLxjgvlkqCbEA61LpgSarIW6Bth7x3Q==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=ownmail.net;
	spf=pass smtp.mailfrom=ownmail.net;
	dkim=pass header.d=ownmail.net header.i=@ownmail.net header.a=rsa-sha256 header.s=fm2 header.b=keKxA3eM;
	dkim=pass header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm2 header.b=lY8Ea6t1;
	arc=none smtp.remote-ip=202.12.124.151
Received: from fout-b8-smtp.messagingengine.com (fout-b8-smtp.messagingengine.com [202.12.124.151])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 88949606A31A
	for <linux-nfs@vger.kernel.org>; Wed, 21 Oct 2026 10:28:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 88949606A31A
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=ownmail.net header.i=@ownmail.net header.a=rsa-sha256 header.s=fm2 header.b=keKxA3eM;
	dkim=pass (2048-bit key, unprotected) header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm2 header.b=lY8Ea6t1
Received: from phl-compute-01.internal (phl-compute-01.internal [10.202.2.41])
	by mailfout.stl.internal (Postfix) with ESMTP id 8E5821D000B2
	for <linux-nfs@vger.kernel.org>; Wed, 21 Oct 2026 06:28:31 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-01.internal (MEProxy); Wed, 21 Oct 2026 06:28:31 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to; s=fm2; t=
	1792578511; x=1792664911; bh=TTOT2RHpdTNw/iL/eyTILsE04DtZ3hMxAYi
	wMsVpaqg=; b=keKxA3eMvcD+mXNBpy4nSavhe/j4T9hKLqyhZ29lb/Q7PAveh7G
	RLnMr/5n+ZTBUk/9+5HU3qOn8TK54Fqh7sj+mFM2RlrFX3PR/vlf53zAL1fg7nv4
	q8kQiObjTjZ/lL+mhm7sJTk50fgwu1u6iqqXQ4YCnc6d71rNMGk7GY7GqNvjrUEe
	NpBkOeASSxcP6DQ74PDew0nfEdqfM0toCYXnfEvchgUN8GkBdH6c2WmGuQb17cps
	QhWvQp60aIFd1WdnpJEcs4o0tdHe2oe2GqkmUDLKk30JZ2SLTc5mgguDKeaeQvk+
	aJ5UrUdQZ8WyyK1PZ+CsiwfM0DOz2iSOnLw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; t=1792578511; x=
	1792664911; bh=TTOT2RHpdTNw/iL/eyTILsE04DtZ3hMxAYiwMsVpaqg=; b=l
	Y8Ea6t181/RsG2QLGlV1LuJOFgTCECBBTIXRp0ZiNJ59udaZhyP4SzeyTTFKjBtE
	OSDjqcYvC9w6dNtsZ8j2gTYY5pbUFd9gEsFcs3hGvAXZQ7y1KNfWdZlzPx3a1dSF
	oVN+cE6HQSWBWgUXtm19NH2FRTVnyGYvHy6rmMDRkooV9Sr6icZC6kjG3K5k80w+
	kqEbr8FkXJPjyr+5PDlWe1nTlUoDgsThHBrOZu4ShxWBNm+aYoVOd5IFdJ/tFCxG
	c4E6DEgpqYdShqcjmwfvpMAYJt3tYyiC/BmzoiWr4rVWz49Rkt4HKug/uPObNGCQ
	A8CihKAKaIYnUFFDNTEOQ==
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-07;
	repo=github.com/dkim2wg/interop; date=2026-10-18; sw=lmtpprox;
	action=sign d=ownmail.net a=rsa-sha256;
DKIM2-Signature: i=1; m=1; t=1792578511; d=ownmail.net;
	mf=PG5laWxiQG93bm1haWwubmV0Pg==;
	rt=PGxpbnV4LW5mc0B2Z2VyLmtlcm5lbC5vcmc+;
	s=fm2:rsa-sha256:M+noep4sdIE8AWIWiSiaUBr2Vow54b3JvyGl02x5DOglXG+
	lWkJlZcMcBOpK907joIAHDbkU2idNTC83ptbE1GlKKxX6kCyD41Czm3nQeccfMyu
	G9QC2Hw76QfZZjHGj4+rsxx079MGgrmVSGqtSCVqL+FvXYnuPyaoDfmLOsIerWUk
	jCZBt1vAx30CnkN73vMBYV+o4wKjRhGqzcCLbCo7vp/s2hkD352yi+5doIznkz0n
	3MREhZCxBnqptiVAN2YimCTDNh75MpsDTneaWxkip3XAd8GIfXMxO98mfIv1eKcV
	a/cTCAlKQ8YAiY/VsMKG/PjQ9g4YcNhKyX7pHbw==;
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-07;
	repo=github.com/dkim2wg/interop; date=2026-10-18; sw=lmtpprox;
	action=mi-m=1; hc=13;
	hn=cc,content-transfer-encoding,content-type,date,feedback-id,
	from,in-reply-to,message-id,mime-version,references,reply-to,
	subject,to;
Message-Instance: m=1; h=sha256:UBUAD6Qk2BxrzMWX35FlLANF0lEAxH+02kfEewzu/CU=:e0dXa1NlVGzzFYHfts24LsyDelKD5zggPEW+9apv6r0=;
X-ME-Sender: <xms:zpPYar6ojw6njOjahzNcz3NqO1uQIe3WGFMSDps99zmNsBSdW6edsQ>
    <xme:zpPYajdtocpyITF5WwVFBkmN_kLRug-QQQguyXyCps6WaHTR6fM1eObX4t924fkhM
    awX9Bn0d846WTgToftLX3PqNq-vm9emBF32JIORY8a7aTJOv44>
X-ME-Received: <xmr:zpPYamG_rDaN7F5D_ATk2HuwzX08-oYYWEvVjtXxaNOzc3pyy8NVskKCx0g3fgnxb0i04LsnyzvdBYrrxTDuZTXTh4je0P0>
X-ME-Proxy-Cause: dmFkZTFf2LA/vJzIlKR7wQaDQy4m/7RZVCQrYJ1mUXlvFwTZkRrW23YBcuVJwGe2F78y2S
    Oyq27n6nvC01YpiTo30OJjip71O8GACLUrJIMbZ+xsvapE4RJgh3jzg4G27EPsqHieDH73
    rF3IgUKweWhvK2M+TsPybMcIEnvGyir4Sm/jSbDvafWYAO7AV48Pl3aywwGYQU80IlLBWS
    N4cwZXJG1fZYJrydXu+7iHncfUEtdkdCvUsUFNiRaPxg5+TGB2cFElbYx2yeAfnd4BiDhT
    DkhvU1j6WAis1hfat9QbIEmUPq7WbPo/PhM2cLiikgKM2q/OSl0jmTXTGYjtZrFOZbdPBc
    hZUVuS1nwfOU+DbN5mTsw3oYMfpSBJcFpm6jnQenKyORZAsgpH7G9bVHc66A5hyz9J7iXK
    6me4l/PLQwc0bi2g+H6XAxZNZdSE5eaApYd12KagBbwnPezmszF90FXvq6oPhCnHjmKQXP
    Q/izCHtVrYDEkXJ5KwpfD5FZZrGZkmnjWK7olT4MTNHQ8n3AaA0oC0j8ZsOVhfCAih3mmP
    mxVYKnkjVGa2FUbk47oIgxw1bqBoNWSKCsrKVywNEJ6Nwx1ocKvv+4xBAWvZ35redTNBNz
    IJH+nHbKLgaLkh45XIeGxT+62tdaumpTxMOmh9RB7eEJoHXzq5zNf7zDNX8A
X-ME-Proxy: <xmx:zpPYasRXdxQsA-c07navvw2J9MYwBwddE26qkfm2YFyyRiabRlJUXw>
    <xmx:zpPYakam2lE-LAA_Ioyl1b3tcqYe_AAF-lAO8m1imW50p1FKrmVYfA>
    <xmx:zpPYav1lpVn7Iuo8q9SaP5y7DwY7Zfr9FaQv533ag4qbDAgzOtjrWg>
    <xmx:zpPYavq2UPnt0YUh21lZC5golbunisWKrL_nTKBxZA_JIyGcuhsUPA>
    <xmx:z5PYatwuZT2Pe4kdDxFpMOeboRGv8hcWLqMV71MeKI1yIIL8sZR8fyuP>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Wed,
 21 Oct 2026 06:28:28 -0400 (EDT)
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
To: "Christian Brauner" <brauner@kernel.org>
Cc: "Trond Myklebust" <trondmy@kernel.org>, "Anna Schumaker" <anna@kernel.org>,
 "Alexander Viro" <viro@zeniv.linux.org.uk>,
 "Jeff Layton" <jlayton@kernel.org>, "Jan Kara" <jack@suse.cz>,
 linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/9] nfs preparing for locking changes.
In-reply-to: <20261021-hinbekommen-angedacht-bahnanlagen-d832186d3a71@brauner>
References: <20260926001011.401824-1-neilb@ownmail.net>
  <20261021-hinbekommen-angedacht-bahnanlagen-d832186d3a71@brauner>
Date: Wed, 21 Oct 2026 21:28:24 +1100
Message-id: <179257850450.1724252.1685434539612383422@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>

On Wed, 21 Oct 2026, Christian Brauner wrote:
> On Sat, Sep 26, 2026 at 10:01:17AM +1000, NeilBrown wrote:
> > I am working on changes to directory locking.  The medium term goal is
> > to lift d_alloc_parallel() locking above i_rwsem, so d_alloc_paralle()
> > can be run unlocked, and consequently cannot be called when ->i_rwsem is
> > held.
> >=20
> > The requires:
> >  1/ the d_alloc_parallel() not be called while i_rwsem is held.  NFS does
> >     this in a few places. New interfaces d_alloc_trylock() and d_duplicat=
e()
> >     are now available and can be used instead.
> >=20
> >  2/ a dentry must not be d_drop()ed while an operation is ongoing, as an
> >     unlocked d_alloc_parallel() would then be able to create a new
> >     dentry with the same name.  In particular d_rehash() must be phased
> >     out as it won't be safe.  Various techiniques are used to avoid the
> >     need for d_drop(), particularly that d_splice_alias() is now able to
> >     splice a hashed alias.
> >=20
> > Further, the first two patches here fixes bugs that I found while
> > developing and reviewing these changes.
> >=20
> > The patches depend on patches recently added to the vfs tree.  I would
> > prefer these land in that tree too with an Acked-by or similar from NFS
> > maintainers.
>=20
> I'm happy to take them. I just need an Ack from the nfs people.
>=20

You have an Ack from Anna for v2.

https://lore.kernel.org/all/68919e69-d97b-47a4-8695-8021f24f119c@app.fastmail=
.com/

Thanks,
NeilBrown
