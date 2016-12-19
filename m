Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:51246 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751396AbcLSAdV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 18 Dec 2016 19:33:21 -0500
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Date: Mon, 19 Dec 2016 11:33:13 +1100
Cc: Jeff Layton <jlayton@redhat.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc: Benjamin Coddington <bcodding@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH] NFSv4: ensure __nfs4_find_lock_state returns consistent result.
In-Reply-To: <1476442146.2546.1.camel@redhat.com>
References: <147633263771.766.17853370901003798934.stgit@noble> <147633280755.766.16463067741350482818.stgit@noble> <1476372136.12134.12.camel@redhat.com> <87shrzzsnq.fsf@notabene.neil.brown.name> <1476442146.2546.1.camel@redhat.com>
Message-ID: <8737hkvjue.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


If a file has both flock locks and OFD locks, then it is possible that
two different nfs4 lock states could apply to file accesses from a
single process.

It is not possible to know, efficiently, which one is "correct".
Presumably the state which represents a lock that covers the region
undergoing IO would be the "correct" one to use, but finding that has
a non-trivial cost and would provide miniscule value.

Currently we just return whichever is first in the list, which could
result in inconsistent behaviour if an application ever put it self in
this position.  As consistent behaviour is preferable (when perfectly
correct behaviour is not available), change the search to return a
consistent result in this circumstance.
Specifically: if there is both a flock and OFD lock state, always return
the flock one.

Reviewed-by: Jeff Layton <jlayton@redhat.com>
Signed-off-by: NeilBrown <neilb@suse.com>
=2D--

Hi Trond,
 thanks for applying my recent lock-state management series.
 This patch was missed, probably because it was buried in a reply to a
 conversation.  Sorry about that.

 It is not a critical fix, but it does complete the series.

Thanks,
NeilBrown


 fs/nfs/nfs4state.c | 28 ++++++++++++++++++++--------
 1 file changed, 20 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 95baf7d340f0..cf869802ff23 100644
=2D-- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -797,21 +797,33 @@ void nfs4_close_sync(struct nfs4_state *state, fmode_=
t fmode)
=20
 /*
  * Search the state->lock_states for an existing lock_owner
=2D * that is compatible with current->files
+ * that is compatible with either of the given owners.
+ * If the second is non-zero, then the first refers to a Posix-lock
+ * owner (current->files) and the second refers to a flock/OFD
+ * owner (struct file*).  In that case, prefer a match for the first
+ * owner.
+ * If both sorts of locks are held on the one file we cannot know
+ * which stateid was intended to be used, so a "correct" choice cannot
+ * be made.  Failing that, a "consistent" choice is preferable.  The
+ * consistent choice we make is to prefer the first owner, that of a
+ * Posix lock.
  */
 static struct nfs4_lock_state *
 __nfs4_find_lock_state(struct nfs4_state *state,
 		       fl_owner_t fl_owner, fl_owner_t fl_owner2)
 {
=2D	struct nfs4_lock_state *pos;
+	struct nfs4_lock_state *pos, *ret =3D NULL;
 	list_for_each_entry(pos, &state->lock_states, ls_locks) {
=2D		if (pos->ls_owner !=3D fl_owner &&
=2D		    pos->ls_owner !=3D fl_owner2)
=2D			continue;
=2D		atomic_inc(&pos->ls_count);
=2D		return pos;
+		if (pos->ls_owner =3D=3D fl_owner) {
+			ret =3D pos;
+			break;
+		}
+		if (pos->ls_owner =3D=3D fl_owner2)
+			ret =3D pos;
 	}
=2D	return NULL;
+	if (ret)
+		atomic_inc(&ret->ls_count);
+	return ret;
 }
=20
 /*
=2D-=20
2.11.0


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlhXKskACgkQOeye3VZi
gblP3A/+M4J4WPfWTf2OMML6C1onIPloF2+jd8jDVQVIZRklMI4xCnnHkyZYK8qb
gPfYH5JWce313RSDqNYtwUnZwJUSxel3avMx0WDN5p6uLIOfOC3Rc+AT8evocx4F
yVXcErTBxRiBV0OupIMkQLIGwwNLy21Uwi37slLIMlXQmWZwUCHB8+S0pK5dZfWE
amZzAhZhlJ8YNEhgx9q3Ylyhrxp3pvIG24mM5dXjqAnNeTnWvBhIfJlnJ3DCrae8
wNWnfHRgajk/dwHJ8p2vfPYvCED6wR6634LcJfsxBO5Mvrfm5DN/T/7RGn26KPD0
g9HhKNgmagz7lE/qrK+zZApuV95JP85WhxqMDaNhk+0WPGnIc/pCADZBHzG2YW3/
yL+VGeq0WEeIcruDd53Emqh0lEEmkpaV3RLekti/pc2dvY4iBP2i+7UhZ8gvcInN
LBtr1bOfhRe4OAVm5CHNSwzY4csnuaX2J3bHeFIqS0YA+EY1M12OMZwrfneUH3m+
kQwMqTacZVTAmP8bKTJdNN5S+pJZf4C1lgoFwnoVXELPXnRQLvzaJhsCZT3gottS
GwDWmQnVQ0PX6jSbm9Qhlq4+z/Oc3gsL8znUYs6VBq5bQoD2P4yWn21/eEZ08uUx
n6rHcXqFd0iqEiZI07nnhRr4GspMuRVOo7ejMq8oG8ew8bGTliE=
=VT7w
-----END PGP SIGNATURE-----
--=-=-=--
