From: Ruben Puettmann <ruben@puettmann.net>
Subject: Re: 2.6.X File locking on NFS stil broken
Date: Wed, 9 Jun 2004 23:24:30 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040609212430.GG29969@puettmann.net>
References: <20040609191758.GA29969@puettmann.net> <1086813672.4078.24.camel@lade.trondhjem.org> <20040609204235.GC29969@puettmann.net> <1086814428.4078.35.camel@lade.trondhjem.org> <20040609210313.GE29969@puettmann.net> <1086815623.4078.43.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="JVTRtevMO87SusWP"
Cc: linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org-S265986AbUFIV2A@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1086815623.4078.43.camel@lade.trondhjem.org>
List-ID: <nfs.lists.sourceforge.net>


--JVTRtevMO87SusWP
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Jun 09, 2004 at 05:13:43PM -0400, Trond Myklebust wrote:
> P=E5 on , 09/06/2004 klokka 17:03, skreiv Ruben Puettmann:
>=20
> > attached the strace and one tcpdump from the testprogramm.
>=20
> According to that tcpdump, the server is denying you the lock because it
> is still in its grace period.=20
>=20
> During that period only clients that held locks before the server
> rebooted are allowed to reclaim those locks. Your client will need to
> wait until that grace period is over (usually ~ 1 minute or so).
>=20

I have done a reboot on teh server ( It was up for over 315 day's ;-( )
now all runs fine seems to be an race condition. I will take a look on
it if this happend again.=20

Thanks for your help !!


                Ruben

--=20
Ruben Puettmann
ruben@puettmann.net
http://www.puettmann.net

--JVTRtevMO87SusWP
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFAx4AOgHHssbUmOEIRAtzqAKCua3s9zl7RF1UpnvDWZfWxOk7KXACg8NVf
P0ncWJ7k0oppDM97aMWqIbA=
=S8wH
-----END PGP SIGNATURE-----

--JVTRtevMO87SusWP--
