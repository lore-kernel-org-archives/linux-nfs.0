Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:51778 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750914AbcLSAsf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 18 Dec 2016 19:48:35 -0500
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trondmy@primarydata.com>
Date: Mon, 19 Dec 2016 11:48:23 +1100
Cc: Schumaker Anna <anna.schumaker@netapp.com>,
        List Linux NFS Mailing <linux-nfs@vger.kernel.org>
Subject: [PATCH resend] NFS: Don't disconnect open-owner on NFS4ERR_BAD_SEQID
In-Reply-To: <8737k2354z.fsf@notabene.neil.brown.name>
References: <87y46monel.fsf@notabene.neil.brown.name> <87bmyx3q3u.fsf@notabene.neil.brown.name> <C37BA8D0-2EAF-41D7-9086-D8729D4BAD48@primarydata.com> <8737k2354z.fsf@notabene.neil.brown.name>
Message-ID: <87zijsu4ko.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


When an NFS4ERR_BAD_SEQID is received the open-owner is removed from
the ->state_owners rbtree so that it will no longer be used.

If any stateids attached to this open-owner are still in use, and if a
request using one gets an NFS4ERR_BAD_STATEID reply, this can for bad.

The state is marked as needing recovery and the nfs4_state_manager()
is scheduled to clean up.  nfs4_state_manager() finds states to be
recovered by walking the state_owners rbtree.  As the open-owner is
not in the rbtree, the bad state is not found so nfs4_state_manager()
completes having done nothing.  The request is then retried, with a
predicatable result (indefinite retries).

If the stateid is for a delegation, this open_owner will be used
to open files when the delegation is returned.  For that to work,
a new open-owner needs to be presented to the server.

This patch changes NFS4ERR_BAD_SEQID handling to leave the open-owner
in the rbtree but updates the 'create_time' so it looks like a new
open-owner.  With this the indefinite retries no longer happen.

Signed-off-by: NeilBrown <neilb@suse.com>
=2D--

Hi Trond,
 It appears this one got lost too.
 I've added a comment as I thought an explanation was needed, and
 renamed the function from "drop" to "reset".

Thanks,
NeilBrown

 fs/nfs/nfs4state.c | 29 +++++++++++++----------------
 1 file changed, 13 insertions(+), 16 deletions(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index cf869802ff23..1d152f4470cd 100644
=2D-- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -494,21 +494,18 @@ nfs4_alloc_state_owner(struct nfs_server *server,
 }
=20
 static void
=2Dnfs4_drop_state_owner(struct nfs4_state_owner *sp)
=2D{
=2D	struct rb_node *rb_node =3D &sp->so_server_node;
=2D
=2D	if (!RB_EMPTY_NODE(rb_node)) {
=2D		struct nfs_server *server =3D sp->so_server;
=2D		struct nfs_client *clp =3D server->nfs_client;
=2D
=2D		spin_lock(&clp->cl_lock);
=2D		if (!RB_EMPTY_NODE(rb_node)) {
=2D			rb_erase(rb_node, &server->state_owners);
=2D			RB_CLEAR_NODE(rb_node);
=2D		}
=2D		spin_unlock(&clp->cl_lock);
=2D	}
+nfs4_reset_state_owner(struct nfs4_state_owner *sp)
+{
+	/* This state_owner is no longer usable, but must
+	 * remain in place so that state recovery can find it
+	 * and the opens associated with it.
+	 * It may also be used for new 'open' request to
+	 * return a delegation to the server.
+	 * So update the 'create_time' so that it looks like
+	 * a new state_owner.  This will cause the server to
+	 * request an OPEN_CONFIRM to start a new sequence.
+	 */
+	sp->so_seqid.create_time =3D ktime_get();
 }
=20
 static void nfs4_free_state_owner(struct nfs4_state_owner *sp)
@@ -1113,7 +1110,7 @@ void nfs_increment_open_seqid(int status, struct nfs_=
seqid *seqid)
=20
 	sp =3D container_of(seqid->sequence, struct nfs4_state_owner, so_seqid);
 	if (status =3D=3D -NFS4ERR_BAD_SEQID)
=2D		nfs4_drop_state_owner(sp);
+		nfs4_reset_state_owner(sp);
 	if (!nfs4_has_session(sp->so_server->nfs_client))
 		nfs_increment_seqid(status, seqid);
 }
=2D-=20
2.11.0


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlhXLlgACgkQOeye3VZi
gbnG9hAAqAXhk3gwj11JbKTSbQL6GJ6CGNgG7OA72vMqJCZq7wKDJl73y6XSJjKq
tbJ4x2XdRsdEw+RrlFf39FcF914TGyODEOX98n3CFgL2D4yOPrCirROL8prq7dq9
+37WYdFLrmNTV+8QdY5otHM71Q1N0t637mlu1tVgSz7Lq76My2PmJtWCluiUNCrE
u5/d/jPLCZ92X1Hpl3xjOxEAr3ioXVivhxi4lDnPlk1WnYBb8udDBnJtXarrBpLz
CSmcB3JbAAlw0PnWfqDwDY8yRmB+a5vICYuRdL998r8RekeusAfUaMw1cdiXISV2
AVqFqHH0iswqs/C4eMLSpxhSQSEZm5ByfavoVw0RrNys0UFiRyTFF0rOKbcUl66W
FJwkEyLVJlRyGW5g+l3Eaw+xnGnwLZfyInJ2bvUZsu1m7WQSBgL68OCSVxHwUJfd
OJGwQ6O4xYkC14D00CHoqbsz1Krr0xBW65GD9qz9W6NWEShZ58PbgWmXNQufJpEq
VaaHaxj15D+lgzYf72FMECVWppxC8yGFRoiKmEY9Fh8sXMCv0WKc9m2qzcbT0oPr
4QPzH0Ztwif9snw0dyTeeZL6TAr7Ra2vMBnPgzoB0dFgvquqCT40Aw6ur1eLRxfw
RmwB0qVVNMvpLZYlP8p8EXH93G1xjEIa1DPsiVheuKSYLhJZHoc=
=cKX0
-----END PGP SIGNATURE-----
--=-=-=--
