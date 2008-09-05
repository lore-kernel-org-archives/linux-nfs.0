From: Aaron Straus <aaron-bYFJunmd+ZV8UrSeD/g0lQ@public.gmane.org>
Subject: Re: [NFS] blocks of zeros (NULLs) in NFS files in kernels >= 2.6.20
Date: Fri, 5 Sep 2008 15:14:35 -0700
Message-ID: <20080905221435.GA12911@merfinllc.com>
References: <20080905191939.GG22796@merfinllc.com> <0A24B45A-9761-4310-B1DB-B4738964E862@oracle.com> <20080905200455.GH22796@merfinllc.com> <04854041-E23D-48B5-B9FF-0B7ECEB2C371@oracle.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="17pEHd4RhPHOinZp"
Cc: Neil Brown <neilb@suse.de>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	LKML Kernel <linux-kernel@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from quackingmoose.com ([63.73.180.143]:60382 "EHLO
	penguin.merfinllc.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751646AbYIEWOg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Sep 2008 18:14:36 -0400
In-Reply-To: <04854041-E23D-48B5-B9FF-0B7ECEB2C371@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--17pEHd4RhPHOinZp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Sep 05 04:36 PM, Chuck Lever wrote:
> I have the latest Fedora 9 kernels on two clients, mounting via NFSv3 =20
> using "actimeo=3D600" (for other reasons).  The server is OpenSolaris =20
> 2008.5.
>=20
> reader.py reported zeroes in the test file after about 5 minutes.

Awesome.  Thanks for testing!  Our actime is much shorter which is
probably why it happens sooner for us.

> Looking at the file a little later, I don't see any problems with it.
>=20
> Since your scripts are not using any kind of serialization (ie file =20
> locking) between the clients, I wonder if non-determinant behavior is =20
> to be expected.

Hmm... yep.  I don't know what guarantees we want to make.   The
behavior doesn't seem to be consistent with older kernels though... so
I'm thinking it might be a bug.

We hit this particular issue because we have scripts which essentially
'tail -f' log files looking for errors.   They miss log messages (and
see corrupted ones) b/c of the NULLs.  That's also why there is no
serialization.... we don't need it when grep'ing through log messages.

I'm bisecting now.  I see a block of intricate-looking NFS patches, I'll
try to narrow it down to a particular commit. =20

I'll also get the wireshark data at that point.

					Thanks,
					=3Da=3D


--=20
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
Aaron Straus
aaron-bYFJunmd+ZV8UrSeD/g0lQ@public.gmane.org

--17pEHd4RhPHOinZp
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2.2 (GNU/Linux)

iD8DBQFIwa9Lr/o4YuvB+jgRAmvKAKDUdRcC4+2SENjQ7ZG5zDktvwmtfwCg38Cv
G/k0kYMgXmnCnQFFINZ0oP8=
=N7mJ
-----END PGP SIGNATURE-----

--17pEHd4RhPHOinZp--
