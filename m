From: Christoph Hellwig <hch@infradead.org>
Subject: [PATCH, RFC] rework rpc_pipefs
Date: Tue, 28 Jun 2005 12:29:23 +0100
Message-ID: <20050628112923.GA18703@infradead.org>
References: <20050506161018.GA3979@infradead.org> <1115410171.1960.26.camel@lade.trondhjem.org> <20050510122745.GA28981@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [10.3.1.92] (helo=sc8-sf-mx2-new.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DnEHS-00049o-9m
	for nfs@lists.sourceforge.net; Tue, 28 Jun 2005 04:29:30 -0700
Received: from pentafluge.infradead.org ([213.146.154.40])
	by sc8-sf-mx2-new.sourceforge.net with esmtp (Exim 4.44)
	id 1DnEHR-0008PD-HM
	for nfs@lists.sourceforge.net; Tue, 28 Jun 2005 04:29:30 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <20050510122745.GA28981@infradead.org>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Currently rpc_mkdir/rpc_rmdir and rpc_mkpipe/mk_unlink have an API that's
a little unfortunate.  They take a path relative to the rpc_pipefs root and
thus need to perform a full lookup.  If you look at debugfs or usbfs they
always store the dentry for directories they created and thus can pass in
a dentry + single pathname component pair into their equivalents of the
above functions.
 
And in fact rpc_pipefs actually stores a dentry for all but one component so
this change not only simplifies the core rpc_pipe code but also the callers.

Unfortuntately this code path is only used by the NFS4 idmapper and
AUTH_GSSAPI for which I don't have a test enviroment.  Could someone give
it a spin?  It's the last bit needed before we can rework the lookup_hash API


Index: linux-2.6/net/sunrpc/rpc_pipe.c
===================================================================
--- linux-2.6.orig/net/sunrpc/rpc_pipe.c	2005-05-09 13:50:05.000000000 +0200
+++ linux-2.6/net/sunrpc/rpc_pipe.c	2005-05-09 15:02:34.000000000 +0200
@@ -414,38 +414,6 @@
 	simple_release_fs(&rpc_mount, &rpc_mount_count);
 }
 
-static int
-rpc_lookup_parent(char *path, struct nameidata *nd)
-{
-	if (path[0] == '\0')
-		return -ENOENT;
-	if (rpc_get_mount()) {
-		printk(KERN_WARNING "%s: %s failed to mount "
-			       "pseudofilesystem \n", __FILE__, __FUNCTION__);
-		return -ENODEV;
-	}
-	nd->mnt = mntget(rpc_mount);
-	nd->dentry = dget(rpc_mount->mnt_root);
-	nd->last_type = LAST_ROOT;
-	nd->flags = LOOKUP_PARENT;
-	nd->depth = 0;
-
-	if (path_walk(path, nd)) {
-		printk(KERN_WARNING "%s: %s failed to find path %s\n",
-				__FILE__, __FUNCTION__, path);
-		rpc_put_mount();
-		return -ENOENT;
-	}
-	return 0;
-}
-
-static void
-rpc_release_path(struct nameidata *nd)
-{
-	path_release(nd);
-	rpc_put_mount();
-}
-
 static struct inode *
 rpc_get_inode(struct super_block *sb, int mode)
 {
@@ -550,197 +518,144 @@
 	return -ENOMEM;
 }
 
-static int
-__rpc_mkdir(struct inode *dir, struct dentry *dentry)
-{
-	struct inode *inode;
-
-	inode = rpc_get_inode(dir->i_sb, S_IFDIR | S_IRUSR | S_IXUSR);
-	if (!inode)
-		goto out_err;
-	inode->i_ino = iunique(dir->i_sb, 100);
-	d_instantiate(dentry, inode);
-	dir->i_nlink++;
-	inode_dir_notify(dir, DN_CREATE);
-	rpc_get_mount();
-	return 0;
-out_err:
-	printk(KERN_WARNING "%s: %s failed to allocate inode for dentry %s\n",
-			__FILE__, __FUNCTION__, dentry->d_name.name);
-	return -ENOMEM;
-}
-
-static int
-__rpc_rmdir(struct inode *dir, struct dentry *dentry)
-{
-	int error;
-
-	shrink_dcache_parent(dentry);
-	if (dentry->d_inode) {
-		rpc_close_pipes(dentry->d_inode);
-		rpc_inode_setowner(dentry->d_inode, NULL);
-	}
-	if ((error = simple_rmdir(dir, dentry)) != 0)
-		return error;
-	if (!error) {
-		inode_dir_notify(dir, DN_DELETE);
-		d_drop(dentry);
-		rpc_put_mount();
-	}
-	return 0;
-}
-
-static struct dentry *
-rpc_lookup_negative(char *path, struct nameidata *nd)
+struct dentry *
+rpc_mkdir(struct dentry *parent, char *name, struct rpc_clnt *rpc_client)
 {
+	struct inode *dir = parent->d_inode;
 	struct dentry *dentry;
-	struct inode *dir;
+	struct inode *inode;
 	int error;
-
-	if ((error = rpc_lookup_parent(path, nd)) != 0)
+	
+	error = rpc_get_mount();
+	if (error)
 		return ERR_PTR(error);
-	dir = nd->dentry->d_inode;
+
 	down(&dir->i_sem);
-	dentry = lookup_hash(&nd->last, nd->dentry);
+	dentry = lookup_one_len(name, parent, strlen(name));
 	if (IS_ERR(dentry))
-		goto out_err;
+		goto out_unlock;
 	if (dentry->d_inode) {
-		dput(dentry);
 		dentry = ERR_PTR(-EEXIST);
-		goto out_err;
+		goto out_dput;
 	}
-	return dentry;
-out_err:
-	up(&dir->i_sem);
-	rpc_release_path(nd);
-	return dentry;
-}
 
+	inode = rpc_get_inode(dir->i_sb, S_IFDIR | S_IRUSR | S_IXUSR);
+	if (!inode)
+		goto out_dput;
+	inode->i_ino = iunique(dir->i_sb, 100);
+	dir->i_nlink++;
+	RPC_I(dentry->d_inode)->private = rpc_client;
 
-struct dentry *
-rpc_mkdir(char *path, struct rpc_clnt *rpc_client)
-{
-	struct nameidata nd;
-	struct dentry *dentry;
-	struct inode *dir;
-	int error;
+	d_instantiate(dentry, inode);
+	dget(dentry);
+	up(&dir->i_sem);
+
+	inode_dir_notify(dir, DN_CREATE);
 
-	dentry = rpc_lookup_negative(path, &nd);
-	if (IS_ERR(dentry))
-		return dentry;
-	dir = nd.dentry->d_inode;
-	if ((error = __rpc_mkdir(dir, dentry)) != 0)
-		goto err_dput;
-	RPC_I(dentry->d_inode)->private = rpc_client;
 	error = rpc_populate(dentry, authfiles,
 			RPCAUTH_info, RPCAUTH_EOF);
 	if (error)
-		goto err_depopulate;
-out:
-	up(&dir->i_sem);
-	rpc_release_path(&nd);
+		goto out_depopulate;
+
 	return dentry;
-err_depopulate:
-	rpc_depopulate(dentry);
-	__rpc_rmdir(dir, dentry);
-err_dput:
+
+ out_depopulate:
+	rpc_rmdir(dentry);
+ out_dput:
 	dput(dentry);
-	printk(KERN_WARNING "%s: %s() failed to create directory %s (errno = %d)\n",
-			__FILE__, __FUNCTION__, path, error);
-	dentry = ERR_PTR(error);
-	goto out;
+ out_unlock:
+	up(&dir->i_sem);
+	rpc_put_mount();
+	return dentry;
 }
 
-int
-rpc_rmdir(char *path)
+void
+rpc_rmdir(struct dentry *dentry)
 {
-	struct nameidata nd;
-	struct dentry *dentry;
-	struct inode *dir;
-	int error;
+	struct dentry *parent = dentry->d_parent;
 
-	if ((error = rpc_lookup_parent(path, &nd)) != 0)
-		return error;
-	dir = nd.dentry->d_inode;
-	down(&dir->i_sem);
-	dentry = lookup_hash(&nd.last, nd.dentry);
-	if (IS_ERR(dentry)) {
-		error = PTR_ERR(dentry);
-		goto out_release;
-	}
 	rpc_depopulate(dentry);
-	error = __rpc_rmdir(dir, dentry);
-	dput(dentry);
-out_release:
-	up(&dir->i_sem);
-	rpc_release_path(&nd);
-	return error;
+
+	down(&parent->d_inode->i_sem);
+	if (dentry->d_inode) {
+		rpc_close_pipes(dentry->d_inode);
+		rpc_inode_setowner(dentry->d_inode, NULL);
+		simple_rmdir(parent->d_inode, dentry);
+	}
+	up(&parent->d_inode->i_sem);
+
+	inode_dir_notify(parent->d_inode, DN_DELETE);
+	rpc_put_mount();
 }
 
 struct dentry *
-rpc_mkpipe(char *path, void *private, struct rpc_pipe_ops *ops, int flags)
+rpc_mkpipe(struct dentry *parent, char *name, void *private,
+	   struct rpc_pipe_ops *ops, int flags)
 {
-	struct nameidata nd;
+	struct inode *dir = parent->d_inode;
 	struct dentry *dentry;
-	struct inode *dir, *inode;
+	struct inode *inode;
 	struct rpc_inode *rpci;
+	int error;
 
-	dentry = rpc_lookup_negative(path, &nd);
+	error = rpc_get_mount();
+	if (error)
+		return ERR_PTR(error);
+
+	down(&parent->d_inode->i_sem);
+	dentry = lookup_one_len(name, parent, strlen(name));
 	if (IS_ERR(dentry))
-		return dentry;
-	dir = nd.dentry->d_inode;
-	inode = rpc_get_inode(dir->i_sb, S_IFSOCK | S_IRUSR | S_IWUSR);
-	if (!inode)
-		goto err_dput;
+		goto out_unlock;
+	if (dentry->d_inode) {
+		dentry = ERR_PTR(-EEXIST);
+		goto out_dput;
+	}
+
+	inode = rpc_get_inode(parent->d_inode->i_sb,
+			S_IFSOCK | S_IRUSR | S_IWUSR);
+	if (!inode) {
+		dentry = ERR_PTR(-ENOMEM);
+		goto out_dput;
+	}
+
 	inode->i_ino = iunique(dir->i_sb, 100);
 	inode->i_fop = &rpc_pipe_fops;
-	d_instantiate(dentry, inode);
+
 	rpci = RPC_I(inode);
 	rpci->private = private;
 	rpci->flags = flags;
 	rpci->ops = ops;
+
+	d_instantiate(dentry, inode);
+	dget(dentry);
+	up(&parent->d_inode->i_sem);
+
 	inode_dir_notify(dir, DN_CREATE);
-out:
-	up(&dir->i_sem);
-	rpc_release_path(&nd);
 	return dentry;
-err_dput:
+
+ out_dput:
 	dput(dentry);
-	dentry = ERR_PTR(-ENOMEM);
-	printk(KERN_WARNING "%s: %s() failed to create pipe %s (errno = %d)\n",
-			__FILE__, __FUNCTION__, path, -ENOMEM);
-	goto out;
+ out_unlock:
+	up(&parent->d_inode->i_sem);
+	rpc_put_mount();
+	return dentry;
 }
 
-int
-rpc_unlink(char *path)
+void
+rpc_unlink(struct dentry *dentry)
 {
-	struct nameidata nd;
-	struct dentry *dentry;
-	struct inode *dir;
-	int error;
+	struct dentry *parent = dentry->d_parent;
 
-	if ((error = rpc_lookup_parent(path, &nd)) != 0)
-		return error;
-	dir = nd.dentry->d_inode;
-	down(&dir->i_sem);
-	dentry = lookup_hash(&nd.last, nd.dentry);
-	if (IS_ERR(dentry)) {
-		error = PTR_ERR(dentry);
-		goto out_release;
-	}
-	d_drop(dentry);
+	down(&parent->d_inode->i_sem);
 	if (dentry->d_inode) {
 		rpc_close_pipes(dentry->d_inode);
 		rpc_inode_setowner(dentry->d_inode, NULL);
-		error = simple_unlink(dir, dentry);
+		simple_unlink(parent->d_inode, dentry);
 	}
-	dput(dentry);
-	inode_dir_notify(dir, DN_DELETE);
-out_release:
-	up(&dir->i_sem);
-	rpc_release_path(&nd);
-	return error;
+	up(&parent->d_inode->i_sem);
+
+	inode_dir_notify(parent->d_inode, DN_DELETE);
+	rpc_put_mount();
 }
 
 /*


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
