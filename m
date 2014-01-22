Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:55151 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750824AbaAVAYs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Jan 2014 19:24:48 -0500
Date: Wed, 22 Jan 2014 11:24:36 +1100
From: NeilBrown <neilb@suse.de>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: varekova@redhat.com, sysstat@orange.fr,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Too many programs called nfsiostat.
Message-ID: <20140122112436.574f0e29@notabene.brown>
In-Reply-To: <A5BFEC5C-7AF2-4A7E-856F-D62F35BCEFC0@oracle.com>
References: <20130410094639.5debfc90@notabene.brown>
	<20140121144517.5f549347@notabene.brown>
	<A5BFEC5C-7AF2-4A7E-856F-D62F35BCEFC0@oracle.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/z_tT2MUYs.uiWwP1DPgI0/I"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/z_tT2MUYs.uiWwP1DPgI0/I
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 21 Jan 2014 10:40:01 -0500 Chuck Lever <chuck.lever@oracle.com> wro=
te:

>=20
> On Jan 20, 2014, at 10:45 PM, NeilBrown <neilb@suse.de> wrote:
>=20
> >=20
> > (This time without the typo in Chuck's address - sorry).
> >=20
> > Not quite a year ago I wrote:
> >=20
> > On Wed, 10 Apr 2013 09:46:39 +1000 NeilBrown <neilb@suse.de> wrote:
> >=20
> >>=20
> >> Hi all,
> >> it seems that in 2010, a program called nfsiostat was added to the sys=
stat
> >> package (http://sebastien.godard.pagesperso-orange.fr/)
> >>=20
> >> This is unfortunate because in 2008 a program called nfsiostat was add=
ed to
> >> the nfs-utils package.
> >>    (https://www.kernel.org/pub/linux/utils/nfs-utils/1.2.7/)
> >>=20
> >> The default install locations seem to be different (/usr/bin vs /usr/s=
bin),
> >> so packagers would not immediately notice.
> >>=20
> >> This seems like something that should be "fixed".
> >>=20
> >> Any suggestions what a good "fix" should look like?
> >>=20
> >> NeilBrown
> >=20
> >=20
> > No suggestions were forthcoming.
> > So I have a suggestion.
> > I propose we rename the "nfsiostat" in the "sysstat" package to
> > "nfsio-sysstat" and the "nfsiostat" in "nfs-utils" to
> > "nfs-utils-iostat".
> >=20
> > Does anyone object?  If not I'll send off patches shortly :-)
>=20
> What does the sysstat version do?  do we need two programs, or can they b=
e merged?  Or can one be dropped?
>=20

It reads /proc/self/mountstats and reports some numbers, not unlike the
nfs-utils version.

$ /usr/sbin/nfsiostat=20

eli:/home mounted on /mnt:

   op/s		rpc bklog
   3.55	   0.00
read:            ops/s		   kB/s		  kB/op		retrans		avg RTT (ms)	avg exe (ms)
		  0.000	  0.000	  0.000       0 (0.0%)	  0.000	  0.000
write:           ops/s		   kB/s		  kB/op		retrans		avg RTT (ms)	avg exe (ms)
		  0.000	  0.000	  0.000       0 (0.0%)	  0.000	  0.000
$ /usr/bin/nfsiostat=20
Linux 3.11.6-4-desktop (notabene.brown) 	01/22/2014 	_x86_64_	(8 CPU)

Filesystem:               rkB_nor/s    wkB_nor/s    rkB_dir/s    wkB_dir/s =
   rkB_svr/s    wkB_svr/s     ops/s    rops/s    wops/s
eli:/home                      0.00         0.00         0.00         0.00 =
        0.00         0.00      0.00      0.00      0.00


The man page for the sysstat version is:

http://www.makelinux.com/man/1/N/nfsiostat

while man page for nfs-utils version is:

http://linux.die.net/man/8/nfsiostat

NeilBrown

--Sig_/z_tT2MUYs.uiWwP1DPgI0/I
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBUt8PxDnsnt1WYoG5AQJEKBAAjLA3s2VOh6Ul7O8ntqaPVBWfA52rkD7Z
ymyVz+fNx1sX7B65tDlp0grjnbjgOeG4WGlbaI8DIEEAEGCkiK6SAoYbzuGKng4w
X0afBjYcXohyGkj6WWxhMQk6NPBg9TITDxd8Eyr/z3Yukv2jaWyLy32sdXp5Axo6
QH+pzMYjg62UwMksJqii5B11vT1x/qr2w4J4Eyj63rWoIx03+4+MGdRUE8yO3Ehp
R/54xQVqbzXQ6o4/BLZH3FFusIi1fYHVrOmYo4mjA6/6q1TB0Ri0zVu6b54WychQ
nFac1EtuV24Pw05GF1Og4jRRGOymbiHb29kjbhcvLbA1YBDzieNIjov3cy8sn1mm
CU3n77CuFMkpp1JquWpituWXTlbF2SlQJ1bs3z9HEcjwwRRf9uphvlBaKK+MFjIb
hrGQVSnoYpE/fl2USQGhjPevN2zJvDeo3dlL6uX7+e0/tcjrGyT/TrXKpjKI55ka
IG0jLh0X90SZYl1X6zvL0GVun0DdFkGaq48TRBZLIzZIt/dkk4fMxNJMI5w6mliP
EJjFP3mLYmmyShNQJ3B7zshnYVubT4ZIcYQUTNvIGre3ars0x52dbGIfkFdn7xUt
d/gDOZVlrQGfeyL3ZJRQdY06tTcl8sWhJ+wvsQxuM0HprKIPC6i+DcrDxhJgZqox
G/7OZdhyM+I=
=jgtt
-----END PGP SIGNATURE-----

--Sig_/z_tT2MUYs.uiWwP1DPgI0/I--
