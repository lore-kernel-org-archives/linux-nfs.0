Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:41638 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751913AbdBHDyL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 7 Feb 2017 22:54:11 -0500
From: NeilBrown <neilb@suse.com>
To: steved@redhat.com
Date: Wed, 08 Feb 2017 13:03:51 +1100
Subject: [PATCH] nfs-server-generator: handle 'noauto' mounts correctly.
cc: linux-nfs@vger.kernel.org
Message-ID: <87poitv3p4.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


When this code was written, the systemd documentation stated
that "RequiresMountsFor" ignored mountpoints marked as "noauto".
Unfortunately this is incorrect.  Consquently a filesystem marked
as noauto that is also NFS exported will currently be mounted when
the NFS server is started. This is not what people expect.

So add a check for the noauto flag.  If any ancestor of a given
export point has the noauto flag, no RequiresMountsFor will be
generated for that point.

Also skip RequiresMountsFor for exports marked 'mountpoint', as their
absence is, theoretically, already handled by mountd.

URL: https://github.com/systemd/systemd/issues/5249
Signed-off-by: NeilBrown <neilb@suse.com>
=2D--
 systemd/nfs-server-generator.c | 26 ++++++++++++++++++++++++++
 1 file changed, 26 insertions(+)

diff --git a/systemd/nfs-server-generator.c b/systemd/nfs-server-generator.c
index cc99969e9922..4aa65094ca07 100644
=2D-- a/systemd/nfs-server-generator.c
+++ b/systemd/nfs-server-generator.c
@@ -84,6 +84,28 @@ static void systemd_escape(FILE *f, char *path)
 	}
 }
=20
+static int has_noauto_flag(char *path)
+{
+	FILE		*fstab;
+	struct mntent	*mnt;
+
+	fstab =3D setmntent("/etc/fstab", "r");
+	if (!fstab)
+		return 0;
+
+	while ((mnt =3D getmntent(fstab)) !=3D NULL) {
+		int l =3D strlen(mnt->mnt_dir);
+		if (strncmp(mnt->mnt_dir, path, l) !=3D 0)
+			continue;
+		if (path[l] && path[l] !=3D '/')
+			continue;
+		if (hasmntopt(mnt, "noauto"))
+			break;
+	}
+	fclose(fstab);
+	return mnt !=3D NULL;
+}
+
 int main(int argc, char *argv[])
 {
 	char		*path;
@@ -124,6 +146,10 @@ int main(int argc, char *argv[])
 		for (exp =3D exportlist[i].p_head; exp; exp =3D exp->m_next) {
 			if (!is_unique(&list, exp->m_export.e_path))
 				continue;
+			if (exp->m_export.e_mountpoint)
+				continue;
+			if (has_noauto_flag(exp->m_export.e_path))
+				continue;
 			if (strchr(exp->m_export.e_path, ' '))
 				fprintf(f, "RequiresMountsFor=3D\"%s\"\n",
 					exp->m_export.e_path);
=2D-=20
2.11.0


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAliafIcACgkQOeye3VZi
gbk8MQ//dmpwS3osXF2WeWCdqZLH/PjSuAG63fvaSkFHNS0I7czK2sh05aVdTk2O
80ZtJjkLZZ0cthX//1fvFEBmaOKxaJFfaPlxb1xquvIBvnd1BgMr8w61atQQ+Tsm
Jo8j7otADb/V0h7S68Afb5LbMJQKpLBulU+hnXo4RJnpJpn4q4XDJvzxhQqYv21Q
mt6VlZ8+HiAV/kPYgmBKs/lgG4MeiKGeAZRluIOv313rQovUjnMsoLPQyroM6nal
x8WIqKPBBuhGHPT4aJ+26WgOQcjBo0RI07IJy+XN+GX11gdLwY1c1l7K3t7FcuXP
gC63bhe18ovyiD5BFuJvzE+9hkvxsszPuXZoXaEl8s+D2dP3bQ1umK5iK1kmrSVL
h/kXfrmLkmdDQ2WIU20/0O6ge9heDqSg84wGzOeZRNHSOOc4tRIpsOMS2w3aXHl0
uAss2JLQkAKCR9KhzrRAygwTYrYu88AcU4pg2L/snDqSlL3Yc25Wu94UVyAs1a5a
WmkiSsZXbreqd0pcLTrolHT9gSpvN9KSBEBxtRoi+CDRvSvMI6a/0VIMR5FRScKQ
LA3Pm38cG4b5W50faFZ3kH3ZJFiUq1t+RTweO1r7Gi9RW2NIaNCadpdtgaf8DmFj
2rIh6WeLHsxmgYdWHb028crXgw3PXAoK3ROizl3EDtdtlVrrfJ8=
=spf9
-----END PGP SIGNATURE-----
--=-=-=--
