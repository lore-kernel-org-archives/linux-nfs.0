From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: [PATCH] Clean up NFSv4 WRITE xdr path
Date: Tue, 17 Dec 2002 19:15:17 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15871.27061.307281.359451@charged.uio.no>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS maillist <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18OMFc-0003Cy-00
	for <nfs@lists.sourceforge.net>; Tue, 17 Dec 2002 10:15:28 -0800
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


The following patch creates a clean XDR path for the NFSv4 write requests
instead of routing through encode_compound()/decode_compound().

Cheers,
  Trond

diff -u --recursive --new-file linux-2.5.52-01-nfsv4_read/fs/nfs/nfs3proc.c linux-2.5.52-02-nfsv4_write/fs/nfs/nfs3proc.c
--- linux-2.5.52-01-nfsv4_read/fs/nfs/nfs3proc.c	2002-12-17 15:27:29.000000000 +0100
+++ linux-2.5.52-02-nfsv4_write/fs/nfs/nfs3proc.c	2002-12-17 15:27:47.000000000 +0100
@@ -730,12 +730,9 @@
 static void
 nfs3_write_done(struct rpc_task *task)
 {
-	struct nfs_write_data *data = (struct nfs_write_data *) task->tk_calldata;
-
 	if (nfs3_async_handle_jukebox(task))
 		return;
-	nfs_writeback_done(task, data->u.v3.args.stable,
-			   data->u.v3.args.count, data->u.v3.res.count);
+	nfs_writeback_done(task);
 }
 
 static void
@@ -748,8 +745,8 @@
 	int			flags;
 	struct rpc_message	msg = {
 		.rpc_proc	= &nfs3_procedures[NFS3PROC_WRITE],
-		.rpc_argp	= &data->u.v3.args,
-		.rpc_resp	= &data->u.v3.res,
+		.rpc_argp	= &data->args,
+		.rpc_resp	= &data->res,
 		.rpc_cred	= data->cred,
 	};
 
@@ -762,15 +759,15 @@
 		stable = NFS_UNSTABLE;
 	
 	req = nfs_list_entry(data->pages.next);
-	data->u.v3.args.fh     = NFS_FH(inode);
-	data->u.v3.args.offset = req_offset(req) + req->wb_offset;
-	data->u.v3.args.pgbase = req->wb_offset;
-	data->u.v3.args.count  = count;
-	data->u.v3.args.stable = stable;
-	data->u.v3.args.pages  = data->pagevec;
-	data->u.v3.res.fattr   = &data->fattr;
-	data->u.v3.res.count   = count;
-	data->u.v3.res.verf    = &data->verf;
+	data->args.fh     = NFS_FH(inode);
+	data->args.offset = req_offset(req) + req->wb_offset;
+	data->args.pgbase = req->wb_offset;
+	data->args.count  = count;
+	data->args.stable = stable;
+	data->args.pages  = data->pagevec;
+	data->res.fattr   = &data->fattr;
+	data->res.count   = count;
+	data->res.verf    = &data->verf;
 
 	/* Set the initial flags for the task.  */
 	flags = (how & FLUSH_SYNC) ? 0 : RPC_TASK_ASYNC;
@@ -800,17 +797,17 @@
 	int			flags;
 	struct rpc_message	msg = {
 		.rpc_proc	= &nfs3_procedures[NFS3PROC_COMMIT],
-		.rpc_argp	= &data->u.v3.args,
-		.rpc_resp	= &data->u.v3.res,
+		.rpc_argp	= &data->args,
+		.rpc_resp	= &data->res,
 		.rpc_cred	= data->cred,
 	};
 
-	data->u.v3.args.fh     = NFS_FH(data->inode);
-	data->u.v3.args.offset = start;
-	data->u.v3.args.count  = len;
-	data->u.v3.res.count   = len;
-	data->u.v3.res.fattr   = &data->fattr;
-	data->u.v3.res.verf    = &data->verf;
+	data->args.fh     = NFS_FH(data->inode);
+	data->args.offset = start;
+	data->args.count  = len;
+	data->res.count   = len;
+	data->res.fattr   = &data->fattr;
+	data->res.verf    = &data->verf;
 	
 	/* Set the initial flags for the task.  */
 	flags = (how & FLUSH_SYNC) ? 0 : RPC_TASK_ASYNC;
diff -u --recursive --new-file linux-2.5.52-01-nfsv4_read/fs/nfs/nfs4proc.c linux-2.5.52-02-nfsv4_write/fs/nfs/nfs4proc.c
--- linux-2.5.52-01-nfsv4_read/fs/nfs/nfs4proc.c	2002-12-17 15:27:29.000000000 +0100
+++ linux-2.5.52-02-nfsv4_write/fs/nfs/nfs4proc.c	2002-12-17 15:27:47.000000000 +0100
@@ -94,19 +94,6 @@
 }
 
 static void
-nfs4_setup_commit(struct nfs4_compound *cp, u64 start, u32 len, struct nfs_writeverf *verf)
-{
-	struct nfs4_commit *commit = GET_OP(cp, commit);
-
-	commit->co_start = start;
-	commit->co_len = len;
-	commit->co_verifier = verf;
-
-	OPNUM(cp) = OP_COMMIT;
-	cp->req_nops++;
-}
-
-static void
 nfs4_setup_create_dir(struct nfs4_compound *cp, struct qstr *name,
 		      struct iattr *sattr, struct nfs4_change_info *info)
 {
@@ -577,26 +564,6 @@
 }
 
 static void
-nfs4_setup_write(struct nfs4_compound *cp, u64 offset, u32 length, int stable,
-		 struct page **pages, unsigned int pgbase, u32 *bytes_written,
-		 struct nfs_writeverf *verf)
-{
-	struct nfs4_write *write = GET_OP(cp, write);
-
-	write->wr_offset = offset;
-	write->wr_stable_how = stable;
-	write->wr_len = length;
-	write->wr_bytes_written = bytes_written;
-	write->wr_verf = verf;
-
-	write->wr_pages = pages;
-	write->wr_pgbase = pgbase;
-
-	OPNUM(cp) = OP_WRITE;
-	cp->req_nops++;
-}
-
-static void
 renew_lease(struct nfs_server *server, unsigned long timestamp)
 {
 	spin_lock(&renew_lock);
@@ -1026,23 +993,32 @@
 		unsigned int base, unsigned int count,
 		struct page *page, struct nfs_writeverf *verf)
 {
-	u64			offset = page_offset(page) + base;
-	struct nfs4_compound	compound;
-	struct nfs4_op		ops[2];
-	u32			bytes_written;
-	int			stable = (flags & NFS_RW_SYNC) ? NFS_FILE_SYNC : NFS_UNSTABLE;
+	struct nfs_server *server = NFS_SERVER(inode);
+	uint64_t offset = page_offset(page) + base;
+	struct nfs_writeargs arg = {
+		.fh		= NFS_FH(inode),
+		.offset		= offset,
+		.count		= count,
+		.stable		= (flags & NFS_RW_SYNC) ? NFS_FILE_SYNC : NFS_UNSTABLE,
+		.pgbase		= base,
+		.pages		= &page,
+	};
+	struct nfs_writeres res = {
+		.fattr		= fattr,
+		.count		= count,
+		.verf		= verf,
+	};
+	struct rpc_message msg = {
+		.rpc_proc	= &nfs4_procedures[NFSPROC4_CLNT_WRITE],
+		.rpc_argp	= &arg,
+		.rpc_resp	= &res,
+		.rpc_cred	= cred,
+	};
 	int			rpcflags = (flags & NFS_RW_SWAP) ? NFS_RPC_SWAPFLAGS : 0;
-	int			status;
 
+	dprintk("NFS call  write %d @ %Ld\n", count, (long long)offset);
 	fattr->valid = 0;
-	nfs4_setup_compound(&compound, ops, NFS_SERVER(inode), "write [sync]");
-	nfs4_setup_putfh(&compound, NFS_FH(inode));
-	nfs4_setup_write(&compound, offset, count, stable, &page, base, &bytes_written, verf);
-	status = nfs4_call_compound(&compound, cred, rpcflags);
-	
-	if (status >= 0)
-		status = bytes_written;
-	return status;
+	return rpc_call_sync(server->client, &msg, rpcflags);
 }
 
 static int
@@ -1410,20 +1386,20 @@
 {
 	struct nfs_write_data *data = (struct nfs_write_data *) task->tk_calldata;
 	
-	process_lease(&data->u.v4.compound);
-	nfs_writeback_done(task, data->u.v4.arg_stable,
-			   data->u.v4.arg_count, data->u.v4.res_count);
+	if (task->tk_status > 0)
+		renew_lease(NFS_SERVER(data->inode), data->timestamp);
+	/* Call back common NFS writeback processing */
+	nfs_writeback_done(task);
 }
 
 static void
 nfs4_proc_write_setup(struct nfs_write_data *data, unsigned int count, int how)
 {
 	struct rpc_task	*task = &data->task;
-	struct nfs4_compound *cp = &data->u.v4.compound;
 	struct rpc_message msg = {
-		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_COMPOUND],
-		.rpc_argp = cp,
-		.rpc_resp = cp,
+		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_WRITE],
+		.rpc_argp = &data->args,
+		.rpc_resp = &data->res,
 		.rpc_cred = data->cred,
 	};
 	struct inode *inode = data->inode;
@@ -1439,11 +1415,16 @@
 	} else
 		stable = NFS_UNSTABLE;
 
-	nfs4_setup_compound(cp, data->u.v4.ops, NFS_SERVER(inode), "write [async]");
-	nfs4_setup_putfh(cp, NFS_FH(inode));
-	nfs4_setup_write(cp, req_offset(req) + req->wb_offset,
-			 count, stable, data->pagevec, req->wb_offset,
-			 &data->u.v4.res_count, &data->verf);
+	data->args.fh     = NFS_FH(inode);
+	data->args.offset = req_offset(req) + req->wb_offset;
+	data->args.pgbase = req->wb_offset;
+	data->args.count  = count;
+	data->args.stable = stable;
+	data->args.pages  = data->pagevec;
+	data->res.fattr   = &data->fattr;
+	data->res.count   = count;
+	data->res.verf    = &data->verf;
+	data->timestamp   = jiffies;
 
 	/* Set the initial flags for the task.  */
 	flags = (how & FLUSH_SYNC) ? 0 : RPC_TASK_ASYNC;
@@ -1458,37 +1439,30 @@
 }
 
 static void
-nfs4_commit_done(struct rpc_task *task)
-{
-	struct nfs_write_data *data = (struct nfs_write_data *) task->tk_calldata;
-	
-	process_lease(&data->u.v4.compound);
-	nfs_commit_done(task);
-}
-
-static void
 nfs4_proc_commit_setup(struct nfs_write_data *data, u64 start, u32 len, int how)
 {
 	struct rpc_task	*task = &data->task;
-	struct nfs4_compound *cp = &data->u.v4.compound;
 	struct rpc_message msg = {
-		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_COMPOUND],
-		.rpc_argp = cp,
-		.rpc_resp = cp,
+		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_COMMIT],
+		.rpc_argp = &data->args,
+		.rpc_resp = &data->res,
 		.rpc_cred = data->cred,
 	};	
 	struct inode *inode = data->inode;
 	int flags;
 	
-	nfs4_setup_compound(cp, data->u.v4.ops, NFS_SERVER(inode), "commit [async]");
-	nfs4_setup_putfh(cp, NFS_FH(inode));
-	nfs4_setup_commit(cp, start, len, &data->verf);
+	data->args.fh     = NFS_FH(data->inode);
+	data->args.offset = start;
+	data->args.count  = len;
+	data->res.count   = len;
+	data->res.fattr   = &data->fattr;
+	data->res.verf    = &data->verf;
 	
 	/* Set the initial flags for the task.  */
 	flags = (how & FLUSH_SYNC) ? 0 : RPC_TASK_ASYNC;
 
 	/* Finalize the task. */
-	rpc_init_task(task, NFS_CLIENT(inode), nfs4_commit_done, flags);
+	rpc_init_task(task, NFS_CLIENT(inode), nfs_commit_done, flags);
 	task->tk_calldata = data;
 	/* Release requests */
 	task->tk_release = nfs_commit_release;
diff -u --recursive --new-file linux-2.5.52-01-nfsv4_read/fs/nfs/nfs4xdr.c linux-2.5.52-02-nfsv4_write/fs/nfs/nfs4xdr.c
--- linux-2.5.52-01-nfsv4_read/fs/nfs/nfs4xdr.c	2002-12-17 15:27:29.000000000 +0100
+++ linux-2.5.52-02-nfsv4_write/fs/nfs/nfs4xdr.c	2002-12-17 15:27:47.000000000 +0100
@@ -87,6 +87,19 @@
 #define NFS4_dec_read_sz	compound_decode_hdr_maxsz + \
 				decode_putfh_maxsz + \
 				op_decode_hdr_maxsz + 2
+#define NFS4_enc_write_sz	compound_encode_hdr_maxsz + \
+				encode_putfh_maxsz + \
+				op_encode_hdr_maxsz + 8
+#define NFS4_dec_write_sz	compound_decode_hdr_maxsz + \
+				decode_putfh_maxsz + \
+				op_decode_hdr_maxsz + 4
+#define NFS4_enc_commit_sz	compound_encode_hdr_maxsz + \
+				encode_putfh_maxsz + \
+				op_encode_hdr_maxsz + 3
+#define NFS4_dec_commit_sz	compound_decode_hdr_maxsz + \
+				decode_putfh_maxsz + \
+				op_decode_hdr_maxsz + 2
+
 
 static struct {
 	unsigned int	mode;
@@ -332,14 +345,14 @@
 }
 
 static int
-encode_commit(struct xdr_stream *xdr, struct nfs4_commit *commit)
+encode_commit(struct xdr_stream *xdr, struct nfs_writeargs *args)
 {
 	uint32_t *p;
         
         RESERVE_SPACE(16);
         WRITE32(OP_COMMIT);
-        WRITE64(commit->co_start);
-        WRITE32(commit->co_len);
+        WRITE64(args->offset);
+        WRITE32(args->count);
 
         return 0;
 }
@@ -705,9 +718,8 @@
 }
 
 static int
-encode_write(struct xdr_stream *xdr, struct nfs4_write *write, struct rpc_rqst *req)
+encode_write(struct xdr_stream *xdr, struct nfs_writeargs *args)
 {
-	struct xdr_buf *sndbuf = &req->rq_snd_buf;
 	uint32_t *p;
 
 	RESERVE_SPACE(36);
@@ -716,11 +728,11 @@
 	WRITE32(0xffffffff);
 	WRITE32(0xffffffff);
 	WRITE32(0xffffffff);
-	WRITE64(write->wr_offset);
-	WRITE32(write->wr_stable_how);
-	WRITE32(write->wr_len);
+	WRITE64(args->offset);
+	WRITE32(args->stable);
+	WRITE32(args->count);
 
-	xdr_encode_pages(sndbuf, write->wr_pages, write->wr_pgbase, write->wr_len);
+	xdr_write_pages(xdr, args->pages, args->pgbase, args->count);
 
 	return 0;
 }
@@ -746,9 +758,6 @@
 		case OP_CLOSE:
 			status = encode_close(xdr, &cp->ops[i].u.close);
 			break;
-		case OP_COMMIT:
-			status = encode_commit(xdr, &cp->ops[i].u.commit);
-			break;
 		case OP_CREATE:
 			status = encode_create(xdr, &cp->ops[i].u.create);
 			break;
@@ -806,9 +815,6 @@
 		case OP_SETCLIENTID_CONFIRM:
 			status = encode_setclientid_confirm(xdr, cp->ops[i].u.setclientid_confirm);
 			break;
-		case OP_WRITE:
-			status = encode_write(xdr, &cp->ops[i].u.write, req);
-			break;
 		default:
 			BUG();
 		}
@@ -869,6 +875,49 @@
 	return status;
 }
 
+/*
+ * Encode a WRITE request
+ */
+static int
+nfs4_xdr_enc_write(struct rpc_rqst *req, uint32_t *p, struct nfs_writeargs *args)
+{
+	struct xdr_stream xdr;
+	struct compound_hdr hdr = {
+		.nops   = 2,
+	};
+	int status;
+
+	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
+	encode_compound_hdr(&xdr, &hdr);
+	status = encode_putfh(&xdr, args->fh);
+	if (status)
+		goto out;
+	status = encode_write(&xdr, args);
+out:
+	return status;
+}
+
+/*
+ * Encode a COMMIT request
+ */
+static int
+nfs4_xdr_enc_commit(struct rpc_rqst *req, uint32_t *p, struct nfs_writeargs *args)
+{
+	struct xdr_stream xdr;
+	struct compound_hdr hdr = {
+		.nops   = 2,
+	};
+	int status;
+
+	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
+	encode_compound_hdr(&xdr, &hdr);
+	status = encode_putfh(&xdr, args->fh);
+	if (status)
+		goto out;
+	status = encode_commit(&xdr, args);
+out:
+	return status;
+}
 
 /*
  * START OF "GENERIC" DECODE ROUTINES.
@@ -1022,7 +1071,7 @@
 }
 
 static int
-decode_commit(struct xdr_stream *xdr, struct nfs4_commit *commit)
+decode_commit(struct xdr_stream *xdr, struct nfs_writeres *res)
 {
 	uint32_t *p;
 	int status;
@@ -1031,7 +1080,7 @@
 	if (status)
 		return status;
 	READ_BUF(8);
-	COPYMEM(commit->co_verifier->verifier, 8);
+	COPYMEM(res->verf->verifier, 8);
 	return 0;
 }
 
@@ -1672,7 +1721,7 @@
 }
 
 static int
-decode_write(struct xdr_stream *xdr, struct nfs4_write *write)
+decode_write(struct xdr_stream *xdr, struct nfs_writeres *res)
 {
 	uint32_t *p;
 	int status;
@@ -1682,11 +1731,9 @@
 		return status;
 
 	READ_BUF(16);
-	READ32(*write->wr_bytes_written);
-	if (*write->wr_bytes_written > write->wr_len)
-		return -EIO;
-	READ32(write->wr_verf->committed);
-	COPYMEM(write->wr_verf->verifier, 8);
+	READ32(res->count);
+	READ32(res->verf->committed);
+	COPYMEM(res->verf->verifier, 8);
 	return 0;
 }
 
@@ -1726,9 +1773,6 @@
 		case OP_CLOSE:
 			status = decode_close(xdr, &op->u.close);
 			break;
-		case OP_COMMIT:
-			status = decode_commit(xdr, &op->u.commit);
-			break;
 		case OP_CREATE:
 			status = decode_create(xdr, &op->u.create);
 			break;
@@ -1786,9 +1830,6 @@
 		case OP_SETCLIENTID_CONFIRM:
 			status = decode_setclientid_confirm(xdr);
 			break;
-		case OP_WRITE:
-			status = decode_write(xdr, &op->u.write);
-			break;
 		default:
 			BUG();
 			return -EIO;
@@ -1848,6 +1889,56 @@
 	return status;
 }
 
+/*
+ * Decode WRITE response
+ */
+static int
+nfs4_xdr_dec_write(struct rpc_rqst *rqstp, uint32_t *p, struct nfs_writeres *res)
+{
+	struct xdr_stream xdr;
+	struct compound_hdr hdr;
+	int status;
+
+	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
+	status = decode_compound_hdr(&xdr, &hdr);
+	if (status)
+		goto out;
+	status = decode_putfh(&xdr);
+	if (status)
+		goto out;
+	status = decode_write(&xdr, res);
+	if (!status)
+		status = -nfs_stat_to_errno(hdr.status);
+	if (!status)
+		status = res->count;
+out:
+	return status;
+}
+
+/*
+ * Decode COMMIT response
+ */
+static int
+nfs4_xdr_dec_commit(struct rpc_rqst *rqstp, uint32_t *p, struct nfs_writeres *res)
+{
+	struct xdr_stream xdr;
+	struct compound_hdr hdr;
+	int status;
+
+	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
+	status = decode_compound_hdr(&xdr, &hdr);
+	if (status)
+		goto out;
+	status = decode_putfh(&xdr);
+	if (status)
+		goto out;
+	status = decode_commit(&xdr, res);
+	if (!status)
+		status = -nfs_stat_to_errno(hdr.status);
+out:
+	return status;
+}
+
 uint32_t *
 nfs4_decode_dirent(uint32_t *p, struct nfs_entry *entry, int plus)
 {
@@ -1901,6 +1992,8 @@
 struct rpc_procinfo	nfs4_procedures[] = {
   PROC(COMPOUND,	enc_compound,	dec_compound),
   PROC(READ,		enc_read,	dec_read),
+  PROC(WRITE,		enc_write,	dec_write),
+  PROC(COMMIT,		enc_commit,	dec_commit),
 };
 
 struct rpc_version		nfs_version4 = {
diff -u --recursive --new-file linux-2.5.52-01-nfsv4_read/fs/nfs/proc.c linux-2.5.52-02-nfsv4_write/fs/nfs/proc.c
--- linux-2.5.52-01-nfsv4_read/fs/nfs/proc.c	2002-12-17 15:27:29.000000000 +0100
+++ linux-2.5.52-02-nfsv4_write/fs/nfs/proc.c	2002-12-17 15:27:47.000000000 +0100
@@ -557,14 +557,6 @@
 }
 
 static void
-nfs_write_done(struct rpc_task *task)
-{
-	struct nfs_write_data *data = (struct nfs_write_data *) task->tk_calldata;
-	nfs_writeback_done(task, data->u.v3.args.stable,
-			   data->u.v3.args.count, data->u.v3.res.count);
-}
-
-static void
 nfs_proc_write_setup(struct nfs_write_data *data, unsigned int count, int how)
 {
 	struct rpc_task		*task = &data->task;
@@ -573,29 +565,29 @@
 	int			flags;
 	struct rpc_message	msg = {
 		.rpc_proc	= &nfs_procedures[NFSPROC_WRITE],
-		.rpc_argp	= &data->u.v3.args,
-		.rpc_resp	= &data->u.v3.res,
+		.rpc_argp	= &data->args,
+		.rpc_resp	= &data->res,
 		.rpc_cred	= data->cred,
 	};
 
 	/* Note: NFSv2 ignores @stable and always uses NFS_FILE_SYNC */
 	
 	req = nfs_list_entry(data->pages.next);
-	data->u.v3.args.fh     = NFS_FH(inode);
-	data->u.v3.args.offset = req_offset(req) + req->wb_offset;
-	data->u.v3.args.pgbase = req->wb_offset;
-	data->u.v3.args.count  = count;
-	data->u.v3.args.stable = NFS_FILE_SYNC;
-	data->u.v3.args.pages  = data->pagevec;
-	data->u.v3.res.fattr   = &data->fattr;
-	data->u.v3.res.count   = count;
-	data->u.v3.res.verf    = &data->verf;
+	data->args.fh     = NFS_FH(inode);
+	data->args.offset = req_offset(req) + req->wb_offset;
+	data->args.pgbase = req->wb_offset;
+	data->args.count  = count;
+	data->args.stable = NFS_FILE_SYNC;
+	data->args.pages  = data->pagevec;
+	data->res.fattr   = &data->fattr;
+	data->res.count   = count;
+	data->res.verf    = &data->verf;
 
 	/* Set the initial flags for the task.  */
 	flags = (how & FLUSH_SYNC) ? 0 : RPC_TASK_ASYNC;
 
 	/* Finalize the task. */
-	rpc_init_task(task, NFS_CLIENT(inode), nfs_write_done, flags);
+	rpc_init_task(task, NFS_CLIENT(inode), nfs_writeback_done, flags);
 	task->tk_calldata = data;
 	/* Release requests */
 	task->tk_release = nfs_writedata_release;
diff -u --recursive --new-file linux-2.5.52-01-nfsv4_read/fs/nfs/write.c linux-2.5.52-02-nfsv4_write/fs/nfs/write.c
--- linux-2.5.52-01-nfsv4_read/fs/nfs/write.c	2002-12-14 18:42:09.000000000 +0100
+++ linux-2.5.52-02-nfsv4_write/fs/nfs/write.c	2002-12-17 15:27:47.000000000 +0100
@@ -841,10 +841,11 @@
  * This function is called when the WRITE call is complete.
  */
 void
-nfs_writeback_done(struct rpc_task *task, int stable,
-		   unsigned int arg_count, unsigned int res_count)
+nfs_writeback_done(struct rpc_task *task)
 {
 	struct nfs_write_data	*data = (struct nfs_write_data *) task->tk_calldata;
+	struct nfs_writeargs	*argp = &data->args;
+	struct nfs_writeres	*resp = &data->res;
 	struct inode		*inode = data->inode;
 	struct nfs_page		*req;
 	struct page		*page;
@@ -853,7 +854,7 @@
 		task->tk_pid, task->tk_status);
 
 	/* We can't handle that yet but we check for it nevertheless */
-	if (res_count < arg_count && task->tk_status >= 0) {
+	if (resp->count < argp->count && task->tk_status >= 0) {
 		static unsigned long    complain;
 		if (time_before(complain, jiffies)) {
 			printk(KERN_WARNING
@@ -865,7 +866,7 @@
 		task->tk_status = -EIO;
 	}
 #if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
-	if (data->verf.committed < stable && task->tk_status >= 0) {
+	if (data->verf.committed < argp->stable && task->tk_status >= 0) {
 		/* We tried a write call, but the server did not
 		 * commit data to stable storage even though we
 		 * requested it.
@@ -880,7 +881,7 @@
 			dprintk("NFS: faulty NFS server %s:"
 				" (committed = %d) != (stable = %d)\n",
 				NFS_SERVER(inode)->hostname,
-				data->verf.committed, stable);
+				data->verf.committed, argp->stable);
 			complain = jiffies + 300 * HZ;
 		}
 	}
@@ -917,7 +918,7 @@
 		end_page_writeback(page);
 
 #if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
-		if (stable != NFS_UNSTABLE || data->verf.committed == NFS_FILE_SYNC) {
+		if (argp->stable != NFS_UNSTABLE || data->verf.committed == NFS_FILE_SYNC) {
 			nfs_inode_remove_request(req);
 			dprintk(" OK\n");
 			goto next;
diff -u --recursive --new-file linux-2.5.52-01-nfsv4_read/include/linux/nfs4.h linux-2.5.52-02-nfsv4_write/include/linux/nfs4.h
--- linux-2.5.52-01-nfsv4_read/include/linux/nfs4.h	2002-12-17 15:27:29.000000000 +0100
+++ linux-2.5.52-02-nfsv4_write/include/linux/nfs4.h	2002-12-17 15:27:47.000000000 +0100
@@ -204,6 +204,8 @@
 	NFSPROC4_CLNT_NULL = 0,		/* Unused */
 	NFSPROC4_CLNT_COMPOUND,		/* Soon to be unused */
 	NFSPROC4_CLNT_READ,
+	NFSPROC4_CLNT_WRITE,
+	NFSPROC4_CLNT_COMMIT,
 };
 
 #endif
diff -u --recursive --new-file linux-2.5.52-01-nfsv4_read/include/linux/nfs_fs.h linux-2.5.52-02-nfsv4_write/include/linux/nfs_fs.h
--- linux-2.5.52-01-nfsv4_read/include/linux/nfs_fs.h	2002-12-17 15:27:29.000000000 +0100
+++ linux-2.5.52-02-nfsv4_write/include/linux/nfs_fs.h	2002-12-17 15:27:47.000000000 +0100
@@ -295,8 +295,7 @@
 extern int  nfs_writepages(struct address_space *, struct writeback_control *);
 extern int  nfs_flush_incompatible(struct file *file, struct page *page);
 extern int  nfs_updatepage(struct file *, struct page *, unsigned int, unsigned int);
-extern void nfs_writeback_done(struct rpc_task *task, int stable,
-			       unsigned int arg_count, unsigned int res_count);
+extern void nfs_writeback_done(struct rpc_task *task);
 extern void nfs_writedata_release(struct rpc_task *task);
 
 #if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
diff -u --recursive --new-file linux-2.5.52-01-nfsv4_read/include/linux/nfs_xdr.h linux-2.5.52-02-nfsv4_write/include/linux/nfs_xdr.h
--- linux-2.5.52-01-nfsv4_read/include/linux/nfs_xdr.h	2002-12-17 15:27:29.000000000 +0100
+++ linux-2.5.52-02-nfsv4_write/include/linux/nfs_xdr.h	2002-12-17 15:27:47.000000000 +0100
@@ -346,12 +346,6 @@
 	u32				cl_seqid;          /* request */
 };
 
-struct nfs4_commit {
-	u64				co_start;          /* request */
-	u32				co_len;            /* request */
-	struct nfs_writeverf *		co_verifier;       /* response */
-};
-
 struct nfs4_create {
 	u32				cr_ftype;          /* request */
 	union {                                            /* request */
@@ -467,22 +461,11 @@
 	struct nfs4_client *		sc_state;	  /* response */
 };
 
-struct nfs4_write {
-	u64				wr_offset;        /* request */
-	u32				wr_stable_how;    /* request */
-	u32				wr_len;           /* request */
-	u32 *				wr_bytes_written; /* response */
-	struct nfs_writeverf *		wr_verf;          /* response */
-	struct page **			wr_pages;   /* zero-copy data */
-	unsigned int			wr_pgbase;  /* zero-copy data */
-};
-
 struct nfs4_op {
 	u32				opnum;
 	union {
 		struct nfs4_access	access;
 		struct nfs4_close	close;
-		struct nfs4_commit	commit;
 		struct nfs4_create	create;
 		struct nfs4_getattr	getattr;
 		struct nfs4_getfh	getfh;
@@ -499,7 +482,6 @@
 		struct nfs4_setattr	setattr;
 		struct nfs4_setclientid	setclientid;
 		struct nfs4_client *	setclientid_confirm;
-		struct nfs4_write	write;
 	} u;
 };
 
@@ -553,21 +535,11 @@
 	struct nfs_writeverf	verf;
 	struct list_head	pages;		/* Coalesced requests we wish to flush */
 	struct page		*pagevec[NFS_WRITE_MAXIOV];
-	union {
-		struct {
-			struct nfs_writeargs	args;		/* argument struct */
-			struct nfs_writeres	res;		/* result struct */
-		} v3;
+	struct nfs_writeargs	args;		/* argument struct */
+	struct nfs_writeres	res;		/* result struct */
 #ifdef CONFIG_NFS_V4
-		struct {
-			struct nfs4_compound  compound;
-			struct nfs4_op        ops[3];
-			u32                   arg_count;
-			u32                   arg_stable;
-			u32                   res_count;
-		} v4;
+	unsigned long		timestamp;	/* For lease renewal */
 #endif
-	} u;
 };
 
 /*


-------------------------------------------------------
This sf.net email is sponsored by:
With Great Power, Comes Great Responsibility 
Learn to use your power at OSDN's High Performance Computing Channel
http://hpc.devchannel.org/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
