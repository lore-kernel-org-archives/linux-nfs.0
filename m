Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 74658494832
	for <linux-nfs@vger.kernel.org>; Fri,  4 Sep 2026 13:10:09 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788527411; cv=none; b=llOnzFkVWPKpPm525JBr99AMmW4X24PnPOnHaACYKMhd4fVkPwxu42xZP5juFfS/bwV2P5q++W4UT+uOKi7NRs7waQpaintgSxoSKHypYTXDbx2Qa+ylmYfMPFxSGvyakmqcB7rQYPhXQyQA+g35bu5jlbfolLlyHaruV36y77A=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788527411; c=relaxed/simple;
	bh=07WAM1SfjOXKV0WA0TwbLd8Yy1QpCX1zVyf9xGCo5KI=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=t2P53QKRqZjHk9Bp+60iducukaFA393aGjqqowoKRqNWFVeHOvhPFDdnWSbxNItWa1AfnB0VgPOb4XtxGPR65MOAG4Ba+yWAKTmGS8JIkm7VovwKiqjCA/lrOtTzukccYFwXOWUiLLO8CQ6ttomHo4YaqcXxNtD1/UUI5M/BnZE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Bf3MFPLM; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Bf3MFPLM"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D96861F00A3F;
	Fri,  4 Sep 2026 13:10:08 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788527409;
	bh=07WAM1SfjOXKV0WA0TwbLd8Yy1QpCX1zVyf9xGCo5KI=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=Bf3MFPLMgJ2DQesHLlSJb9aDVkS+Usu6Q9leJY1kL6PenJ3MeVxglGqnWamkY0Xbm
	 iXxAVKBZlcQLDGEMkqcQpciVoruoz++mOxfIMn5/+inwWhx/94x6k1TMyR2py1j1ui
	 /A0Ki0AHm3ecdWS3E9MSMRqMQFPDPWwjAGYuKcyV9ZuD8avPkCms6Wtvo9lJ+ujjlc
	 yR5ZmXv2q3r7tSAmvLgFAf/hTHQq+IBiQSVI6gyNYvZ0xF8JaFQpz2jA25Qlaq6S6G
	 eKogJ/Cm//8lnpaokmL08lC7bh7HLiPyKAqtbbbD+dwe6ORq0QGNLdVrCG+bAMi0lf
	 pRSvUgVMNVN0g==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id EAB6EF40066;
	Fri,  4 Sep 2026 09:10:07 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Fri, 04 Sep 2026 09:10:07 -0400
X-ME-Sender: <xms:L8Oaagi9WWKK5RJI-fcSCEIx1D3k9ex1X5UJ62mnuFe3VC0NV6duWg>
    <xme:L8Oaaj2A-Y5o-xamteP3-LaKmORrguOx4KV8QKTfMzXgcJyWtkMTaX7KJ9C-N4Ur2
    UdbKUtfr1z8clmtgyjHH3eX4FjFxHNlUZGPGbbijECS6DfAI8-PqspU>
X-ME-Proxy-Cause: dmFkZTG3Hr5U8nL9jz62ZL93FO6z18bs2jb882+m+rBBuUiAAdw/C36HqM8Z6wp9AjT65u
    sG8zrQlSZD5cjtaGZ2czfNpbrQ+5rNQ+X93USqIweUdGNjOtehYLlCZyVIH015Dh41eCHW
    U6BTVR15G0bdyBQyFpPeYoSsrcRSVoIwWkCPwOzR4lfzAHR79uZanEfjD05EGT26m5v8/H
    59hj9zsjFOAvP4dLyzHYUycKbzW3mX1pQng811ClDWg5fBXl+XgQ8vDKahIt06KoSVvT/8
    xrdBbr9lWNklv87woii/HDVovmGRBHG3OdzoXugkOOhhzPdYcRC815E8MNKowdTR8/oJIa
    r4BmKijPvhwtROWW/7EdOt+fJapeKCOpOwxuH1d6XYdVcdYjtaXH/FFeBcvY95adTElqWu
    FKsVrG5vn/K8LslM2x0XMHiOcRWiFezo3/fkwdmAZBWFrEXH4zynD5twqMnwWw2QyNJoor
    UfwKl6on6iZO8eQG/l4JY1b8BLj0EFNuruLL7CYsNECqq5LDnF3wAdDoIXmeoGKXas0ybO
    rQokFy9H1ZsJgBFOfWoNHee2rtrgadaXD++cmTooxiexWFI+e82gmE8Yk9OO4L33I+yqaD
    K9V+Hb3BH3g50S8WV/Eh/0XnWEGTKfkQIuZIVxX0LJCYdzxePy9JPEskzdZA
X-ME-Proxy: <xmx:L8OaauVze4D8urO4NlGW7LXDxykaeMJ_2v9xEqRmOingKUWEplW-Wg>
    <xmx:L8OaauRXPQOh272f92d48hp_MmwGVxe3iT0LsDDoqpzq5-qID9C82A>
    <xmx:L8OaasOeCIXhqJ7-k78pmSqEOimX30rUEj-2jHyp7NhkysJEEBsqJA>
    <xmx:L8OaasQ6AL2rkOpATskfVHX5T9d365Ji1OUnoqsSZ0ti3cxj6TNfJA>
    <xmx:L8OaaqjsCjlKnVNVfJB3PuktpGb0LsYhYwr9Ok1naNFI7JtMvEnvPirx>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id BFC8F7811F4; Fri,  4 Sep 2026 09:10:07 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AXS_LISVHZGo
Date: Fri, 04 Sep 2026 09:09:47 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Benji Wiebe" <itsme@benjiwiebe.com>, "Jeff Layton" <jlayton@kernel.org>
Cc: "Linux kernel regressions list" <regressions@lists.linux.dev>,
 linux-nfs@vger.kernel.org, stable@vger.kernel.org
Message-Id: <c734eeb8-8486-4491-bb4d-b9656cbaffbe@app.fastmail.com>
In-Reply-To: <c3d06b9f-7da5-479f-be4f-9c0136631ce9@oracle.com>
References: <c26ff09f-48d6-4ef3-9feb-8a8e6d6f37ba@benjiwiebe.com>
 <c3d06b9f-7da5-479f-be4f-9c0136631ce9@oracle.com>
Subject: Re: [REGRESSION] reads and writes hang if NFS server has v3 disabled
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

[ Adding correct addresses from MAINTAINERS ]

On Fri, Sep 4, 2026, at 9:05 AM, Chuck Lever wrote:
> I'm using a minimal Fedora 45 VM (kvm) for testing.=E2=80=8A=C2=A0 I e=
xport a
> directory with rw and mount it from my personal computer running Fedora
> 45 as well. If /etc/nfs.=E2=80=8Aconf has vers3=3Dn, then reads and wr=
ites hang in
> D+ state, and there's a continuous
>
>
> I'm using a minimal Fedora 45 VM (kvm) for testing.=C2=A0 I export a=20
> directory with rw and mount it from my personal computer running Fedor=
a=20
> 45 as well.
> If /etc/nfs.conf has vers3=3Dn, then reads and writes hang in D+ state=
,=20
> and there's a continuous loop of V3 NULL calls, with the server replyi=
ng=20
> that it only supports v4.
> If nfs.conf has vers3=3Dy, then the reads and writes succeed.
> Introduced in 70b7e3526c53d9dd, still present in the latest=20
> mainline/master (841e384b841a).
>
> The hung state can be rescued by changing the setting and restarting=20
> nfs-server, at which point the read/write will complete.
>
> I can do more testing / get more information as needed.
>
> Here's links to pcap files with it working/bugged:
> http://grepper.net/lkml-files/nfs-working.pcap
> http://grepper.net/lkml-files/nfs-bugged.pcap
> http://grepper.net/lkml-files/nfs-bug-kernel.config
>
> #regzbot introduced:=C2=A0 70b7e3526c53d9dd7caccdbeff5b0485640d8cf1

It's not immediately obvious to me why 70b7e3526c53d9dd should
cause this kind of behavior regression.

Jeff, it's a netlink change. Can you triage?


--=20
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
