Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:52267 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1162359AbdAFDdu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 5 Jan 2017 22:33:50 -0500
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Date: Fri, 06 Jan 2017 14:19:58 +1100
Subject: [PATCH] SUNRPC: two small improvements to rpcauth shrinker.
Message-ID: <87fukwlvs1.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


1/ If we find an entry that is too young to be pruned,
  return SHRINK_STOP to ensure we don't get called again.
  This is more correct, and avoids wasting a little CPU time.
  Prior to 3.12, it can prevent drop_slab() from spinning indefinitely.

2/ Return a precise number from rpcauth_cache_shrink_count(), rather than
  rounding down to a multiple of 100 (of whatever sysctl_vfs_cache_pressure=
 is).
  This ensures that when we "echo 3 > /proc/sys/vm/drop_caches", this cache=
 is
  still purged, even if it has fewer than 100 entires.

Neither of these are really important, they just make behaviour
more predicatable, which can be helpful when debugging related issues.

Signed-off-by: NeilBrown <neilb@suse.com>
=2D--
 net/sunrpc/auth.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index 2bff63a73cf8..d8f17ea7932e 100644
=2D-- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -464,8 +464,10 @@ rpcauth_prune_expired(struct list_head *free, int nr_t=
o_scan)
 		 * Note that the cred_unused list must be time-ordered.
 		 */
 		if (time_in_range(cred->cr_expire, expired, jiffies) &&
=2D		    test_bit(RPCAUTH_CRED_HASHED, &cred->cr_flags) !=3D 0)
+		    test_bit(RPCAUTH_CRED_HASHED, &cred->cr_flags) !=3D 0) {
+			freed =3D SHRINK_STOP;
 			break;
+		}
=20
 		list_del_init(&cred->cr_lru);
 		number_cred_unused--;
@@ -520,7 +522,7 @@ static unsigned long
 rpcauth_cache_shrink_count(struct shrinker *shrink, struct shrink_control =
*sc)
=20
 {
=2D	return (number_cred_unused / 100) * sysctl_vfs_cache_pressure;
+	return number_cred_unused * sysctl_vfs_cache_pressure / 100;
 }
=20
 static void
=2D-=20
2.11.0


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlhvDN4ACgkQOeye3VZi
gbkjRQ/8Crf1MKBFcdzlIYugXJGa/TkdHFmcQBliB8RTi4GrnHkOgiV4YtsLoZl9
HMvemJkqYpkwKSeiR7XAd9jX0n3Oo1BXevn8PoQHrXcMO3Dq8PAGY60jJcmFleij
EJNonLJ96YqWw48kij8xSXt0gmyf2fVpcppVVHFpSgqmmWy+FCOUd0ZozJv7EMWA
+AzPmEEW+2c5mbBSm0SalK7TZjywdxLT73wB5A5CfpARmKIDyus8pEbqWNxXhQuf
oN+nFbVRyZMeudrpM7qkzijgGOuMHu7GVcxBE2UMTI0FwIjpHzi96YnFQc6F9MrS
hHYJLvhejKqlt6gP6Mh2yKNToVlBz+g/6O3YwEBtDJaURmeyXT9nAWPA3XUeFDfB
0KHtWFlzp0/kv62jXX7UnVOlCZicNhaJDvWCxaXztUn9ZrIrE0tR0NkLgOZE2PI8
Sq+ea20NYaiQn6hAhnMquAYmNgP6IlZ4e4Zt35mmuQ1GejuA3+7tS/clwRA5Uaa8
s4tYp09Mz7vK9ONFXFXinnvJY3OAqTxSxw06Uu7KGTo5Dj9NNzb4nuxRyxJkpRdn
yudqkQKT7RqtRxC7yN+wlkC98/vX1kMHGbUUzqnIjI3euRf6hICU9MN07nET+ybp
667sUZW5zt4wRxsrM4Q4zOzFNvOfQ+I9jHUNFhh2CstldptXDfU=
=w3Kg
-----END PGP SIGNATURE-----
--=-=-=--
