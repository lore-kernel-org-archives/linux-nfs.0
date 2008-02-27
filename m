From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: nfs client fixup
Date: Wed, 27 Feb 2008 21:56:57 +1100
Message-ID: <20080227215657.bc2d9ed0.sfr@canb.auug.org.au>
References: <20080227165251.f3393be2.sfr@canb.auug.org.au>
	<1204100196.7327.5.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Wed__27_Feb_2008_21_56_57_+1100_GjMmNycUn3sFZ69n"
Cc: linux-next@vger.kernel.org, linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from chilli.pcug.org.au ([203.10.76.44]:50407 "EHLO smtps.tip.net.au"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753714AbYB0K5D (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 Feb 2008 05:57:03 -0500
In-Reply-To: <1204100196.7327.5.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Signature=_Wed__27_Feb_2008_21_56_57_+1100_GjMmNycUn3sFZ69n
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Trond,

On Wed, 27 Feb 2008 00:16:36 -0800 Trond Myklebust <trond.myklebust-N1bbTUo86Qc@public.gmane.org=
.no> wrote:
>
> On Wed, 2008-02-27 at 16:52 +1100, Stephen Rothwell wrote:
> >=20
> > I assume you have already found this, but the current linux-next tree
> > fails to build if CONFIG_NFS_V4 is not set and CONFIG_NFS_FS is set.
> >=20
> > s/nfs/client.c:192: error: 'struct nfs_client' has no member named 'cl_=
rpcwaitq'
> >=20
>=20
> Thanks Stephen! I assume I can add a signed-off-by line on your behalf?

Yes, but I would prefer that you fold this back into the original patch
that caused the breakage so that we don't have a bisection hole  (if that
is at all possible.

I didn't actually test (or even compile) the fix I posted as it seemed
obvious ...

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Wed__27_Feb_2008_21_56_57_+1100_GjMmNycUn3sFZ69n
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFHxUH9TgG2atn1QN8RAoHCAJ4gsKbPK+YtUAvMux4JqIdnxX8F9wCdGtBD
rp0/Fp9dHFXKLuNAd+bCJ7Y=
=qcHs
-----END PGP SIGNATURE-----

--Signature=_Wed__27_Feb_2008_21_56_57_+1100_GjMmNycUn3sFZ69n--
