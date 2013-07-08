Return-Path: linux-nfs-owner@vger.kernel.org
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:46997 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753321Ab3GHBNJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 7 Jul 2013 21:13:09 -0400
Message-ID: <1373245980.3428.46.camel@deadeye.wl.decadent.org.uk>
Subject: NFS 'readdir loop' error on JFS
From: Ben Hutchings <ben@decadent.org.uk>
To: jfs-discussion@lists.sourceforge.net, linux-nfs@vger.kernel.org
Cc: Karl Schmidt <karl@xtronics.com>, 714974@bugs.debian.org,
        Jonathan McDowell <noodles@earth.li>
Date: Mon, 08 Jul 2013 02:13:00 +0100
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-EpPMwlpJ/bmYeDUy/zoz"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-EpPMwlpJ/bmYeDUy/zoz
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Jonathan McDowell and Karl Schmidt reported that when sharing a JFS
filesystem through NFS and Samba, NFS clients can report 'readdir loop'
and the directories in question then appear to have duplicate entries on
the client system.

This was seen with Linux 3.2 on the server and client.  The JFS
directory code is basically unchanged since then, but NFS has changed
somewhat.

The original bug reports were:
http://bugs.debian.org/685407#85
http://bugs.debian.org/714974

The log messages are:
[593351.877678] NFS: directory fs/nfsd contains a readdir loop.Please conta=
ct your server vendor.  The file: .nfs3proc.o.cmda.com has duplicate cookie=
 73
[593351.904689] NFS: directory fs/nfsd contains a readdir loop.Please conta=
ct your server vendor.  The file: .nfs3proc.o.cmda.com has duplicate cookie=
 73
[280774.570555] NFS: directory //accounting contains a readdir loop.Please =
contact your server vendor.  The file: .~lock.credit.rtf1.rtf# has duplicat=
e cookie 199

Is this likely to be a problem with JFS, the NFS client or server?  Can
anyone suggest how to investigate this further?

Ben.

--=20
Ben Hutchings
It is easier to write an incorrect program than to understand a correct one=
.

--=-EpPMwlpJ/bmYeDUy/zoz
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAUdoSHOe/yOyVhhEJAQqffhAAgcfrCivzqA0raGX85kBvug+4x0cCWm7u
vBTvU/b/dRrtUFimq8oTXo3S1G/GnIh0RQ65nVcUcl6g9n6BoS3SiafzBnh4nQEn
0I9l5V5jSxxw/KxOlwl+MNzrKUqGhEewR+1elnTauMMw/Dk9HstmVE4cesurPHEE
f3rjNVV10YEmd01uWr4qRs1T62Tp7MIghPXwFHDNrMU2F+BxoqgM9h3Y+/TAPJKN
noQpjpmkFW5QbcdTN6D2+QO0JpSicK0M5F4Cf974ACMoeEBf8wKMAnbhjEoUjpOx
JNR1tMdEqIiP9NRGlcXhbw0UFRu45hYrn5bWTih8dQMzePU6e94ColVIoXfEIOx7
TAWcvJfwsZI3l8g33vAWjv1HntRjj1u1v1TgOxE0qaeClhfgU5NR2QofzGUtrCKd
xRiSL+uPgW7s8GztOvwqNiM7SwE8s6lGcvzPHqPpbx/UXsKQE7iCtOG/l81ZZlDL
iCxKfyqcsRBUB/pA9QPdHKuced85D+nlb/a63TPD92CKjkkMgzsrYoeSnrNAnKe/
h/VLnBUrj+jhZdUzxseDFD+x4F72oaC23zsOmmEAKSJAK+lQtNMmFERAKFR55X7J
KnRsERXUkO+5ruvZoJjsYHlyVpelCVW382sANacaOOeZBTB5f37cUp6FoqlCHKV6
6wXprlFggYg=
=uRLY
-----END PGP SIGNATURE-----

--=-EpPMwlpJ/bmYeDUy/zoz--
