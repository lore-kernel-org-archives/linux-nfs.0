Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:20483 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751863Ab2HNWru (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 Aug 2012 18:47:50 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Dros Adamson <Weston.Adamson@netapp.com>
Cc: Sachin Prabhu <sprabhu@redhat.com>,
        Andy Adamson <William.Adamson@netapp.com>, linux-nfs@vger.kernel.org
Subject: [PATCH 3/3] NFSv4: Don't use private xdr_stream fields in decode_getacl
Date: Tue, 14 Aug 2012 18:47:27 -0400
Message-Id: <1344984447-17804-3-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1344984447-17804-2-git-send-email-Trond.Myklebust@netapp.com>
References: <1344984447-17804-1-git-send-email-Trond.Myklebust@netapp.com>
 <1344984447-17804-2-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Instead of using the private field xdr->p from struct xdr_stream,
use the public xdr_stream_pos().

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4xdr.c | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 54d3f5a..1bfbd67 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -5045,10 +5045,10 @@ static int decode_getacl(struct xdr_stream *xdr, struct rpc_rqst *req,
 			 struct nfs_getaclres *res)
 {
 	unsigned int savep;
-	__be32 *bm_p;
 	uint32_t attrlen,
 		 bitmap[3] = {0};
 	int status;
+	unsigned int pg_offset;
 
 	res->acl_len = 0;
 	if ((status = decode_op_hdr(xdr, OP_GETATTR)) != 0)
@@ -5056,7 +5056,8 @@ static int decode_getacl(struct xdr_stream *xdr, struct rpc_rqst *req,
 
 	xdr_enter_page(xdr, xdr->buf->page_len);
 
-	bm_p = xdr->p;
+	/* Calculate the offset of the page data */
+	pg_offset = xdr->buf->head[0].iov_len;
 
 	if ((status = decode_attr_bitmap(xdr, bitmap)) != 0)
 		goto out;
@@ -5070,18 +5071,18 @@ static int decode_getacl(struct xdr_stream *xdr, struct rpc_rqst *req,
 		/* The bitmap (xdr len + bitmaps) and the attr xdr len words
 		 * are stored with the acl data to handle the problem of
 		 * variable length bitmaps.*/
-		res->acl_data_offset = (xdr->p - bm_p) << 2;
+		res->acl_data_offset = xdr_stream_pos(xdr) - pg_offset;
 
 		/* We ignore &savep and don't do consistency checks on
 		 * the attr length.  Let userspace figure it out.... */
 		res->acl_len = attrlen;
-		if (attrlen + res->acl_data_offset > xdr->buf->page_len) {
+		if (attrlen > (xdr->nwords << 2)) {
 			if (res->acl_flags & NFS4_ACL_LEN_REQUEST) {
 				/* getxattr interface called with a NULL buf */
 				goto out;
 			}
 			dprintk("NFS: acl reply: attrlen %u > page_len %u\n",
-					attrlen, xdr->buf->page_len);
+					attrlen, xdr->nwords << 2);
 			return -EINVAL;
 		}
 	} else
-- 
1.7.11.2

