From: Chuck Lever <chucklever@gmail.com>
Subject: [PATCH 23/25] NFS: Fix double d_drop in nfs_instantiate()
	error path
Date: Wed, 09 Aug 2006 10:59:46 -0400
Message-ID: <20060809145946.3914.34497.stgit@picasso.dsl.sfldmi.ameritech.net>
References: <20060809144716.3914.62804.stgit@picasso.dsl.sfldmi.ameritech.net>
Reply-To: Chuck Lever <chucklever@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GApcV-0000pq-Vl
	for nfs@lists.sourceforge.net; Wed, 09 Aug 2006 08:05:20 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GApcW-0003J3-0i
	for nfs@lists.sourceforge.net; Wed, 09 Aug 2006 08:05:20 -0700
To: trond.myklebust@fys.uio.no
In-Reply-To: <20060809144716.3914.62804.stgit@picasso.dsl.sfldmi.ameritech.net>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

If the LOOKUP or GETATTR in nfs_instantiate fail, nfs_instantiate will do a
d_drop before returning.  But some callers already do a d_drop in the case
of an error return.  Make certain we do only one d_drop in all error paths.

This bug was introduced because over time, the symlink proc API diverged
slightly from the create/mkdir/mknod proc API.  To prevent other bugs of
this type, change the symlink proc API to be more like create/mkdir/mknod
and move the nfs_instantiate call into the symlink proc routines so it is
used in exactly the same way for create, mkdir, mknod, and symlink.

Test plan:
Connectathon, all versions of NFS.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/dir.c            |   16 ++++------------
 fs/nfs/nfs3proc.c       |   26 ++++++++++++++++----------
 fs/nfs/nfs4proc.c       |   31 ++++++++++++++++---------------
 fs/nfs/proc.c           |   29 +++++++++++++++++++++--------
 include/linux/nfs_xdr.h |    5 ++---
 5 files changed, 59 insertions(+), 48 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 428d963..ff4e852 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1143,23 +1143,20 @@ int nfs_instantiate(struct dentry *dentr
 		struct inode *dir = dentry->d_parent->d_inode;
 		error = NFS_PROTO(dir)->lookup(dir, &dentry->d_name, fhandle, fattr);
 		if (error)
-			goto out_err;
+			return error;
 	}
 	if (!(fattr->valid & NFS_ATTR_FATTR)) {
 		struct nfs_server *server = NFS_SB(dentry->d_sb);
 		error = server->rpc_ops->getattr(server, fhandle, fattr);
 		if (error < 0)
-			goto out_err;
+			return error;
 	}
 	inode = nfs_fhget(dentry->d_sb, fhandle, fattr);
 	error = PTR_ERR(inode);
 	if (IS_ERR(inode))
-		goto out_err;
+		return error;
 	d_instantiate(dentry, inode);
 	return 0;
-out_err:
-	d_drop(dentry);
-	return error;
 }
 
 /*
@@ -1444,8 +1441,6 @@ static int
 nfs_symlink(struct inode *dir, struct dentry *dentry, const char *symname)
 {
 	struct iattr attr;
-	struct nfs_fattr sym_attr;
-	struct nfs_fh sym_fh;
 	struct qstr qsymname;
 	int error;
 
@@ -1469,12 +1464,9 @@ #endif
 
 	lock_kernel();
 	nfs_begin_data_update(dir);
-	error = NFS_PROTO(dir)->symlink(dir, &dentry->d_name, &qsymname,
-					  &attr, &sym_fh, &sym_attr);
+	error = NFS_PROTO(dir)->symlink(dir, dentry, &qsymname, &attr);
 	nfs_end_data_update(dir);
 	if (!error)
-		error = nfs_instantiate(dentry, &sym_fh, &sym_attr);
-	else
 		d_drop(dentry);
 	unlock_kernel();
 	return error;
diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index 7143b1f..15eac8d 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -544,23 +544,23 @@ nfs3_proc_link(struct inode *inode, stru
 }
 
 static int
-nfs3_proc_symlink(struct inode *dir, struct qstr *name, struct qstr *path,
-		  struct iattr *sattr, struct nfs_fh *fhandle,
-		  struct nfs_fattr *fattr)
+nfs3_proc_symlink(struct inode *dir, struct dentry *dentry, struct qstr *path,
+		  struct iattr *sattr)
 {
-	struct nfs_fattr	dir_attr;
+	struct nfs_fh fhandle;
+	struct nfs_fattr fattr, dir_attr;
 	struct nfs3_symlinkargs	arg = {
 		.fromfh		= NFS_FH(dir),
-		.fromname	= name->name,
-		.fromlen	= name->len,
+		.fromname	= dentry->d_name.name,
+		.fromlen	= dentry->d_name.len,
 		.topath		= path->name,
 		.tolen		= path->len,
 		.sattr		= sattr
 	};
 	struct nfs3_diropres	res = {
 		.dir_attr	= &dir_attr,
-		.fh		= fhandle,
-		.fattr		= fattr
+		.fh		= &fhandle,
+		.fattr		= &fattr
 	};
 	struct rpc_message msg = {
 		.rpc_proc	= &nfs3_procedures[NFS3PROC_SYMLINK],
@@ -571,11 +571,17 @@ nfs3_proc_symlink(struct inode *dir, str
 
 	if (path->len > NFS3_MAXPATHLEN)
 		return -ENAMETOOLONG;
-	dprintk("NFS call  symlink %s -> %s\n", name->name, path->name);
+
+	dprintk("NFS call  symlink %s -> %s\n", dentry->d_name.name,
+			path->name);
 	nfs_fattr_init(&dir_attr);
-	nfs_fattr_init(fattr);
+	nfs_fattr_init(&fattr);
 	status = rpc_call_sync(NFS_CLIENT(dir), &msg, 0);
 	nfs_post_op_update_inode(dir, &dir_attr);
+	if (status != 0)
+		goto out;
+	status = nfs_instantiate(dentry, &fhandle, &fattr);
+out:
 	dprintk("NFS reply symlink: %d\n", status);
 	return status;
 }
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index e6ee97f..370b5ab 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2089,24 +2089,24 @@ static int nfs4_proc_link(struct inode *
 	return err;
 }
 
-static int _nfs4_proc_symlink(struct inode *dir, struct qstr *name,
-		struct qstr *path, struct iattr *sattr, struct nfs_fh *fhandle,
-		struct nfs_fattr *fattr)
+static int _nfs4_proc_symlink(struct inode *dir, struct dentry *dentry,
+		struct qstr *path, struct iattr *sattr)
 {
 	struct nfs_server *server = NFS_SERVER(dir);
-	struct nfs_fattr dir_fattr;
+	struct nfs_fh fhandle;
+	struct nfs_fattr fattr, dir_fattr;
 	struct nfs4_create_arg arg = {
 		.dir_fh = NFS_FH(dir),
 		.server = server,
-		.name = name,
+		.name = &dentry->d_name,
 		.attrs = sattr,
 		.ftype = NF4LNK,
 		.bitmask = server->attr_bitmask,
 	};
 	struct nfs4_create_res res = {
 		.server = server,
-		.fh = fhandle,
-		.fattr = fattr,
+		.fh = &fhandle,
+		.fattr = &fattr,
 		.dir_fattr = &dir_fattr,
 	};
 	struct rpc_message msg = {
@@ -2118,27 +2118,28 @@ static int _nfs4_proc_symlink(struct ino
 
 	if (path->len > NFS4_MAXPATHLEN)
 		return -ENAMETOOLONG;
+
 	arg.u.symlink = path;
-	nfs_fattr_init(fattr);
+	nfs_fattr_init(&fattr);
 	nfs_fattr_init(&dir_fattr);
 	
 	status = rpc_call_sync(NFS_CLIENT(dir), &msg, 0);
-	if (!status)
+	if (!status) {
 		update_changeattr(dir, &res.dir_cinfo);
-	nfs_post_op_update_inode(dir, res.dir_fattr);
+		nfs_post_op_update_inode(dir, res.dir_fattr);
+		status = nfs_instantiate(dentry, &fhandle, &fattr);
+	}
 	return status;
 }
 
-static int nfs4_proc_symlink(struct inode *dir, struct qstr *name,
-		struct qstr *path, struct iattr *sattr, struct nfs_fh *fhandle,
-		struct nfs_fattr *fattr)
+static int nfs4_proc_symlink(struct inode *dir, struct dentry *dentry,
+		struct qstr *path, struct iattr *sattr)
 {
 	struct nfs4_exception exception = { };
 	int err;
 	do {
 		err = nfs4_handle_exception(NFS_SERVER(dir),
-				_nfs4_proc_symlink(dir, name, path, sattr,
-					fhandle, fattr),
+				_nfs4_proc_symlink(dir, dentry, path, sattr),
 				&exception);
 	} while (exception.retry);
 	return err;
diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
index b3899ea..7512f71 100644
--- a/fs/nfs/proc.c
+++ b/fs/nfs/proc.c
@@ -425,14 +425,15 @@ nfs_proc_link(struct inode *inode, struc
 }
 
 static int
-nfs_proc_symlink(struct inode *dir, struct qstr *name, struct qstr *path,
-		 struct iattr *sattr, struct nfs_fh *fhandle,
-		 struct nfs_fattr *fattr)
+nfs_proc_symlink(struct inode *dir, struct dentry *dentry, struct qstr *path,
+		 struct iattr *sattr)
 {
+	struct nfs_fh fhandle;
+	struct nfs_fattr fattr;
 	struct nfs_symlinkargs	arg = {
 		.fromfh		= NFS_FH(dir),
-		.fromname	= name->name,
-		.fromlen	= name->len,
+		.fromname	= dentry->d_name.name,
+		.fromlen	= dentry->d_name.len,
 		.topath		= path->name,
 		.tolen		= path->len,
 		.sattr		= sattr
@@ -445,11 +446,23 @@ nfs_proc_symlink(struct inode *dir, stru
 
 	if (path->len > NFS2_MAXPATHLEN)
 		return -ENAMETOOLONG;
-	dprintk("NFS call  symlink %s -> %s\n", name->name, path->name);
-	nfs_fattr_init(fattr);
-	fhandle->size = 0;
+
+	dprintk("NFS call  symlink %s -> %s\n", dentry->d_name.name,
+			path->name);
 	status = rpc_call_sync(NFS_CLIENT(dir), &msg, 0);
 	nfs_mark_for_revalidate(dir);
+
+	/*
+	 * V2 SYMLINK requests don't return any attributes.  Setting the
+	 * filehandle size to zero indicates to nfs_instantiate that it
+	 * should fill in the data with a LOOKUP call on the wire.
+	 */
+	if (status == 0) {
+		nfs_fattr_init(&fattr);
+		fhandle.size = 0;
+		status = nfs_instantiate(dentry, &fhandle, &fattr);
+	}
+
 	dprintk("NFS reply symlink: %d\n", status);
 	return status;
 }
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 0c1093c..cfabcd1 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -790,9 +790,8 @@ struct nfs_rpc_ops {
 	int	(*rename)  (struct inode *, struct qstr *,
 			    struct inode *, struct qstr *);
 	int	(*link)    (struct inode *, struct inode *, struct qstr *);
-	int	(*symlink) (struct inode *, struct qstr *, struct qstr *,
-			    struct iattr *, struct nfs_fh *,
-			    struct nfs_fattr *);
+	int	(*symlink) (struct inode *, struct dentry *, struct qstr *,
+			    struct iattr *);
 	int	(*mkdir)   (struct inode *, struct dentry *, struct iattr *);
 	int	(*rmdir)   (struct inode *, struct qstr *);
 	int	(*readdir) (struct dentry *, struct rpc_cred *,

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
