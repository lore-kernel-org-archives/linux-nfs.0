Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:55277 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933021AbaDCFrB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Apr 2014 01:47:01 -0400
Received: from relay1.suse.de (charybdis-ext.suse.de [195.135.220.254])
	by mx2.suse.de (Postfix) with ESMTP id 54775ACE0
	for <linux-nfs@vger.kernel.org>; Thu,  3 Apr 2014 05:46:59 +0000 (UTC)
Date: Thu, 3 Apr 2014 16:46:52 +1100
From: NeilBrown <neilb@suse.de>
To: NFS <linux-nfs@vger.kernel.org>
Subject: Should exportfs/mountd cope with case-insensitive directory names.
Message-ID: <20140403164652.5d7770ad@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/aqCsD1AqdPbo=_Z_+/1bWQ1"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/aqCsD1AqdPbo=_Z_+/1bWQ1
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable


Hi,
 I came across an interesting issue recently.

Suppose you have a filesystem which supports case-insensitive file names
(like VFAT, but in this particular case 'NSS' - Novell Storage Services).

And support you export some subdirectory (or sub-volume) using a
non-canonical name.
i.e. you "mkdir /path/export", the put "/path/EXPORT" in /etc/exports and
mount  server:/path/EXPORT from some client.

This all works until the export cache times out and the kernel asks mountd
if "/path/export" is exported.  mountd says "no" and suddenly all accesses
fail.

I don't think much of case-insensitive file names, but I suspect we should
either make this work, it issue a warning as to why it is failing.
A simple work around is to export the canonical name and use it when
mounting.  But if the sysadmin doesn't know they need to, they are unlikely
to guess.

I don't think there is any API to test if a name is canonical, or to get the
canonical name, so I cannot see any way in advance to see if this problem
situation has arisen.  So the only option I can think of is to fix it.

The following patch (or something much like it for an older nfs-utils) seems
to do the trick.

What do people think?  Is this a reasonable thing to do?  Is it likely to
have negative consequences that I haven't thought of?

Thanks,
NeilBrown



diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index 9a1bb2767ac2..2d91db76b867 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -377,6 +377,28 @@ static char *next_mnt(void **v, char *p)
 	return me->mnt_dir;
 }
=20
+static int same_path(char *child, char *parent, int len)
+{
+	static char p[PATH_MAX];
+	struct stat sc, sp;
+	if (len <=3D 0)
+		len =3D strlen(child);
+	strncpy(p, child, len);
+	p[len] =3D 0;
+	if (strcmp(p, parent) =3D=3D 0)
+		return 1;
+
+	if (lstat(p, &sc) !=3D 0)
+		return 0;
+	if (lstat(parent, &sp) !=3D 0)
+		return 0;
+	if (sc.st_dev !=3D sp.st_dev)
+		return 0;
+	if (sc.st_ino !=3D sp.st_ino)
+		return 0;
+	return 1;
+}
+
 static int is_subdirectory(char *child, char *parent)
 {
 	/* Check is child is strictly a subdirectory of
@@ -387,7 +409,7 @@ static int is_subdirectory(char *child, char *parent)
 	if (strcmp(parent, "/") =3D=3D 0 && child[1] !=3D 0)
 		return 1;
=20
-	return (strncmp(child, parent, l) =3D=3D 0 && child[l] =3D=3D '/');
+	return (same_path(child, parent, l) && child[l] =3D=3D '/');
 }
=20
 static int path_matches(nfs_export *exp, char *path)
@@ -396,7 +418,7 @@ static int path_matches(nfs_export *exp, char *path)
 	 * exact match, or does the export have CROSSMOUNT, and path
 	 * is a descendant?
 	 */
-	return strcmp(path, exp->m_export.e_path) =3D=3D 0
+	return same_path(path, exp->m_export.e_path, 0)
 		|| ((exp->m_export.e_flags & NFSEXP_CROSSMOUNT)
 		    && is_subdirectory(path, exp->m_export.e_path));
 }

--Sig_/aqCsD1AqdPbo=_Z_+/1bWQ1
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBUzz1zTnsnt1WYoG5AQLwoRAAjwnQSmNXk/wY3lrv48hCAXS3oHAO8YmU
Y7uHrmJ+abLVmBWxJr+cR8fOW4LX4qz2TvbMu0nqsVF0u76Gc/tZbjsZkjlJW7wg
EvCXMxCaD62pgJxyCr2jvnK8w1wZ3P+lF6r4aqOEVdagddNdzQOjqhLqq+GnDyAP
7xojbMGlNi8y6IG8QQb7d/VQW8z89upm6IKOKTVwThkKoFnjrgUIlZK2MjO85xM/
/I8Ji/leurEbqWN6m7W0YI3/3jzZgOBGEb2GpmrTv32v4hS2Jq0Rj0wLxsmFMf3o
kHGFsGlgkiBrt3RTquW/2JFH+pBj7Cs/8MyKHxSl5SzLAnH4IhqXYBeGlyS2fasZ
oO64XbRPkvMysv78U8cakfcM8PZeZxbbCeawhqVQJESJkA3ERT71v0NHD/iAszuM
7TL1amy/ofXPfcTPRHC+c1OiQbxd88UA1vqD5BewZwghERPJZ+gCy4nNpUc5K6rH
8lS3z9IpnW/bzTiWnqG9I84eBhDHQral1f+lY38jRNE+Ffaj6fkLExnS4jV+BrlY
hPOu3jcvtd33V2Qs8juHzSp6Psw3lMwG6TqospqeukqpcLjyK+7rpRES06UmjG2l
tn0othG9puM7uVhr8k6MVhITNZe0lcGBfcvrLRYI73cTzCf0zXLlI/joSmsNm+sm
Lbfq4lsp5qc=
=fHXe
-----END PGP SIGNATURE-----

--Sig_/aqCsD1AqdPbo=_Z_+/1bWQ1--
