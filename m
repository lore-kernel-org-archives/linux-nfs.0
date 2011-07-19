Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:22489 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750877Ab1GSAJV convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Jul 2011 20:09:21 -0400
Date: Mon, 18 Jul 2011 20:09:15 -0400
Subject: Re: [PATCH] nfs: open-associated setattr shouldn't invalidate own cache
Content-Type: text/plain;
	charset="utf-8"
Message-ID: <02f301cc45a8$1ad15db6$78be630a@hq.netapp.com>
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "J. Bruce Fields" <bfields@redhat.com>, <trond@netapp.com>
Cc: <linux-nfs@vger.kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

We should already optimize away the unnecessary setting of the size. The problem is that truncate() still requires you to set the ctime, whereas ftruncate() does not iirc.

"J. Bruce Fields" <bfields@redhat.com> wrote:

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

