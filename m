Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:50475 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756886Ab1LGQkD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Dec 2011 11:40:03 -0500
Date: Wed, 7 Dec 2011 11:40:01 -0500
To: Trond Myklebust <trond@netapp.com>
Cc: Bryan Schumaker <bjschuma@netapp.com>, linux-nfs@vger.kernel.org
Subject: [PATCH] nfs: treat open-associated setattr like write otc purposes
Message-ID: <20111207164001.GC20079@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

For the purposes of open-to-close cache consistency, I don't see why a
setattr (if it's something like "ftruncate", that's associated with an
open) should be treated any differently than a write.

In the v4 case (in the absence of pre-op attributes) that means we
should fake up pre-op attributes as we do for write.

This allows us to handle reads from cache in more cases.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfs/inode.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

We discussed this a few weeks ago and you seemed amenable to the basic
idea, but I have doubts about my implementation:

	- Is this really the right place to do this?
	- I'm changing v2/v3 behavior here too, where in the write case
	  I think it's only v4 that does the
	  nfs_post_op_update_inode_force_wcc().

Also cc'ing Bryan since I think you suggested he might be interested.

--b.

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index fe12037..b84748e 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -438,8 +438,13 @@ nfs_setattr(struct dentry *dentry, struct iattr *attr)
 	if ((attr->ia_valid & (ATTR_MODE|ATTR_UID|ATTR_GID)) != 0)
 		nfs_inode_return_delegation(inode);
 	error = NFS_PROTO(inode)->setattr(dentry, fattr, attr);
-	if (error == 0)
+	if (error)
+		goto out_free;
+	if (attr->ia_valid & ATTR_FILE)
+		nfs_post_op_update_inode_force_wcc(inode, fattr);
+	else
 		nfs_refresh_inode(inode, fattr);
+out_free:
 	nfs_free_fattr(fattr);
 out:
 	return error;
-- 
1.7.5.4

