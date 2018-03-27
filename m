Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:40239 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751068AbeC0Oy2 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 27 Mar 2018 10:54:28 -0400
Received: by mail-it0-f65.google.com with SMTP id y20-v6so15641684itc.5
        for <linux-nfs@vger.kernel.org>; Tue, 27 Mar 2018 07:54:28 -0700 (PDT)
Subject: [PATCH v2 18/18] NFSD: Clean up legacy NFS SYMLINK argument XDR
 decoders
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Date: Tue, 27 Mar 2018 10:54:21 -0400
Message-ID: <20180327145421.7710.69145.stgit@oracle-ib-101.nfsv4bat.org>
In-Reply-To: <20180327144420.7710.82288.stgit@oracle-ib-101.nfsv4bat.org>
References: <20180327144420.7710.82288.stgit@oracle-ib-101.nfsv4bat.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Move common code in NFSD's legacy SYMLINK decoders into a helper.
The immediate benefits include:

 - one fewer data copies on transports that support DDP
 - consistent error checking across all versions
 - reduction of code duplication
 - support for both legal forms of SYMLINK requests on RDMA
   transports for all versions of NFS (in particular, NFSv2, for
   completeness)

In the long term, this helper is an appropriate spot to perform a
per-transport call-out to fill the pathname argument using, say,
RDMA Reads.

Filling the pathname in the proc function also means that eventually
the incoming filehandle can be interpreted so that filesystem-
specific memory can be allocated as a sink for the pathname
argument, rather than using anonymous pages.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfsd/nfs3proc.c         |   10 +++++++
 fs/nfsd/nfs3xdr.c          |   51 ++++++++-------------------------
 fs/nfsd/nfsproc.c          |   14 +++++----
 fs/nfsd/nfsxdr.c           |   49 +++++++++++++++++++-------------
 fs/nfsd/xdr.h              |    1 +
 fs/nfsd/xdr3.h             |    1 +
 fs/nfsd/xdr4.h             |    2 +
 include/linux/sunrpc/svc.h |    2 +
 net/sunrpc/svc.c           |   67 ++++++++++++++++++++++++++++++++++++++++++++
 9 files changed, 132 insertions(+), 65 deletions(-)

diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
index 2dd95eb..6259a4b 100644
--- a/fs/nfsd/nfs3proc.c
+++ b/fs/nfsd/nfs3proc.c
@@ -283,6 +283,16 @@
 	struct nfsd3_diropres *resp = rqstp->rq_resp;
 	__be32	nfserr;
 
+	if (argp->tlen == 0)
+		RETURN_STATUS(nfserr_inval);
+	if (argp->tlen > NFS3_MAXPATHLEN)
+		RETURN_STATUS(nfserr_nametoolong);
+
+	argp->tname = svc_fill_symlink_pathname(rqstp, &argp->first,
+						argp->tlen);
+	if (IS_ERR(argp->tname))
+		RETURN_STATUS(nfserrno(PTR_ERR(argp->tname)));
+
 	dprintk("nfsd: SYMLINK(3)  %s %.*s -> %.*s\n",
 				SVCFH_fmt(&argp->ffh),
 				argp->flen, argp->fname,
diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
index e19fc5d..3192b54 100644
--- a/fs/nfsd/nfs3xdr.c
+++ b/fs/nfsd/nfs3xdr.c
@@ -481,51 +481,24 @@ void fill_post_wcc(struct svc_fh *fhp)
 nfs3svc_decode_symlinkargs(struct svc_rqst *rqstp, __be32 *p)
 {
 	struct nfsd3_symlinkargs *args = rqstp->rq_argp;
-	unsigned int len, avail;
-	char *old, *new;
-	struct kvec *vec;
+	char *base = (char *)p;
+	size_t dlen;
 
 	if (!(p = decode_fh(p, &args->ffh)) ||
-	    !(p = decode_filename(p, &args->fname, &args->flen))
-		)
+	    !(p = decode_filename(p, &args->fname, &args->flen)))
 		return 0;
 	p = decode_sattr3(p, &args->attrs);
 
-	/* now decode the pathname, which might be larger than the first page.
-	 * As we have to check for nul's anyway, we copy it into a new page
-	 * This page appears in the rq_res.pages list, but as pages_len is always
-	 * 0, it won't get in the way
-	 */
-	len = ntohl(*p++);
-	if (len == 0 || len > NFS3_MAXPATHLEN || len >= PAGE_SIZE)
-		return 0;
-	args->tname = new = page_address(*(rqstp->rq_next_page++));
-	args->tlen = len;
-	/* first copy and check from the first page */
-	old = (char*)p;
-	vec = &rqstp->rq_arg.head[0];
-	if ((void *)old > vec->iov_base + vec->iov_len)
-		return 0;
-	avail = vec->iov_len - (old - (char*)vec->iov_base);
-	while (len && avail && *old) {
-		*new++ = *old++;
-		len--;
-		avail--;
-	}
-	/* now copy next page if there is one */
-	if (len && !avail && rqstp->rq_arg.page_len) {
-		avail = min_t(unsigned int, rqstp->rq_arg.page_len, PAGE_SIZE);
-		old = page_address(rqstp->rq_arg.pages[0]);
-	}
-	while (len && avail && *old) {
-		*new++ = *old++;
-		len--;
-		avail--;
-	}
-	*new = '\0';
-	if (len)
-		return 0;
+	args->tlen = ntohl(*p++);
 
+	args->first.iov_base = p;
+	args->first.iov_len = rqstp->rq_arg.head[0].iov_len;
+	args->first.iov_len -= (char *)p - base;
+
+	dlen = args->first.iov_len + rqstp->rq_arg.page_len +
+	       rqstp->rq_arg.tail[0].iov_len;
+	if (dlen < XDR_QUADLEN(args->tlen) << 2)
+		return 0;
 	return 1;
 }
 
diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
index 1995ea6..f107f9f 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -449,17 +449,19 @@
 	struct svc_fh	newfh;
 	__be32		nfserr;
 
+	if (argp->tlen > NFS_MAXPATHLEN)
+		return nfserr_nametoolong;
+
+	argp->tname = svc_fill_symlink_pathname(rqstp, &argp->first,
+						argp->tlen);
+	if (IS_ERR(argp->tname))
+		return nfserrno(PTR_ERR(argp->tname));
+
 	dprintk("nfsd: SYMLINK  %s %.*s -> %.*s\n",
 		SVCFH_fmt(&argp->ffh), argp->flen, argp->fname,
 		argp->tlen, argp->tname);
 
 	fh_init(&newfh, NFS_FHSIZE);
-	/*
-	 * Crazy hack: the request fits in a page, and already-decoded
-	 * attributes follow argp->tname, so it's safe to just write a
-	 * null to ensure it's null-terminated:
-	 */
-	argp->tname[argp->tlen] = '\0';
 	nfserr = nfsd_symlink(rqstp, &argp->ffh, argp->fname, argp->flen,
 						 argp->tname, &newfh);
 
diff --git a/fs/nfsd/nfsxdr.c b/fs/nfsd/nfsxdr.c
index db24ae8..a43e826 100644
--- a/fs/nfsd/nfsxdr.c
+++ b/fs/nfsd/nfsxdr.c
@@ -71,22 +71,6 @@ __be32 *nfs2svc_decode_fh(__be32 *p, struct svc_fh *fhp)
 }
 
 static __be32 *
-decode_pathname(__be32 *p, char **namp, unsigned int *lenp)
-{
-	char		*name;
-	unsigned int	i;
-
-	if ((p = xdr_decode_string_inplace(p, namp, lenp, NFS_MAXPATHLEN)) != NULL) {
-		for (i = 0, name = *namp; i < *lenp; i++, name++) {
-			if (*name == '\0')
-				return NULL;
-		}
-	}
-
-	return p;
-}
-
-static __be32 *
 decode_sattr(__be32 *p, struct iattr *iap)
 {
 	u32	tmp, tmp1;
@@ -384,14 +368,39 @@ __be32 *nfs2svc_encode_fattr(struct svc_rqst *rqstp, __be32 *p, struct svc_fh *f
 nfssvc_decode_symlinkargs(struct svc_rqst *rqstp, __be32 *p)
 {
 	struct nfsd_symlinkargs *args = rqstp->rq_argp;
+	char *base = (char *)p;
+	size_t xdrlen;
 
 	if (   !(p = decode_fh(p, &args->ffh))
-	    || !(p = decode_filename(p, &args->fname, &args->flen))
-	    || !(p = decode_pathname(p, &args->tname, &args->tlen)))
+	    || !(p = decode_filename(p, &args->fname, &args->flen)))
 		return 0;
-	p = decode_sattr(p, &args->attrs);
 
-	return xdr_argsize_check(rqstp, p);
+	args->tlen = ntohl(*p++);
+	if (args->tlen == 0)
+		return 0;
+
+	args->first.iov_base = p;
+	args->first.iov_len = rqstp->rq_arg.head[0].iov_len;
+	args->first.iov_len -= (char *)p - base;
+
+	/* This request is never larger than a page. Therefore,
+	 * transport will deliver either:
+	 * 1. pathname in the pagelist -> sattr is in the tail.
+	 * 2. everything in the head buffer -> sattr is in the head.
+	 */
+	if (rqstp->rq_arg.page_len) {
+		if (args->tlen != rqstp->rq_arg.page_len)
+			return 0;
+		p = rqstp->rq_arg.tail[0].iov_base;
+	} else {
+		xdrlen = XDR_QUADLEN(args->tlen);
+		if (xdrlen > args->first.iov_len - (8 * sizeof(__be32)))
+			return 0;
+		p += xdrlen;
+	}
+	decode_sattr(p, &args->attrs);
+
+	return 1;
 }
 
 int
diff --git a/fs/nfsd/xdr.h b/fs/nfsd/xdr.h
index a765c41..ea7cca3 100644
--- a/fs/nfsd/xdr.h
+++ b/fs/nfsd/xdr.h
@@ -72,6 +72,7 @@ struct nfsd_symlinkargs {
 	char *			tname;
 	unsigned int		tlen;
 	struct iattr		attrs;
+	struct kvec		first;
 };
 
 struct nfsd_readdirargs {
diff --git a/fs/nfsd/xdr3.h b/fs/nfsd/xdr3.h
index deccf7f..2cb29e9 100644
--- a/fs/nfsd/xdr3.h
+++ b/fs/nfsd/xdr3.h
@@ -90,6 +90,7 @@ struct nfsd3_symlinkargs {
 	char *			tname;
 	unsigned int		tlen;
 	struct iattr		attrs;
+	struct kvec		first;
 };
 
 struct nfsd3_readdirargs {
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index bc29511..fdab2a2 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -110,6 +110,7 @@ struct nfsd4_create {
 		struct {
 			u32 datalen;
 			char *data;
+			struct kvec first;
 		} link;   /* NF4LNK */
 		struct {
 			u32 specdata1;
@@ -124,6 +125,7 @@ struct nfsd4_create {
 };
 #define cr_datalen	u.link.datalen
 #define cr_data		u.link.data
+#define cr_first	u.link.first
 #define cr_specdata1	u.dev.specdata1
 #define cr_specdata2	u.dev.specdata2
 
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index fb3fcac..574368e 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -497,6 +497,8 @@ int		   svc_register(const struct svc_serv *, struct net *, const int,
 char *		   svc_print_addr(struct svc_rqst *, char *, size_t);
 unsigned int	   svc_fill_write_vector(struct svc_rqst *rqstp,
 					 struct kvec *first, size_t total);
+char		  *svc_fill_symlink_pathname(struct svc_rqst *rqstp,
+					     struct kvec *first, size_t total);
 
 #define	RPC_MAX_ADDRBUFLEN	(63U)
 
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index a155e2d..30a4226 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1575,3 +1575,70 @@ unsigned int svc_fill_write_vector(struct svc_rqst *rqstp, struct kvec *first,
 	return i;
 }
 EXPORT_SYMBOL_GPL(svc_fill_write_vector);
+
+/**
+ * svc_fill_symlink_pathname - Construct pathname argument for VFS symlink call
+ * @rqstp: svc_rqst to operate on
+ * @first: buffer containing first section of pathname
+ * @total: total length of the pathname argument
+ *
+ * Returns pointer to a NUL-terminated string, or an ERR_PTR. The buffer is
+ * released automatically when @rqstp is recycled.
+ */
+char *svc_fill_symlink_pathname(struct svc_rqst *rqstp, struct kvec *first,
+				size_t total)
+{
+	struct xdr_buf *arg = &rqstp->rq_arg;
+	struct page **pages;
+	char *result;
+
+	/* VFS API demands a NUL-terminated pathname. This function
+	 * uses a page from @rqstp as the pathname buffer, to enable
+	 * direct placement. Thus the total buffer size is PAGE_SIZE.
+	 * Space in this buffer for NUL-termination requires that we
+	 * cap the size of the returned symlink pathname just a
+	 * little early.
+	 */
+	if (total > PAGE_SIZE - 1)
+		return ERR_PTR(-ENAMETOOLONG);
+
+	/* Some types of transport can present the pathname entirely
+	 * in rq_arg.pages. If not, then copy the pathname into one
+	 * page.
+	 */
+	pages = arg->pages;
+	WARN_ON_ONCE(arg->page_base != 0);
+	if (first->iov_base == 0) {
+		result = page_address(*pages);
+		result[total] = '\0';
+	} else {
+		size_t len, remaining;
+		char *dst;
+
+		result = page_address(*(rqstp->rq_next_page++));
+		dst = result;
+		remaining = total;
+
+		len = min_t(size_t, total, first->iov_len);
+		memcpy(dst, first->iov_base, len);
+		dst += len;
+		remaining -= len;
+
+		/* No more than one page left */
+		if (remaining) {
+			len = min_t(size_t, remaining, PAGE_SIZE);
+			memcpy(dst, page_address(*pages), len);
+			dst += len;
+		}
+
+		*dst = '\0';
+	}
+
+	/* Sanity check: we don't allow the pathname argument to
+	 * contain a NUL byte.
+	 */
+	if (strlen(result) != total)
+		return ERR_PTR(-EINVAL);
+	return result;
+}
+EXPORT_SYMBOL_GPL(svc_fill_symlink_pathname);

