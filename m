From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: A unresponsive file system can hang all I/O in the system on
	linux-2.6.23-rc6 (dirty_thresh problem?)
Date: Fri, 28 Sep 2007 11:12:09 +0200
Message-ID: <1190970729.31636.29.camel@twins>
References: <92cbf19b0709272332s25684643odaade0e98cb3a1f4@mail.gmail.com>
	 <20070927235034.ae7bd73d.akpm@linux-foundation.org>
	 <1190962752.31636.15.camel@twins>
	 <92cbf19b0709280127yba48b60wfe58e532944894ca@mail.gmail.com>
	 <1190968800.31636.26.camel@twins>
	 <92cbf19b0709280201o3778f945mf1d8d61cbb3d0558@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-zm6ysXZgiOYQu9hXaqPx"
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-pm <linux-pm@lists.linux-foundation.org>,
	lkml <linux-kernel@vger.kernel.org>, nfs@lists.sourceforge.net
To: Chakri n <chakriin5@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760426AbXI1JMZ@vger.kernel.org>
In-Reply-To: <92cbf19b0709280201o3778f945mf1d8d61cbb3d0558@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>


--=-zm6ysXZgiOYQu9hXaqPx
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, 2007-09-28 at 02:01 -0700, Chakri n wrote:
> Thanks for explaining the adaptive logic.
>=20
> > However other devices will at that moment try to maintain a limit of 0,
> > which ends up being similar to a sync mount.
> >
> > So they'll not get stuck, but they will be slow.
> >
> >
>=20
> Sync should be ok, when the situation is bad like this and some one
> hijacked all the buffers.
>=20
> But, I see my simple dd to write 10blocks on local disk never
> completes even after 10 minutes.
>=20
> [root@h46 ~]# dd if=3D/dev/zero of=3D/tmp/x count=3D10
>=20
> I think the process is completely stuck and is not progressing at all.
>=20
> Is something going wrong in the calculations where it does not fall
> back to sync mode.

What kernel is that?


--=-zm6ysXZgiOYQu9hXaqPx
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBG/MVpXA2jU0ANEf4RApYXAJ4pMrfaOLkfqxvL2jwsJbmKqGSElwCfSljX
VUTEF8+u/t4ll3T9b5KJeHc=
=eO/D
-----END PGP SIGNATURE-----

--=-zm6ysXZgiOYQu9hXaqPx--
