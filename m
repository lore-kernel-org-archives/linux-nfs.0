Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:53937 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756409Ab0H3SBL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Aug 2010 14:01:11 -0400
From: Mike Frysinger <vapier@gentoo.org>
To: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: `rpc.nfsd #` gets hung up when loopback iface is down
Date: Mon, 30 Aug 2010 14:00:31 -0400
Cc: NFS list <linux-nfs@vger.kernel.org>
References: <201008281646.44883.vapier@gentoo.org> <4C2340A7-5500-455D-AA22-60ABCC2324DB@oracle.com>
In-Reply-To: <4C2340A7-5500-455D-AA22-60ABCC2324DB@oracle.com>
Content-Type: multipart/signed;
  boundary="nextPart1697401.cKBXM4ku84";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Message-Id: <201008301400.32473.vapier@gentoo.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--nextPart1697401.cKBXM4ku84
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

On Monday, August 30, 2010 13:03:16 Chuck Lever wrote:
> On Aug 28, 2010, at 4:46 PM, Mike Frysinger wrote:
> > is it expected behavior that `rpc.nfsd #` gets hung up whenever the
> > loopback interface hasnt been configured ?  even `rpc.nfsd 0` which
> > seems a bit odd.=20
>=20
> NFS doesn't work without lo being configured.  We don't test that scenari=
o,
> normally, so I wouldn't say specifically that we expect this particular
> behavior.  However, since rpc.nfsd might require the kernel to use the
> local portmapper, yes, it probably will hang without "lo".
>=20
> We had a similar report earlier this year on client side misbehavior when
> lo was not configured.  It was a root-on-NFS situation where an NFS mount
> was done before networking was fully configured.
>=20
> The kernel's portmapper client now uses TCP to contact the local portmapp=
er
> so that it can detect immediately when there is no local portmapper
> running.  Normally, if a physical interface is down, operations on a TCP
> socket will fail.  Apparently this has never been the case for "lo".
>=20
> Usually our solution to this problem is "Don't try to use NFS without lo"=
=2E=20
> But please let us know what your use case is.

i had a user who attempted to start nfs services but had removed the net.lo=
=20
service (presumably by accident).  i just told them "dont do that".  so i d=
ont=20
have a real use case that demands no loopback interface.  just making upstr=
eam=20
aware of possible bugs.
=2Dmike

--nextPart1697401.cKBXM4ku84
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.16 (GNU/Linux)

iQIcBAABAgAGBQJMe/HAAAoJEEFjO5/oN/WBtSMP+wQ30cMMptrgFADFXLL0AYno
zqeThaE+EGU9xhhXT5NvB1HXEv+G0n4LuJxVxNQclFeE2sPqT8sqE+HO3OZdTlzi
XWNIYeTwQo1oXNxHqyspyC74y6DVyIxRigSnt0Pk9V75fT1o/ibtiWSThJUEy7GQ
Vo/6p+3TeepXcMt9rGXbNr6iv2dBJaB05Kqhb/fxz7wPwe7GCOZ3NwR9FP+14jKt
82Kgn5NsokTZ2Vwll5Uh/TnxzaKusi92qNUAimpvVaik7tbtpekToPXPIGi3nUmK
2s2klcnwgrowaI3nDgoG4zgu9PWOE+b2MqXXK1JrL1//aa/0QPyQ0s9ASWgkz8rl
EMJPVveQf7gHPzCQbQuzGAVXOra2ifCcXzlR26b87pfpsAfy6wrYnH391kpiw/UI
t5SyXs9dhXSIDA89ai3o9qqeces6CDkKb+aB/KNX0Dw6iyi+ZDqwYnM4VDd6DRV0
2m0AuC6mFbTJW+s4LUNf0PypI3RSwEB7eoSGPRT3g7nfZFBw7Y0HW9DuLbIRBX7C
0amOWGUqG3r/HLEATVw9zTqEVScNkWRZwrOHvmmhhg+RbGp9TeI3qB4dgLKM9OKc
mQiv28hyknadTllrN4d0zEiC5y6OpSznvU5aLcozuKUPl71SaEj12BkV/rfwcn3f
Ma8umKlnK/hqX1eqNMen
=843T
-----END PGP SIGNATURE-----

--nextPart1697401.cKBXM4ku84--
