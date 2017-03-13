Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailapp01.imgtec.com ([195.59.15.196]:26918 "EHLO
        imgpgp01.kl.imgtec.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752135AbdCMJsB (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Mar 2017 05:48:01 -0400
Date: Mon, 13 Mar 2017 09:47:57 +0000
From: James Hogan <james.hogan@imgtec.com>
To: Matt Turner <mattst88@gmail.com>
CC: "linux-mips@linux-mips.org" <linux-mips@linux-mips.org>,
        <linux-nfs@vger.kernel.org>, Manuel Lauss <manuel.lauss@gmail.com>,
        LKML <linux-kernel@vger.kernel.org>
Subject: Re: NFS corruption, fixed by echo 1 > /proc/sys/vm/drop_caches --
 next debugging steps?
Message-ID: <20170313094757.GI2878@jhogan-linux.le.imgtec.org>
References: <CAEdQ38HcOgAT6wJWWKY3P0hzYwkBGSQkRSQ2a=eaGmD6c6rwXA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="ev7mvGV+3JQuI2Eo"
In-Reply-To: <CAEdQ38HcOgAT6wJWWKY3P0hzYwkBGSQkRSQ2a=eaGmD6c6rwXA@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--ev7mvGV+3JQuI2Eo
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sun, Mar 12, 2017 at 06:43:47PM -0700, Matt Turner wrote:
> On a Broadcom BCM91250a MIPS system I can reliably trigger NFS
> corruption on the first file read.
>=20
> To demonstrate, I downloaded five identical copies of the gcc-5.4.0
> source tarball. On the NFS server, they hash to the same value:
>=20
> server distfiles # md5sum gcc-5.4.0.tar.bz2*
> 4c626ac2a83ef30dfb9260e6f59c2b30  gcc-5.4.0.tar.bz2
> 4c626ac2a83ef30dfb9260e6f59c2b30  gcc-5.4.0.tar.bz2.1
> 4c626ac2a83ef30dfb9260e6f59c2b30  gcc-5.4.0.tar.bz2.2
> 4c626ac2a83ef30dfb9260e6f59c2b30  gcc-5.4.0.tar.bz2.3
> 4c626ac2a83ef30dfb9260e6f59c2b30  gcc-5.4.0.tar.bz2.4
>=20
> On the MIPS system (the NFS client):
>=20
> bcm91250a-le distfiles # md5sum gcc-5.4.0.tar.bz2.2
> 35346975989954df8a8db2b034da610d  gcc-5.4.0.tar.bz2.2
> bcm91250a-le distfiles # md5sum gcc-5.4.0.tar.bz2*
> 4c626ac2a83ef30dfb9260e6f59c2b30  gcc-5.4.0.tar.bz2
> 4c626ac2a83ef30dfb9260e6f59c2b30  gcc-5.4.0.tar.bz2.1
> 35346975989954df8a8db2b034da610d  gcc-5.4.0.tar.bz2.2
> 4c626ac2a83ef30dfb9260e6f59c2b30  gcc-5.4.0.tar.bz2.3
> 4c626ac2a83ef30dfb9260e6f59c2b30  gcc-5.4.0.tar.bz2.4
>=20
> The first file read will contain some corruption, and it is persistent un=
til...
>=20
> bcm91250a-le distfiles # echo 1 > /proc/sys/vm/drop_caches
> bcm91250a-le distfiles # md5sum gcc-5.4.0.tar.bz2*
> 4c626ac2a83ef30dfb9260e6f59c2b30  gcc-5.4.0.tar.bz2
> 4c626ac2a83ef30dfb9260e6f59c2b30  gcc-5.4.0.tar.bz2.1
> 4c626ac2a83ef30dfb9260e6f59c2b30  gcc-5.4.0.tar.bz2.2
> 4c626ac2a83ef30dfb9260e6f59c2b30  gcc-5.4.0.tar.bz2.3
> 4c626ac2a83ef30dfb9260e6f59c2b30  gcc-5.4.0.tar.bz2.4
>=20
> the caches are dropped, at which point it reads back properly.
>=20
> Note that the corruption is different across reboots, both in the size
> of the corruption and the location. I saw 1900~ and 1400~ byte
> sequences corrupted on separate occasions, which don't correspond to
> the system's 16kB page size.
>=20
> I've tested kernels from v3.19 to 4.11-rc1+ (master branch from
> today). All exhibit this behavior with differing frequencies. Earlier
> kernels seem to reproduce the issue less often, while more recent
> kernels reliably exhibit the problem every boot.
>=20
> How can I further debug this?

It smells a bit like a DMA / caching issue.

Can you provide a full kernel log. That might provide some information
about caching that might be relevant (e.g. does dcache have aliases?).

Cheers
James

--ev7mvGV+3JQuI2Eo
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCAAGBQJYxmrGAAoJEGwLaZPeOHZ6f3IP/Am5NSzZnkBChs3z0bpCai5V
e7HoDsZaZl57hxeuMgs2YMUvqVKqZHKwug2ZtTPeJXdrkzKmc29HhphoDdjAchb8
eqtXsobKSXTorr4WF7OfFR7udNgLQPR013+QaUyErH6ffP5eBiuUgwJSjeFv+RZF
jN4NbU23W/FkrB7IFGQM4+dyeBH6QfXysNmFLvCvs3T16vOtJlIvQmPMG3LG4KwL
QTGP2eLf09PnBoh6b1W/ZMnvpF+zxazXsSPtH1MOOLtCNdKJ4OStABfjVUBdMLKu
qs9AN2k5Jvk4icEE0r4TOJW9qbj8lsBYHsbprkUM1J2CSKT/NHpKpflxf1zyih0L
BFnRc8XtTTzHVW3URgVU43g/18TJnC55CTwSTgLfcxDH4hS74pOzZtNh2E8oSwBr
oKp03H6nKrHssAdsWjCGXwR0fE0cYXw4spAwoPVwt8DiTrIHtC1iYGTu8UlIcJYU
8mmT/r/d1YvfYnY3Ewd3Sxmv4MQypYA4qftfL7a6JEWnxWZr1yytJ+Uj1iyZqStk
Vmys90Iu/X4G8jvRs5s8ZDiHYt+s/HQEAdZp9lmAWTWviWmwT8n0W2GTDION/QCC
YNQAO37ef4fXX8j/wqK/92GwCj0PPt+p7gp9djG4Eiy4+CQsQY12j7vF9QxDP361
/cDqMwMqg3O+eXuM3GIn
=UVuQ
-----END PGP SIGNATURE-----

--ev7mvGV+3JQuI2Eo--
