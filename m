Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:48947 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753829Ab2HXOQN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 24 Aug 2012 10:16:13 -0400
From: Sachin Prabhu <sprabhu@redhat.com>
To: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Cc: Trond Myklebust <trond.myklebust@netapp.com>
Subject: [PATCH] Avoid array overflow in __nfs4_get_acl_uncached
Date: Fri, 24 Aug 2012 15:16:08 +0100
Message-Id: <1345817768-23511-1-git-send-email-sprabhu@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This fixes a bug introduced by commit
5a00689930ab975fdd1b37b034475017e460cf2a
The patch adds an extra page to npages to hold the bitmap returned by
the server.

Bruce Fields pointed out that the changes introduced by the patch will
cause the array npages to overflow if a buffer of size greater than or
equal to XATTR_SIZE_MAX is passed to __nfs4_get_acl_uncached()

Signed-off-by: Sachin Prabhu <sprabhu@redhat.com>
---
 fs/nfs/nfs4proc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 6352741..86333b8 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3768,7 +3768,7 @@ out:
  */
 static ssize_t __nfs4_get_acl_uncached(struct inode *inode, void *buf, size_t buflen)
 {
-	struct page *pages[NFS4ACL_MAXPAGES] = {NULL, };
+	struct page *pages[NFS4ACL_MAXPAGES+1] = {NULL, };
 	struct nfs_getaclargs args = {
 		.fh = NFS_FH(inode),
 		.acl_pages = pages,
-- 
1.7.11.4

