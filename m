Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from vr160.rayconnect.de ([213.155.88.90]:50385 "EHLO
	mail.schwartzkopff.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751123Ab1GUNpz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Jul 2011 09:45:55 -0400
Received: from nb002.localnet (cl-1872.cgn-01.de.sixxs.net [IPv6:2001:4dd0:ff00:74f::2])
	(Authenticated sender: misch)
	by mail.schwartzkopff.org (Postfix) with ESMTPSA id 71738129164
	for <linux-nfs@vger.kernel.org>; Thu, 21 Jul 2011 15:40:06 +0200 (CEST)
From: Michael Schwartzkopff <misch@schwartzkopff.org>
Reply-To: misch@schwartzkopff.org
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: NFSv4 grace time
Date: Thu, 21 Jul 2011 15:40:05 +0200
Content-Type: multipart/signed;
  boundary="nextPart2937924.h2s9kaPMiY";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Message-Id: <201107211540.05673.misch@schwartzkopff.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--nextPart2937924.h2s9kaPMiY
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

Hi,

setting up a linux NFS server cluster I experience a strange problem during=
 a=20
failover. A client can access a file only after 60 to 90 seconds. On the li=
ne I=20
see a NFS4ERR_GRACE from the server to the client.

I already set the /proc/fs/nfsd/nfsv4leastime to 10.

Any other idea?

=46or the tests I have a simple setup:

One host with a simple script that simulates failover:

#!/bin/bash

ip a d 1.2.3.4/24 dev eth0
exportfs -u *:/srv/nfs/home
exportfs -u *:/srv/nfs
/etc/init.d/nfsserver stop
#
/etc/init.d/nfsserver start
exportfs -o fsid=3D0,rw,crossmnt,no_root_squash *:/srv/nfs
exportfs -o fsid=3D1000,rw,mountpoint,no_root_squash *:/srv/nfs/home
ip a a 1.2.3.4/24 dev eth0

=2D-=20
Dr. Michael Schwartzkopff
Guardinistr. 63
81375 M=FCnchen

Tel: (0163) 172 50 98
=46ax: (089) 620 304 13

--nextPart2937924.h2s9kaPMiY
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAk4oLDUACgkQH8fVuZhm6xyGygCgj4YJxtMbeQs8HXr8lOmcjlTZ
X38Anj0oBf3WW4ObKaYkP63CywMfPbcL
=egXE
-----END PGP SIGNATURE-----

--nextPart2937924.h2s9kaPMiY--
