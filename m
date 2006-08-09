From: Chuck Lever <chucklever@gmail.com>
Subject: [PATCH 25/25] NFS: Use cached page as buffer for NFS symlink
	requests
Date: Wed, 09 Aug 2006 10:59:51 -0400
Message-ID: <20060809145951.3914.9584.stgit@picasso.dsl.sfldmi.ameritech.net>
References: <20060809144716.3914.62804.stgit@picasso.dsl.sfldmi.ameritech.net>
Reply-To: Chuck Lever <chucklever@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GApcV-0000pp-Nb
	for nfs@lists.sourceforge.net; Wed, 09 Aug 2006 08:05:19 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GApcV-0005np-LN
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

Now that we have a copy of the symlink path in the page cache, we can pass
a struct page down to the XDR routines instead of a string buffer.

Test plan:
Connectathon, all NFS versions.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/dir.c            |    8 +-------
 fs/nfs/nfs2xdr.c        |   21 ++++++++++++++++++---
 fs/nfs/nfs3proc.c       |   14 +++++++-------
 fs/nfs/nfs3xdr.c        |    7 +++++--
 fs/nfs/nfs4proc.c       |   12 +++++++-----
 fs/nfs/nfs4xdr.c        |    8 ++++----
 fs/nfs/proc.c           |   14 +++++++-------
 include/linux/nfs_xdr.h |   17 ++++++++++-------
 8 files changed, 59 insertions(+), 42 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 815ec2b..64306e5 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1460,10 +1460,6 @@ static int nfs_symlink(struct inode *dir
 	char *kaddr;
 	struct iattr attr;
 	unsigned int pathlen = strlen(symname);
-	struct qstr qsymname = {
-		.name	= symname,
-		.len	= pathlen,
-	};
 	int error;
 
 	dfprintk(VFS, "NFS: symlink(%s/%ld, %s, %s)\n", dir->i_sb->s_id,
@@ -1489,10 +1485,8 @@ static int nfs_symlink(struct inode *dir
 		memset(kaddr + pathlen, 0, PAGE_SIZE - pathlen);
 	kunmap_atomic(kaddr, KM_USER0);
 
-	/* XXX: eventually this will pass in {page, pathlen},
-	 *	instead of qsymname; need XDR changes for that */
 	nfs_begin_data_update(dir);
-	error = NFS_PROTO(dir)->symlink(dir, dentry, &qsymname, &attr);
+	error = NFS_PROTO(dir)->symlink(dir, dentry, page, pathlen, &attr);
 	nfs_end_data_update(dir);
 	if (error != 0) {
 		dfprintk(VFS, "NFS: symlink(%s/%ld, %s, %s) error %d\n",
diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
index 67391ee..b49501f 100644
--- a/fs/nfs/nfs2xdr.c
+++ b/fs/nfs/nfs2xdr.c
@@ -51,7 +51,7 @@ #define NFS_writeargs_sz	(NFS_fhandle_sz
 #define NFS_createargs_sz	(NFS_diropargs_sz+NFS_sattr_sz)
 #define NFS_renameargs_sz	(NFS_diropargs_sz+NFS_diropargs_sz)
 #define NFS_linkargs_sz		(NFS_fhandle_sz+NFS_diropargs_sz)
-#define NFS_symlinkargs_sz	(NFS_diropargs_sz+NFS_path_sz+NFS_sattr_sz)
+#define NFS_symlinkargs_sz	(NFS_diropargs_sz+1+NFS_sattr_sz)
 #define NFS_readdirargs_sz	(NFS_fhandle_sz+2)
 
 #define NFS_attrstat_sz		(1+NFS_fattr_sz)
@@ -351,11 +351,26 @@ nfs_xdr_linkargs(struct rpc_rqst *req, u
 static int
 nfs_xdr_symlinkargs(struct rpc_rqst *req, u32 *p, struct nfs_symlinkargs *args)
 {
+	struct xdr_buf *sndbuf = &req->rq_snd_buf;
+	size_t pad;
+
 	p = xdr_encode_fhandle(p, args->fromfh);
 	p = xdr_encode_array(p, args->fromname, args->fromlen);
-	p = xdr_encode_array(p, args->topath, args->tolen);
+	*p++ = htonl(args->pathlen);
+	sndbuf->len = xdr_adjust_iovec(sndbuf->head, p);
+
+	xdr_encode_pages(sndbuf, args->pages, 0, args->pathlen);
+
+	/*
+	 * xdr_encode_pages may have added a few bytes to ensure the
+	 * pathname ends on a 4-byte boundary.  Start encoding the
+	 * attributes after the pad bytes.
+	 */
+	pad = sndbuf->tail->iov_len;
+	if (pad > 0)
+		p++;
 	p = xdr_encode_sattr(p, args->sattr);
-	req->rq_slen = xdr_adjust_iovec(req->rq_svec, p);
+	sndbuf->len += xdr_adjust_iovec(sndbuf->tail, p) - pad;
 	return 0;
 }
 
diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index 15eac8d..44cf0a9 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -544,8 +544,8 @@ nfs3_proc_link(struct inode *inode, stru
 }
 
 static int
-nfs3_proc_symlink(struct inode *dir, struct dentry *dentry, struct qstr *path,
-		  struct iattr *sattr)
+nfs3_proc_symlink(struct inode *dir, struct dentry *dentry, struct page *page,
+		  unsigned int len, struct iattr *sattr)
 {
 	struct nfs_fh fhandle;
 	struct nfs_fattr fattr, dir_attr;
@@ -553,8 +553,8 @@ nfs3_proc_symlink(struct inode *dir, str
 		.fromfh		= NFS_FH(dir),
 		.fromname	= dentry->d_name.name,
 		.fromlen	= dentry->d_name.len,
-		.topath		= path->name,
-		.tolen		= path->len,
+		.pages		= &page,
+		.pathlen	= len,
 		.sattr		= sattr
 	};
 	struct nfs3_diropres	res = {
@@ -569,11 +569,11 @@ nfs3_proc_symlink(struct inode *dir, str
 	};
 	int			status;
 
-	if (path->len > NFS3_MAXPATHLEN)
+	if (len > NFS3_MAXPATHLEN)
 		return -ENAMETOOLONG;
 
-	dprintk("NFS call  symlink %s -> %s\n", dentry->d_name.name,
-			path->name);
+	dprintk("NFS call  symlink %s\n", dentry->d_name.name);
+
 	nfs_fattr_init(&dir_attr);
 	nfs_fattr_init(&fattr);
 	status = rpc_call_sync(NFS_CLIENT(dir), &msg, 0);
diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
index 0250269..16556fa 100644
--- a/fs/nfs/nfs3xdr.c
+++ b/fs/nfs/nfs3xdr.c
@@ -56,7 +56,7 @@ #define NFS3_readargs_sz	(NFS3_fh_sz+3)
 #define NFS3_writeargs_sz	(NFS3_fh_sz+5)
 #define NFS3_createargs_sz	(NFS3_diropargs_sz+NFS3_sattr_sz)
 #define NFS3_mkdirargs_sz	(NFS3_diropargs_sz+NFS3_sattr_sz)
-#define NFS3_symlinkargs_sz	(NFS3_diropargs_sz+NFS3_path_sz+NFS3_sattr_sz)
+#define NFS3_symlinkargs_sz	(NFS3_diropargs_sz+1+NFS3_sattr_sz)
 #define NFS3_mknodargs_sz	(NFS3_diropargs_sz+2+NFS3_sattr_sz)
 #define NFS3_renameargs_sz	(NFS3_diropargs_sz+NFS3_diropargs_sz)
 #define NFS3_linkargs_sz		(NFS3_fh_sz+NFS3_diropargs_sz)
@@ -398,8 +398,11 @@ nfs3_xdr_symlinkargs(struct rpc_rqst *re
 	p = xdr_encode_fhandle(p, args->fromfh);
 	p = xdr_encode_array(p, args->fromname, args->fromlen);
 	p = xdr_encode_sattr(p, args->sattr);
-	p = xdr_encode_array(p, args->topath, args->tolen);
+	*p++ = htonl(args->pathlen);
 	req->rq_slen = xdr_adjust_iovec(req->rq_svec, p);
+
+	/* Copy the page */
+	xdr_encode_pages(&req->rq_snd_buf, args->pages, 0, args->pathlen);
 	return 0;
 }
 
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 370b5ab..05775e2 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2090,7 +2090,7 @@ static int nfs4_proc_link(struct inode *
 }
 
 static int _nfs4_proc_symlink(struct inode *dir, struct dentry *dentry,
-		struct qstr *path, struct iattr *sattr)
+		struct page *page, unsigned int len, struct iattr *sattr)
 {
 	struct nfs_server *server = NFS_SERVER(dir);
 	struct nfs_fh fhandle;
@@ -2116,10 +2116,11 @@ static int _nfs4_proc_symlink(struct ino
 	};
 	int			status;
 
-	if (path->len > NFS4_MAXPATHLEN)
+	if (len > NFS4_MAXPATHLEN)
 		return -ENAMETOOLONG;
 
-	arg.u.symlink = path;
+	arg.u.symlink.pages = &page;
+	arg.u.symlink.len = len;
 	nfs_fattr_init(&fattr);
 	nfs_fattr_init(&dir_fattr);
 	
@@ -2133,13 +2134,14 @@ static int _nfs4_proc_symlink(struct ino
 }
 
 static int nfs4_proc_symlink(struct inode *dir, struct dentry *dentry,
-		struct qstr *path, struct iattr *sattr)
+		struct page *page, unsigned int len, struct iattr *sattr)
 {
 	struct nfs4_exception exception = { };
 	int err;
 	do {
 		err = nfs4_handle_exception(NFS_SERVER(dir),
-				_nfs4_proc_symlink(dir, dentry, path, sattr),
+				_nfs4_proc_symlink(dir, dentry, page,
+							len, sattr),
 				&exception);
 	} while (exception.retry);
 	return err;
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 1750d99..26dd22c 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -128,7 +128,7 @@ #define encode_link_maxsz	(op_encode_hdr
 #define decode_link_maxsz	(op_decode_hdr_maxsz + 5)
 #define encode_symlink_maxsz	(op_encode_hdr_maxsz + \
 				1 + nfs4_name_maxsz + \
-				nfs4_path_maxsz + \
+				1 + \
 				nfs4_fattr_maxsz)
 #define decode_symlink_maxsz	(op_decode_hdr_maxsz + 8)
 #define encode_create_maxsz	(op_encode_hdr_maxsz + \
@@ -673,9 +673,9 @@ static int encode_create(struct xdr_stre
 
 	switch (create->ftype) {
 	case NF4LNK:
-		RESERVE_SPACE(4 + create->u.symlink->len);
-		WRITE32(create->u.symlink->len);
-		WRITEMEM(create->u.symlink->name, create->u.symlink->len);
+		RESERVE_SPACE(4);
+		WRITE32(create->u.symlink.len);
+		xdr_write_pages(xdr, create->u.symlink.pages, 0, create->u.symlink.len);
 		break;
 
 	case NF4BLK: case NF4CHR:
diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
index 7512f71..a6ee598 100644
--- a/fs/nfs/proc.c
+++ b/fs/nfs/proc.c
@@ -425,8 +425,8 @@ nfs_proc_link(struct inode *inode, struc
 }
 
 static int
-nfs_proc_symlink(struct inode *dir, struct dentry *dentry, struct qstr *path,
-		 struct iattr *sattr)
+nfs_proc_symlink(struct inode *dir, struct dentry *dentry, struct page *page,
+		 unsigned int len, struct iattr *sattr)
 {
 	struct nfs_fh fhandle;
 	struct nfs_fattr fattr;
@@ -434,8 +434,8 @@ nfs_proc_symlink(struct inode *dir, stru
 		.fromfh		= NFS_FH(dir),
 		.fromname	= dentry->d_name.name,
 		.fromlen	= dentry->d_name.len,
-		.topath		= path->name,
-		.tolen		= path->len,
+		.pages		= &page,
+		.pathlen	= len,
 		.sattr		= sattr
 	};
 	struct rpc_message msg = {
@@ -444,11 +444,11 @@ nfs_proc_symlink(struct inode *dir, stru
 	};
 	int			status;
 
-	if (path->len > NFS2_MAXPATHLEN)
+	if (len > NFS2_MAXPATHLEN)
 		return -ENAMETOOLONG;
 
-	dprintk("NFS call  symlink %s -> %s\n", dentry->d_name.name,
-			path->name);
+	dprintk("NFS call  symlink %s\n", dentry->d_name.name);
+
 	status = rpc_call_sync(NFS_CLIENT(dir), &msg, 0);
 	nfs_mark_for_revalidate(dir);
 
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index cfabcd1..0ed4104 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -358,8 +358,8 @@ struct nfs_symlinkargs {
 	struct nfs_fh *		fromfh;
 	const char *		fromname;
 	unsigned int		fromlen;
-	const char *		topath;
-	unsigned int		tolen;
+	struct page **		pages;
+	unsigned int		pathlen;
 	struct iattr *		sattr;
 };
 
@@ -434,8 +434,8 @@ struct nfs3_symlinkargs {
 	struct nfs_fh *		fromfh;
 	const char *		fromname;
 	unsigned int		fromlen;
-	const char *		topath;
-	unsigned int		tolen;
+	struct page **		pages;
+	unsigned int		pathlen;
 	struct iattr *		sattr;
 };
 
@@ -533,7 +533,10 @@ struct nfs4_accessres {
 struct nfs4_create_arg {
 	u32				ftype;
 	union {
-		struct qstr *		symlink;    /* NF4LNK */
+		struct {
+			struct page **	pages;
+			unsigned int	len;
+		} symlink;   /* NF4LNK */
 		struct {
 			u32		specdata1;
 			u32		specdata2;
@@ -790,8 +793,8 @@ struct nfs_rpc_ops {
 	int	(*rename)  (struct inode *, struct qstr *,
 			    struct inode *, struct qstr *);
 	int	(*link)    (struct inode *, struct inode *, struct qstr *);
-	int	(*symlink) (struct inode *, struct dentry *, struct qstr *,
-			    struct iattr *);
+	int	(*symlink) (struct inode *, struct dentry *, struct page *,
+			    unsigned int, struct iattr *);
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
