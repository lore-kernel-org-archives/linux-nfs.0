Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:14576 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752632Ab2HAN3g (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 1 Aug 2012 09:29:36 -0400
From: Sachin Prabhu <sprabhu@redhat.com>
To: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Cc: Trond Myklebust <trond.myklebust@netapp.com>
Subject: [PATCH 1/2] Fix array overflow in __nfs4_get_acl_uncached
Date: Wed,  1 Aug 2012 14:29:30 +0100
Message-Id: <1343827771-6258-2-git-send-email-sprabhu@redhat.com>
In-Reply-To: <1343827771-6258-1-git-send-email-sprabhu@redhat.com>
References: <1343827771-6258-1-git-send-email-sprabhu@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This fixes a bug introduced by commit
5a00689930ab975fdd1b37b034475017e460cf2a

Bruce Fields pointed out that the changes introduced by the patch will
cause the array npages to overflow if a size requested is >=
XATTR_SIZE_MAX.

The patch also fixes the check for the size of acl returned in the same
function and updates the comment associated with this function.

Signed-off-by: Sachin Prabhu <sprabhu@redhat.com>
---
 fs/nfs/nfs4proc.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index c157b20..be03b95 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3709,16 +3709,16 @@ out:
 /*
  * The getxattr API returns the required buffer length when called with a
  * NULL buf. The NFSv4 acl tool then calls getxattr again after allocating
- * the required buf.  On a NULL buf, we send a page of data to the server
- * guessing that the ACL request can be serviced by a page. If so, we cache
- * up to the page of ACL data, and the 2nd call to getxattr is serviced by
- * the cache. If not so, we throw away the page, and cache the required
- * length. The next getxattr call will then produce another round trip to
- * the server, this time with the input buf of the required size.
+ * the required buf.  On a NULL buf, we allocate 2 pages guessing that the
+ * ACL request can be serviced by those pages. If so, we cache the ACL data,
+ * and the 2nd call to getxattr is serviced by the cache. If not so, we throw
+ * away the pages, and cache the required length. The next getxattr call will
+ * then produce another round trip to the server, this time with the input buf
+ * of the required size.
  */
 static ssize_t __nfs4_get_acl_uncached(struct inode *inode, void *buf, size_t buflen)
 {
-	struct page *pages[NFS4ACL_MAXPAGES] = {NULL, };
+	struct page *pages[NFS4ACL_MAXPAGES+1] = {NULL, };
 	struct nfs_getaclargs args = {
 		.fh = NFS_FH(inode),
 		.acl_pages = pages,
@@ -3770,7 +3770,7 @@ static ssize_t __nfs4_get_acl_uncached(struct inode *inode, void *buf, size_t bu
 		goto out_free;
 
 	acl_len = res.acl_len - res.acl_data_offset;
-	if (acl_len > args.acl_len)
+	if (res.acl_len > args.acl_len)
 		nfs4_write_cached_acl(inode, NULL, 0, acl_len);
 	else
 		nfs4_write_cached_acl(inode, pages, res.acl_data_offset,
-- 
1.7.11.2

