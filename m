From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: [PATCH] Clean up NFSv4 READ xdr path
Date: Tue, 17 Dec 2002 19:14:47 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15871.27031.103107.327144@charged.uio.no>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS maillist <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18OMF8-00038Q-00
	for <nfs@lists.sourceforge.net>; Tue, 17 Dec 2002 10:14:58 -0800
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


The following patch creates a clean XDR path for the NFSv4 read requests
instead of routing through encode_compound()/decode_compound().
This eliminates the intermediate step of setting up a struct nfs4_compound
before proceeding to XDR encoding, and removes the large 'switch()'
statements from the codepath altogether.

Cheers,
  Trond


diff -u --recursive --new-file linux-2.5.52/fs/nfs/nfs3proc.c linux-2.5.52-01-nfsv4_read/fs/nfs/nfs3proc.c
--- linux-2.5.52/fs/nfs/nfs3proc.c	2002-11-13 15:59:23.000000000 +0100
+++ linux-2.5.52-01-nfsv4_read/fs/nfs/nfs3proc.c	2002-12-17 15:27:29.000000000 +0100
@@ -685,11 +685,10 @@
 static void
 nfs3_read_done(struct rpc_task *task)
 {
-	struct nfs_read_data *data = (struct nfs_read_data *) task->tk_calldata;
-
 	if (nfs3_async_handle_jukebox(task))
 		return;
-	nfs_readpage_result(task, data->u.v3.res.count, data->u.v3.res.eof);
+	/* Call back common NFS readpage processing */
+	nfs_readpage_result(task);
 }
 
 static void
@@ -701,20 +700,20 @@
 	int			flags;
 	struct rpc_message	msg = {
 		.rpc_proc	= &nfs3_procedures[NFS3PROC_READ],
-		.rpc_argp	= &data->u.v3.args,
-		.rpc_resp	= &data->u.v3.res,
+		.rpc_argp	= &data->args,
+		.rpc_resp	= &data->res,
 		.rpc_cred	= data->cred,
 	};
 	
 	req = nfs_list_entry(data->pages.next);
-	data->u.v3.args.fh     = NFS_FH(inode);
-	data->u.v3.args.offset = req_offset(req) + req->wb_offset;
-	data->u.v3.args.pgbase = req->wb_offset;
-	data->u.v3.args.pages  = data->pagevec;
-	data->u.v3.args.count  = count;
-	data->u.v3.res.fattr   = &data->fattr;
-	data->u.v3.res.count   = count;
-	data->u.v3.res.eof     = 0;
+	data->args.fh     = NFS_FH(inode);
+	data->args.offset = req_offset(req) + req->wb_offset;
+	data->args.pgbase = req->wb_offset;
+	data->args.pages  = data->pagevec;
+	data->args.count  = count;
+	data->res.fattr   = &data->fattr;
+	data->res.count   = count;
+	data->res.eof     = 0;
 	
 	/* N.B. Do we need to test? Never called for swapfile inode */
 	flags = RPC_TASK_ASYNC | (IS_SWAPFILE(inode)? NFS_RPC_SWAPFLAGS : 0);
diff -u --recursive --new-file linux-2.5.52/fs/nfs/nfs4proc.c linux-2.5.52-01-nfsv4_read/fs/nfs/nfs4proc.c
--- linux-2.5.52/fs/nfs/nfs4proc.c	2002-11-23 04:16:55.000000000 +0100
+++ linux-2.5.52-01-nfsv4_read/fs/nfs/nfs4proc.c	2002-12-17 15:27:29.000000000 +0100
@@ -402,23 +402,6 @@
 }
 
 static void
-nfs4_setup_read(struct nfs4_compound *cp, u64 offset, u32 length,
-		struct page **pages, unsigned int pgbase, u32 *eofp, u32 *bytes_read)
-{
-	struct nfs4_read *read = GET_OP(cp, read);
-
-	read->rd_offset = offset;
-	read->rd_length = length;
-	read->rd_pages = pages;
-	read->rd_pgbase = pgbase;
-	read->rd_eof = eofp;
-	read->rd_bytes_read = bytes_read;
-
-	OPNUM(cp) = OP_READ;
-	cp->req_nops++;
-}
-
-static void
 nfs4_setup_readdir(struct nfs4_compound *cp, u64 cookie, u32 *verifier,
 		     struct page **pages, unsigned int bufsize, struct dentry *dentry)
 {
@@ -613,11 +596,18 @@
 	cp->req_nops++;
 }
 
+static void
+renew_lease(struct nfs_server *server, unsigned long timestamp)
+{
+	spin_lock(&renew_lock);
+	if (time_before(server->last_renewal,timestamp))
+		server->last_renewal = timestamp;
+	spin_unlock(&renew_lock);
+}
+
 static inline void
 process_lease(struct nfs4_compound *cp)
 {
-	struct nfs_server *server;
-	
         /*
          * Generic lease processing: If this operation contains a
 	 * lease-renewing operation, and it succeeded, update the RENEW time
@@ -634,13 +624,8 @@
          */
 	if (!cp->renew_index)
 		return;
-	if (!cp->toplevel_status || cp->resp_nops > cp->renew_index) {
-		server = cp->server;
-		spin_lock(&renew_lock);
-		if (server->last_renewal < cp->timestamp)
-			server->last_renewal = cp->timestamp;
-		spin_unlock(&renew_lock);
-	}
+	if (!cp->toplevel_status || cp->resp_nops > cp->renew_index)
+		renew_lease(cp->server, cp->timestamp);
 }
 
 static int
@@ -1003,20 +988,35 @@
 	       unsigned int base, unsigned int count,
 	       struct page *page, int *eofp)
 {
-	u64			offset = page_offset(page) + base;
-	struct nfs4_compound	compound;
-	struct nfs4_op		ops[2];
-	u32			bytes_read;
-	int			status;
+	struct nfs_server *server = NFS_SERVER(inode);
+	uint64_t offset = page_offset(page) + base;
+	struct nfs_readargs arg = {
+		.fh		= NFS_FH(inode),
+		.offset		= offset,
+		.count		= count,
+		.pgbase		= base,
+		.pages		= &page,
+	};
+	struct nfs_readres res = {
+		.fattr		= fattr,
+		.count		= count,
+	};
+	struct rpc_message msg = {
+		.rpc_proc	= &nfs4_procedures[NFSPROC4_CLNT_READ],
+		.rpc_argp	= &arg,
+		.rpc_resp	= &res,
+		.rpc_cred	= cred,
+	};
+	unsigned long timestamp = jiffies;
+	int status;
 
+	dprintk("NFS call  read %d @ %Ld\n", count, (long long)offset);
 	fattr->valid = 0;
-	nfs4_setup_compound(&compound, ops, NFS_SERVER(inode), "read [sync]");
-	nfs4_setup_putfh(&compound, NFS_FH(inode));
-	nfs4_setup_read(&compound, offset, count, &page, base, eofp, &bytes_read);
-	status = nfs4_call_compound(&compound, cred, 0);
-
-	if (status >= 0)
-		status = bytes_read;
+	status = rpc_call_sync(server->client, &msg, flags);
+	if (!status)
+		renew_lease(server, timestamp);
+	dprintk("NFS reply read: %d\n", status);
+	*eofp = res.eof;
 	return status;
 }
 
@@ -1363,31 +1363,35 @@
 {
 	struct nfs_read_data *data = (struct nfs_read_data *) task->tk_calldata;
 
-	process_lease(&data->u.v4.compound);
-	nfs_readpage_result(task, data->u.v4.res_count, data->u.v4.res_eof);
+	if (task->tk_status > 0)
+		renew_lease(NFS_SERVER(data->inode), data->timestamp);
+	/* Call back common NFS readpage processing */
+	nfs_readpage_result(task);
 }
 
 static void
 nfs4_proc_read_setup(struct nfs_read_data *data, unsigned int count)
 {
 	struct rpc_task	*task = &data->task;
-	struct nfs4_compound *cp = &data->u.v4.compound;
 	struct rpc_message msg = {
-		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_COMPOUND],
-		.rpc_argp = cp,
-		.rpc_resp = cp,
+		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_READ],
+		.rpc_argp = &data->args,
+		.rpc_resp = &data->res,
 		.rpc_cred = data->cred,
 	};
 	struct inode *inode = data->inode;
 	struct nfs_page *req = nfs_list_entry(data->pages.next);
 	int flags;
 
-	nfs4_setup_compound(cp, data->u.v4.ops, NFS_SERVER(inode), "read [async]");
-	nfs4_setup_putfh(cp, NFS_FH(inode));
-	nfs4_setup_read(cp, req_offset(req) + req->wb_offset,
-			count, data->pagevec, req->wb_offset,
-			&data->u.v4.res_eof,
-			&data->u.v4.res_count);
+	data->args.fh     = NFS_FH(inode);
+	data->args.offset = req_offset(req) + req->wb_offset;
+	data->args.pgbase = req->wb_offset;
+	data->args.pages  = data->pagevec;
+	data->args.count  = count;
+	data->res.fattr   = &data->fattr;
+	data->res.count   = count;
+	data->res.eof     = 0;
+	data->timestamp   = jiffies;
 
 	/* N.B. Do we need to test? Never called for swapfile inode */
 	flags = RPC_TASK_ASYNC | (IS_SWAPFILE(inode)? NFS_RPC_SWAPFLAGS : 0);
diff -u --recursive --new-file linux-2.5.52/fs/nfs/nfs4xdr.c linux-2.5.52-01-nfsv4_read/fs/nfs/nfs4xdr.c
--- linux-2.5.52/fs/nfs/nfs4xdr.c	2002-11-23 04:16:55.000000000 +0100
+++ linux-2.5.52-01-nfsv4_read/fs/nfs/nfs4xdr.c	2002-12-17 15:27:29.000000000 +0100
@@ -64,8 +64,29 @@
 
 extern int			nfs_stat_to_errno(int);
 
+/* NFSv4 COMPOUND tags are only wanted for debugging purposes */
+#ifdef DEBUG
+#define NFS4_MAXTAGLEN		20
+#else
+#define NFS4_MAXTAGLEN		0
+#endif
+
+#define compound_encode_hdr_maxsz	3 + (NFS4_MAXTAGLEN >> 2)
+#define compound_decode_hdr_maxsz	2 + (NFS4_MAXTAGLEN >> 2)
+#define op_encode_hdr_maxsz	1
+#define op_decode_hdr_maxsz	2
+#define encode_putfh_maxsz	op_encode_hdr_maxsz + 1 + \
+				(NFS4_FHSIZE >> 2)
+#define decode_putfh_maxsz	op_decode_hdr_maxsz
+
 #define NFS4_enc_compound_sz	1024  /* XXX: large enough? */
 #define NFS4_dec_compound_sz	1024  /* XXX: large enough? */
+#define NFS4_enc_read_sz	compound_encode_hdr_maxsz + \
+				encode_putfh_maxsz + \
+				op_encode_hdr_maxsz + 7
+#define NFS4_dec_read_sz	compound_decode_hdr_maxsz + \
+				decode_putfh_maxsz + \
+				op_decode_hdr_maxsz + 2
 
 static struct {
 	unsigned int	mode;
@@ -131,6 +152,7 @@
 	uint32_t *p;
 
 	dprintk("encode_compound: tag=%.*s\n", (int)hdr->taglen, hdr->tag);
+	BUG_ON(hdr->taglen > NFS4_MAXTAGLEN);
 	RESERVE_SPACE(12+XDR_QUADLEN(hdr->taglen));
 	WRITE32(hdr->taglen);
 	WRITEMEM(hdr->tag, hdr->taglen);
@@ -472,15 +494,15 @@
 }
 
 static int
-encode_putfh(struct xdr_stream *xdr, struct nfs4_putfh *putfh)
+encode_putfh(struct xdr_stream *xdr, struct nfs_fh *fh)
 {
-	int len = putfh->pf_fhandle->size;
+	int len = fh->size;
 	uint32_t *p;
 
 	RESERVE_SPACE(8 + len);
 	WRITE32(OP_PUTFH);
 	WRITE32(len);
-	WRITEMEM(putfh->pf_fhandle->data, len);
+	WRITEMEM(fh->data, len);
 
 	return 0;
 }
@@ -497,10 +519,8 @@
 }
 
 static int
-encode_read(struct xdr_stream *xdr, struct nfs4_read *read, struct rpc_rqst *req)
+encode_read(struct xdr_stream *xdr, struct nfs_readargs *args)
 {
-	struct rpc_auth	*auth = req->rq_task->tk_auth;
-	int		replen;
 	uint32_t *p;
 
 	RESERVE_SPACE(32);
@@ -509,16 +529,8 @@
 	WRITE32(0);
 	WRITE32(0);
 	WRITE32(0);
-	WRITE64(read->rd_offset);
-	WRITE32(read->rd_length);
-
-	/* set up reply iovec
-	 *    toplevel status + taglen + rescount + OP_PUTFH + status
-	 *       + OP_READ + status + eof + datalen = 9
-	 */
-	replen = (RPC_REPHDRSIZE + auth->au_rslack + 9) << 2;
-	xdr_inline_pages(&req->rq_rcv_buf, replen,
-			 read->rd_pages, read->rd_pgbase, read->rd_length);
+	WRITE64(args->offset);
+	WRITE32(args->count);
 
 	return 0;
 }
@@ -759,14 +771,11 @@
 			status = encode_open_confirm(xdr, &cp->ops[i].u.open_confirm);
 			break;
 		case OP_PUTFH:
-			status = encode_putfh(xdr, &cp->ops[i].u.putfh);
+			status = encode_putfh(xdr, cp->ops[i].u.putfh.pf_fhandle);
 			break;
 		case OP_PUTROOTFH:
 			status = encode_putrootfh(xdr);
 			break;
-		case OP_READ:
-			status = encode_read(xdr, &cp->ops[i].u.read, req);
-			break;
 		case OP_READDIR:
 			status = encode_readdir(xdr, &cp->ops[i].u.readdir, req);
 			break;
@@ -829,6 +838,37 @@
 	return status;
 }
 
+/*
+ * Encode a READ request
+ */
+static int
+nfs4_xdr_enc_read(struct rpc_rqst *req, uint32_t *p, struct nfs_readargs *args)
+{
+	struct rpc_auth	*auth = req->rq_task->tk_auth;
+	struct xdr_stream xdr;
+	struct compound_hdr hdr = {
+		.nops	= 2,
+	};
+	int replen, status;
+
+	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
+	encode_compound_hdr(&xdr, &hdr);
+	status = encode_putfh(&xdr, args->fh);
+	if (status)
+		goto out;
+	status = encode_read(&xdr, args);
+
+	/* set up reply iovec
+	 *    toplevel status + taglen=0 + rescount + OP_PUTFH + status
+	 *       + OP_READ + status + eof + datalen = 9
+	 */
+	replen = (RPC_REPHDRSIZE + auth->au_rslack + NFS4_dec_read_sz) << 2;
+	xdr_inline_pages(&req->rq_rcv_buf, replen,
+			 args->pages, args->pgbase, args->count);
+out:
+	return status;
+}
+
 
 /*
  * START OF "GENERIC" DECODE ROUTINES.
@@ -1368,7 +1408,7 @@
 }
 
 static int
-decode_read(struct xdr_stream *xdr, struct rpc_rqst *req, struct nfs4_read *read)
+decode_read(struct xdr_stream *xdr, struct rpc_rqst *req, struct nfs_readres *res)
 {
 	struct iovec *iov = req->rq_rvec;
 	uint32_t *p;
@@ -1382,14 +1422,6 @@
 	READ32(eof);
 	READ32(count);
 	hdrlen = (u8 *) p - (u8 *) iov->iov_base;
-	if (iov->iov_len < hdrlen) {
-		printk(KERN_WARNING "NFS: READ reply header overflowed:"
-				"length %u > %Zu\n", hdrlen, iov->iov_len);
-		return -errno_NFSERR_IO;
-	} else if (iov->iov_len != hdrlen) {
-		dprintk("NFS: READ header is short. iovec will be shifted.\n");
-		xdr_shift_buf(&req->rq_rcv_buf, iov->iov_len - hdrlen);
-	}
 	recvd = req->rq_received - hdrlen;
 	if (count > recvd) {
 		printk(KERN_WARNING "NFS: server cheating in read reply: "
@@ -1397,9 +1429,9 @@
 		count = recvd;
 		eof = 0;
 	}
-	if (read->rd_eof)
-		*read->rd_eof = eof;
-	*read->rd_bytes_read = count;
+	xdr_read_pages(xdr, count);
+	res->eof = eof;
+	res->count = count;
 	return 0;
 }
 
@@ -1421,17 +1453,10 @@
 	COPYMEM(readdir->rd_resp_verifier, 8);
 
 	hdrlen = (char *) p - (char *) iov->iov_base;
-	if (iov->iov_len < hdrlen) {
-		printk(KERN_WARNING "NFS: READDIR reply header overflowed:"
-				"length %d > %Zu\n", hdrlen, iov->iov_len);
-		return -EIO;
-	} else if (iov->iov_len != hdrlen) {
-		dprintk("NFS: READDIR header is short. iovec will be shifted.\n");
-		xdr_shift_buf(rcvbuf, iov->iov_len - hdrlen);
-	}
 	recvd = req->rq_received - hdrlen;
 	if (pglen > recvd)
 		pglen = recvd;
+	xdr_read_pages(xdr, pglen);
 
 	BUG_ON(pglen + readdir->rd_pgbase > PAGE_CACHE_SIZE);
 	p   = (uint32_t *) kmap(page);
@@ -1731,9 +1756,6 @@
 		case OP_PUTROOTFH:
 			status = decode_putrootfh(xdr);
 			break;
-		case OP_READ:
-			status = decode_read(xdr, req, &op->u.read);
-			break;
 		case OP_READDIR:
 			status = decode_readdir(xdr, req, &op->u.readdir);
 			break;
@@ -1802,6 +1824,30 @@
 	return status;
 }
 
+/*
+ * Decode Read response
+ */
+static int
+nfs4_xdr_dec_read(struct rpc_rqst *rqstp, uint32_t *p, struct nfs_readres *res)
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
+	status = decode_read(&xdr, rqstp, res);
+	if (!status)
+		status = -nfs_stat_to_errno(hdr.status);
+out:
+	return status;
+}
+
 uint32_t *
 nfs4_decode_dirent(uint32_t *p, struct nfs_entry *entry, int plus)
 {
@@ -1854,6 +1900,7 @@
 
 struct rpc_procinfo	nfs4_procedures[] = {
   PROC(COMPOUND,	enc_compound,	dec_compound),
+  PROC(READ,		enc_read,	dec_read),
 };
 
 struct rpc_version		nfs_version4 = {
diff -u --recursive --new-file linux-2.5.52/fs/nfs/proc.c linux-2.5.52-01-nfsv4_read/fs/nfs/proc.c
--- linux-2.5.52/fs/nfs/proc.c	2002-11-13 15:57:48.000000000 +0100
+++ linux-2.5.52-01-nfsv4_read/fs/nfs/proc.c	2002-12-17 15:27:29.000000000 +0100
@@ -521,13 +521,6 @@
 extern u32 * nfs_decode_dirent(u32 *, struct nfs_entry *, int);
 
 static void
-nfs_read_done(struct rpc_task *task)
-{
-	struct nfs_read_data *data = (struct nfs_read_data *) task->tk_calldata;
-	nfs_readpage_result(task, data->u.v3.res.count, data->u.v3.res.eof);
-}
-
-static void
 nfs_proc_read_setup(struct nfs_read_data *data, unsigned int count)
 {
 	struct rpc_task		*task = &data->task;
@@ -536,26 +529,26 @@
 	int			flags;
 	struct rpc_message	msg = {
 		.rpc_proc	= &nfs_procedures[NFSPROC_READ],
-		.rpc_argp	= &data->u.v3.args,
-		.rpc_resp	= &data->u.v3.res,
+		.rpc_argp	= &data->args,
+		.rpc_resp	= &data->res,
 		.rpc_cred	= data->cred,
 	};
 	
 	req = nfs_list_entry(data->pages.next);
-	data->u.v3.args.fh     = NFS_FH(inode);
-	data->u.v3.args.offset = req_offset(req) + req->wb_offset;
-	data->u.v3.args.pgbase = req->wb_offset;
-	data->u.v3.args.pages  = data->pagevec;
-	data->u.v3.args.count  = count;
-	data->u.v3.res.fattr   = &data->fattr;
-	data->u.v3.res.count   = count;
-	data->u.v3.res.eof     = 0;
+	data->args.fh     = NFS_FH(inode);
+	data->args.offset = req_offset(req) + req->wb_offset;
+	data->args.pgbase = req->wb_offset;
+	data->args.pages  = data->pagevec;
+	data->args.count  = count;
+	data->res.fattr   = &data->fattr;
+	data->res.count   = count;
+	data->res.eof     = 0;
 	
 	/* N.B. Do we need to test? Never called for swapfile inode */
 	flags = RPC_TASK_ASYNC | (IS_SWAPFILE(inode)? NFS_RPC_SWAPFLAGS : 0);
 
 	/* Finalize the task. */
-	rpc_init_task(task, NFS_CLIENT(inode), nfs_read_done, flags);
+	rpc_init_task(task, NFS_CLIENT(inode), nfs_readpage_result, flags);
 	task->tk_calldata = data;
 	/* Release requests */
 	task->tk_release = nfs_readdata_release;
diff -u --recursive --new-file linux-2.5.52/fs/nfs/read.c linux-2.5.52-01-nfsv4_read/fs/nfs/read.c
--- linux-2.5.52/fs/nfs/read.c	2002-11-10 05:37:59.000000000 +0100
+++ linux-2.5.52-01-nfsv4_read/fs/nfs/read.c	2002-12-17 15:27:29.000000000 +0100
@@ -255,11 +255,12 @@
  * received or some error occurred (timeout or socket shutdown).
  */
 void
-nfs_readpage_result(struct rpc_task *task, unsigned int count, int eof)
+nfs_readpage_result(struct rpc_task *task)
 {
 	struct nfs_read_data	*data = (struct nfs_read_data *) task->tk_calldata;
 	struct inode		*inode = data->inode;
 	struct nfs_fattr	*fattr = &data->fattr;
+	unsigned int count = data->res.count;
 
 	dprintk("NFS: %4d nfs_readpage_result, (status %d)\n",
 		task->tk_pid, task->tk_status);
@@ -279,7 +280,7 @@
 							req->wb_bytes - count);
 				kunmap(page);
 
-				if (eof ||
+				if (data->res.eof ||
 				    ((fattr->valid & NFS_ATTR_FATTR) &&
 				     ((req_offset(req) + req->wb_offset + count) >= fattr->size)))
 					SetPageUptodate(page);
diff -u --recursive --new-file linux-2.5.52/include/linux/nfs4.h linux-2.5.52-01-nfsv4_read/include/linux/nfs4.h
--- linux-2.5.52/include/linux/nfs4.h	2002-11-23 04:16:55.000000000 +0100
+++ linux-2.5.52-01-nfsv4_read/include/linux/nfs4.h	2002-12-17 15:27:29.000000000 +0100
@@ -203,6 +203,7 @@
 enum {
 	NFSPROC4_CLNT_NULL = 0,		/* Unused */
 	NFSPROC4_CLNT_COMPOUND,		/* Soon to be unused */
+	NFSPROC4_CLNT_READ,
 };
 
 #endif
diff -u --recursive --new-file linux-2.5.52/include/linux/nfs_fs.h linux-2.5.52-01-nfsv4_read/include/linux/nfs_fs.h
--- linux-2.5.52/include/linux/nfs_fs.h	2002-12-14 18:42:09.000000000 +0100
+++ linux-2.5.52-01-nfsv4_read/include/linux/nfs_fs.h	2002-12-17 15:27:29.000000000 +0100
@@ -369,7 +369,7 @@
 extern int  nfs_readpages(struct file *, struct address_space *,
 		struct list_head *, unsigned);
 extern int  nfs_pagein_list(struct list_head *, int);
-extern void nfs_readpage_result(struct rpc_task *, unsigned int count, int eof);
+extern void nfs_readpage_result(struct rpc_task *);
 extern void nfs_readdata_release(struct rpc_task *);
 
 /*
diff -u --recursive --new-file linux-2.5.52/include/linux/nfs_xdr.h linux-2.5.52-01-nfsv4_read/include/linux/nfs_xdr.h
--- linux-2.5.52/include/linux/nfs_xdr.h	2002-11-23 04:16:55.000000000 +0100
+++ linux-2.5.52-01-nfsv4_read/include/linux/nfs_xdr.h	2002-12-17 15:27:29.000000000 +0100
@@ -422,15 +422,6 @@
 	struct nfs_fh *			pf_fhandle;       /* request */
 };
 
-struct nfs4_read {
-	u64				rd_offset;        /* request */
-	u32				rd_length;        /* request */
-	u32				*rd_eof;          /* response */
-	u32				*rd_bytes_read;   /* response */
-	struct page **			rd_pages;   /* zero-copy data */
-	unsigned int			rd_pgbase;  /* zero-copy data */
-};
-
 struct nfs4_readdir {
 	u64				rd_cookie;        /* request */
 	nfs4_verifier			rd_req_verifier;  /* request */
@@ -500,7 +491,6 @@
 		struct nfs4_open	open;
 		struct nfs4_open_confirm open_confirm;
 		struct nfs4_putfh	putfh;
-		struct nfs4_read	read;
 		struct nfs4_readdir	readdir;
 		struct nfs4_readlink	readlink;
 		struct nfs4_remove	remove;
@@ -548,20 +538,11 @@
 	struct nfs_fattr	fattr;	/* fattr storage */
 	struct list_head	pages;	/* Coalesced read requests */
 	struct page		*pagevec[NFS_READ_MAXIOV];
-	union {
-		struct {
-			struct nfs_readargs args;
-			struct nfs_readres  res;
-		} v3;   /* also v2 */
+	struct nfs_readargs args;
+	struct nfs_readres  res;
 #ifdef CONFIG_NFS_V4
-		struct {
-			struct nfs4_compound  compound;
-			struct nfs4_op        ops[3];
-			u32                   res_count;
-			u32                   res_eof;
-		} v4;
+	unsigned long		timestamp;	/* For lease renewal */
 #endif
-	} u;
 };
 
 struct nfs_write_data {


-------------------------------------------------------
This sf.net email is sponsored by:
With Great Power, Comes Great Responsibility 
Learn to use your power at OSDN's High Performance Computing Channel
http://hpc.devchannel.org/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
