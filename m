Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f172.google.com ([209.85.216.172]:38433 "EHLO
	mail-qc0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753511AbaAaC2v (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Jan 2014 21:28:51 -0500
From: Noah Massey <noah.massey@gmail.com>
To: Al Viro <viro@zeniv.linux.org.uk>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Noah Massey <noah.massey@gmail.com>, Christoph Hellwig <hch@infradead.org>,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: [PATCH] nfs: fix setting of ACLs on file creation.
Date: Thu, 30 Jan 2014 21:31:12 -0500
Message-Id: <1391135472-9639-1-git-send-email-Noah.Massey@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Noah Massey <noah.massey@gmail.com>

nfs3_get_acl() tries to skip posix equivalent ACLs, but misinterprets
the return value of posix_acl_equiv_mode(). Fix it.

This is a regression introduced by
"nfs: use generic posix ACL infrastructure for v3 Posix ACLs"

CC: Christoph Hellwig <hch@infradead.org>
CC: linux-nfs@vger.kernel.org
CC: linux-fsdevel@vger.kernel.org
---
 fs/nfs/nfs3acl.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs3acl.c b/fs/nfs/nfs3acl.c
index 9a5ca03..0851f85 100644
--- a/fs/nfs/nfs3acl.c
+++ b/fs/nfs/nfs3acl.c
@@ -80,7 +80,7 @@ struct posix_acl *nfs3_get_acl(struct inode *inode, int type)
 	}
 
 	if (res.acl_access != NULL) {
-		if (posix_acl_equiv_mode(res.acl_access, NULL) ||
+		if ((posix_acl_equiv_mode(res.acl_access, NULL) == 0) ||
 		    res.acl_access->a_count == 0) {
 			posix_acl_release(res.acl_access);
 			res.acl_access = NULL;
-- 
1.8.5.3

