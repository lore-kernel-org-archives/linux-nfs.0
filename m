Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B12B547F3D3
	for <linux-nfs@vger.kernel.org>; Sun,  4 Oct 2026 19:40:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791142835; cv=none; b=EZUjYuF0NfKoLGl7S1970uSm5HR8w24uo6Lg7T+25aIB7ioQEioD4mD3cxDjmtVrh+No2nlqMfxjy5qCv0/12w14G17l3PG57VCpC/B0hCLKW+aeRDqBrJslEYTr2kL2BIoAo7NPzRRAXpGyWW8HBNIOzIB+aFlCaOUttOmbzy8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791142835; c=relaxed/simple;
	bh=dlVHY+HO1n5bZm5STmW09zLpnzNHMjwyl7EnOefr6UY=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=H/gVbHNmT7298lCIqBPuQ7Tn8h8vEW5XtygfDUtg7NPcdQ+Ow5vPQnvmJHbB31QaUcWe6xbFGHeVReZmu45Cgu09NbD6+MlF2bS08v8zimW3BoP7bUAjPno7HPplpZ5AQ2PK7msA5T8gUBFVf9FLYxpuYnr4WzdIcrJbs910n1w=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=c7g9FTnv; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="c7g9FTnv"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 13C761F000FF;
	Sun,  4 Oct 2026 19:40:33 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791142833;
	bh=m7aS5e+kTugdF9wZVUb7JB1PT222FXapQNcWY7nQGeQ=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=c7g9FTnvUcJ8UhsIEzYH0sNsXDosS21+jAVgzq4wOSwf0dWYrZZtOKWUS/WLcfGNZ
	 o9zsEArzCZLjUa9o3dAwujuuNlL/KFm5BGO8OsyUHYEI5RZiRBCe8H1SORsgGMCKl8
	 BsG1aChLoyq7rO5LsVM7Q8C85MkQMs8echflKlVGmti+T6NasAx0QQm6STA1jvJDbn
	 sVKOJYR/JE4DfZ7465iHPd4GZ8J6FbUmT9xEe4iwFNtroZaE0sZSHI/5kw70YO5h4V
	 mJY5iLb/FrWCiyZTEOtkYi1QzcboK6vyK63WPocP1DsPjGcqpANFykxec2aPRsoJOh
	 akJwpI+DTZejA==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 3/7] nfsd: locate the READ sink page from the reply buffer
Date: Sun,  4 Oct 2026 15:40:25 -0400
Message-ID: <20261004194029.10714-4-cel@kernel.org>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20261004194029.10714-1-cel@kernel.org>
References: <20261004194029.10714-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

nfsd_iter_read() places file data at *rq_next_page, at an in-page
offset its caller computes from the xdr_buf. The page and the offset
come from different sources, and nothing keeps them consistent.
nfsd4_encode_readv() sets rq_next_page from the xdr_buf before each
call to keep them so, and any other caller has to do the same.

Have nfsd_iter_read() compute both the first sink page and the
in-page offset from rq_res.page_len, the accounting that
xdr_reserve_space_vec() extends once the read completes. NFSv2 and
NFSv3 hand the reply pages to READ untouched, so page_len is zero
there and the sink page is still *rq_next_page. nfsd_iter_read() and
nfsd_direct_read() now write rq_next_page and never read it.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs4xdr.c |  7 +------
 fs/nfsd/vfs.c     | 38 ++++++++++++++++++++------------------
 fs/nfsd/vfs.h     |  3 +--
 3 files changed, 22 insertions(+), 26 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 89230b3206ac..b86d181b58c3 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -5303,17 +5303,12 @@ static __be32 nfsd4_encode_readv(struct nfsd4_compoundres *resp,
 				 unsigned long maxcount)
 {
 	struct xdr_stream *xdr = resp->xdr;
-	unsigned int base = xdr->buf->page_len & ~PAGE_MASK;
 	unsigned int starting_len = xdr->buf->len;
 	__be32 zero = xdr_zero;
 	__be32 nfserr;
 
-	resp->rqstp->rq_next_page = xdr->buf->pages +
-				    (xdr->buf->page_len >> PAGE_SHIFT);
-
 	nfserr = nfsd_iter_read(resp->rqstp, read->rd_fhp, read->rd_nf,
-				read->rd_offset, &maxcount, base,
-				&read->rd_eof);
+				read->rd_offset, &maxcount, &read->rd_eof);
 	read->rd_length = maxcount;
 	if (nfserr)
 		return nfserr;
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 3f328378c805..c7dd94697f2f 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1097,14 +1097,13 @@ __be32 nfsd_splice_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
  *
  * Note that a direct read can be done only when the xdr_buf containing
  * the NFS READ reply does not already have contents in its .pages array.
- * This is due to potentially restrictive alignment requirements on the
- * read buffer. When .page_len and @base are zero, the .pages array is
- * guaranteed to be page-aligned.
+ * Direct I/O alignment can be restrictive, and with .page_len zero the
+ * read buffer starts on a page boundary.
  */
 static noinline_for_stack __be32
 nfsd_direct_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		 struct nfsd_file *nf, loff_t offset, unsigned long *count,
-		 u32 *eof)
+		 struct page **page, u32 *eof)
 {
 	u64 dio_start, dio_end;
 	unsigned long v, total;
@@ -1124,16 +1123,15 @@ nfsd_direct_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
 
 	v = 0;
 	total = dio_end - dio_start;
-	while (total && v < rqstp->rq_maxpages &&
-	       rqstp->rq_next_page < rqstp->rq_page_end) {
+	while (total && v < rqstp->rq_maxpages && page < rqstp->rq_page_end) {
 		len = min_t(size_t, total, PAGE_SIZE);
-		bvec_set_page(&rqstp->rq_bvec[v], *rqstp->rq_next_page,
-			      len, 0);
+		bvec_set_page(&rqstp->rq_bvec[v], *page, len, 0);
 
 		total -= len;
-		++rqstp->rq_next_page;
+		++page;
 		++v;
 	}
+	rqstp->rq_next_page = page;
 
 	trace_nfsd_read_direct(rqstp, fhp, offset, *count - total);
 	iov_iter_bvec(&iter, ITER_DEST, rqstp->rq_bvec, v,
@@ -1191,19 +1189,24 @@ static bool nfsd_direct_read_ok(struct svc_rqst *rqstp, struct nfsd_file *nf)
  * @nf: opened struct nfsd_file of file to be read
  * @offset: starting byte offset
  * @count: IN: requested number of bytes; OUT: number of bytes read
- * @base: offset in first page of read buffer
  * @eof: OUT: set non-zero if operation reached the end of the file
  *
  * Some filesystems or situations cannot use nfsd_splice_read. This
  * function is the slightly less-performant fallback for those cases.
+ * File data lands in @rqstp->rq_res.pages at the offset .page_len
+ * records. On return, @rqstp->rq_next_page points past the last page
+ * offered to the read.
  *
  * Returns nfs_ok on success, otherwise an nfserr stat value is
  * returned.
  */
 __be32 nfsd_iter_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		      struct nfsd_file *nf, loff_t offset, unsigned long *count,
-		      unsigned int base, u32 *eof)
+		      u32 *eof)
 {
+	struct xdr_buf *buf = &rqstp->rq_res;
+	struct page **page = buf->pages + (buf->page_len >> PAGE_SHIFT);
+	unsigned int base = buf->page_len & ~PAGE_MASK;
 	struct file *file = nf->nf_file;
 	unsigned long v, total;
 	struct iov_iter iter;
@@ -1219,7 +1222,7 @@ __be32 nfsd_iter_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	case NFSD_IO_DIRECT:
 		if (nfsd_direct_read_ok(rqstp, nf))
 			return nfsd_direct_read(rqstp, fhp, nf, offset,
-						count, eof);
+						count, page, eof);
 		fallthrough;
 	case NFSD_IO_DONTCACHE:
 		if (file->f_op->fop_flags & FOP_DONTCACHE)
@@ -1231,17 +1234,16 @@ __be32 nfsd_iter_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
 
 	v = 0;
 	total = *count;
-	while (total && v < rqstp->rq_maxpages &&
-	       rqstp->rq_next_page < rqstp->rq_page_end) {
+	while (total && v < rqstp->rq_maxpages && page < rqstp->rq_page_end) {
 		len = min_t(size_t, total, PAGE_SIZE - base);
-		bvec_set_page(&rqstp->rq_bvec[v], *rqstp->rq_next_page,
-			      len, base);
+		bvec_set_page(&rqstp->rq_bvec[v], *page, len, base);
 
 		total -= len;
-		++rqstp->rq_next_page;
+		++page;
 		++v;
 		base = 0;
 	}
+	rqstp->rq_next_page = page;
 
 	trace_nfsd_read_vector(rqstp, fhp, offset, *count - total);
 	iov_iter_bvec(&iter, ITER_DEST, rqstp->rq_bvec, v, *count - total);
@@ -1598,7 +1600,7 @@ __be32 nfsd_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	if (file->f_op->splice_read && nfsd_read_splice_ok(rqstp))
 		err = nfsd_splice_read(rqstp, fhp, file, offset, count, eof);
 	else
-		err = nfsd_iter_read(rqstp, fhp, nf, offset, count, 0, eof);
+		err = nfsd_iter_read(rqstp, fhp, nf, offset, count, eof);
 
 	nfsd_file_put(nf);
 	trace_nfsd_read_done(rqstp, fhp, offset, *count);
diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
index 38f7d36bd4da..8c130473aa79 100644
--- a/fs/nfsd/vfs.h
+++ b/fs/nfsd/vfs.h
@@ -181,8 +181,7 @@ __be32		nfsd_splice_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
 				u32 *eof);
 __be32		nfsd_iter_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
 				struct nfsd_file *nf, loff_t offset,
-				unsigned long *count, unsigned int base,
-				u32 *eof);
+				unsigned long *count, u32 *eof);
 bool		nfsd_read_splice_ok(struct svc_rqst *rqstp);
 __be32		nfsd_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
 				loff_t offset, unsigned long *count,
-- 
2.55.0

