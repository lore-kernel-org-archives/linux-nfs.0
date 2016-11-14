Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:38348 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751201AbcKNHGG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 14 Nov 2016 02:06:06 -0500
From: NeilBrown <neilb@suse.com>
To: Steve Dickson <SteveD@redhat.com>
Date: Mon, 14 Nov 2016 18:05:57 +1100
Cc: Mike Frysinger <vapier@gentoo.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        libtirpc-devel@lists.sourceforge.net
Subject: [PATCH rpcbind v2] Move default state-dir to a subdirectory of /tmp
In-Reply-To: <87polzj7sx.fsf@notabene.neil.brown.name>
References: <877f8almcf.fsf@notabene.neil.brown.name> <20161111210034.GM21655@vapier.lan> <87polzj7sx.fsf@notabene.neil.brown.name>
Message-ID: <87vavqilre.fsf@notabene.neil.brown.name>
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

The default location is currently "/tmp" which is
not ideal for system files.  It is particularly unpleasant
to put simple files there rather than creating a directory
to contain them.

On a modern Linux system it is preferable to use /run, and there it is
even more consistent with practice to use a subdirectory.

This directory needs to be create one each boot, and while there are
tools (e.g. systemd-tmpfiles) which can do that it is cleaner to keep
rpcbind self-contained and have it create the directory.

So change the default location to /tmp/rpcbind, and create that
directory.  If a different user-id is used, we need to create
and chown the directory before dropping privileges.  We do this
with care so avoid chowning the wrong thing by mistake.

Signed-off-by: NeilBrown <neilb@suse.com>
=2D--

hi,
 I realized that I hadn't allowed for the fact that rpcbind changes
 it's uid, and we need to mkdir and chown before that.
 I've also reverted the move to /run, but moved to /tmp/rpcbind
 instead.  A subdirectory is a good idea, even in /tmp.

NeilBrown


 configure.ac    |  4 ++--
 src/rpcbind.c   |  5 +++++
 src/rpcbind.h   |  1 +
 src/warmstart.c | 25 +++++++++++++++++++++----
 4 files changed, 29 insertions(+), 6 deletions(-)

diff --git a/configure.ac b/configure.ac
index f84921eb27fb..df931c720f93 100644
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
t=3D/tmp/rpcbind@:>@])
+  ,, [with_statedir=3D/tmp/rpcbind])
 AC_SUBST([statedir], [$with_statedir])
=20
 AC_ARG_WITH([rpcuser],
diff --git a/src/rpcbind.c b/src/rpcbind.c
index 87ccdc27e4c9..8db8dfc17c27 100644
=2D-- a/src/rpcbind.c
+++ b/src/rpcbind.c
@@ -263,6 +263,11 @@ main(int argc, char *argv[])
 			syslog(LOG_ERR, "cannot get uid of '%s': %m", id);
 			exit(1);
 		}
+#ifdef WARMSTART
+		if (warmstart) {
+			mkdir_warmstart(p->pw_uid);
+		}
+#endif
                 if (setgid(p->pw_gid) =3D=3D -1) {
                         syslog(LOG_ERR, "setgid to '%s' (%d) failed: %m", =
id, p->pw_gid);
                         exit(1);
diff --git a/src/rpcbind.h b/src/rpcbind.h
index 74f9591ae720..5b1a9bb8651a 100644
=2D-- a/src/rpcbind.h
+++ b/src/rpcbind.h
@@ -129,6 +129,7 @@ int is_localroot(struct netbuf *);
 extern void pmap_service(struct svc_req *, SVCXPRT *);
 #endif
=20
+void mkdir_warmstart(int uid);
 void write_warmstart(void);
 void read_warmstart(void);
=20
diff --git a/src/warmstart.c b/src/warmstart.c
index 122a058b7954..3a6bcb5e34e1 100644
=2D-- a/src/warmstart.c
+++ b/src/warmstart.c
@@ -45,19 +45,23 @@
 #include <syslog.h>
 #include <unistd.h>
 #include <errno.h>
+#include <fcntl.h>
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
 #define	PMAPFILE	RPCBIND_STATEDIR "/portmap.xdr"
 #endif
=20
+#ifndef O_DIRECTORY
+#define O_DIRECTORY 0
+#endif
+#ifndef O_NOFOLLOW
+#define O_NOFOLLOW 0
+#endif
+
 static bool_t write_struct(char *, xdrproc_t, void *);
 static bool_t read_struct(char *, xdrproc_t, void *);
=20
@@ -139,8 +143,21 @@ error:
 }
=20
 void
+mkdir_warmstart(int uid)
+{
+	if (mkdir(RPCBIND_STATEDIR, 0770) =3D=3D 0) {
+		int fd =3D open(RPCBIND_STATEDIR, O_RDONLY | O_DIRECTORY | O_NOFOLLOW);
+		if (fd >=3D 0) {
+			fchown(fd, uid, -1);
+			close(fd);
+		}
+	}
+}
+
+void
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

iQIcBAEBCAAGBQJYKWJVAAoJEDnsnt1WYoG5CqQP/0yq5Ihigx7jHqtBJfQFpp1u
+9s5TlNFbBScGcDJ0tyGq6nH5NMKxCrU9/8oPImpGpqv294BdWfl0UCWwLyyniR4
yu8GhsANV//Cl1aTGANaI6vcObjrfnQpiWrychqxlsbrwc2ZJhceZitoDFITRws5
lJqFVpUtq7ZUYtyH82E72wA4OhaU7imBLrPYtYqC6F/eFRG//6VbK5sHEbGTedKb
T+fcINsHx34G2ARnkxCcXJhxx0QnmxAwHn6PzVGlmvNU88ZT80TKPUA94QItEgdb
UdFbMkBr43mi+8GjVBOLdDq+TrHlPTfO2pJvWQtthiw11adcqluC5HmKkAYBc2+s
zuL8OOQIwPLeja7fjTXhzmbJeI1zGnPD7Z53+AgF3cCMpKPZceDaLJsrVpe+w1HW
4JIHbFL0sNFffmCGFQ3LX2dMFdXrXS2i4ZPZbJtSWL8Vj8NDqLAvN4UmB9u73brd
0OFmQDar4W5MoCSdiY7wuogn9nCknHkMIWbeHaFI6sB8UE/KnjJgLkTrA/KZu1XA
O5Nyt8rtpf9za3aCeWt5eAkYz6IWjc8bwEBaFHI8SEwgFZb5K4RfJ1w4EH1YORZ/
jJAeptbnOmJyPN0Y/yP9YhWzycEGEqhDld5zBJ+6EniURvt5/b52NTk8AnC1/cyc
U/hByL6Gj0BYoEinId9E
=pY3g
-----END PGP SIGNATURE-----
--=-=-=--
