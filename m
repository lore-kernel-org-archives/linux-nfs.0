From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: [PATCH 2.5.60] further rpc_pipefs cleanups...
Date: Thu, 13 Feb 2003 15:50:38 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15947.45246.506230.39790@charged.uio.no>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel <linux-kernel@vger.kernel.org>,
    NFS maillist <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14] ident=7411)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18jKhT-0006On-00
	for <nfs@lists.sourceforge.net>; Thu, 13 Feb 2003 06:50:55 -0800
To: Linus Torvalds <torvalds@transmeta.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


  - Only set up pipefs entries for those RPC services that actually
    need them (for the moment NFS only). Portmap, lockd,... shouldn't
    need to make upcalls.

 - Add in missing semaphore in rpc_populate().

 - Make inode/dentry variable names in rpc_depopulate/rpc_populate
   more consistent w.r.t other functions in rpc_pipe.c

 - Call shrink_dcache_parent() in order to clean up child entries
   before we rmdir().

Cheers,
  Trond

diff -u --recursive --new-file linux-2.5.60/fs/nfs/inode.c linux-2.5.60-00-fix_pipes/fs/nfs/inode.c
--- linux-2.5.60/fs/nfs/inode.c	2003-01-12 22:40:13.000000000 +0100
+++ linux-2.5.60-00-fix_pipes/fs/nfs/inode.c	2003-02-13 13:57:46.000000000 +0100
@@ -93,6 +93,7 @@
 	.nrvers			= sizeof(nfs_version) / sizeof(nfs_version[0]),
 	.version		= nfs_version,
 	.stats			= &nfs_rpcstat,
+	.pipe_dir_name		= "/nfs",
 };
 
 static inline unsigned long
diff -u --recursive --new-file linux-2.5.60/include/linux/sunrpc/clnt.h linux-2.5.60-00-fix_pipes/include/linux/sunrpc/clnt.h
--- linux-2.5.60/include/linux/sunrpc/clnt.h	2003-01-12 22:39:49.000000000 +0100
+++ linux-2.5.60-00-fix_pipes/include/linux/sunrpc/clnt.h	2003-02-13 13:57:46.000000000 +0100
@@ -79,6 +79,7 @@
 	unsigned int		nrvers;		/* number of versions */
 	struct rpc_version **	version;	/* version array */
 	struct rpc_stat *	stats;		/* statistics */
+	char *			pipe_dir_name;	/* path to rpc_pipefs dir */
 };
 
 struct rpc_version {
diff -u --recursive --new-file linux-2.5.60/net/sunrpc/clnt.c linux-2.5.60-00-fix_pipes/net/sunrpc/clnt.c
--- linux-2.5.60/net/sunrpc/clnt.c	2003-02-07 21:25:20.000000000 +0100
+++ linux-2.5.60-00-fix_pipes/net/sunrpc/clnt.c	2003-02-13 13:57:46.000000000 +0100
@@ -63,6 +63,32 @@
 static u32 *	call_verify(struct rpc_task *task);
 
 
+static int
+rpc_setup_pipedir(struct rpc_clnt *clnt, char *dir_name)
+{
+	static uint32_t clntid;
+	int maxlen = sizeof(clnt->cl_pathname);
+	int error;
+
+	if (dir_name == NULL)
+		return 0;
+	for (;;) {
+		snprintf(clnt->cl_pathname, sizeof(clnt->cl_pathname),
+				"%s/clnt%x", dir_name,
+				(unsigned int)clntid++);
+		clnt->cl_pathname[sizeof(clnt->cl_pathname) - 1] = '\0';
+		clnt->cl_dentry = rpc_mkdir(clnt->cl_pathname, clnt);
+		if (!IS_ERR(clnt->cl_dentry))
+			return 0;
+		error = PTR_ERR(clnt->cl_dentry);
+		if (error != -EEXIST) {
+			printk(KERN_INFO "RPC: Couldn't create pipefs entry %s, error %d\n",
+					clnt->cl_pathname, error);
+			return error;
+		}
+	}
+}
+
 /*
  * Create an RPC client
  * FIXME: This should also take a flags argument (as in task->tk_flags).
@@ -109,14 +135,9 @@
 
 	rpc_init_rtt(&clnt->cl_rtt, xprt->timeout.to_initval);
 
-	snprintf(clnt->cl_pathname, sizeof(clnt->cl_pathname),
-			"/%s/clnt%p", clnt->cl_protname, clnt);
-	clnt->cl_dentry = rpc_mkdir(clnt->cl_pathname, clnt);
-	if (IS_ERR(clnt->cl_dentry)) {
-		printk(KERN_INFO "RPC: Couldn't create pipefs entry %s\n",
-				clnt->cl_pathname);
+	if (rpc_setup_pipedir(clnt, program->pipe_dir_name) < 0)
 		goto out_no_path;
-	}
+
 	if (!rpcauth_create(flavor, clnt)) {
 		printk(KERN_INFO "RPC: Couldn't create auth handle (flavor %u)\n",
 				flavor);
diff -u --recursive --new-file linux-2.5.60/net/sunrpc/rpc_pipe.c linux-2.5.60-00-fix_pipes/net/sunrpc/rpc_pipe.c
--- linux-2.5.60/net/sunrpc/rpc_pipe.c	2003-02-12 09:19:07.000000000 +0100
+++ linux-2.5.60-00-fix_pipes/net/sunrpc/rpc_pipe.c	2003-02-13 13:57:46.000000000 +0100
@@ -476,15 +476,16 @@
  * FIXME: This probably has races.
  */
 static void
-rpc_depopulate(struct dentry *dir)
+rpc_depopulate(struct dentry *parent)
 {
+	struct inode *dir = parent->d_inode;
 	LIST_HEAD(head);
 	struct list_head *pos, *next;
 	struct dentry *dentry;
 
-	down(&dir->d_inode->i_sem);
+	down(&dir->i_sem);
 	spin_lock(&dcache_lock);
-	list_for_each_safe(pos, next, &dir->d_subdirs) {
+	list_for_each_safe(pos, next, &parent->d_subdirs) {
 		dentry = list_entry(pos, struct dentry, d_child);
 		if (!d_unhashed(dentry)) {
 			dget_locked(dentry);
@@ -499,32 +500,34 @@
 		__d_drop(dentry);
 		if (dentry->d_inode) {
 			rpc_inode_setowner(dentry->d_inode, NULL);
-			simple_unlink(dir->d_inode, dentry);
+			simple_unlink(dir, dentry);
 		}
 		dput(dentry);
 	}
-	up(&dir->d_inode->i_sem);
+	up(&dir->i_sem);
 }
 
 static int
-rpc_populate(struct dentry *dir,
+rpc_populate(struct dentry *parent,
 		struct rpc_filelist *files,
 		int start, int eof)
 {
-	void *private = RPC_I(dir->d_inode)->private;
+	struct inode *inode, *dir = parent->d_inode;
+	void *private = RPC_I(dir)->private;
 	struct qstr name;
 	struct dentry *dentry;
-	struct inode *inode;
 	int mode, i;
+
+	down(&dir->i_sem);
 	for (i = start; i < eof; i++) {
 		name.name = files[i].name;
 		name.len = strlen(name.name);
 		name.hash = full_name_hash(name.name, name.len);
-		dentry = d_alloc(dir, &name);
+		dentry = d_alloc(parent, &name);
 		if (!dentry)
 			goto out_bad;
 		mode = files[i].mode;
-		inode = rpc_get_inode(dir->d_inode->i_sb, mode);
+		inode = rpc_get_inode(dir->i_sb, mode);
 		if (!inode) {
 			dput(dentry);
 			goto out_bad;
@@ -535,13 +538,15 @@
 		if (private)
 			rpc_inode_setowner(inode, private);
 		if (S_ISDIR(mode))
-			dir->d_inode->i_nlink++;
+			dir->i_nlink++;
 		d_add(dentry, inode);
 	}
+	up(&dir->i_sem);
 	return 0;
 out_bad:
+	up(&dir->i_sem);
 	printk(KERN_WARNING "%s: %s failed to populate directory %s\n",
-			__FILE__, __FUNCTION__, dir->d_name.name);
+			__FILE__, __FUNCTION__, parent->d_name.name);
 	return -ENOMEM;
 }
 
@@ -570,6 +575,7 @@
 {
 	int error;
 
+	shrink_dcache_parent(dentry);
 	rpc_inode_setowner(dentry->d_inode, NULL);
 	if ((error = simple_rmdir(dir, dentry)) != 0)
 		return error;


-------------------------------------------------------
This SF.NET email is sponsored by: FREE  SSL Guide from Thawte
are you planning your Web Server Security? Click here to get a FREE
Thawte SSL guide and find the answers to all your  SSL security issues.
http://ads.sourceforge.net/cgi-bin/redirect.pl?thaw0026en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
