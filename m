From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: [PATCH] Support for NFSv4 READ + WRITE attribute cache consistency
Date: Tue, 17 Dec 2002 19:16:11 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15871.27115.53994.646430@charged.uio.no>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS maillist <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18OMGP-0003vt-00
	for <nfs@lists.sourceforge.net>; Tue, 17 Dec 2002 10:16:17 -0800
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


Retrieve the post-operation attribute changes for NFSv4 READ and
WRITE operations. Unlike for NFSv2 and NFSv3, we do not retrieve the
full set of file attributes. The main reason for this is that
interpreting attributes is a much heavier task on NFSv4 (requiring, for
instance, translation of file owner names into uids ...). Hence

  For a READ request, we retrieve only the 'change attribute' (for cache
  consistency checking) and the atime.

  For a WRITE request, we retrieve the 'change attribute' and the file size.
  In addition, we retrieve the value of the change attribute prior to the
  write operation, in order to be able to do weak cache consistency checking.

Cheers,
  Trond

diff -u --recursive --new-file linux-2.5.52-02-nfsv4_write/fs/nfs/nfs3proc.c linux-2.5.52-03-nfsv4_attr/fs/nfs/nfs3proc.c
--- linux-2.5.52-02-nfsv4_write/fs/nfs/nfs3proc.c	2002-12-17 15:27:47.000000000 +0100
+++ linux-2.5.52-03-nfsv4_attr/fs/nfs/nfs3proc.c	2002-12-17 15:28:07.000000000 +0100
@@ -67,6 +67,20 @@
 	return 1;
 }
 
+static void
+nfs3_write_refresh_inode(struct inode *inode, struct nfs_fattr *fattr)
+{
+	if (fattr->valid & NFS_ATTR_FATTR) {
+		if (!(fattr->valid & NFS_ATTR_WCC)) {
+			fattr->pre_size  = NFS_CACHE_ISIZE(inode);
+			fattr->pre_mtime = NFS_CACHE_MTIME(inode);
+			fattr->pre_ctime = NFS_CACHE_CTIME(inode);
+			fattr->valid |= NFS_ATTR_WCC;
+		}
+		nfs_refresh_inode(inode, fattr);
+	}
+}
+
 /*
  * Bare-bones access to getattr: this is for nfs_read_super.
  */
@@ -239,6 +253,8 @@
 	dprintk("NFS call  read %d @ %Ld\n", count, (long long)offset);
 	fattr->valid = 0;
 	status = rpc_call_sync(NFS_CLIENT(inode), &msg, flags);
+	if (status >= 0)
+		nfs_refresh_inode(inode, fattr);
 	dprintk("NFS reply read: %d\n", status);
 	*eofp = res.eof;
 	return status;
@@ -279,6 +295,9 @@
 
 	status = rpc_call_sync(NFS_CLIENT(inode), &msg, rpcflags);
 
+	if (status >= 0)
+		nfs3_write_refresh_inode(inode, fattr);
+
 	dprintk("NFS reply read: %d\n", status);
 	return status < 0? status : res.count;
 }
@@ -685,9 +704,13 @@
 static void
 nfs3_read_done(struct rpc_task *task)
 {
+	struct nfs_write_data *data = (struct nfs_write_data *) task->tk_calldata;
+
 	if (nfs3_async_handle_jukebox(task))
 		return;
 	/* Call back common NFS readpage processing */
+	if (task->tk_status >= 0)
+		nfs_refresh_inode(data->inode, &data->fattr);
 	nfs_readpage_result(task);
 }
 
@@ -730,8 +753,12 @@
 static void
 nfs3_write_done(struct rpc_task *task)
 {
+	struct nfs_write_data *data = (struct nfs_write_data *) task->tk_calldata;
+
 	if (nfs3_async_handle_jukebox(task))
 		return;
+	if (task->tk_status >= 0)
+		nfs3_write_refresh_inode(data->inode, data->res.fattr);
 	nfs_writeback_done(task);
 }
 
@@ -784,8 +811,12 @@
 static void
 nfs3_commit_done(struct rpc_task *task)
 {
+	struct nfs_write_data *data = (struct nfs_write_data *) task->tk_calldata;
+
 	if (nfs3_async_handle_jukebox(task))
 		return;
+	if (task->tk_status >= 0)
+		nfs3_write_refresh_inode(data->inode, data->res.fattr);
 	nfs_commit_done(task);
 }
 
diff -u --recursive --new-file linux-2.5.52-02-nfsv4_write/fs/nfs/nfs4proc.c linux-2.5.52-03-nfsv4_attr/fs/nfs/nfs4proc.c
--- linux-2.5.52-02-nfsv4_write/fs/nfs/nfs4proc.c	2002-12-17 15:27:47.000000000 +0100
+++ linux-2.5.52-03-nfsv4_attr/fs/nfs/nfs4proc.c	2002-12-17 15:28:07.000000000 +0100
@@ -980,8 +980,12 @@
 	dprintk("NFS call  read %d @ %Ld\n", count, (long long)offset);
 	fattr->valid = 0;
 	status = rpc_call_sync(server->client, &msg, flags);
-	if (!status)
+	if (!status) {
 		renew_lease(server, timestamp);
+		/* Check cache consistency */
+		if (fattr->change_attr != NFS_CHANGE_ATTR(inode))
+			nfs_zap_caches(inode);
+	}
 	dprintk("NFS reply read: %d\n", status);
 	*eofp = res.eof;
 	return status;
@@ -1338,9 +1342,16 @@
 nfs4_read_done(struct rpc_task *task)
 {
 	struct nfs_read_data *data = (struct nfs_read_data *) task->tk_calldata;
+	struct inode *inode = data->inode;
+	struct nfs_fattr *fattr = data->res.fattr;
 
 	if (task->tk_status > 0)
-		renew_lease(NFS_SERVER(data->inode), data->timestamp);
+		renew_lease(NFS_SERVER(inode), data->timestamp);
+	/* Check cache consistency */
+	if (fattr->change_attr != NFS_CHANGE_ATTR(inode))
+		nfs_zap_caches(inode);
+	if (fattr->bitmap[1] & FATTR4_WORD1_TIME_ACCESS)
+		inode->i_atime = fattr->atime;
 	/* Call back common NFS readpage processing */
 	nfs_readpage_result(task);
 }
@@ -1382,12 +1393,29 @@
 }
 
 static void
+nfs4_write_refresh_inode(struct inode *inode, struct nfs_fattr *fattr)
+{
+	/* Check cache consistency */
+	if (fattr->pre_change_attr != NFS_CHANGE_ATTR(inode))
+		nfs_zap_caches(inode);
+	NFS_CHANGE_ATTR(inode) = fattr->change_attr;
+	if (fattr->bitmap[1] & FATTR4_WORD1_SPACE_USED)
+		inode->i_blocks = (fattr->du.nfs3.used + 511) >> 9;
+	if (fattr->bitmap[1] & FATTR4_WORD1_TIME_METADATA)
+		inode->i_ctime = fattr->ctime;
+	if (fattr->bitmap[1] & FATTR4_WORD1_TIME_MODIFY)
+		inode->i_mtime = fattr->mtime;
+}
+
+static void
 nfs4_write_done(struct rpc_task *task)
 {
 	struct nfs_write_data *data = (struct nfs_write_data *) task->tk_calldata;
+	struct inode *inode = data->inode;
 	
-	if (task->tk_status > 0)
-		renew_lease(NFS_SERVER(data->inode), data->timestamp);
+	if (task->tk_status >= 0)
+		renew_lease(NFS_SERVER(inode), data->timestamp);
+	nfs4_write_refresh_inode(inode, data->res.fattr);
 	/* Call back common NFS writeback processing */
 	nfs_writeback_done(task);
 }
@@ -1439,6 +1467,16 @@
 }
 
 static void
+nfs4_commit_done(struct rpc_task *task)
+{
+	struct nfs_write_data *data = (struct nfs_write_data *) task->tk_calldata;
+	
+	nfs4_write_refresh_inode(data->inode, data->res.fattr);
+	/* Call back common NFS writeback processing */
+	nfs_commit_done(task);
+}
+
+static void
 nfs4_proc_commit_setup(struct nfs_write_data *data, u64 start, u32 len, int how)
 {
 	struct rpc_task	*task = &data->task;
@@ -1462,7 +1500,7 @@
 	flags = (how & FLUSH_SYNC) ? 0 : RPC_TASK_ASYNC;
 
 	/* Finalize the task. */
-	rpc_init_task(task, NFS_CLIENT(inode), nfs_commit_done, flags);
+	rpc_init_task(task, NFS_CLIENT(inode), nfs4_commit_done, flags);
 	task->tk_calldata = data;
 	/* Release requests */
 	task->tk_release = nfs_commit_release;
diff -u --recursive --new-file linux-2.5.52-02-nfsv4_write/fs/nfs/nfs4xdr.c linux-2.5.52-03-nfsv4_attr/fs/nfs/nfs4xdr.c
--- linux-2.5.52-02-nfsv4_write/fs/nfs/nfs4xdr.c	2002-12-17 15:27:47.000000000 +0100
+++ linux-2.5.52-03-nfsv4_attr/fs/nfs/nfs4xdr.c	2002-12-17 15:28:07.000000000 +0100
@@ -78,27 +78,43 @@
 #define encode_putfh_maxsz	op_encode_hdr_maxsz + 1 + \
 				(NFS4_FHSIZE >> 2)
 #define decode_putfh_maxsz	op_decode_hdr_maxsz
+#define encode_read_getattr_maxsz	op_encode_hdr_maxsz + 2
+#define decode_read_getattr_maxsz	op_decode_hdr_maxsz + 8
+#define encode_pre_write_getattr_maxsz	op_encode_hdr_maxsz + 2
+#define decode_pre_write_getattr_maxsz	op_decode_hdr_maxsz + 5
+#define encode_post_write_getattr_maxsz	op_encode_hdr_maxsz + 2
+#define decode_post_write_getattr_maxsz	op_decode_hdr_maxsz + 13
 
 #define NFS4_enc_compound_sz	1024  /* XXX: large enough? */
 #define NFS4_dec_compound_sz	1024  /* XXX: large enough? */
 #define NFS4_enc_read_sz	compound_encode_hdr_maxsz + \
 				encode_putfh_maxsz + \
+				encode_read_getattr_maxsz + \
 				op_encode_hdr_maxsz + 7
 #define NFS4_dec_read_sz	compound_decode_hdr_maxsz + \
 				decode_putfh_maxsz + \
+				decode_read_getattr_maxsz + \
 				op_decode_hdr_maxsz + 2
 #define NFS4_enc_write_sz	compound_encode_hdr_maxsz + \
 				encode_putfh_maxsz + \
-				op_encode_hdr_maxsz + 8
+				encode_pre_write_getattr_maxsz + \
+				op_encode_hdr_maxsz + 8 + \
+				encode_post_write_getattr_maxsz
 #define NFS4_dec_write_sz	compound_decode_hdr_maxsz + \
 				decode_putfh_maxsz + \
-				op_decode_hdr_maxsz + 4
+				decode_pre_write_getattr_maxsz + \
+				op_decode_hdr_maxsz + 4 + \
+				decode_post_write_getattr_maxsz
 #define NFS4_enc_commit_sz	compound_encode_hdr_maxsz + \
 				encode_putfh_maxsz + \
-				op_encode_hdr_maxsz + 3
+				encode_pre_write_getattr_maxsz + \
+				op_encode_hdr_maxsz + 3 + \
+				encode_post_write_getattr_maxsz
 #define NFS4_dec_commit_sz	compound_decode_hdr_maxsz + \
 				decode_putfh_maxsz + \
-				op_decode_hdr_maxsz + 2
+				decode_pre_write_getattr_maxsz + \
+				op_decode_hdr_maxsz + 2 + \
+				decode_post_write_getattr_maxsz
 
 
 static struct {
@@ -391,19 +407,69 @@
 }
 
 static int
-encode_getattr(struct xdr_stream *xdr, struct nfs4_getattr *getattr)
+encode_getattr_one(struct xdr_stream *xdr, uint32_t bitmap)
+{
+        uint32_t *p;
+
+        RESERVE_SPACE(12);
+        WRITE32(OP_GETATTR);
+        WRITE32(1);
+        WRITE32(bitmap);
+        return 0;
+}
+
+static int
+encode_getattr_two(struct xdr_stream *xdr, uint32_t bm0, uint32_t bm1)
 {
         uint32_t *p;
 
         RESERVE_SPACE(16);
         WRITE32(OP_GETATTR);
         WRITE32(2);
-        WRITE32(getattr->gt_bmval[0]);
-        WRITE32(getattr->gt_bmval[1]);
-
+        WRITE32(bm0);
+        WRITE32(bm1);
         return 0;
 }
 
+static inline int
+encode_getattr(struct xdr_stream *xdr, struct nfs4_getattr *getattr)
+{
+	return encode_getattr_two(xdr, getattr->gt_bmval[0],
+					getattr->gt_bmval[1]);
+}
+
+/*
+ * Request the change attribute in order to check attribute+cache consistency
+ */
+static inline int
+encode_read_getattr(struct xdr_stream *xdr)
+{
+	return encode_getattr_two(xdr, FATTR4_WORD0_CHANGE,
+			FATTR4_WORD1_TIME_ACCESS);
+}
+
+/*
+ * Request the change attribute prior to doing a write operation
+ */
+static inline int
+encode_pre_write_getattr(struct xdr_stream *xdr)
+{
+	/* Request the change attribute */
+	return encode_getattr_one(xdr, FATTR4_WORD0_CHANGE);
+}
+
+/*
+ * Request the change attribute, size, and [cm]time after a write operation
+ */
+static inline int
+encode_post_write_getattr(struct xdr_stream *xdr)
+{
+	return encode_getattr_two(xdr, FATTR4_WORD0_CHANGE|FATTR4_WORD0_SIZE,
+			FATTR4_WORD1_SPACE_USED |
+			FATTR4_WORD1_TIME_METADATA |
+			FATTR4_WORD1_TIME_MODIFY);
+}
+
 static int
 encode_getfh(struct xdr_stream *xdr)
 {
@@ -853,7 +919,7 @@
 	struct rpc_auth	*auth = req->rq_task->tk_auth;
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops	= 2,
+		.nops	= 3,
 	};
 	int replen, status;
 
@@ -863,12 +929,16 @@
 	if (status)
 		goto out;
 	status = encode_read(&xdr, args);
+	if (status)
+		goto out;
+	status = encode_read_getattr(&xdr);
 
 	/* set up reply iovec
 	 *    toplevel status + taglen=0 + rescount + OP_PUTFH + status
 	 *       + OP_READ + status + eof + datalen = 9
 	 */
-	replen = (RPC_REPHDRSIZE + auth->au_rslack + NFS4_dec_read_sz) << 2;
+	replen = (RPC_REPHDRSIZE + auth->au_rslack +
+			NFS4_dec_read_sz - decode_read_getattr_maxsz) << 2;
 	xdr_inline_pages(&req->rq_rcv_buf, replen,
 			 args->pages, args->pgbase, args->count);
 out:
@@ -883,7 +953,7 @@
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops   = 2,
+		.nops   = 4,
 	};
 	int status;
 
@@ -892,7 +962,13 @@
 	status = encode_putfh(&xdr, args->fh);
 	if (status)
 		goto out;
+	status = encode_pre_write_getattr(&xdr);
+	if (status)
+		goto out;
 	status = encode_write(&xdr, args);
+	if (status)
+		goto out;
+	status = encode_post_write_getattr(&xdr);
 out:
 	return status;
 }
@@ -905,7 +981,7 @@
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops   = 2,
+		.nops   = 4,
 	};
 	int status;
 
@@ -914,7 +990,13 @@
 	status = encode_putfh(&xdr, args->fh);
 	if (status)
 		goto out;
+	status = encode_pre_write_getattr(&xdr);
+	if (status)
+		goto out;
 	status = encode_commit(&xdr, args);
+	if (status)
+		goto out;
+	status = encode_post_write_getattr(&xdr);
 out:
 	return status;
 }
@@ -1360,6 +1442,139 @@
 }
 
 static int
+decode_change_attr(struct xdr_stream *xdr, uint64_t *change_attr)
+{
+	uint32_t *p;
+	uint32_t attrlen, bmlen, bmval = 0;
+	int status;
+
+	status = decode_op_hdr(xdr, OP_GETATTR);
+	if (status)
+		return status;
+	READ_BUF(4);
+	READ32(bmlen);
+	if (bmlen < 1)
+		return -EIO;
+	READ_BUF(bmlen << 2);
+	READ32(bmval);
+	if (bmval != FATTR4_WORD0_CHANGE) {
+		printk(KERN_NOTICE "decode_change_attr: server returned bad attribute bitmap 0x%x\n",
+			(unsigned int)bmval);
+		return -EIO;
+	}
+	READ_BUF(4);
+	READ32(attrlen);
+	READ_BUF(attrlen);
+	if (attrlen < 8) {
+		printk(KERN_NOTICE "decode_change_attr: server returned bad attribute length %u\n",
+				(unsigned int)attrlen);
+		return -EIO;
+	}
+	READ64(*change_attr);
+	return 0;
+}
+
+static int
+decode_read_getattr(struct xdr_stream *xdr, struct nfs_fattr *fattr)
+{
+	uint32_t *p;
+	uint32_t attrlen, bmlen, bmval0 = 0, bmval1 = 0;
+	int status;
+
+	status = decode_op_hdr(xdr, OP_GETATTR);
+	if (status)
+		return status;
+	READ_BUF(4);
+	READ32(bmlen);
+	if (bmlen < 1)
+		return -EIO;
+	READ_BUF(bmlen << 2);
+	READ32(bmval0);
+	if (bmval0 != FATTR4_WORD0_CHANGE)
+		goto out_bad_bitmap;
+	if (bmlen > 1) {
+		READ32(bmval1);
+		if (bmval1 & ~(FATTR4_WORD1_TIME_ACCESS))
+			goto out_bad_bitmap;
+	}
+	READ_BUF(4);
+	READ32(attrlen);
+	READ_BUF(attrlen);
+	if (attrlen < 16) {
+		printk(KERN_NOTICE "decode_post_write_getattr: server returned bad attribute length %u\n",
+				(unsigned int)attrlen);
+		return -EIO;
+	}
+	READ64(fattr->change_attr);
+	if (bmval1 & FATTR4_WORD1_TIME_ACCESS)
+		READTIME(fattr->atime);
+	fattr->bitmap[0] = bmval0;
+	fattr->bitmap[1] = bmval1;
+	return 0;
+out_bad_bitmap:
+	printk(KERN_NOTICE "decode_read_getattr: server returned bad attribute bitmap 0x%x/0x%x\n",
+			(unsigned int)bmval0, (unsigned int)bmval1);
+	return -EIO;
+}
+
+static int
+decode_pre_write_getattr(struct xdr_stream *xdr, struct nfs_fattr *fattr)
+{
+	return decode_change_attr(xdr, &fattr->pre_change_attr);
+}
+
+static int
+decode_post_write_getattr(struct xdr_stream *xdr, struct nfs_fattr *fattr)
+{
+	uint32_t *p;
+	uint32_t attrlen, bmlen, bmval0 = 0, bmval1 = 0;
+	int status;
+
+	status = decode_op_hdr(xdr, OP_GETATTR);
+	if (status)
+		return status;
+	READ_BUF(4);
+	READ32(bmlen);
+	if (bmlen < 1)
+		return -EIO;
+	READ_BUF(bmlen << 2);
+	READ32(bmval0);
+	if (bmval0 != (FATTR4_WORD0_CHANGE|FATTR4_WORD0_SIZE))
+		goto out_bad_bitmap;
+	if (bmlen > 1) {
+		READ32(bmval1);
+		if (bmval1 & ~(FATTR4_WORD1_SPACE_USED |
+					FATTR4_WORD1_TIME_METADATA |
+					FATTR4_WORD1_TIME_MODIFY))
+			goto out_bad_bitmap;
+	}
+	READ_BUF(4);
+	READ32(attrlen);
+	READ_BUF(attrlen);
+	if (attrlen < 16) {
+		printk(KERN_NOTICE "decode_post_write_getattr: server returned bad attribute length %u\n",
+				(unsigned int)attrlen);
+		return -EIO;
+	}
+	READ64(fattr->change_attr);
+	READ64(fattr->size);
+	if (bmval1 & FATTR4_WORD1_SPACE_USED)
+		READ64(fattr->du.nfs3.used);
+	if (bmval1 & FATTR4_WORD1_TIME_METADATA)
+		READTIME(fattr->ctime);
+	if (bmval1 & FATTR4_WORD1_TIME_MODIFY)
+		READTIME(fattr->mtime);
+	fattr->bitmap[0] = bmval0;
+	fattr->bitmap[1] = bmval1;
+	return 0;
+out_bad_bitmap:
+	printk(KERN_NOTICE "decode_post_write_getattr: server returned bad attribute bitmap 0x%x/0x%x\n",
+			(unsigned int)bmval0, (unsigned int)bmval1);
+	return -EIO;
+}
+
+
+static int
 decode_getfh(struct xdr_stream *xdr, struct nfs4_getfh *getfh)
 {
 	struct nfs_fh *fh = getfh->gf_fhandle;
@@ -1883,6 +2098,9 @@
 	if (status)
 		goto out;
 	status = decode_read(&xdr, rqstp, res);
+	if (status)
+		goto out;
+	status = decode_read_getattr(&xdr, res->fattr);
 	if (!status)
 		status = -nfs_stat_to_errno(hdr.status);
 out:
@@ -1906,7 +2124,13 @@
 	status = decode_putfh(&xdr);
 	if (status)
 		goto out;
+	status = decode_pre_write_getattr(&xdr, res->fattr);
+	if (status)
+		goto out;
 	status = decode_write(&xdr, res);
+	if (status)
+		goto out;
+	status = decode_post_write_getattr(&xdr, res->fattr);
 	if (!status)
 		status = -nfs_stat_to_errno(hdr.status);
 	if (!status)
@@ -1932,7 +2156,13 @@
 	status = decode_putfh(&xdr);
 	if (status)
 		goto out;
+	status = decode_pre_write_getattr(&xdr, res->fattr);
+	if (status)
+		goto out;
 	status = decode_commit(&xdr, res);
+	if (status)
+		goto out;
+	status = decode_post_write_getattr(&xdr, res->fattr);
 	if (!status)
 		status = -nfs_stat_to_errno(hdr.status);
 out:
diff -u --recursive --new-file linux-2.5.52-02-nfsv4_write/fs/nfs/proc.c linux-2.5.52-03-nfsv4_attr/fs/nfs/proc.c
--- linux-2.5.52-02-nfsv4_write/fs/nfs/proc.c	2002-12-17 15:27:47.000000000 +0100
+++ linux-2.5.52-03-nfsv4_attr/fs/nfs/proc.c	2002-12-17 15:28:07.000000000 +0100
@@ -48,6 +48,18 @@
 
 extern struct rpc_procinfo nfs_procedures[];
 
+static void
+nfs_write_refresh_inode(struct inode *inode, struct nfs_fattr *fattr)
+{
+	if (!(fattr->valid & NFS_ATTR_WCC)) {
+		fattr->pre_size  = NFS_CACHE_ISIZE(inode);
+		fattr->pre_mtime = NFS_CACHE_MTIME(inode);
+		fattr->pre_ctime = NFS_CACHE_CTIME(inode);
+		fattr->valid |= NFS_ATTR_WCC;
+	}
+	nfs_refresh_inode(inode, fattr);
+}
+
 /*
  * Bare-bones access to getattr: this is for nfs_read_super.
  */
@@ -166,6 +178,8 @@
 	fattr->valid = 0;
 	status = rpc_call_sync(NFS_CLIENT(inode), &msg, flags);
 
+	if (status >= 0)
+		nfs_refresh_inode(inode, fattr);
 	dprintk("NFS reply read: %d\n", status);
 	*eofp = res.eof;
 	return status;
@@ -205,6 +219,9 @@
 		flags |= NFS_RPC_SWAPFLAGS;
 	status = rpc_call_sync(NFS_CLIENT(inode), &msg, flags);
 
+	if (status >= 0)
+		nfs_write_refresh_inode(inode, fattr);
+
 	dprintk("NFS reply write: %d\n", status);
 	verf->committed = NFS_FILE_SYNC;      /* NFSv2 always syncs data */
 	return status < 0? status : count;
@@ -521,6 +538,16 @@
 extern u32 * nfs_decode_dirent(u32 *, struct nfs_entry *, int);
 
 static void
+nfs_read_done(struct rpc_task *task)
+{
+	struct nfs_read_data *data = (struct nfs_read_data *) task->tk_calldata;
+
+	if (task->tk_status >= 0)
+		nfs_refresh_inode(data->inode, data->res.fattr);
+	nfs_readpage_result(task);
+}
+
+static void
 nfs_proc_read_setup(struct nfs_read_data *data, unsigned int count)
 {
 	struct rpc_task		*task = &data->task;
@@ -548,7 +575,7 @@
 	flags = RPC_TASK_ASYNC | (IS_SWAPFILE(inode)? NFS_RPC_SWAPFLAGS : 0);
 
 	/* Finalize the task. */
-	rpc_init_task(task, NFS_CLIENT(inode), nfs_readpage_result, flags);
+	rpc_init_task(task, NFS_CLIENT(inode), nfs_read_done, flags);
 	task->tk_calldata = data;
 	/* Release requests */
 	task->tk_release = nfs_readdata_release;
@@ -557,6 +584,16 @@
 }
 
 static void
+nfs_write_done(struct rpc_task *task)
+{
+	struct nfs_write_data *data = (struct nfs_write_data *) task->tk_calldata;
+
+	if (task->tk_status >= 0)
+		nfs_write_refresh_inode(data->inode, data->res.fattr);
+	nfs_writeback_done(task);
+}
+
+static void
 nfs_proc_write_setup(struct nfs_write_data *data, unsigned int count, int how)
 {
 	struct rpc_task		*task = &data->task;
@@ -587,7 +624,7 @@
 	flags = (how & FLUSH_SYNC) ? 0 : RPC_TASK_ASYNC;
 
 	/* Finalize the task. */
-	rpc_init_task(task, NFS_CLIENT(inode), nfs_writeback_done, flags);
+	rpc_init_task(task, NFS_CLIENT(inode), nfs_write_done, flags);
 	task->tk_calldata = data;
 	/* Release requests */
 	task->tk_release = nfs_writedata_release;
diff -u --recursive --new-file linux-2.5.52-02-nfsv4_write/fs/nfs/read.c linux-2.5.52-03-nfsv4_attr/fs/nfs/read.c
--- linux-2.5.52-02-nfsv4_write/fs/nfs/read.c	2002-12-17 15:27:29.000000000 +0100
+++ linux-2.5.52-03-nfsv4_attr/fs/nfs/read.c	2002-12-17 15:28:07.000000000 +0100
@@ -100,7 +100,6 @@
 		lock_kernel();
 		result = NFS_PROTO(inode)->read(inode, cred, &fattr, flags,
 						offset, rsize, page, &eof);
-		nfs_refresh_inode(inode, &fattr);
 		unlock_kernel();
 
 		/*
@@ -258,14 +257,12 @@
 nfs_readpage_result(struct rpc_task *task)
 {
 	struct nfs_read_data	*data = (struct nfs_read_data *) task->tk_calldata;
-	struct inode		*inode = data->inode;
 	struct nfs_fattr	*fattr = &data->fattr;
 	unsigned int count = data->res.count;
 
 	dprintk("NFS: %4d nfs_readpage_result, (status %d)\n",
 		task->tk_pid, task->tk_status);
 
-	nfs_refresh_inode(inode, fattr);
 	while (!list_empty(&data->pages)) {
 		struct nfs_page *req = nfs_list_entry(data->pages.next);
 		struct page *page = req->wb_page;
diff -u --recursive --new-file linux-2.5.52-02-nfsv4_write/fs/nfs/write.c linux-2.5.52-03-nfsv4_attr/fs/nfs/write.c
--- linux-2.5.52-02-nfsv4_write/fs/nfs/write.c	2002-12-17 15:27:47.000000000 +0100
+++ linux-2.5.52-03-nfsv4_attr/fs/nfs/write.c	2002-12-17 15:28:07.000000000 +0100
@@ -125,23 +125,6 @@
 }
 
 /*
- * This function will be used to simulate weak cache consistency
- * under NFSv2 when the NFSv3 attribute patch is included.
- * For the moment, we just call nfs_refresh_inode().
- */
-static __inline__ int
-nfs_write_attributes(struct inode *inode, struct nfs_fattr *fattr)
-{
-	if ((fattr->valid & NFS_ATTR_FATTR) && !(fattr->valid & NFS_ATTR_WCC)) {
-		fattr->pre_size  = NFS_CACHE_ISIZE(inode);
-		fattr->pre_mtime = NFS_CACHE_MTIME(inode);
-		fattr->pre_ctime = NFS_CACHE_CTIME(inode);
-		fattr->valid |= NFS_ATTR_WCC;
-	}
-	return nfs_refresh_inode(inode, fattr);
-}
-
-/*
  * Write a page synchronously.
  * Offset is the data offset within the page.
  */
@@ -178,7 +161,6 @@
 
 		result = NFS_PROTO(inode)->write(inode, cred, &fattr, flags,
 						 offset, wsize, page, &verf);
-		nfs_write_attributes(inode, &fattr);
 
 		if (result < 0) {
 			/* Must mark the page invalid after I/O error */
@@ -893,7 +875,6 @@
 	 *	  writebacks since the page->count is kept > 1 for as long
 	 *	  as the page has a write request pending.
 	 */
-	nfs_write_attributes(inode, &data->fattr);
 	while (!list_empty(&data->pages)) {
 		req = nfs_list_entry(data->pages.next);
 		nfs_list_remove_request(req);
@@ -1018,12 +999,10 @@
 {
 	struct nfs_write_data	*data = (struct nfs_write_data *)task->tk_calldata;
 	struct nfs_page		*req;
-	struct inode		*inode = data->inode;
 
         dprintk("NFS: %4d nfs_commit_done (status %d)\n",
                                 task->tk_pid, task->tk_status);
 
-	nfs_write_attributes(inode, &data->fattr);
 	while (!list_empty(&data->pages)) {
 		req = nfs_list_entry(data->pages.next);
 		nfs_list_remove_request(req);
diff -u --recursive --new-file linux-2.5.52-02-nfsv4_write/include/linux/nfs_xdr.h linux-2.5.52-03-nfsv4_attr/include/linux/nfs_xdr.h
--- linux-2.5.52-02-nfsv4_write/include/linux/nfs_xdr.h	2002-12-17 15:27:47.000000000 +0100
+++ linux-2.5.52-03-nfsv4_attr/include/linux/nfs_xdr.h	2002-12-17 15:28:07.000000000 +0100
@@ -35,8 +35,11 @@
 	struct timespec		atime;
 	struct timespec		mtime;
 	struct timespec		ctime;
+#ifdef CONFIG_NFS_V4
+	__u32			bitmap[2];	/* NFSv4 returned attribute bitmap */
 	__u64			change_attr;	/* NFSv4 change attribute */
 	__u64			pre_change_attr;/* pre-op NFSv4 change attribute */
+#endif
 	unsigned long		timestamp;
 };
 


-------------------------------------------------------
This sf.net email is sponsored by:
With Great Power, Comes Great Responsibility 
Learn to use your power at OSDN's High Performance Computing Channel
http://hpc.devchannel.org/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
