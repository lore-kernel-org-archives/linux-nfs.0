Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:61053 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754719Ab1BTWdt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 20 Feb 2011 17:33:49 -0500
Received: by qwd7 with SMTP id 7so1620777qwd.19
        for <linux-nfs@vger.kernel.org>; Sun, 20 Feb 2011 14:33:48 -0800 (PST)
From: Ilia Mirkin <imirkin@alum.mit.edu>
To: Trond.Myklebust@netapp.com
Cc: chuck.lever@oracle.com, linux-nfs@vger.kernel.org,
        Ilia Mirkin <imirkin@alum.mit.edu>
Subject: [PATCH] NFS: Zero entire acl2 structure
Date: Sun, 20 Feb 2011 17:33:04 -0500
Message-Id: <1298241184-1250-1-git-send-email-imirkin@alum.mit.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

The semantic match that finds this problem:
// <smpl>
@@
type T;
identifier x;
@@

T *x;
...
* memset(x, ..., ... * sizeof(x) * ...);
// </smpl>

Signed-off-by: Ilia Mirkin <imirkin@alum.mit.edu>

---
 fs/nfs_common/nfsacl.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

Untested. But it's unlikely that the original intention was to only
zero out the acl's refcount. However all of the acl's fields are
explicitly initialized, so perhaps this can just be removed entirely.
Unless the intention was to avoid leaking stack data in the structure's
padding bytes.

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
1.7.3.4

