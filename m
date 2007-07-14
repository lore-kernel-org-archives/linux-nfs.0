From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 2/3] NFS: Introduce struct nfs_removeargs+nfs_removeres
Date: Sat, 14 Jul 2007 18:12:09 -0400
Message-ID: <20070714221209.13914.90070.stgit@heimdal.trondhjem.org>
References: <20070714221209.13914.10001.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Chuck Lever <Chuck.Lever@oracle.com>,
	Trond Myklebust <Trond.Myklebust@netapp.com>
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I9s5f-0003EC-2O
	for nfs@lists.sourceforge.net; Sat, 14 Jul 2007 17:35:59 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I9s5i-0008Py-1v
	for nfs@lists.sourceforge.net; Sat, 14 Jul 2007 17:36:02 -0700
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

We need a common structure for setting up an unlink() rpc call in order to
fix the asynchronous unlink code.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/nfs2xdr.c        |   19 ++++++++++++++++---
 fs/nfs/nfs3proc.c       |   34 +++++++++++++++++-----------------
 fs/nfs/nfs3xdr.c        |   24 ++++++++++++++++++++++--
 fs/nfs/nfs4proc.c       |   31 +++++++++++++++----------------
 fs/nfs/nfs4xdr.c        |    8 ++++----
 fs/nfs/proc.c           |   20 ++++++++++----------
 include/linux/nfs_xdr.h |   27 +++++++++++++++------------
 7 files changed, 99 insertions(+), 64 deletions(-)

diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
index 7fcc78f..c5fce75 100644
--- a/fs/nfs/nfs2xdr.c
+++ b/fs/nfs/nfs2xdr.c
@@ -43,6 +43,7 @@
 #define NFS_entry_sz		(NFS_filename_sz+3)
 
 #define NFS_diropargs_sz	(NFS_fhandle_sz+NFS_filename_sz)
+#define NFS_removeargs_sz	(NFS_fhandle_sz+NFS_filename_sz)
 #define NFS_sattrargs_sz	(NFS_fhandle_sz+NFS_sattr_sz)
 #define NFS_readlinkargs_sz	(NFS_fhandle_sz)
 #define NFS_readargs_sz		(NFS_fhandle_sz+3)
@@ -66,7 +67,7 @@
  * Common NFS XDR functions as inlines
  */
 static inline __be32 *
-xdr_encode_fhandle(__be32 *p, struct nfs_fh *fhandle)
+xdr_encode_fhandle(__be32 *p, const struct nfs_fh *fhandle)
 {
 	memcpy(p, fhandle->data, NFS2_FHSIZE);
 	return p + XDR_QUADLEN(NFS2_FHSIZE);
@@ -204,7 +205,7 @@ nfs_xdr_sattrargs(struct rpc_rqst *req, __be32 *p, struct nfs_sattrargs *args)
 
 /*
  * Encode directory ops argument
- * LOOKUP, REMOVE, RMDIR
+ * LOOKUP, RMDIR
  */
 static int
 nfs_xdr_diropargs(struct rpc_rqst *req, __be32 *p, struct nfs_diropargs *args)
@@ -216,6 +217,18 @@ nfs_xdr_diropargs(struct rpc_rqst *req, __be32 *p, struct nfs_diropargs *args)
 }
 
 /*
+ * Encode REMOVE argument
+ */
+static int
+nfs_xdr_removeargs(struct rpc_rqst *req, __be32 *p, const struct nfs_removeargs *args)
+{
+	p = xdr_encode_fhandle(p, args->fh);
+	p = xdr_encode_array(p, args->name.name, args->name.len);
+	req->rq_slen = xdr_adjust_iovec(req->rq_svec, p);
+	return 0;
+}
+
+/*
  * Arguments to a READ call. Since we read data directly into the page
  * cache, we also set up the reply iovec here so that iov[1] points
  * exactly to the page we want to fetch.
@@ -705,7 +718,7 @@ struct rpc_procinfo	nfs_procedures[] = {
     PROC(READ,		readargs,	readres, 3),
     PROC(WRITE,		writeargs,	writeres, 4),
     PROC(CREATE,	createargs,	diropres, 0),
-    PROC(REMOVE,	diropargs,	stat, 0),
+    PROC(REMOVE,	removeargs,	stat, 0),
     PROC(RENAME,	renameargs,	stat, 0),
     PROC(LINK,		linkargs,	stat, 0),
     PROC(SYMLINK,	symlinkargs,	stat, 0),
diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index 814d886..eac07f2 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -349,23 +349,23 @@ out:
 static int
 nfs3_proc_remove(struct inode *dir, struct qstr *name)
 {
-	struct nfs_fattr	dir_attr;
-	struct nfs3_diropargs	arg = {
-		.fh		= NFS_FH(dir),
-		.name		= name->name,
-		.len		= name->len
+	struct nfs_removeargs arg = {
+		.fh = NFS_FH(dir),
+		.name.len = name->len,
+		.name.name = name->name,
 	};
-	struct rpc_message	msg = {
-		.rpc_proc	= &nfs3_procedures[NFS3PROC_REMOVE],
-		.rpc_argp	= &arg,
-		.rpc_resp	= &dir_attr,
+	struct nfs_removeres res;
+	struct rpc_message msg = {
+		.rpc_proc = &nfs3_procedures[NFS3PROC_REMOVE],
+		.rpc_argp = &arg,
+		.rpc_resp = &res,
 	};
 	int			status;
 
 	dprintk("NFS call  remove %s\n", name->name);
-	nfs_fattr_init(&dir_attr);
+	nfs_fattr_init(&res.dir_attr);
 	status = rpc_call_sync(NFS_CLIENT(dir), &msg, 0);
-	nfs_post_op_update_inode(dir, &dir_attr);
+	nfs_post_op_update_inode(dir, &res.dir_attr);
 	dprintk("NFS reply remove: %d\n", status);
 	return status;
 }
@@ -374,17 +374,17 @@ static int
 nfs3_proc_unlink_setup(struct rpc_message *msg, struct dentry *dir, struct qstr *name)
 {
 	struct unlinkxdr {
-		struct nfs3_diropargs arg;
-		struct nfs_fattr res;
+		struct nfs_removeargs arg;
+		struct nfs_removeres res;
 	} *ptr;
 
 	ptr = kmalloc(sizeof(*ptr), GFP_KERNEL);
 	if (!ptr)
 		return -ENOMEM;
 	ptr->arg.fh = NFS_FH(dir->d_inode);
-	ptr->arg.name = name->name;
-	ptr->arg.len = name->len;
-	nfs_fattr_init(&ptr->res);
+	ptr->arg.name.name = name->name;
+	ptr->arg.name.len = name->len;
+	nfs_fattr_init(&ptr->res.dir_attr);
 	msg->rpc_proc = &nfs3_procedures[NFS3PROC_REMOVE];
 	msg->rpc_argp = &ptr->arg;
 	msg->rpc_resp = &ptr->res;
@@ -400,7 +400,7 @@ nfs3_proc_unlink_done(struct dentry *dir, struct rpc_task *task)
 	if (nfs3_async_handle_jukebox(task, dir->d_inode))
 		return 1;
 	if (msg->rpc_argp) {
-		dir_attr = (struct nfs_fattr*)msg->rpc_resp;
+		dir_attr = &((struct nfs_removeres*)msg->rpc_resp)->dir_attr;
 		nfs_post_op_update_inode(dir->d_inode, dir_attr);
 		kfree(msg->rpc_argp);
 	}
diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
index b4647a2..d9e08f0 100644
--- a/fs/nfs/nfs3xdr.c
+++ b/fs/nfs/nfs3xdr.c
@@ -50,6 +50,7 @@
 
 #define NFS3_sattrargs_sz	(NFS3_fh_sz+NFS3_sattr_sz+3)
 #define NFS3_diropargs_sz	(NFS3_fh_sz+NFS3_filename_sz)
+#define NFS3_removeargs_sz	(NFS3_fh_sz+NFS3_filename_sz)
 #define NFS3_accessargs_sz	(NFS3_fh_sz+1)
 #define NFS3_readlinkargs_sz	(NFS3_fh_sz)
 #define NFS3_readargs_sz	(NFS3_fh_sz+3)
@@ -65,6 +66,7 @@
 
 #define NFS3_attrstat_sz	(1+NFS3_fattr_sz)
 #define NFS3_wccstat_sz		(1+NFS3_wcc_data_sz)
+#define NFS3_removeres_sz	(NFS3_wccstat_sz)
 #define NFS3_lookupres_sz	(1+NFS3_fh_sz+(2 * NFS3_post_op_attr_sz))
 #define NFS3_accessres_sz	(1+NFS3_post_op_attr_sz+1)
 #define NFS3_readlinkres_sz	(1+NFS3_post_op_attr_sz+1)
@@ -106,7 +108,7 @@ static struct {
  * Common NFS XDR functions as inlines
  */
 static inline __be32 *
-xdr_encode_fhandle(__be32 *p, struct nfs_fh *fh)
+xdr_encode_fhandle(__be32 *p, const struct nfs_fh *fh)
 {
 	return xdr_encode_array(p, fh->data, fh->size);
 }
@@ -300,6 +302,18 @@ nfs3_xdr_diropargs(struct rpc_rqst *req, __be32 *p, struct nfs3_diropargs *args)
 }
 
 /*
+ * Encode REMOVE argument
+ */
+static int
+nfs3_xdr_removeargs(struct rpc_rqst *req, __be32 *p, const struct nfs_removeargs *args)
+{
+	p = xdr_encode_fhandle(p, args->fh);
+	p = xdr_encode_array(p, args->name.name, args->name.len);
+	req->rq_slen = xdr_adjust_iovec(req->rq_svec, p);
+	return 0;
+}
+
+/*
  * Encode access() argument
  */
 static int
@@ -736,6 +750,12 @@ nfs3_xdr_wccstat(struct rpc_rqst *req, __be32 *p, struct nfs_fattr *fattr)
 	return status;
 }
 
+static int
+nfs3_xdr_removeres(struct rpc_rqst *req, __be32 *p, struct nfs_removeres *res)
+{
+	return nfs3_xdr_wccstat(req, p, &res->dir_attr);
+}
+
 /*
  * Decode LOOKUP reply
  */
@@ -1126,7 +1146,7 @@ struct rpc_procinfo	nfs3_procedures[] = {
   PROC(MKDIR,		mkdirargs,	createres, 0),
   PROC(SYMLINK,		symlinkargs,	createres, 0),
   PROC(MKNOD,		mknodargs,	createres, 0),
-  PROC(REMOVE,		diropargs,	wccstat, 0),
+  PROC(REMOVE,		removeargs,	removeres, 0),
   PROC(RMDIR,		diropargs,	wccstat, 0),
   PROC(RENAME,		renameargs,	renameres, 0),
   PROC(LINK,		linkargs,	linkres, 0),
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index fee2da8..05fd1e4 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1908,28 +1908,27 @@ out:
 static int _nfs4_proc_remove(struct inode *dir, struct qstr *name)
 {
 	struct nfs_server *server = NFS_SERVER(dir);
-	struct nfs4_remove_arg args = {
+	struct nfs_removeargs args = {
 		.fh = NFS_FH(dir),
-		.name = name,
+		.name.len = name->len,
+		.name.name = name->name,
 		.bitmask = server->attr_bitmask,
 	};
-	struct nfs_fattr dir_attr;
-	struct nfs4_remove_res	res = {
+	struct nfs_removeres res = {
 		.server = server,
-		.dir_attr = &dir_attr,
 	};
 	struct rpc_message msg = {
-		.rpc_proc	= &nfs4_procedures[NFSPROC4_CLNT_REMOVE],
-		.rpc_argp	= &args,
-		.rpc_resp	= &res,
+		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_REMOVE],
+		.rpc_argp = &args,
+		.rpc_resp = &res,
 	};
 	int			status;
 
-	nfs_fattr_init(res.dir_attr);
+	nfs_fattr_init(&res.dir_attr);
 	status = rpc_call_sync(server->client, &msg, 0);
 	if (status == 0) {
 		update_changeattr(dir, &res.cinfo);
-		nfs_post_op_update_inode(dir, res.dir_attr);
+		nfs_post_op_update_inode(dir, &res.dir_attr);
 	}
 	return status;
 }
@@ -1947,9 +1946,8 @@ static int nfs4_proc_remove(struct inode *dir, struct qstr *name)
 }
 
 struct unlink_desc {
-	struct nfs4_remove_arg	args;
-	struct nfs4_remove_res	res;
-	struct nfs_fattr dir_attr;
+	struct nfs_removeargs args;
+	struct nfs_removeres res;
 };
 
 static int nfs4_proc_unlink_setup(struct rpc_message *msg, struct dentry *dir,
@@ -1963,10 +1961,11 @@ static int nfs4_proc_unlink_setup(struct rpc_message *msg, struct dentry *dir,
 		return -ENOMEM;
 	
 	up->args.fh = NFS_FH(dir->d_inode);
-	up->args.name = name;
+	up->args.name.len = name->len;
+	up->args.name.name = name->name;
 	up->args.bitmask = server->attr_bitmask;
 	up->res.server = server;
-	up->res.dir_attr = &up->dir_attr;
+	nfs_fattr_init(&up->res.dir_attr);
 	
 	msg->rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_REMOVE];
 	msg->rpc_argp = &up->args;
@@ -1982,7 +1981,7 @@ static int nfs4_proc_unlink_done(struct dentry *dir, struct rpc_task *task)
 	if (msg->rpc_resp != NULL) {
 		up = container_of(msg->rpc_resp, struct unlink_desc, res);
 		update_changeattr(dir->d_inode, &up->res.cinfo);
-		nfs_post_op_update_inode(dir->d_inode, up->res.dir_attr);
+		nfs_post_op_update_inode(dir->d_inode, &up->res.dir_attr);
 		kfree(up);
 		msg->rpc_resp = NULL;
 		msg->rpc_argp = NULL;
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index c087384..188577f 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1398,7 +1398,7 @@ out:
 /*
  * Encode REMOVE request
  */
-static int nfs4_xdr_enc_remove(struct rpc_rqst *req, __be32 *p, const struct nfs4_remove_arg *args)
+static int nfs4_xdr_enc_remove(struct rpc_rqst *req, __be32 *p, const struct nfs_removeargs *args)
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
@@ -1410,7 +1410,7 @@ static int nfs4_xdr_enc_remove(struct rpc_rqst *req, __be32 *p, const struct nfs
 	encode_compound_hdr(&xdr, &hdr);
 	if ((status = encode_putfh(&xdr, args->fh)) != 0)
 		goto out;
-	if ((status = encode_remove(&xdr, args->name)) != 0)
+	if ((status = encode_remove(&xdr, &args->name)) != 0)
 		goto out;
 	status = encode_getfattr(&xdr, args->bitmask);
 out:
@@ -3772,7 +3772,7 @@ out:
 /*
  * Decode REMOVE response
  */
-static int nfs4_xdr_dec_remove(struct rpc_rqst *rqstp, __be32 *p, struct nfs4_remove_res *res)
+static int nfs4_xdr_dec_remove(struct rpc_rqst *rqstp, __be32 *p, struct nfs_removeres *res)
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr;
@@ -3785,7 +3785,7 @@ static int nfs4_xdr_dec_remove(struct rpc_rqst *rqstp, __be32 *p, struct nfs4_re
 		goto out;
 	if ((status = decode_remove(&xdr, &res->cinfo)) != 0)
 		goto out;
-	decode_getfattr(&xdr, res->dir_attr, res->server);
+	decode_getfattr(&xdr, &res->dir_attr, res->server);
 out:
 	return status;
 }
diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
index 7be0ee2..3b3eb69 100644
--- a/fs/nfs/proc.c
+++ b/fs/nfs/proc.c
@@ -272,14 +272,14 @@ nfs_proc_mknod(struct inode *dir, struct dentry *dentry, struct iattr *sattr,
 static int
 nfs_proc_remove(struct inode *dir, struct qstr *name)
 {
-	struct nfs_diropargs	arg = {
-		.fh		= NFS_FH(dir),
-		.name		= name->name,
-		.len		= name->len
+	struct nfs_removeargs arg = {
+		.fh = NFS_FH(dir),
+		.name.len = name->len,
+		.name.name = name->name,
 	};
-	struct rpc_message	msg = { 
-		.rpc_proc	= &nfs_procedures[NFSPROC_REMOVE],
-		.rpc_argp	= &arg,
+	struct rpc_message msg = { 
+		.rpc_proc = &nfs_procedures[NFSPROC_REMOVE],
+		.rpc_argp = &arg,
 	};
 	int			status;
 
@@ -294,14 +294,14 @@ nfs_proc_remove(struct inode *dir, struct qstr *name)
 static int
 nfs_proc_unlink_setup(struct rpc_message *msg, struct dentry *dir, struct qstr *name)
 {
-	struct nfs_diropargs	*arg;
+	struct nfs_removeargs *arg;
 
 	arg = kmalloc(sizeof(*arg), GFP_KERNEL);
 	if (!arg)
 		return -ENOMEM;
 	arg->fh = NFS_FH(dir->d_inode);
-	arg->name = name->name;
-	arg->len = name->len;
+	arg->name.name = name->name;
+	arg->name.len = name->len;
 	msg->rpc_proc = &nfs_procedures[NFSPROC_REMOVE];
 	msg->rpc_argp = arg;
 	return 0;
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 38d7768..7babcb1 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -278,6 +278,21 @@ struct nfs_writeres {
 };
 
 /*
+ * Common arguments to the unlink call
+ */
+struct nfs_removeargs {
+	const struct nfs_fh	*fh;
+	struct qstr		name;
+	const u32 *		bitmask;
+};
+
+struct nfs_removeres {
+	const struct nfs_server *server;
+	struct nfs4_change_info	cinfo;
+	struct nfs_fattr	dir_attr;
+};
+
+/*
  * Argument struct for decode_entry function
  */
 struct nfs_entry {
@@ -631,18 +646,6 @@ struct nfs4_readlink {
 	struct page **			pages;   /* zero-copy data */
 };
 
-struct nfs4_remove_arg {
-	const struct nfs_fh *		fh;
-	const struct qstr *		name;
-	const u32 *			bitmask;
-};
-
-struct nfs4_remove_res {
-	const struct nfs_server *	server;
-	struct nfs4_change_info		cinfo;
-	struct nfs_fattr *		dir_attr;
-};
-
 struct nfs4_rename_arg {
 	const struct nfs_fh *		old_dir;
 	const struct nfs_fh *		new_dir;

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
