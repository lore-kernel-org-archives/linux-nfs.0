Received: from fout-b7-smtp.messagingengine.com (fout-b7-smtp.messagingengine.com [202.12.124.150])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3065C30E821
	for <linux-nfs@vger.kernel.org>; Tue,  2 Jun 2026 22:53:25 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.150
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1780440808; cv=none; b=LS+OGSl752YV2cHxRur1h/pUbaXsW7lID8PAYBWFdwZceyFtpVe0x1Fo3J4iLy57Ae6MjfGRbW0Pz3LMDOIOPIlJr2k9n0b9/KIdn893jlqBc3i2gmqmP+5MYtNU+qQQiIVsL6z4cEmYPFBXz32vQDWyCb5IgbmaNhaBKZRRWZw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1780440808; c=relaxed/simple;
	bh=srYDscbjvxTyeM8NOTP7K+Gl64OT2uhk28x6DF9ZDSw=;
	h=Content-Type:MIME-Version:From:To:Cc:Subject:In-reply-to:
	 References:Date:Message-id; b=B3s5fXEKaY6avGrAPz6wNquQTO7/i3JwNyUEMh31uJiGLW+MA+P9npjIqm7AV221YsZyqF7C91LMWNnD4a1Ttt73u54ErxxGM1xHPpbCCcWLEAPRcWI7BNuCvGB59S+RT3AQXb5QJjlCKYBU1J7YGAHTPM3/YNJv8CBpEgRZsB8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=cRL1YLXR; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=QBoBGs2r; arc=none smtp.client-ip=202.12.124.150
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="cRL1YLXR";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="QBoBGs2r"
Received: from phl-compute-01.internal (phl-compute-01.internal [10.202.2.41])
	by mailfout.stl.internal (Postfix) with ESMTP id 2E9FE1D00058;
	Tue,  2 Jun 2026 18:53:24 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-01.internal (MEProxy); Tue, 02 Jun 2026 18:53:24 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to; s=fm1; t=
	1780440803; x=1780527203; bh=3GH6o4sDJpS7TnBXTaIao63CfKOEZJgejEG
	WkBXhuuc=; b=cRL1YLXRzPccvQN6FnYxM/c+oUF5PXLIW/N9nvaUB1krHcNzgjQ
	sNHH3GZ4haV3VRxUbRJgjKXaPLJpVUhoTGsk84Tl2R/gvpqkVb8wPfNgSYVwYSnn
	rgw6+f/+/BAgxhlo5NVnCVGZrW6KzFyTea9mLgmtsfHCISw5+wagHeTD1ljvOV3J
	H3pAPw/R7UjKUjQZjmR2751wkYPDzusYvENPWs3rhkDzZfG+o4/FBJru7o0rlJBl
	JDXHk0gjS+i4JxJBKf67Yqc4qERFD9fqEkWlrXIwOl0LdV8xRavVwxGsjuw1Sds6
	T+qlSiRXYUoiAFSkB1UE+C5rZ8mxh+rTUqg==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm1; t=1780440803; x=
	1780527203; bh=3GH6o4sDJpS7TnBXTaIao63CfKOEZJgejEGWkBXhuuc=; b=Q
	BoBGs2r3p6vokoxGmALE/3My9tYrToM/SMrRTyUXI3xohO3/7FmwV/s+LbopIRG+
	ZiB94e+ua6IoAJ5ZOTUltLRKUxysDNBl3lYcp6Q5/5spktLzCPuResihUmnB7Ayi
	AKuPpseUJiBVWInsipUvoty8wuuPnczoNx2OGXgVDdxmUJiuLSfnqz84d7fbamWK
	KCbfinY0eQYa7ETIefy3xKhPL/GxFqHE5EACn7MjQzmcGQkITWcnwOtXA39nArWK
	1Hz1O4vLT6TDX6v0HhP6Gsq2Jpn9KRdeWXKkLNQURhIdGDWnklmi95MZF7nocVMG
	02LMcjMSh9f/OrDK9qpEQ==
X-ME-Sender: <xms:414fauzT2I2wzv5weOhZ5jZIL4Q9QBpDgwelrrZ8cv37UsFWeCw0Zw>
    <xme:414fahQEd5xvYhLj0nznqZdF2X_LsZwfHoB2cwUpjQrFjCvTz7lgjFDAKHm0Y45cc
    935mqpjeXWXWZOg-y6zGAX3Hs09R4V8_h0Z-BFOJJGgKWu9jQ>
X-ME-Received: <xmr:414falXCsBQsgMeHRtt89O2DkAzq4qpdDET8xtxRe9-q4-jMaMnU31K2i_cq-iKFckjAc4FYjSQjsT-R7ZBPLT83ANXcsBI>
X-ME-Proxy-Cause: dmFkZTEVB0IuhCUXwRqoA2U7tPMbxcGU2Y4Y5Sh57UjaoYKdZoly5+itdGwrby9auhrf59
    ppWNlBAhOGAbbVMKssPsVYRYH+7TGbu5w60qYXN2vpSUcQUGFcANXnMAl/eb3aegrsv+yZ
    9YN8lV3YAUdp2eAfBAVPTpi8GbmcQ2OVk5zQcdgzer/2Zng5TLqEvLyDTKF61mcXTFrzXk
    Rk8IUG7Zvpg0daHFKNQUIBzhadAo0oTK79nNHk4v884Hmk7+8poEKo+kwkDUv5O76uFaYl
    ghAzX9sqW1PnIzRWQnGXUWpTM9g0SxBk2j1Bpp/aQzCeI7Zn/2QwEcyEwvwMxZG7fvRSYt
    8ghu2Yc7ceOaM/zaHMeDLrcdLXkxU4rqLGZT+sfE5WAUm/Li4WeJlGakxrboShYU+RkHAZ
    U42Nrcg/dXzfhk/JnAF7b4Uab4HrkoambZhKq8vnpdaB1ck2WPMF7sWFl6B5ta/iO6IxhQ
    nHUmX7yUedahU4IHeLiIIDuCUDb7GEQU3bXSNoct3z4N4qWeIsfegYoQiDGB70s1IEIrnj
    HF/dDTe28ppas/HtjNmghaYwUDs11ncg683DS5D93W4QQuu7MCCstUKKSxtuR94BwDo9l4
    OTyEAgmLirqqDwBzRE7MMr4ch5/tp7QO84aA/W//KLS4U+9eXwiq64qcNHAA
X-ME-Proxy: <xmx:414fajYqV1MGV9B0hVTTOPUxz6l6FXQL5u7e3Q10jzWOezWqI9aPmg>
    <xmx:414far2yEjfWhp6r2_f9ZUwLFELO1V0Lv_BBz99Obqsu0LMlnNUc-Q>
    <xmx:414falg2XjpH-S79jABodPgpV-JtwKLCDdsUT4jMDxUuZp6ZjcQtiA>
    <xmx:414favZG-2_TNGPu1Jeb_sJm4ZzzxOC3gk94tMIj9lzAJHrsEgENYg>
    <xmx:414fahTz3Zx4VTawL0Xa30wO5JK2OUmpQ9XbhpIGhsZYC4MHJtWPFfBS>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Tue,
 2 Jun 2026 18:53:22 -0400 (EDT)
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
Cc: "Benjamin Coddington" <ben.coddington@hammerspace.com>,
 "Jeff Layton" <jlayton@kernel.org>, linux-nfs@vger.kernel.org
Subject: Re: [RFC] knfsd: per-client fair scheduling to prevent single-client
 starvation
In-reply-to: <1a5c70d8-e7f4-4671-a29a-023be7c107fc@app.fastmail.com>
References: <D33770A1-9098-4F1A-93EF-590E6C0B7638@hammerspace.com>
  <473e337b-fabc-4884-a6c4-0f04b6874d0b@app.fastmail.com>
  <3AB7EB6A-B207-4B91-A695-66C4704D0E31@hammerspace.com>
  <4c5dbb98-0209-4572-8eac-1578536bbd78@app.fastmail.com>
  <AED22AED-E97D-40E3-9839-BF8307EF8B65@hammerspace.com>
  <1a5c70d8-e7f4-4671-a29a-023be7c107fc@app.fastmail.com>
Date: Wed, 03 Jun 2026 08:53:18 +1000
Message-id: <178044079821.2082204.6117918610145832039@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>

On Wed, 20 May 2026, Chuck Lever wrote:
>=20
> On Tue, May 19, 2026, at 6:02 PM, Benjamin Coddington wrote:
> > On 19 May 2026, at 14:44, Chuck Lever wrote:
> >
> >> On Tue, May 19, 2026, at 5:08 PM, Benjamin Coddington wrote:
> >>> Just to be clear - the issue I'm exploring isn't the same as when all t=
he
> >>> kNFSD threads are slow due to their workload.  This is very much a
> >>> multi-client dynamic where one client (or a group of automated client
> >>> instances) are able to easily starve another simply because they create=
 the
> >>> most connections.
> >>>
> >>> That's different from the other problem that we've discussed a bunch at
> >>> bakeathon and on the list previously.
> >>>
> >>> This is not so much a deadlock issue as it is an issue
> >>> of per-client fairness.  I think this problem is in a different class.
> >>
> >> Does dynamic svc thread creation have any impact?
> >
> > I haven't tested it - I think it would just pin to max-threads for the
> > workload in question.
>=20
> If the aggregate workload consumes all the threads, then that doesn=E2=80=
=99t
> sound like xprt scheduling is the bottleneck. But I should look at
> numbers instead of speculating.
>=20
> Are you seeing connection loss in these scenarios?
>=20
>=20
> > I'm probably not understanding you here, because for the problem I'm
> > interested in fair would look like prioritizing each client's request
> > queue equally, no matter how many xprts each client has.
>=20
> Then for NFSv4.1 and later, NFSD might schedule work on the session, and
> manage each session=E2=80=99s workload by raising and lowering the number o=
f slots
> in its slot table.

I agree that managing slot numbers is likely to be a good approach.
It doesn't make much sense to allocate to any client more slots than the
maximum number of threads - does it?

We already have code to reduce slots numbers based on memory pressure.
We could extend that to reduce based on demand compared to number of
threads.

e.g. let every client have a least one unused slot until the total slots
across all clients reaches the maximum number of threads.  Then apply
pressure evenly like we do for memory shortage.
Idle clients will get pushed back to 1 slot, active client will tend
towards a "fair" share based on how comparatively busy they are.

This wouldn't help for v3 of course but I don't think we need these
advanced features for v3.

Thanks,
NeilBrown
