Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:63026 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932175Ab2DQNfm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Apr 2012 09:35:42 -0400
Message-ID: <1334669739.5396.9.camel@localhost>
Subject: [PATCH 1/2] Avoid reading past buffer when calling GETACL
From: Sachin Prabhu <sprabhu@redhat.com>
To: Andy Adamson <andros@netapp.com>,
        Trond Myklebust <trond.myklebust@netapp.com>
Cc: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Date: Tue, 17 Apr 2012 14:35:39 +0100
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Bug noticed in commit
bf118a342f10dafe44b14451a1392c3254629a1f

When calling GETACL, if the size of the bitmap array, the length
attribute and the acl returned by the server is greater than the
allocated buffer(args.acl_len), we can Oops with a General Protection
fault at _copy_from_pages() when we attempt to read past the pages
allocated.

This patch allocates an extra PAGE for the bitmap and checks to see that
the bitmap + attribute_length + ACLs don't exceed the buffer space
allocated to it.

Signed-off-by: Sachin Prabhu <sprabhu@redhat.com>
Reported-by: Jian Li <jiali@redhat.com>
---
 fs/nfs/nfs4proc.c |   16 ++++++++++------
 fs/nfs/nfs4xdr.c  |   18 +++++++++++-------
 2 files changed, 21 insertions(+), 13 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index f82bde0..bd54803 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3675,19 +3675,23 @@ static ssize_t __nfs4_get_acl_uncached(struct inode *inode, void *buf, size_t bu
 	if (npages == 0)
 		npages = 1;
 
+	/* Add an extra page to handle the bitmap returned */
+	npages++;
+
 	for (i = 0; i < npages; i++) {
 		pages[i] = alloc_page(GFP_KERNEL);
 		if (!pages[i])
 			goto out_free;
 	}
-	if (npages > 1) {
-		/* for decoding across pages */
-		res.acl_scratch = alloc_page(GFP_KERNEL);
-		if (!res.acl_scratch)
-			goto out_free;
-	}
+
+	/* for decoding across pages */
+	res.acl_scratch = alloc_page(GFP_KERNEL);
+	if (!res.acl_scratch)
+		goto out_free;
+
 	args.acl_len = npages * PAGE_SIZE;
 	args.acl_pgbase = 0;
+
 	/* Let decode_getfacl know not to fail if the ACL data is larger than
 	 * the page we send as a guess */
 	if (buf == NULL)
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index c74fdb1..f74d87a 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -4901,11 +4901,19 @@ static int decode_getacl(struct xdr_stream *xdr, struct rpc_rqst *req,
 		 bitmap[3] = {0};
 	struct kvec *iov = req->rq_rcv_buf.head;
 	int status;
+	size_t page_len = xdr->buf->page_len;
 
 	res->acl_len = 0;
 	if ((status = decode_op_hdr(xdr, OP_GETATTR)) != 0)
 		goto out;
+
 	bm_p = xdr->p;
+	res->acl_data_offset = be32_to_cpup(bm_p) + 2;
+	res->acl_data_offset <<= 2;
+	/* Check if the acl data starts beyond the allocated buffer */
+	if (res->acl_data_offset > page_len)
+		return -ERANGE;
+
 	if ((status = decode_attr_bitmap(xdr, bitmap)) != 0)
 		goto out;
 	if ((status = decode_attr_length(xdr, &attrlen, &savep)) != 0)
@@ -4915,28 +4923,24 @@ static int decode_getacl(struct xdr_stream *xdr, struct rpc_rqst *req,
 		return -EIO;
 	if (likely(bitmap[0] & FATTR4_WORD0_ACL)) {
 		size_t hdrlen;
-		u32 recvd;
 
 		/* The bitmap (xdr len + bitmaps) and the attr xdr len words
 		 * are stored with the acl data to handle the problem of
 		 * variable length bitmaps.*/
 		xdr->p = bm_p;
-		res->acl_data_offset = be32_to_cpup(bm_p) + 2;
-		res->acl_data_offset <<= 2;
 
 		/* We ignore &savep and don't do consistency checks on
 		 * the attr length.  Let userspace figure it out.... */
 		hdrlen = (u8 *)xdr->p - (u8 *)iov->iov_base;
 		attrlen += res->acl_data_offset;
-		recvd = req->rq_rcv_buf.len - hdrlen;
-		if (attrlen > recvd) {
+		if (attrlen > page_len) {
 			if (res->acl_flags & NFS4_ACL_LEN_REQUEST) {
 				/* getxattr interface called with a NULL buf */
 				res->acl_len = attrlen;
 				goto out;
 			}
-			dprintk("NFS: acl reply: attrlen %u > recvd %u\n",
-					attrlen, recvd);
+			dprintk("NFS: acl reply: attrlen %u > page_len %u\n",
+					attrlen, page_len);
 			return -EINVAL;
 		}
 		xdr_read_pages(xdr, attrlen);
-- 
1.7.7.6



