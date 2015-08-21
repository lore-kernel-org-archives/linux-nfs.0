Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:35905 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752741AbbHUB7l (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Aug 2015 21:59:41 -0400
Received: by pawq9 with SMTP id q9so40642626paw.3
        for <linux-nfs@vger.kernel.org>; Thu, 20 Aug 2015 18:59:40 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4: Force a post-op attribute update when holding a delegation
Date: Thu, 20 Aug 2015 20:59:38 -0500
Message-Id: <1440122378-30452-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the ctime or mtime or change attribute have changed because
of an operation we initiated, we should make sure that we force
an attribute update. However we do not want to mark the page cache
for revalidation.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/inode.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 2744d48bbbfe..e2cc0031decb 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1477,6 +1477,13 @@ static int nfs_post_op_update_inode_locked(struct inode *inode, struct nfs_fattr
 {
 	unsigned long invalid = NFS_INO_INVALID_ATTR|NFS_INO_REVAL_PAGECACHE;
 
+	/*
+	 * Don't revalidate the pagecache if we hold a delegation, but do
+	 * force an attribute update
+	 */
+	if (NFS_PROTO(inode)->have_delegation(inode, FMODE_READ))
+		invalid = NFS_INO_INVALID_ATTR|NFS_INO_REVAL_FORCED;
+
 	if (S_ISDIR(inode->i_mode))
 		invalid |= NFS_INO_INVALID_DATA;
 	nfs_set_cache_invalid(inode, invalid);
-- 
2.4.3

