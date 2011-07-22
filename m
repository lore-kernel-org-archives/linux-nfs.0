Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from vr160.rayconnect.de ([213.155.88.90]:38392 "EHLO
	mail.schwartzkopff.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752260Ab1GVLYZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Jul 2011 07:24:25 -0400
Received: from nb002.localnet (cl-1872.cgn-01.de.sixxs.net [IPv6:2001:4dd0:ff00:74f::2])
	(Authenticated sender: misch)
	by mail.schwartzkopff.org (Postfix) with ESMTPSA id 6A158129164
	for <linux-nfs@vger.kernel.org>; Fri, 22 Jul 2011 13:24:24 +0200 (CEST)
From: Michael Schwartzkopff <misch@schwartzkopff.org>
Reply-To: misch@schwartzkopff.org
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: NFSv4 grace time
Date: Fri, 22 Jul 2011 13:24:22 +0200
References: <201107211540.05673.misch@schwartzkopff.org> <20110722070742.776ae99d@tlielax.poochiereds.net>
In-Reply-To: <20110722070742.776ae99d@tlielax.poochiereds.net>
Content-Type: multipart/signed;
  boundary="nextPart17493502.tP6OnvOam0";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Message-Id: <201107221324.22512.misch@schwartzkopff.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--nextPart17493502.tP6OnvOam0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

> On Thu, 21 Jul 2011 15:40:05 +0200
>=20
> Michael Schwartzkopff <misch@schwartzkopff.org> wrote:
> > Hi,
> >=20
> > setting up a linux NFS server cluster I experience a strange problem
> > during a failover. A client can access a file only after 60 to 90
> > seconds. On the line I see a NFS4ERR_GRACE from the server to the
> > client.
> >=20
> > I already set the /proc/fs/nfsd/nfsv4leastime to 10.
> >=20
> > Any other idea?
> >=20
> > For the tests I have a simple setup:
> >=20
> > One host with a simple script that simulates failover:
> >=20
> > #!/bin/bash
> >=20
> > ip a d 1.2.3.4/24 dev eth0
> > exportfs -u *:/srv/nfs/home
> > exportfs -u *:/srv/nfs
> > /etc/init.d/nfsserver stop
> > #
> > /etc/init.d/nfsserver start
> > exportfs -o fsid=3D0,rw,crossmnt,no_root_squash *:/srv/nfs
> > exportfs -o fsid=3D1000,rw,mountpoint,no_root_squash *:/srv/nfs/home
> > ip a a 1.2.3.4/24 dev eth0
>=20
> This is normal. The grace period is there to allow clients to reclaim
> their state without other clients racing in and grabbing their locks on
> the new server, etc.

Ok. But this is the same client that cannot its own data.
=20
> You can play with /proc/fs/nfsd/nfsv4gracetime too but I'd be very
> leery of setting that too low. It should never be lower than the
> previous leasetime (see the comments on write_gracetime in the kernel).

I did already set this to 10 seconds without success. The client still has =
to=20
wait 60 seconds to access its data.

By the way: Is there a nice way to set this during startup of the nfsserver=
,=20
i.e. a mount option for nfsd?

Greetings,

=2D-=20
Dr. Michael Schwartzkopff
Guardinistr. 63
81375 M=FCnchen

Tel: (0163) 172 50 98
=46ax: (089) 620 304 13

--nextPart17493502.tP6OnvOam0
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAk4pXeYACgkQH8fVuZhm6xw5kACeJbxKfCvI40Z9qLXtJNZkxGeI
3EkAoJBTFUD86XPBizIL8yuIKcwtf51X
=wB6n
-----END PGP SIGNATURE-----

--nextPart17493502.tP6OnvOam0--
