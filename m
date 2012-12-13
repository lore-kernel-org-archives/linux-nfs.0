Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:34598 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754962Ab2LMAX5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 Dec 2012 19:23:57 -0500
Date: Thu, 13 Dec 2012 11:23:42 +1100
From: NeilBrown <neilb@suse.de>
To: Steve Dickson <SteveD@redhat.com>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: [nfs-utils PATCH] mountd: fix is_subdirectory to understand '/'
Message-ID: <20121213112342.720ddc6d@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/24sihv0PBWuXncYMH6ZmvAY"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/24sihv0PBWuXncYMH6ZmvAY
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable


The is_subdirectory() function checks if a given 'child' is a subdirectory
of the given 'parent'.
However it always fails if 'parent' =3D=3D "/"  (because 'child' doesn't be=
gin
with 'parent' followed by "/").

So change is_subdirectory() to special-case "/".

subexport() also tests if one directory is a subdirectory of the
other, and contains the same bug.  So change it to use is_subdirectory().

Finally, move is_subdirectory() and related path_matches() and
export_matches() earlier in the file to avoid a forward-reference.

This patch fixes a bug wherein if you export "/" with 'crossmnt', the
crossmnt flag is ineffective and you can only access the root
filesystem, not any descendants.

Signed-off-by: NeilBrown <neilb@suse.de>

diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index 3853bb6..45012be 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -343,6 +343,30 @@ static char *next_mnt(void **v, char *p)
 	return me->mnt_dir;
 }
=20
+static int is_subdirectory(char *child, char *parent)
+{
+	size_t l =3D strlen(parent);
+
+	if (strcmp(parent, "/") =3D=3D 0)
+		return 1;
+
+	return strcmp(child, parent) =3D=3D 0
+		|| (strncmp(child, parent, l) =3D=3D 0 && child[l] =3D=3D '/');
+}
+
+static int path_matches(nfs_export *exp, char *path)
+{
+	if (exp->m_export.e_flags & NFSEXP_CROSSMOUNT)
+		return is_subdirectory(path, exp->m_export.e_path);
+	return strcmp(path, exp->m_export.e_path) =3D=3D 0;
+}
+
+static int
+export_matches(nfs_export *exp, char *dom, char *path, struct addrinfo *ai)
+{
+	return path_matches(exp, path) && client_matches(exp, dom, ai);
+}
+
 /* True iff e1 is a child of e2 and e2 has crossmnt set: */
 static bool subexport(struct exportent *e1, struct exportent *e2)
 {
@@ -350,8 +374,7 @@ static bool subexport(struct exportent *e1, struct expo=
rtent *e2)
 	size_t l2 =3D strlen(p2);
=20
 	return e2->e_flags & NFSEXP_CROSSMOUNT
-	       && strncmp(p1, p2, l2) =3D=3D 0
-	       && p1[l2] =3D=3D '/';
+		&& is_subdirectory(p1, p2);
 }
=20
 struct parsed_fsid {
@@ -752,27 +775,6 @@ static int dump_to_cache(FILE *f, char *domain, char *=
path, struct exportent *ex
 	return qword_eol(f);
 }
=20
-static int is_subdirectory(char *child, char *parent)
-{
-	size_t l =3D strlen(parent);
-
-	return strcmp(child, parent) =3D=3D 0
-		|| (strncmp(child, parent, l) =3D=3D 0 && child[l] =3D=3D '/');
-}
-
-static int path_matches(nfs_export *exp, char *path)
-{
-	if (exp->m_export.e_flags & NFSEXP_CROSSMOUNT)
-		return is_subdirectory(path, exp->m_export.e_path);
-	return strcmp(path, exp->m_export.e_path) =3D=3D 0;
-}
-
-static int
-export_matches(nfs_export *exp, char *dom, char *path, struct addrinfo *ai)
-{
-	return path_matches(exp, path) && client_matches(exp, dom, ai);
-}
-
 static nfs_export *
 lookup_export(char *dom, char *path, struct addrinfo *ai)
 {

--Sig_/24sihv0PBWuXncYMH6ZmvAY
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUMkgDjnsnt1WYoG5AQKpiBAArcWvOW7DIwtYSgx414d8jszH6Avhghtf
BGnIo/eehJ1Jf/x4usDBI+1TJAj0VgbRLXXhzHZHzBLbSQ2VLd4YXrA1nIsLn7PU
Ti4/V7fZjCYpT9w39mt2RhT5Vf1SatTNa8GJvCzu9LGz+2JVOU1su1+5+rtXolLP
4+XwOmCoot/vVpB21iidismR620CApiQR4EVoDimnYTanXayewLSiOnRKHQb3XyM
f0VLkplA/VFWwAtzEuRXU+YE5PJ75YCkFt93gVWW2O25iayI3sOQ0FOm863Z4wL5
z9MnrzOObqBlbCN5za+6GLK717LVfpTUFpRE2hwyuGkivfWoRFncb2PAA4hzIo3a
HKqss0X+ljuGoAWBTgig03+AgiUbsui24nBdJ7Xc9wfa6hej/+XjIk88d+FSM6RW
agoV8eVcLbKukTOJbMpHoBAdhAbKmvc1KzmCSf7KlYFpX1vUJR+1b0LKzyIo7V31
XG93+Z3hMVULEc1LzEGtDP4jqYQnXiXuh0wFRJvJ6kJ73dorjzE8Cm1fdamfeqEH
mo+3B15GFfWMs9uV0t5vZAp08vCRSAbG8qJ3CYJyfUprdQBuHFyiB8Vol8WYGW+R
sP+7ewXXN4EhSovvYLHB7ma9AxhIO5AGBiyTa1QfeY3XJv2FKeyQqisHj6p7w3n3
RMov6NVVvvM=
=b3oM
-----END PGP SIGNATURE-----

--Sig_/24sihv0PBWuXncYMH6ZmvAY--
