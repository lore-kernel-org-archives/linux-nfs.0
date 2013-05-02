Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:56810 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753754Ab3EBHFV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 2 May 2013 03:05:21 -0400
Date: Thu, 2 May 2013 17:05:11 +1000
From: NeilBrown <neilb@suse.de>
To: Steve Dickson <SteveD@redhat.com>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: [PATCH] mountd: Fix is_subdirectory again.
Message-ID: <20130502170511.646e2717@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/rMHGdUe3JJLpMJGTAxBcYPW"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/rMHGdUe3JJLpMJGTAxBcYPW
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable



Hi Steve,
 I just noticed

commit ebe2826ca571a3959c3b5c8e29686c621f2775cf
Author: Steve Dickson <steved@redhat.com>
Date:   Sat Mar 23 10:30:17 2013 -0400

    mountd: regression in crossmounts

Sorry I missed the email you presumably sent me to let me know
that I had caused a regression.

Here is the proper fix.

Thanks,
NeilBrown


Subject: [PATCH] mountd: Fix is_subdirectory again.

commit ebe2826ca571a (mountd: regression in crossmounts)
said it was:
    Reverting the logic of commit 8e2fb3fc until
    a better solution can be found for the original
    problem.

here is the "something better".

The problem was that is_subdirectory() would also succeed if the two
directories were the same.  This is needed for path_matches() which
needs to see if the child is same-or-descendant.

So this patch rearranges path_matches() to do the "are they the same"
test itself and only bother with is_subdirectory() if it they are not
the same.

So now is_subdirectory() can be strict, and so can be usable for
subexport(), which needs a strong 'in subdirectory - not the same' test.

Signed-off-by: NeilBrown <neilb@suse.de>

diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index 737927c..517aa62 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -347,20 +347,26 @@ static char *next_mnt(void **v, char *p)
=20
 static int is_subdirectory(char *child, char *parent)
 {
+	/* Check is child is strictly a subdirectory of
+	 * parent or a more distant descendant.
+	 */
 	size_t l =3D strlen(parent);
=20
-	if (strcmp(parent, "/") =3D=3D 0)
+	if (strcmp(parent, "/") =3D=3D 0 && child[1] !=3D 0)
 		return 1;
=20
-	return strcmp(child, parent) =3D=3D 0
-		|| (strncmp(child, parent, l) =3D=3D 0 && child[l] =3D=3D '/');
+	return (strncmp(child, parent, l) =3D=3D 0 && child[l] =3D=3D '/');
 }
=20
 static int path_matches(nfs_export *exp, char *path)
 {
-	if (exp->m_export.e_flags & NFSEXP_CROSSMOUNT)
-		return is_subdirectory(path, exp->m_export.e_path);
-	return strcmp(path, exp->m_export.e_path) =3D=3D 0;
+	/* Does the path match the export?  I.e. is it an
+	 * exact match, or does the export have CROSSMOUNT, and path
+	 * is a descendant?
+	 */
+	return strcmp(path, exp->m_export.e_path) =3D=3D 0
+		|| ((exp->m_export.e_flags & NFSEXP_CROSSMOUNT)
+		    && is_subdirectory(path, exp->m_export.e_path));
 }
=20
 static int
@@ -369,15 +375,13 @@ export_matches(nfs_export *exp, char *dom, char *path=
, struct addrinfo *ai)
 	return path_matches(exp, path) && client_matches(exp, dom, ai);
 }
=20
-/* True iff e1 is a child of e2 and e2 has crossmnt set: */
+/* True iff e1 is a child of e2 (or descendant) and e2 has crossmnt set: */
 static bool subexport(struct exportent *e1, struct exportent *e2)
 {
 	char *p1 =3D e1->e_path, *p2 =3D e2->e_path;
-	size_t l2 =3D strlen(p2);
=20
 	return e2->e_flags & NFSEXP_CROSSMOUNT
-		&& strncmp(p1, p2, l2) =3D=3D 0
-		&& p1[l2] =3D=3D '/';
+		&& is_subdirectory(p1, p2);
 }
=20
 struct parsed_fsid {

--Sig_/rMHGdUe3JJLpMJGTAxBcYPW
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUYIQJznsnt1WYoG5AQK1mA//Xq5+eB1PAzM+EYzrrDKhbUPxoT9bDJhx
/WCPFH7u3BMXm2GYo8iouQKK/+PFy+RfTJoRkOsXBmaFC0dsPauwGc9vAJso86We
njRxNjwghW05l8XIjdxOGUKyXtq2R4sJgSzNaQPzSw73d03biS6ZrGRHY0nfQd/L
2u6TjWmLYqsshV3gfBsFFMMUopqAwHcZbo9upQFDEmI64z2eiEomR+TYPTyK24/G
9fRCOBHz39ZxgYKLegNrB/yuSdFTjdAZvm4P/fn5oW1MaoVWmdifdEHL35rMlxIA
tZMXVanU1bgn1ci3vERJjSuHU9xnB0lVsnsN/PDc0TW/2tQ1FReCIoS3geuelZ36
aYbgNJOKh47nSNqIDIUPu0obtyjMdtTw0kgvTul61nscJ6duZbZ+eaGOL7wSzrgl
KJnf+2Zwofm6qwlCyBI1vSiMyZt9xTwLanlvhfZnZfs01o1SMSxtRZrYLBjU85RN
f70cdHaEFfnxHknN5x2dT0BkUPaH4AKHnZ6wvLuuCPxo2UzfnQ63jM7TeXG5oBMH
lzuAUHBIXXextWu0k10JlaOJ7FkXO841zgwebgI0JOOUURf1oxquTeCreECHZ6WN
u9i7rsB87UYzupfZyFENRh9WP0kc6XF3heO+/4F4zwpvSbt2q6I1cZ79iLjUmcrK
dcaDSdFN6Qo=
=ehHy
-----END PGP SIGNATURE-----

--Sig_/rMHGdUe3JJLpMJGTAxBcYPW--
