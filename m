From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: [PATCH 2.5.51] NFSv4 cleanups [1/many]
Date: Thu, 12 Dec 2002 12:13:59 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15864.28535.691365.690078@charged.uio.no>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS maillist <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18MRIC-0006lj-00
	for <nfs@lists.sourceforge.net>; Thu, 12 Dec 2002 03:14:12 -0800
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


 - Move the encoding/decoding of the actual COMPOUND XDR header out of
   encode_compound()/decode_compound().

 - Make each NFSv4 operation 'decode_' routine also take care of
   decoding its own header, and checking it for correctness.
   Also allows us to get rid of the 'nfserr' parameter...

Cheers,
  Trond

diff -u --recursive --new-file linux-2.5.49-00-nfsv4_xdr1/fs/nfs/nfs4proc.c linux-2.5.49-01-nfsv4_xdr2/fs/nfs/nfs4proc.c
--- linux-2.5.49-00-nfsv4_xdr1/fs/nfs/nfs4proc.c	2002-11-18 11:53:14.000000000 -0500
+++ linux-2.5.49-01-nfsv4_xdr2/fs/nfs/nfs4proc.c	2002-11-22 22:16:55.000000000 -0500
@@ -648,7 +648,7 @@
 {
 	int status;
 	struct rpc_message msg = {
-		.rpc_proc = &nfs4_procedures[NFSPROC4_COMPOUND],
+		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_COMPOUND],
 		.rpc_argp = cp,
 		.rpc_resp = cp,
 		.rpc_cred = cred,
@@ -1112,7 +1112,7 @@
 	nfs4_setup_remove(cp, name, &up->cinfo);
 	nfs4_setup_getattr(cp, &up->attrs, bmres);
 	
-	msg->rpc_proc = &nfs4_procedures[NFSPROC4_COMPOUND];
+	msg->rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_COMPOUND];
 	msg->rpc_argp = cp;
 	msg->rpc_resp = cp;
 	return 0;
@@ -1373,7 +1373,7 @@
 	struct rpc_task	*task = &data->task;
 	struct nfs4_compound *cp = &data->u.v4.compound;
 	struct rpc_message msg = {
-		.rpc_proc = &nfs4_procedures[NFSPROC4_COMPOUND],
+		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_COMPOUND],
 		.rpc_argp = cp,
 		.rpc_resp = cp,
 		.rpc_cred = data->cred,
@@ -1417,7 +1417,7 @@
 	struct rpc_task	*task = &data->task;
 	struct nfs4_compound *cp = &data->u.v4.compound;
 	struct rpc_message msg = {
-		.rpc_proc = &nfs4_procedures[NFSPROC4_COMPOUND],
+		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_COMPOUND],
 		.rpc_argp = cp,
 		.rpc_resp = cp,
 		.rpc_cred = data->cred,
@@ -1468,7 +1468,7 @@
 	struct rpc_task	*task = &data->task;
 	struct nfs4_compound *cp = &data->u.v4.compound;
 	struct rpc_message msg = {
-		.rpc_proc = &nfs4_procedures[NFSPROC4_COMPOUND],
+		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_COMPOUND],
 		.rpc_argp = cp,
 		.rpc_resp = cp,
 		.rpc_cred = data->cred,
@@ -1523,7 +1523,7 @@
 	struct rpc_task *task;
 	struct nfs4_compound *cp;
 	struct rpc_message msg = {
-		.rpc_proc	= &nfs4_procedures[NFSPROC4_COMPOUND],
+		.rpc_proc	= &nfs4_procedures[NFSPROC4_CLNT_COMPOUND],
 	};
 
 	rp = (struct renew_desc *) kmalloc(sizeof(*rp), GFP_KERNEL);
diff -u --recursive --new-file linux-2.5.49-00-nfsv4_xdr1/fs/nfs/nfs4xdr.c linux-2.5.49-01-nfsv4_xdr2/fs/nfs/nfs4xdr.c
--- linux-2.5.49-00-nfsv4_xdr1/fs/nfs/nfs4xdr.c	2002-11-22 22:16:34.000000000 -0500
+++ linux-2.5.49-01-nfsv4_xdr2/fs/nfs/nfs4xdr.c	2002-11-22 22:16:55.000000000 -0500
@@ -83,6 +83,13 @@
 	{ 0,		NFNON	     },
 };
 
+struct compound_hdr {
+	int32_t		status;
+	uint32_t	nops;
+	uint32_t	taglen;
+	char *		tag;
+};
+
 /*
  * START OF "GENERIC" ENCODE ROUTINES.
  *   These may look a little ugly since they are imported from a "generic"
@@ -118,6 +125,20 @@
 	return p + tmp;
 }
 
+static int
+encode_compound_hdr(struct xdr_stream *xdr, struct compound_hdr *hdr)
+{
+	uint32_t *p;
+
+	dprintk("encode_compound: tag=%.*s\n", (int)hdr->taglen, hdr->tag);
+	RESERVE_SPACE(12+XDR_QUADLEN(hdr->taglen));
+	WRITE32(hdr->taglen);
+	WRITEMEM(hdr->tag, hdr->taglen);
+	WRITE32(NFS4_MINOR_VERSION);
+	WRITE32(hdr->nops);
+	return 0;
+}
+
 /*
  * FIXME: The following dummy entries will be replaced once the userland
  * upcall gets in...
@@ -696,16 +717,14 @@
 static int
 encode_compound(struct xdr_stream *xdr, struct nfs4_compound *cp, struct rpc_rqst *req)
 {
+	struct compound_hdr hdr = {
+		.taglen = cp->taglen,
+		.tag	= cp->tag,
+		.nops	= cp->req_nops,
+	};
 	int i, status = 0;
-	uint32_t *p;
 
-	dprintk("encode_compound: tag=%.*s\n", (int)cp->taglen, cp->tag);
-	
-	RESERVE_SPACE(12 + cp->taglen);
-	WRITE32(cp->taglen);
-	WRITEMEM(cp->tag, cp->taglen);
-	WRITE32(NFS4_MINOR_VERSION);
-	WRITE32(cp->req_nops);
+	encode_compound_hdr(xdr, &hdr);
 
 	for (i = 0; i < cp->req_nops; i++) {
 		switch (cp->ops[i].opnum) {
@@ -849,8 +868,8 @@
 	p = xdr_inline_decode(xdr, nbytes); \
 	if (!p) { \
 		printk(KERN_WARNING "%s: reply buffer overflowed in line %d.", \
-				__FUNCTION__, __LINE__); \
-			return -EIO; \
+			       	__FUNCTION__, __LINE__); \
+		return -EIO; \
 	} \
 } while (0)
 
@@ -877,6 +896,44 @@
 }
 
 static int
+decode_compound_hdr(struct xdr_stream *xdr, struct compound_hdr *hdr)
+{
+	uint32_t *p;
+
+	READ_BUF(8);
+	READ32(hdr->status);
+	READ32(hdr->taglen);
+	
+	READ_BUF(hdr->taglen + 4);
+	hdr->tag = (char *)p;
+	p += XDR_QUADLEN(hdr->taglen);
+	READ32(hdr->nops);
+	return 0;
+}
+
+static int
+decode_op_hdr(struct xdr_stream *xdr, enum nfs_opnum4 expected)
+{
+	uint32_t *p;
+	uint32_t opnum;
+	int32_t nfserr;
+
+	READ_BUF(8);
+	READ32(opnum);
+	if (opnum != expected) {
+		printk(KERN_NOTICE
+				"nfs4_decode_op_hdr: Server returned operation"
+			       	" %d but we issued a request for %d\n",
+				opnum, expected);
+		return -EIO;
+	}
+	READ32(nfserr);
+	if (nfserr != NFS_OK)
+		return -nfs_stat_to_errno(nfserr);
+	return 0;
+}
+
+static int
 decode_change_info(struct xdr_stream *xdr, struct nfs4_change_info *cinfo)
 {
 	uint32_t *p;
@@ -889,68 +946,71 @@
 }
 
 static int
-decode_access(struct xdr_stream *xdr, int nfserr, struct nfs4_access *access)
+decode_access(struct xdr_stream *xdr, struct nfs4_access *access)
 {
 	uint32_t *p;
 	uint32_t supp, acc;
+	int status;
 
-	if (!nfserr) {
-		READ_BUF(8);
-		READ32(supp);
-		READ32(acc);
-
-		if ((supp & ~access->ac_req_access) || (acc & ~supp)) {
-			printk(KERN_NOTICE "NFS: server returned bad bits in access call!\n");
-			return -EIO;
-		}
-		*access->ac_resp_supported = supp;
-		*access->ac_resp_access = acc;
+	status = decode_op_hdr(xdr, OP_ACCESS);
+	if (status)
+		return status;
+	READ_BUF(8);
+	READ32(supp);
+	READ32(acc);
+	if ((supp & ~access->ac_req_access) || (acc & ~supp)) {
+		printk(KERN_NOTICE "NFS: server returned bad bits in access call!\n");
+		return -EIO;
 	}
+	*access->ac_resp_supported = supp;
+	*access->ac_resp_access = acc;
 	return 0;
 }
 
 static int
-decode_close(struct xdr_stream *xdr, int nfserr, struct nfs4_close *close)
+decode_close(struct xdr_stream *xdr, struct nfs4_close *close)
 {
 	uint32_t *p;
+	int status;
 
-	if (!nfserr) {
-		READ_BUF(sizeof(nfs4_stateid));
-		COPYMEM(close->cl_stateid, sizeof(nfs4_stateid));
-	}
+	status = decode_op_hdr(xdr, OP_CLOSE);
+	if (status)
+		return status;
+	READ_BUF(sizeof(nfs4_stateid));
+	COPYMEM(close->cl_stateid, sizeof(nfs4_stateid));
 	return 0;
 }
 
 static int
-decode_commit(struct xdr_stream *xdr, int nfserr, struct nfs4_commit *commit)
+decode_commit(struct xdr_stream *xdr, struct nfs4_commit *commit)
 {
 	uint32_t *p;
+	int status;
 
-        if (!nfserr) {
-                READ_BUF(8);
-                COPYMEM(commit->co_verifier->verifier, 8);
-        }
+	status = decode_op_hdr(xdr, OP_COMMIT);
+	if (status)
+		return status;
+	READ_BUF(8);
+	COPYMEM(commit->co_verifier->verifier, 8);
 	return 0;
 }
 
 static int
-decode_create(struct xdr_stream *xdr, int nfserr, struct nfs4_create *create)
+decode_create(struct xdr_stream *xdr, struct nfs4_create *create)
 {
 	uint32_t *p;
 	uint32_t bmlen;
 	int status;
 
-	if (!nfserr) {
-		if ((status = decode_change_info(xdr, create->cr_cinfo)))
-			goto out;
-		READ_BUF(4);
-		READ32(bmlen);
-		if (bmlen > 2)
-			goto xdr_error;
-		READ_BUF(bmlen << 2);
-	}
-
-	DECODE_TAIL;
+	status = decode_op_hdr(xdr, OP_CREATE);
+	if (status)
+		return status;
+	if ((status = decode_change_info(xdr, create->cr_cinfo)))
+		return status;
+	READ_BUF(4);
+	READ32(bmlen);
+	READ_BUF(bmlen << 2);
+	return 0;
 }
 
 extern uint32_t nfs4_fattr_bitmap[2];
@@ -959,25 +1019,24 @@
 extern uint32_t nfs4_pathconf_bitmap[2];
 
 static int
-decode_getattr(struct xdr_stream *xdr, int nfserr, struct nfs4_getattr *getattr)
+decode_getattr(struct xdr_stream *xdr, struct nfs4_getattr *getattr)
 {
-        struct nfs_fattr *nfp = getattr->gt_attrs;
+	struct nfs_fattr *nfp = getattr->gt_attrs;
 	struct nfs_fsstat *fsstat = getattr->gt_fsstat;
 	struct nfs_fsinfo *fsinfo = getattr->gt_fsinfo;
 	struct nfs_pathconf *pathconf = getattr->gt_pathconf;
+	uint32_t attrlen, dummy32, bmlen,
+		 bmval0 = 0,
+		 bmval1 = 0,
+		 len = 0;
 	uint32_t *p;
-        uint32_t bmlen;
-        uint32_t bmval0 = 0;
-        uint32_t bmval1 = 0;
-        uint32_t attrlen;
-        uint32_t dummy32;
-        uint32_t len = 0;
 	unsigned int type;
 	int fmode = 0;
 	int status;
 	
-        if (nfserr)
-                goto success;
+	status = decode_op_hdr(xdr, OP_GETATTR);
+	if (status)
+		return status;
         
         READ_BUF(4);
         READ32(bmlen);
@@ -1208,265 +1267,361 @@
         if (len != attrlen)
                 goto xdr_error;
 	
-success:
         DECODE_TAIL;
 }
 
 static int
-decode_getfh(struct xdr_stream *xdr, int nfserr, struct nfs4_getfh *getfh)
+decode_getfh(struct xdr_stream *xdr, struct nfs4_getfh *getfh)
 {
 	struct nfs_fh *fh = getfh->gf_fhandle;
 	uint32_t *p;
 	uint32_t len;
 	int status;
 
+	status = decode_op_hdr(xdr, OP_GETFH);
+	if (status)
+		return status;
 	/* Zero handle first to allow comparisons */
 	memset(fh, 0, sizeof(*fh));
-		
-        if (!nfserr) {
-                READ_BUF(4);
-		READ32(len);
-		if (len > NFS_MAXFHSIZE)
-			goto xdr_error;
-		fh->size = len;
-                READ_BUF(len);
-                COPYMEM(fh->data, len);
-        }
 
-        DECODE_TAIL;
+	READ_BUF(4);
+	READ32(len);
+	if (len > NFS_MAXFHSIZE)
+		return -EIO;
+	fh->size = len;
+	READ_BUF(len);
+	COPYMEM(fh->data, len);
+	return 0;
 }
 
 static int
-decode_link(struct xdr_stream *xdr, int nfserr, struct nfs4_link *link)
+decode_link(struct xdr_stream *xdr, struct nfs4_link *link)
 {
-	int status = 0;
+	int status;
 	
-	if (!nfserr)
-		status = decode_change_info(xdr, link->ln_cinfo);
-	return status;
+	status = decode_op_hdr(xdr, OP_LINK);
+	if (status)
+		return status;
+	return decode_change_info(xdr, link->ln_cinfo);
 }
 
 static int
-decode_open(struct xdr_stream *xdr, int nfserr, struct nfs4_open *open)
+decode_lookup(struct xdr_stream *xdr)
+{
+	return decode_op_hdr(xdr, OP_LOOKUP);
+}
+
+static int
+decode_open(struct xdr_stream *xdr, struct nfs4_open *open)
 {
 	uint32_t *p;
 	uint32_t bmlen, delegation_type;
 	int status;
 	
-	if (!nfserr) {
-		READ_BUF(sizeof(nfs4_stateid));
-		COPYMEM(open->op_stateid, sizeof(nfs4_stateid));
+	status = decode_op_hdr(xdr, OP_OPEN);
+	if (status)
+		return status;
+	READ_BUF(sizeof(nfs4_stateid));
+	COPYMEM(open->op_stateid, sizeof(nfs4_stateid));
 
-		decode_change_info(xdr, open->op_cinfo);
+	decode_change_info(xdr, open->op_cinfo);
 
-		READ_BUF(8);
-		READ32(*open->op_rflags);
-		READ32(bmlen);
-		if (bmlen > 10)
-			goto xdr_error;
+	READ_BUF(8);
+	READ32(*open->op_rflags);
+	READ32(bmlen);
+	if (bmlen > 10)
+		goto xdr_error;
 		
-		READ_BUF((bmlen << 2) + 4);
-		p += bmlen;
-		READ32(delegation_type);
-		if (delegation_type != NFS4_OPEN_DELEGATE_NONE)
-			goto xdr_error;
-	}
+	READ_BUF((bmlen << 2) + 4);
+	p += bmlen;
+	READ32(delegation_type);
+	if (delegation_type != NFS4_OPEN_DELEGATE_NONE)
+		goto xdr_error;
 	
 	DECODE_TAIL;
 }
 
 static int
-decode_open_confirm(struct xdr_stream *xdr, int nfserr, struct nfs4_open_confirm *open_confirm)
+decode_open_confirm(struct xdr_stream *xdr, struct nfs4_open_confirm *open_confirm)
 {
 	uint32_t *p;
+	int status;
 
-	if (!nfserr) {
-		READ_BUF(sizeof(nfs4_stateid));
-		COPYMEM(open_confirm->oc_stateid, sizeof(nfs4_stateid));
-	}
+	status = decode_op_hdr(xdr, OP_OPEN_CONFIRM);
+	if (status)
+		return status;
+	READ_BUF(sizeof(nfs4_stateid));
+	COPYMEM(open_confirm->oc_stateid, sizeof(nfs4_stateid));
 	return 0;
 }
 
 static int
-decode_read(struct xdr_stream *xdr, int nfserr, struct nfs4_read *read)
+decode_putfh(struct xdr_stream *xdr)
 {
-	uint32_t throwaway;
+	return decode_op_hdr(xdr, OP_PUTFH);
+}
+
+static int
+decode_putrootfh(struct xdr_stream *xdr)
+{
+	return decode_op_hdr(xdr, OP_PUTROOTFH);
+}
+
+static int
+decode_read(struct xdr_stream *xdr, struct rpc_rqst *req, struct nfs4_read *read)
+{
+	struct iovec *iov = req->rq_rvec;
 	uint32_t *p;
+	uint32_t count, eof, recvd, hdrlen;
 	int status;
 
-	if (!nfserr) {
-		READ_BUF(8);
-		if (read->rd_eof)
-			READ32(*read->rd_eof);
-		else
-			READ32(throwaway);
-		READ32(*read->rd_bytes_read);
-		if (*read->rd_bytes_read > read->rd_length)
-			goto xdr_error;
-	}
-
-	DECODE_TAIL;
+	status = decode_op_hdr(xdr, OP_READ);
+	if (status)
+		return status;
+	READ_BUF(8);
+	READ32(eof);
+	READ32(count);
+	hdrlen = (u8 *) p - (u8 *) iov->iov_base;
+	if (iov->iov_len < hdrlen) {
+		printk(KERN_WARNING "NFS: READ reply header overflowed:"
+				"length %u > %Zu\n", hdrlen, iov->iov_len);
+		return -errno_NFSERR_IO;
+	} else if (iov->iov_len != hdrlen) {
+		dprintk("NFS: READ header is short. iovec will be shifted.\n");
+		xdr_shift_buf(&req->rq_rcv_buf, iov->iov_len - hdrlen);
+	}
+	recvd = req->rq_received - hdrlen;
+	if (count > recvd) {
+		printk(KERN_WARNING "NFS: server cheating in read reply: "
+				"count %u > recvd %u\n", count, recvd);
+		count = recvd;
+		eof = 0;
+	}
+	if (read->rd_eof)
+		*read->rd_eof = eof;
+	*read->rd_bytes_read = count;
+	return 0;
 }
 
 static int
-decode_readdir(struct xdr_stream *xdr, int nfserr, struct rpc_rqst *req, struct nfs4_readdir *readdir)
+decode_readdir(struct xdr_stream *xdr, struct rpc_rqst *req, struct nfs4_readdir *readdir)
 {
 	struct xdr_buf	*rcvbuf = &req->rq_rcv_buf;
 	struct page	*page = *rcvbuf->pages;
-	unsigned int	pglen = rcvbuf->page_len;
-	uint32_t *end, *entry, *p;
-	uint32_t len, attrlen, word;
-	int i;
+	struct iovec	*iov = rcvbuf->head;
+	unsigned int	nr, pglen = rcvbuf->page_len;
+	uint32_t	*end, *entry, *p;
+	uint32_t	len, attrlen, word;
+	int 		i, hdrlen, recvd, status;
 
-	if (!nfserr) {
-		READ_BUF(8);
-		COPYMEM(readdir->rd_resp_verifier, 8);
+	status = decode_op_hdr(xdr, OP_READDIR);
+	if (status)
+		return status;
+	READ_BUF(8);
+	COPYMEM(readdir->rd_resp_verifier, 8);
 
-		BUG_ON(pglen > PAGE_CACHE_SIZE);
-		p   = (uint32_t *) kmap(page);
-		end = (uint32_t *) ((char *)p + pglen + readdir->rd_pgbase);
-
-		while (*p++) {
-			entry = p - 1;
-			if (p + 3 > end)
-				goto short_pkt;
-			p += 2;     /* cookie */
-			len = ntohl(*p++);  /* filename length */
-			if (len > NFS4_MAXNAMLEN) {
-				printk(KERN_WARNING "NFS: giant filename in readdir (len 0x%x)\n", len);
-				goto err_unmap;
-			}
+	hdrlen = (char *) p - (char *) iov->iov_base;
+	if (iov->iov_len < hdrlen) {
+		printk(KERN_WARNING "NFS: READDIR reply header overflowed:"
+				"length %d > %Zu\n", hdrlen, iov->iov_len);
+		return -EIO;
+	} else if (iov->iov_len != hdrlen) {
+		dprintk("NFS: READDIR header is short. iovec will be shifted.\n");
+		xdr_shift_buf(rcvbuf, iov->iov_len - hdrlen);
+	}
+	recvd = req->rq_received - hdrlen;
+	if (pglen > recvd)
+		pglen = recvd;
+
+	BUG_ON(pglen + readdir->rd_pgbase > PAGE_CACHE_SIZE);
+	p   = (uint32_t *) kmap(page);
+	end = (uint32_t *) ((char *)p + pglen + readdir->rd_pgbase);
+	entry = p;
+	for (nr = 0; *p++; nr++) {
+		if (p + 3 > end)
+			goto short_pkt;
+		p += 2;     /* cookie */
+		len = ntohl(*p++);  /* filename length */
+		if (len > NFS4_MAXNAMLEN) {
+			printk(KERN_WARNING "NFS: giant filename in readdir (len 0x%x)\n", len);
+			goto err_unmap;
+		}
 			
-			p += XDR_QUADLEN(len);
-			if (p + 1 > end)
-				goto short_pkt;
-			len = ntohl(*p++);  /* bitmap length */
-			if (len > 10) {
-				printk(KERN_WARNING "NFS: giant bitmap in readdir (len 0x%x)\n", len);
-				goto err_unmap;
-			}
-			if (p + len + 1 > end)
-				goto short_pkt;
-			attrlen = 0;
-			for (i = 0; i < len; i++) {
-				word = ntohl(*p++);
-				if (!word)
-					continue;
-				else if (i == 0 && word == FATTR4_WORD0_FILEID) {
-					attrlen = 8;
-					continue;
-				}
-				printk(KERN_WARNING "NFS: unexpected bitmap word in readdir (0x%x)\n", word);
-				goto err_unmap;
-			}
-			if (ntohl(*p++) != attrlen) {
-				printk(KERN_WARNING "NFS: unexpected attrlen in readdir\n");
-				goto err_unmap;
+		p += XDR_QUADLEN(len);
+		if (p + 1 > end)
+			goto short_pkt;
+		len = ntohl(*p++);  /* bitmap length */
+		if (len > 10) {
+			printk(KERN_WARNING "NFS: giant bitmap in readdir (len 0x%x)\n", len);
+			goto err_unmap;
+		}
+		if (p + len + 1 > end)
+			goto short_pkt;
+		attrlen = 0;
+		for (i = 0; i < len; i++) {
+			word = ntohl(*p++);
+			if (!word)
+				continue;
+			else if (i == 0 && word == FATTR4_WORD0_FILEID) {
+				attrlen = 8;
+				continue;
 			}
-			p += XDR_QUADLEN(attrlen);
-			if (p + 1 > end)
-				goto short_pkt;
+			printk(KERN_WARNING "NFS: unexpected bitmap word in readdir (0x%x)\n", word);
+			goto err_unmap;
 		}
-		kunmap(page);
-	}
-	
+		if (ntohl(*p++) != attrlen) {
+			printk(KERN_WARNING "NFS: unexpected attrlen in readdir\n");
+			goto err_unmap;
+		}
+		p += XDR_QUADLEN(attrlen);
+		if (p + 1 > end)
+			goto short_pkt;
+	}
+	if (!nr && (entry[0] != 0 || entry[1] == 0))
+		goto short_pkt;
+out:	
+	kunmap(page);
 	return 0;
 short_pkt:
-	printk(KERN_NOTICE "NFS: short packet in readdir reply!\n");
-	/* truncate listing */
-	kunmap(page);
 	entry[0] = entry[1] = 0;
-	return 0;
+	/* truncate listing ? */
+	if (!nr) {
+		printk(KERN_NOTICE "NFS: readdir reply truncated!\n");
+		entry[1] = 1;
+	}
+	goto out;
 err_unmap:
 	kunmap(page);
 	return -errno_NFSERR_IO;
 }
 
 static int
-decode_readlink(struct xdr_stream *xdr, int nfserr, struct rpc_rqst *req, struct nfs4_readlink *readlink)
+decode_readlink(struct xdr_stream *xdr, struct rpc_rqst *req, struct nfs4_readlink *readlink)
 {
 	struct xdr_buf *rcvbuf = &req->rq_rcv_buf;
+	struct iovec *iov = rcvbuf->head;
 	uint32_t *strlen;
-	uint32_t len;
+	unsigned int hdrlen, len;
 	char *string;
+	int status;
 
-	if (!nfserr) {
-		/*
-		 * The XDR encode routine has set things up so that
-		 * the link text will be copied directly into the
-		 * buffer.  We just have to do overflow-checking,
-		 * and and null-terminate the text (the VFS expects
-		 * null-termination).
-		 */
-		strlen = (uint32_t *) kmap(rcvbuf->pages[0]);
-		len = ntohl(*strlen);
-		if (len > PAGE_CACHE_SIZE - 5) {
-			printk(KERN_WARNING "nfs: server returned giant symlink!\n");
-			kunmap(rcvbuf->pages[0]);
-			return -EIO;
-		}
-		*strlen = len;
-		
-		string = (char *)(strlen + 1);
-		string[len] = '\0';
+	status = decode_op_hdr(xdr, OP_READLINK);
+	if (status)
+		return status;
+
+	hdrlen = (char *) xdr->p - (char *) iov->iov_base;
+	if (iov->iov_len > hdrlen) {
+		dprintk("NFS: READLINK header is short. iovec will be shifted.\n");
+		xdr_shift_buf(rcvbuf, iov->iov_len - hdrlen);
+
+	}
+	/*
+	 * The XDR encode routine has set things up so that
+	 * the link text will be copied directly into the
+	 * buffer.  We just have to do overflow-checking,
+	 * and and null-terminate the text (the VFS expects
+	 * null-termination).
+	 */
+	strlen = (uint32_t *) kmap(rcvbuf->pages[0]);
+	len = ntohl(*strlen);
+	if (len > PAGE_CACHE_SIZE - 5) {
+		printk(KERN_WARNING "nfs: server returned giant symlink!\n");
 		kunmap(rcvbuf->pages[0]);
+		return -EIO;
 	}
+	*strlen = len;
+
+	string = (char *)(strlen + 1);
+	string[len] = '\0';
+	kunmap(rcvbuf->pages[0]);
 	return 0;
 }
 
 static int
-decode_remove(struct xdr_stream *xdr, int nfserr, struct nfs4_remove *remove)
+decode_restorefh(struct xdr_stream *xdr)
+{
+	return decode_op_hdr(xdr, OP_RESTOREFH);
+}
+
+static int
+decode_remove(struct xdr_stream *xdr, struct nfs4_remove *remove)
 {
 	int status;
 
-	status = 0;
-	if (!nfserr) 
-		status = decode_change_info(xdr, remove->rm_cinfo);
+	status = decode_op_hdr(xdr, OP_REMOVE);
+	if (status)
+		goto out;
+	status = decode_change_info(xdr, remove->rm_cinfo);
+out:
 	return status;
 }
 
 static int
-decode_rename(struct xdr_stream *xdr, int nfserr, struct nfs4_rename *rename)
+decode_rename(struct xdr_stream *xdr, struct nfs4_rename *rename)
 {
-	int status = 0;
+	int status;
 
-	if (!nfserr) {
-		if ((status = decode_change_info(xdr, rename->rn_src_cinfo)))
-			goto out;
-		if ((status = decode_change_info(xdr, rename->rn_dst_cinfo)))
-			goto out;
-	}
+	status = decode_op_hdr(xdr, OP_RENAME);
+	if (status)
+		goto out;
+	if ((status = decode_change_info(xdr, rename->rn_src_cinfo)))
+		goto out;
+	if ((status = decode_change_info(xdr, rename->rn_dst_cinfo)))
+		goto out;
 out:
 	return status;
 }
 
 static int
+decode_renew(struct xdr_stream *xdr)
+{
+	return decode_op_hdr(xdr, OP_RENEW);
+}
+
+static int
+decode_savefh(struct xdr_stream *xdr)
+{
+	return decode_op_hdr(xdr, OP_SAVEFH);
+}
+
+static int
 decode_setattr(struct xdr_stream *xdr)
 {
 	uint32_t *p;
-        uint32_t bmlen;
+	uint32_t bmlen;
 	int status;
-        
-        READ_BUF(4);
-        READ32(bmlen);
-        if (bmlen > 10)
-                goto xdr_error;
-        READ_BUF(bmlen << 2);
 
-        DECODE_TAIL;
+        
+	status = decode_op_hdr(xdr, OP_SETATTR);
+	if (status)
+		return status;
+	READ_BUF(4);
+	READ32(bmlen);
+	READ_BUF(bmlen << 2);
+	return 0;
 }
 
 static int
-decode_setclientid(struct xdr_stream *xdr, int nfserr, struct nfs4_setclientid *setclientid)
+decode_setclientid(struct xdr_stream *xdr, struct nfs4_setclientid *setclientid)
 {
 	uint32_t *p;
+	uint32_t opnum;
+	int32_t nfserr;
 
-	if (!nfserr) {
+	READ_BUF(8);
+	READ32(opnum);
+	if (opnum != OP_SETCLIENTID) {
+		printk(KERN_NOTICE
+				"nfs4_decode_setclientid: Server returned operation"
+			       	" %d\n", opnum);
+		return -EIO;
+	}
+	READ32(nfserr);
+	if (nfserr == NFS_OK) {
 		READ_BUF(8 + sizeof(nfs4_verifier));
 		READ64(setclientid->sc_state->cl_clientid);
 		COPYMEM(setclientid->sc_state->cl_confirm, sizeof(nfs4_verifier));
-	}
-	else if (nfserr == NFSERR_CLID_INUSE) {
+	} else if (nfserr == NFSERR_CLID_INUSE) {
 		uint32_t len;
 
 		/* skip netid string */
@@ -1478,156 +1633,146 @@
 		READ_BUF(4);
 		READ32(len);
 		READ_BUF(len);
-	}
+		return -EEXIST;
+	} else
+		return -nfs_stat_to_errno(nfserr);
 
 	return 0;
 }
 
 static int
-decode_write(struct xdr_stream *xdr, int nfserr, struct nfs4_write *write)
+decode_setclientid_confirm(struct xdr_stream *xdr)
+{
+	return decode_op_hdr(xdr, OP_SETCLIENTID_CONFIRM);
+}
+
+static int
+decode_write(struct xdr_stream *xdr, struct nfs4_write *write)
 {
 	uint32_t *p;
 	int status;
 
-	if (!nfserr) {
-		READ_BUF(16);
-		READ32(*write->wr_bytes_written);
-		if (*write->wr_bytes_written > write->wr_len)
-			goto xdr_error;
-		READ32(write->wr_verf->committed);
-		COPYMEM(write->wr_verf->verifier, 8);
-	}
+	status = decode_op_hdr(xdr, OP_WRITE);
+	if (status)
+		return status;
 
-	DECODE_TAIL;
+	READ_BUF(16);
+	READ32(*write->wr_bytes_written);
+	if (*write->wr_bytes_written > write->wr_len)
+		return -EIO;
+	READ32(write->wr_verf->committed);
+	COPYMEM(write->wr_verf->verifier, 8);
+	return 0;
 }
 
 /* FIXME: this sucks */
 static int
 decode_compound(struct xdr_stream *xdr, struct nfs4_compound *cp, struct rpc_rqst *req)
 {
-	uint32_t *p;
-	uint32_t taglen;
-	uint32_t opnum, nfserr;
+	struct compound_hdr hdr;
+	struct nfs4_op *op;
 	int status;
 
-	READ_BUF(8);
-	READ32(cp->toplevel_status);
-	READ32(taglen);
+	status = decode_compound_hdr(xdr, &hdr);
+	if (status)
+		goto out;
+
+	cp->toplevel_status = hdr.status;
 
 	/*
 	 * We need this if our zero-copy I/O is going to work.  Rumor has
 	 * it that the spec will soon mandate it...
 	 */
-	if (taglen != cp->taglen)
+	if (hdr.taglen != cp->taglen)
 		dprintk("nfs4: non-conforming server returns tag length mismatch!\n");
 
-	READ_BUF(taglen + 4);
-	p += XDR_QUADLEN(taglen);
-	READ32(cp->resp_nops);
-	if (cp->resp_nops > cp->req_nops) {
+	cp->resp_nops = hdr.nops;
+	if (hdr.nops > cp->req_nops) {
 		dprintk("nfs4: resp_nops > req_nops!\n");
 		goto xdr_error;
 	}
 
-	for (cp->nops = 0; cp->nops < cp->resp_nops; cp->nops++) {
-		READ_BUF(8);
-		READ32(opnum);
-		if (opnum != cp->ops[cp->nops].opnum) {
-			dprintk("nfs4: operation mismatch!\n");
-			goto xdr_error;
-		}
-		READ32(nfserr);
-		if (cp->nops == cp->resp_nops - 1) {
-			if (nfserr != cp->toplevel_status) {
-				dprintk("nfs4: status mismatch!\n");
-				goto xdr_error;
-			}
-		}
-		else if (nfserr) {
-			dprintk("nfs4: intermediate status nonzero!\n");
-			goto xdr_error;
-		}
-		cp->ops[cp->nops].nfserr = nfserr;
-
-		switch (opnum) {
+	op = &cp->ops[0];
+	for (cp->nops = 0; cp->nops < cp->resp_nops; cp->nops++, op++) {
+		switch (op->opnum) {
 		case OP_ACCESS:
-			status = decode_access(xdr, nfserr, &cp->ops[cp->nops].u.access);
+			status = decode_access(xdr, &op->u.access);
 			break;
 		case OP_CLOSE:
-			status = decode_close(xdr, nfserr, &cp->ops[cp->nops].u.close);
+			status = decode_close(xdr, &op->u.close);
 			break;
 		case OP_COMMIT:
-			status = decode_commit(xdr, nfserr, &cp->ops[cp->nops].u.commit);
+			status = decode_commit(xdr, &op->u.commit);
 			break;
 		case OP_CREATE:
-			status = decode_create(xdr, nfserr, &cp->ops[cp->nops].u.create);
+			status = decode_create(xdr, &op->u.create);
 			break;
 		case OP_GETATTR:
-			status = decode_getattr(xdr, nfserr, &cp->ops[cp->nops].u.getattr);
+			status = decode_getattr(xdr, &op->u.getattr);
 			break;
 		case OP_GETFH:
-			status = decode_getfh(xdr, nfserr, &cp->ops[cp->nops].u.getfh);
+			status = decode_getfh(xdr, &op->u.getfh);
 			break;
 		case OP_LINK:
-			status = decode_link(xdr, nfserr, &cp->ops[cp->nops].u.link);
+			status = decode_link(xdr, &op->u.link);
 			break;
 		case OP_LOOKUP:
-			status = 0;
+			status = decode_lookup(xdr);
 			break;
 		case OP_OPEN:
-			status = decode_open(xdr, nfserr, &cp->ops[cp->nops].u.open);
+			status = decode_open(xdr, &op->u.open);
 			break;
 		case OP_OPEN_CONFIRM:
-			status = decode_open_confirm(xdr, nfserr, &cp->ops[cp->nops].u.open_confirm);
+			status = decode_open_confirm(xdr, &op->u.open_confirm);
 			break;
 		case OP_PUTFH:
-			status = 0;
+			status = decode_putfh(xdr);
 			break;
 		case OP_PUTROOTFH:
-			status = 0;
+			status = decode_putrootfh(xdr);
 			break;
 		case OP_READ:
-			status = decode_read(xdr, nfserr, &cp->ops[cp->nops].u.read);
+			status = decode_read(xdr, req, &op->u.read);
 			break;
 		case OP_READDIR:
-			status = decode_readdir(xdr, nfserr, req, &cp->ops[cp->nops].u.readdir);
+			status = decode_readdir(xdr, req, &op->u.readdir);
 			break;
 		case OP_READLINK:
-			status = decode_readlink(xdr, nfserr, req, &cp->ops[cp->nops].u.readlink);
+			status = decode_readlink(xdr, req, &op->u.readlink);
 			break;
 		case OP_RESTOREFH:
-			status = 0;
+			status = decode_restorefh(xdr);
 			break;
 		case OP_REMOVE:
-			status = decode_remove(xdr, nfserr, &cp->ops[cp->nops].u.remove);
+			status = decode_remove(xdr, &op->u.remove);
 			break;
 		case OP_RENAME:
-			status = decode_rename(xdr, nfserr, &cp->ops[cp->nops].u.rename);
+			status = decode_rename(xdr, &op->u.rename);
 			break;
 		case OP_RENEW:
-			status = 0;
+			status = decode_renew(xdr);
 			break;
 		case OP_SAVEFH:
-			status = 0;
+			status = decode_savefh(xdr);
 			break;
 		case OP_SETATTR:
 			status = decode_setattr(xdr);
 			break;
 		case OP_SETCLIENTID:
-			status = decode_setclientid(xdr, nfserr, &cp->ops[cp->nops].u.setclientid);
+			status = decode_setclientid(xdr, &op->u.setclientid);
 			break;
 		case OP_SETCLIENTID_CONFIRM:
-			status = 0;
+			status = decode_setclientid_confirm(xdr);
 			break;
 		case OP_WRITE:
-			status = decode_write(xdr, nfserr, &cp->ops[cp->nops].u.write);
+			status = decode_write(xdr, &op->u.write);
 			break;
 		default:
 			BUG();
 			return -EIO;
 		}
 		if (status)
-			goto xdr_error;
+			break;
 	}
 
 	DECODE_TAIL;
@@ -1700,15 +1845,15 @@
 #endif
 
 #define PROC(proc, argtype, restype)				\
-[NFSPROC4_##proc] = {						\
-	.p_proc   = NFSPROC4_##proc,				\
+[NFSPROC4_CLNT_##proc] = {						\
+	.p_proc   = NFSPROC4_COMPOUND,				\
 	.p_encode = (kxdrproc_t) nfs4_xdr_##argtype,		\
 	.p_decode = (kxdrproc_t) nfs4_xdr_##restype,		\
 	.p_bufsiz = MAX(NFS4_##argtype##_sz,NFS4_##restype##_sz) << 2,	\
     }
 
 struct rpc_procinfo	nfs4_procedures[] = {
-  PROC(COMPOUND,	enc_compound,	dec_compound)
+  PROC(COMPOUND,	enc_compound,	dec_compound),
 };
 
 struct rpc_version		nfs_version4 = {
diff -u --recursive --new-file linux-2.5.49-00-nfsv4_xdr1/include/linux/nfs4.h linux-2.5.49-01-nfsv4_xdr2/include/linux/nfs4.h
--- linux-2.5.49-00-nfsv4_xdr1/include/linux/nfs4.h	2002-10-08 18:42:48.000000000 -0400
+++ linux-2.5.49-01-nfsv4_xdr2/include/linux/nfs4.h	2002-11-22 22:16:55.000000000 -0500
@@ -196,6 +196,16 @@
 #define NFS4_MINOR_VERSION 0
 #define NFS4_DEBUG 1
 
+#ifdef __KERNEL__
+
+/* Index of predefined Linux client operations */
+
+enum {
+	NFSPROC4_CLNT_NULL = 0,		/* Unused */
+	NFSPROC4_CLNT_COMPOUND,		/* Soon to be unused */
+};
+
+#endif
 #endif
 
 /*
diff -u --recursive --new-file linux-2.5.49-00-nfsv4_xdr1/include/linux/nfs_xdr.h linux-2.5.49-01-nfsv4_xdr2/include/linux/nfs_xdr.h
--- linux-2.5.49-00-nfsv4_xdr1/include/linux/nfs_xdr.h	2002-11-18 11:53:14.000000000 -0500
+++ linux-2.5.49-01-nfsv4_xdr2/include/linux/nfs_xdr.h	2002-11-22 22:16:55.000000000 -0500
@@ -488,7 +488,6 @@
 
 struct nfs4_op {
 	u32				opnum;
-	u32				nfserr;
 	union {
 		struct nfs4_access	access;
 		struct nfs4_close	close;


-------------------------------------------------------
This sf.net email is sponsored by:
With Great Power, Comes Great Responsibility 
Learn to use your power at OSDN's High Performance Computing Channel
http://hpc.devchannel.org/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
