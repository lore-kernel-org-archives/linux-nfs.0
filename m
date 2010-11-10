Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from server.klug.on.ca ([205.189.48.131]:2078 "EHLO
	server.klug.on.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755600Ab0KJNnO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Nov 2010 08:43:14 -0500
Received: from linux.interlinx.bc.ca (d67-193-197-208.home3.cgocable.net [67.193.197.208])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by server.klug.on.ca (Postfix) with ESMTP id 3D7502803
	for <linux-nfs@vger.kernel.org>; Wed, 10 Nov 2010 08:43:13 -0500 (EST)
Received: from [10.75.22.1] (pc.ilinx [10.75.22.1])
	by linux.interlinx.bc.ca (Postfix) with ESMTP id 15BB58034
	for <linux-nfs@vger.kernel.org>; Wed, 10 Nov 2010 08:43:12 -0500 (EST)
Subject: Re: Error: state manager failed on NFSv4 server linux with error
 127
From: "Brian J. Murrell" <brian@interlinx.bc.ca>
To: linux-nfs@vger.kernel.org
In-Reply-To: <1288477327.8621.5.camel@heimdal.trondhjem.org>
References: <1287334833.4871.6.camel@pc>
	 <1287340520.5266.70.camel@heimdal.trondhjem.org>
	 <1288460514.32627.105.camel@pc>
	 <1288461151.3238.9.camel@heimdal.trondhjem.org>
	 <1288461562.32627.151.camel@pc>
	 <1288462786.3238.16.camel@heimdal.trondhjem.org>
	 <1288474164.32627.383.camel@pc>
	 <1288474886.8621.3.camel@heimdal.trondhjem.org>
	 <1288475215.32627.406.camel@pc>
	 <1288477327.8621.5.camel@heimdal.trondhjem.org>
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-Ul5QJjrXX/6/s4iSFW9p"
Date: Wed, 10 Nov 2010 08:43:11 -0500
Message-ID: <1289396591.21879.4.camel@pc>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--=-Ul5QJjrXX/6/s4iSFW9p
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2010-10-30 at 18:22 -0400, Trond Myklebust wrote:=20
>=20
> How about something like the following patch? It should allow you to log
> only the errors that lead to a state recovery situation.

So, I came to find my machine looking locked up this morning however
eventually it seemed to release itself.  Looking in dmesg I can see:

[350230.265829] Error: state manager encountered RPCSEC_GSS session expired=
 against NFSv4 server linux.
repeated 8 more times
[350230.297307] Error: state manager encountered RPCSEC_GSS session expired=
 against NFSv4 server linux.
[350235.269660] nfs4_warn_keyexpired: 2075 callbacks suppressed
[350235.269665] Error: state manager encountered RPCSEC_GSS session expired=
 against NFSv4 server linux.
repeated 8 more times
[350235.290167] Error: state manager encountered RPCSEC_GSS session expired=
 against NFSv4 server linux.
[350240.272110] nfs4_warn_keyexpired: 2093 callbacks suppressed
[350240.272115] Error: state manager encountered RPCSEC_GSS session expired=
 against NFSv4 server linux.
repeated 8 more times
[350240.293239] Error: state manager encountered RPCSEC_GSS session expired=
 against NFSv4 server linux.
[350245.276176] nfs4_warn_keyexpired: 2121 callbacks suppressed
[350245.276181] Error: state manager encountered RPCSEC_GSS session expired=
 against NFSv4 server linux.
repeated 8 more times
[350245.299625] Error: state manager encountered RPCSEC_GSS session expired=
 against NFSv4 server linux.
[350250.280834] nfs4_warn_keyexpired: 2082 callbacks suppressed
[350250.280839] Error: state manager encountered RPCSEC_GSS session expired=
 against NFSv4 server linux.
repeated 8 more times
[350250.302470] Error: state manager encountered RPCSEC_GSS session expired=
 against NFSv4 server linux.
[350255.285567] nfs4_warn_keyexpired: 2110 callbacks suppressed
[350255.285572] Error: state manager encountered RPCSEC_GSS session expired=
 against NFSv4 server linux.
repeated 8 more times
[350255.307410] Error: state manager encountered RPCSEC_GSS session expired=
 against NFSv4 server linux.
[350260.290107] nfs4_warn_keyexpired: 2118 callbacks suppressed
[350260.290111] Error: state manager encountered RPCSEC_GSS session expired=
 against NFSv4 server linux.
repeated 8 more times
[350260.315070] Error: state manager encountered RPCSEC_GSS session expired=
 against NFSv4 server linux.
[350265.296668] nfs4_warn_keyexpired: 2107 callbacks suppressed
[350265.296673] Error: state manager encountered RPCSEC_GSS session expired=
 against NFSv4 server linux.
repeated 8 more times
[350265.317877] Error: state manager encountered RPCSEC_GSS session expired=
 against NFSv4 server linux.
[350270.302257] nfs4_warn_keyexpired: 2128 callbacks suppressed
[350270.302262] Error: state manager encountered RPCSEC_GSS session expired=
 against NFSv4 server linux.
repeated 8 more times
[350270.323727] Error: state manager encountered RPCSEC_GSS session expired=
 against NFSv4 server linux.
[350275.310073] nfs4_warn_keyexpired: 2100 callbacks suppressed
[350275.310078] Error: state manager encountered RPCSEC_GSS session expired=
 against NFSv4 server linux.
repeated 8 more times
[350275.332569] Error: state manager encountered RPCSEC_GSS session expired=
 against NFSv4 server linux.
[350280.316868] nfs4_warn_keyexpired: 2085 callbacks suppressed
[350280.316873] Error: state manager encountered RPCSEC_GSS session expired=
 against NFSv4 server linux.
repeated 8 more times
[350280.338332] Error: state manager encountered RPCSEC_GSS session expired=
 against NFSv4 server linux.
[350285.322043] nfs4_warn_keyexpired: 2119 callbacks suppressed
[350285.322049] Error: state manager encountered RPCSEC_GSS session expired=
 against NFSv4 server linux.
repeated 8 more times
[350285.343702] Error: state manager encountered RPCSEC_GSS session expired=
 against NFSv4 server linux.
[350290.328213] nfs4_warn_keyexpired: 2088 callbacks suppressed
[350290.328218] Error: state manager encountered RPCSEC_GSS session expired=
 against NFSv4 server linux.
repeated 8 more times
[350290.350477] Error: state manager encountered RPCSEC_GSS session expired=
 against NFSv4 server linux.
[350295.332510] nfs4_warn_keyexpired: 2122 callbacks suppressed
[350295.332515] Error: state manager encountered RPCSEC_GSS session expired=
 against NFSv4 server linux.
repeated 8 more times
[350295.352991] Error: state manager encountered RPCSEC_GSS session expired=
 against NFSv4 server linux.
[350300.337953] nfs4_warn_keyexpired: 2077 callbacks suppressed
[350300.337959] Error: state manager encountered RPCSEC_GSS session expired=
 against NFSv4 server linux.
repeated 8 more times
[350300.359669] Error: state manager encountered RPCSEC_GSS session expired=
 against NFSv4 server linux.
[350305.345596] nfs4_warn_keyexpired: 2094 callbacks suppressed
[350305.345602] Error: state manager encountered RPCSEC_GSS session expired=
 against NFSv4 server linux.
repeated 8 more times
[350305.380263] Error: state manager encountered RPCSEC_GSS session expired=
 against NFSv4 server linux.
[350310.352954] nfs4_warn_keyexpired: 2081 callbacks suppressed
[350310.352959] Error: state manager encountered RPCSEC_GSS session expired=
 against NFSv4 server linux.
repeated 8 more times
[350310.373999] Error: state manager encountered RPCSEC_GSS session expired=
 against NFSv4 server linux.
[350315.357615] nfs4_warn_keyexpired: 2087 callbacks suppressed
[350315.357620] Error: state manager encountered RPCSEC_GSS session expired=
 against NFSv4 server linux.
repeated 8 more times
[350315.380362] Error: state manager encountered RPCSEC_GSS session expired=
 against NFSv4 server linux.
[350320.362030] nfs4_warn_keyexpired: 2048 callbacks suppressed
[350320.362035] Error: state manager encountered RPCSEC_GSS session expired=
 against NFSv4 server linux.
repeated 8 more times
[350320.383488] Error: state manager encountered RPCSEC_GSS session expired=
 against NFSv4 server linux.

b.


--=-Ul5QJjrXX/6/s4iSFW9p
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAkzaoW8ACgkQl3EQlGLyuXDXKwCfTRBbFwPaQN6+uE7ntq7b3oH7
QesAn2/X7Ds7VJVuWJ7DHg2NHmJarOHa
=Qe1L
-----END PGP SIGNATURE-----

--=-Ul5QJjrXX/6/s4iSFW9p--
