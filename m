Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52552 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750868Ab1GRWXp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 Jul 2011 18:23:45 -0400
Date: Mon, 18 Jul 2011 18:23:24 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: trond@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfs: open-associated setattr shouldn't invalidate own cache
Message-ID: <20110718222323.GB16711@pad.fieldses.org>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: "J. Bruce Fields" <bfields@redhat.com>

We recently noticed that NFSv4 iozone read tests that should have been
performing at local-cache speeds were running at wire speeds, and found
that currently,

	open(O_RDWR|O_TRUNC)
	write()
	close()
	open(O_RDONLY)
	read()

results in an over-the-wire read (due to a setattr triggered by
O_TRUNC).  Even non-O_TRUNC opens send setattrs (of timestamps) in some
cases, causing the same problem.

In discussion with Trond, he blames a VFS bug for breaking what should
be a single open into an open followed by a setattr.

However, it may make sense even in a case like

	open(O_RDWR)
	write()
	setattr()
	close()
	open(O_RDONLY)
	read()

to treat the setattr similarly to the write, and not invalidate the
client's own cache as long as the setattr is performed under a write
open.

(That said, I don't know if this is the correct place in the code to
implement that behavior.)

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfs/inode.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 6f4850d..d4eed06 100644
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
1.7.6

