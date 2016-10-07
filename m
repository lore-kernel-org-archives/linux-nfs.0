Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:53688 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754374AbcJGB16 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 6 Oct 2016 21:27:58 -0400
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Date: Fri, 07 Oct 2016 12:27:49 +1100
Cc: NFS List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFS: Don't disconnect open-owner on NFS4ERR_BAD_SEQID
In-Reply-To: <87y46monel.fsf@notabene.neil.brown.name>
References: <87y46monel.fsf@notabene.neil.brown.name>
Message-ID: <87bmyx3q3u.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


Hi again,
 I posted a version of this patch 4 months and got no reply, so
 thought it might be time to try again.
 This version includes a small change to handle the case when a
 delegation stateid gets a BAD_STATEID, in the context of the open-owner
 getting a BAD_SEQID.
 Obviously this whole issue can only happen if the server is buggy (or
 if the client is buggy, but I don't think it is), but it would be best
 to handle that case gracefully.  Currently it spins indefinitely.

Thanks,
NeilBrown

From: NeilBrown <neilb@suse.com>
Subject: [PATCH] NFS: Don't disconnect open-owner on NFS4ERR_BAD_SEQID

When an NFS4ERR_BAD_SEQID is received the open-owner is removed from
the ->state_owners rbtree so that it will no longer be used.

If any stateids attached to this open-owner are still in use, and if a
request using one get an NFS4ERR_BAD_STATEID reply, this can for bad.

The state is marked as needing recovery and the nfs4_state_manager()
is scheduled to clean up.  nfs4_state_manager() finds states to be
recovered by walking the state_owners rbtree.  As the open-owner is
not in the rbtree, the bad state is not found so nfs4_state_manager()
completes having done nothing.  The request is then retried, with a
predicatable result (indefinite retries).

This patch changes NFS4ERR_BAD_SEQID handling to leave the open-owner
in the rbtree but mark it a 'stale'.  With this the indefinite retries
no longer happen.  Errors get to user-space instead if recovery
doesn't work.

If the stateid is for a delegation, the result is more complex.
nfs4_state_manager() tries to return the delegation but uses the
open-owner with the bad seqid to open files on the server, and this
fails with more BAD_SEQID errors.  To avoid this we update the
so_seqid.create_time of the bad open-owner so that it looks to the server
like a new open-owner and an OPEN_CONFIRM is requested.  This allows
the return of the delagation to complete.

Signed-off-by: NeilBrown <neilb@suse.com>
=2D--
 fs/nfs/nfs4_fs.h   |  3 ++-
 fs/nfs/nfs4state.c | 22 +++++++++-------------
 2 files changed, 11 insertions(+), 14 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 3f0e459f2499..6be19814553f 100644
=2D-- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -113,7 +113,8 @@ struct nfs4_state_owner {
=20
 enum {
 	NFS_OWNER_RECLAIM_REBOOT,
=2D	NFS_OWNER_RECLAIM_NOGRACE
+	NFS_OWNER_RECLAIM_NOGRACE,
+	NFS_OWNER_STALE,
 };
=20
 #define NFS_LOCK_NEW		0
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 74cc32490c7a..8ed2285fc527 100644
=2D-- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -397,6 +397,8 @@ nfs4_find_state_owner_locked(struct nfs_server *server,=
 struct rpc_cred *cred)
 			p =3D &parent->rb_left;
 		else if (cred > sp->so_cred)
 			p =3D &parent->rb_right;
+		else if (test_bit(NFS_OWNER_STALE, &sp->so_flags))
+			p =3D &parent->rb_left;
 		else {
 			if (!list_empty(&sp->so_lru))
 				list_del_init(&sp->so_lru);
@@ -424,6 +426,8 @@ nfs4_insert_state_owner_locked(struct nfs4_state_owner =
*new)
 			p =3D &parent->rb_left;
 		else if (new->so_cred > sp->so_cred)
 			p =3D &parent->rb_right;
+		else if (test_bit(NFS_OWNER_STALE, &sp->so_flags))
+			p =3D &parent->rb_left;
 		else {
 			if (!list_empty(&sp->so_lru))
 				list_del_init(&sp->so_lru);
@@ -496,19 +500,11 @@ nfs4_alloc_state_owner(struct nfs_server *server,
 static void
 nfs4_drop_state_owner(struct nfs4_state_owner *sp)
 {
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
+	set_bit(NFS_OWNER_STALE, &sp->so_flags);
+	/* Delegation recall might insist on using this open_owner
+	 * so reset it to force a new 'confirm' stage to be initiated.
+	 */
+	sp->so_seqid.create_time =3D ktime_get();
 }
=20
 static void nfs4_free_state_owner(struct nfs4_state_owner *sp)
=2D-=20
2.10.0


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCAAGBQJX9voVAAoJEDnsnt1WYoG5GfMP/iocOucrmlDmudk5720CYrpI
m2bRw3u1veHG4BD+Pf75BnOWribRDGBL51RHJpPhw55o4uEJvL6jXJzhk1SitoJm
GCJFb6sHuOF46lkCcMErAVrpj085ajVdIEoGaS/Bvi7xsJSt+5Uyy9ckVr8IYUqc
LvP3QSiapBkTuAWnGGd1I/EX7J+/lOoYlYEBHfy+FBSLuTULArtKrmKJhsd71eMV
ztZ3L0d0C0sKhdQ1qwRQA/ca3sUDrlh0Y63sve2iM1Fq7VbAMG0gROg3qpgyzsom
4E88c9uV/fsbZp2Z/qtleQxn7Sm1kGUyHVpmEdyXtZITXyGGv6ZDqHJcUoU6TCNC
g/TMYCuZEsmXKvwpI26y+Xo1ORlgAM/gCwwauiNwHTiriLlMWFEIOdxsshBvq4Yi
ZFs3DauMScJmUnE/GQYGgLDPTXG9/NjWBljc3+gv7GJHluG6QSVbWSBarZfL3QeQ
rXjiB/47w8UMj/T7pIHqZmePF43onGeztwyWoZX57NAHY7V0QAcRw4eISr4T7wA1
+4s+6kLQ/vhQJ14mszK9roohkbaUqXxV+/9FY8DjV3rHxwio1EQV7mb6Mha7w9+b
GQYK3PrQl1Mr+1cxLKpF4hY+4qNLLc30A911dCncQv6w7VLW+s2bH4dR1DvhFI3a
jGdAzOO4v2Rd6ZM5Lcuh
=pZO9
-----END PGP SIGNATURE-----
--=-=-=--
