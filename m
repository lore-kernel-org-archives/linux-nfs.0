Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:56639 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751204AbdFECdI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 4 Jun 2017 22:33:08 -0400
From: NeilBrown <neilb@suse.com>
To: util-linux@vger.kernel.org,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Date: Mon, 05 Jun 2017 12:32:58 +1000
Cc: Franck Bui <fbui@suse.com>
Subject: [util-linux PATCH] umount: never 'stat' the path when "-c" is given.
Message-ID: <8760gbduzp.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


It is currently not possible to reliably and automatically
unmount an NFS filesystem. If the server is not available, the
umount command will hang.

The hang can be avoided by using "-l" or "-f", but neither
of these are appropriate for automatic use such as by an
automounter (e.g automountd or systemd).

"-l" will unmount even if the filesystem is in use, which
an automounter generally doesn't want.  If the filesystem
is in use, then the umount should fail.

"-f" can cause the filesystem to abort pending transactions
which might break filesystem semantics.  This can be useful
in the hands of a sysadmin, but not when used by an
automatic tool.

umount has another option, "-c" aka "--no-canonicalize"
which avoids some "stat" calls.
Currently this doesn't avoid all calls to
canonicalize_path()
as
  mnt_context_prepare_umount() ->
    lookup_umount_fs() ->
      mnt_context_find_umount_fs() ->
        mnt_context_get_mtab_for_target() ->
	  mnt_resolve_path() ->
	    canonicalize_path_and_cache() ->
	      canonicalize_path()

leads to that function being called.

The "-c" option could be taken to mean "I know what I'm
doing, this really is the path to a mount point, I just want
you to unmount it".  Given that, it seems suitable to
extend this to avoid all 'stat' calls on the mountpoint.

It is already appropriate for any automount program to pass
"-c" to "umount", so they can be changed to do so at any
time.
With the patch below, "-c" will result in the mountpoint
never being "stat"ed, so umount won't hang on an
inaccessible server.

This isn't quite sufficient, for NFS at least, as the usage
of libmount in umount.nfs still calls 'stat' on the mount
point.
"-c" isn't passed to the umount helper, but it is reasonable
for such helpers to assume "-c" because "umount" will have
canonicalized the path when that is appropriate.

So, this patch treats "-c" much like "-l" and "-f" when
deciding whether it is safe to 'stat' the path.

Signed-off-by: NeilBrown <neilb@suse.com>
=2D--
 libmount/src/context_umount.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/libmount/src/context_umount.c b/libmount/src/context_umount.c
index e663a703cca0..693891def0e1 100644
=2D-- a/libmount/src/context_umount.c
+++ b/libmount/src/context_umount.c
@@ -77,6 +77,7 @@ int mnt_context_find_umount_fs(struct libmnt_context *cxt,
 	 * it's usable only for canonicalized stuff (e.g. kernel mountinfo).
 	 */
 	if (!mnt_context_mtab_writable(cxt) && *tgt =3D=3D '/' &&
+	    !mnt_context_is_nocanonicalize(cxt) &&
 	    !mnt_context_is_force(cxt) && !mnt_context_is_lazy(cxt))
 		rc =3D mnt_context_get_mtab_for_target(cxt, &mtab, tgt);
 	else
@@ -245,6 +246,7 @@ static int lookup_umount_fs(struct libmnt_context *cxt)
 	    && !mnt_context_mtab_writable(cxt)
 	    && !mnt_context_is_force(cxt)
 	    && !mnt_context_is_lazy(cxt)
+	    && !mnt_context_is_nocanonicalize(cxt)
 	    && !mnt_context_is_loopdel(cxt)
 	    && mnt_stat_mountpoint(tgt, &st) =3D=3D 0 && S_ISDIR(st.st_mode)
 	    && !has_utab_entry(cxt, tgt)) {
=2D-=20
2.12.2


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlk0wtwACgkQOeye3VZi
gbkpIQ//e1BnBF2p9IvB/QJHt+1EIrrLseAnVc1TSHj13ncgxQB7+Ajz9zbbhJvb
V2LoXj1hcK/qd5gojbf119H3gkbSsfH8Bo4uT93EnTdKZQ0hgHyhbusOiy3t31v5
t9IsDG1JDQOCXyDue3ZRAKgQPjPbU3j563DUREfLpkuIlgQm08O8+cPROpzYYC2J
l8EpoFZc5zG2p+7s4sEy+GSsyq3qc++JxJW4UfAZEJZq+oocB0jDYgkq8qq/WFKt
641PGKREe3dlaK+oKSeh7Ndsg70/Ai6xrl6IiLWRo9vC0uTogInj57u+Wce1lVJQ
HBOWb5FCWqbsiVCmpfO+WX09tsM47q7+0eoRFzGtx6QDpwQr49EbK/rRL8qXoNJB
N4EV7qAB3epp3feRqioQqz2RXXcGX7Gw0mAOxgdf91YXNKZKtd//sGJkthvJea0D
84AFvQhT2jCG00VCQqefOcw/ANyIaIt5Oar88Ciaj1fSC/PztMkljKH0Rn+gkOfg
NqRyyidHx/ZbRk5G0+ep7j27GLQJtYroaP2562RAMfCriAJXIf0Viogth/zhIuSX
Kp2PejFZa01P7tkxshElewK7tR9iihXNY7fOaR9JDLSSQdElZWTKt3mI7SChEfhU
kgSbOTHqoOidp6yQrRLPlqmGp2oMTF5Ml+/+uMept+kGN/5KcMk=
=zTGE
-----END PGP SIGNATURE-----
--=-=-=--
