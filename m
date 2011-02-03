Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from swampdragon.chaosbits.net ([90.184.90.115]:10144 "EHLO
	swampdragon.chaosbits.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932221Ab1BCTQ0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Feb 2011 14:16:26 -0500
Date: Thu, 3 Feb 2011 20:15:28 +0100 (CET)
From: Jesper Juhl <jj@chaosbits.net>
To: linux-nfs@vger.kernel.org
cc: linux-kernel@vger.kernel.org, Trond Myklebust <Trond.Myklebust@netapp.com>,
        Neil Brown <neilb@suse.de>, bfields@fieldses.org
Subject: [PATCH] Fix size argument to memset call in nfsacl_encode
Message-ID: <alpine.LNX.2.00.1102032012540.15101@swampdragon.chaosbits.net>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

We want to give memset() the sizeof(struct posix_acl), not
sizeof(struct posix_acl *).

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 nfsacl.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs_common/nfsacl.c b/fs/nfs_common/nfsacl.c
index 84c27d6..bc6d81b 100644
--- a/fs/nfs_common/nfsacl.c
+++ b/fs/nfs_common/nfsacl.c
@@ -117,7 +117,7 @@ int nfsacl_encode(struct xdr_buf *buf, unsigned int base, struct inode *inode,
 		 * invoked in contexts where a memory allocation failure is
 		 * fatal.  Fortunately this fake ACL is small enough to
 		 * construct on the stack. */
-		memset(acl2, 0, sizeof(acl2));
+		memset(acl2, 0, sizeof(*acl2));
 		posix_acl_init(acl2, 4);
 
 		/* Insert entries in canonical order: other orders seem
-- 
Jesper Juhl <jj@chaosbits.net>            http://www.chaosbits.net/
Don't top-post http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please.

