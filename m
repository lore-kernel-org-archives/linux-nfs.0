Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:33078 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934140AbdBQQoQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 17 Feb 2017 11:44:16 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <schumakeranna@gmail.com>
Cc: linux-nfs@vger.kernel.org, Andreas Gruenbacher <agruenba@redhat.com>,
        Weston Andros Adamson <dros@primarydata.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 3/3] nfsd4: simplify getacl decoding
Date: Fri, 17 Feb 2017 11:44:14 -0500
Message-Id: <1487349854-9732-4-git-send-email-bfields@redhat.com>
In-Reply-To: <1487349854-9732-1-git-send-email-bfields@redhat.com>
References: <1487349854-9732-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

We still have a bug in the case xdr_enter_page() ends up needing to do
xdr_shrink_bufhead().  In that case some of the acl data could end up
shifting into the tail of the xdr_buf, but we're not prepared to handle
that.

There's not really much point to shifting the data around anyway, we're
just going to be copying it out into the buf that the vfs passed us.  So
let's just pass that buf down to the xdr layer and let it copy data
directly into it.

That means we need to allocate our own buf in the case the user didn't
give us one, so that we can still cache in that case (to efficiently
handle the common case of a getxattr(., ., NULL, 0) to get the size
followed immediately by a getxattr(., ., buf, size)).

But this still works out to be much simpler.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfs/nfs4proc.c       | 79 +++++++++++++++++++++++++++++--------------------
 fs/nfs/nfs4xdr.c        | 27 ++++-------------
 include/linux/nfs_xdr.h |  4 +--
 3 files changed, 54 insertions(+), 56 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 2d485dab343e..6262b2955d0e 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5035,17 +5035,23 @@ static inline ssize_t nfs4_read_cached_acl(struct inode *inode, char *buf, size_
 	return ret;
 }
 
-static void nfs4_write_cached_acl(struct inode *inode, struct page **pages, size_t pgbase, size_t acl_len)
+/*
+ * We don't cache ACLs over a certain size.  I don't know if we have any
+ * real reason for this policy:
+ */
+#define NFS4_MAX_CACHED_ACL PAGE_SIZE
+
+static void nfs4_write_cached_acl(struct inode *inode, void *buf, size_t acl_len)
 {
 	struct nfs4_cached_acl *acl;
 	size_t buflen = sizeof(*acl) + acl_len;
 
-	if (buflen <= PAGE_SIZE) {
+	if (buflen <= NFS4_MAX_CACHED_ACL) {
 		acl = kmalloc(buflen, GFP_KERNEL);
 		if (acl == NULL)
 			goto out;
 		acl->cached = 1;
-		_copy_from_pages(acl->data, pages, pgbase, acl_len);
+		memcpy(acl->data, buf, acl_len);
 	} else {
 		acl = kmalloc(sizeof(*acl), GFP_KERNEL);
 		if (acl == NULL)
@@ -5057,13 +5063,7 @@ static void nfs4_write_cached_acl(struct inode *inode, struct page **pages, size
 	nfs4_set_cached_acl(inode, acl);
 }
 
-/*
- * The getxattr API returns the required buffer length when called with a
- * NULL buf. The NFSv4 acl tool then calls getxattr again after allocating
- * the required buf. Cache the result from the first getxattr call to avoid
- * sending another RPC.
- */
-static ssize_t __nfs4_get_acl_uncached(struct inode *inode, void *buf, size_t buflen)
+static ssize_t nfs4_do_get_acl(struct inode *inode, void *buf, size_t buflen)
 {
 	/* enough pages to hold ACL data plus the bitmap and acl length */
 	struct page *pages[NFS4ACL_MAXPAGES + 1] = {NULL, };
@@ -5074,13 +5074,14 @@ static ssize_t __nfs4_get_acl_uncached(struct inode *inode, void *buf, size_t bu
 	};
 	struct nfs_getaclres res = {
 		.acl_len = buflen,
+		.buf = buf,
 	};
 	struct rpc_message msg = {
 		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_GETACL],
 		.rpc_argp = &args,
 		.rpc_resp = &res,
 	};
-	int ret = -ENOMEM, i;
+	int i;
 
 	/* for decoding across pages */
 	res.acl_scratch = alloc_page(GFP_KERNEL);
@@ -5093,34 +5094,48 @@ static ssize_t __nfs4_get_acl_uncached(struct inode *inode, void *buf, size_t bu
 		__func__, buf, buflen, args.acl_len);
 	ret = nfs4_call_sync(NFS_SERVER(inode)->client, NFS_SERVER(inode),
 			     &msg, &args.seq_args, &res.seq_res, 0);
-	if (ret)
-		goto out_free;
+	if (ret == 0)
+		ret = res.acl_len;
 
-	/* Handle the case where the passed-in buffer is too short */
-	if (res.acl_flags & NFS4_ACL_TRUNC) {
-		/* Did the user only issue a request for the acl length? */
-		if (buf == NULL)
-			goto out_ok;
-		ret = -ERANGE;
-		goto out_free;
-	}
-	nfs4_write_cached_acl(inode, pages, res.acl_data_offset, res.acl_len);
-	if (buf) {
-		if (res.acl_len > buflen) {
-			ret = -ERANGE;
-			goto out_free;
-		}
-		_copy_from_pages(buf, pages, res.acl_data_offset, res.acl_len);
-	}
-out_ok:
-	ret = res.acl_len;
-out_free:
 	for (i = 0; i < ARRAY_SIZE(pages) && pages[i]; i++)
 		__free_page(pages[i]);
 	__free_page(res.acl_scratch);
 	return ret;
 }
 
+/*
+ * The getxattr API returns the required buffer length when called with a
+ * NULL buf. The NFSv4 acl tool then calls getxattr again after allocating
+ * the required buf. Cache the result from the first getxattr call to avoid
+ * sending another RPC.
+ */
+static ssize_t __nfs4_get_acl_uncached(struct inode *inode, void *buf, size_t buflen)
+{
+	void *priv_buf = NULL;
+	void *our_buf = buf;
+	int our_buflen = buflen;
+	static ssize_t ret = -ENOMEM;
+
+	if (!buf) {
+		priv_buf = kmalloc(NFS4_MAX_CACHED_ACL, GFP_KERNEL);
+		if (!priv_buf)
+			goto out;
+		our_buf = priv_buf;
+		our_buflen = NFS4_MAX_CACHED_ACL;
+	}
+	ret = nfs4_do_get_acl(inode, our_buf, our_buflen);
+	if (ret < 0)
+		goto out;
+	if (ret <= our_buflen)
+		nfs4_write_cached_acl(inode, our_buf, ret);
+	if (buf && ret > buflen)
+		ret = -ERANGE;
+out:
+	if (priv_buf)
+		kfree(priv_buf);
+	return ret;
+}
+
 static ssize_t nfs4_get_acl_uncached(struct inode *inode, void *buf, size_t buflen)
 {
 	struct nfs4_exception exception = { };
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index bb95dd2edeef..534b377084fb 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -5353,39 +5353,24 @@ static int decode_getacl(struct xdr_stream *xdr, struct rpc_rqst *req,
 	uint32_t attrlen,
 		 bitmap[3] = {0};
 	int status;
-	unsigned int pg_offset;
 
-	res->acl_len = 0;
 	if ((status = decode_op_hdr(xdr, OP_GETATTR)) != 0)
 		goto out;
-
-	xdr_enter_page(xdr, xdr->buf->page_len);
-
-	/* Calculate the offset of the page data */
-	pg_offset = xdr->buf->head[0].iov_len;
-
 	if ((status = decode_attr_bitmap(xdr, bitmap)) != 0)
 		goto out;
 	if ((status = decode_attr_length(xdr, &attrlen, &savep)) != 0)
 		goto out;
-
+	if (unlikely(attrlen > (xdr->nwords << 2)))
+		return -EIO;
 	if (unlikely(bitmap[0] & (FATTR4_WORD0_ACL - 1U)))
 		return -EIO;
 	if (likely(bitmap[0] & FATTR4_WORD0_ACL)) {
+		unsigned int offset = xdr_stream_pos(xdr);
 
-		/* The bitmap (xdr len + bitmaps) and the attr xdr len words
-		 * are stored with the acl data to handle the problem of
-		 * variable length bitmaps.*/
-		res->acl_data_offset = xdr_stream_pos(xdr) - pg_offset;
+		if (attrlen <= res->acl_len)
+			read_bytes_from_xdr_buf(xdr->buf, offset,
+						res->buf, attrlen);
 		res->acl_len = attrlen;
-
-		/* Check for receive buffer overflow */
-		if (res->acl_len > (xdr->nwords << 2) ||
-		    res->acl_len + res->acl_data_offset > xdr->buf->page_len) {
-			res->acl_flags |= NFS4_ACL_TRUNC;
-			dprintk("NFS: acl reply: attrlen %u > page_len %u\n",
-					attrlen, xdr->nwords << 2);
-		}
 	} else
 		status = -EOPNOTSUPP;
 
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 348f7c158084..418116d62740 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -747,13 +747,11 @@ struct nfs_getaclargs {
 	struct page **			acl_pages;
 };
 
-/* getxattr ACL interface flags */
-#define NFS4_ACL_TRUNC		0x0001	/* ACL was truncated */
 struct nfs_getaclres {
 	struct nfs4_sequence_res	seq_res;
+	void *				buf;
 	size_t				acl_len;
 	size_t				acl_data_offset;
-	int				acl_flags;
 	struct page *			acl_scratch;
 };
 
-- 
2.9.3

