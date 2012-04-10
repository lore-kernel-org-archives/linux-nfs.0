Return-Path: linux-nfs-owner@vger.kernel.org
Received: from vr160.rayconnect.de ([213.155.88.90]:58275 "EHLO
	mail.schwartzkopff.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756552Ab2DJSXl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Apr 2012 14:23:41 -0400
From: Michael Schwartzkopff <misch@schwartzkopff.org>
Reply-To: misch@schwartzkopff.org
To: linux-nfs@vger.kernel.org
Subject: Re: NFSv4 high availability setups
Date: Tue, 10 Apr 2012 20:14:48 +0200
References: <20120405103124.GV4752@ics.muni.cz> <20120410125552.GC5074@ics.muni.cz> <20120410091321.1be1a87e@tlielax.poochiereds.net>
In-Reply-To: <20120410091321.1be1a87e@tlielax.poochiereds.net>
Cc: Lukas Hejtmanek <xhejtman@ics.muni.cz>
MIME-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1377581.TqGBSBRntR";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Message-Id: <201204102014.48624.misch@schwartzkopff.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--nextPart1377581.TqGBSBRntR
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

> On Tue, 10 Apr 2012 14:55:52 +0200
>=20
(...)
> > > > Can we put this state dir on a shared volume so that this state dir
> > > > is common for all the front-ends serving the same content? Is is
> > > > supposed to work and NFSv4 can merge its state with existing state
> > > > on a shared disk?
> > >=20
> > > Not properly, no. nfsd expects to have complete control over that
> > > directory. There's no locking or merging of the data there. A node wi=
ll
> > > also clean that directory out in some cases, and that will throw your
> > > state tracking off.
> >=20
> > Thank you for information.
> >=20
> > Is there any (preferably simple) way to demonstrate that this does not
> > work properly? E.g., if I share the same export through two or more
> > NFSv4 front-ends that share the v4recovery directory, do I trigger
> > problems with this tool
> > http://nfsv4.bullopensource.org/tools/tests/locktest.php?
>=20
> Nope. It'll all work just great...until it doesn't. I don't have any
> specific failure scenarios, but most of the problems will be issues
> with state recovery when a server node is restarted.
>=20
> That may manifest in different ways -- problems reclaiming locks for
> instance, or even silent data corruption depending on the application.
>=20
> For instance, a node might hand out a lock and the client release it,
> after a server node reboots but before a client that really "owns" it
> reclaims it. Depending on the application, that may cause serious
> problems.

Hi,

I don't think a active/active NFS server is possible with=20
/var/lib/nfs/v4recovery on a shared media. I think you will get into major=
=20
trouble if two or more nodes access that directory at the same time.

On the other hand an active/passive setup is quite easy. There are some HOW=
TOs=20
on the internet. I like the one of linbit most:
http://www.linbit.com/de/training/tech-guides/highly-available-nfs-with-drb=
d-
and-pacemaker/

The guide provides a basic path to follow. You have to tune it according to=
=20
which distribution you use. Not all distributions have the necessary featur=
es.

See: leasetime, grace time, ...

Greetings,
=2D-=20
Dr. Michael Schwartzkopff
Guardinistr. 63
81375 M=FCnchen

Tel: (0163) 172 50 98
=46ax: (089) 620 304 13

--nextPart1377581.TqGBSBRntR
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAk+EeJgACgkQH8fVuZhm6xxpDQCdGKfA+1hjsyOGg+LVYCHxalTN
pLEAn1tdGDdS0feTEh4k71IbqV6cGiPC
=UxHw
-----END PGP SIGNATURE-----

--nextPart1377581.TqGBSBRntR--
