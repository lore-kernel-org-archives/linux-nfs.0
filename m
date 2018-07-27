Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:38162 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1731160AbeG0Qlf (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Jul 2018 12:41:35 -0400
Subject: [PATCH v1 4/4] NFSD: Handle full-length symlinks
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Fri, 27 Jul 2018 11:19:10 -0400
Message-ID: <20180727151910.21878.49021.stgit@klimt.1015granger.net>
In-Reply-To: <20180727142007.21878.77494.stgit@klimt.1015granger.net>
References: <20180727142007.21878.77494.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I've given up on the idea of zero-copy handling of SYMLINK on the
server side. This is because the Linux VFS symlink API requires the
symlink pathname to be in a NUL-terminated kmalloc'd buffer. The
NUL-termination is going to be problematic (watching out for
landing on a page boundary and dealing with a 4096-byte pathname).

I don't believe that SYMLINK creation is on a performance path or is
requested frequently enough that it will cause noticeable CPU cache
pollution due to data copies.

There will be two places where a transport callout will be necessary
to fill in the rqstp: one will be in the svc_fill_symlink_pathname()
helper that is used by NFSv2 and NFSv3, and the other will be in
nfsd4_decode_create().

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfsd/nfs3proc.c         |    2 +
 fs/nfsd/nfsproc.c          |    2 +
 include/linux/sunrpc/svc.h |    3 +-
 net/sunrpc/svc.c           |   67 ++++++++++++++++----------------------------
 4 files changed, 31 insertions(+), 43 deletions(-)

diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
index 8d1c2d1a..9eb8086 100644
--- a/fs/nfsd/nfs3proc.c
+++ b/fs/nfsd/nfs3proc.c
@@ -290,6 +290,7 @@
 		RETURN_STATUS(nfserr_nametoolong);
 
 	argp->tname = svc_fill_symlink_pathname(rqstp, &argp->first,
+						page_address(rqstp->rq_arg.pages[0]),
 						argp->tlen);
 	if (IS_ERR(argp->tname))
 		RETURN_STATUS(nfserrno(PTR_ERR(argp->tname)));
@@ -303,6 +304,7 @@
 	fh_init(&resp->fh, NFS3_FHSIZE);
 	nfserr = nfsd_symlink(rqstp, &resp->dirfh, argp->fname, argp->flen,
 						   argp->tname, &resp->fh);
+	kfree(argp->tname);
 	RETURN_STATUS(nfserr);
 }
 
diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
index a6faee5..0d20fd1 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -454,6 +454,7 @@
 		return nfserr_nametoolong;
 
 	argp->tname = svc_fill_symlink_pathname(rqstp, &argp->first,
+						page_address(rqstp->rq_arg.pages[0]),
 						argp->tlen);
 	if (IS_ERR(argp->tname))
 		return nfserrno(PTR_ERR(argp->tname));
@@ -466,6 +467,7 @@
 	nfserr = nfsd_symlink(rqstp, &argp->ffh, argp->fname, argp->flen,
 						 argp->tname, &newfh);
 
+	kfree(argp->tname);
 	fh_put(&argp->ffh);
 	fh_put(&newfh);
 	return nfserr;
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 43f88bd..73e130a 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -499,7 +499,8 @@ unsigned int	   svc_fill_write_vector(struct svc_rqst *rqstp,
 					 struct page **pages,
 					 struct kvec *first, size_t total);
 char		  *svc_fill_symlink_pathname(struct svc_rqst *rqstp,
-					     struct kvec *first, size_t total);
+					     struct kvec *first, void *p,
+					     size_t total);
 
 #define	RPC_MAX_ADDRBUFLEN	(63U)
 
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 2194ed5..d13e05f 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1577,65 +1577,48 @@ unsigned int svc_fill_write_vector(struct svc_rqst *rqstp, struct page **pages,
  * svc_fill_symlink_pathname - Construct pathname argument for VFS symlink call
  * @rqstp: svc_rqst to operate on
  * @first: buffer containing first section of pathname
+ * @p: buffer containing remaining section of pathname
  * @total: total length of the pathname argument
  *
- * Returns pointer to a NUL-terminated string, or an ERR_PTR. The buffer is
- * released automatically when @rqstp is recycled.
+ * The VFS symlink API demands a NUL-terminated pathname in mapped memory.
+ * Returns pointer to a NUL-terminated string, or an ERR_PTR. Caller must free
+ * the returned string.
  */
 char *svc_fill_symlink_pathname(struct svc_rqst *rqstp, struct kvec *first,
-				size_t total)
+				void *p, size_t total)
 {
-	struct xdr_buf *arg = &rqstp->rq_arg;
-	struct page **pages;
-	char *result;
-
-	/* VFS API demands a NUL-terminated pathname. This function
-	 * uses a page from @rqstp as the pathname buffer, to enable
-	 * direct placement. Thus the total buffer size is PAGE_SIZE.
-	 * Space in this buffer for NUL-termination requires that we
-	 * cap the size of the returned symlink pathname just a
-	 * little early.
-	 */
-	if (total > PAGE_SIZE - 1)
-		return ERR_PTR(-ENAMETOOLONG);
+	size_t len, remaining;
+	char *result, *dst;
 
-	/* Some types of transport can present the pathname entirely
-	 * in rq_arg.pages. If not, then copy the pathname into one
-	 * page.
-	 */
-	pages = arg->pages;
-	WARN_ON_ONCE(arg->page_base != 0);
-	if (first->iov_base == 0) {
-		result = page_address(*pages);
-		result[total] = '\0';
-	} else {
-		size_t len, remaining;
-		char *dst;
+	result = kmalloc(total + 1, GFP_KERNEL);
+	if (!result)
+		return ERR_PTR(-ESERVERFAULT);
 
-		result = page_address(*(rqstp->rq_next_page++));
-		dst = result;
-		remaining = total;
+	dst = result;
+	remaining = total;
 
-		len = min_t(size_t, total, first->iov_len);
+	len = min_t(size_t, total, first->iov_len);
+	if (len) {
 		memcpy(dst, first->iov_base, len);
 		dst += len;
 		remaining -= len;
+	}
 
-		/* No more than one page left */
-		if (remaining) {
-			len = min_t(size_t, remaining, PAGE_SIZE);
-			memcpy(dst, page_address(*pages), len);
-			dst += len;
-		}
-
-		*dst = '\0';
+	if (remaining) {
+		len = min_t(size_t, remaining, PAGE_SIZE);
+		memcpy(dst, p, len);
+		dst += len;
 	}
 
-	/* Sanity check: we don't allow the pathname argument to
+	*dst = '\0';
+
+	/* Sanity check: Linux doesn't allow the pathname argument to
 	 * contain a NUL byte.
 	 */
-	if (strlen(result) != total)
+	if (strlen(result) != total) {
+		kfree(result);
 		return ERR_PTR(-EINVAL);
+	}
 	return result;
 }
 EXPORT_SYMBOL_GPL(svc_fill_symlink_pathname);

