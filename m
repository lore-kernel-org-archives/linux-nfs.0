Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:7269 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752332Ab3AWWzl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Jan 2013 17:55:41 -0500
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r0NMtfli000606
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 23 Jan 2013 17:55:41 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 7/7] nfsd4: readdir encoding
Date: Wed, 23 Jan 2013 17:55:38 -0500
Message-Id: <1358981738-5649-8-git-send-email-bfields@redhat.com>
In-Reply-To: <1358981738-5649-1-git-send-email-bfields@redhat.com>
References: <1358981738-5649-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Rewrite readdir encoding using the new xdr primitives.  This allows us
to return more than 4k of data in a readdir reply, improving performance
on large directories.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4xdr.c | 157 +++++++++++++++++++++++++++++-------------------------
 fs/nfsd/xdr4.h    |   5 +-
 2 files changed, 85 insertions(+), 77 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index a378435..84ad067 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1870,6 +1870,11 @@ static void write64(struct svcxdr_ptr *ptr, u64 n)
 	writemem(ptr, i, sizeof(i));
 }
 
+static void write_nfserr(struct svcxdr_ptr *ptr, __be32 err)
+{
+	writemem(ptr, &err, sizeof(err));
+}
+
 static bool write_opaque(struct svcxdr_stream *xdr, const void *data, int len)
 {
 	struct svcxdr_ptr ptr;
@@ -2672,7 +2677,7 @@ static inline int attributes_need_mount(u32 *bmval)
 
 static __be32
 nfsd4_encode_dirent_fattr(struct nfsd4_readdir *cd,
-		const char *name, int namlen, __be32 **p, int buflen)
+		const char *name, int namlen, struct svcxdr_stream *xdr)
 {
 	struct svc_export *exp = cd->rd_fhp->fh_export;
 	struct dentry *dentry;
@@ -2724,7 +2729,7 @@ nfsd4_encode_dirent_fattr(struct nfsd4_readdir *cd,
 
 	}
 out_encode:
-	nfserr = nfsd4_encode_fattr_to_buffer(p, buflen, NULL, exp, dentry, cd->rd_bmval,
+	nfserr = nfsd4_encode_fattr(xdr, NULL, exp, dentry, cd->rd_bmval,
 					cd->rd_rqstp, ignore_crossmnt);
 out_put:
 	dput(dentry);
@@ -2732,18 +2737,20 @@ out_put:
 	return nfserr;
 }
 
-static __be32 *
-nfsd4_encode_rdattr_error(__be32 *p, int buflen, __be32 nfserr)
+static bool
+nfsd4_encode_rdattr_error(struct svcxdr_stream *xdr, __be32 nfserr)
 {
-	if (buflen < 6)
-		return NULL;
-	*p++ = htonl(2);
-	*p++ = htonl(FATTR4_WORD0_RDATTR_ERROR); /* bmval0 */
-	*p++ = htonl(0);			 /* bmval1 */
+	struct svcxdr_ptr ptr;
 
-	*p++ = htonl(4);     /* attribute length */
-	*p++ = nfserr;       /* no htonl */
-	return p;
+	if (!svcxdr_reserve_space(xdr, &ptr, 5*4))
+		return false;
+	write32(&ptr, 2);
+	write32(&ptr, FATTR4_WORD0_RDATTR_ERROR);	/* bmval0 */
+	write32(&ptr, 0);				/* bmval1 */
+
+	write32(&ptr, 4);				/* attribute length */
+	write_nfserr(&ptr, nfserr);
+	return true;
 }
 
 static int
@@ -2752,9 +2759,10 @@ nfsd4_encode_dirent(void *ccdv, const char *name, int namlen,
 {
 	struct readdir_cd *ccd = ccdv;
 	struct nfsd4_readdir *cd = container_of(ccd, struct nfsd4_readdir, common);
-	int buflen;
-	__be32 *p = cd->buffer;
-	__be32 *cookiep;
+	struct svcxdr_stream *xdr = cd->xdr;
+	struct svcxdr_ptr start = xdr->ptr;
+	struct svcxdr_ptr cookiep;
+	struct svcxdr_ptr ptr;
 	__be32 nfserr = nfserr_toosmall;
 
 	/* In nfsv4, "." and ".." never make it onto the wire.. */
@@ -2763,27 +2771,30 @@ nfsd4_encode_dirent(void *ccdv, const char *name, int namlen,
 		return 0;
 	}
 
-	if (cd->offset)
-		xdr_encode_hyper(cd->offset, (u64) offset);
+	if (cd->offset.p) {
+		ptr = cd->offset;
+		write64(&ptr, (u64)offset);
+	}
 
-	buflen = cd->buflen - 4 - XDR_QUADLEN(namlen);
-	if (buflen < 0)
+	if (!svcxdr_reserve_space(xdr, &ptr, 3*4))
 		goto fail;
+	write32(&ptr, 1);			/* mark entry present */
+	cookiep = ptr;
+	write64(&ptr, NFS_OFFSET_MAX);		/* offset of next entry */
 
-	*p++ = xdr_one;                             /* mark entry present */
-	cookiep = p;
-	p = xdr_encode_hyper(p, NFS_OFFSET_MAX);    /* offset of next entry */
-	p = xdr_encode_array(p, name, namlen);      /* name length & name */
+	if (!write_opaque(xdr, name, namlen))
+		goto fail;
 
-	nfserr = nfsd4_encode_dirent_fattr(cd, name, namlen, &p, buflen);
+	nfserr = nfsd4_encode_dirent_fattr(cd, name, namlen, xdr);
 	switch (nfserr) {
 	case nfs_ok:
 		break;
 	case nfserr_resource:
 		nfserr = nfserr_toosmall;
 		goto fail;
-	case nfserr_noent:
-		goto skip_entry;
+	case nfserr_noent: /* skip entry: */
+		svcxdr_reset(xdr, &start);
+		goto out;
 	default:
 		/*
 		 * If the client requested the RDATTR_ERROR attribute,
@@ -2794,19 +2805,17 @@ nfsd4_encode_dirent(void *ccdv, const char *name, int namlen,
 		 */
 		if (!(cd->rd_bmval[0] & FATTR4_WORD0_RDATTR_ERROR))
 			goto fail;
-		p = nfsd4_encode_rdattr_error(p, buflen, nfserr);
-		if (p == NULL) {
+		if (!nfsd4_encode_rdattr_error(xdr, nfserr)) {
 			nfserr = nfserr_toosmall;
 			goto fail;
 		}
 	}
-	cd->buflen -= (p - cd->buffer);
-	cd->buffer = p;
 	cd->offset = cookiep;
-skip_entry:
+out:
 	cd->common.err = nfs_ok;
 	return 0;
 fail:
+	svcxdr_reset(xdr, &start);
 	cd->common.err = nfserr;
 	return -EINVAL;
 }
@@ -3231,46 +3240,45 @@ nfsd4_encode_readdir(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4
 {
 	int maxcount;
 	loff_t offset;
-	__be32 *page, *savep, *tailbase;
-	__be32 *p;
+	struct svcxdr_stream xdr;
+	struct svcxdr_ptr p;
+	struct svcxdr_ptr savep;
 
 	if (nfserr)
 		return nfserr;
-	if (resp->xbuf->page_len)
-		return nfserr_resource;
 	if (!*resp->rqstp->rq_next_page)
 		return nfserr_resource;
 
-	RESERVE_SPACE(NFS4_VERIFIER_SIZE);
-	savep = p;
-
-	/* XXX: Following NFSv3, we ignore the READDIR verifier for now. */
-	WRITE32(0);
-	WRITE32(0);
-	ADJUST_ARGS();
-	resp->xbuf->head[0].iov_len = ((char*)resp->p) - (char*)resp->xbuf->head[0].iov_base;
-	tailbase = p;
-
-	maxcount = PAGE_SIZE;
+	nfserr = svcxdr_stream_init_from_resp(&xdr, resp);
+	if (nfserr)
+		return nfserr;
+	maxcount = svc_max_payload(resp->rqstp);
 	if (maxcount > readdir->rd_maxcount)
 		maxcount = readdir->rd_maxcount;
-
 	/*
-	 * Convert from bytes to words, account for the two words already
-	 * written, make sure to leave two words at the end for the next
-	 * pointer and eof field.
+	 * Allow space for the two words (entry follows, eof) at the
+	 * end.  Note we generally assume rd_maxcount is at fault.
+	 * Which is the most likely case.  If someone sent a readdir at
+	 * the end of an extremely long compound this might result in us
+	 * returning the wrong error:
 	 */
-	maxcount = (maxcount >> 2) - 4;
-	if (maxcount < 0) {
-		nfserr =  nfserr_toosmall;
+	maxcount -= 8;
+	nfserr = nfserr_toosmall;
+	if (maxcount < 0)
 		goto err_no_verf;
-	}
 
-	page = page_address(*(resp->rqstp->rq_next_page++));
+	xdr.maxbytes = maxcount;
+	if (!svcxdr_reserve_space(&xdr, &p, 8))
+		goto err_no_verf;
+	savep = p;
+
+	/* XXX: Following NFSv3, we ignore the READDIR verifier for now. */
+	write32(&p, 0);
+	write32(&p, 0);
+
+	readdir->xdr = &xdr;
 	readdir->common.err = 0;
-	readdir->buflen = maxcount;
-	readdir->buffer = page;
-	readdir->offset = NULL;
+	readdir->offset.p = NULL;
 
 	offset = readdir->rd_cookie;
 	nfserr = nfsd_readdir(readdir->rd_rqstp, readdir->rd_fhp,
@@ -3278,30 +3286,31 @@ nfsd4_encode_readdir(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4
 			      &readdir->common, nfsd4_encode_dirent);
 	if (nfserr == nfs_ok &&
 	    readdir->common.err == nfserr_toosmall &&
-	    readdir->buffer == page) 
+	    xdr.ptr.p == xdr.last_commit.p + 2) /* We made no progress at all */
 		nfserr = nfserr_toosmall;
 	if (nfserr)
 		goto err_no_verf;
 
-	if (readdir->offset)
-		xdr_encode_hyper(readdir->offset, offset);
-
-	p = readdir->buffer;
-	*p++ = 0;	/* no more entries */
-	*p++ = htonl(readdir->common.err == nfserr_eof);
-	resp->xbuf->page_len = ((char*)p) -
-		(char*)page_address(*(resp->rqstp->rq_next_page-1));
+	if (readdir->offset.p) {
+		p = readdir->offset;
+		write64(&p, offset);
+	}
+	xdr.maxbytes += 8;
+	if (!svcxdr_reserve_space(&xdr, &p, 8)) {
+		WARN_ON_ONCE(1);
+		goto err_no_verf;
+	}
+	write32(&p, 0);	/* no more entries */
+	write32(&p, readdir->common.err == nfserr_eof);
 
-	/* Use rest of head for padding and remaining ops: */
-	resp->xbuf->tail[0].iov_base = tailbase;
-	resp->xbuf->tail[0].iov_len = 0;
-	resp->p = resp->xbuf->tail[0].iov_base;
-	resp->end = resp->p + (PAGE_SIZE - resp->xbuf->head[0].iov_len)/4;
+	svcxdr_stream_update_resp(&xdr, resp);
 
 	return 0;
 err_no_verf:
-	p = savep;
-	ADJUST_ARGS();
+	/*
+	 * returning without svcxdr_stream_update_resp will leave
+	 * xdr_buf unchanged, as if we'd encoded nothing:
+	 */
 	return nfserr;
 }
 
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index 36b8c2c..9c58f05 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -299,9 +299,8 @@ struct nfsd4_readdir {
 	struct svc_fh * rd_fhp;             /* response */
 
 	struct readdir_cd	common;
-	__be32 *		buffer;
-	int			buflen;
-	__be32 *		offset;
+	struct svcxdr_stream	*xdr;
+	struct svcxdr_ptr	offset;
 };
 
 struct nfsd4_release_lockowner {
-- 
1.7.11.7

