From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS open/setuid/ftruncate problem
Date: Tue, 10 Jun 2008 19:47:10 -0400
Message-ID: <1213141630.20459.113.camel@localhost>
References: <0707E37B6D2E244C85660487B602C9221D9D9846@ex02.briontech.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	linux-nfs@vger.kernel.org
To: Luoqi Chen <Luoqi.Chen-IKBeIF8UJ7oAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:32786 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751869AbYFJXrQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Jun 2008 19:47:16 -0400
In-Reply-To: <0707E37B6D2E244C85660487B602C9221D9D9846-JF6rn/ZKWM+tJcKNL5McE9BPR1lH4CV8@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2008-06-10 at 15:05 -0700, Luoqi Chen wrote:
> Hi,
> 
> I've recently encountered a problem which could be a bug in the nfs implementation.
> It could be illustrated with the following small program,
> 
> #include <fcntl.h>
> #include <unistd.h>
> 
> main()
> {
>         int fd;
> 
>         fd = open("abc", O_WRONLY | O_CREAT, 0644);
>         if (fd < 0) {
>                 perror("open");
>                 exit(-1);
>         }
> 
>         write(fd, "test\n", 5);
> 
>         setuid(65534);
> 
>         if (ftruncate(fd, 3) < 0)
>                 perror("ftruncate");
> 
>         close(fd);
> }
> 
> Compile and run it as root on an NFS mount without root squash, ftruncate() would
> return an EACCESS error. On a local disk, it would complete successfully, leaving
> behind a file "abc" with the string "tes". It would also be successful on NFS
> if you change the mode from 0644 to 0666 (make sure to set your umask to 0).

Known problem. I suspect that the following untested patch (against
2.6.26-rc5) should fix it.

Cheers
  Trond
-------------------------------------------------------------------------------
From: Trond Myklebust <Trond.Myklebust@netapp.com>
Date: Tue, 10 Jun 2008 19:39:41 -0400
NFS: Fix the ftruncate() credential problem

ftruncate() access checking is supposed to be performed at open() time,
just like reads and writes.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/inode.c          |   10 +++++++---
 fs/nfs/nfs3proc.c       |    7 ++++---
 fs/nfs/nfs4proc.c       |   47 +++++++++++++++++++++++++++--------------------
 fs/nfs/proc.c           |    5 +++--
 include/linux/nfs_xdr.h |    4 ++--
 5 files changed, 43 insertions(+), 30 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 596c5d8..072ee6c 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -347,13 +347,14 @@ out_no_inode:
 	goto out;
 }
 
-#define NFS_VALID_ATTRS (ATTR_MODE|ATTR_UID|ATTR_GID|ATTR_SIZE|ATTR_ATIME|ATTR_ATIME_SET|ATTR_MTIME|ATTR_MTIME_SET)
+#define NFS_VALID_ATTRS (ATTR_MODE|ATTR_UID|ATTR_GID|ATTR_SIZE|ATTR_ATIME|ATTR_ATIME_SET|ATTR_MTIME|ATTR_MTIME_SET|ATTR_FILE)
 
 int
 nfs_setattr(struct dentry *dentry, struct iattr *attr)
 {
 	struct inode *inode = dentry->d_inode;
 	struct nfs_fattr fattr;
+	struct rpc_cred *cred = NULL;
 	int error;
 
 	nfs_inc_stats(inode, NFSIOS_VFSSETATTR);
@@ -369,9 +370,12 @@ nfs_setattr(struct dentry *dentry, struct iattr *attr)
 
 	/* Optimization: if the end result is no change, don't RPC */
 	attr->ia_valid &= NFS_VALID_ATTRS;
-	if (attr->ia_valid == 0)
+	if ((attr->ia_valid & ~ATTR_FILE) == 0)
 		return 0;
 
+	if (attr->ia_valid & ATTR_FILE)
+		cred = nfs_file_cred(attr->ia_file);
+
 	lock_kernel();
 	/* Write all dirty data */
 	if (S_ISREG(inode->i_mode)) {
@@ -383,7 +387,7 @@ nfs_setattr(struct dentry *dentry, struct iattr *attr)
 	 */
 	if ((attr->ia_valid & (ATTR_MODE|ATTR_UID|ATTR_GID)) != 0)
 		nfs_inode_return_delegation(inode);
-	error = NFS_PROTO(inode)->setattr(dentry, &fattr, attr);
+	error = NFS_PROTO(inode)->setattr(dentry, cred, &fattr, attr);
 	if (error == 0)
 		nfs_refresh_inode(inode, &fattr);
 	unlock_kernel();
diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index c3523ad..48359c6 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -113,8 +113,8 @@ nfs3_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle,
 }
 
 static int
-nfs3_proc_setattr(struct dentry *dentry, struct nfs_fattr *fattr,
-			struct iattr *sattr)
+nfs3_proc_setattr(struct dentry *dentry, struct rpc_cred *cred,
+		  struct nfs_fattr *fattr, struct iattr *sattr)
 {
 	struct inode *inode = dentry->d_inode;
 	struct nfs3_sattrargs	arg = {
@@ -125,6 +125,7 @@ nfs3_proc_setattr(struct dentry *dentry, struct nfs_fattr *fattr,
 		.rpc_proc	= &nfs3_procedures[NFS3PROC_SETATTR],
 		.rpc_argp	= &arg,
 		.rpc_resp	= fattr,
+		.rpc_cred	= cred,
 	};
 	int	status;
 
@@ -330,7 +331,7 @@ again:
 		/* Note: we could use a guarded setattr here, but I'm
 		 * not sure this buys us anything (and I'd have
 		 * to revamp the NFSv3 XDR code) */
-		status = nfs3_proc_setattr(dentry, &fattr, sattr);
+		status = nfs3_proc_setattr(dentry, NULL, &fattr, sattr);
 		nfs_post_op_update_inode(dentry->d_inode, &fattr);
 		dprintk("NFS reply setattr (post-create): %d\n", status);
 	}
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 1293e0a..4583649 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1139,8 +1139,9 @@ static struct nfs4_state *nfs4_do_open(struct inode *dir, struct path *path, int
 	return res;
 }
 
-static int _nfs4_do_setattr(struct inode *inode, struct nfs_fattr *fattr,
-                struct iattr *sattr, struct nfs4_state *state)
+static int _nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
+			    struct nfs_fattr *fattr, struct iattr *sattr,
+			    struct nfs4_state *state)
 {
 	struct nfs_server *server = NFS_SERVER(inode);
         struct nfs_setattrargs  arg = {
@@ -1157,6 +1158,7 @@ static int _nfs4_do_setattr(struct inode *inode, struct nfs_fattr *fattr,
                 .rpc_proc       = &nfs4_procedures[NFSPROC4_CLNT_SETATTR],
                 .rpc_argp       = &arg,
                 .rpc_resp       = &res,
+		.rpc_cred	= cred,
         };
 	unsigned long timestamp = jiffies;
 	int status;
@@ -1166,7 +1168,6 @@ static int _nfs4_do_setattr(struct inode *inode, struct nfs_fattr *fattr,
 	if (nfs4_copy_delegation_stateid(&arg.stateid, inode)) {
 		/* Use that stateid */
 	} else if (state != NULL) {
-		msg.rpc_cred = state->owner->so_cred;
 		nfs4_copy_stateid(&arg.stateid, state, current->files);
 	} else
 		memcpy(&arg.stateid, &zero_stateid, sizeof(arg.stateid));
@@ -1177,15 +1178,16 @@ static int _nfs4_do_setattr(struct inode *inode, struct nfs_fattr *fattr,
 	return status;
 }
 
-static int nfs4_do_setattr(struct inode *inode, struct nfs_fattr *fattr,
-                struct iattr *sattr, struct nfs4_state *state)
+static int nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
+			   struct nfs_fattr *fattr, struct iattr *sattr,
+			   struct nfs4_state *state)
 {
 	struct nfs_server *server = NFS_SERVER(inode);
 	struct nfs4_exception exception = { };
 	int err;
 	do {
 		err = nfs4_handle_exception(server,
-				_nfs4_do_setattr(inode, fattr, sattr, state),
+				_nfs4_do_setattr(inode, cred, fattr, sattr, state),
 				&exception);
 	} while (exception.retry);
 	return err;
@@ -1644,27 +1646,31 @@ static int nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle,
  * This will be fixed with VFS changes (lookup-intent).
  */
 static int
-nfs4_proc_setattr(struct dentry *dentry, struct nfs_fattr *fattr,
-		  struct iattr *sattr)
+nfs4_proc_setattr(struct dentry *dentry, struct rpc_cred *cred,
+		  struct nfs_fattr *fattr, struct iattr *sattr)
 {
-	struct rpc_cred *cred;
 	struct inode *inode = dentry->d_inode;
-	struct nfs_open_context *ctx;
+	struct nfs_open_context *ctx = NULL;
 	struct nfs4_state *state = NULL;
 	int status;
 
 	nfs_fattr_init(fattr);
 	
-	cred = rpc_lookup_cred();
-	if (IS_ERR(cred))
-		return PTR_ERR(cred);
+	if (cred == NULL) {
+		cred = rpc_lookup_cred();
+		if (IS_ERR(cred))
+			return PTR_ERR(cred);
+	} else
+		get_rpccred(cred);
 
 	/* Search for an existing open(O_WRITE) file */
-	ctx = nfs_find_open_context(inode, cred, FMODE_WRITE);
-	if (ctx != NULL)
-		state = ctx->state;
+	if (sattr->ia_valid && ATTR_FILE) {
+		ctx = nfs_file_open_context(sattr->ia_file);
+		if (ctx != NULL)
+			state = ctx->state;
+	}
 
-	status = nfs4_do_setattr(inode, fattr, sattr, state);
+	status = nfs4_do_setattr(inode, cred, fattr, sattr, state);
 	if (status == 0)
 		nfs_setattr_update_inode(inode, sattr);
 	if (ctx != NULL)
@@ -1897,17 +1903,16 @@ nfs4_proc_create(struct inode *dir, struct dentry *dentry, struct iattr *sattr,
 		goto out;
 	}
 	state = nfs4_do_open(dir, &path, flags, sattr, cred);
-	put_rpccred(cred);
 	d_drop(dentry);
 	if (IS_ERR(state)) {
 		status = PTR_ERR(state);
-		goto out;
+		goto out_putcred;
 	}
 	d_add(dentry, igrab(state->inode));
 	nfs_set_verifier(dentry, nfs_save_change_attribute(dir));
 	if (flags & O_EXCL) {
 		struct nfs_fattr fattr;
-		status = nfs4_do_setattr(state->inode, &fattr, sattr, state);
+		status = nfs4_do_setattr(state->inode, cred, &fattr, sattr, state);
 		if (status == 0)
 			nfs_setattr_update_inode(state->inode, sattr);
 		nfs_post_op_update_inode(state->inode, &fattr);
@@ -1916,6 +1921,8 @@ nfs4_proc_create(struct inode *dir, struct dentry *dentry, struct iattr *sattr,
 		status = nfs4_intent_set_file(nd, &path, state);
 	else
 		nfs4_close_sync(&path, state, flags);
+out_putcred:
+	put_rpccred(cred);
 out:
 	return status;
 }
diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
index 5c35b02..e203f7e 100644
--- a/fs/nfs/proc.c
+++ b/fs/nfs/proc.c
@@ -110,8 +110,8 @@ nfs_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle,
 }
 
 static int
-nfs_proc_setattr(struct dentry *dentry, struct nfs_fattr *fattr,
-		 struct iattr *sattr)
+nfs_proc_setattr(struct dentry *dentry, struct rpc_cred *cred,
+		 struct nfs_fattr *fattr, struct iattr *sattr)
 {
 	struct inode *inode = dentry->d_inode;
 	struct nfs_sattrargs	arg = { 
@@ -122,6 +122,7 @@ nfs_proc_setattr(struct dentry *dentry, struct nfs_fattr *fattr,
 		.rpc_proc	= &nfs_procedures[NFSPROC_SETATTR],
 		.rpc_argp	= &arg,
 		.rpc_resp	= fattr,
+		.rpc_cred	= cred,
 	};
 	int	status;
 
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 8d780de..af6661e 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -792,8 +792,8 @@ struct nfs_rpc_ops {
 			    struct nfs_fattr *);
 	int	(*getattr) (struct nfs_server *, struct nfs_fh *,
 			    struct nfs_fattr *);
-	int	(*setattr) (struct dentry *, struct nfs_fattr *,
-			    struct iattr *);
+	int	(*setattr) (struct dentry *, struct rpc_cred *,
+			    struct nfs_fattr *, struct iattr *);
 	int	(*lookup)  (struct inode *, struct qstr *,
 			    struct nfs_fh *, struct nfs_fattr *);
 	int	(*access)  (struct inode *, struct nfs_access_entry *);


