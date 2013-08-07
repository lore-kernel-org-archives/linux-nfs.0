Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.gmx.net ([74.208.4.200]:51512 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932518Ab3HGVvV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Aug 2013 17:51:21 -0400
Received: from [192.168.1.101] ([71.135.96.196]) by mail.gmx.com (mrgmxus002)
 with ESMTPSA (Nemesis) id 0M7YR7-1W31Zw3xbD-00xIgl for
 <linux-nfs@vger.kernel.org>; Wed, 07 Aug 2013 23:51:20 +0200
Message-ID: <5202C154.6020907@musician.org>
Date: Wed, 07 Aug 2013 14:51:16 -0700
From: Joe Lee <joe.lee@musician.org>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: MDS setup
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="W98S7xsIDGjRRQXGBCRU9aGqnvtvqSwxp"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--W98S7xsIDGjRRQXGBCRU9aGqnvtvqSwxp
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

I have an NFS server that I want to use as an MDS, so I'm going through
the pNFS setup instructions from the wiki --
http://www.linux-nfs.org/wiki/index.php/PNFS_Setup_Instructions

When I get to the step to tell the MDS the IP addresses of the DSs, I
get this response:

    bash: /proc/fs/nfsd/pnfs_dlm_device: Permission denied

Did I misconfigure something?

The system I'm working on is version 6.4 of the CentOS GNU/Linux
distribution.

I've built and installed the linux and nfs-utils from bhalevy's git
repositories. The linux version is 3.8.0-pnfs+, and the nfs-utils
version is 1.1.0.


-Joe


--W98S7xsIDGjRRQXGBCRU9aGqnvtvqSwxp
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.20 (GNU/Linux)

iQEcBAEBAgAGBQJSAsFUAAoJENdrWZED3ONIOLQH/RS945L7oEAtG5PGBYsGhsW8
5MH4CpDOhaNDv3SiBR9/diw3PQnsEX0oazTOfBNU+j1Dr2F49Zd7w/BYih+h1IQS
sUvJx0+GDha4TNE6jt8+kcl2zqkqqonIUQvjlF1g56IpLzLLRFuy2XppubqPhnt4
3jk/4NGjcrnk/S0KgfXgO6XY5btE+t+V5Cf6Y5Ut42wbv4Bnj0UpNEMnc7pidcAb
1ZFJv6l5E10yoRvjj7mBVTQLWFcPFz8jtaJbDWiFuuF0u6q0ohY4x7zEePaQr+XF
0gNs5+GlmUZeO/bQv2LBfAqmiAarA2mQC1U/jq62sLTs/Z7Y8j1W2sXjO9c3ZC0=
=k66B
-----END PGP SIGNATURE-----

--W98S7xsIDGjRRQXGBCRU9aGqnvtvqSwxp--
