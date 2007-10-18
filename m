From: Le Rouzic <aime.le-rouzic@bull.net>
Subject: Re: 2.6.23-rc9-CITI_NFS4_ALL-1 connectathon suite testdir error
Date: Thu, 18 Oct 2007 13:49:11 +0200
Message-ID: <47174837.6090404@bull.net>
References: <470F80BD.1090608@bull.net>
	<1192575407.7554.40.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Cc: nfs@lists.sourceforge.net
To: nfsv4 <nfsv4@linux-nfs.org>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <1192575407.7554.40.camel@heimdal.trondhjem.org>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <nfs.lists.sourceforge.net>


Hi,

Unfortunately not the case I was mentioning.
More on

------------------------------------------------------------- =

Bug: =

  http://bugzilla.linux-nfs.org/show_bug.cgi?id=3D150  =

  =



Cheers



Trond Myklebust a =E9crit :

>On Fri, 2007-10-12 at 16:12 +0200, Le Rouzic wrote:
>  =

>
>>Hi,
>>
>>Running 2.6.23-rc9-CITI_NFS4_ALL-1 on two Intel X86_64 bi-ways machines as
>>client and server, get the following error with the runtest (-s) of the s=
pecial
>>tests of the connectathon suite when running it with several other robust=
ness
>>tests (fsx,iozone,fssbfss_stress) in the same time:
>>
>> Second check for lost reply on non-idempotent requests
>> testing 50 idempotencies in directory "testdir"
>> rmdir 1: Directory not empty
>> special tests failed
>>
>>
>> =

>>------------------------------------------------------------- =

>>Bug: =

>>  http://bugzilla.linux-nfs.org/show_bug.cgi?id=3D150  =

>>  =

>>Cheers
>>    =

>>
>
>I'm hoping that the attached patch will fix this problem. It basically
>ensures that lookup(), readdir(), and open() cannot race with the
>sillyrename code.
>
>Cheers
>  Trond
>  =

>
>
> ------------------------------------------------------------------------
>
> Sujet:
> No Subject
> Exp=E9diteur:
> Trond Myklebust <Trond.Myklebust@netapp.com>
> Date:
> Mon, 15 Oct 2007 18:17:53 -0400
>
>
>lookup() and sillyrename() can race one another because the sillyrename()
>completion cannot take the parent directory's inode->i_mutex since the
>latter may be held by whoever is calling dput().
>
>We therefore have little option but to add extra locking to ensure that
>nfs_lookup() and nfs_atomic_open() do not race with the sillyrename
>completion.
>If somebody has looked up the sillyrenamed file in the meantime, we just
>transfer the sillydelete information to the new dentry.
>
>Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
>---
>
> fs/nfs/dir.c           |   14 +++++-
> fs/nfs/inode.c         |    3 +
> fs/nfs/nfs4proc.c      |    6 +++
> fs/nfs/unlink.c        |  114 ++++++++++++++++++++++++++++++++++++++++++-=
-----
> include/linux/nfs_fs.h |    8 +++
> 5 files changed, 127 insertions(+), 18 deletions(-)
>
>diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
>index 8ec7fbd..3533453 100644
>--- a/fs/nfs/dir.c
>+++ b/fs/nfs/dir.c
>@@ -562,6 +562,7 @@ static int nfs_readdir(struct file *filp, void *dirent=
, filldir_t filldir)
> 	nfs_fattr_init(&fattr);
> 	desc->entry =3D &my_entry;
> =

>+	nfs_block_sillyrename(dentry);
> 	while(!desc->entry->eof) {
> 		res =3D readdir_search_pagecache(desc);
> =

>@@ -592,6 +593,7 @@ static int nfs_readdir(struct file *filp, void *dirent=
, filldir_t filldir)
> 			break;
> 		}
> 	}
>+	nfs_unblock_sillyrename(dentry);
> 	unlock_kernel();
> 	if (res > 0)
> 		res =3D 0;
>@@ -866,6 +868,7 @@ struct dentry_operations nfs_dentry_operations =3D {
> static struct dentry *nfs_lookup(struct inode *dir, struct dentry * dentr=
y, struct nameidata *nd)
> {
> 	struct dentry *res;
>+	struct dentry *parent;
> 	struct inode *inode =3D NULL;
> 	int error;
> 	struct nfs_fh fhandle;
>@@ -894,26 +897,31 @@ static struct dentry *nfs_lookup(struct inode *dir, =
struct dentry * dentry, stru
> 		goto out_unlock;
> 	}
> =

>+	parent =3D dentry->d_parent;
>+	/* Protect against concurrent sillydeletes */
>+	nfs_block_sillyrename(parent);
> 	error =3D NFS_PROTO(dir)->lookup(dir, &dentry->d_name, &fhandle, &fattr);
> 	if (error =3D=3D -ENOENT)
> 		goto no_entry;
> 	if (error < 0) {
> 		res =3D ERR_PTR(error);
>-		goto out_unlock;
>+		goto out_unblock_sillyrename;
> 	}
> 	inode =3D nfs_fhget(dentry->d_sb, &fhandle, &fattr);
> 	res =3D (struct dentry *)inode;
> 	if (IS_ERR(res))
>-		goto out_unlock;
>+		goto out_unblock_sillyrename;
> =

> no_entry:
> 	res =3D d_materialise_unique(dentry, inode);
> 	if (res !=3D NULL) {
> 		if (IS_ERR(res))
>-			goto out_unlock;
>+			goto out_unblock_sillyrename;
> 		dentry =3D res;
> 	}
> 	nfs_set_verifier(dentry, nfs_save_change_attribute(dir));
>+out_unblock_sillyrename:
>+	nfs_unblock_sillyrename(parent);
> out_unlock:
> 	unlock_kernel();
> out:
>diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
>index 035c769..facb065 100644
>--- a/fs/nfs/inode.c
>+++ b/fs/nfs/inode.c
>@@ -1165,6 +1165,9 @@ static void init_once(void * foo, struct kmem_cache =
* cachep, unsigned long flag
> 	INIT_RADIX_TREE(&nfsi->nfs_page_tree, GFP_ATOMIC);
> 	nfsi->ncommit =3D 0;
> 	nfsi->npages =3D 0;
>+	atomic_set(&nfsi->silly_count, 1);
>+	INIT_HLIST_HEAD(&nfsi->silly_list);
>+	init_waitqueue_head(&nfsi->waitqueue);
> 	nfs4_init_once(nfsi);
> }
> =

>diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>index cb99fd9..2cb3b8b 100644
>--- a/fs/nfs/nfs4proc.c
>+++ b/fs/nfs/nfs4proc.c
>@@ -1372,6 +1372,7 @@ out_close:
> struct dentry *
> nfs4_atomic_open(struct inode *dir, struct dentry *dentry, struct nameida=
ta *nd)
> {
>+	struct dentry *parent;
> 	struct path path =3D {
> 		.mnt =3D nd->mnt,
> 		.dentry =3D dentry,
>@@ -1394,6 +1395,9 @@ nfs4_atomic_open(struct inode *dir, struct dentry *d=
entry, struct nameidata *nd)
> 	cred =3D rpcauth_lookupcred(NFS_CLIENT(dir)->cl_auth, 0);
> 	if (IS_ERR(cred))
> 		return (struct dentry *)cred;
>+	parent =3D dentry->d_parent;
>+	/* Protect against concurrent sillydeletes */
>+	nfs_block_sillyrename(parent);
> 	state =3D nfs4_do_open(dir, &path, nd->intent.open.flags, &attr, cred);
> 	put_rpccred(cred);
> 	if (IS_ERR(state)) {
>@@ -1401,12 +1405,14 @@ nfs4_atomic_open(struct inode *dir, struct dentry =
*dentry, struct nameidata *nd)
> 			d_add(dentry, NULL);
> 			nfs_set_verifier(dentry, nfs_save_change_attribute(dir));
> 		}
>+		nfs_unblock_sillyrename(parent);
> 		return (struct dentry *)state;
> 	}
> 	res =3D d_add_unique(dentry, igrab(state->inode));
> 	if (res !=3D NULL)
> 		path.dentry =3D res;
> 	nfs_set_verifier(path.dentry, nfs_save_change_attribute(dir));
>+	nfs_unblock_sillyrename(parent);
> 	nfs4_intent_set_file(nd, &path, state);
> 	return res;
> }
>diff --git a/fs/nfs/unlink.c b/fs/nfs/unlink.c
>index 1aed850..6ecd46c 100644
>--- a/fs/nfs/unlink.c
>+++ b/fs/nfs/unlink.c
>@@ -14,6 +14,7 @@
> =

> =

> struct nfs_unlinkdata {
>+	struct hlist_node list;
> 	struct nfs_removeargs args;
> 	struct nfs_removeres res;
> 	struct inode *dir;
>@@ -52,6 +53,20 @@ static int nfs_copy_dname(struct dentry *dentry, struct=
 nfs_unlinkdata *data)
> 	return 0;
> }
> =

>+static void nfs_free_dname(struct nfs_unlinkdata *data)
>+{
>+	kfree(data->args.name.name);
>+	data->args.name.name =3D NULL;
>+	data->args.name.len =3D 0;
>+}
>+
>+static void nfs_dec_sillycount(struct inode *dir)
>+{
>+	struct nfs_inode *nfsi =3D NFS_I(dir);
>+	if (atomic_dec_return(&nfsi->silly_count) =3D=3D 1)
>+		wake_up(&nfsi->waitqueue);
>+}
>+
> /**
>  * nfs_async_unlink_init - Initialize the RPC info
>  * task: rpc_task of the sillydelete
>@@ -95,6 +110,8 @@ static void nfs_async_unlink_done(struct rpc_task *task=
, void *calldata)
> static void nfs_async_unlink_release(void *calldata)
> {
> 	struct nfs_unlinkdata	*data =3D calldata;
>+
>+	nfs_dec_sillycount(data->dir);
> 	nfs_free_unlinkdata(data);
> }
> =

>@@ -104,33 +121,100 @@ static const struct rpc_call_ops nfs_unlink_ops =3D=
 {
> 	.rpc_release =3D nfs_async_unlink_release,
> };
> =

>-static int nfs_call_unlink(struct dentry *dentry, struct nfs_unlinkdata *=
data)
>+static int nfs_do_call_unlink(struct dentry *parent, struct inode *dir, s=
truct nfs_unlinkdata *data)
> {
> 	struct rpc_task *task;
>+	struct dentry *alias;
>+
>+	alias =3D d_lookup(parent, &data->args.name);
>+	if (alias !=3D NULL) {
>+		int ret =3D 0;
>+		/*
>+		 * Hey, we raced with lookup... See if we need to transfer
>+		 * the sillyrename information to the aliased dentry.
>+		 */
>+		nfs_free_dname(data);
>+		spin_lock(&alias->d_lock);
>+		if (!(alias->d_flags & DCACHE_NFSFS_RENAMED)) {
>+			alias->d_fsdata =3D data;
>+			alias->d_flags ^=3D DCACHE_NFSFS_RENAMED;
>+			ret =3D 1;
>+		}
>+		spin_unlock(&alias->d_lock);
>+		nfs_dec_sillycount(dir);
>+		dput(alias);
>+		return ret;
>+	}
>+	data->dir =3D igrab(dir);
>+	if (!data->dir) {
>+		nfs_dec_sillycount(dir);
>+		return 0;
>+	}
>+	data->args.fh =3D NFS_FH(dir);
>+	nfs_fattr_init(&data->res.dir_attr);
>+
>+	task =3D rpc_run_task(NFS_CLIENT(dir), RPC_TASK_ASYNC, &nfs_unlink_ops, =
data);
>+	if (!IS_ERR(task))
>+		rpc_put_task(task);
>+	return 1;
>+}
>+
>+static int nfs_call_unlink(struct dentry *dentry, struct nfs_unlinkdata *=
data)
>+{
> 	struct dentry *parent;
> 	struct inode *dir;
>+	int ret =3D 0;
> =

>-	if (nfs_copy_dname(dentry, data) < 0)
>-		goto out_free;
> =

> 	parent =3D dget_parent(dentry);
> 	if (parent =3D=3D NULL)
> 		goto out_free;
>-	dir =3D igrab(parent->d_inode);
>+	dir =3D parent->d_inode;
>+	if (nfs_copy_dname(dentry, data) =3D=3D 0)
>+		goto out_dput;
>+	/* Non-exclusive lock protects against concurrent lookup() calls */
>+	spin_lock(&dir->i_lock);
>+	if (atomic_inc_not_zero(&NFS_I(dir)->silly_count) =3D=3D 0) {
>+		/* Deferred delete */
>+		hlist_add_head(&data->list, &NFS_I(dir)->silly_list);
>+		spin_unlock(&dir->i_lock);
>+		ret =3D 1;
>+		goto out_dput;
>+	}
>+	spin_unlock(&dir->i_lock);
>+	ret =3D nfs_do_call_unlink(parent, dir, data);
>+out_dput:
> 	dput(parent);
>-	if (dir =3D=3D NULL)
>-		goto out_free;
>+out_free:
>+	return ret;
>+}
> =

>-	data->dir =3D dir;
>-	data->args.fh =3D NFS_FH(dir);
>-	nfs_fattr_init(&data->res.dir_attr);
>+void nfs_block_sillyrename(struct dentry *dentry)
>+{
>+	struct nfs_inode *nfsi =3D NFS_I(dentry->d_inode);
> =

>-	task =3D rpc_run_task(NFS_CLIENT(dir), RPC_TASK_ASYNC, &nfs_unlink_ops, =
data);
>-	if (!IS_ERR(task))
>-		rpc_put_task(task);
>-	return 1;
>-out_free:
>-	return 0;
>+	wait_event(nfsi->waitqueue, atomic_cmpxchg(&nfsi->silly_count, 1, 0) =3D=
=3D 1);
>+}
>+
>+void nfs_unblock_sillyrename(struct dentry *dentry)
>+{
>+	struct inode *dir =3D dentry->d_inode;
>+	struct nfs_inode *nfsi =3D NFS_I(dir);
>+	struct nfs_unlinkdata *data;
>+
>+	atomic_inc(&nfsi->silly_count);
>+	spin_lock(&dir->i_lock);
>+	while (!hlist_empty(&nfsi->silly_list)) {
>+		if (!atomic_inc_not_zero(&nfsi->silly_count))
>+			break;
>+		data =3D hlist_entry(nfsi->silly_list.first, struct nfs_unlinkdata, lis=
t);
>+		hlist_del(&data->list);
>+		spin_unlock(&dir->i_lock);
>+		if (nfs_do_call_unlink(dentry, dir, data) =3D=3D 0)
>+			nfs_free_unlinkdata(data);
>+		spin_lock(&dir->i_lock);
>+	}
>+	spin_unlock(&dir->i_lock);
> }
> =

> /**
>diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
>index c5164c2..e82a6eb 100644
>--- a/include/linux/nfs_fs.h
>+++ b/include/linux/nfs_fs.h
>@@ -160,6 +160,12 @@ struct nfs_inode {
> 	/* Open contexts for shared mmap writes */
> 	struct list_head	open_files;
> =

>+	/* Number of in-flight sillydelete RPC calls */
>+	atomic_t		silly_count;
>+	/* List of deferred sillydelete requests */
>+	struct hlist_head	silly_list;
>+	wait_queue_head_t	waitqueue;
>+
> #ifdef CONFIG_NFS_V4
> 	struct nfs4_cached_acl	*nfs4_acl;
>         /* NFSv4 state */
>@@ -394,6 +400,8 @@ extern void nfs_release_automount_timer(void);
>  */
> extern int  nfs_async_unlink(struct inode *dir, struct dentry *dentry);
> extern void nfs_complete_unlink(struct dentry *dentry, struct inode *);
>+extern void nfs_block_sillyrename(struct dentry *dentry);
>+extern void nfs_unblock_sillyrename(struct dentry *dentry);
> =

> /*
>  * linux/fs/nfs/write.c
>  =

>


-- =

-----------------------------------------------------------------
Company : Bull, Architect of an Open World TM (www.bull.com)
Name    : Aime Le Rouzic =

Mail    : Bull - BP 208 - 38432 Echirolles Cedex - France
E-Mail  : aime.le-rouzic@bull.net
Phone   : 33 (4) 76.29.75.51
Fax     : 33 (4) 76.29.75.18
----------------------------------------------------------------- =
