From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 3/3] SUNRPC: Clean up the sillyrename code
Date: Sat, 14 Jul 2007 18:12:09 -0400
Message-ID: <20070714221209.13914.27061.stgit@heimdal.trondhjem.org>
References: <20070714221209.13914.10001.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Chuck Lever <Chuck.Lever@oracle.com>,
	Trond Myklebust <Trond.Myklebust@netapp.com>
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I9sEm-0004LB-J0
	for nfs@lists.sourceforge.net; Sat, 14 Jul 2007 17:45:24 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I9sEp-00009u-M3
	for nfs@lists.sourceforge.net; Sat, 14 Jul 2007 17:45:28 -0700
In-Reply-To: <20070714221209.13914.10001.stgit@heimdal.trondhjem.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

From: Trond Myklebust <Trond.Myklebust@netapp.com>

Fix a couple of bugs:
 - Don't rely on the parent dentry still being valid when the call completes.
   Fixes a race with shrink_dcache_for_umount_subtree()

 - Don't remove the file if the filehandle has been labelled as stale.

Fix a couple of inefficiencies
 - Remove the global list of sillyrenamed files. Instead we can cache the
   sillyrename information in the dentry->d_fsdata
 - Move common code from unlink_setup/unlink_done into fs/nfs/unlink.c

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/dir.c            |    4 -
 fs/nfs/nfs3proc.c       |   38 ++-------
 fs/nfs/nfs4proc.c       |   50 +++---------
 fs/nfs/proc.c           |   26 +-----
 fs/nfs/unlink.c         |  195 +++++++++++++++++++++--------------------------
 include/linux/nfs_fs.h  |    4 -
 include/linux/nfs_xdr.h |    5 -
 7 files changed, 120 insertions(+), 202 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 0fa1dbc..ea97408 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -869,7 +869,7 @@ static void nfs_dentry_iput(struct dentry *dentry, struct inode *inode)
 	if (dentry->d_flags & DCACHE_NFSFS_RENAMED) {
 		lock_kernel();
 		drop_nlink(inode);
-		nfs_complete_unlink(dentry);
+		nfs_complete_unlink(dentry, inode);
 		unlock_kernel();
 	}
 	/* When creating a negative dentry, we want to renew d_time */
@@ -1411,7 +1411,7 @@ static int nfs_sillyrename(struct inode *dir, struct dentry *dentry)
 		nfs_renew_times(dentry);
 		nfs_set_verifier(dentry, nfs_save_change_attribute(dir));
 		d_move(dentry, sdentry);
-		error = nfs_async_unlink(dentry);
+		error = nfs_async_unlink(dir, dentry);
  		/* If we return 0 we don't unlink */
 	}
 	dput(sdentry);
diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index eac07f2..c7ca5d7 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -370,41 +370,21 @@ nfs3_proc_remove(struct inode *dir, struct qstr *name)
 	return status;
 }
 
-static int
-nfs3_proc_unlink_setup(struct rpc_message *msg, struct dentry *dir, struct qstr *name)
+static void
+nfs3_proc_unlink_setup(struct rpc_message *msg, struct inode *dir)
 {
-	struct unlinkxdr {
-		struct nfs_removeargs arg;
-		struct nfs_removeres res;
-	} *ptr;
-
-	ptr = kmalloc(sizeof(*ptr), GFP_KERNEL);
-	if (!ptr)
-		return -ENOMEM;
-	ptr->arg.fh = NFS_FH(dir->d_inode);
-	ptr->arg.name.name = name->name;
-	ptr->arg.name.len = name->len;
-	nfs_fattr_init(&ptr->res.dir_attr);
 	msg->rpc_proc = &nfs3_procedures[NFS3PROC_REMOVE];
-	msg->rpc_argp = &ptr->arg;
-	msg->rpc_resp = &ptr->res;
-	return 0;
 }
 
 static int
-nfs3_proc_unlink_done(struct dentry *dir, struct rpc_task *task)
+nfs3_proc_unlink_done(struct rpc_task *task, struct inode *dir)
 {
-	struct rpc_message *msg = &task->tk_msg;
-	struct nfs_fattr	*dir_attr;
-
-	if (nfs3_async_handle_jukebox(task, dir->d_inode))
-		return 1;
-	if (msg->rpc_argp) {
-		dir_attr = &((struct nfs_removeres*)msg->rpc_resp)->dir_attr;
-		nfs_post_op_update_inode(dir->d_inode, dir_attr);
-		kfree(msg->rpc_argp);
-	}
-	return 0;
+	struct nfs_removeres *res;
+	if (nfs3_async_handle_jukebox(task, dir))
+		return 0;
+	res = task->tk_msg.rpc_resp;
+	nfs_post_op_update_inode(dir, &res->dir_attr);
+	return 1;
 }
 
 static int
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 05fd1e4..d4e7beb 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1945,48 +1945,26 @@ static int nfs4_proc_remove(struct inode *dir, struct qstr *name)
 	return err;
 }
 
-struct unlink_desc {
-	struct nfs_removeargs args;
-	struct nfs_removeres res;
-};
-
-static int nfs4_proc_unlink_setup(struct rpc_message *msg, struct dentry *dir,
-		struct qstr *name)
+static void nfs4_proc_unlink_setup(struct rpc_message *msg, struct inode *dir)
 {
-	struct nfs_server *server = NFS_SERVER(dir->d_inode);
-	struct unlink_desc *up;
+	struct nfs_server *server = NFS_SERVER(dir);
+	struct nfs_removeargs *args = msg->rpc_argp;
+	struct nfs_removeres *res = msg->rpc_resp;
 
-	up = kmalloc(sizeof(*up), GFP_KERNEL);
-	if (!up)
-		return -ENOMEM;
-	
-	up->args.fh = NFS_FH(dir->d_inode);
-	up->args.name.len = name->len;
-	up->args.name.name = name->name;
-	up->args.bitmask = server->attr_bitmask;
-	up->res.server = server;
-	nfs_fattr_init(&up->res.dir_attr);
-	
+	args->bitmask = server->attr_bitmask;
+	res->server = server;
 	msg->rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_REMOVE];
-	msg->rpc_argp = &up->args;
-	msg->rpc_resp = &up->res;
-	return 0;
 }
 
-static int nfs4_proc_unlink_done(struct dentry *dir, struct rpc_task *task)
+static int nfs4_proc_unlink_done(struct rpc_task *task, struct inode *dir)
 {
-	struct rpc_message *msg = &task->tk_msg;
-	struct unlink_desc *up;
-	
-	if (msg->rpc_resp != NULL) {
-		up = container_of(msg->rpc_resp, struct unlink_desc, res);
-		update_changeattr(dir->d_inode, &up->res.cinfo);
-		nfs_post_op_update_inode(dir->d_inode, &up->res.dir_attr);
-		kfree(up);
-		msg->rpc_resp = NULL;
-		msg->rpc_argp = NULL;
-	}
-	return 0;
+	struct nfs_removeres *res = task->tk_msg.rpc_resp;
+
+	if (nfs4_async_handle_error(task, res->server) == -EAGAIN)
+		return 0;
+	update_changeattr(dir, &res->cinfo);
+	nfs_post_op_update_inode(dir, &res->dir_attr);
+	return 1;
 }
 
 static int _nfs4_proc_rename(struct inode *old_dir, struct qstr *old_name,
diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
index 3b3eb69..845cdde 100644
--- a/fs/nfs/proc.c
+++ b/fs/nfs/proc.c
@@ -291,32 +291,16 @@ nfs_proc_remove(struct inode *dir, struct qstr *name)
 	return status;
 }
 
-static int
-nfs_proc_unlink_setup(struct rpc_message *msg, struct dentry *dir, struct qstr *name)
+static void
+nfs_proc_unlink_setup(struct rpc_message *msg, struct inode *dir)
 {
-	struct nfs_removeargs *arg;
-
-	arg = kmalloc(sizeof(*arg), GFP_KERNEL);
-	if (!arg)
-		return -ENOMEM;
-	arg->fh = NFS_FH(dir->d_inode);
-	arg->name.name = name->name;
-	arg->name.len = name->len;
 	msg->rpc_proc = &nfs_procedures[NFSPROC_REMOVE];
-	msg->rpc_argp = arg;
-	return 0;
 }
 
-static int
-nfs_proc_unlink_done(struct dentry *dir, struct rpc_task *task)
+static int nfs_proc_unlink_done(struct rpc_task *task, struct inode *dir)
 {
-	struct rpc_message *msg = &task->tk_msg;
-	
-	if (msg->rpc_argp) {
-		nfs_mark_for_revalidate(dir->d_inode);
-		kfree(msg->rpc_argp);
-	}
-	return 0;
+	nfs_mark_for_revalidate(dir);
+	return 1;
 }
 
 static int
diff --git a/fs/nfs/unlink.c b/fs/nfs/unlink.c
index 0e28189..045ab80 100644
--- a/fs/nfs/unlink.c
+++ b/fs/nfs/unlink.c
@@ -3,7 +3,6 @@
  *
  * nfs sillydelete handling
  *
- * NOTE: we rely on holding the BKL for list manipulation protection.
  */
 
 #include <linux/slab.h>
@@ -15,46 +14,23 @@
 
 
 struct nfs_unlinkdata {
-	struct nfs_unlinkdata	*next;
-	struct dentry	*dir, *dentry;
-	struct qstr	name;
-	struct rpc_task	task;
+	struct nfs_removeargs args;
+	struct nfs_removeres res;
+	struct inode *dir;
 	struct rpc_cred	*cred;
-	unsigned int	count;
 };
 
-static struct nfs_unlinkdata	*nfs_deletes;
-static RPC_WAITQ(nfs_delete_queue, "nfs_delete_queue");
-
-/**
- * nfs_detach_unlinkdata - Remove asynchronous unlink from global list
- * @data: pointer to descriptor
- */
-static inline void
-nfs_detach_unlinkdata(struct nfs_unlinkdata *data)
-{
-	struct nfs_unlinkdata	**q;
-
-	for (q = &nfs_deletes; *q != NULL; q = &((*q)->next)) {
-		if (*q == data) {
-			*q = data->next;
-			break;
-		}
-	}
-}
-
 /**
- * nfs_put_unlinkdata - release data from a sillydelete operation.
+ * nfs_free_unlinkdata - release data from a sillydelete operation.
  * @data: pointer to unlink structure.
  */
 static void
-nfs_put_unlinkdata(struct nfs_unlinkdata *data)
+nfs_free_unlinkdata(struct nfs_unlinkdata *data)
 {
-	if (--data->count == 0) {
-		nfs_detach_unlinkdata(data);
-		kfree(data->name.name);
-		kfree(data);
-	}
+	iput(data->dir);
+	put_rpccred(data->cred);
+	kfree(data->args.name.name);
+	kfree(data);
 }
 
 #define NAME_ALLOC_LEN(len)	((len+16) & ~15)
@@ -63,50 +39,36 @@ nfs_put_unlinkdata(struct nfs_unlinkdata *data)
  * @dentry: pointer to dentry
  * @data: nfs_unlinkdata
  */
-static inline void
-nfs_copy_dname(struct dentry *dentry, struct nfs_unlinkdata *data)
+static int nfs_copy_dname(struct dentry *dentry, struct nfs_unlinkdata *data)
 {
 	char		*str;
 	int		len = dentry->d_name.len;
 
-	str = kmalloc(NAME_ALLOC_LEN(len), GFP_KERNEL);
+	str = kmemdup(dentry->d_name.name, NAME_ALLOC_LEN(len), GFP_KERNEL);
 	if (!str)
-		return;
-	memcpy(str, dentry->d_name.name, len);
-	if (!data->name.len) {
-		data->name.len = len;
-		data->name.name = str;
-	} else
-		kfree(str);
+		return -ENOMEM;
+	data->args.name.len = len;
+	data->args.name.name = str;
+	return 0;
 }
 
 /**
  * nfs_async_unlink_init - Initialize the RPC info
- * @task: rpc_task of the sillydelete
- *
- * We delay initializing RPC info until after the call to dentry_iput()
- * in order to minimize races against rename().
+ * task: rpc_task of the sillydelete
  */
 static void nfs_async_unlink_init(struct rpc_task *task, void *calldata)
 {
-	struct nfs_unlinkdata	*data = calldata;
-	struct dentry		*dir = data->dir;
-	struct rpc_message	msg = {
-		.rpc_cred	= data->cred,
+	struct nfs_unlinkdata *data = calldata;
+	struct inode *dir = data->dir;
+	struct rpc_message msg = {
+		.rpc_argp = &data->args,
+		.rpc_resp = &data->res,
+		.rpc_cred = data->cred,
 	};
-	int			status = -ENOENT;
-
-	if (!data->name.len)
-		goto out_err;
 
-	status = NFS_PROTO(dir->d_inode)->unlink_setup(&msg, dir, &data->name);
-	if (status < 0)
-		goto out_err;
-	nfs_begin_data_update(dir->d_inode);
+	nfs_begin_data_update(dir);
+	NFS_PROTO(dir)->unlink_setup(&msg, dir);
 	rpc_call_setup(task, &msg, 0);
-	return;
- out_err:
-	rpc_exit(task, status);
 }
 
 /**
@@ -117,19 +79,13 @@ static void nfs_async_unlink_init(struct rpc_task *task, void *calldata)
  */
 static void nfs_async_unlink_done(struct rpc_task *task, void *calldata)
 {
-	struct nfs_unlinkdata	*data = calldata;
-	struct dentry		*dir = data->dir;
-	struct inode		*dir_i;
-
-	if (!dir)
-		return;
-	dir_i = dir->d_inode;
-	nfs_end_data_update(dir_i);
-	if (NFS_PROTO(dir_i)->unlink_done(dir, task))
-		return;
-	put_rpccred(data->cred);
-	data->cred = NULL;
-	dput(dir);
+	struct nfs_unlinkdata *data = calldata;
+	struct inode *dir = data->dir;
+
+	if (!NFS_PROTO(dir)->unlink_done(task, dir))
+		rpc_restart_call(task);
+	else
+		nfs_end_data_update(dir);
 }
 
 /**
@@ -142,7 +98,7 @@ static void nfs_async_unlink_done(struct rpc_task *task, void *calldata)
 static void nfs_async_unlink_release(void *calldata)
 {
 	struct nfs_unlinkdata	*data = calldata;
-	nfs_put_unlinkdata(data);
+	nfs_free_unlinkdata(data);
 }
 
 static const struct rpc_call_ops nfs_unlink_ops = {
@@ -151,73 +107,94 @@ static const struct rpc_call_ops nfs_unlink_ops = {
 	.rpc_release = nfs_async_unlink_release,
 };
 
+static int nfs_call_unlink(struct dentry *dentry, struct nfs_unlinkdata *data)
+{
+	struct rpc_task *task;
+	struct dentry *parent;
+	struct inode *dir;
+
+	if (nfs_copy_dname(dentry, data) < 0)
+		goto out_free;
+
+	parent = dget_parent(dentry);
+	if (parent == NULL)
+		goto out_free;
+	dir = igrab(parent->d_inode);
+	dput(parent);
+	if (dir == NULL)
+		goto out_free;
+
+	data->dir = dir;
+	data->args.fh = NFS_FH(dir);
+	nfs_fattr_init(&data->res.dir_attr);
+
+	task = rpc_run_task(NFS_CLIENT(dir), RPC_TASK_ASYNC, &nfs_unlink_ops, data);
+	if (!IS_ERR(task))
+		rpc_put_task(task);
+	return 1;
+out_free:
+	return 0;
+}
+
 /**
  * nfs_async_unlink - asynchronous unlinking of a file
+ * @dir: parent directory of dentry
  * @dentry: dentry to unlink
  */
 int
-nfs_async_unlink(struct dentry *dentry)
+nfs_async_unlink(struct inode *dir, struct dentry *dentry)
 {
-	struct dentry	*dir = dentry->d_parent;
-	struct nfs_unlinkdata	*data;
-	struct rpc_clnt	*clnt = NFS_CLIENT(dir->d_inode);
-	int		status = -ENOMEM;
+	struct nfs_unlinkdata *data;
+	int status = -ENOMEM;
 
 	data = kzalloc(sizeof(*data), GFP_KERNEL);
-	if (!data)
+	if (data == NULL)
 		goto out;
 
-	data->cred = rpcauth_lookupcred(clnt->cl_auth, 0);
+	data->cred = rpcauth_lookupcred(NFS_CLIENT(dir)->cl_auth, 0);
 	if (IS_ERR(data->cred)) {
 		status = PTR_ERR(data->cred);
 		goto out_free;
 	}
-	data->dir = dget(dir);
-	data->dentry = dentry;
-
-	data->next = nfs_deletes;
-	nfs_deletes = data;
-	data->count = 1;
-
-	rpc_init_task(&data->task, clnt, RPC_TASK_ASYNC, &nfs_unlink_ops, data);
 
+	status = -EBUSY;
 	spin_lock(&dentry->d_lock);
+	if (dentry->d_flags & DCACHE_NFSFS_RENAMED)
+		goto out_unlock;
 	dentry->d_flags |= DCACHE_NFSFS_RENAMED;
+	dentry->d_fsdata = data;
 	spin_unlock(&dentry->d_lock);
-
-	rpc_sleep_on(&nfs_delete_queue, &data->task, NULL, NULL);
-	status = 0;
- out:
-	return status;
+	return 0;
+out_unlock:
+	spin_unlock(&dentry->d_lock);
+	put_rpccred(data->cred);
 out_free:
 	kfree(data);
+out:
 	return status;
 }
 
 /**
  * nfs_complete_unlink - Initialize completion of the sillydelete
  * @dentry: dentry to delete
+ * @inode: inode
  *
  * Since we're most likely to be called by dentry_iput(), we
  * only use the dentry to find the sillydelete. We then copy the name
  * into the qstr.
  */
 void
-nfs_complete_unlink(struct dentry *dentry)
+nfs_complete_unlink(struct dentry *dentry, struct inode *inode)
 {
-	struct nfs_unlinkdata	*data;
+	struct nfs_unlinkdata	*data = NULL;
 
-	for(data = nfs_deletes; data != NULL; data = data->next) {
-		if (dentry == data->dentry)
-			break;
-	}
-	if (!data)
-		return;
-	data->count++;
-	nfs_copy_dname(dentry, data);
 	spin_lock(&dentry->d_lock);
-	dentry->d_flags &= ~DCACHE_NFSFS_RENAMED;
+	if (dentry->d_flags & DCACHE_NFSFS_RENAMED) {
+		dentry->d_flags &= ~DCACHE_NFSFS_RENAMED;
+		data = dentry->d_fsdata;
+	}
 	spin_unlock(&dentry->d_lock);
-	rpc_wake_up_task(&data->task);
-	nfs_put_unlinkdata(data);
+
+	if (data != NULL && (NFS_STALE(inode) || !nfs_call_unlink(dentry, data)))
+		nfs_free_unlinkdata(data);
 }
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index c098ae1..9ba4aec 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -407,8 +407,8 @@ extern void nfs_release_automount_timer(void);
 /*
  * linux/fs/nfs/unlink.c
  */
-extern int  nfs_async_unlink(struct dentry *);
-extern void nfs_complete_unlink(struct dentry *);
+extern int  nfs_async_unlink(struct inode *dir, struct dentry *dentry);
+extern void nfs_complete_unlink(struct dentry *dentry, struct inode *);
 
 /*
  * linux/fs/nfs/write.c
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 7babcb1..cf74a4d 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -791,9 +791,8 @@ struct nfs_rpc_ops {
 	int	(*create)  (struct inode *, struct dentry *,
 			    struct iattr *, int, struct nameidata *);
 	int	(*remove)  (struct inode *, struct qstr *);
-	int	(*unlink_setup)  (struct rpc_message *,
-			    struct dentry *, struct qstr *);
-	int	(*unlink_done) (struct dentry *, struct rpc_task *);
+	void	(*unlink_setup)  (struct rpc_message *, struct inode *dir);
+	int	(*unlink_done) (struct rpc_task *, struct inode *);
 	int	(*rename)  (struct inode *, struct qstr *,
 			    struct inode *, struct qstr *);
 	int	(*link)    (struct inode *, struct inode *, struct qstr *);

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
