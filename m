From: Ben Hutchings <ben@decadent.org.uk>
Subject: Bug#600871: nfs-common: Very slow and unreliable performance of GUI(KDE) when /home nfs mounted
Date: Wed, 27 Oct 2010 01:38:05 +0200
Message-ID: <1288136285.4010.27.camel@localhost>
References: <20101020195155.17760.31074.reportbug@cod.com>
	 <201010211145.45625.o.vasylyuk@osorno.ca>
	 <20101025204556.GP13095@decadent.org.uk>
	 <201010261059.58090.o.vasylyuk@osorno.ca>
Reply-To: Ben Hutchings <ben@decadent.org.uk>, 600871@bugs.debian.org
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-tEew+pBTmAthqFM3GOH0"
Cc: 600871@bugs.debian.org, Oleksiy Vasylyuk <o.vasylyuk@osorno.ca>
To: linux-nfs@vger.kernel.org
Return-path: <bounce-debian-bugs-dist=glddb-debian-bugs-dist=m.gmane.org@lists.debian.org>
Resent-Message-ID: <handler.600871.B600871.128813630415915@bugs.debian.org>
In-Reply-To: <201010261059.58090.o.vasylyuk@osorno.ca>
List-Post: <mailto:debian-bugs-dist@lists.debian.org>
List-Help: <mailto:debian-bugs-dist-request@lists.debian.org?subject=help>
List-Subscribe: <mailto:debian-bugs-dist-request@lists.debian.org?subject=subscribe>
List-Unsubscribe: <mailto:debian-bugs-dist-request@lists.debian.org?subject=unsubscribe>
List-ID: <linux-nfs.vger.kernel.org>


--=-tEew+pBTmAthqFM3GOH0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Oleksiy Vasylyuk reported severe performance degradation of KDE on an
NFS client on Linux 2.6.26 after upgrading nfs-utils from version 1.1.2
to 1.2.2.  Some additional details are logged at
<http://bugs.debian.org/600871>.

Does anyone recognise this problem, or can someone suggest how to
investigate further?

Ben.

--=20
Ben Hutchings
Once a job is fouled up, anything done to improve it makes it worse.

--=-tEew+pBTmAthqFM3GOH0
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIVAwUATMdmV+e/yOyVhhEJAQIvWw//fqvNwG2PvyN2b+tKsVkiYxy1dedd49Pv
SVxlZvcagz/YCQVW5C5S904hkZcVb/anIOLRUJIHi1g/k7C4yjwsr3z7Om0CzNko
jqn5LB+jQ1YfBAP47+Zd99Jfr3No9IZekdhLIsB1XMOcWD3j00hJvMDxQpCd765v
OjHwzZ15SVu1WFtdaZG3X8DyPRXdb9JfQAYMP6umu+8owBcbsp82SJsSRcaxKvcl
UkIiYBEs7kCcnahhQ/tYP8L296XBMcwHgt2kjkq7RnNgl0MoKmWAVo/2oCMGaVkQ
ps3ApimkefZZ5RbBEjhjDWgR9XiAyptX5h/DVaPlz1Ajqgjd57STBHa+6WycyxHn
PoY4cNTdTKY7miBO6/MmkDupQyz25BjWP6ogBnRoMhPHShgBbim8FB5x2ZDAtO47
Ra+FkIHsqH6zVLnnrFXoOwPew0W3vD5w4AV8AP7D6o1axdcYfz0Epeoc8KLvS0CS
cpwoHxoW6SxDly535R5cJ7IjF2QvsmIdnfOgljl+F+bXnr0H/Xm6CbcgdW1HEblz
Mw+zuBr9c49znNsiSbGO5d68hpPVwjdje7wTJo+uAe99lH5CVT87bX0j5wvqHsxE
2C/QzC7XQDZdLOawtANLA03NhEwzSNsVBp0v/E9XuV85OJD679i5yNAGkWMPo6SN
U01lfmfCXsA=
=sMEo
-----END PGP SIGNATURE-----

--=-tEew+pBTmAthqFM3GOH0--
