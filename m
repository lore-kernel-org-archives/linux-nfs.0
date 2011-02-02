Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail4.comsite.net ([205.238.176.238]:50948 "EHLO
	mail4.comsite.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752421Ab1BBGOq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Feb 2011 01:14:46 -0500
From: Milton Miller <miltonm@bga.com>
To: Chuck Lever <chuck.lever@oracle.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>,
        <linux-nfs@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Subject: [PATCH] adjust suspicious memset in nfsacl_encode()
Message-id: <nfsacl-suspicous-memset@mdm.bga.com>
Date: Wed, 02 Feb 2011 00:14:45 -0600
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0


commit f61f6da0d53842e849bab7f69e1431bd3de1136d "NFS: Prevent memory
allocation failure in nfsacl_encode()" added a memset whose length was
the size of the pointer.  Change this to the size of the pointed struct
that is later passed to posix_acl_init().  The 4 entries that are the
remainder of the parent struct will be set and therefore should not
need zeroing.

Alternatively we could remove the memset as posix_acl_init sets all
fields with storage in struct posix_acl and we won't reference any
implicit padding.

Signed-off-by: Milton Miller <miltonm@bga.com>
---
While I was reviewing changes merged post rc2 I saw this suspicious memset.

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
