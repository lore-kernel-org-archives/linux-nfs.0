Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2E112126BE1
	for <linux-nfs@vger.kernel.org>; Mon, 14 Sep 2026 11:54:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789386847; cv=none; b=YiqOCvF0IG3vfdZGzaRw1yx9ff+8e8vi7yK2CoVJKltVeWo0QC69baydgkVoQzTXCJJGjwEP9GQSC8zwVFjCrpUsGLcVreL+SL4HnFVo5KOAZW9bnjXAHe3sDoRVwLVdx4LSh86bidGnVqZ2q8D1ams398EC0Wy2VM2XM5iCfDA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789386847; c=relaxed/simple;
	bh=+VOrq72jWv0+9xkkY7PtzRvzhVxNhLQPQKwG/jPmsTg=;
	h=Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:MIME-Version; b=hr4ybTfXSSQOueeVdoihZlpn+b3fj7iy40XmvT1C1mJgWsLDLgrelPmfArkEBKfXpPj60Q9X6IPA+cKfRHvn2c7z7kogPry+/yBOXOYSsqMNFre4s2Qvj6dyx+RDuz4/ngqnTpPB3vkRXJaweWgIOKaZCwGe9kjS9HxMs2QSW1w=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=FXUHRST4; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="FXUHRST4"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6BBFE1F000FF;
	Mon, 14 Sep 2026 11:54:05 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789386845;
	bh=fK7DDLOIWGN84gTVlCGe0dvetzsXumlCfNVwbO9I590=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=FXUHRST40DJs8YS4UBxuLpZq4fshLHb6B0x7Q6mc0TO8ldcaTyfK55gplUAuJechv
	 aDcYo5vnH7TZDi1VMjoxrQhWoZQX1UFC1EtRo5uobZMsGEXtXnQV4t93axqxWOOned
	 dQIE8gh740eRSB2c5zt/6E1yDpKesie0gf+nySipgRKzzLcdgeeXPsmoVOKLdCBf/X
	 MfgtQTrbSRc1rygpNaUW9ursn8tKVX6NaFIfwSEXDkWfeColEfVodg41kUqrzfetOV
	 7MQM+Hbr/Os1HP85exmjFpLIhDNzKLOt4JR6fdXmjzkE06fmXWyL45aGyan0u5nlKo
	 da3mm994DvEQw==
Message-ID: <3483881f956eeafca6c31820e9609c9e8ff407b0.camel@kernel.org>
Subject: Re: [PATCH nfs-utils v2 00/10] mountd: bugfixes for up/downcall
 interfaces
From: Jeff Layton <jlayton@kernel.org>
To: Mantas =?UTF-8?Q?Mikul=C4=97nas?= <grawity@gmail.com>
Cc: Chuck Lever <cel@kernel.org>, linux-nfs@vger.kernel.org, Steve Dickson
	 <steved@redhat.com>
Date: Mon, 14 Sep 2026 07:54:04 -0400
In-Reply-To: <ef045e0b-8700-42c4-8ec6-a13cbe8d0940@gmail.com>
References: <20260911-nl-crossmnt-v2-0-f4d869951c5e@kernel.org>
	 <ef045e0b-8700-42c4-8ec6-a13cbe8d0940@gmail.com>
Autocrypt: addr=jlayton@kernel.org; prefer-encrypt=mutual;
 keydata=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
 QZIQXVeAA+smfTT0tDrisj1U5x6ZB9b3nBg65kc=
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
User-Agent: Evolution 3.60.2 (3.60.2-1.fc44) 
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0

On Mon, 2026-09-14 at 09:24 +0300, Mantas Mikul=C4=97nas wrote:
> On 11/09/2026 19.25, Jeff Layton wrote:
> > Mantas reported a problem with his configuration that was using crossmn=
t
> > and autofs to export a number of btrfs filesystems. Some analysis with
> > Claude also uncovered a few other bugs. This version also fixes a
> > number of problems that Sashiko flagged. Some of them were preexisting
> > but seemed like good things to fix.
> >=20
> > Signed-off-by: Jeff Layton <jlayton@kernel.org>
> > ---
> > Changes in v2:
> > - Retry instead of caching a negative when the failure may be transient=
:
> >    kernel errno, statfs, fsidd, and an undelivered negative fallback
> > - Drop a deferred request once it has been answered
> > - Bound the junction path copied into exportent.e_path (preexisting)
> > - Give each worker its own netlink command socket (preexisting)
> > - Bound the retry queues (preexisting)
> > - Link to v1: https://lore.kernel.org/r/20260909-nl-crossmnt-v1-0-4064b=
5a3bd85@kernel.org
> >=20
> > ---
> > Jeff Layton (10):
> >        mountd: factor out the per-path export attribute computation
> >        mountd: handle unmountable paths and junctions in the netlink do=
wncall
> >        mountd: answer requests the kernel rejects on the netlink downca=
ll
> >        mountd: don't leak the parent export's fsid onto crossmnt submou=
nts
> >        mountd: retry unresolvable fsid lookups on the netlink downcall
> >        mountd: bound the junction path before copying it into e_path
> >        mountd: give each worker its own netlink command socket
> >        mountd: retry export attributes that fail to resolve for a passi=
ng reason
> >        mountd: drop a deferred fsid lookup once it has been answered
> >        mountd: bound the retry queues
> >=20
> >   support/export/cache.c | 1331 +++++++++++++++++++++++++++++++++++++--=
---------
> >   1 file changed, 1026 insertions(+), 305 deletions(-)
> > ---
> > base-commit: 630393e9c73667b3fda6a7507cb5171ec0ec38dc
> > change-id: 20260908-nl-crossmnt-85584b71c721
>=20
> Hi,
>=20
> I finally got around to building the v2 branch, so now I've tested both=
=20
> v1 and v2 and it all seems to work well so far. It successfully exports=
=20
> ext4, btrfs, and tmpfs sub-mounts via crossmnt.
>=20
> Since I'm using a blanket export, rpc.mount does log three errors per=20
> unsupported sub-mount it encounters (proc, sys, autofsd-based /net) the=
=20
> first time it is contacted, which I suppose could be less verbose, for=
=20
> implicit sub-mount exports at least. But since my usage of exporting the=
=20
> whole of "/" (with crossmnt at that) is probably generally rare anyway,=
=20
> it is not a problem, I'll just filter them from my syslog errors monitori=
ng.
>=20
> (Is the -7 supposed to be E2BIG? If so, that seems a little odd in this=
=20
> context, but I don't know netlink well.)
>=20
> -
> rpc.mountd: Version 2.9.2 starting
> rpc.mountd: cache_nl_set_reqs: SET_REQS failed: -7
> rpc.mountd: cache_nl_set_reqs: SET_REQS failed: -7
> rpc.mountd: Cannot export /sys, possibly unsupported filesystem or fsid=
=3D=20
> required
> rpc.mountd: cache_nl_set_reqs: SET_REQS failed: -7
> rpc.mountd: cache_nl_set_reqs: SET_REQS failed: -7
> rpc.mountd: Cannot export /proc, possibly unsupported filesystem or=20
> fsid=3D required
> rpc.mountd: cache_nl_set_reqs: SET_REQS failed: -7
> rpc.mountd: cache_nl_set_reqs: SET_REQS failed: -7
> rpc.mountd: Cannot export /n, possibly unsupported filesystem or fsid=3D=
=20
> required
> rpc.mountd: cache_nl_set_reqs: SET_REQS failed: -7
> rpc.mountd: cache_nl_set_reqs: SET_REQS failed: -7
> rpc.mountd: Cannot export /net, possibly unsupported filesystem or fsid=
=3D=20
> required
> -

The -7 is an internal netlink error code (NLE_INVAL). I'll send a v3
that should fix those.

Thanks,
--=20
Jeff Layton <jlayton@kernel.org>
