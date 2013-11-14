Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:59901 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753086Ab3KNE0b (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Nov 2013 23:26:31 -0500
Date: Thu, 14 Nov 2013 14:25:56 +1100
From: NeilBrown <neilb@suse.de>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Jim Rees <rees@umich.edu>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: please proof-read: updates to nfs.man for some missing options.
Message-ID: <20131114142556.41724d1b@notabene.brown>
In-Reply-To: <1AF110D7-1CE6-491B-85C6-F6A2692F93B6@oracle.com>
References: <20131114140244.6f7c0094@notabene.brown>
	<20131114031253.GA9522@umich.edu>
	<1AF110D7-1CE6-491B-85C6-F6A2692F93B6@oracle.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/fvvZ5aV8NrcgQXh4.NaHD0u"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/fvvZ5aV8NrcgQXh4.NaHD0u
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed, 13 Nov 2013 22:13:56 -0500 Chuck Lever <chuck.lever@oracle.com> wro=
te:

>=20
> On Nov 13, 2013, at 10:12 PM, Jim Rees <rees@umich.edu> wrote:
>=20
> > NeilBrown wrote:
> >=20
> >  +.BR addr=3D ip-address
> >  +This option is rarely used but can provide an explicit IP address of
> >  +the NFS server in cases where the server is multi-homed.
> >  +.TP 1.5i
> >=20
> > I would change "rarely used" to "usually not needed." Also I think you =
have
> > this option in here twice.

Yes I included it twice.  Once for v2+v3, once for "v4".  There are a few
other options that are given for bother rather than in the common section a=
nd
this seemed to fit better with those.

>=20
> I actually think mount.nfs may strip this option out of the list if a use=
r specifies it.
>=20

Indeed it does.  Well, I can scrape that then - thanks.

NeilBrown

--Sig_/fvvZ5aV8NrcgQXh4.NaHD0u
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUoRCxTnsnt1WYoG5AQIBhA//VtogneWPJN4sOW4Bek71mE0VmGqDmxQ/
oV8nve9TNNaM2KmHdJd5InUTATt6ODdyQeySxPkNhNL5Ox4bUMOXeEwsiByUri85
9tTQ+Hn7E2r77H7d5LJ8CVzudJj9PRZ77PdC19W9jPK05dJ3qSKNnrKAVv3A+nmN
si0n2aqOBxQtwVMmowbxJiwshJUD2RVOPGuxqbehaR9LW/Dgrw936EvYo9TpE6zd
1QHEBVfAAAugrW0M0Nf/9OsySMiEoeK1BPNlZLreQQT+mhMsqmfp6vRLnLSVR/OG
A9ZpFDBCqGxtCQjHvIt5r2uB0DOczzSI80paz0ueV87Idzsn8eYt483KspYmjEPw
lfYf24XM6P8EtOwYqLtrkp24nKAAPGMPdsiKkCqsgdclUX2jGIDYjHp2d8m+6EG4
50C6ShHMg/uIZIzu6DPj2xw0Ue4gpFgWxRfZUGY0t1sHOAkbs+PxaqRdQfWMCe0Q
Wa2xN2EXspmU6qiViMaabCfJQ9XRHgA8mguQYLnl7gMQMaPOhrUlBXPQcCZTDkuc
JQSX/GnXbUcljpYJMgcw4KDiNamQdVlzphXa9FbOP7j1s9aOuIkviQHNFVr1BGdS
WJukSyCKcuBM8snG0EvdS0HVqtLwJFu4I7/Q9bDPNV+PfwKmIDwfQAC6weMg06zo
tIJmJ5VR23g=
=zlvn
-----END PGP SIGNATURE-----

--Sig_/fvvZ5aV8NrcgQXh4.NaHD0u--
