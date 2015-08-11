Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from 216-82-208-22.static.grandenetworks.net ([216.82.208.22]:45227
	"EHLO mx1.mthode.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965317AbbHKQAr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Aug 2015 12:00:47 -0400
Reply-To: mthode@mthode.org
To: trond.myklebust@primarydata.com, anna.schumaker@netapp.com,
        linux-nfs@vger.kernel.org
From: Matthew Thode <mthode@mthode.org>
Subject: is it possible to set CONFIG_PNFS_FLEXFILE_LAYOUT=y ?
Message-ID: <55CA1941.3070007@mthode.org>
Date: Tue, 11 Aug 2015 10:48:17 -0500
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="D7DWO7M1En9uq2kUwQafNwxMlwq8EBsUK"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--D7DWO7M1En9uq2kUwQafNwxMlwq8EBsUK
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

All the requirements seem to be set but it won't seem to set itself to
be built-in.  Even when set manually it resets itself.

Here's the search on it from menuconfig, as you can see, it seems like
all requirements are met.

Depends on: NETWORK_FILESYSTEMS [=3Dy] && NFS_V4_1 [=3Dy] && NFS_V3 [=3Dy=
]

Thanks,
--=20
Matthew Thode


--D7DWO7M1En9uq2kUwQafNwxMlwq8EBsUK
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCgAGBQJVyhlJAAoJEGSje+quGaTo/1oQAJT6hxWlVKyhktlEWBUszHqG
M2qdBF+1ZA+vooDKcaEm4zO2S/268dX0P8KIhUgx/OBKHAngIFL7uSn91/Wk/y7g
ecxaB91XeJ5tmH4a+YiKReH+i8XjEkzwJIy0iYZQIjpOBiL3cCCYwawjVoGlZQg1
dONf0gWpYsRqoBJsuPa/IxpbwKOB1unt9INBsKfi2KFqwiTekrug/1uIFmTLpvvz
3Wnq3lXtdk7OJ9Hl0Y0y6Q2F69mgao6wGLnNERbQ8POa59iG/lpvPhDcDv3y8cRD
qZcFq8YayreaSCpNKQKusaJMnH4SkVHWF6LexxJJlNsMwgimqvRY841G/ICrkN6N
XNH9Ov24heIcXD6VA2WJFrVlrQdt7mFt2H+QPGXPdkAr0FpI5A2W27N/A18bJhVi
PhdwfPyPw7FlhxZjOjHxHfABL8mLNP5tnmDnvZh1LxQ4Ia/6OK7a+PKeEmUFMDQW
osYd1lJtbCOtmxcgoFwtxOLmkr5e/RfIEH0d5L2iXMKjDHexj/F6TQUHW4zMLPvs
L2hutngF7vFxC9zSp08eBpLCxzrl0MaOWERSPYkIgoVwfvZyAXTopUBLDvPzaWGo
C5zDhvtj/4wr2oOc83Rv6wQHxVkM4oJyBpL/XKDM385yaQf2zxvg2W5IPInNH7Bi
Low5nBCrWw2Id+Lo2b8H
=3cmj
-----END PGP SIGNATURE-----

--D7DWO7M1En9uq2kUwQafNwxMlwq8EBsUK--
