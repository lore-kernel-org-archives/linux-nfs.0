Return-Path: <neilb@suse.de>
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Jeff Layton <jlayton@redhat.com>
Date: Wed, 12 Oct 2016 14:33:19 +1100
Cc: Benjamin Coddington <bcodding@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH 2/5 - version 2] NFSv4: add flock_owner to open context
In-Reply-To: <147623995850.19592.5998774293057362829.stgit@noble>
References: <147623977637.19592.12766016823334433969.stgit@noble> <147623995850.19592.5998774293057362829.stgit@noble>
Message-ID: <87zima1bsw.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


An open file description (struct file) in a given process can be
associated with two different lock owners.

It can have a Posix lock owner which will be different in each process
that has a fd on the file.
It can have a Flock owner which will be the same in all processes.

When searching for a lock stateid to use, we need to consider both of these
owners

So add a new "flock_owner" to the "nfs_open_context" (of which there
is one for each open file description).

This flock_owner does not need to be reference-counted as there is a
1-1 relation between 'struct file' and nfs open contexts,
and it will never be part of a list of contexts.  So there is no need
for a 'flock_context' - just the owner is enough.

The io_count included in the (Posix) lock_context provides no
guarantee that all read-aheads that could use the state have
completed, so not supporting it for flock locks in not a serious
problem.  Synchronization between flock and read-ahead can be added
later if needed.

When creating an open_context for a non-openning create call, we don't have
a 'struct file' to pass in, so the lock context gets initialized with
a NULL owner, but this will never be used.

The flock_owner is not used at all in this patch, that will come later.

Signed-off-by: NeilBrown <neilb@suse.com>
=2D--
 fs/nfs/dir.c           | 6 +++---
 fs/nfs/inode.c         | 7 +++++--
 fs/nfs/nfs4file.c      | 2 +-
 fs/nfs/nfs4proc.c      | 2 +-
 include/linux/nfs_fs.h | 3 ++-
 5 files changed, 12 insertions(+), 8 deletions(-)

Sorry, two little errors in previous version....

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 06e0bf092ba9..d5b87b28010d 100644
=2D-- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1453,9 +1453,9 @@ static fmode_t flags_to_mode(int flags)
 	return res;
 }
=20
=2Dstatic struct nfs_open_context *create_nfs_open_context(struct dentry *d=
entry, int open_flags)
+static struct nfs_open_context *create_nfs_open_context(struct dentry *den=
try, int open_flags, struct file *filp)
 {
=2D	return alloc_nfs_open_context(dentry, flags_to_mode(open_flags));
+	return alloc_nfs_open_context(dentry, flags_to_mode(open_flags), filp);
 }
=20
 static int do_open(struct inode *inode, struct file *filp)
@@ -1540,7 +1540,7 @@ int nfs_atomic_open(struct inode *dir, struct dentry =
*dentry,
 			return finish_no_open(file, dentry);
 	}
=20
=2D	ctx =3D create_nfs_open_context(dentry, open_flags);
+	ctx =3D create_nfs_open_context(dentry, open_flags, file);
 	err =3D PTR_ERR(ctx);
 	if (IS_ERR(ctx))
 		goto out;
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 1752fc7c0024..2138027eaba9 100644
=2D-- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -796,7 +796,9 @@ void nfs_close_context(struct nfs_open_context *ctx, in=
t is_sync)
 }
 EXPORT_SYMBOL_GPL(nfs_close_context);
=20
=2Dstruct nfs_open_context *alloc_nfs_open_context(struct dentry *dentry, f=
mode_t f_mode)
+struct nfs_open_context *alloc_nfs_open_context(struct dentry *dentry,
+						fmode_t f_mode,
+						struct file *filp)
 {
 	struct nfs_open_context *ctx;
 	struct rpc_cred *cred =3D rpc_lookup_cred();
@@ -815,6 +817,7 @@ struct nfs_open_context *alloc_nfs_open_context(struct =
dentry *dentry, fmode_t f
 	ctx->mode =3D f_mode;
 	ctx->flags =3D 0;
 	ctx->error =3D 0;
+	ctx->flock_owner =3D (fl_owner_t)filp;
 	nfs_init_lock_context(&ctx->lock_context);
 	ctx->lock_context.open_context =3D ctx;
 	INIT_LIST_HEAD(&ctx->list);
@@ -939,7 +942,7 @@ int nfs_open(struct inode *inode, struct file *filp)
 {
 	struct nfs_open_context *ctx;
=20
=2D	ctx =3D alloc_nfs_open_context(file_dentry(filp), filp->f_mode);
+	ctx =3D alloc_nfs_open_context(file_dentry(filp), filp->f_mode, filp);
 	if (IS_ERR(ctx))
 		return PTR_ERR(ctx);
 	nfs_file_set_open_context(filp, ctx);
diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index 89a77950e0b0..0efba77789b9 100644
=2D-- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -57,7 +57,7 @@ nfs4_file_open(struct inode *inode, struct file *filp)
 	parent =3D dget_parent(dentry);
 	dir =3D d_inode(parent);
=20
=2D	ctx =3D alloc_nfs_open_context(file_dentry(filp), filp->f_mode);
+	ctx =3D alloc_nfs_open_context(file_dentry(filp), filp->f_mode, filp);
 	err =3D PTR_ERR(ctx);
 	if (IS_ERR(ctx))
 		goto out;
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index b7df3ef84fc3..422ed5ac4efe 100644
=2D-- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3792,7 +3792,7 @@ nfs4_proc_create(struct inode *dir, struct dentry *de=
ntry, struct iattr *sattr,
 	struct nfs4_state *state;
 	int status =3D 0;
=20
=2D	ctx =3D alloc_nfs_open_context(dentry, FMODE_READ);
+	ctx =3D alloc_nfs_open_context(dentry, FMODE_READ, NULL);
 	if (IS_ERR(ctx))
 		return PTR_ERR(ctx);
=20
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index bf8a713c45b4..0adb02c4744d 100644
=2D-- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -70,6 +70,7 @@ struct nfs_lock_context {
 struct nfs4_state;
 struct nfs_open_context {
 	struct nfs_lock_context lock_context;
+	fl_owner_t flock_owner;
 	struct dentry *dentry;
 	struct rpc_cred *cred;
 	struct nfs4_state *state;
@@ -357,7 +358,7 @@ extern void nfs_setsecurity(struct inode *inode, struct=
 nfs_fattr *fattr,
 extern struct nfs_open_context *get_nfs_open_context(struct nfs_open_conte=
xt *ctx);
 extern void put_nfs_open_context(struct nfs_open_context *ctx);
 extern struct nfs_open_context *nfs_find_open_context(struct inode *inode,=
 struct rpc_cred *cred, fmode_t mode);
=2Dextern struct nfs_open_context *alloc_nfs_open_context(struct dentry *de=
ntry, fmode_t f_mode);
+extern struct nfs_open_context *alloc_nfs_open_context(struct dentry *dent=
ry, fmode_t f_mode, struct file *filp);
 extern void nfs_inode_attach_open_context(struct nfs_open_context *ctx);
 extern void nfs_file_set_open_context(struct file *filp, struct nfs_open_c=
ontext *ctx);
 extern void nfs_file_clear_open_context(struct file *flip);
=2D-=20
2.10.0


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCAAGBQJX/a7/AAoJEDnsnt1WYoG52vsP/jRuWVBZzP61+3Lsst33XoHz
+ohpC74TO/YYDcZ18jGZw1eVSQKsccgtV+K2C+yp3qIoaDLal/os8AIPXy1kKiJA
QFkfVYquChhdfoFtOcRaUtpluQlhUNKYy/AvXihwq5RIGGp4b+oE3Pf4mNKcU9TN
Svi6YoYl/oleHJZJLGLBqJi4vittgar/8a1yABAegjklG/55M7B4YYuYRwN1XCgl
GPWtuhWRyRSdnUhJBynCUKWDzNz6HBdGV2VidIsuyCwyf83pDMHd9T1dig9t7kli
B64dkqLuOkmudvu/eLgl87ErIzo1nK+0rWYDl9AI1sy9JZxrrXecAVMKYQiOZKPL
V4Qpuz+GKRNU9Bqsu2caUnN7vL9njjp/cjBFl2kFuYkpFldV7ciftxh6KgwrRPO3
p+UjbU5ymhuyH/PRjmnLo25oylcEOv1Pi/jZhtK5RMlxAfK0h9uWuu/9Hco/lq/F
3awCBBH7eEvHHamRypzYk12sRy8a8tiMKG9tSOdSH3+sZ7NDJqInoQ6drn9sQseY
84a7gQrSQ0gOTv/fGdoOrL5fW4KQWw8sijw97jTKOFWoXM9QitAEb1+N6907CDOY
bNvrjXGtM7DUF6h0SIrPMoRv6x8ZPjCaF0vb4+dQJEqXDHBJyE53XpWbGxUdUz+K
MPcY4WSbib1eychwoEW9
=mQri
-----END PGP SIGNATURE-----
--=-=-=--
