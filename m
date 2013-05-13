Return-Path: linux-nfs-owner@vger.kernel.org
Received: from zak.futurequest.net ([69.5.6.152]:57877 "HELO
	zak.futurequest.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1755286Ab3EMUXx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 May 2013 16:23:53 -0400
Date: Mon, 13 May 2013 14:22:20 -0600
From: Bruce Guenter <bruce@untroubled.org>
To: linux-nfs@vger.kernel.org
Subject: Looping NFSv4 traffic
Message-ID: <20130513202220.GA16969@untroubled.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="jI8keyz6grp/JLjh"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--jI8keyz6grp/JLjh
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable


I'm seeing repeated duplicated queries going on between a NFSv4 client
and server. Both client and server are running linux v3.9.2, but I have
observed this with other versions on both.

Wireshark decodes it as (copied by hand):

V4 Call (Reply In 3) WRITE StateID:0x1c7c Offset:0 Len:8192
V4 Reply (Call In 2) WRITE Status: NFS4ERR_OLD_STATEID

I've put a tcpdump recording up here:
http://untroubled.org/nfsv4.tcpdump.xz

This behavior seems to be most reliably triggered by using Chromium, but
I have observed it continuing even after shutting that down. I am able
to continue to use the client while this behavior is going on, albeit
with considerably reduced NFS performance.

What is going on here?

--=20
Bruce Guenter <bruce@untroubled.org>                http://untroubled.org/

--jI8keyz6grp/JLjh
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIcBAEBAgAGBQJRkUt8AAoJEFFRvcnBTTxnvQgP/0cLpZ7Kti+4XNUeSOKZCWpi
LzvwQU2cbvH1GeXK+sQDtH+klnldtLbqEw8qTSzWEdB5DGRuTIFwQ4tPGXGWcBL2
1+s3zF6Mm/drAE1qvUm3dVjk/FDLr5wn/zPdvP5auvlK5H23YsE2JslDFwsBRzDD
xR2yPnLnEh6Dpf/O+At4let/MZCl88RlCI6T24WM+89YyQgfnnpWLTuOrz2Ui1Pb
Pk2dIw6UZhOz+l8o541o0O2XRLPNmTDqEe/mgGG/e7do9xhbNR/myuOdNOLGvpbV
Ox+h3I8qwsp7ycOq/kG3EnTPmIi9F5KA7pG4mBvxOPPwCNVT4EyaMhES5EGGaBCA
E0gCdxFn/1kaTYqJt7rYY3Jd9g4cJ1K3n3V0YL3WantTa9/vwX8Ioo35YFu/5S9+
h7WAY8c4WqvvqdJkRG7wKQFXnatTVayhfDvtUziYZIj5+TuOz1XCH2bVYL1AVpgn
GsPKjZCfA+42P4fbwtTJeZjF0ugOGJ2OGGjac9hmaTpkqotBooaRXde2oWi4fUeR
baUvzoOCz0HSykR0K+4YZFY4CIVBlWrdgHQBEWnOIBXByzftxlQI/9zsxU70QtOD
aVzDLMsWiusDZFzfWx4I/wdOjh7ibJlIGlL9hhB9LTPHptzGHs7C7OEw6BEFlx8e
ncEx/WPY4nll9oaDuRAZ
=NHNC
-----END PGP SIGNATURE-----

--jI8keyz6grp/JLjh--
