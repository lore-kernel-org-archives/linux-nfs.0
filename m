Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:49437 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932601AbbLNWVz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Dec 2015 17:21:55 -0500
Date: Mon, 14 Dec 2015 17:21:54 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Weston Andros Adamson <dros@netapp.com>
Cc: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4: fix getacl ERANGE for some ACL buffer sizes
Message-ID: <20151214222154.GB7342@fieldses.org>
References: <1385068813-5491-1-git-send-email-dros@netapp.com>
 <20151214221816.GA7342@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20151214221816.GA7342@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Weston Andros Adamson <dros@netapp.com>

Fix a bug where getxattr returns ERANGE when the attr buffer
length is close enough to the nearest PAGE_SIZE multiple that adding
the extra bytes leaves too little room for the ACL buffer.

Besides storing the ACL buffer, the getacl decoder uses the inline
pages for the attr bitmap and buffer length. __nfs4_get_acl_uncached
must allocate enough page space for all of the data to be decoded.

This patch uses xdr_partial_copy_from_skb to allocate any needed
pages past the first one. This allows the client to always cache the acl
on the first getacl call and not just if it fits in one page.

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfs/nfs4proc.c | 40 +++++++++++++++-------------------------
 fs/nfs/nfs4xdr.c  |  2 --
 2 files changed, 15 insertions(+), 27 deletions(-)

On Mon, Dec 14, 2015 at 05:18:16PM -0500, bfields wrote:
> Looks like it's still a bug upstream.  And it's easier to reproduce now
> that we've got a) numeric id's and b) a server that can handle larger
> ACLs.  I'm reliably reproducing with:

And the same patch still applies after minor conflict resolution;
updated patch below.  I've confirmed that it eliminates the ERANGE.

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 765a03559363..2e679c295185 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4702,20 +4702,17 @@ out:
 /*
  * The getxattr API returns the required buffer length when called with a
  * NULL buf. The NFSv4 acl tool then calls getxattr again after allocating
- * the required buf.  On a NULL buf, we send a page of data to the server
- * guessing that the ACL request can be serviced by a page. If so, we cache
- * up to the page of ACL data, and the 2nd call to getxattr is serviced by
- * the cache. If not so, we throw away the page, and cache the required
- * length. The next getxattr call will then produce another round trip to
- * the server, this time with the input buf of the required size.
+ * the required buf. Cache the result from the first getxattr call to avoid
+ * sending another RPC.
  */
 static ssize_t __nfs4_get_acl_uncached(struct inode *inode, void *buf, size_t buflen)
 {
-	struct page *pages[NFS4ACL_MAXPAGES] = {NULL, };
+	/* enough pages to hold ACL data plus the bitmap and acl length */
+	struct page *pages[NFS4ACL_MAXPAGES + 1] = {NULL, };
 	struct nfs_getaclargs args = {
 		.fh = NFS_FH(inode),
+		/* The xdr layer may allocate pages here. */
 		.acl_pages = pages,
-		.acl_len = buflen,
 	};
 	struct nfs_getaclres res = {
 		.acl_len = buflen,
@@ -4725,31 +4722,24 @@ static ssize_t __nfs4_get_acl_uncached(struct inode *inode, void *buf, size_t bu
 		.rpc_argp = &args,
 		.rpc_resp = &res,
 	};
-	unsigned int npages = DIV_ROUND_UP(buflen, PAGE_SIZE);
 	int ret = -ENOMEM, i;
 
-	/* As long as we're doing a round trip to the server anyway,
-	 * let's be prepared for a page of acl data. */
-	if (npages == 0)
-		npages = 1;
-	if (npages > ARRAY_SIZE(pages))
-		return -ERANGE;
-
-	for (i = 0; i < npages; i++) {
-		pages[i] = alloc_page(GFP_KERNEL);
-		if (!pages[i])
-			goto out_free;
-	}
+	/*
+	 * There will be some data returned by the server, how much is not
+	 * known yet. Allocate one page and let the XDR layer allocate
+	 * more if needed.
+	 */
+	pages[0] = alloc_page(GFP_KERNEL);
 
 	/* for decoding across pages */
 	res.acl_scratch = alloc_page(GFP_KERNEL);
 	if (!res.acl_scratch)
 		goto out_free;
 
-	args.acl_len = npages * PAGE_SIZE;
+	args.acl_len = ARRAY_SIZE(pages) << PAGE_SHIFT;
 
-	dprintk("%s  buf %p buflen %zu npages %d args.acl_len %zu\n",
-		__func__, buf, buflen, npages, args.acl_len);
+	dprintk("%s  buf %p buflen %zu args.acl_len %zu\n",
+		__func__, buf, buflen, args.acl_len);
 	ret = nfs4_call_sync(NFS_SERVER(inode)->client, NFS_SERVER(inode),
 			     &msg, &args.seq_args, &res.seq_res, 0);
 	if (ret)
@@ -4774,7 +4764,7 @@ static ssize_t __nfs4_get_acl_uncached(struct inode *inode, void *buf, size_t bu
 out_ok:
 	ret = res.acl_len;
 out_free:
-	for (i = 0; i < npages; i++)
+	for (i = 0; i < ARRAY_SIZE(pages) && pages[i]; i++)
 		if (pages[i])
 			__free_page(pages[i]);
 	if (res.acl_scratch)
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index dfed4f5c8fcc..35d15004b0d6 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -5298,8 +5298,6 @@ static int decode_getacl(struct xdr_stream *xdr, struct rpc_rqst *req,
 	if ((status = decode_op_hdr(xdr, OP_GETATTR)) != 0)
 		goto out;
 
-	xdr_enter_page(xdr, xdr->buf->page_len);
-
 	/* Calculate the offset of the page data */
 	pg_offset = xdr->buf->head[0].iov_len;
 
-- 
2.5.0

