Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:53664 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753185AbcLUDc3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 20 Dec 2016 22:32:29 -0500
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@redhat.com>
Date: Wed, 21 Dec 2016 14:32:19 +1100
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
Subject: [PATCH] NFSD: correctly range-check v4.x minor version when setting versions.
Message-ID: <87bmw6rm7w.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


Writing to /proc/fs/nfsd/versions allows individual major versions
and NFSv4 minor versions to be enabled or disabled.

However NFSv4.0 cannot currently be disabled, thought there is no good reas=
on.
Also the minor number is parsed as a 'long' but used as an 'int'
so '4294967297' will be incorrectly treated as '1'.

This patch removes the test on 'minor =3D=3D 0' and switches to kstrtouint()
to get correct range checking.

When reading from /proc/fs/nfsd/versions, 4.0 is current not reported.
To allow the disabling for v4.0 to be visible, while maintaining
backward compatibility, change code to report "-4.0" if appropriate, but
not "+4.0".

Signed-off-by: NeilBrown <neilb@suse.com>
=2D--
 fs/nfsd/nfsctl.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index f3b2f34b10a3..d54fb0e3f30e 100644
=2D-- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -569,8 +569,7 @@ static ssize_t __write_versions(struct file *file, char=
 *buf, size_t size)
 			if (*minorp =3D=3D '.') {
 				if (num !=3D 4)
 					return -EINVAL;
=2D				minor =3D simple_strtoul(minorp+1, NULL, 0);
=2D				if (minor =3D=3D 0)
+				if (kstrtouint(minorp+1, 0, &minor) < 0)
 					return -EINVAL;
 				if (nfsd_minorversion(minor, sign =3D=3D '-' ?
 						     NFSD_CLEAR : NFSD_SET) < 0)
@@ -613,8 +612,13 @@ static ssize_t __write_versions(struct file *file, cha=
r *buf, size_t size)
 			tlen +=3D len;
 		}
 	if (nfsd_vers(4, NFSD_AVAIL))
=2D		for (minor =3D 1; minor <=3D NFSD_SUPPORTED_MINOR_VERSION;
+		for (minor =3D 0; minor <=3D NFSD_SUPPORTED_MINOR_VERSION;
 		     minor++) {
+			if (minor =3D=3D 0 && nfsd_minorversion(minor, NFSD_TEST))
+				/* for backward compatibility, don't report
+				 * +4.0
+				 */
+				continue;
 			len =3D snprintf(buf, remaining, " %c4.%u",
 					(nfsd_vers(4, NFSD_TEST) &&
 					 nfsd_minorversion(minor, NFSD_TEST)) ?
=2D-=20
2.11.0


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlhZ98MACgkQOeye3VZi
gbngCRAAwEhKMdVLSYEnqvV9UTobHdU1htciaBAlulgvbVc7W5DRLiIl756chxb7
eFpPCrQ1tWCvJCBCi2da3+l7Cyh9PUg+uhzWg4TJUta/GPNe3RmrNzEpn+sS7adv
5TAD5L9xk525Ms4s8orNpcXcQQY9ubQ2gTy+BPzohbLcEpwMVMq8ckglRiip0SMe
1y+DaD5dzqwpHvLVKhvWWBGWWWIgxRVbAOnM2tOBIouMjxJ0x8LlaMkCg0QtzEo5
ZXOProt/hrFMlbajP4ZcD+h2HMIxG/sWq3zJImNUitNjO1cFnKtxi8vVvmidkrR4
FO8X9GzzIkpTKhdoI3sQiwxQQHZ6oU5eR+V4QjnPCXKTmygp80p48+PhvrrWooz+
UwL91CqdCa/SxDRSl/UvzN3ctbHVIEtErPnASD+H0yhT3Ml4BJFjvVgS5mOZCIIW
hB40CPeD6Hq7N9Rsn9juBi3ocjzWmEOZBJVCyqKxP2LCPg76M7MJwNcRzJOVQsdj
uI3SWiPtN5A2rj72vE8oJ+AFrry0nvGz2M12DhXqBWXvcloMPFfeJ1Qr9tMEIRYR
F5UiinKLgDI9dbtSTYtMgvENdr3w2+Emizrcdvt6yFscMDYkCBLnNWXhCjLOp8VT
diG/EharxQoTQ66pOeobPXPFXw0IRAC0bXRXBKf7P67CbhCBZuU=
=H4Co
-----END PGP SIGNATURE-----
--=-=-=--
