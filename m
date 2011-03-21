Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from swampdragon.chaosbits.net ([90.184.90.115]:18176 "EHLO
	swampdragon.chaosbits.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754069Ab1CUTf6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Mar 2011 15:35:58 -0400
Date: Mon, 21 Mar 2011 20:35:49 +0100 (CET)
From: Jesper Juhl <jj@chaosbits.net>
To: linux-nfs@vger.kernel.org
cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Milton Miller <miltonm@bga.com>, Chuck Lever <chuck.lever@oracle.com>,
        linux-kernel@vger.kernel.org, Neil Brown <neilb@suse.de>,
        bfields@fieldses.org
Subject: [PATCH][resend] Remove pointless memset in nfsacl_encode()
Message-ID: <alpine.LNX.2.00.1103212031550.15815@swampdragon.chaosbits.net>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Remove pointless memset() in nfsacl_encode().

Thanks to Trond Myklebust <Trond.Myklebust@netapp.com> for pointing out 
that it is not needed since posix_acl_init() will set everything 
regardless..

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 nfsacl.c |    1 -
 1 file changed, 1 deletion(-)

 Patch against up-to-date Linus' tree.

diff --git a/fs/nfs_common/nfsacl.c b/fs/nfs_common/nfsacl.c
index 84c27d6..ec0f277 100644
--- a/fs/nfs_common/nfsacl.c
+++ b/fs/nfs_common/nfsacl.c
@@ -117,7 +117,6 @@ int nfsacl_encode(struct xdr_buf *buf, unsigned int base, struct inode *inode,
 		 * invoked in contexts where a memory allocation failure is
 		 * fatal.  Fortunately this fake ACL is small enough to
 		 * construct on the stack. */
-		memset(acl2, 0, sizeof(acl2));
 		posix_acl_init(acl2, 4);
 
 		/* Insert entries in canonical order: other orders seem



-- 
Jesper Juhl <jj@chaosbits.net>       http://www.chaosbits.net/
Don't top-post http://www.catb.org/jargon/html/T/top-post.html
Plain text mails only, please.

