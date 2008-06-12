From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 08/15] NFS: Remove the BKL from nfs_link()
Date: Thu, 12 Jun 2008 15:28:17 -0400
Message-ID: <20080612192817.24916.5291.stgit@localhost.localdomain>
References: <20080612192817.24916.52065.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:47822 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754198AbYFLTtX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Jun 2008 15:49:23 -0400
Received: from sacexrs01.hq.netapp.com (sacexrs01.hq.netapp.com [10.99.190.105])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m5CJnMmW006173
	for <linux-nfs@vger.kernel.org>; Thu, 12 Jun 2008 12:49:22 -0700 (PDT)
In-Reply-To: <20080612192817.24916.52065.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/dir.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 7e072ea..cdcc0c3 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1549,14 +1549,12 @@ nfs_link(struct dentry *old_dentry, struct inode *dir, struct dentry *dentry)
 		old_dentry->d_parent->d_name.name, old_dentry->d_name.name,
 		dentry->d_parent->d_name.name, dentry->d_name.name);
 
-	lock_kernel();
 	d_drop(dentry);
 	error = NFS_PROTO(dir)->link(inode, dir, &dentry->d_name);
 	if (error == 0) {
 		atomic_inc(&inode->i_count);
 		d_add(dentry, inode);
 	}
-	unlock_kernel();
 	return error;
 }
 

