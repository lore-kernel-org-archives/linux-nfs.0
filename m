Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=80.241.56.171
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793079325;
	b=q+AGo6VXyxw1IY45R86gjtuQMGpyGOUPV3y6ZfQYHSayX869Ba5T6QYMOlW03R+gXVFI
	 rgXtu+AAb+vB+xslF+iMifMZNoBg+A/Z0kk69A8pWok09BpAuauyaPPxQNKHbSUz4z1cd
	 EAneatXem/TzpVlfzBfdpy0lccwODh6g6VFrAsi2MUB7ne0tHYoqhNnp8z1ATMUgAInU7
	 CRXGBDVQub6hN9S+S8F4BfZYd9zbRx5nid7VmcaT6vw+Q1AcMOldI1HLntmw3HjIaTkSO
	 s9cDKDsmFj+qf28Bv7bu3Zay7F3fizD2d78kZhk925aFxf2MbJSwEZZTz1bvd4iWG4A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793079325;
	h=DMARC-Filter:Received:DKIM-Signature:Date:From:To:Cc:Subject:
	 Message-ID:References:MIME-Version:Content-Type:Content-Disposition:
	 In-Reply-To:X-Rspamd-Queue-Id;
	bh=pecqxhy441AdUrYYTH+JW9ncF8Dlsdnr56Yn2X9/Cwk=;
	b=KgdLcvJJ+sZGP+rrPERFkyJNIgnxVbcofcG2TMKCvrOfSlmGf1xL28Cx+Zoz7WJ2Sfig
	 4rtmB7Y63TZnX8Xa/vR7Ck0Kdyt1BIVpESvi/69rRZ97KJfo6EYCglpjRCE+GEGezCuxB
	 jcHIbpSQPGLzMDVPlw37L7TxWUp49+9ir1tmewxn2wg7miDy8lnBNYPZ1HsB/dneJBG+u
	 2oRTvlu5TDCU2bzson1HPpfTsfvezxlkmbw2yiOIIMKI18isrX4fOYtFb0fz9ark7elx+
	 WtHXjchStolWDwpqzMtm1NtWcHVvpy0RG+1lcS41wgaZ2L43SEKvKxkMO8vbB62xgsg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=cyphar.com;
	spf=pass smtp.mailfrom=cyphar.com;
	dkim=pass header.d=cyphar.com header.i=@cyphar.com header.a=rsa-sha256 header.s=MBO0001 header.b=heAP3XQj;
	arc=none smtp.remote-ip=80.241.56.171
Received: from mout-p-201.mailbox.org (mout-p-201.mailbox.org [80.241.56.171])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AFF60606A31A;
	Tue, 27 Oct 2026 05:35:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org AFF60606A31A
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=cyphar.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=cyphar.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=cyphar.com header.i=@cyphar.com header.a=rsa-sha256 header.s=MBO0001 header.b=heAP3XQj
Received: from smtp1.mailbox.org (smtp1.mailbox.org [IPv6:2001:67c:2050:b231:465::1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519MLKEM768 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by mout-p-201.mailbox.org (Postfix) with ESMTPS id 4jDK2T70cZzMlGZ;
	Tue, 27 Oct 2026 06:35:13 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=cyphar.com; s=MBO0001;
	t=1793079314;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=pecqxhy441AdUrYYTH+JW9ncF8Dlsdnr56Yn2X9/Cwk=;
	b=heAP3XQj/2C13my8Zq1fVtfEWzAwvFlv018k/Fzi93G0Tg6V2DIgs2UmR2/DjWCEYC0+Eo
	q/yk8NhDYmL8jz4W6eyjcCqggLDdQZlkfozojZxVXDFMpSj4wdaZbw2b06DH3byv4o4DkM
	l1RU0LawwMq//FDnQx6jk+rWw+eKQzic6Cz/16wTtt9oOG2ccgE+sf0ADkUlZs15C7K95B
	5p1WyW4mFb7CLXmtiGNPeWwIhW6ocNQ986u9WE78KB04PDsQTOAQKngNHZoiQHNo9HOnS6
	5JVkXUgJRdoKOKJmJYTw1/SZ5xO2/EvLikss5GwSGlRBme219e67pqpJyC9Muw==
Authentication-Results: outgoing_mbo_mout;
	dkim=none;
	spf=pass (outgoing_mbo_mout: domain of cyphar@cyphar.com designates 2001:67c:2050:b231:465::1 as permitted sender) smtp.mailfrom=cyphar@cyphar.com
Date: Tue, 27 Oct 2026 06:34:59 +0100
From: Aleksa Sarai <cyphar@cyphar.com>
To: Christian Brauner <brauner@kernel.org>
Cc: linux-fsdevel@vger.kernel.org, linux-afs@lists.infradead.org, 
	linux-nfs@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, 
	Jan Kara <jack@suse.cz>, Chris Mason <mason@kernel.org>, stable@vger.kernel.org
Subject: Re: [PATCH 0/7] proc: block mounts below /proc/<pid>/net and on the
 links into /proc/self
Message-ID: <2026-10-27-glad-unseen-agency-overture-T2ffBN@cyphar.com>
References: <20261024-work-procfs-fixes-v1-0-46b03c3a8fac@kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature"; boundary="fwq2dkicka26nbxc"
Content-Disposition: inline
In-Reply-To: <20261024-work-procfs-fixes-v1-0-46b03c3a8fac@kernel.org>
X-Rspamd-Queue-Id: 4jDK2T70cZzMlGZ


--fwq2dkicka26nbxc
Content-Type: text/plain; protected-headers=v1; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
Subject: Re: [PATCH 0/7] proc: block mounts below /proc/<pid>/net and on the
 links into /proc/self
MIME-Version: 1.0

On 2026-10-24, Christian Brauner <brauner@kernel.org> wrote:
> Nuke this crap.
>=20
> [1]: https://lore.kernel.org/r/20240806-work-procfs-v1-0-fb04e1d09f0c@ker=
nel.org
>=20
> Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
> ---
> Christian Brauner (7):
>       proc: don't let an entry below /proc/<pid>/net be a mountpoint
>       proc: don't let /proc/self and /proc/thread-self be mountpoints
>       proc: don't let /proc/mounts and /proc/net be mountpoints
>       afs: create /proc/fs/afs with proc_self_symlink()
>       nfs: create the /proc/fs/nfsfs links with proc_self_symlink()
>       proc: explain which entries can't be mountpoints
>       selftests/proc: test which entries can't be mountpoints

I love it, nuke it from orbit.

Reviewed-by: Aleksa Sarai <aleksa@amutable.com>

The proc_net_d_revalidate() thing is particularly wild, I'm surprised it
hadn't come up to us in bug reports in the past ~10 years. I guess
nobody cared enough to try to mask it?

And yeah, it's a shame we couldn't kill this entirely but I'm looking
forward to the patch you mentioned that restricts who and what can be
over-mounted.

>  fs/afs/main.c                                   |   2 +-
>  fs/nfs/client.c                                 |   4 +-
>  fs/proc/generic.c                               |  31 ++++-
>  fs/proc/internal.h                              |  18 ++-
>  fs/proc/proc_net.c                              |   2 +-
>  fs/proc/root.c                                  |   2 +-
>  fs/proc/self.c                                  |   2 +
>  fs/proc/thread_self.c                           |   2 +
>  include/linux/proc_fs.h                         |   5 +
>  tools/testing/selftests/proc/.gitignore         |   1 +
>  tools/testing/selftests/proc/Makefile           |   1 +
>  tools/testing/selftests/proc/proc-unmountable.c | 150 ++++++++++++++++++=
++++++
>  12 files changed, 208 insertions(+), 12 deletions(-)
> ---
> base-commit: 7be4bc52fd9e0e55dc9a2e0232b89427d2c4b614
> change-id: 20261024-work-procfs-fixes-8b21a6d17448

--=20
Aleksa Sarai
Founding Engineer at Amutable
https://www.cyphar.com/

--fwq2dkicka26nbxc
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iJAEABYKADkWIQS2TklVsp+j1GPyqQYol/rSt+lEbwUCauA4AhsUgAAAAAAEAA5t
YW51MiwyLjUrMS4xMiwyLDIACgkQKJf60rfpRG8zcgD4pkFLYeDZVdXN5GDUvD9c
CsEU8XPAyz89oIBWCTK5DQD8Cfps5SlaPxsKxDl/J77PthZtQSrxiN4R3gpAGYHC
qwE=
=819b
-----END PGP SIGNATURE-----

--fwq2dkicka26nbxc--
