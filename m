Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f169.google.com ([209.85.192.169]:58505 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752055AbaFJKI3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Jun 2014 06:08:29 -0400
Received: by mail-pd0-f169.google.com with SMTP id w10so5961494pde.28
        for <linux-nfs@vger.kernel.org>; Tue, 10 Jun 2014 03:08:29 -0700 (PDT)
Message-ID: <5396D913.7090909@gmail.com>
Date: Tue, 10 Jun 2014 18:08:19 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>, kinglongmee@gmail.com
Subject: [PATCH] NFSD: Using min/max/min_t/max_t for calculate
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfs3proc.c |  6 +-----
 fs/nfsd/nfs3xdr.c  | 30 ++++++++----------------------
 fs/nfsd/nfs4proc.c | 12 ++++--------
 fs/nfsd/nfs4xdr.c  | 10 +++-------
 fs/nfsd/nfsctl.c   |  9 +++------
 fs/nfsd/nfssvc.c   | 11 +++++------
 fs/nfsd/nfsxdr.c   | 14 ++++++--------
 fs/nfsd/vfs.c      |  3 +--
 8 files changed, 31 insertions(+), 64 deletions(-)

diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
index 4012899..61ef42c 100644
--- a/fs/nfsd/nfs3proc.c
+++ b/fs/nfsd/nfs3proc.c
@@ -157,11 +157,7 @@ nfsd3_proc_read(struct svc_rqst *rqstp, struct nfsd3_readargs *argp,
 	 * 1 (status) + 22 (post_op_attr) + 1 (count) + 1 (eof)
 	 * + 1 (xdr opaque byte count) = 26
 	 */
-
-	resp->count = argp->count;
-	if (max_blocksize < resp->count)
-		resp->count = max_blocksize;
-
+	resp->count = min(argp->count, max_blocksize);
 	svc_reserve_auth(rqstp, ((1 + NFS3_POST_OP_ATTR_WORDS + 3)<<2) + resp->count +4);
 
 	fh_copy(&resp->fh, &argp->fh);
diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
index e6c01e8..39c5eb3 100644
--- a/fs/nfsd/nfs3xdr.c
+++ b/fs/nfsd/nfs3xdr.c
@@ -120,10 +120,7 @@ decode_sattr3(__be32 *p, struct iattr *iap)
 
 		iap->ia_valid |= ATTR_SIZE;
 		p = xdr_decode_hyper(p, &newsize);
-		if (newsize <= NFS_OFFSET_MAX)
-			iap->ia_size = newsize;
-		else
-			iap->ia_size = NFS_OFFSET_MAX;
+		iap->ia_size = min_t(u64, newsize, NFS_OFFSET_MAX);
 	}
 	if ((tmp = ntohl(*p++)) == 1) {	/* set to server time */
 		iap->ia_valid |= ATTR_ATIME;
@@ -338,10 +335,8 @@ nfs3svc_decode_readargs(struct svc_rqst *rqstp, __be32 *p,
 		return 0;
 	p = xdr_decode_hyper(p, &args->offset);
 
-	len = args->count = ntohl(*p++);
-
-	if (len > max_blocksize)
-		len = max_blocksize;
+	args->count = ntohl(*p++);
+	len = min(args->count, max_blocksize);
 
 	/* set up the kvec */
 	v=0;
@@ -349,7 +344,7 @@ nfs3svc_decode_readargs(struct svc_rqst *rqstp, __be32 *p,
 		struct page *p = *(rqstp->rq_next_page++);
 
 		rqstp->rq_vec[v].iov_base = page_address(p);
-		rqstp->rq_vec[v].iov_len = len < PAGE_SIZE? len : PAGE_SIZE;
+		rqstp->rq_vec[v].iov_len = min_t(unsigned int, len, PAGE_SIZE);
 		len -= rqstp->rq_vec[v].iov_len;
 		v++;
 	}
@@ -484,9 +479,7 @@ nfs3svc_decode_symlinkargs(struct svc_rqst *rqstp, __be32 *p,
 	}
 	/* now copy next page if there is one */
 	if (len && !avail && rqstp->rq_arg.page_len) {
-		avail = rqstp->rq_arg.page_len;
-		if (avail > PAGE_SIZE)
-			avail = PAGE_SIZE;
+		avail = min_t(unsigned int, rqstp->rq_arg.page_len, PAGE_SIZE);
 		old = page_address(rqstp->rq_arg.pages[0]);
 	}
 	while (len && avail && *old) {
@@ -571,10 +564,7 @@ nfs3svc_decode_readdirargs(struct svc_rqst *rqstp, __be32 *p,
 	args->verf   = p; p += 2;
 	args->dircount = ~0;
 	args->count  = ntohl(*p++);
-
-	if (args->count > PAGE_SIZE)
-		args->count = PAGE_SIZE;
-
+	args->count  = min_t(u32, args->count, PAGE_SIZE);
 	args->buffer = page_address(*(rqstp->rq_next_page++));
 
 	return xdr_argsize_check(rqstp, p);
@@ -595,10 +585,7 @@ nfs3svc_decode_readdirplusargs(struct svc_rqst *rqstp, __be32 *p,
 	args->dircount = ntohl(*p++);
 	args->count    = ntohl(*p++);
 
-	len = (args->count > max_blocksize) ? max_blocksize :
-						  args->count;
-	args->count = len;
-
+	len = args->count = min(args->count, max_blocksize);
 	while (len > 0) {
 		struct page *p = *(rqstp->rq_next_page++);
 		if (!args->buffer)
@@ -913,8 +900,7 @@ encode_entry(struct readdir_cd *ccd, const char *name, int namlen,
 	 */
 
 	/* truncate filename if too long */
-	if (namlen > NFS3_MAXNAMLEN)
-		namlen = NFS3_MAXNAMLEN;
+	namlen = min(namlen, NFS3_MAXNAMLEN);
 
 	slen = XDR_QUADLEN(namlen);
 	elen = slen + NFS3_ENTRY_BAGGAGE
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 6851b00..baa3803 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1529,21 +1529,17 @@ static inline u32 nfsd4_read_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op)
 	u32 maxcount = 0, rlen = 0;
 
 	maxcount = svc_max_payload(rqstp);
-	rlen = op->u.read.rd_length;
-
-	if (rlen > maxcount)
-		rlen = maxcount;
+	rlen = min(op->u.read.rd_length, maxcount);
 
 	return (op_encode_hdr_size + 2 + XDR_QUADLEN(rlen)) * sizeof(__be32);
 }
 
 static inline u32 nfsd4_readdir_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op)
 {
-	u32 maxcount = svc_max_payload(rqstp);
-	u32 rlen = op->u.readdir.rd_maxcount;
+	u32 maxcount = 0, rlen = 0;
 
-	if (rlen > maxcount)
-		rlen = maxcount;
+	maxcount = svc_max_payload(rqstp);
+	rlen = min(op->u.readdir.rd_maxcount, maxcount);
 
 	return (op_encode_hdr_size + op_encode_verifier_maxsz +
 		XDR_QUADLEN(rlen)) * sizeof(__be32);
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 2d305a1..53ca43c 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3133,9 +3133,7 @@ static __be32 nfsd4_encode_readv(struct nfsd4_compoundres *resp,
 	len = maxcount;
 	v = 0;
 
-	thislen = (void *)xdr->end - (void *)xdr->p;
-	if (len < thislen)
-		thislen = len;
+	thislen = min(len, ((void *)xdr->end - (void *)xdr->p));
 	p = xdr_reserve_space(xdr, (thislen+3)&~3);
 	WARN_ON_ONCE(!p);
 	resp->rqstp->rq_vec[v].iov_base = p;
@@ -3202,10 +3200,8 @@ nfsd4_encode_read(struct nfsd4_compoundres *resp, __be32 nfserr,
 	xdr_commit_encode(xdr);
 
 	maxcount = svc_max_payload(resp->rqstp);
-	if (maxcount > xdr->buf->buflen - xdr->buf->len)
-		maxcount = xdr->buf->buflen - xdr->buf->len;
-	if (maxcount > read->rd_length)
-		maxcount = read->rd_length;
+	maxcount = min_t(unsigned long, maxcount, (xdr->buf->buflen - xdr->buf->len));
+	maxcount = min_t(unsigned long, maxcount, read->rd_length);
 
 	if (!read->rd_filp) {
 		err = nfsd_get_tmp_read_open(resp->rqstp, read->rd_fhp,
diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 5184404..6a6f65c 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -369,8 +369,7 @@ static ssize_t write_filehandle(struct file *file, char *buf, size_t size)
 
 	if (maxsize < NFS_FHSIZE)
 		return -EINVAL;
-	if (maxsize > NFS3_FHSIZE)
-		maxsize = NFS3_FHSIZE;
+	maxsize = min(maxsize, NFS3_FHSIZE);
 
 	if (qword_get(&mesg, mesg, size)>0)
 		return -EINVAL;
@@ -871,10 +870,8 @@ static ssize_t write_maxblksize(struct file *file, char *buf, size_t size)
 		/* force bsize into allowed range and
 		 * required alignment.
 		 */
-		if (bsize < 1024)
-			bsize = 1024;
-		if (bsize > NFSSVC_MAXBLKSIZE)
-			bsize = NFSSVC_MAXBLKSIZE;
+		bsize = max_t(int, bsize, 1024);
+		bsize = min_t(int, bsize, NFSSVC_MAXBLKSIZE);
 		bsize &= ~(1024-1);
 		mutex_lock(&nfsd_mutex);
 		if (nn->nfsd_serv) {
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 1879e43..2094741 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -469,8 +469,7 @@ int nfsd_set_nrthreads(int n, int *nthreads, struct net *net)
 	/* enforce a global maximum number of threads */
 	tot = 0;
 	for (i = 0; i < n; i++) {
-		if (nthreads[i] > NFSD_MAXSERVS)
-			nthreads[i] = NFSD_MAXSERVS;
+		nthreads[i] = min(nthreads[i], NFSD_MAXSERVS);
 		tot += nthreads[i];
 	}
 	if (tot > NFSD_MAXSERVS) {
@@ -519,11 +518,11 @@ nfsd_svc(int nrservs, struct net *net)
 
 	mutex_lock(&nfsd_mutex);
 	dprintk("nfsd: creating service\n");
-	if (nrservs <= 0)
-		nrservs = 0;
-	if (nrservs > NFSD_MAXSERVS)
-		nrservs = NFSD_MAXSERVS;
+
+	nrservs = max(nrservs, 0);
+	nrservs = min(nrservs, NFSD_MAXSERVS);
 	error = 0;
+
 	if (nrservs == 0 && nn->nfsd_serv == NULL)
 		goto out;
 
diff --git a/fs/nfsd/nfsxdr.c b/fs/nfsd/nfsxdr.c
index 1ac306b..412d706 100644
--- a/fs/nfsd/nfsxdr.c
+++ b/fs/nfsd/nfsxdr.c
@@ -257,8 +257,7 @@ nfssvc_decode_readargs(struct svc_rqst *rqstp, __be32 *p,
 	len = args->count     = ntohl(*p++);
 	p++; /* totalcount - unused */
 
-	if (len > NFSSVC_MAXBLKSIZE_V2)
-		len = NFSSVC_MAXBLKSIZE_V2;
+	len = min_t(unsigned int, len, NFSSVC_MAXBLKSIZE_V2);
 
 	/* set up somewhere to store response.
 	 * We take pages, put them on reslist and include in iovec
@@ -268,7 +267,7 @@ nfssvc_decode_readargs(struct svc_rqst *rqstp, __be32 *p,
 		struct page *p = *(rqstp->rq_next_page++);
 
 		rqstp->rq_vec[v].iov_base = page_address(p);
-		rqstp->rq_vec[v].iov_len = len < PAGE_SIZE?len:PAGE_SIZE;
+		rqstp->rq_vec[v].iov_len = min_t(unsigned int, len, PAGE_SIZE);
 		len -= rqstp->rq_vec[v].iov_len;
 		v++;
 	}
@@ -400,9 +399,7 @@ nfssvc_decode_readdirargs(struct svc_rqst *rqstp, __be32 *p,
 		return 0;
 	args->cookie = ntohl(*p++);
 	args->count  = ntohl(*p++);
-	if (args->count > PAGE_SIZE)
-		args->count = PAGE_SIZE;
-
+	args->count  = min_t(u32, args->count, PAGE_SIZE);
 	args->buffer = page_address(*(rqstp->rq_next_page++));
 
 	return xdr_argsize_check(rqstp, p);
@@ -516,10 +513,11 @@ nfssvc_encode_entry(void *ccdv, const char *name,
 	}
 	if (cd->offset)
 		*cd->offset = htonl(offset);
-	if (namlen > NFS2_MAXNAMLEN)
-		namlen = NFS2_MAXNAMLEN;/* truncate filename */
 
+	/* truncate filename */
+	namlen = min(namlen, NFS2_MAXNAMLEN);
 	slen = XDR_QUADLEN(namlen);
+
 	if ((buflen = cd->buflen - slen - 4) < 0) {
 		cd->common.err = nfserr_toosmall;
 		return -EINVAL;
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 140c496..7498099 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -2093,8 +2093,7 @@ nfsd_racache_init(int cache_size)
 	if (raparm_hash[0].pb_head)
 		return 0;
 	nperbucket = DIV_ROUND_UP(cache_size, RAPARM_HASH_SIZE);
-	if (nperbucket < 2)
-		nperbucket = 2;
+	nperbucket = max(2, nperbucket);
 	cache_size = nperbucket * RAPARM_HASH_SIZE;
 
 	dprintk("nfsd: allocating %d readahead buffers.\n", cache_size);
-- 
1.9.3

