Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.tpi.com ([70.99.223.143]:1221 "EHLO mail.tpi.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750734Ab3BLUDw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Feb 2013 15:03:52 -0500
From: Tim Gardner <tim.gardner@canonical.com>
To: linux-kernel@vger.kernel.org
Cc: Tim Gardner <tim.gardner@canonical.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: [PATCH linux-next] nfs: remove kfree() redundant null checks
Date: Tue, 12 Feb 2013 13:03:42 -0700
Message-Id: <1360699422-64416-1-git-send-email-tim.gardner@canonical.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

smatch analysis:

fs/nfs/getroot.c:130 nfs_get_root() info: redundant null
 check on name calling kfree()

fs/nfs/unlink.c:272 nfs_async_unlink() info: redundant null
 check on devname_garbage calling kfree()

Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Signed-off-by: Tim Gardner <tim.gardner@canonical.com>
---
 fs/nfs/getroot.c |    3 +--
 fs/nfs/unlink.c  |    3 +--
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/getroot.c b/fs/nfs/getroot.c
index 033803c..44efaa8 100644
--- a/fs/nfs/getroot.c
+++ b/fs/nfs/getroot.c
@@ -126,8 +126,7 @@ struct dentry *nfs_get_root(struct super_block *sb, struct nfs_fh *mntfh,
 	}
 	spin_unlock(&ret->d_lock);
 out:
-	if (name)
-		kfree(name);
+	kfree(name);
 	nfs_free_fattr(fsinfo.fattr);
 	return ret;
 }
diff --git a/fs/nfs/unlink.c b/fs/nfs/unlink.c
index 13cea63..d26a32f 100644
--- a/fs/nfs/unlink.c
+++ b/fs/nfs/unlink.c
@@ -268,8 +268,7 @@ nfs_async_unlink(struct inode *dir, struct dentry *dentry)
 	 * point dentry is definitely not a root, so we won't need
 	 * that anymore.
 	 */
-	if (devname_garbage)
-		kfree(devname_garbage);
+	kfree(devname_garbage);
 	return 0;
 out_unlock:
 	spin_unlock(&dentry->d_lock);
-- 
1.7.9.5

