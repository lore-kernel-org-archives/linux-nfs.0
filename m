Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:33070 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934070AbdBQQoQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 17 Feb 2017 11:44:16 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <schumakeranna@gmail.com>
Cc: linux-nfs@vger.kernel.org, Andreas Gruenbacher <agruenba@redhat.com>,
        Weston Andros Adamson <dros@primarydata.com>,
        Weston Andros Adamson <dros@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 2/3] NFSv4: fix getacl ERANGE for some ACL buffer sizes
Date: Fri, 17 Feb 2017 11:44:13 -0500
Message-Id: <1487349854-9732-3-git-send-email-bfields@redhat.com>
In-Reply-To: <1487349854-9732-1-git-send-email-bfields@redhat.com>
References: <1487349854-9732-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Weston Andros Adamson <dros@netapp.com>

Fix a bug where getxattr returns ERANGE when the attr buffer
length is close enough to the nearest PAGE_SIZE multiple that adding
the extra bytes leaves too little room for the ACL buffer.

Besides storing the ACL buffer, the getacl decoder uses the inline
pages for the attr bitmap and buffer length. __nfs4_get_acl_uncached
must allocate enough page space for all of the data to be decoded.

This patch uses xdr_partial_copy_from_skb to allocate any needed pages.

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
[bfields: restore xdr_enter_page, don't preallocate a page, misc. cleanup]
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfs/nfs4proc.c | 43 ++++++++++++-------------------------------
 1 file changed, 12 insertions(+), 31 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 0a0eaecf9676..2d485dab343e 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5060,20 +5060,17 @@ static void nfs4_write_cached_acl(struct inode *inode, struct page **pages, size
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
@@ -5083,31 +5080,17 @@ static ssize_t __nfs4_get_acl_uncached(struct inode *inode, void *buf, size_t bu
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
-
 	/* for decoding across pages */
 	res.acl_scratch = alloc_page(GFP_KERNEL);
 	if (!res.acl_scratch)
-		goto out_free;
+		return -ENOMEM;
 
-	args.acl_len = npages * PAGE_SIZE;
+	args.acl_len = ARRAY_SIZE(pages) << PAGE_SHIFT;
 
-	dprintk("%s  buf %p buflen %zu npages %d args.acl_len %zu\n",
-		__func__, buf, buflen, npages, args.acl_len);
+	dprintk("%s  buf %p buflen %zu args.acl_len %zu\n",
+		__func__, buf, buflen, args.acl_len);
 	ret = nfs4_call_sync(NFS_SERVER(inode)->client, NFS_SERVER(inode),
 			     &msg, &args.seq_args, &res.seq_res, 0);
 	if (ret)
@@ -5132,11 +5115,9 @@ static ssize_t __nfs4_get_acl_uncached(struct inode *inode, void *buf, size_t bu
 out_ok:
 	ret = res.acl_len;
 out_free:
-	for (i = 0; i < npages; i++)
-		if (pages[i])
-			__free_page(pages[i]);
-	if (res.acl_scratch)
-		__free_page(res.acl_scratch);
+	for (i = 0; i < ARRAY_SIZE(pages) && pages[i]; i++)
+		__free_page(pages[i]);
+	__free_page(res.acl_scratch);
 	return ret;
 }
 
-- 
2.9.3

