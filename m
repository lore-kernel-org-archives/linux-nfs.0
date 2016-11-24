Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:40434 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S966049AbcKXWsW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 24 Nov 2016 17:48:22 -0500
From: NeilBrown <neilb@suse.com>
To: Steve Dickson <SteveD@redhat.com>
Date: Fri, 25 Nov 2016 09:48:14 +1100
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        libtirpc-devel@lists.sourceforge.net
Subject: [PATCH rpcbind] Fix path for rpcbind in rpcbind.service.
Message-ID: <87shqga40h.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


Due to a miscommunication,
 Commit: 0cc39c519278 ("Provide systemd unit files for rpcbind")
used sbindir as the location of rpcbind to put in the systemd unit
file instead of bindir, which is where rpcbind gets installed.

So change those few instances of sbindir to bindir so that the unit
file will have the correct path.

Signed-off-by: NeilBrown <neilb@suse.com>
=2D--
 configure.ac               | 6 +++---
 systemd/rpcbind.service.in | 2 +-
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/configure.ac b/configure.ac
index acc69149c862..f34f669dc7da 100644
=2D-- a/configure.ac
+++ b/configure.ac
@@ -61,9 +61,9 @@ AC_SEARCH_LIBS([pthread_create], [pthread])
=20
 AC_CHECK_HEADERS([nss.h rpcsvc/mount.h])
=20
=2D# make sbindir available for substitution in config file
+# make bindir available for substitution in config file
 # 2 "evals" needed to expand variable names
=2DAC_SUBST([_sbindir])
=2DAC_CONFIG_COMMANDS_PRE([eval eval _sbindir=3D$sbindir])
+AC_SUBST([_bindir])
+AC_CONFIG_COMMANDS_PRE([eval eval _bindir=3D$bindir])
=20
 AC_OUTPUT([Makefile systemd/rpcbind.service])
diff --git a/systemd/rpcbind.service.in b/systemd/rpcbind.service.in
index c173b838bd42..e7e86da0c268 100644
=2D-- a/systemd/rpcbind.service.in
+++ b/systemd/rpcbind.service.in
@@ -11,7 +11,7 @@ After=3Drpcbind.socket
 [Service]
 Type=3Dnotify
 # distro can provide a drop-in adding EnvironmentFile=3D-/??? if needed.
=2DExecStart=3D@_sbindir@/rpcbind $RPCBIND_OPTIONS -w -f
+ExecStart=3D@_bindir@/rpcbind $RPCBIND_OPTIONS -w -f
=20
 [Install]
 WantedBy=3Dmulti-user.target
=2D-=20
2.10.2


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCAAGBQJYN24uAAoJEDnsnt1WYoG5bnsP/3aOjEr9QEH1+js7nBxq8sK/
ntQRGc9lyGmDYkh4wCpNCrS3Sbe+76zg59vrtsHr7kBDBPkIKSRZbl+NoMZXFH0j
2wyEaiN5ogofPO+LqSU7Ys1EybG/jk+3lCsF6yMuy0pQZRqunvwHe/aFFy11UKTK
wZfXwJaSUIuFl1iibB9YLOFrTUUs1/W6Qfo9LulDoJQ6RUzj8v+Pd1GL4ZMtgKqR
9M5qLU2YGRhXe/Q0zQn+XTyzmJer4NFsQw7g0xOu8NCJgaj+yKauBAwMPErD0kFg
jRsy3X35BHwGDV5f39ENc8eqVxsubW5TvZiFcL1q+JoWKc5KMy3h0fU8DV1ApK3z
nNmWQrFgos0T9BVIPz3CPR1qh0f8q06I5KuIwuj6ocZUdM4B5zajNld5VDvp9q3t
g77lmPNN/d7tHdrUtuTfWH5NL+g64IlMYUGQb+l/PNgeGaaIhG4hJLFcQl5EdpIF
WOM4O2ORTOXYfnBj39Kw7/uAKehxT8bM7BYcT1RnSK9fF+/1nKnRr0pTqqelfB+h
yshbSlBuXmvMJqjZcajdvu3w9jSVe6JRn1wpgvZhp+6ea5qyzK9ZH4fsXGGGSUKn
cNiPeWjC4FKl9CQ4HMklesMIGcL4t0e+QumwekbjvnD0nmU1lJoD5a/E95puQols
PEOWMee1BR+ivzT9cJh6
=1oUy
-----END PGP SIGNATURE-----
--=-=-=--
