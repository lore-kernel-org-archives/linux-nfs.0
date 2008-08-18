From: Athanasius <link-QVNlIYdkypLYtjvyW6yDsg@public.gmane.org>
Subject: Re: NFS regression?  Odd delays and lockups accessing an NFS export.
Date: Tue, 19 Aug 2008 00:13:40 +0100
Message-ID: <20080818231340.GP20684@miggy.org>
References: <p6lha4te54h04qdbnos1mcemdmn1cfca6s@4ax.com> <20080818185048.GO20684@miggy.org> <48A9CF89.9090304@bellsouth.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="byLs0wutDcxFdwtm"
Cc: Grant Coady <gcoady.lk@gmail.com>,
	linux-kernel <linux-kernel@vger.kernel.org>, neilb@suse.de,
	bfields@fieldses.org, linux-nfs@vger.kernel.org
To: jacliburn-Bdlq13kUjeyLZ21kGMrzwg@public.gmane.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pond.fysh.org ([166.84.7.109]:39984 "EHLO pond.fysh.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752245AbYHRXNm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 Aug 2008 19:13:42 -0400
In-Reply-To: <48A9CF89.9090304-Bdlq13kUjeyLZ21kGMrzwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--byLs0wutDcxFdwtm
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Aug 18, 2008 at 02:37:45PM -0500, J. K. Cliburn wrote:
> Athanasius wrote:
> >  I wonder if this is what I've been seeing.  I've been otherwise too
> >busy to properly report it, thinking that *someone* else must also be
> >seeing it and it's being worked on, else it's a subtle configuration
> >problem my end.
> >
> >  I first started seeing this with 2.6.26 on the client end,=20
>=20
> I see you're running the atl1 driver on your client.  I'm chasing an=20
> intermittent bug in that driver that seems to be affected by certain=20
> offload parameters.  Try disabling TSO and see if things improve.
>=20
> ethtool -K eth0 tso off
>=20
> Let me know if it helps.

  Indeed it does, and indeed tso was on by default.  I booted up once
after first trying this, thinking I had things set to apply it
automatically, but hadn't and ran into the exact same problem.  This 2nd
time around with the setting definitely applied things appear to be
working normally.  At least I can actually start Firefox up and have it
work (lots of /home/users/... access over NFS to the server).

thanks,

-Ath
--=20
- Athanasius =3D Athanasius(at)miggy.org / http://www.miggy.org/
                  Finger athan(at)fysh.org for PGP key
	   "And it's me who is my enemy. Me who beats me up.
Me who makes the monsters. Me who strips my confidence." Paula Cole - ME

--byLs0wutDcxFdwtm
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFIqgIkSEDmQuIYzh0RApx2AJ4m2Sh3BWGlE9PUygG4bOQ2Cs8kJwCfdr3J
bOtWRC2AUJ8WOH5q4SDrkHU=
=aw7P
-----END PGP SIGNATURE-----

--byLs0wutDcxFdwtm--
