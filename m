Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:10480 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752189Ab1J0Shf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 27 Oct 2011 14:37:35 -0400
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id p9RIbZ9M005229
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 27 Oct 2011 14:37:35 -0400
Received: from fathat.boston.devel.redhat.com (fathat.boston.devel.redhat.com [10.16.60.125])
	by int-mx02.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id p9RIbYul013416
	for <linux-nfs@vger.kernel.org>; Thu, 27 Oct 2011 14:37:34 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [RFC] [PATCH 1/1] nfs: open-associated setattr shouldn't invalidate own cache
Date: Thu, 27 Oct 2011 15:09:32 -0400
Message-Id: <1319742572-6337-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: J. Bruce Fields <bfields@citi.umich.edu>

I'm not sure if this is really the right fix, but it seems silly to me
that e.g.

    open(O_RDWR|O_TRUNC)
    write()
    close()
    open(O_RDONLY)
    read()

results in an over-the-wire read (due to the setattr triggered by O_TRUNC).

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 fs/nfs/inode.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 385bc6d..5cdef63 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -429,8 +429,13 @@ nfs_setattr(struct dentry *dentry, struct iattr *attr)
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
1.7.1

