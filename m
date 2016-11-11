Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:37427 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S965233AbcKKDgJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 10 Nov 2016 22:36:09 -0500
From: NeilBrown <neilb@suse.com>
To: Steve Dickson <SteveD@redhat.com>
Date: Fri, 11 Nov 2016 14:36:00 +1100
Cc: libtirpc-devel@lists.sourceforge.net,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH rpcbind] Move default state-dir to /run/rpcbind
Message-ID: <877f8almcf.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


rpcbind can save state in a file to allow restart without forgetting
about running services.

The default location is currently "/tmp" which is an over-used
directory that isn't really suitable for system files.
The modern preferences would be a subdirectory of "/run", which can
be selected with a ./configure option.  That subdirectory would still need
to be created by something.

It is trivial for rpcbind to create the directory itself, and harmless
to try if it already exists, so:
=2D add a "mkdir" when saving state data
=2D change the default to /run/rpcbind (currently used by Debian)
=2D remove the default settign in the code, just use the one
  in configure.ac

Signed-off-by: NeilBrown <neilb@suse.com>
=2D--
 configure.ac    | 4 ++--
 src/warmstart.c | 5 +----
 2 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/configure.ac b/configure.ac
index f84921eb27fb..fe7d0b068439 100644
=2D-- a/configure.ac
+++ b/configure.ac
@@ -22,8 +22,8 @@ AC_ARG_ENABLE([warmstarts],
 AM_CONDITIONAL(WARMSTART, test x$enable_warmstarts =3D xyes)
=20
 AC_ARG_WITH([statedir],
=2D  AS_HELP_STRING([--with-statedir=3DARG], [use ARG as state dir @<:@defa=
ult=3D/tmp@:>@])
=2D  ,, [with_statedir=3D/tmp])
+  AS_HELP_STRING([--with-statedir=3DARG], [use ARG as state dir @<:@defaul=
t=3D/run/rpcbind@:>@])
+  ,, [with_statedir=3D/run/rpcbind])
 AC_SUBST([statedir], [$with_statedir])
=20
 AC_ARG_WITH([rpcuser],
diff --git a/src/warmstart.c b/src/warmstart.c
index 122a058b7954..3896027e62ba 100644
=2D-- a/src/warmstart.c
+++ b/src/warmstart.c
@@ -48,10 +48,6 @@
=20
 #include "rpcbind.h"
=20
=2D#ifndef RPCBIND_STATEDIR
=2D#define RPCBIND_STATEDIR "/tmp"
=2D#endif
=2D
 /* These files keep the pmap_list and rpcb_list in XDR format */
 #define	RPCBFILE	RPCBIND_STATEDIR "/rpcbind.xdr"
 #ifdef PORTMAP
@@ -141,6 +137,7 @@ error:
 void
 write_warmstart()
 {
+	(void) mkdir(RPCBIND_STATEDIR, 0770);
 	(void) write_struct(RPCBFILE, (xdrproc_t)xdr_rpcblist_ptr, &list_rbl);
 #ifdef PORTMAP
 	(void) write_struct(PMAPFILE, (xdrproc_t)xdr_pmaplist_ptr, &list_pml);
=2D-=20
2.10.2


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCAAGBQJYJTygAAoJEDnsnt1WYoG5jfwP+wfrkAloWwetmx4RwIsrmipd
XiToap/8hUf6qNZ89iFqrX5JquEFvgsgSOXddWj2IMFyMxGXF3M16D465uxCQoPH
dHadGOHRsPmOIKcKwNVtkYXAPpRI8H+Qofd4nh9meiwxGKGG5LNRsl3HFLYNk6Ex
hGxjCqDt/xvJIlOvLHUemRcSh/wjzPe43UwVdefqW/eYhMqlxjajc690eVNQXq1V
vGFsHTCzUrj/7Qxytr/kfsB09i8M9HjWgBd6pIhl6qTZXmEKI+rCvHPnZTqFOsZf
2aC5mBfA+0SSUbaHizP876be9NJLceti5QWbarYPmNzYkboab/uoBVMZj1sria41
qwm4rlQdSxdanVuKiqdad1ZBh5sS7Y4UbmyCg+tfd8jl7mve7HZQCLwLU3A2fu7W
Ome2VIMa2g4vukAcCLwN5m4So0xJSdxU67WEZWaduumRrh4yrcsOMGWs854qAY4O
qyAhFpuudPyM9mFDfZUs3ZGHL0B/hFu4hXkPfmWiz2dPb05aehFftjR2NnfVXUdb
nw34QfIZxAdiqwcNnWG0v3mXdDTqaeL9xH/aMZptTVJDtzr+nJv3JRz3Tj3A72PJ
2UzwexIMvxwXyIQ7/yGla+tzj02mS++sTAmGwhcYNE4d9pQb9S27DdEYsnPob8qc
WY7RL8ZEEpm5+4AslG5s
=J5Xt
-----END PGP SIGNATURE-----
--=-=-=--
