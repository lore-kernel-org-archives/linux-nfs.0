Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:45533 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750754AbcFBGbK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 2 Jun 2016 02:31:10 -0400
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Date: Thu, 02 Jun 2016 16:31:03 +1000
Cc: NFS List <linux-nfs@vger.kernel.org>
Subject: [PATCH] sunrpc: remove 'inuse' flag from struct cache_detail.
Message-ID: <87inxsp0ew.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


This field is not currently in use.

Signed-off-by: NeilBrown <neilb@suse.com>
=2D--

I recently noticed this and wondered what it was for. "Nothing" seems to
be the answer..

NeilBrown


 include/linux/sunrpc/cache.h | 2 --
 net/sunrpc/cache.c           | 2 +-
 2 files changed, 1 insertion(+), 3 deletions(-)

diff --git a/include/linux/sunrpc/cache.h b/include/linux/sunrpc/cache.h
index ed03c9f7f908..62a60eeacb0a 100644
=2D-- a/include/linux/sunrpc/cache.h
+++ b/include/linux/sunrpc/cache.h
@@ -78,8 +78,6 @@ struct cache_detail {
 	struct hlist_head *	hash_table;
 	rwlock_t		hash_lock;
=20
=2D	atomic_t		inuse; /* active user-space update or lookup */
=2D
 	char			*name;
 	void			(*cache_put)(struct kref *);
=20
diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 553bf95f7003..4d8e11f94a35 100644
=2D-- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -362,7 +362,7 @@ void sunrpc_destroy_cache_detail(struct cache_detail *c=
d)
 	cache_purge(cd);
 	spin_lock(&cache_list_lock);
 	write_lock(&cd->hash_lock);
=2D	if (cd->entries || atomic_read(&cd->inuse)) {
+	if (cd->entries) {
 		write_unlock(&cd->hash_lock);
 		spin_unlock(&cache_list_lock);
 		goto out;
=2D-=20
2.8.3


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJXT9KnAAoJEDnsnt1WYoG53MUQAJoN2Gvu5iOENav85SwXctdb
nBW3WtTuz7I71l0QbeAz0bQf9h0RrH8bBAzi7/HwMF6E+hWwKuIn9wsWS/jrTu3h
mTzLRq2SnHHorE+hSWZTZqSBDgyb3YfZxabucVsv7xKehe6cE1Bpebwmuz68fHNg
6ETVfwlKMA6QLQDMcQmJ/T3ffwj0h1kmeqenrUVSh7y3IeHxHqL/OdEUmFr+IlAC
dQ9cSfIYHXeAY+BdWcyZzfRsdDs5SSxyycQNDzy3x9mS0VUhamfNMQLSdOCldEfU
hkSnbaQ+YhQhQQW4UzQXy3UiK2GxpGf/HZ3N3P1qWmTLxU/An8svUHz7KZIfVXZ2
0NFKXo2LkW02J3O9G3iWvzqqpsN5HtDKXKz+t+NBMKdITl8YTr8DcFiF22o4Cc5E
5visXgsZ/BrdCLzY5bd3f9OKiC5rQJv/gQ6G7nZJO0sMRE+oNYNz8DngvwDVwwR1
bsBixuOzysRYVSE8ZNP4Lnk6G25s1LgsN6y7KbR2FriMRIHcnYolNebJEI7M/8gJ
ThV9MX83r5Nu27tGWHEGl1lP5tUfD8ymZ/ZAiI5gGOj+gi/KLBN9/8+pS3D5tuzv
z+scM8x2jWBVlenn21WF4tamIDmQm+GeR0pK0BIxzaacF30LI08L/sRadiGyylHz
QjayDrcF3Xgy45zdzy7v
=2uKH
-----END PGP SIGNATURE-----
--=-=-=--
