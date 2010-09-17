Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:44211 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754833Ab0IQQ0o (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Sep 2010 12:26:44 -0400
Received: by gyd8 with SMTP id 8so777986gyd.19
        for <linux-nfs@vger.kernel.org>; Fri, 17 Sep 2010 09:26:44 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 03/22] SUNRPC: Refactor logic to NUL-terminate strings in pages
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Fri, 17 Sep 2010 12:26:40 -0400
Message-ID: <20100917162640.19761.51548.stgit@seurat.1015granger.net>
In-Reply-To: <20100917162204.19761.58249.stgit@seurat.1015granger.net>
References: <20100917162204.19761.58249.stgit@seurat.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Clean up: Introduce a helper to '\0'-terminate XDR strings
that are placed in a page in the page cache.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs2xdr.c           |    6 +-----
 fs/nfs/nfs3xdr.c           |    6 +-----
 fs/nfs/nfs4xdr.c           |    5 +----
 include/linux/sunrpc/xdr.h |    1 +
 net/sunrpc/xdr.c           |   17 +++++++++++++++++
 5 files changed, 21 insertions(+), 14 deletions(-)

diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
index db8846a..43413f2 100644
--- a/fs/nfs/nfs2xdr.c
+++ b/fs/nfs/nfs2xdr.c
@@ -596,7 +596,6 @@ nfs_xdr_readlinkres(struct rpc_rqst *req, __be32 *p, void *dummy)
 	struct kvec *iov = rcvbuf->head;
 	size_t hdrlen;
 	u32 len, recvd;
-	char	*kaddr;
 	int	status;
 
 	if ((status = ntohl(*p++)))
@@ -623,10 +622,7 @@ nfs_xdr_readlinkres(struct rpc_rqst *req, __be32 *p, void *dummy)
 		return -EIO;
 	}
 
-	/* NULL terminate the string we got */
-	kaddr = (char *)kmap_atomic(rcvbuf->pages[0], KM_USER0);
-	kaddr[len+rcvbuf->page_base] = '\0';
-	kunmap_atomic(kaddr, KM_USER0);
+	xdr_terminate_string(rcvbuf, len);
 	return 0;
 }
 
diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
index 9769704..a8170a0 100644
--- a/fs/nfs/nfs3xdr.c
+++ b/fs/nfs/nfs3xdr.c
@@ -824,7 +824,6 @@ nfs3_xdr_readlinkres(struct rpc_rqst *req, __be32 *p, struct nfs_fattr *fattr)
 	struct kvec *iov = rcvbuf->head;
 	size_t hdrlen;
 	u32 len, recvd;
-	char	*kaddr;
 	int	status;
 
 	status = ntohl(*p++);
@@ -857,10 +856,7 @@ nfs3_xdr_readlinkres(struct rpc_rqst *req, __be32 *p, struct nfs_fattr *fattr)
 		return -EIO;
 	}
 
-	/* NULL terminate the string we got */
-	kaddr = (char*)kmap_atomic(rcvbuf->pages[0], KM_USER0);
-	kaddr[len+rcvbuf->page_base] = '\0';
-	kunmap_atomic(kaddr, KM_USER0);
+	xdr_terminate_string(rcvbuf, len);
 	return 0;
 }
 
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 08ef912..e1ed89e 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -4299,7 +4299,6 @@ static int decode_readlink(struct xdr_stream *xdr, struct rpc_rqst *req)
 	size_t hdrlen;
 	u32 len, recvd;
 	__be32 *p;
-	char *kaddr;
 	int status;
 
 	status = decode_op_hdr(xdr, OP_READLINK);
@@ -4330,9 +4329,7 @@ static int decode_readlink(struct xdr_stream *xdr, struct rpc_rqst *req)
 	 * and and null-terminate the text (the VFS expects
 	 * null-termination).
 	 */
-	kaddr = (char *)kmap_atomic(rcvbuf->pages[0], KM_USER0);
-	kaddr[len+rcvbuf->page_base] = '\0';
-	kunmap_atomic(kaddr, KM_USER0);
+	xdr_terminate_string(rcvbuf, len);
 	return 0;
 out_overflow:
 	print_overflow_msg(__func__, xdr);
diff --git a/include/linux/sunrpc/xdr.h b/include/linux/sunrpc/xdr.h
index 35cf2e8..8c1dcbb 100644
--- a/include/linux/sunrpc/xdr.h
+++ b/include/linux/sunrpc/xdr.h
@@ -108,6 +108,7 @@ void	xdr_encode_pages(struct xdr_buf *, struct page **, unsigned int,
 			 unsigned int);
 void	xdr_inline_pages(struct xdr_buf *, unsigned int,
 			 struct page **, unsigned int, unsigned int);
+void	xdr_terminate_string(struct xdr_buf *, const u32);
 
 static inline __be32 *xdr_encode_array(__be32 *p, const void *s, unsigned int len)
 {
diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
index a1f82a8..d463d20 100644
--- a/net/sunrpc/xdr.c
+++ b/net/sunrpc/xdr.c
@@ -111,6 +111,23 @@ xdr_decode_string_inplace(__be32 *p, char **sp,
 }
 EXPORT_SYMBOL_GPL(xdr_decode_string_inplace);
 
+/**
+ * xdr_terminate_string - '\0'-terminate a string residing in an xdr_buf
+ * @buf: XDR buffer where string resides
+ * @len: length of string, in bytes
+ *
+ */
+void
+xdr_terminate_string(struct xdr_buf *buf, const u32 len)
+{
+	char *kaddr;
+
+	kaddr = kmap_atomic(buf->pages[0], KM_USER0);
+	kaddr[buf->page_base + len] = '\0';
+	kunmap_atomic(kaddr, KM_USER0);
+}
+EXPORT_SYMBOL(xdr_terminate_string);
+
 void
 xdr_encode_pages(struct xdr_buf *xdr, struct page **pages, unsigned int base,
 		 unsigned int len)

