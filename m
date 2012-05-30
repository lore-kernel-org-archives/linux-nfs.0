Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:60154 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932174Ab2E3DE1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 May 2012 23:04:27 -0400
Date: Wed, 30 May 2012 13:04:14 +1000
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: "Darcy Partridge" <dpartrid@novell.com>, NFS <linux-nfs@vger.kernel.org>
Subject: NFSv4 client does not allow you to execute a file with no read
 permission.
Message-ID: <20120530130414.597e29ae@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/OVfVAfS=twHct=Tsj_=Wu3f"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/OVfVAfS=twHct=Tsj_=Wu3f
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable


If there is a file on the server with permissions --x--x--x,
then if I mount with NFSv3 I (as a non-root user) can run it.
However if I mount with NFSv4 I cannot.

This is with a sufficiently recent server kernel which fixes that server-si=
de
bug that caused a problem with this scenario.

I think the bug was introduced by commit cd9a1c0e5ac68
    NFSv4: Clean up nfs4_atomic_open

which added a new call to nfs_may_open.

The problem is that nfs_intent_set_file calls nfs_may_open passing
intent.open.flags which contains O_RDONLY (i.e. 0).  This is mapped
to FMODE_READ before being passed to nfs_do_access.
As I don't have read access, the exec fails.

I can "fix it" with

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index eedd24d..15a718b 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -2278,12 +2278,12 @@ static int nfs_open_permission_mask(int openflags)
 {
 	int mask =3D 0;
=20
-	if ((openflags & O_ACCMODE) !=3D O_WRONLY)
-		mask |=3D MAY_READ;
 	if ((openflags & O_ACCMODE) !=3D O_RDONLY)
 		mask |=3D MAY_WRITE;
 	if (openflags & __FMODE_EXEC)
 		mask |=3D MAY_EXEC;
+	else if ((openflags & O_ACCMODE) !=3D O_WRONLY)
+		mask |=3D MAY_READ;
 	return mask;
 }
=20
so we don't ask for READ permission if we are asking for EXEC permission.
I suspect this may not be the right fix.  I'm just presenting it to help
focus on whether the problem seems to be.

Is there a better way to fix this?

Thanks,
NeilBrown

--Sig_/OVfVAfS=twHct=Tsj_=Wu3f
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.18 (GNU/Linux)

iQIVAwUBT8WOLjnsnt1WYoG5AQJd/w/9GabEbjB2Emsv4cbKjRaYjEM6rPNfnF4v
Adc5HMWDyxFBvBbJgdr9QrViUA+1T3vZAviZPhA7szKuZq9hLKC8SHj2yWM8ZxpJ
a9NoKE4Oa0n+NwrsspB3SwJu637pmsa53g/5njCV9fDw3GpK0Rigoinie8NqHRM0
Lp0uVteg30FfhNPWoMwwy6dwLPAoVQbvacf0nJj1DhdBFBA7aPPL29jcag8uVxLN
2tZsPVfabDpKxugo3IU95pTrsGUwti7hN40V1B/a6L8ifm8+8ispWlCo/kZ/cU/b
a/FihC+FAY/dgLZRJRv/IcYd1ByWMSDCEQdIX62Eeg9VdAHlmKTHhoWza78bF8vi
9IS121s8DwBquONuiy5wmHxeP947Q4cML+SPUm4sfYEsubJ5RrDoT7vAXNso+zpE
dvEhyKPBBUzuP0OyvInpk39LHz2gaLogGXDt5GSu1qMZ0ZBYSXJakq3/YQsUX/q+
78mKK2/vWXy5mhcrOKeW0hjJ9E5LZEFI3zdpHiXnyyNZsxE7MBBhHWK1u8fqVDwg
HeRYX1v0E11PNP1Mnd2xc2IBMuHxTkWE/Ij2pgpaHm7l3KChnobU8Q0b/kMXZzUP
KbZFlSghdhxS74YeGTqH8T3U8nV02U2xWuN+XbGwgmFH3uoCsYwGgGYSxcKXHmU/
N2mVqHTVaYU=
=uPUG
-----END PGP SIGNATURE-----

--Sig_/OVfVAfS=twHct=Tsj_=Wu3f--
