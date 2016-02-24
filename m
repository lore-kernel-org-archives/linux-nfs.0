Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:51477 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756160AbcBXDy0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Feb 2016 22:54:26 -0500
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Date: Wed, 24 Feb 2016 14:54:18 +1100
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH - nfsv4-acl-tools] nfs4_ace_from_string: ignore inheritance ACEs on
 non-directories.
Message-ID: <8760xen4ph.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


If you try to use
     nfs4_setfacl -R -a A:d:........   directory

to recursively set an inheritance ACE on all directories in a tree, it
will fail on the first non-directory as setting an inheritance ACE
there is not permitted (and as it aborts on the first sign of an error).

So use the is_dir flag to avoid doing that, just as is done with the
DELETE_CHILD permission.

Signed-off-by: NeilBrown <neilb@suse.com>
=2D--

Hi Bruce,
 are you still maintaining nfsv4-acl-tools?  Last commit was over
 a year ago!! I guess that means it is nearly perfect :-)
=20
 A customer came across this problem and it seems simple to fix,
 but if I'm missing something important, please let me know.

NeilBrown


 libnfs4acl/nfs4_ace_from_string.c | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/libnfs4acl/nfs4_ace_from_string.c b/libnfs4acl/nfs4_ace_from_s=
tring.c
index 510ffee35d32..a7a30360d860 100644
=2D-- a/libnfs4acl/nfs4_ace_from_string.c
+++ b/libnfs4acl/nfs4_ace_from_string.c
@@ -185,16 +185,20 @@ struct nfs4_ace * nfs4_ace_from_string(char *ace_buf,=
 int is_dir)
 	for (buflen =3D strlen(field); buflen > 0; buflen--) {
 		switch (*field) {
 			case FLAG_FILE_INHERIT:
=2D				flags |=3D NFS4_ACE_FILE_INHERIT_ACE;
+				if (is_dir)
+					flags |=3D NFS4_ACE_FILE_INHERIT_ACE;
 				break;
 			case FLAG_DIR_INHERIT:
=2D				flags |=3D NFS4_ACE_DIRECTORY_INHERIT_ACE;
+				if (is_dir)
+					flags |=3D NFS4_ACE_DIRECTORY_INHERIT_ACE;
 				break;
 			case FLAG_NO_PROPAGATE_INHERIT:
=2D				flags |=3D NFS4_ACE_NO_PROPAGATE_INHERIT_ACE;
+				if (is_dir)
+					flags |=3D NFS4_ACE_NO_PROPAGATE_INHERIT_ACE;
 				break;
 			case FLAG_INHERIT_ONLY:
=2D				flags |=3D NFS4_ACE_INHERIT_ONLY_ACE;
+				if (is_dir)
+					flags |=3D NFS4_ACE_INHERIT_ONLY_ACE;
 				break;
 			case FLAG_SUCCESSFUL_ACCESS:
 				flags |=3D NFS4_ACE_SUCCESSFUL_ACCESS_ACE_FLAG;
=2D-=20
2.7.1


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJWzSlqAAoJEDnsnt1WYoG5tFkP/0N0DvTEAa3nWCPXFwLMNgLH
jbtgt4gySQqb6P8VyKg8mncUmWT10iXxG8WPV7zB3k5dsdQEmKYTfIDOWn3O3y/X
IT8Ziwlay2rJzP6cCnFd6Of7KC/81gMqAxwlEIFN6Q0UuhXQibUuHz3iTzq15OGk
M+okJAU5H9hl0cX4WaA3qE3f26eOUImti9DkW7lqVAlpboxHi2iQ40EFke0lzxaT
L3zWGZS/tmqes75eUYpj/ye3qxZVWddEKzxwJiv22wjTkvxRQz1hh893kMbDdKCu
j66MpuISTSt2cic7xnwyPcVCR7Ya1iG5Nfj3R7LeDzSmBVdlId9p+iCwVCDD1j3/
bZU4IjJQXXPZWYimyzGrpbWReNQKaHxZYFQKEH2I559TjmTBw31V9ASr0qr0+0Zz
7Fk9/s90JhdPBOCONJWTl5sVVAi3LI/iDVAX/dkjeukMKrZ44GTZl7kckvQPkPb7
o9betyB7wyw0V7qKrb2oL4wd1gItc10iFqm1QBzbeFnGd7kNoS+KPrEHXUTXqe1j
Vz7+h9pVWzhAk4Bz1wzoqR0ZAIkrJPX4D/Gv5O6nvWpbey5bTj1J+kH3XWM17NIA
nmSsUyKEweYqnR31aJ1M9Aam4fyEk6lLbraj+wd4T/UuEe82QunLIWGqnolQKAkn
IKADGOP4s6FBfibB/UQt
=2Ktn
-----END PGP SIGNATURE-----
--=-=-=--
