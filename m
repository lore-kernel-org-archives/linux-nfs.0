From: Aaron Straus <aaron-bYFJunmd+ZV8UrSeD/g0lQ@public.gmane.org>
Subject: Re: [NFS] blocks of zeros (NULLs) in NFS files in kernels >= 2.6.20
Date: Fri, 5 Sep 2008 17:03:51 -0700
Message-ID: <20080906000351.GE12911@merfinllc.com>
References: <20080905191939.GG22796@merfinllc.com> <0A24B45A-9761-4310-B1DB-B4738964E862@oracle.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="RpqchZ26BWispMcB"
Cc: Neil Brown <neilb@suse.de>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	LKML Kernel <linux-kernel@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from quackingmoose.com ([63.73.180.143]:45266 "EHLO
	penguin.merfinllc.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751607AbYIFADv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Sep 2008 20:03:51 -0400
In-Reply-To: <0A24B45A-9761-4310-B1DB-B4738964E862@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--RpqchZ26BWispMcB
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sep 05 03:56 PM, Chuck Lever wrote:
> > I can try to bisect between 2.6.19 <-> 2.6.20.
>=20
> That's a good start.

Hi,

OK.    Bisected.

This is the commit where we start to see blocks of NULLs in NFS files.

e261f51f25b98c213e0b3d7f2109b117d714f69d is first bad commit
commit e261f51f25b98c213e0b3d7f2109b117d714f69d
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Dec 5 00:35:41 2006 -0500

    NFS: Make nfs_updatepage() mark the page as dirty.
   =20
    This will ensure that we can call set_page_writeback() from within
    nfs_writepage(), which is always called with the page lock set.
   =20
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>



					Thanks,
					=3Da=3D



--=20
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
Aaron Straus
aaron-bYFJunmd+ZV8UrSeD/g0lQ@public.gmane.org

--RpqchZ26BWispMcB
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2.2 (GNU/Linux)

iD8DBQFIwcjmr/o4YuvB+jgRAkFpAKDwFy4suG3fDVj9cdeidhWJcZ3obgCg43yF
g0Aat8IFtXE0yjOzxOwARNc=
=xXb5
-----END PGP SIGNATURE-----

--RpqchZ26BWispMcB--
