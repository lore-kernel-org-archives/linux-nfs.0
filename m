From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: [PATCH 17/19] A basic NFSv4 client for 2.5.x
Date: Tue, 15 Oct 2002 00:34:32 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15787.18040.721059.837775@charged.uio.no>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS maillist <nfs@lists.sourceforge.net>,
    nfsv4-wg@citi.umich.edu
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 181DnS-000444-00
	for <nfs@lists.sourceforge.net>; Mon, 14 Oct 2002 15:34:46 -0700
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
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>

Further cleanups

Separate the static and dynamic filesystem data retrieval calls as per the
NFSv3 spec. This also simplifies things for NFSv4, since many of the
attributes in the fsinfo+fstat combined call are not mandatory to
implement.

diff -u --recursive --new-file linux-2.5.42-nfsv4-E01/fs/nfs/inode.c linux-2.5.42-nfsv4-E02/fs/nfs/inode.c
--- linux-2.5.42-nfsv4-E01/fs/nfs/inode.c	2002-10-12 19:22:13.000000000 -0400
+++ linux-2.5.42-nfsv4-E02/fs/nfs/inode.c	2002-10-12 19:23:31.000000000 -0400
@@ -240,7 +240,13 @@
 {
 	struct nfs_server	*server;
 	struct inode		*root_inode = NULL;
-	struct nfs_fsinfo	fsinfo;
+	struct nfs_fattr	fattr;
+	struct nfs_fsinfo	fsinfo = {
+					.fattr = &fattr,
+				};
+	struct nfs_pathconf pathinfo = {
+			.fattr = &fattr,
+	};
 
 	/* We probably want something more informative here */
 	snprintf(sb->s_id, sizeof(sb->s_id), "%x:%x", MAJOR(sb->s_dev), MINOR(sb->s_dev));
@@ -265,31 +271,27 @@
 	sb->s_root->d_op = &nfs_dentry_operations;
 
 	/* Get some general file system info */
-        if (server->rpc_ops->statfs(server, &server->fh, &fsinfo) >= 0) {
-		if (server->namelen == 0)
-			server->namelen = fsinfo.namelen;
-	} else {
+        if (server->rpc_ops->fsinfo(server, &server->fh, &fsinfo) < 0) {
 		printk(KERN_NOTICE "NFS: cannot retrieve file system info.\n");
 		goto out_no_root;
         }
-
+	if (server->namelen == 0 &&
+	    server->rpc_ops->pathconf(server, &server->fh, &pathinfo) >= 0)
+		server->namelen = pathinfo.max_namelen;
 	/* Work out a lot of parameters */
 	if (server->rsize == 0)
 		server->rsize = nfs_block_size(fsinfo.rtpref, NULL);
 	if (server->wsize == 0)
 		server->wsize = nfs_block_size(fsinfo.wtpref, NULL);
-	/* NFSv3: we don't have bsize, but rather rtmult and wtmult... */
-	if (!fsinfo.bsize)
-		fsinfo.bsize = (fsinfo.rtmult>fsinfo.wtmult) ? fsinfo.rtmult : fsinfo.wtmult;
-	/* Also make sure we don't go below rsize/wsize since
-	 * RPC calls are expensive */
-	if (fsinfo.bsize < server->rsize)
-		fsinfo.bsize = server->rsize;
-	if (fsinfo.bsize < server->wsize)
-		fsinfo.bsize = server->wsize;
+	if (sb->s_blocksize == 0) {
+		if (fsinfo.wtmult == 0) {
+			sb->s_blocksize = 512;
+			sb->s_blocksize_bits = 9;
+		} else
+			sb->s_blocksize = nfs_block_bits(fsinfo.wtmult,
+							 &sb->s_blocksize_bits);
+	}
 
-	if (sb->s_blocksize == 0)
-		sb->s_blocksize = nfs_block_bits(fsinfo.bsize, &sb->s_blocksize_bits);
 	if (fsinfo.rtmax >= 512 && server->rsize > fsinfo.rtmax)
 		server->rsize = nfs_block_size(fsinfo.rtmax, NULL);
 	if (fsinfo.wtmax >= 512 && server->wsize > fsinfo.wtmax)
@@ -472,29 +474,30 @@
 	struct nfs_server *server = NFS_SB(sb);
 	unsigned char blockbits;
 	unsigned long blockres;
-	struct nfs_fsinfo res;
+	struct nfs_fh *rootfh = NFS_FH(sb->s_root->d_inode);
+	struct nfs_fattr fattr;
+	struct nfs_fsstat res = {
+			.fattr = &fattr,
+	};
 	int error;
 
 	lock_kernel();
 
-	error = server->rpc_ops->statfs(server, NFS_FH(sb->s_root->d_inode), &res);
+	error = server->rpc_ops->statfs(server, rootfh, &res);
 	buf->f_type = NFS_SUPER_MAGIC;
 	if (error < 0)
 		goto out_err;
 
-	if (res.bsize == 0)
-		res.bsize = sb->s_blocksize;
-	buf->f_bsize = nfs_block_bits(res.bsize, &blockbits);
+	buf->f_bsize = sb->s_blocksize;
+	blockbits = sb->s_blocksize_bits;
 	blockres = (1 << blockbits) - 1;
 	buf->f_blocks = (res.tbytes + blockres) >> blockbits;
 	buf->f_bfree = (res.fbytes + blockres) >> blockbits;
 	buf->f_bavail = (res.abytes + blockres) >> blockbits;
 	buf->f_files = res.tfiles;
 	buf->f_ffree = res.afiles;
-	if (res.namelen == 0 || res.namelen > server->namelen)
-		res.namelen = server->namelen;
-	buf->f_namelen = res.namelen;
 
+	buf->f_namelen = server->namelen;
  out:
 	unlock_kernel();
 
diff -u --recursive --new-file linux-2.5.42-nfsv4-E01/fs/nfs/nfs2xdr.c linux-2.5.42-nfsv4-E02/fs/nfs/nfs2xdr.c
--- linux-2.5.42-nfsv4-E01/fs/nfs/nfs2xdr.c	2002-10-08 18:44:43.000000000 -0400
+++ linux-2.5.42-nfsv4-E02/fs/nfs/nfs2xdr.c	2002-10-12 19:26:49.000000000 -0400
@@ -596,37 +596,18 @@
  * Decode STATFS reply
  */
 static int
-nfs_xdr_statfsres(struct rpc_rqst *req, u32 *p, struct nfs_fsinfo *res)
+nfs_xdr_statfsres(struct rpc_rqst *req, u32 *p, struct nfs2_fsstat *res)
 {
 	int	status;
-	u32	xfer_size;
 
 	if ((status = ntohl(*p++)))
 		return -nfs_stat_to_errno(status);
 
-	/* For NFSv2, we more or less have to guess the preferred
-	 * read/write/readdir sizes from the single 'transfer size'
-	 * value.
-	 */
-	xfer_size = ntohl(*p++);	/* tsize */
-	res->rtmax  = 8 * 1024;
-	res->rtpref = xfer_size;
-	res->rtmult = xfer_size;
-	res->wtmax  = 8 * 1024;
-	res->wtpref = xfer_size;
-	res->wtmult = xfer_size;
-	res->dtpref = PAGE_CACHE_SIZE;
-	res->maxfilesize = 0x7FFFFFFF;	/* just a guess */
+	res->tsize  = ntohl(*p++);
 	res->bsize  = ntohl(*p++);
-
-	res->tbytes = ntohl(*p++) * res->bsize;
-	res->fbytes = ntohl(*p++) * res->bsize;
-	res->abytes = ntohl(*p++) * res->bsize;
-	res->tfiles = 0;
-	res->ffiles = 0;
-	res->afiles = 0;
-	res->namelen = 0;
-
+	res->blocks = ntohl(*p++);
+	res->bfree  = ntohl(*p++);
+	res->bavail = ntohl(*p++);
 	return 0;
 }
 
diff -u --recursive --new-file linux-2.5.42-nfsv4-E01/fs/nfs/nfs3proc.c linux-2.5.42-nfsv4-E02/fs/nfs/nfs3proc.c
--- linux-2.5.42-nfsv4-E01/fs/nfs/nfs3proc.c	2002-10-11 18:22:38.000000000 -0400
+++ linux-2.5.42-nfsv4-E02/fs/nfs/nfs3proc.c	2002-10-12 19:56:07.000000000 -0400
@@ -639,24 +639,42 @@
 	return status;
 }
 
-/*
- * This is a combo call of fsstat and fsinfo
- */
 static int
 nfs3_proc_statfs(struct nfs_server *server, struct nfs_fh *fhandle,
-		 struct nfs_fsinfo *info)
+		 struct nfs_fsstat *stat)
 {
 	int	status;
 
 	dprintk("NFS call  fsstat\n");
-	memset((char *)info, 0, sizeof(*info));
-	status = rpc_call(server->client, NFS3PROC_FSSTAT, fhandle, info, 0);
-	if (status < 0)
-		goto error;
+	stat->fattr->valid = 0;
+	status = rpc_call(server->client, NFS3PROC_FSSTAT, fhandle, stat, 0);
+	dprintk("NFS reply statfs: %d\n", status);
+	return status;
+}
+
+static int
+nfs3_proc_fsinfo(struct nfs_server *server, struct nfs_fh *fhandle,
+		 struct nfs_fsinfo *info)
+{
+	int	status;
+
+	dprintk("NFS call  fsinfo\n");
+	info->fattr->valid = 0;
 	status = rpc_call(server->client, NFS3PROC_FSINFO, fhandle, info, 0);
+	dprintk("NFS reply fsinfo: %d\n", status);
+	return status;
+}
 
-error:
-	dprintk("NFS reply statfs: %d\n", status);
+static int
+nfs3_proc_pathconf(struct nfs_server *server, struct nfs_fh *fhandle,
+		   struct nfs_pathconf *info)
+{
+	int	status;
+
+	dprintk("NFS call  pathconf\n");
+	info->fattr->valid = 0;
+	status = rpc_call(server->client, NFS3PROC_PATHCONF, fhandle, info, 0);
+	dprintk("NFS reply pathconf: %d\n", status);
 	return status;
 }
 
@@ -824,6 +842,8 @@
 	.readdir	= nfs3_proc_readdir,
 	.mknod		= nfs3_proc_mknod,
 	.statfs		= nfs3_proc_statfs,
+	.fsinfo		= nfs3_proc_fsinfo,
+	.pathconf	= nfs3_proc_pathconf,
 	.decode_dirent	= nfs3_decode_dirent,
 	.read_setup	= nfs3_proc_read_setup,
 	.write_setup	= nfs3_proc_write_setup,
diff -u --recursive --new-file linux-2.5.42-nfsv4-E01/fs/nfs/nfs3xdr.c linux-2.5.42-nfsv4-E02/fs/nfs/nfs3xdr.c
--- linux-2.5.42-nfsv4-E01/fs/nfs/nfs3xdr.c	2002-10-08 18:44:43.000000000 -0400
+++ linux-2.5.42-nfsv4-E02/fs/nfs/nfs3xdr.c	2002-10-12 19:41:19.000000000 -0400
@@ -912,14 +912,13 @@
  * Decode FSSTAT reply
  */
 static int
-nfs3_xdr_fsstatres(struct rpc_rqst *req, u32 *p, struct nfs_fsinfo *res)
+nfs3_xdr_fsstatres(struct rpc_rqst *req, u32 *p, struct nfs_fsstat *res)
 {
-	struct nfs_fattr dummy;
 	int		status;
 
 	status = ntohl(*p++);
 
-	p = xdr_decode_post_op_attr(p, &dummy);
+	p = xdr_decode_post_op_attr(p, res->fattr);
 	if (status != 0)
 		return -nfs_stat_to_errno(status);
 
@@ -940,12 +939,11 @@
 static int
 nfs3_xdr_fsinfores(struct rpc_rqst *req, u32 *p, struct nfs_fsinfo *res)
 {
-	struct nfs_fattr dummy;
 	int		status;
 
 	status = ntohl(*p++);
 
-	p = xdr_decode_post_op_attr(p, &dummy);
+	p = xdr_decode_post_op_attr(p, res->fattr);
 	if (status != 0)
 		return -nfs_stat_to_errno(status);
 
@@ -959,6 +957,7 @@
 	p = xdr_decode_hyper(p, &res->maxfilesize);
 
 	/* ignore time_delta and properties */
+	res->lease_time = 0;
 	return 0;
 }
 
@@ -966,18 +965,17 @@
  * Decode PATHCONF reply
  */
 static int
-nfs3_xdr_pathconfres(struct rpc_rqst *req, u32 *p, struct nfs_fsinfo *res)
+nfs3_xdr_pathconfres(struct rpc_rqst *req, u32 *p, struct nfs_pathconf *res)
 {
-	struct nfs_fattr dummy;
 	int		status;
 
 	status = ntohl(*p++);
 
-	p = xdr_decode_post_op_attr(p, &dummy);
+	p = xdr_decode_post_op_attr(p, res->fattr);
 	if (status != 0)
 		return -nfs_stat_to_errno(status);
-	res->linkmax = ntohl(*p++);
-	res->namelen = ntohl(*p++);
+	res->max_link = ntohl(*p++);
+	res->max_namelen = ntohl(*p++);
 
 	/* ignore remaining fields */
 	return 0;
diff -u --recursive --new-file linux-2.5.42-nfsv4-E01/fs/nfs/proc.c linux-2.5.42-nfsv4-E02/fs/nfs/proc.c
--- linux-2.5.42-nfsv4-E01/fs/nfs/proc.c	2002-10-11 18:22:12.000000000 -0400
+++ linux-2.5.42-nfsv4-E02/fs/nfs/proc.c	2002-10-12 19:33:34.000000000 -0400
@@ -460,17 +460,62 @@
 
 static int
 nfs_proc_statfs(struct nfs_server *server, struct nfs_fh *fhandle,
-			struct nfs_fsinfo *info)
+			struct nfs_fsstat *stat)
 {
+	struct nfs2_fsstat fsinfo;
 	int	status;
 
 	dprintk("NFS call  statfs\n");
-	memset((char *)info, 0, sizeof(*info));
-	status = rpc_call(server->client, NFSPROC_STATFS, fhandle, info, 0);
+	stat->fattr->valid = 0;
+	status = rpc_call(server->client, NFSPROC_STATFS, fhandle, &fsinfo, 0);
 	dprintk("NFS reply statfs: %d\n", status);
+	if (status)
+		goto out;
+	stat->tbytes = (u64)fsinfo.blocks * fsinfo.bsize;
+	stat->fbytes = (u64)fsinfo.bfree  * fsinfo.bsize;
+	stat->abytes = (u64)fsinfo.bavail * fsinfo.bsize;
+	stat->tfiles = 0;
+	stat->ffiles = 0;
+	stat->afiles = 0;
+out:
 	return status;
 }
 
+static int
+nfs_proc_fsinfo(struct nfs_server *server, struct nfs_fh *fhandle,
+			struct nfs_fsinfo *info)
+{
+	struct nfs2_fsstat fsinfo;
+	int	status;
+
+	dprintk("NFS call  fsinfo\n");
+	info->fattr->valid = 0;
+	status = rpc_call(server->client, NFSPROC_STATFS, fhandle, &info, 0);
+	dprintk("NFS reply fsinfo: %d\n", status);
+	if (status)
+		goto out;
+	info->rtmax  = NFS_MAXDATA;
+	info->rtpref = fsinfo.tsize;
+	info->rtmult = fsinfo.bsize;
+	info->wtmax  = NFS_MAXDATA;
+	info->wtpref = fsinfo.tsize;
+	info->wtmult = fsinfo.bsize;
+	info->dtpref = fsinfo.tsize;
+	info->maxfilesize = 0x7FFFFFFF;
+	info->lease_time = 0;
+out:
+	return status;
+}
+
+static int
+nfs_proc_pathconf(struct nfs_server *server, struct nfs_fh *fhandle,
+		  struct nfs_pathconf *info)
+{
+	info->max_link = 0;
+	info->max_namelen = NFS2_MAXNAMLEN;
+	return 0;
+}
+
 extern u32 * nfs_decode_dirent(u32 *, struct nfs_entry *, int);
 
 static void
@@ -590,6 +635,8 @@
 	.readdir	= nfs_proc_readdir,
 	.mknod		= nfs_proc_mknod,
 	.statfs		= nfs_proc_statfs,
+	.fsinfo		= nfs_proc_fsinfo,
+	.pathconf	= nfs_proc_pathconf,
 	.decode_dirent	= nfs_decode_dirent,
 	.read_setup	= nfs_proc_read_setup,
 	.write_setup	= nfs_proc_write_setup,
diff -u --recursive --new-file linux-2.5.42-nfsv4-E01/include/linux/nfs_xdr.h linux-2.5.42-nfsv4-E02/include/linux/nfs_xdr.h
--- linux-2.5.42-nfsv4-E01/include/linux/nfs_xdr.h	2002-10-11 18:23:09.000000000 -0400
+++ linux-2.5.42-nfsv4-E02/include/linux/nfs_xdr.h	2002-10-12 19:26:24.000000000 -0400
@@ -50,6 +50,7 @@
  * Info on the file system
  */
 struct nfs_fsinfo {
+	struct nfs_fattr	*fattr; /* Post-op attributes */
 	__u32			rtmax;	/* max.  read transfer size */
 	__u32			rtpref;	/* pref. read transfer size */
 	__u32			rtmult;	/* reads should be multiple of this */
@@ -58,16 +59,31 @@
 	__u32			wtmult;	/* writes should be multiple of this */
 	__u32			dtpref;	/* pref. readdir transfer size */
 	__u64			maxfilesize;
-	__u64			bsize;	/* block size */
+	__u32			lease_time; /* in seconds */
+};
+
+struct nfs_fsstat {
+	struct nfs_fattr	*fattr; /* Post-op attributes */
 	__u64			tbytes;	/* total size in bytes */
 	__u64			fbytes;	/* # of free bytes */
 	__u64			abytes;	/* # of bytes available to user */
 	__u64			tfiles;	/* # of files */
 	__u64			ffiles;	/* # of free files */
 	__u64			afiles;	/* # of files available to user */
-	__u32			linkmax;/* max # of hard links */
-	__u32			namelen;/* max name length */
-	__u32			lease_time; /* in seconds */
+};
+
+struct nfs2_fsstat {
+	__u32			tsize;  /* Server transfer size */
+	__u32			bsize;  /* Filesystem block size */
+	__u32			blocks; /* No. of "bsize" blocks on filesystem */
+	__u32			bfree;  /* No. of free "bsize" blocks */
+	__u32			bavail; /* No. of available "bsize" blocks */
+};
+
+struct nfs_pathconf {
+	struct nfs_fattr	*fattr; /* Post-op attributes */
+	__u32			max_link; /* max # of hard links */
+	__u32			max_namelen; /* max name length */
 };
 
 /*
@@ -391,7 +407,11 @@
 	int	(*mknod)   (struct inode *, struct qstr *, struct iattr *,
 			    dev_t, struct nfs_fh *, struct nfs_fattr *);
 	int	(*statfs)  (struct nfs_server *, struct nfs_fh *,
+			    struct nfs_fsstat *);
+	int	(*fsinfo)  (struct nfs_server *, struct nfs_fh *,
 			    struct nfs_fsinfo *);
+	int	(*pathconf) (struct nfs_server *, struct nfs_fh *,
+			     struct nfs_pathconf *);
 	u32 *	(*decode_dirent)(u32 *, struct nfs_entry *, int plus);
 	void	(*read_setup)   (struct nfs_read_data *, unsigned int count);
 	void	(*write_setup)  (struct nfs_write_data *, unsigned int count, int how);


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
