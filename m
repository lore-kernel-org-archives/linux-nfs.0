Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f41.google.com ([209.85.214.41]:43052 "EHLO
        mail-it0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751098AbeACUm2 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Jan 2018 15:42:28 -0500
Subject: [PATCH v2 2/3] NFSD: Clean up write argument XDR decoders
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Wed, 03 Jan 2018 15:42:27 -0500
Message-ID: <20180103204226.7074.73730.stgit@klimt.1015granger.net>
In-Reply-To: <20180103203849.7074.9609.stgit@klimt.1015granger.net>
References: <20180103203849.7074.9609.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Move common code in NFSD's write arg decoders into a helper. The
immediate benefit is reduction of code duplication and some nice
micro-optimizations (see below).

However, in the long term, this helper could perform a per-transport
call-out to fill the rq_vec (say, using RDMA Reads).

The legacy WRITE decoders and procs are changed to work like NFSv4,
which constructs the rq_vec just before it is about to call
vfs_writev.

Why? Calling a transport call-out from the proc instead of the XDR
decoder means that the incoming FH can be resolved to a particular
filesystem and file. This would allow pages from the backing file to
be presented to the transport to be filled, rather than presenting
anonymous pages and copying or swapping them into the file's page
cache later.

We also prefer using the pages in rq_arg.pages, instead of pulling
the data pages directly out of the rqstp::rq_pages array. This
removes the only reference to rq_pages found in NFSD, eliminating an
NFSD assumption about how transports use the pages in rq_pages.

Lastly, avoid setting up the first element of rq_vec as a zero-
length buffer. This happens with an RDMA transport when a normal
Read chunk is present because the data payload is in rq_arg's
page list (none of it is in the head buffer).

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfsd/nfs3proc.c         |    8 ++++++--
 fs/nfsd/nfs3xdr.c          |   16 ++++------------
 fs/nfsd/nfs4proc.c         |   30 ++++++------------------------
 fs/nfsd/nfs4xdr.c          |    1 -
 fs/nfsd/nfsproc.c          |    9 +++++++--
 fs/nfsd/nfsxdr.c           |   14 ++------------
 fs/nfsd/xdr.h              |    2 +-
 fs/nfsd/xdr3.h             |    2 +-
 fs/nfsd/xdr4.h             |    1 -
 include/linux/sunrpc/svc.h |    2 ++
 net/sunrpc/svc.c           |   42 ++++++++++++++++++++++++++++++++++++++++++
 11 files changed, 71 insertions(+), 56 deletions(-)

diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
index 1d0ce3c..2dd95eb 100644
--- a/fs/nfsd/nfs3proc.c
+++ b/fs/nfsd/nfs3proc.c
@@ -192,6 +192,7 @@
 	struct nfsd3_writeres *resp = rqstp->rq_resp;
 	__be32	nfserr;
 	unsigned long cnt = argp->len;
+	unsigned int nvecs;
 
 	dprintk("nfsd: WRITE(3)    %s %d bytes at %Lu%s\n",
 				SVCFH_fmt(&argp->fh),
@@ -201,9 +202,12 @@
 
 	fh_copy(&resp->fh, &argp->fh);
 	resp->committed = argp->stable;
+	nvecs = svc_fill_write_vector(rqstp, &argp->first, cnt);
+	if (!nvecs)
+		RETURN_STATUS(nfserr_io);
 	nfserr = nfsd_write(rqstp, &resp->fh, argp->offset,
-				rqstp->rq_vec, argp->vlen,
-				&cnt, resp->committed);
+			    rqstp->rq_vec, nvecs, &cnt,
+			    resp->committed);
 	resp->count = cnt;
 	RETURN_STATUS(nfserr);
 }
diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
index 2758480..240cdb0e 100644
--- a/fs/nfsd/nfs3xdr.c
+++ b/fs/nfsd/nfs3xdr.c
@@ -362,7 +362,7 @@ void fill_post_wcc(struct svc_fh *fhp)
 nfs3svc_decode_writeargs(struct svc_rqst *rqstp, __be32 *p)
 {
 	struct nfsd3_writeargs *args = rqstp->rq_argp;
-	unsigned int len, v, hdr, dlen;
+	unsigned int len, hdr, dlen;
 	u32 max_blocksize = svc_max_payload(rqstp);
 	struct kvec *head = rqstp->rq_arg.head;
 	struct kvec *tail = rqstp->rq_arg.tail;
@@ -404,17 +404,9 @@ void fill_post_wcc(struct svc_fh *fhp)
 		args->count = max_blocksize;
 		len = args->len = max_blocksize;
 	}
-	rqstp->rq_vec[0].iov_base = (void*)p;
-	rqstp->rq_vec[0].iov_len = head->iov_len - hdr;
-	v = 0;
-	while (len > rqstp->rq_vec[v].iov_len) {
-		len -= rqstp->rq_vec[v].iov_len;
-		v++;
-		rqstp->rq_vec[v].iov_base = page_address(rqstp->rq_pages[v]);
-		rqstp->rq_vec[v].iov_len = PAGE_SIZE;
-	}
-	rqstp->rq_vec[v].iov_len = len;
-	args->vlen = v + 1;
+
+	args->first.iov_base = (void *)p;
+	args->first.iov_len = head->iov_len - hdr;
 	return 1;
 }
 
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 008ea0b..5029b96 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -969,24 +969,6 @@ static __be32 nfsd4_do_lookupp(struct svc_rqst *rqstp, struct svc_fh *fh)
 	return status;
 }
 
-static int fill_in_write_vector(struct kvec *vec, struct nfsd4_write *write)
-{
-        int i = 1;
-        int buflen = write->wr_buflen;
-
-        vec[0].iov_base = write->wr_head.iov_base;
-        vec[0].iov_len = min_t(int, buflen, write->wr_head.iov_len);
-        buflen -= vec[0].iov_len;
-
-        while (buflen) {
-                vec[i].iov_base = page_address(write->wr_pagelist[i - 1]);
-                vec[i].iov_len = min_t(int, PAGE_SIZE, buflen);
-                buflen -= vec[i].iov_len;
-                i++;
-        }
-        return i;
-}
-
 static __be32
 nfsd4_write(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	    union nfsd4_op_u *u)
@@ -995,8 +977,8 @@ static int fill_in_write_vector(struct kvec *vec, struct nfsd4_write *write)
 	stateid_t *stateid = &write->wr_stateid;
 	struct file *filp = NULL;
 	__be32 status = nfs_ok;
+	unsigned int nvecs;
 	unsigned long cnt;
-	int nvecs;
 
 	if (write->wr_offset >= OFFSET_MAX)
 		return nfserr_inval;
@@ -1012,12 +994,12 @@ static int fill_in_write_vector(struct kvec *vec, struct nfsd4_write *write)
 	write->wr_how_written = write->wr_stable_how;
 	gen_boot_verifier(&write->wr_verifier, SVC_NET(rqstp));
 
-	nvecs = fill_in_write_vector(rqstp->rq_vec, write);
-	WARN_ON_ONCE(nvecs > ARRAY_SIZE(rqstp->rq_vec));
-
+	nvecs = svc_fill_write_vector(rqstp, &write->wr_head, cnt);
+	if (!nvecs)
+		return nfserr_io;
 	status = nfsd_vfs_write(rqstp, &cstate->current_fh, filp,
-				write->wr_offset, rqstp->rq_vec, nvecs, &cnt,
-				write->wr_how_written);
+				write->wr_offset, rqstp->rq_vec, nvecs,
+				&cnt, write->wr_how_written);
 	fput(filp);
 
 	write->wr_bytes_written = cnt;
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 2c61c6b..bd25230 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1285,7 +1285,6 @@ static __be32 nfsd4_decode_opaque(struct nfsd4_compoundargs *argp, struct xdr_ne
 	}
 	write->wr_head.iov_base = p;
 	write->wr_head.iov_len = avail;
-	write->wr_pagelist = argp->pagelist;
 
 	len = XDR_QUADLEN(write->wr_buflen) << 2;
 	if (len >= avail) {
diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
index 43c0419..1995ea6 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -212,13 +212,18 @@
 	struct nfsd_attrstat *resp = rqstp->rq_resp;
 	__be32	nfserr;
 	unsigned long cnt = argp->len;
+	unsigned int nvecs;
 
 	dprintk("nfsd: WRITE    %s %d bytes at %d\n",
 		SVCFH_fmt(&argp->fh),
 		argp->len, argp->offset);
 
-	nfserr = nfsd_write(rqstp, fh_copy(&resp->fh, &argp->fh), argp->offset,
-				rqstp->rq_vec, argp->vlen, &cnt, NFS_DATA_SYNC);
+	nvecs = svc_fill_write_vector(rqstp, &argp->first, cnt);
+	if (!nvecs)
+		return nfserr_io;
+	nfserr = nfsd_write(rqstp, fh_copy(&resp->fh, &argp->fh),
+			    argp->offset, rqstp->rq_vec, nvecs,
+			    &cnt, NFS_DATA_SYNC);
 	return nfsd_return_attrs(nfserr, resp);
 }
 
diff --git a/fs/nfsd/nfsxdr.c b/fs/nfsd/nfsxdr.c
index 644a034..165e25e 100644
--- a/fs/nfsd/nfsxdr.c
+++ b/fs/nfsd/nfsxdr.c
@@ -286,7 +286,6 @@ __be32 *nfs2svc_encode_fattr(struct svc_rqst *rqstp, __be32 *p, struct svc_fh *f
 	struct nfsd_writeargs *args = rqstp->rq_argp;
 	unsigned int len, hdr, dlen;
 	struct kvec *head = rqstp->rq_arg.head;
-	int v;
 
 	p = decode_fh(p, &args->fh);
 	if (!p)
@@ -322,17 +321,8 @@ __be32 *nfs2svc_encode_fattr(struct svc_rqst *rqstp, __be32 *p, struct svc_fh *f
 	if (dlen < XDR_QUADLEN(len)*4)
 		return 0;
 
-	rqstp->rq_vec[0].iov_base = (void*)p;
-	rqstp->rq_vec[0].iov_len = head->iov_len - hdr;
-	v = 0;
-	while (len > rqstp->rq_vec[v].iov_len) {
-		len -= rqstp->rq_vec[v].iov_len;
-		v++;
-		rqstp->rq_vec[v].iov_base = page_address(rqstp->rq_pages[v]);
-		rqstp->rq_vec[v].iov_len = PAGE_SIZE;
-	}
-	rqstp->rq_vec[v].iov_len = len;
-	args->vlen = v + 1;
+	args->first.iov_base = (void *)p;
+	args->first.iov_len = head->iov_len - hdr;
 	return 1;
 }
 
diff --git a/fs/nfsd/xdr.h b/fs/nfsd/xdr.h
index 2f4f22e..a765c41 100644
--- a/fs/nfsd/xdr.h
+++ b/fs/nfsd/xdr.h
@@ -34,7 +34,7 @@ struct nfsd_writeargs {
 	svc_fh			fh;
 	__u32			offset;
 	int			len;
-	int			vlen;
+	struct kvec		first;
 };
 
 struct nfsd_createargs {
diff --git a/fs/nfsd/xdr3.h b/fs/nfsd/xdr3.h
index 056bf8a..deccf7f 100644
--- a/fs/nfsd/xdr3.h
+++ b/fs/nfsd/xdr3.h
@@ -41,7 +41,7 @@ struct nfsd3_writeargs {
 	__u32			count;
 	int			stable;
 	__u32			len;
-	int			vlen;
+	struct kvec		first;
 };
 
 struct nfsd3_createargs {
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index bc29511..d56219d 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -390,7 +390,6 @@ struct nfsd4_write {
 	u32		wr_stable_how;      /* request */
 	u32		wr_buflen;          /* request */
 	struct kvec	wr_head;
-	struct page **	wr_pagelist;        /* request */
 
 	u32		wr_bytes_written;   /* response */
 	u32		wr_how_written;     /* response */
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 786ae22..238b9ae 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -493,6 +493,8 @@ int		   svc_register(const struct svc_serv *, struct net *, const int,
 void		   svc_reserve(struct svc_rqst *rqstp, int space);
 struct svc_pool *  svc_pool_for_cpu(struct svc_serv *serv, int cpu);
 char *		   svc_print_addr(struct svc_rqst *, char *, size_t);
+unsigned int	   svc_fill_write_vector(struct svc_rqst *rqstp,
+					 struct kvec *first, size_t total);
 
 #define	RPC_MAX_ADDRBUFLEN	(63U)
 
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 387cc4a..759b668 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1536,3 +1536,45 @@ u32 svc_max_payload(const struct svc_rqst *rqstp)
 	return max;
 }
 EXPORT_SYMBOL_GPL(svc_max_payload);
+
+/**
+ * svc_fill_write_vector - Construct data argument for VFS write call
+ * @rqstp: svc_rqst to operate on
+ * @first: buffer containing first section of write payload
+ * @total: total number of bytes of write payload
+ *
+ * Returns the number of elements populated in the data argument array.
+ */
+unsigned int svc_fill_write_vector(struct svc_rqst *rqstp, struct kvec *first,
+				   size_t total)
+{
+	struct kvec *vec = rqstp->rq_vec;
+	struct page **pages;
+	unsigned int i;
+
+	/* Some types of transport can present the write payload
+	 * entirely in rq_arg.pages. In this case, @first is empty.
+	 */
+	i = 0;
+	if (first->iov_len) {
+		vec[i].iov_base = first->iov_base;
+		vec[i].iov_len = min_t(size_t, total, first->iov_len);
+		total -= vec[i].iov_len;
+		++i;
+	}
+
+	WARN_ON_ONCE(rqstp->rq_arg.page_base != 0);
+	pages = rqstp->rq_arg.pages;
+	while (total) {
+		vec[i].iov_base = page_address(*pages);
+		vec[i].iov_len = min_t(size_t, total, PAGE_SIZE);
+		total -= vec[i].iov_len;
+		++i;
+
+		++pages;
+	}
+
+	WARN_ON_ONCE(i > ARRAY_SIZE(rqstp->rq_vec));
+	return i;
+}
+EXPORT_SYMBOL_GPL(svc_fill_write_vector);

