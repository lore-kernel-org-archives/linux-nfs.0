Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:40987 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756362Ab3IDHE7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Sep 2013 03:04:59 -0400
Date: Wed, 4 Sep 2013 17:04:47 +1000
From: NeilBrown <neilb@suse.de>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: [PATCH - alt-1] NFSv4:  Don't try to recover NFSv4 locks when they
 are lost.
Message-ID: <20130904170447.030a4fd0@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/Q9aDynRc3h2mUK8DQjX/voD"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/Q9aDynRc3h2mUK8DQjX/voD
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable



When an NFSv4 client loses contact with the server it can lose any
locks that it holds.

Currently when it reconnects to the server it simply tries to reclaim
those locks.  This might succeed even though some other client has
held and released a lock in the mean time.  So the first client might
think the file is unchanged, but it isn't.  This isn't good.

If, when recovery happens, the locks cannot be claimed because some
other client still holds the lock, then we get a message in the kernel
logs, but the client can still write.  So two clients can both think
they have a lock and can both write at the same time.  This is equally
not good.

There was a patch a while ago
  http://comments.gmane.org/gmane.linux.nfs/41917

which tried to address some of this, but it didn't seem to go
anywhere.  That patch would also send a signal to the process.  That
might be useful but for now this patch just causes writes to fail.

For NFSv4 (unlike v2/v3) there is a strong link between the lock and
the write request so we can fairly easily fail any IO of the lock is
gone.  While some applications might not expect this, it is still
safer than allowing the write to succeed.

Signed-off-by: NeilBrown <neilb@suse.de>

--
This alternative does not use a module parameter - locks are never recovere=
d.
This is more correct.

NeilBrown

diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index f5c84c3..de0229b 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -826,9 +826,10 @@ static void nfs3_proc_read_setup(struct nfs_read_data =
*data, struct rpc_message
 	msg->rpc_proc =3D &nfs3_procedures[NFS3PROC_READ];
 }
=20
-static void nfs3_proc_read_rpc_prepare(struct rpc_task *task, struct nfs_r=
ead_data *data)
+static int nfs3_proc_read_rpc_prepare(struct rpc_task *task, struct nfs_re=
ad_data *data)
 {
 	rpc_call_start(task);
+	return 0;
 }
=20
 static int nfs3_write_done(struct rpc_task *task, struct nfs_write_data *d=
ata)
@@ -847,9 +848,10 @@ static void nfs3_proc_write_setup(struct nfs_write_dat=
a *data, struct rpc_messag
 	msg->rpc_proc =3D &nfs3_procedures[NFS3PROC_WRITE];
 }
=20
-static void nfs3_proc_write_rpc_prepare(struct rpc_task *task, struct nfs_=
write_data *data)
+static int nfs3_proc_write_rpc_prepare(struct rpc_task *task, struct nfs_w=
rite_data *data)
 {
 	rpc_call_start(task);
+	return 0;
 }
=20
 static void nfs3_proc_commit_rpc_prepare(struct rpc_task *task, struct nfs=
_commit_data *data)
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index ee81e35..a468b345 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -135,6 +135,7 @@ struct nfs4_lock_state {
 	struct list_head	ls_locks;	/* Other lock stateids */
 	struct nfs4_state *	ls_state;	/* Pointer to open state */
 #define NFS_LOCK_INITIALIZED 0
+#define NFS_LOCK_LOST        1
 	unsigned long		ls_flags;
 	struct nfs_seqid_counter	ls_seqid;
 	nfs4_stateid		ls_stateid;
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 108a774..e284f83 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3905,15 +3905,19 @@ static void nfs4_proc_read_setup(struct nfs_read_da=
ta *data, struct rpc_message
 	nfs41_init_sequence(&data->args.seq_args, &data->res.seq_res, 0);
 }
=20
-static void nfs4_proc_read_rpc_prepare(struct rpc_task *task, struct nfs_r=
ead_data *data)
+static int nfs4_proc_read_rpc_prepare(struct rpc_task *task, struct nfs_re=
ad_data *data)
 {
 	if (nfs4_setup_sequence(NFS_SERVER(data->header->inode),
 			&data->args.seq_args,
 			&data->res.seq_res,
 			task))
-		return;
-	nfs4_set_rw_stateid(&data->args.stateid, data->args.context,
-			data->args.lock_context, FMODE_READ);
+		return 0;
+	if (nfs4_set_rw_stateid(&data->args.stateid, data->args.context,
+				data->args.lock_context, FMODE_READ) =3D=3D -EIO)
+		return -EIO;
+	if (unlikely(test_bit(NFS_CONTEXT_BAD, &data->args.context->flags)))
+		return -EIO;
+	return 0;
 }
=20
 static int nfs4_write_done_cb(struct rpc_task *task, struct nfs_write_data=
 *data)
@@ -3988,15 +3992,19 @@ static void nfs4_proc_write_setup(struct nfs_write_=
data *data, struct rpc_messag
 	nfs41_init_sequence(&data->args.seq_args, &data->res.seq_res, 1);
 }
=20
-static void nfs4_proc_write_rpc_prepare(struct rpc_task *task, struct nfs_=
write_data *data)
+static int nfs4_proc_write_rpc_prepare(struct rpc_task *task, struct nfs_w=
rite_data *data)
 {
 	if (nfs4_setup_sequence(NFS_SERVER(data->header->inode),
 			&data->args.seq_args,
 			&data->res.seq_res,
 			task))
-		return;
-	nfs4_set_rw_stateid(&data->args.stateid, data->args.context,
-			data->args.lock_context, FMODE_WRITE);
+		return 0;
+	if (nfs4_set_rw_stateid(&data->args.stateid, data->args.context,
+				data->args.lock_context, FMODE_WRITE) =3D=3D -EIO)
+		return -EIO;
+	if (unlikely(test_bit(NFS_CONTEXT_BAD, &data->args.context->flags)))
+		return -EIO;
+	return 0;
 }
=20
 static void nfs4_proc_commit_rpc_prepare(struct rpc_task *task, struct nfs=
_commit_data *data)
@@ -5380,29 +5388,10 @@ static int nfs4_lock_reclaim(struct nfs4_state *sta=
te, struct file_lock *request
=20
 static int nfs4_lock_expired(struct nfs4_state *state, struct file_lock *r=
equest)
 {
-	struct nfs_server *server =3D NFS_SERVER(state->inode);
-	struct nfs4_exception exception =3D {
-		.inode =3D state->inode,
-	};
 	int err;
=20
 	err =3D nfs4_set_lock_state(state, request);
-	if (err !=3D 0)
-		return err;
-	do {
-		if (test_bit(NFS_DELEGATED_STATE, &state->flags) !=3D 0)
-			return 0;
-		err =3D _nfs4_do_setlk(state, F_SETLK, request, NFS_LOCK_EXPIRED);
-		switch (err) {
-		default:
-			goto out;
-		case -NFS4ERR_GRACE:
-		case -NFS4ERR_DELAY:
-			nfs4_handle_exception(server, err, &exception);
-			err =3D 0;
-		}
-	} while (exception.retry);
-out:
+	set_bit(NFS_LOCK_LOST, &request->fl_u.nfs4_fl.owner->ls_flags);
 	return err;
 }
=20
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index e22862f..1e26e8c 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -998,7 +998,9 @@ static int nfs4_copy_lock_stateid(nfs4_stateid *dst,
 	fl_pid =3D lockowner->l_pid;
 	spin_lock(&state->state_lock);
 	lsp =3D __nfs4_find_lock_state(state, fl_owner, fl_pid, NFS4_ANY_LOCK_TYP=
E);
-	if (lsp !=3D NULL && test_bit(NFS_LOCK_INITIALIZED, &lsp->ls_flags) !=3D =
0) {
+	if (lsp && test_bit(NFS_LOCK_LOST, &lsp->ls_flags))
+		ret =3D -EIO;
+	else if (lsp !=3D NULL && test_bit(NFS_LOCK_INITIALIZED, &lsp->ls_flags) =
!=3D 0) {
 		nfs4_stateid_copy(dst, &lsp->ls_stateid);
 		ret =3D 0;
 		smp_rmb();
@@ -1038,11 +1040,17 @@ static int nfs4_copy_open_stateid(nfs4_stateid *dst=
, struct nfs4_state *state)
 int nfs4_select_rw_stateid(nfs4_stateid *dst, struct nfs4_state *state,
 		fmode_t fmode, const struct nfs_lockowner *lockowner)
 {
-	int ret =3D 0;
+	int ret =3D nfs4_copy_lock_stateid(dst, state, lockowner);
+	if (ret =3D=3D -EIO)
+		/* A lost lock - don't even consider delegations */
+		goto out;
 	if (nfs4_copy_delegation_stateid(dst, state->inode, fmode))
 		goto out;
-	ret =3D nfs4_copy_lock_stateid(dst, state, lockowner);
 	if (ret !=3D -ENOENT)
+		/* nfs4_copy_delegation_stateid() didn't over-write
+		 * dst, so it still has the lock stateid which we now
+		 * choose to use.
+		 */
 		goto out;
 	ret =3D nfs4_copy_open_stateid(dst, state);
 out:
diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
index c041c41..a8f57c7 100644
--- a/fs/nfs/proc.c
+++ b/fs/nfs/proc.c
@@ -623,9 +623,10 @@ static void nfs_proc_read_setup(struct nfs_read_data *=
data, struct rpc_message *
 	msg->rpc_proc =3D &nfs_procedures[NFSPROC_READ];
 }
=20
-static void nfs_proc_read_rpc_prepare(struct rpc_task *task, struct nfs_re=
ad_data *data)
+static int nfs_proc_read_rpc_prepare(struct rpc_task *task, struct nfs_rea=
d_data *data)
 {
 	rpc_call_start(task);
+	return 0;
 }
=20
 static int nfs_write_done(struct rpc_task *task, struct nfs_write_data *da=
ta)
@@ -644,9 +645,10 @@ static void nfs_proc_write_setup(struct nfs_write_data=
 *data, struct rpc_message
 	msg->rpc_proc =3D &nfs_procedures[NFSPROC_WRITE];
 }
=20
-static void nfs_proc_write_rpc_prepare(struct rpc_task *task, struct nfs_w=
rite_data *data)
+static int nfs_proc_write_rpc_prepare(struct rpc_task *task, struct nfs_wr=
ite_data *data)
 {
 	rpc_call_start(task);
+	return 0;
 }
=20
 static void nfs_proc_commit_rpc_prepare(struct rpc_task *task, struct nfs_=
commit_data *data)
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 70a26c6..31db5c3 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -513,9 +513,10 @@ static void nfs_readpage_release_common(void *calldata)
 void nfs_read_prepare(struct rpc_task *task, void *calldata)
 {
 	struct nfs_read_data *data =3D calldata;
-	NFS_PROTO(data->header->inode)->read_rpc_prepare(task, data);
-	if (unlikely(test_bit(NFS_CONTEXT_BAD, &data->args.context->flags)))
-		rpc_exit(task, -EIO);
+	int err;
+	err =3D NFS_PROTO(data->header->inode)->read_rpc_prepare(task, data);
+	if (err)
+		rpc_exit(task, err);
 }
=20
 static const struct rpc_call_ops nfs_read_common_ops =3D {
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index f1bdb72..7816801 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1265,9 +1265,10 @@ EXPORT_SYMBOL_GPL(nfs_pageio_reset_write_mds);
 void nfs_write_prepare(struct rpc_task *task, void *calldata)
 {
 	struct nfs_write_data *data =3D calldata;
-	NFS_PROTO(data->header->inode)->write_rpc_prepare(task, data);
-	if (unlikely(test_bit(NFS_CONTEXT_BAD, &data->args.context->flags)))
-		rpc_exit(task, -EIO);
+	int err;
+	err =3D NFS_PROTO(data->header->inode)->write_rpc_prepare(task, data);
+	if (err)
+		rpc_exit(task, err);
 }
=20
 void nfs_commit_prepare(struct rpc_task *task, void *calldata)
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 8651574..c71e12b 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1419,12 +1419,12 @@ struct nfs_rpc_ops {
 	void	(*read_setup)   (struct nfs_read_data *, struct rpc_message *);
 	void	(*read_pageio_init)(struct nfs_pageio_descriptor *, struct inode *,
 				    const struct nfs_pgio_completion_ops *);
-	void	(*read_rpc_prepare)(struct rpc_task *, struct nfs_read_data *);
+	int	(*read_rpc_prepare)(struct rpc_task *, struct nfs_read_data *);
 	int	(*read_done)  (struct rpc_task *, struct nfs_read_data *);
 	void	(*write_setup)  (struct nfs_write_data *, struct rpc_message *);
 	void	(*write_pageio_init)(struct nfs_pageio_descriptor *, struct inode *,=
 int,
 				     const struct nfs_pgio_completion_ops *);
-	void	(*write_rpc_prepare)(struct rpc_task *, struct nfs_write_data *);
+	int	(*write_rpc_prepare)(struct rpc_task *, struct nfs_write_data *);
 	int	(*write_done)  (struct rpc_task *, struct nfs_write_data *);
 	void	(*commit_setup) (struct nfs_commit_data *, struct rpc_message *);
 	void	(*commit_rpc_prepare)(struct rpc_task *, struct nfs_commit_data *);

--Sig_/Q9aDynRc3h2mUK8DQjX/voD
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUibbjznsnt1WYoG5AQIi2Q//fnrh+4AUE1FJ2/mf7Cg8rnsjMhhWlC8/
Ggom4VqYNCDLSVQt+LXm4940sMuxBvHNi99+aDWtzJBva3NM4FzaR0a/bxmYcZh+
KUpIMbwzn4lnHISlFUbskl7AsSNEeyCs3OL2OQ4fID2gqUwBD5XqjnLGmPERTL7X
Y6R+cKeG1QM0lTH9ikJ3E8EA4xNujsBu4vJ+VnI9Eb9s1pZm45StgytqM+2ZvetE
4lCUYueXURc+7ffu6AKlY4ANE/6uykknJgIGGp42cy4qa1gAkcZd0hksSeB/myp0
P1QTssVW+zxXY+HvdYBzsPbBK/rc98/jOXDvFq7pEDuhNX1rGqyUqyT/63aXsGLM
WZHSCvK+ad2Eslh+F0HQI7wU4WDLuD/dCaJzluEdWCAFgNeFBCh0UNdwY6PieTSs
XHzTKyzpSR9UmAs/pfDuJeSihBFyYM5w7r9Z6z5OOLPvoudCVvbvNMSnw1sVazx+
4AKVL7en0iIP09J/OGvwLWL1uMjwKOXq4YOmqH3hJWgDZZS+zPAVVqXvJ9GdEKEd
4De8EygNPJ15jB+NbTx4MBB74a6iqJhZwc/fNYdWEKCG6tx4xFUXUew3qZO61kNH
JDyXSLHeIjxcoGRUwLObhMpse9+JvYeOL1wBsq0lE+ZpsjXxWCHIKJHg5Gz8gU97
BU8JrxcdRKE=
=3nfv
-----END PGP SIGNATURE-----

--Sig_/Q9aDynRc3h2mUK8DQjX/voD--
