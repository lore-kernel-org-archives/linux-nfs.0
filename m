Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:35794 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751413AbdIEVgA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 5 Sep 2017 17:36:00 -0400
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@redhat.com>
Date: Wed, 06 Sep 2017 07:35:47 +1000
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH 2/3] fs: hide another detail of delegation logic
In-Reply-To: <20170905195619.GB17828@parsley.fieldses.org>
References: <1503697958-6122-3-git-send-email-bfields@redhat.com> <878ti4i9pi.fsf@notabene.neil.brown.name> <20170829214026.GI8822@parsley.fieldses.org> <8760d5hol3.fsf@notabene.neil.brown.name> <20170830170938.GC24373@parsley.fieldses.org> <87wp5kfxi3.fsf@notabene.neil.brown.name> <20170831190531.GA8223@parsley.fieldses.org> <873787fhc5.fsf@notabene.neil.brown.name> <20170901161809.GA22140@parsley.fieldses.org> <871snndq04.fsf@notabene.neil.brown.name> <20170905195619.GB17828@parsley.fieldses.org>
Message-ID: <877excde18.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, Sep 05 2017, J. Bruce Fields wrote:

> On Mon, Sep 04, 2017 at 02:52:43PM +1000, NeilBrown wrote:
>> On Fri, Sep 01 2017, J. Bruce Fields wrote:
>>=20
>> >>=20
>> >> nfsd would need to find that delegation, prevent further delegations
>> >> being handed out, and check that there aren't already conflicting
>> >> delegations.  If there are conflicts, recall them.  Once there are no
>> >> conflicting delegations, make the vfs_ request.
>> >
>> > The way that we currently serialize setting, unsetting, and breaking
>> > delegations is by locks on the delegated inodes which aren't taken till
>> > deeper in the vfs code.
>>=20
>> Do we?
>> I can see nfs4_set_delegation adding a new delegation for a new client
>> without entering the vfs at all if there is already a lease held.
>
> By "delegations", I meant locks of type FL_DELEG.  But even then I was
> wrong, apologies.
>
> There is an inode_trylock in generic_add_lease that will prevent any new
> delegations from being given while the inode's locked.
>
>> If there isn't a lease already, vfs_setlease() is called, which doesn't
>> its own internal locking of course.  Much the same applies to unsetting
>> delegations.
>> Breaking delegations involves nfsd_break_deleg_cb() which has a comment
>> that it is called with i_lock held.... that seems to be used to
>> be sure that it is safe to a reference to the delegation state id.
>> Is that the only dependency on the vfs locking, or did I miss something?
>>=20
>> >
>> > I guess you're suggesting adding a second mechanism to prevent
>> > delegations being given out on the inode.  We could add an atomic
>> > counter taken by each nfsd breaker while it's in progress.  Hrm.
>>=20
>> Something like that.
>> We would also need to be able to look up an nfs4_file by inode (why
>> *are* they hashed by file handle??)
>
> Grepping the logs....  That was ca9432178378 "nfsd: Use the filehandle
> to look up the struct nfs4_file instead of inode" which doesn't give a
> full justification.  Later commits suggest it might be about keeping
> nfsv4 state in many-to-one filehandle->inode cases (spec requirement, I
> believe) and preventing the nfs4_file from pinning the inode (not seeing
> immediately why that was an issue).
>
> Anyway, I can't think of a reason why hashing the filehandle's a
> problem.

Thanks for the background.  I didn't see it as a problem exactly,
though I did wonder about different filehandles mapping to the same
nfs4_file (unlikely but possible).  You say that is required and I can
see how that might be.

My perspective was more that I do want to perform a lookup by inode.
When an UNLINK arrives we lookup the dentry and so know the inode.  Then
we want to see if the client holds a delegation.  So we want to find the
nfs4_file given the dentry/inode.  We could, of course, use
export_encode_fh, but that seems a bit round-about.
We could add a second index, but would need to allow that there could be
multiple nfs4_files for a given inode.

>
>> and add some wait queue somewhere
>> so the breaker could wait for a delegation to be returned.
>
> In the nfsd case we're just returning to the client immediately, so
> that's not really necessary, though maybe it could be useful.

Ah yes, so we do.  I inverted the logic in my mind.  That makes it easier.

>
>> My big-picture point is that any complexity created by NFSD's choice to
>> merge delegations to multiple clients into a single vfs-level delegation
>> should be handled by NFSD, and not imposed on the VFS.
>> It certainly makes sense for the VFS to understand that certain
>> operations are being performed by an fl_owner_t, and to allow
>> delegations to that owner to remain.  It doesn't make as much sense for
>> the VFS to understand that there is a finer granularity of ownership
>> than the one that it already supports.
>
> Fair enough, I'll think about that.

Thanks.  Below is a patch that does compile but is probably wrong is
various ways and definitely needs cleanliness work at least.  I provide
it just to be more concrete about my thinking.

NeilBrown

diff --git a/drivers/base/devtmpfs.c b/drivers/base/devtmpfs.c
index d2fb9c8ed205..c823a244f8b2 100644
=2D-- a/drivers/base/devtmpfs.c
+++ b/drivers/base/devtmpfs.c
@@ -216,7 +216,7 @@ static int handle_create(const char *nodename, umode_t =
mode, kuid_t uid,
 		newattrs.ia_gid =3D gid;
 		newattrs.ia_valid =3D ATTR_MODE|ATTR_UID|ATTR_GID;
 		inode_lock(d_inode(dentry));
=2D		notify_change(dentry, &newattrs, NULL);
+		notify_change(dentry, &newattrs, NULL, NULL);
 		inode_unlock(d_inode(dentry));
=20
 		/* mark as kernel-created inode */
@@ -323,9 +323,9 @@ static int handle_remove(const char *nodename, struct d=
evice *dev)
 			newattrs.ia_valid =3D
 				ATTR_UID|ATTR_GID|ATTR_MODE;
 			inode_lock(d_inode(dentry));
=2D			notify_change(dentry, &newattrs, NULL);
+			notify_change(dentry, &newattrs, NULL, NULL);
 			inode_unlock(d_inode(dentry));
=2D			err =3D vfs_unlink(d_inode(parent.dentry), dentry, NULL);
+			err =3D vfs_unlink(d_inode(parent.dentry), dentry, NULL, NULL);
 			if (!err || err =3D=3D -ENOENT)
 				deleted =3D 1;
 		}
diff --git a/fs/attr.c b/fs/attr.c
index 135304146120..d94e516070af 100644
=2D-- a/fs/attr.c
+++ b/fs/attr.c
@@ -185,6 +185,7 @@ EXPORT_SYMBOL(setattr_copy);
  * notify_change - modify attributes of a filesytem object
  * @dentry:	object affected
  * @iattr:	new attributes
+ * @owner:      allow delegations to this owner to remain
  * @delegated_inode: returns inode, if the inode is delegated
  *
  * The caller must hold the i_mutex on the affected object.
@@ -201,7 +202,7 @@ EXPORT_SYMBOL(setattr_copy);
  * the file open for write, as there can be no conflicting delegation in
  * that case.
  */
=2Dint notify_change(struct dentry * dentry, struct iattr * attr, struct in=
ode **delegated_inode)
+int notify_change(struct dentry * dentry, struct iattr * attr, fl_owner_t =
owner, struct inode **delegated_inode)
 {
 	struct inode *inode =3D dentry->d_inode;
 	umode_t mode =3D inode->i_mode;
@@ -304,7 +305,7 @@ int notify_change(struct dentry * dentry, struct iattr =
* attr, struct inode **de
 	error =3D security_inode_setattr(dentry, attr);
 	if (error)
 		return error;
=2D	error =3D try_break_deleg(inode, delegated_inode);
+	error =3D try_break_deleg(inode, owner, delegated_inode);
 	if (error)
 		return error;
=20
diff --git a/fs/inode.c b/fs/inode.c
index 50370599e371..c28fbb91b863 100644
=2D-- a/fs/inode.c
+++ b/fs/inode.c
@@ -1788,7 +1788,7 @@ static int __remove_privs(struct dentry *dentry, int =
kill)
 	 * Note we call this on write, so notify_change will not
 	 * encounter any conflicting delegations:
 	 */
=2D	return notify_change(dentry, &newattrs, NULL);
+	return notify_change(dentry, &newattrs, NULL, NULL);
 }
=20
 /*
diff --git a/fs/locks.c b/fs/locks.c
index afefeb4ad6de..231d93bfbdc1 100644
=2D-- a/fs/locks.c
+++ b/fs/locks.c
@@ -1408,6 +1408,8 @@ static bool leases_conflict(struct file_lock *lease, =
struct file_lock *breaker)
 		return false;
 	if ((breaker->fl_flags & FL_DELEG) && (lease->fl_flags & FL_LEASE))
 		return false;
+	if (breaker->fl_owner && breaker->fl_owner =3D=3D lease->fl_owner)
+		return false;
 	return locks_conflict(breaker, lease);
 }
=20
@@ -1429,6 +1431,7 @@ any_leases_conflict(struct inode *inode, struct file_=
lock *breaker)
 /**
  *	__break_lease	-	revoke all outstanding leases on file
  *	@inode: the inode of the file to return
+ *      @owner: if non-NULL, ignore leases held by this owner.
  *	@mode: O_RDONLY: break only write leases; O_WRONLY or O_RDWR:
  *	    break all leases
  *	@type: FL_LEASE: break leases and delegations; FL_DELEG: break
@@ -1439,7 +1442,7 @@ any_leases_conflict(struct inode *inode, struct file_=
lock *breaker)
  *	a call to open() or truncate().  This function can sleep unless you
  *	specified %O_NONBLOCK to your open().
  */
=2Dint __break_lease(struct inode *inode, unsigned int mode, unsigned int t=
ype)
+int __break_lease(struct inode *inode, fl_owner_t owner, unsigned int mode=
, unsigned int type)
 {
 	int error =3D 0;
 	struct file_lock_context *ctx;
@@ -1452,6 +1455,7 @@ int __break_lease(struct inode *inode, unsigned int m=
ode, unsigned int type)
 	if (IS_ERR(new_fl))
 		return PTR_ERR(new_fl);
 	new_fl->fl_flags =3D type;
+	new_fl->fl_owner =3D owner;
=20
 	/* typically we will check that ctx is non-NULL before calling */
 	ctx =3D smp_load_acquire(&inode->i_flctx);
diff --git a/fs/namei.c b/fs/namei.c
index ddb6a7c2b3d4..a1bf2ccdabb5 100644
=2D-- a/fs/namei.c
+++ b/fs/namei.c
@@ -3941,6 +3941,7 @@ SYSCALL_DEFINE1(rmdir, const char __user *, pathname)
  * vfs_unlink - unlink a filesystem object
  * @dir:	parent directory
  * @dentry:	victim
+ * @owner:	allow delegation to this owner to remain.
  * @delegated_inode: returns victim inode, if the inode is delegated.
  *
  * The caller must hold dir->i_mutex.
@@ -3955,7 +3956,7 @@ SYSCALL_DEFINE1(rmdir, const char __user *, pathname)
  * be appropriate for callers that expect the underlying filesystem not
  * to be NFS exported.
  */
=2Dint vfs_unlink(struct inode *dir, struct dentry *dentry, struct inode **=
delegated_inode)
+int vfs_unlink(struct inode *dir, struct dentry *dentry, fl_owner_t owner,=
 struct inode **delegated_inode)
 {
 	struct inode *target =3D dentry->d_inode;
 	int error =3D may_delete(dir, dentry, 0);
@@ -3972,7 +3973,7 @@ int vfs_unlink(struct inode *dir, struct dentry *dent=
ry, struct inode **delegate
 	else {
 		error =3D security_inode_unlink(dir, dentry);
 		if (!error) {
=2D			error =3D try_break_deleg(target, delegated_inode);
+			error =3D try_break_deleg(target, owner, delegated_inode);
 			if (error)
 				goto out;
 			error =3D dir->i_op->unlink(dir, dentry);
@@ -4040,7 +4041,7 @@ static long do_unlinkat(int dfd, const char __user *p=
athname)
 		error =3D security_path_unlink(&path, dentry);
 		if (error)
 			goto exit2;
=2D		error =3D vfs_unlink(path.dentry->d_inode, dentry, &delegated_inode);
+		error =3D vfs_unlink(path.dentry->d_inode, dentry, NULL, &delegated_inod=
e);
 exit2:
 		dput(dentry);
 	}
@@ -4049,7 +4050,7 @@ static long do_unlinkat(int dfd, const char __user *p=
athname)
 		iput(inode);	/* truncate the inode here */
 	inode =3D NULL;
 	if (delegated_inode) {
=2D		error =3D break_deleg_wait(&delegated_inode);
+		error =3D break_deleg_wait(NULL, &delegated_inode);
 		if (!error)
 			goto retry_deleg;
 	}
@@ -4152,6 +4153,7 @@ SYSCALL_DEFINE2(symlink, const char __user *, oldname=
, const char __user *, newn
  * @old_dentry:	object to be linked
  * @dir:	new parent
  * @new_dentry:	where to create the new link
+ * @owner:	allow delegation to this owner to remain
  * @delegated_inode: returns inode needing a delegation break
  *
  * The caller must hold dir->i_mutex
@@ -4166,7 +4168,8 @@ SYSCALL_DEFINE2(symlink, const char __user *, oldname=
, const char __user *, newn
  * be appropriate for callers that expect the underlying filesystem not
  * to be NFS exported.
  */
=2Dint vfs_link(struct dentry *old_dentry, struct inode *dir, struct dentry=
 *new_dentry, struct inode **delegated_inode)
+int vfs_link(struct dentry *old_dentry, struct inode *dir, struct dentry *=
new_dentry,
+	     fl_owner_t owner, struct inode **delegated_inode)
 {
 	struct inode *inode =3D old_dentry->d_inode;
 	unsigned max_links =3D dir->i_sb->s_max_links;
@@ -4210,7 +4213,7 @@ int vfs_link(struct dentry *old_dentry, struct inode =
*dir, struct dentry *new_de
 	else if (max_links && inode->i_nlink >=3D max_links)
 		error =3D -EMLINK;
 	else {
=2D		error =3D try_break_deleg(inode, delegated_inode);
+		error =3D try_break_deleg(inode, owner, delegated_inode);
 		if (!error)
 			error =3D dir->i_op->link(old_dentry, dir, new_dentry);
 	}
@@ -4280,11 +4283,11 @@ SYSCALL_DEFINE5(linkat, int, olddfd, const char __u=
ser *, oldname,
 	error =3D security_path_link(old_path.dentry, &new_path, new_dentry);
 	if (error)
 		goto out_dput;
=2D	error =3D vfs_link(old_path.dentry, new_path.dentry->d_inode, new_dentr=
y, &delegated_inode);
+	error =3D vfs_link(old_path.dentry, new_path.dentry->d_inode, new_dentry,=
 NULL, &delegated_inode);
 out_dput:
 	done_path_create(&new_path, new_dentry);
 	if (delegated_inode) {
=2D		error =3D break_deleg_wait(&delegated_inode);
+		error =3D break_deleg_wait(NULL, &delegated_inode);
 		if (!error) {
 			path_put(&old_path);
 			goto retry;
@@ -4312,6 +4315,7 @@ SYSCALL_DEFINE2(link, const char __user *, oldname, c=
onst char __user *, newname
  * @old_dentry:	source
  * @new_dir:	parent of destination
  * @new_dentry:	destination
+ * @owner:	allow delegation to this owner to remain
  * @delegated_inode: returns an inode needing a delegation break
  * @flags:	rename flags
  *
@@ -4358,6 +4362,7 @@ SYSCALL_DEFINE2(link, const char __user *, oldname, c=
onst char __user *, newname
  */
 int vfs_rename(struct inode *old_dir, struct dentry *old_dentry,
 	       struct inode *new_dir, struct dentry *new_dentry,
+	       fl_owner_t owner,
 	       struct inode **delegated_inode, unsigned int flags)
 {
 	int error;
@@ -4435,12 +4440,12 @@ int vfs_rename(struct inode *old_dir, struct dentry=
 *old_dentry,
 	if (is_dir && !(flags & RENAME_EXCHANGE) && target)
 		shrink_dcache_parent(new_dentry);
 	if (!is_dir) {
=2D		error =3D try_break_deleg(source, delegated_inode);
+		error =3D try_break_deleg(source, owner, delegated_inode);
 		if (error)
 			goto out;
 	}
 	if (target && !new_is_dir) {
=2D		error =3D try_break_deleg(target, delegated_inode);
+		error =3D try_break_deleg(target, owner, delegated_inode);
 		if (error)
 			goto out;
 	}
@@ -4594,7 +4599,7 @@ SYSCALL_DEFINE5(renameat2, int, olddfd, const char __=
user *, oldname,
 		goto exit5;
 	error =3D vfs_rename(old_path.dentry->d_inode, old_dentry,
 			   new_path.dentry->d_inode, new_dentry,
=2D			   &delegated_inode, flags);
+			   NULL, &delegated_inode, flags);
 exit5:
 	dput(new_dentry);
 exit4:
@@ -4602,7 +4607,7 @@ SYSCALL_DEFINE5(renameat2, int, olddfd, const char __=
user *, oldname,
 exit3:
 	unlock_rename(new_path.dentry, old_path.dentry);
 	if (delegated_inode) {
=2D		error =3D break_deleg_wait(&delegated_inode);
+		error =3D break_deleg_wait(NULL, &delegated_inode);
 		if (!error)
 			goto retry_deleg;
 	}
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 0c04f81aa63b..e713484b93b3 100644
=2D-- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3654,6 +3654,27 @@ find_file_locked(struct knfsd_fh *fh, unsigned int h=
ashval)
 	return NULL;
 }
=20
+static struct nfs4_file *
+find_deleg_file_by_inode(struct inode *ino)
+{
+	int i;
+	struct nfs4_file *fp;
+
+	if (!ino)
+		return NULL;
+
+	rcu_read_lock();
+	for (i =3D 0; i < FILE_HASH_SIZE; i++)
+		hlist_for_each_entry_rcu(fp, &file_hashtbl[i], fi_hash)
+			if (fp->fi_deleg_file && file_inode(fp->fi_deleg_file) =3D=3D ino)
+				if (atomic_inc_not_zero(&fp->fi_ref)) {
+					rcu_read_unlock();
+					return fp;
+				}
+
+	return NULL;
+}
+
 struct nfs4_file *
 find_file(struct knfsd_fh *fh)
 {
@@ -3825,6 +3846,49 @@ nfsd_break_deleg_cb(struct file_lock *fl)
 	return ret;
 }
=20
+static struct nfs4_client *nfsd4_client_from_rqst(struct svc_rqst *rqst)
+{
+	struct nfsd4_compoundres *resp;
+
+	/*
+	 * In case it's possible we could be called from NLM or ACL
+	 * code?:
+	 */
+	if (rqst->rq_prog !=3D NFS_PROGRAM)
+		return NULL;
+	if (rqst->rq_vers !=3D 4)
+		return NULL;
+	resp =3D rqst->rq_resp;
+	return resp->cstate.clp;
+}
+
+int nfsd_conflicting_leases(struct dentry *dentry, struct svc_rqst *rqstp)
+{
+	struct nfs4_client *cl;
+	struct nfs4_delegation *dl;
+	struct nfs4_file *fi;
+	bool conflict;
+
+	cl =3D nfsd4_client_from_rqst(rqstp);
+	if (!cl)
+		return 0;
+	fi =3D find_deleg_file_by_inode(d_inode(dentry));
+	if (!fi)
+		return 0;
+
+	spin_lock(&fi->fi_lock);
+	conflict =3D false;
+	list_for_each_entry(dl, &fi->fi_delegations, dl_perfile) {
+		if (dl->dl_stid.sc_client !=3D cl) {
+			fi->fi_had_conflict =3D true;
+			nfsd_break_one_deleg(dl);
+			conflict =3D true;
+		}
+	}
+	spin_unlock(&fi->fi_lock);
+	return conflict ? -EWOULDBLOCK : 0;
+}
+
 static int
 nfsd_change_deleg_cb(struct file_lock *onlist, int arg,
 		     struct list_head *dispose)
@@ -4137,6 +4201,8 @@ static bool nfsd4_cb_channel_good(struct nfs4_client =
*clp)
 	return clp->cl_minorversion && clp->cl_cb_state =3D=3D NFSD4_CB_UNKNOWN;
 }
=20
+char nfsd_deleg_owner[1];
+
 static struct file_lock *nfs4_alloc_init_lease(struct nfs4_file *fp, int f=
lag)
 {
 	struct file_lock *fl;
@@ -4148,7 +4214,7 @@ static struct file_lock *nfs4_alloc_init_lease(struct=
 nfs4_file *fp, int flag)
 	fl->fl_flags =3D FL_DELEG;
 	fl->fl_type =3D flag =3D=3D NFS4_OPEN_DELEGATE_READ? F_RDLCK: F_WRLCK;
 	fl->fl_end =3D OFFSET_MAX;
=2D	fl->fl_owner =3D (fl_owner_t)fp;
+	fl->fl_owner =3D (fl_owner_t)nfsd_deleg_owner;
 	fl->fl_pid =3D current->tgid;
 	return fl;
 }
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index bc69d40c4e8b..c091633fe441 100644
=2D-- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -75,6 +75,9 @@ struct raparm_hbucket {
 #define RAPARM_HASH_MASK	(RAPARM_HASH_SIZE-1)
 static struct raparm_hbucket	raparm_hash[RAPARM_HASH_SIZE];
=20
+bool nfsd_conflicting_leases(struct dentry *dentry, struct svc_rqst *rqstp=
);
+extern char nfsd_deleg_owner[1];
+
 /*=20
  * Called from nfsd_lookup and encode_dirent. Check if we have crossed=20
  * a mount point.
@@ -455,7 +458,8 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp=
, struct iattr *iap,
 			.ia_size	=3D iap->ia_size,
 		};
=20
=2D		host_err =3D notify_change(dentry, &size_attr, NULL);
+		host_err =3D nfsd_conflicting_leases(dentry, rqstp);
+		host_err =3D host_err ?: notify_change(dentry, &size_attr, nfsd_deleg_ow=
ner, NULL);
 		if (host_err)
 			goto out_unlock;
 		iap->ia_valid &=3D ~ATTR_SIZE;
@@ -470,7 +474,8 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp=
, struct iattr *iap,
 	}
=20
 	iap->ia_valid |=3D ATTR_CTIME;
=2D	host_err =3D notify_change(dentry, iap, NULL);
+	host_err =3D nfsd_conflicting_leases(dentry, rqstp);
+	host_err =3D host_err ?: notify_change(dentry, iap, nfsd_deleg_owner, NUL=
L);
=20
 out_unlock:
 	fh_unlock(fhp);
@@ -1590,7 +1595,8 @@ nfsd_link(struct svc_rqst *rqstp, struct svc_fh *ffhp,
 	err =3D nfserr_noent;
 	if (d_really_is_negative(dold))
 		goto out_dput;
=2D	host_err =3D vfs_link(dold, dirp, dnew, NULL);
+	host_err =3D nfsd_conflicting_leases(dold, rqstp);
+	host_err =3D host_err ?: vfs_link(dold, dirp, dnew, nfsd_deleg_owner, NUL=
L);
 	if (!host_err) {
 		err =3D nfserrno(commit_metadata(ffhp));
 		if (!err)
@@ -1683,7 +1689,9 @@ nfsd_rename(struct svc_rqst *rqstp, struct svc_fh *ff=
hp, char *fname, int flen,
 	if (ffhp->fh_export->ex_path.dentry !=3D tfhp->fh_export->ex_path.dentry)
 		goto out_dput_new;
=20
=2D	host_err =3D vfs_rename(fdir, odentry, tdir, ndentry, NULL, 0);
+	host_err =3D nfsd_conflicting_leases(odentry, rqstp);
+	host_err |=3D nfsd_conflicting_leases(ndentry, rqstp);
+	host_err =3D host_err ?: vfs_rename(fdir, odentry, tdir, ndentry, nfsd_de=
leg_owner, NULL, 0);
 	if (!host_err) {
 		host_err =3D commit_metadata(tfhp);
 		if (!host_err)
@@ -1752,9 +1760,10 @@ nfsd_unlink(struct svc_rqst *rqstp, struct svc_fh *f=
hp, int type,
 	if (!type)
 		type =3D d_inode(rdentry)->i_mode & S_IFMT;
=20
=2D	if (type !=3D S_IFDIR)
=2D		host_err =3D vfs_unlink(dirp, rdentry, NULL);
=2D	else
+	if (type !=3D S_IFDIR) {
+		host_err =3D nfsd_conflicting_leases(dentry, rqstp);
+		host_err =3D host_err ?: vfs_unlink(dirp, rdentry, nfsd_deleg_owner, NUL=
L);
+	} else
 		host_err =3D vfs_rmdir(dirp, rdentry);
 	if (!host_err)
 		host_err =3D commit_metadata(fhp);
diff --git a/fs/open.c b/fs/open.c
index 35bb784763a4..fad27de55ec0 100644
=2D-- a/fs/open.c
+++ b/fs/open.c
@@ -60,7 +60,7 @@ int do_truncate(struct dentry *dentry, loff_t length, uns=
igned int time_attrs,
=20
 	inode_lock(dentry->d_inode);
 	/* Note any delegations or leases have already been broken: */
=2D	ret =3D notify_change(dentry, &newattrs, NULL);
+	ret =3D notify_change(dentry, &newattrs, NULL, NULL);
 	inode_unlock(dentry->d_inode);
 	return ret;
 }
@@ -529,11 +529,11 @@ static int chmod_common(const struct path *path, umod=
e_t mode)
 		goto out_unlock;
 	newattrs.ia_mode =3D (mode & S_IALLUGO) | (inode->i_mode & ~S_IALLUGO);
 	newattrs.ia_valid =3D ATTR_MODE | ATTR_CTIME;
=2D	error =3D notify_change(path->dentry, &newattrs, &delegated_inode);
+	error =3D notify_change(path->dentry, &newattrs, NULL, &delegated_inode);
 out_unlock:
 	inode_unlock(inode);
 	if (delegated_inode) {
=2D		error =3D break_deleg_wait(&delegated_inode);
+		error =3D break_deleg_wait(NULL, &delegated_inode);
 		if (!error)
 			goto retry_deleg;
 	}
@@ -609,10 +609,10 @@ static int chown_common(const struct path *path, uid_=
t user, gid_t group)
 	inode_lock(inode);
 	error =3D security_path_chown(path, uid, gid);
 	if (!error)
=2D		error =3D notify_change(path->dentry, &newattrs, &delegated_inode);
+		error =3D notify_change(path->dentry, &newattrs, NULL, &delegated_inode);
 	inode_unlock(inode);
 	if (delegated_inode) {
=2D		error =3D break_deleg_wait(&delegated_inode);
+		error =3D break_deleg_wait(NULL, &delegated_inode);
 		if (!error)
 			goto retry_deleg;
 	}
diff --git a/fs/utimes.c b/fs/utimes.c
index 6571d8c848a0..c7b53d3602ce 100644
=2D-- a/fs/utimes.c
+++ b/fs/utimes.c
@@ -87,10 +87,10 @@ static int utimes_common(const struct path *path, struc=
t timespec *times)
 	}
 retry_deleg:
 	inode_lock(inode);
=2D	error =3D notify_change(path->dentry, &newattrs, &delegated_inode);
+	error =3D notify_change(path->dentry, &newattrs, NULL, &delegated_inode);
 	inode_unlock(inode);
 	if (delegated_inode) {
=2D		error =3D break_deleg_wait(&delegated_inode);
+		error =3D break_deleg_wait(NULL, &delegated_inode);
 		if (!error)
 			goto retry_deleg;
 	}
diff --git a/include/linux/fs.h b/include/linux/fs.h
index cc2e0f5a8fd1..6e434c677e4c 100644
=2D-- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1084,7 +1084,7 @@ extern int vfs_test_lock(struct file *, struct file_l=
ock *);
 extern int vfs_lock_file(struct file *, unsigned int, struct file_lock *, =
struct file_lock *);
 extern int vfs_cancel_lock(struct file *filp, struct file_lock *fl);
 extern int locks_lock_inode_wait(struct inode *inode, struct file_lock *fl=
);
=2Dextern int __break_lease(struct inode *inode, unsigned int flags, unsign=
ed int type);
+extern int __break_lease(struct inode *inode, fl_owner_t owner, unsigned i=
nt flags, unsigned int type);
 extern void lease_get_mtime(struct inode *, struct timespec *time);
 extern int generic_setlease(struct file *, long, struct file_lock **, void=
 **priv);
 extern int vfs_setlease(struct file *, long, struct file_lock **, void **);
@@ -1195,7 +1195,7 @@ static inline int locks_lock_inode_wait(struct inode =
*inode, struct file_lock *f
 	return -ENOLCK;
 }
=20
=2Dstatic inline int __break_lease(struct inode *inode, unsigned int mode, =
unsigned int type)
+static inline int __break_lease(struct inode *inode, fl_owner_t owner, uns=
igned int mode, unsigned int type)
 {
 	return 0;
 }
@@ -1573,10 +1573,10 @@ extern int vfs_create(struct inode *, struct dentry=
 *, umode_t, bool);
 extern int vfs_mkdir(struct inode *, struct dentry *, umode_t);
 extern int vfs_mknod(struct inode *, struct dentry *, umode_t, dev_t);
 extern int vfs_symlink(struct inode *, struct dentry *, const char *);
=2Dextern int vfs_link(struct dentry *, struct inode *, struct dentry *, st=
ruct inode **);
+extern int vfs_link(struct dentry *, struct inode *, struct dentry *, fl_o=
wner_t, struct inode **);
 extern int vfs_rmdir(struct inode *, struct dentry *);
=2Dextern int vfs_unlink(struct inode *, struct dentry *, struct inode **);
=2Dextern int vfs_rename(struct inode *, struct dentry *, struct inode *, s=
truct dentry *, struct inode **, unsigned int);
+extern int vfs_unlink(struct inode *, struct dentry *, fl_owner_t, struct =
inode **);
+extern int vfs_rename(struct inode *, struct dentry *, struct inode *, str=
uct dentry *, fl_owner_t, struct inode **, unsigned int);
 extern int vfs_whiteout(struct inode *, struct dentry *);
=20
 extern struct dentry *vfs_tmpfile(struct dentry *dentry, umode_t mode,
@@ -2260,11 +2260,11 @@ static inline int break_lease(struct inode *inode, =
unsigned int mode)
 	 */
 	smp_mb();
 	if (inode->i_flctx && !list_empty_careful(&inode->i_flctx->flc_lease))
=2D		return __break_lease(inode, mode, FL_LEASE);
+		return __break_lease(inode, NULL, mode, FL_LEASE);
 	return 0;
 }
=20
=2Dstatic inline int break_deleg(struct inode *inode, unsigned int mode)
+static inline int break_deleg(struct inode *inode, fl_owner_t owner, unsig=
ned int mode)
 {
 	/*
 	 * Since this check is lockless, we must ensure that any refcounts
@@ -2274,15 +2274,15 @@ static inline int break_deleg(struct inode *inode, =
unsigned int mode)
 	 */
 	smp_mb();
 	if (inode->i_flctx && !list_empty_careful(&inode->i_flctx->flc_lease))
=2D		return __break_lease(inode, mode, FL_DELEG);
+		return __break_lease(inode, owner, mode, FL_DELEG);
 	return 0;
 }
=20
=2Dstatic inline int try_break_deleg(struct inode *inode, struct inode **de=
legated_inode)
+static inline int try_break_deleg(struct inode *inode, fl_owner_t owner, s=
truct inode **delegated_inode)
 {
 	int ret;
=20
=2D	ret =3D break_deleg(inode, O_WRONLY|O_NONBLOCK);
+	ret =3D break_deleg(inode, owner, O_WRONLY|O_NONBLOCK);
 	if (ret =3D=3D -EWOULDBLOCK && delegated_inode) {
 		*delegated_inode =3D inode;
 		ihold(inode);
@@ -2290,11 +2290,11 @@ static inline int try_break_deleg(struct inode *ino=
de, struct inode **delegated_
 	return ret;
 }
=20
=2Dstatic inline int break_deleg_wait(struct inode **delegated_inode)
+static inline int break_deleg_wait(fl_owner_t owner, struct inode **delega=
ted_inode)
 {
 	int ret;
=20
=2D	ret =3D break_deleg(*delegated_inode, O_WRONLY);
+	ret =3D break_deleg(*delegated_inode, owner, O_WRONLY);
 	iput(*delegated_inode);
 	*delegated_inode =3D NULL;
 	return ret;
@@ -2304,7 +2304,7 @@ static inline int break_layout(struct inode *inode, b=
ool wait)
 {
 	smp_mb();
 	if (inode->i_flctx && !list_empty_careful(&inode->i_flctx->flc_lease))
=2D		return __break_lease(inode,
+		return __break_lease(inode, NULL,
 				wait ? O_WRONLY : O_WRONLY | O_NONBLOCK,
 				FL_LAYOUT);
 	return 0;
@@ -2316,17 +2316,17 @@ static inline int break_lease(struct inode *inode, =
unsigned int mode)
 	return 0;
 }
=20
=2Dstatic inline int break_deleg(struct inode *inode, unsigned int mode)
+static inline int break_deleg(struct inode *inode, fl_owner_t owner, unsig=
ned int mode)
 {
 	return 0;
 }
=20
=2Dstatic inline int try_break_deleg(struct inode *inode, struct inode **de=
legated_inode)
+static inline int try_break_deleg(struct inode *inode, fl_owner_t owner, s=
truct inode **delegated_inode)
 {
 	return 0;
 }
=20
=2Dstatic inline int break_deleg_wait(struct inode **delegated_inode)
+static inline int break_deleg_wait(fl_owner_t owner, struct inode **delega=
ted_inode)
 {
 	BUG();
 	return 0;
@@ -2643,7 +2643,7 @@ extern void emergency_remount(void);
 #ifdef CONFIG_BLOCK
 extern sector_t bmap(struct inode *, sector_t);
 #endif
=2Dextern int notify_change(struct dentry *, struct iattr *, struct inode *=
*);
+extern int notify_change(struct dentry *, struct iattr *, fl_owner_t, stru=
ct inode **);
 extern int inode_permission(struct inode *, int);
 extern int __inode_permission(struct inode *, int);
 extern int generic_permission(struct inode *, int);

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlmvGLUACgkQOeye3VZi
gbmhAg/8DL/cTNfX3pDHdTUd8LypOrZJ7t9AEmxmEd9FCOM7o8QbzUdEhMIWVcdU
E6iL6P2PqyyOpJ5obn6PsfxPJOw+iYLMmB5IInDeF5T0a+Jqjwt4qeCTXJQR4hC3
ApI1hU3+XRkZn6K3gI+YlBBrmulddkBC9f2JBCsNGGylHKizYCc4AtwcgCPTiLU0
J7YUQnPiohtg85gte+gPvSPzxCuR+pL8NtFdoSNASuFXqPI+9mtGvyqUdbaS50mF
FgRmQBekNT5HQ10vA4IYMbuSneKsoNyIGUkowTgBAYYrJcnT/Iy8mM1gpBoM7SjC
e+xmt+6wfhxF+ikoCNa7nj85DQSOPyv9Ii86Nn6g0L/X3OUzIhXbnd5NDTaLfIEv
lwuRZTKqTg2qpt3VeHJQmnbOBzfY12zvKCnzEFK+P05FcqA5SxRGm2oYodfvJMAq
rptlwXwn/ivaCdoECIQS663qFVpg66NBuBt+Buwhx5jhYo61C3/v+rsSAbTRKv4G
psCV9gBWJ0NfI3B9ITdSns8ODYDzMf5f426rU1iBD9p2FsYNWPPvFlMd//Ygjw1+
6mwbcmF+4LUWPDvir5bgsIZuCYA9EmqxcfU8AYU6QGrYQrn//68mn4KGlqavqeI1
1dAeLtv6Nd78m8ZvfaI9aDZW815XXonG6/GTWF+usmAi2kjgxaE=
=mhgM
-----END PGP SIGNATURE-----
--=-=-=--
