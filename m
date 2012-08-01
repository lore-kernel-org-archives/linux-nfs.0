Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:23434 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753460Ab2HAN3g (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 1 Aug 2012 09:29:36 -0400
From: Sachin Prabhu <sprabhu@redhat.com>
To: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Cc: Trond Myklebust <trond.myklebust@netapp.com>
Subject: [PATCH 2/2] Simplify check for size of ACL returned in __nfs4_get_acl_uncached
Date: Wed,  1 Aug 2012 14:29:31 +0100
Message-Id: <1343827771-6258-3-git-send-email-sprabhu@redhat.com>
In-Reply-To: <1343827771-6258-1-git-send-email-sprabhu@redhat.com>
References: <1343827771-6258-1-git-send-email-sprabhu@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Rename flag ACL_LEN_REQEST to NFS4_ACL_LEN_ONLY. Apart from using this
flag during a request to indicate that the user is only interested in
the length of the ACL, we now also use it in the response stage to
indicate that the data returned holds the complete ACL or just the
length.

Signed-off-by: Sachin Prabhu <sprabhu@redhat.com>
---
 fs/nfs/nfs4proc.c       | 4 ++--
 fs/nfs/nfs4xdr.c        | 4 +++-
 include/linux/nfs_xdr.h | 2 +-
 3 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index be03b95..aaa98f0 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3760,7 +3760,7 @@ static ssize_t __nfs4_get_acl_uncached(struct inode *inode, void *buf, size_t bu
 	/* Let decode_getfacl know not to fail if the ACL data is larger than
 	 * the page we send as a guess */
 	if (buf == NULL)
-		res.acl_flags |= NFS4_ACL_LEN_REQUEST;
+		res.acl_flags |= NFS4_ACL_LEN_ONLY;
 
 	dprintk("%s  buf %p buflen %zu npages %d args.acl_len %zu\n",
 		__func__, buf, buflen, npages, args.acl_len);
@@ -3770,7 +3770,7 @@ static ssize_t __nfs4_get_acl_uncached(struct inode *inode, void *buf, size_t bu
 		goto out_free;
 
 	acl_len = res.acl_len - res.acl_data_offset;
-	if (res.acl_len > args.acl_len)
+	if (res.acl_flags & NFS4_ACL_LEN_ONLY)
 		nfs4_write_cached_acl(inode, NULL, 0, acl_len);
 	else
 		nfs4_write_cached_acl(inode, pages, res.acl_data_offset,
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 18fae29..a88fcd0 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -5101,7 +5101,7 @@ static int decode_getacl(struct xdr_stream *xdr, struct rpc_rqst *req,
 		hdrlen = (u8 *)xdr->p - (u8 *)iov->iov_base;
 		attrlen += res->acl_data_offset;
 		if (attrlen > page_len) {
-			if (res->acl_flags & NFS4_ACL_LEN_REQUEST) {
+			if (res->acl_flags & NFS4_ACL_LEN_ONLY) {
 				/* getxattr interface called with a NULL buf */
 				res->acl_len = attrlen;
 				goto out;
@@ -5110,6 +5110,8 @@ static int decode_getacl(struct xdr_stream *xdr, struct rpc_rqst *req,
 					attrlen, page_len);
 			return -EINVAL;
 		}
+		/* At this stage we have the complete ACL */
+		res->acl_flags &= ~NFS4_ACL_LEN_ONLY;
 		xdr_read_pages(xdr, attrlen);
 		res->acl_len = attrlen;
 	} else
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index d3b7c18..c2d77d5 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -648,7 +648,7 @@ struct nfs_getaclargs {
 };
 
 /* getxattr ACL interface flags */
-#define NFS4_ACL_LEN_REQUEST	0x0001	/* zero length getxattr buffer */
+#define NFS4_ACL_LEN_ONLY	0x0001	/* zero length getxattr buffer */
 struct nfs_getaclres {
 	size_t				acl_len;
 	size_t				acl_data_offset;
-- 
1.7.11.2

