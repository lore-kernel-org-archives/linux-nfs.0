Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zak.futurequest.net ([69.5.6.152]:54757 "HELO
	zak.futurequest.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1750990Ab1BVV65 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Feb 2011 16:58:57 -0500
Date: Tue, 22 Feb 2011 15:52:14 -0600
From: Bruce Guenter <bruce@untroubled.org>
To: linux-nfs@vger.kernel.org
Subject: Invisible file problem
Message-ID: <20110222215214.GA32537@untroubled.org>
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="wac7ysb48OaltWcw"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--wac7ysb48OaltWcw
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable


I have come on a situation where a file in a directory is not showing up
in any directory listings, yet is still accessible by direct access.  It
shows up in listings on the server but not on the client.  I did a
capture of the NFS protocol traffic, and the file is showing up in the
readdir call results.  If I recreate the directory using the same file
names but empty files, the behavior persists.

I am running vanilla 2.6.37.1 on both client and server, using NFSv4.
The server filesystem is ext4.

Is this a kernel NFS client bug?  Is there anything else I can do to
diagnose the source of the problem, or any way to work around it?

Thanks.

--=20
Bruce Guenter <bruce@untroubled.org>                http://untroubled.org/

--wac7ysb48OaltWcw
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.17 (GNU/Linux)

iEYEARECAAYFAk1kMA4ACgkQ6W+y3GmZgOhIxgCggy2Ixvm+veGyLSsIngx2pG/6
qeEAn0FCqUaYcYmkrljp+SuHLE8O9z9O
=Zbyp
-----END PGP SIGNATURE-----

--wac7ysb48OaltWcw--
