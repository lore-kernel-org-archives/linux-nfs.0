Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:42620 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752679AbdLLW5S (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 12 Dec 2017 17:57:18 -0500
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>
Date: Wed, 13 Dec 2017 09:57:09 +1100
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4: always set NFS_LOCK_LOST when a lock is lost.
Message-ID: <87r2rzo8qi.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable



There are 2 comments in the NFSv4 code which suggest that
SIGLOST should possibly be sent to a process.  In these
cases a lock has been lost.
The current practice is to set NFS_LOCK_LOST so that
read/write returns EIO when a lock is lost.
So change these comments to code when sets NFS_LOCK_LOST.

One case is when lock recovery after apparent server restart
fails with NFS4ERR_DENIED, NFS4ERR_RECLAIM_BAD, or
NFS4ERRO_RECLAIM_CONFLICT.  The other case is when a lock
attempt as part of lease recovery fails with NFS4ERR_DENIED.

In an ideal world, these should not happen.  However I have
a packet trace showing an NFSv4.1 session getting
NFS4ERR_BADSESSION after an extended network parition.  The
NFSv4.1 client treats this like server reboot until/unless
it get NFS4ERR_NO_GRACE, in which case it switches over to
"nograce" recovery mode.  In this network trace, the client
attempts to recover a lock and the server (incorrectly)
reports NFS4ERR_DENIED rather than NFS4ERR_NO_GRACE.  This
leads to the ineffective comment and the client then
continues to write using the OPEN stateid.

Signed-off-by: NeilBrown <neilb@suse.com>
=2D--

Note that I have not tested this as I do not have direct access to a
faulty NFS server.  Once I get confirmation I will provide an update.

NeilBrown

 fs/nfs/nfs4proc.c  | 12 ++++++++----
 fs/nfs/nfs4state.c |  5 ++++-
 2 files changed, 12 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 56fa5a16e097..083802f7a1e9 100644
=2D-- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2019,7 +2019,7 @@ static int nfs4_open_reclaim(struct nfs4_state_owner =
*sp, struct nfs4_state *sta
 	return ret;
 }
=20
=2Dstatic int nfs4_handle_delegation_recall_error(struct nfs_server *server=
, struct nfs4_state *state, const nfs4_stateid *stateid, int err)
+static int nfs4_handle_delegation_recall_error(struct nfs_server *server, =
struct nfs4_state *state, const nfs4_stateid *stateid, struct file_lock *fl=
, int err)
 {
 	switch (err) {
 		default:
@@ -2066,7 +2066,11 @@ static int nfs4_handle_delegation_recall_error(struc=
t nfs_server *server, struct
 			return -EAGAIN;
 		case -ENOMEM:
 		case -NFS4ERR_DENIED:
=2D			/* kill_proc(fl->fl_pid, SIGLOST, 1); */
+			if (fl) {
+				struct nfs4_lock_state *lsp =3D fl->fl_u.nfs4_fl.owner;
+				if (lsp)
+					set_bit(NFS_LOCK_LOST, &lsp->ls_flags);
+			}
 			return 0;
 	}
 	return err;
@@ -2102,7 +2106,7 @@ int nfs4_open_delegation_recall(struct nfs_open_conte=
xt *ctx,
 		err =3D nfs4_open_recover_helper(opendata, FMODE_READ);
 	}
 	nfs4_opendata_put(opendata);
=2D	return nfs4_handle_delegation_recall_error(server, state, stateid, err);
+	return nfs4_handle_delegation_recall_error(server, state, stateid, NULL, =
err);
 }
=20
 static void nfs4_open_confirm_prepare(struct rpc_task *task, void *calldat=
a)
@@ -6739,7 +6743,7 @@ int nfs4_lock_delegation_recall(struct file_lock *fl,=
 struct nfs4_state *state,
 	if (err !=3D 0)
 		return err;
 	err =3D _nfs4_do_setlk(state, F_SETLK, fl, NFS_LOCK_NEW);
=2D	return nfs4_handle_delegation_recall_error(server, state, stateid, err);
+	return nfs4_handle_delegation_recall_error(server, state, stateid, fl, er=
r);
 }
=20
 struct nfs_release_lockowner_data {
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index e4f4a09ed9f4..91a4d4eeb235 100644
=2D-- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1482,6 +1482,7 @@ static int nfs4_reclaim_locks(struct nfs4_state *stat=
e, const struct nfs4_state_
 	struct inode *inode =3D state->inode;
 	struct nfs_inode *nfsi =3D NFS_I(inode);
 	struct file_lock *fl;
+	struct nfs4_lock_state *lsp;
 	int status =3D 0;
 	struct file_lock_context *flctx =3D inode->i_flctx;
 	struct list_head *list;
@@ -1522,7 +1523,9 @@ static int nfs4_reclaim_locks(struct nfs4_state *stat=
e, const struct nfs4_state_
 		case -NFS4ERR_DENIED:
 		case -NFS4ERR_RECLAIM_BAD:
 		case -NFS4ERR_RECLAIM_CONFLICT:
=2D			/* kill_proc(fl->fl_pid, SIGLOST, 1); */
+			lsp =3D fl->fl_u.nfs4_fl.owner;
+			if (lsp)
+				set_bit(NFS_LOCK_LOST, &lsp->ls_flags);
 			status =3D 0;
 		}
 		spin_lock(&flctx->flc_lock);
=2D-=20
2.14.0.rc0.dirty


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlowXsYACgkQOeye3VZi
gbksAxAAtLV2Uz6nzcRvlckUySJGxTH19PRMSM0bfTt9NAPYDErf9cT3CTUcj51N
NcwztNvhTcTyFrtwAKQNDAZkbvujfXPzYMVtC36atRxc3RiX9XawawJmI80A6aXV
8uosDR4GRTkxzsHlGD3+JmEl7KzYOyGezm5pF/Ee0FG5Q31519V23PY52duvAGg2
3VMNnVRPgq+wSrBpeXajzDzJi9qCp7xyNei3D/q6UPIEeZXIKD5/qO4PqeaDXDBC
cMzIZYlYd0XPyEAtwFI83VTls619Bb0igP2xVqEGZpGWNoSLICfNUV3sUegRqIsb
8VFcINdAcOndNrMeX3aU4cZVo5+H5INR5WMj6VH17y8X135FiTIyMBt+dvunvFdk
3dbcZaJGpdVUv9hIemXVWJNq62wZK523qnR434w6xdVilkJ9TUGgCV52nD0hOBBU
NF0tBHDZoYkrPsBqIfsCVXcZo7/9asdTBNdX1O53wrWa7kFQDHE7uqXSFVjf32BB
TxVdRFANW5jMGmcZnqabXRCqXP0ZVDN7xt7K32E3EPIh6y0o7NzlEGYmwwUsBTUw
rY9vjQZVaO0xNWi9NT0oT0fZ8uh3rIcRScnZG8MMzky13jLr8dJ95jhVuCKzmhMH
H2v+7G+J228OtCmlLSMMGa/JgqSAs6XDhIlBxkBai6oewOQN8gA=
=nmpr
-----END PGP SIGNATURE-----
--=-=-=--
