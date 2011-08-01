Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from chilli.pcug.org.au ([203.10.76.44]:48730 "EHLO smtps.tip.net.au"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752123Ab1HAA5v (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 31 Jul 2011 20:57:51 -0400
Date: Mon, 1 Aug 2011 10:57:39 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Jens Axboe <jaxboe@fusionio.com>, Christoph Hellwig <hch@infradead.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: Please pull NFS client changes
Message-Id: <20110801105739.4dd1244f1a6f5f13e1b486b8@canb.auug.org.au>
In-Reply-To: <1312142325.7127.3.camel@lade.trondhjem.org>
References: <1312082377.10882.1.camel@lade.trondhjem.org>
	<20110731182406.GA16470@infradead.org>
	<4E35A9B1.9090309@fusionio.com>
	<1312141193.7127.1.camel@lade.trondhjem.org>
	<4E35B126.8050009@fusionio.com>
	<1312142325.7127.3.camel@lade.trondhjem.org>
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Mon__1_Aug_2011_10_57_39_+1000_xAa/oHeQzkERkSvM"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--Signature=_Mon__1_Aug_2011_10_57_39_+1000_xAa/oHeQzkERkSvM
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

On Sun, 31 Jul 2011 15:58:45 -0400 Trond Myklebust <Trond.Myklebust@netapp.=
com> wrote:
>
> How's this?
>=20
> 8<-----------------------------------------------------------------------=
---------------=20
> From e01e56eb7013a11f3e09bd8a8562332777f9e100 Mon Sep 17 00:00:00 2001
> From: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date: Sun, 31 Jul 2011 15:33:26 -0400
> Subject: [PATCH v2] NFS: Re-enable compilation of nfs with !CONFIG_NFS_V4=
 ||
>  !CONFIG_NFS_V4_1
>=20
> Fix a typo in fs/nfs/pnfs.h
> Move the pnfs_blksize declaration outside the CONFIG_NFS_V4 section in
> struct nfs_server.
>=20
> Reported-by: Jens Axboe <jaxboe@fusionio.com>
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

I have applied this the linux-next today ..

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Mon__1_Aug_2011_10_57_39_+1000_xAa/oHeQzkERkSvM
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAEBAgAGBQJONfoDAAoJEDMEi1NhKgbsTewH+gPrqxgWi3GjnhEyRbWBUVFJ
zYmhFt3tgOLeYLjc6VVAihwauJ6tzs567ztJB+NpOA6ZMdfFGS10l379dS3Z6G2Q
3D37t5zo2PsIgUp4jwONPOTF6HLHxr0ucxATufn3ZpfYzFv6pMBXARZA4cGBJkF2
fAbGTKt5G5dXL+CwdIJVHHmLVWcSjmITuHAxh0YmlfV3kq+ctixwtA7SOsSjrC/6
ov0263LM3Pay36TVM1f5LWr9CxGcM3HWeEZPjFeT1d94hwtnprU4sSTAu3ZcHS1f
1Ga3dKAaB8Ew0aEU8O03IEAcZwX8iwRywLxZFJayUZAoKxABSS4uwTUFAtEYOCE=
=GdBh
-----END PGP SIGNATURE-----

--Signature=_Mon__1_Aug_2011_10_57_39_+1000_xAa/oHeQzkERkSvM--
