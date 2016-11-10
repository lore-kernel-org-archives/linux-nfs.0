Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:41945 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752287AbcKJAtQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 9 Nov 2016 19:49:16 -0500
From: NeilBrown <neilb@suse.com>
To: Steve Dickson <SteveD@redhat.com>, Jeff Layton <jlayton@redhat.com>
Date: Thu, 10 Nov 2016 11:49:06 +1100
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH nfs-utils] Remove all use of /var/lib/nfs/xtab
Message-ID: <87eg2kma65.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


/var/lib/nfs/xtab is only used to find out what has been exported to
the kernel.  This is more reliably done by reading
/proc/fs/nfs{,d}/export and nfs-utils uses that file if is available.
So xtab is only need if you have an incredibly ancient kernel which
doesn't have /proc/fs/nfs/export (and so which only supports NFSv2) or if
/proc is not mounted.

Neither of these are credible contexts to run a modern nfs-utils,
so stop creating or reading the xtab file.

Signed-off-by: NeilBrown <neilb@suse.com>
=2D--
 Makefile.am                |  3 +--
 support/export/xtab.c      | 31 ++-----------------------------
 support/include/exportfs.h |  4 +---
 support/include/nfslib.h   |  9 ---------
 utils/exportfs/exportfs.c  |  4 +---
 utils/mountd/auth.c        |  1 -
 utils/mountd/mountd.c      | 11 ++---------
 7 files changed, 7 insertions(+), 56 deletions(-)

diff --git a/Makefile.am b/Makefile.am
index 4a2edc682de8..e1f39aab5f62 100644
=2D-- a/Makefile.am
+++ b/Makefile.am
@@ -23,7 +23,6 @@ ACLOCAL_AMFLAGS =3D -I aclocal
=20
 install-data-hook:
 	if [ ! -d $(DESTDIR)$(statedir) ]; then mkdir -p $(DESTDIR)$(statedir); fi
=2D	touch $(DESTDIR)$(statedir)/xtab; chmod 644 $(DESTDIR)$(statedir)/xtab
 	touch $(DESTDIR)$(statedir)/etab; chmod 644 $(DESTDIR)$(statedir)/etab
 	touch $(DESTDIR)$(statedir)/rmtab; chmod 644 $(DESTDIR)$(statedir)/rmtab
 	mkdir -p $(DESTDIR)$(statdpath)/sm $(DESTDIR)$(statdpath)/sm.bak
@@ -32,7 +31,7 @@ install-data-hook:
 	-chown $(statduser) $(DESTDIR)$(statdpath)/sm $(DESTDIR)$(statdpath)/sm.b=
ak $(DESTDIR)$(statdpath)/state
=20
 uninstall-hook:
=2D	rm $(DESTDIR)$(statedir)/xtab
+	rm -f $(DESTDIR)$(statedir)/xtab
 	rm $(DESTDIR)$(statedir)/etab
 	rm $(DESTDIR)$(statedir)/rmtab
 	rm $(DESTDIR)$(statdpath)/state
diff --git a/support/export/xtab.c b/support/export/xtab.c
index e953071ea901..10d9dbc5db15 100644
=2D-- a/support/export/xtab.c
+++ b/support/export/xtab.c
@@ -1,7 +1,7 @@
 /*
  * support/export/xtab.c
  *
=2D * Interface to the xtab file.
+ * Interface to the etab/exports file.
  *
  * Copyright (C) 1995, 1996 Olaf Kirch <okir@monad.swb.de>
  */
@@ -29,7 +29,6 @@ xtab_read(char *xtab, char *lockfn, int is_export)
 {
     /* is_export =3D=3D 0  =3D> reading /proc/fs/nfs/exports - we know the=
se things are exported to kernel
      * is_export =3D=3D 1  =3D> reading /var/lib/nfs/etab - these things a=
re allowed to be exported
=2D     * is_export =3D=3D 2  =3D> reading /var/lib/nfs/xtab - these things=
 might be known to kernel
      */
 	struct exportent	*xp;
 	nfs_export		*exp;
@@ -55,9 +54,6 @@ xtab_read(char *xtab, char *lockfn, int is_export)
 			if ((xp->e_flags & NFSEXP_FSID) && xp->e_fsid =3D=3D 0)
 				v4root_needed =3D 0;
 			break;
=2D		case 2:
=2D			exp->m_exported =3D -1;/* may be exported */
=2D			break;
 		}
 	}
 	endexportent();
@@ -79,7 +75,7 @@ xtab_mount_read(void)
 		return xtab_read(_PATH_PROC_EXPORTS_ALT,
 				 _PATH_PROC_EXPORTS_ALT, 0);
 	} else
=2D		return xtab_read(_PATH_XTAB, _PATH_XTABLCK, 2);
+		return 0;
 }
=20
 int
@@ -135,29 +131,6 @@ xtab_export_write()
 	return xtab_write(_PATH_ETAB, _PATH_ETABTMP, _PATH_ETABLCK, 1);
 }
=20
=2Dint
=2Dxtab_mount_write()
=2D{
=2D	return xtab_write(_PATH_XTAB, _PATH_XTABTMP, _PATH_XTABLCK, 0);
=2D}
=2D
=2Dvoid
=2Dxtab_append(nfs_export *exp)
=2D{
=2D	struct exportent xe;
=2D	int		lockid;
=2D
=2D	if ((lockid =3D xflock(_PATH_XTABLCK, "w")) < 0)
=2D		return;
=2D	setexportent(_PATH_XTAB, "a");
=2D	xe =3D exp->m_export;
=2D	xe.e_hostname =3D exp->m_client->m_hostname;
=2D	putexportent(&xe);
=2D	endexportent();
=2D	xfunlock(lockid);
=2D	exp->m_xtabent =3D 1;
=2D}
=2D
 /*
  * rename newfile onto oldfile unless
  * they are identical
diff --git a/support/include/exportfs.h b/support/include/exportfs.h
index 32d4fe95fd7e..08ef30a2f580 100644
=2D-- a/support/include/exportfs.h
+++ b/support/include/exportfs.h
@@ -96,7 +96,7 @@ typedef struct mexport {
 	struct mexport *	m_next;
 	struct mclient *	m_client;
 	struct exportent	m_export;
=2D	int			m_exported;	/* known to knfsd. -1 means not sure */
+	int			m_exported;	/* known to knfsd. */
 	int			m_xtabent  : 1,	/* xtab entry exists */
 				m_mayexport: 1,	/* derived from xtabbed */
 				m_changed  : 1, /* options (may) have changed */
@@ -150,9 +150,7 @@ int				export_unexport(nfs_export *);
=20
 int				xtab_mount_read(void);
 int				xtab_export_read(void);
=2Dint				xtab_mount_write(void);
 int				xtab_export_write(void);
=2Dvoid				xtab_append(nfs_export *);
=20
 int				secinfo_addflavor(struct flav_info *, struct exportent *);
=20
diff --git a/support/include/nfslib.h b/support/include/nfslib.h
index ddd71ac94aa5..777f398c1486 100644
=2D-- a/support/include/nfslib.h
+++ b/support/include/nfslib.h
@@ -35,15 +35,6 @@
 #ifndef _PATH_IDMAPDCONF
 #define _PATH_IDMAPDCONF	"/etc/idmapd.conf"
 #endif
=2D#ifndef _PATH_XTAB
=2D#define _PATH_XTAB		NFS_STATEDIR "/xtab"
=2D#endif
=2D#ifndef _PATH_XTABTMP
=2D#define _PATH_XTABTMP		NFS_STATEDIR "/xtab.tmp"
=2D#endif
=2D#ifndef _PATH_XTABLCK
=2D#define _PATH_XTABLCK		NFS_STATEDIR "/.xtab.lock"
=2D#endif
 #ifndef _PATH_ETAB
 #define _PATH_ETAB		NFS_STATEDIR "/etab"
 #endif
diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
index 5136810029d0..98368a5ef1e1 100644
=2D-- a/utils/exportfs/exportfs.c
+++ b/utils/exportfs/exportfs.c
@@ -219,8 +219,6 @@ main(int argc, char **argv)
 	xtab_export_write();
 	if (new_cache)
 		cache_flush(force_flush);
=2D	if (!new_cache)
=2D		xtab_mount_write();
=20
 	return export_errno;
 }
@@ -238,7 +236,7 @@ exports_update_one(nfs_export *exp, int verbose)
 		       exp->m_export.e_path, exp->m_export.e_mountpoint);
 		exp->m_mayexport =3D 0;
 	}
=2D	if (exp->m_mayexport && ((exp->m_exported<1) || exp->m_changed)) {
+	if (exp->m_mayexport && exp->m_changed) {
 		if (verbose)
 			printf("%sexporting %s:%s to kernel\n",
 			       exp->m_exported ?"re":"",
diff --git a/utils/mountd/auth.c b/utils/mountd/auth.c
index 0881d9a6edba..b612d88b6143 100644
=2D-- a/utils/mountd/auth.c
+++ b/utils/mountd/auth.c
@@ -46,7 +46,6 @@ void
 auth_init(void)
 {
 	auth_reload();
=2D	xtab_mount_write();
 }
=20
 /*
diff --git a/utils/mountd/mountd.c b/utils/mountd/mountd.c
index 7a51b093f66a..981abd456d91 100644
=2D-- a/utils/mountd/mountd.c
+++ b/utils/mountd/mountd.c
@@ -107,7 +107,6 @@ unregister_services (void)
 static void
 cleanup_lockfiles (void)
 {
=2D	unlink(_PATH_XTABLCK);
 	unlink(_PATH_ETABLCK);
 	unlink(_PATH_RMTABLCK);
 }
@@ -289,7 +288,7 @@ mount_umntall_1_svc(struct svc_req *rqstp, void *UNUSED=
(argp),
 	xlog(D_CALL, "Received UMNTALL request from %s",
 		host_ntop(sap, buf, sizeof(buf)));
=20
=2D	/* Reload /etc/xtab if necessary */
+	/* Reload /etc/exports if necessary */
 	auth_reload();
=20
 	mountlist_del_all(nfs_getrpccaller(rqstp->rq_xprt));
@@ -350,7 +349,7 @@ mount_pathconf_2_svc(struct svc_req *rqstp, dirpath *pa=
th, ppathcnf *res)
 	if (*p =3D=3D '\0')
 		p =3D "/";
=20
=2D	/* Reload /etc/xtab if necessary */
+	/* Reload /etc/exports if necessary */
 	auth_reload();
=20
 	/* Resolve symlinks */
@@ -531,12 +530,6 @@ get_rootfh(struct svc_req *rqstp, dirpath *path, nfs_e=
xport **expret,
 	} else {
 		int did_export =3D 0;
 	retry:
=2D		if (exp->m_exported<1) {
=2D			export_export(exp);
=2D			did_export =3D 1;
=2D		}
=2D		if (!exp->m_xtabent)
=2D			xtab_append(exp);
=20
 		if (v3)
 			fh =3D getfh_size((struct sockaddr_in *)sap, p, 64);
=2D-=20
2.10.1


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCAAGBQJYI8QCAAoJEDnsnt1WYoG5eZYQAKYj+qFJ+S2+fwLNoSDJV0Co
B000anE6wDNoXIzdw9JqlNHRycr9zmzJWgefE9+vENtUfXfJ1IRYGy/Box+2byVT
kYAaHDgUrWr1cutiQwnjCGJ+9e//TdMAzd9uvkNk/USqGKee/vYXbRwfCku685xZ
kFx815ung7HqcbZxYEJt8GXHsXoqRPiBDN1GjkRvlsJFnZ7ypWQj1lOI+eoNDo3W
8FaCeDvCWGbbPaxJaSMJGIlhri+CDoV0dpsUCggBiJrmmOEzEHaG8QFmo1tHuKfh
1JXR2nKNZ5t0ZnjvxfG9/OXkP4GMBr/GN0I+EXQGVyYbhs1Ee7EPLi0PXQ5xzxTF
UFPUEm8lBSysUyRQ4hMMQwTGbcDgArGM2/geoxJlTTBarUvv3Q9Y6cKHE3/YMhcg
GF7tbPW4fCm8fbmj9fyv1Nq6tJwB+48ZldSa1Cb/lH6W+ImzhTb1fXxkHQazcjJw
6KybmPWA80FG1h9QHElvNMVgGOVuVRRxqk+hHYHX4wTCSlyGxfJ1DYQfanSrDxvC
8hr1MN+La5Wv280nhbE3Np6opiT0Iv+W3tK7kbbaXGWf+R9KPHOQsQs3hjoH7v23
WAyH8CjMf7C3lnJNaaXHWAIcSb9RJcAcQoD3RbiFOEEsBS7vCG7kjAgrtMHh5YL3
coR9/bZLsVQ9aOl6hx8r
=VcQ1
-----END PGP SIGNATURE-----
--=-=-=--
