From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 01/24] SUNRPC: Refactor logic to NUL-terminate strings in pages
Date: Sun, 16 May 2010 22:45:46 -0400
Message-ID: <20100517024546.20258.89110.stgit@localhost.localdomain>
References: <20100517023905.20258.86631.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f171.google.com ([209.85.221.171]:63658 "EHLO
	mail-qy0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752752Ab0EQCps (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 16 May 2010 22:45:48 -0400
Received: by mail-qy0-f171.google.com with SMTP id 1so6350026qyk.5
        for <linux-nfs@vger.kernel.org>; Sun, 16 May 2010 19:45:48 -0700 (PDT)
In-Reply-To: <20100517023905.20258.86631.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

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
index 81cf142..279883c 100644
--- a/fs/nfs/nfs2xdr.c
+++ b/fs/nfs/nfs2xdr.c
@@ -597,7 +597,6 @@ nfs_xdr_readlinkres(struct rpc_rqst *req, __be32 *p, void *dummy)
 	struct kvec *iov = rcvbuf->head;
 	size_t hdrlen;
 	u32 len, recvd;
-	char	*kaddr;
 	int	status;
 
 	if ((status = ntohl(*p++)))
@@ -624,10 +623,7 @@ nfs_xdr_readlinkres(struct rpc_rqst *req, __be32 *p, void *dummy)
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
index 56a86f6..cb2eb1f 100644
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
index 38f3b58..ab18790 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -4250,7 +4250,6 @@ static int decode_readlink(struct xdr_stream *xdr, struct rpc_rqst *req)
 	size_t hdrlen;
 	u32 len, recvd;
 	__be32 *p;
-	char *kaddr;
 	int status;
 
 	status = decode_op_hdr(xdr, OP_READLINK);
@@ -4281,9 +4280,7 @@ static int decode_readlink(struct xdr_stream *xdr, struct rpc_rqst *req)
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
index 2763fde..a6ce4f4 100644
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

