Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:46658 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752087Ab2GSGos (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 Jul 2012 02:44:48 -0400
Date: Thu, 19 Jul 2012 16:44:52 +1000
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <trond.myklebust@netapp.com>
Cc: "Darcy Partridge" <dpartrid@novell.com>, NFS <linux-nfs@vger.kernel.org>
Subject: NFSv4 client does not allow you to execute a file with no read
 permission.
Message-ID: <20120719164452.2a1cf3bc@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/0WvEtwF_gI_CtlNBHTQEozv"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/0WvEtwF_gI_CtlNBHTQEozv
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable


[resending - with more current address for Trond :-]

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

--Sig_/0WvEtwF_gI_CtlNBHTQEozv
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.18 (GNU/Linux)

iQIVAwUBUAes5Dnsnt1WYoG5AQL8mw/+NXwS41wLogGhCwWnH12UGBPZUC82KuWe
tdntxX9HwIrtnTUtxwzEWQMVXxHz32MLwtWPgrXHFncmEGTyR4AeCTz4aQ/asRfz
cFKfjodNcPw0DyeAfd3YtBQMok/Xe11tlrVs9Y1OmS/TdEsbyoGz/3dvpvfRxizO
cR/CnC7NRpjYOV4R+yBugufD5TwEj+7qiZY2yQnUlhYZWcrPrnTkTQkN684MhfAL
bgcX2dBYBU9h4c6JMquW8vfi9Tw4ggUuR10euVYSHLq73kqvE4HZIgJ/eLwxRLDM
zAl29CseoaP3cRmlwljYajqEpqOiZ+X8jK7J1GoDuYIFIT/kcfOfFMqavMbmAmSr
nSkUGlWLvFLGcxuitbmK6bDX39e5uNP+W3dYVALhw1AWdvorWTPD0bQKAweU3y01
Z80c0ydx3vzWZGN67CivCw+IxqmHRS+oA8JhZKfbqQUsrGCKzqfV8gg1XNsusD4I
8HaVLF83ggIc/m3/erts1qboZCfF0BzT23h6ep+fUdTPuxQilIs6RBXGjwh6fIa7
8Np4EXeQIhfnHR6M45AKVtNIy/TVg9hw/CQrJyDMc2706Bag+Zd+A5haOkByDSuf
49+mdpADVTDibJiVh21GPIOcx3UhuQYywm4uumksWXGcBp4voYi1nhkwf7hMyJke
wLpmA288B2o=
=S9FC
-----END PGP SIGNATURE-----

--Sig_/0WvEtwF_gI_CtlNBHTQEozv--
