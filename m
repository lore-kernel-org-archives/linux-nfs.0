Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:36932 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751457AbcFCFY1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 3 Jun 2016 01:24:27 -0400
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Date: Fri, 03 Jun 2016 15:24:18 +1000
Subject: [PATCH] NFS: Don't disconnect open-owner on NFS4ERR_BAD_SEQID
cc: NFS List <linux-nfs@vger.kernel.org>
Message-ID: <87y46monel.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


Hi Trond/Anna,
 I'd like your thoughts on this patch.
 I have a customer whose NFS client occasionally gets into a state
 where it spins indefinitely sending WRITE (or OPEN) and getting an
 NFS4ERR_BAD_STATEID (or NFS4ERR_BAD_SEQID) error.  The  state manager
 doesn't try any recovery as the open owner is no longer in the rbtree -
 presumably due to an earlier NFS4ERR_BAD_SEQID.  I've seen at least one
   NFS: v4 server XXX returned a bad sequence-id error!
 in the logs.
 I don't know if this is a server problem or a client problem - client
 didn't have
  Commit: c7848f69ec4a ("NFSv4: OPEN must handle the NFS4ERR_IO return code=
 correctly")
 which cause cause BAD_SEQID errors.
 However wherever the bug is we don't want the NFS client to spin like
 that.
 This patch removes the spinning when tested against a hacked NFS
 server which can be convinced to return BAD_SEQID and BAD_STATED for a
 given open owner.

 My main concern is: is there some other reason to remove the open owner
 from the rbtree other than to make sure it isn't used for new opens?

Thanks,
NeilBrown


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

Signed-off-by: NeilBrown <neilb@suse.com>
=2D--
 fs/nfs/nfs4_fs.h   |  3 ++-
 fs/nfs/nfs4state.c | 18 +++++-------------
 2 files changed, 7 insertions(+), 14 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 768456fa1b17..42244d1123f6 100644
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
index 9679f4749364..abacaf521d29 100644
=2D-- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -400,6 +400,8 @@ nfs4_find_state_owner_locked(struct nfs_server *server,=
 struct rpc_cred *cred)
 			p =3D &parent->rb_left;
 		else if (cred > sp->so_cred)
 			p =3D &parent->rb_right;
+		else if (test_bit(NFS_OWNER_STALE, &sp->so_flags))
+			p =3D &parent->rb_left;
 		else {
 			if (!list_empty(&sp->so_lru))
 				list_del_init(&sp->so_lru);
@@ -427,6 +429,8 @@ nfs4_insert_state_owner_locked(struct nfs4_state_owner =
*new)
 			p =3D &parent->rb_left;
 		else if (new->so_cred > sp->so_cred)
 			p =3D &parent->rb_right;
+		else if (test_bit(NFS_OWNER_STALE, &sp->so_flags))
+			p =3D &parent->rb_left;
 		else {
 			if (!list_empty(&sp->so_lru))
 				list_del_init(&sp->so_lru);
@@ -499,19 +503,7 @@ nfs4_alloc_state_owner(struct nfs_server *server,
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
 }
=20
 static void nfs4_free_state_owner(struct nfs4_state_owner *sp)
=2D-=20
2.8.3


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJXURSCAAoJEDnsnt1WYoG5jToP/3lRsLtJGKfNDdAH6ZVNrQbC
J8j/EK12B2IZo9avupI5EHBphSlltF8trzE+Pqzteic95GISR8gO+Yll+Y37qUr0
bwf4kDYiOpzMKuXeP79NeRtUa/CRauD9tYicWjhxmx2RUAeCwUZOkBlcqfK85MUe
n7edSYCewaVYAd77qZlQ/pKFGSxdpaGpbGOxA/8i6CJ5r1tsy1QjaM9RsAxK/WDm
0CPcHnNaAirzh31emqbmruXNbHGU41xoKNWLWzX2XSka/iBB53gF+238a9kfhagL
IFs+lFFh6erfj3Q5pXwEwgeEerPCWTZucU1hc3wq3wSPaf/0t3RxXpu58S6OweNp
nmb1paWJfu4FwGF67oQZ1M8PF0XPEEWx9nv9ZGKc1cYVn3WI8xNoTQue5JIaaG8H
SNhq7C8ZOQBwlKbUA2V+Fr8LGJIhVLryzekYXXvqshHVpcNAE5231xyVqyY5bZT0
QB9t5gWqmeyH7z1tBUXWxTXe/0/snzMxCYceQS4knaLIiysTOzmde1bCYu+H55Y+
/y08AN7EYJonAIOXw9yf/SqXfpeq+yGiJYmn9MRgnneOgPUWHD2f8Dos5RqIXMUs
G+zyfM9JbKkgpWXWbxECAPTQrzqZe4KmKkQcZKEKZtlktYySfJovJZyHE5+9GGft
NnFvPGvlTaBM/Qm02j6Z
=TL9A
-----END PGP SIGNATURE-----
--=-=-=--
