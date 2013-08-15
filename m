Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:37771 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758345Ab3HOCgT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Aug 2013 22:36:19 -0400
Date: Thu, 15 Aug 2013 12:36:04 +1000
From: NeilBrown <neilb@suse.de>
To: NFS <linux-nfs@vger.kernel.org>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH/RFC]  Don't try to recover NFS locks when they are lost.
Message-ID: <20130815123604.47755509@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/pG3mPsk=12dkFQhufQENPPt"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/pG3mPsk=12dkFQhufQENPPt
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable



When an NFS (V4 specifically) client loses contact with the server it can
lose any locks that it holds.
Currently when it reconnects to the server it simply tries to reclaim
those locks.  This might succeed even though some other client has held and
released a lock in the mean time.  So the first client might think the file
is unchanged, but it isn't.  This isn't good.

If, when recovery happens, the locks cannot be claimed because some other
client still holds the lock, then  we get a message in the kernel logs, but
the client can still write.  So two clients can both think they have a lock
and can both write at the same time.  This is equally not good.

There was a patch a while ago
  http://comments.gmane.org/gmane.linux.nfs/41917

which tried to address some of this, but it didn't seem to go anywhere.
That patch would also send a signal to the process.  That might be useful
but I'm really just interested in failing the writes.
For NFSv4 (unlike v2/v3) there is a strong link between the lock and the
write request so we can fairly easily fail an IO of the lock is gone.

The patch below attempts to do this.  Does it make sense?
Because this is a fairly big change I introduces a module parameter
"recover_locks" which defaults to true (the current behaviour) but can be s=
et
to "false" to tell the client not to try to recover things that were lost.

Comments?

Thanks,
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
index cf11799..bcbcd07 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3907,15 +3907,19 @@ static void nfs4_proc_read_setup(struct nfs_read_da=
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
@@ -3990,15 +3994,19 @@ static void nfs4_proc_write_setup(struct nfs_write_=
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
@@ -5380,6 +5388,11 @@ static int nfs4_lock_reclaim(struct nfs4_state *stat=
e, struct file_lock *request
 	return err;
 }
=20
+bool recover_locks =3D true;
+module_param(recover_locks, bool, 0644);
+MODULE_PARM_DESC(recovery_locks,
+		 "If the server reports that a lock might be lost, "
+		 "try to recovery it risking corruption.");
 static int nfs4_lock_expired(struct nfs4_state *state, struct file_lock *r=
equest)
 {
 	struct nfs_server *server =3D NFS_SERVER(state->inode);
@@ -5391,6 +5404,10 @@ static int nfs4_lock_expired(struct nfs4_state *stat=
e, struct file_lock *request
 	err =3D nfs4_set_lock_state(state, request);
 	if (err !=3D 0)
 		return err;
+	if (!recover_locks) {
+		set_bit(NFS_LOCK_LOST, &request->fl_u.nfs4_fl.owner->ls_flags);
+		return 0;
+	}
 	do {
 		if (test_bit(NFS_DELEGATED_STATE, &state->flags) !=3D 0)
 			return 0;
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index e22862f..4d103ff 100644
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

--Sig_/pG3mPsk=12dkFQhufQENPPt
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUgw+lDnsnt1WYoG5AQI9pg//bvUW3/jsxUkZUtTom0i8SvBeRgGaRrvn
SdIO/Jhtca9y+WP+m+eq/v1OqXYSpcmxAcCLlQ+PvH8elrfY8EGqJQKiQxMMC4sF
EBYK3pmP8GHn+n1FIo/30W7BKd4NQmXaQ+UJvHEc6/1ws9qsW7ZIz+x+aUB7IZ5i
/ITnun9/4y5pbUTSRZ20kIGQJxm8Z7NCehYdbeyQAlMQJF/m+itK8hnUoMX9qBDf
h167stYrSJt2CbuTqzek2Gmx00FDvftNychRt0wN6JaaGM8iGNR4uf+lhGVEDYEM
v2648Ut3qN5EO0tCamIC/a7s2UMqHw/REC7/VzCysaleZCQ872LFLSYYzRs2qTef
5jb4Y587PEx/z13mI/9fpoDHfYp0M9AsNSjT/OVVWlmhM7j03VjDTMX2WF5/mwiu
m1/gfbaUqkEv6HuGQlSRKkUN1OrH4qNM7lTSdal+Vb2g5Zsk1I8toSpNDdtCByWV
wlYvp86KUHzhrbwbrrdQkK07YZnNndG6RETpWDHZcI4wOK+a5tZnkuDrg8A4eN6W
ifefu6DQlPDNpnqFBHBBxJUJw6qO/Zvjb+RL8ceBNudNrIDxttVR5XSZMFd+njrO
rv43lSDTAwougRWk1w/kPkgDrsdhd5S+gDqmcB1Mmpen1fJ1ALKPvMnZipHBBtqT
amFM22ILR6M=
=1X3x
-----END PGP SIGNATURE-----

--Sig_/pG3mPsk=12dkFQhufQENPPt--
