Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:52869 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932341Ab2JaBPk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 30 Oct 2012 21:15:40 -0400
Date: Wed, 31 Oct 2012 12:16:01 +1100
From: NeilBrown <neilb@suse.de>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Chuck Lever <chuck.lever@oracle.com>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: [PATCH] NFS: fix bug in legacy DNS resolver.
Message-ID: <20121031121601.5de16a5b@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/+c+HOqW3xiITKgD.nAmi94p"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/+c+HOqW3xiITKgD.nAmi94p
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable


The DNS resolver's use of the sunrpc cache involves a 'ttl' number
(relative) rather that a timeout (absolute).  This confused me when
I wrote
  commit c5b29f885afe890f953f7f23424045cdad31d3e4
     "sunrpc: use seconds since boot in expiry cache"

and I managed to break it.  The effect is that any TTL is interpreted
as 0, and nothing useful gets into the cache.

This patch removes the use of get_expiry() - which really expects an
expiry time - and uses get_uint() instead, treating the int correctly
as a ttl.

This fixes a regression that has been present since 2.6.37, causing
certain NFS accesses in certain environments to incorrectly fail.

Reported-by: Chuck Lever <chuck.lever@oracle.com>
Tested-by: Chuck Lever <chuck.lever@oracle.com>
Cc: stable@vger.kernel.org
Signed-off-by: NeilBrown <neilb@suse.de>

diff --git a/fs/nfs/dns_resolve.c b/fs/nfs/dns_resolve.c
index 31c26c4..d9415a2 100644
--- a/fs/nfs/dns_resolve.c
+++ b/fs/nfs/dns_resolve.c
@@ -217,7 +217,7 @@ static int nfs_dns_parse(struct cache_detail *cd, char =
*buf, int buflen)
 {
 	char buf1[NFS_DNS_HOSTNAME_MAXLEN+1];
 	struct nfs_dns_ent key, *item;
-	unsigned long ttl;
+	unsigned int ttl;
 	ssize_t len;
 	int ret =3D -EINVAL;
=20
@@ -240,7 +240,8 @@ static int nfs_dns_parse(struct cache_detail *cd, char =
*buf, int buflen)
 	key.namelen =3D len;
 	memset(&key.h, 0, sizeof(key.h));
=20
-	ttl =3D get_expiry(&buf);
+	if (get_int(&buf, &ttl) < 0)
+		goto out;
 	if (ttl =3D=3D 0)
 		goto out;
 	key.h.expiry_time =3D ttl + seconds_since_boot();

--Sig_/+c+HOqW3xiITKgD.nAmi94p
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.18 (GNU/Linux)

iQIVAwUBUJB70Tnsnt1WYoG5AQJGvxAAkMlKFbl6Wc12InsKqs89REwZsZAEFp9W
CAQZYo8SeoeLstAawAcpwPiDAfU58yUFNQz8uvtj0nPuJMUioR4boIJ8TQR2+WjK
ForSPX0kau7YUgUcToC+N918qV4EEyCwG5LsUq5M9EIiGuHENs3+hGJTvwtzEd2a
o9SGY1dKQCT5lCwjhl7hRUN/XhXPHKWVSrAvQtN2scQtMprOshFDrso7sak1WUsw
4v8tEVNUuNvBo5Nkavw/g0OCgRxo+GLRDjZQWIjPDzF7qvJlBe3x1uta0ieLfxwV
I8wW6X4q0zeqC8yg7Q+8A7ytpdkUF6w6slOvnmCrD/dKzJfAUvkLXmMfJGepjNRd
Drq2tnmljBnqk5GX0JA0zqq8otG5MTHAoUN2MDERnJ/EeKF8um00qXdaCN4qY31u
UiKQrzPHjLUYYPbUyCZGsWgADG5CVGXRTcySmLbDP3aNYtSgyWwYqqhy8mDCH2Zj
wJHdRFbnW54I+/wc103+qdkiyEuJx+a9Q6wnsxbVzlSINfARLU/wCVf4wmY163R8
+7+Vo03KQeBGbKuh4LLdOytBECaK8ep6pTSc6wTQY/RI/BS0odE29PdRdaPJR3qy
FRKTTF4i+T2Cj51ZrPvZYkOkIJoAnxpUEJraDWMFfs4UboauGYkVY3wiWyYLYvdH
WAFqeTN8egs=
=cw/S
-----END PGP SIGNATURE-----

--Sig_/+c+HOqW3xiITKgD.nAmi94p--
