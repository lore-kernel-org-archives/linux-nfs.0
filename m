From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 01/15] NFS: Protect inode->i_nlink updates using
	inode->i_lock
Date: Thu, 12 Jun 2008 15:28:17 -0400
Message-ID: <20080612192817.24916.20323.stgit@localhost.localdomain>
References: <20080612192817.24916.52065.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:33108 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752952AbYFLTtV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Jun 2008 15:49:21 -0400
Received: from sacexrs01.hq.netapp.com (sacexrs01.hq.netapp.com [10.99.190.105])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m5CJnK1g008536
	for <linux-nfs@vger.kernel.org>; Thu, 12 Jun 2008 12:49:20 -0700 (PDT)
In-Reply-To: <20080612192817.24916.52065.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/dir.c |   12 ++++++++++--
 1 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index ff737bf..3af2760 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -870,6 +870,14 @@ static int nfs_dentry_delete(struct dentry *dentry)
 
 }
 
+static void nfs_drop_nlink(struct inode *inode)
+{
+	spin_lock(&inode->i_lock);
+	if (inode->i_nlink > 0)
+		drop_nlink(inode);
+	spin_unlock(&inode->i_lock);
+}
+
 /*
  * Called when the dentry loses inode.
  * We use it to clean up silly-renamed files.
@@ -1420,7 +1428,7 @@ static int nfs_safe_remove(struct dentry *dentry)
 		error = NFS_PROTO(dir)->remove(dir, &dentry->d_name);
 		/* The VFS may want to delete this inode */
 		if (error == 0)
-			drop_nlink(inode);
+			nfs_drop_nlink(inode);
 		nfs_mark_for_revalidate(inode);
 	} else
 		error = NFS_PROTO(dir)->remove(dir, &dentry->d_name);
@@ -1647,7 +1655,7 @@ static int nfs_rename(struct inode *old_dir, struct dentry *old_dentry,
 			/* dentry still busy? */
 			goto out;
 	} else
-		drop_nlink(new_inode);
+		nfs_drop_nlink(new_inode);
 
 go_ahead:
 	/*

