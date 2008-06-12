From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 12/15] NFS: Remove BKL from the symlink code
Date: Thu, 12 Jun 2008 15:28:17 -0400
Message-ID: <20080612192817.24916.1045.stgit@localhost.localdomain>
References: <20080612192817.24916.52065.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:55731 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754329AbYFLTtY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Jun 2008 15:49:24 -0400
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com [10.57.156.154])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m5CJnN13006182
	for <linux-nfs@vger.kernel.org>; Thu, 12 Jun 2008 12:49:23 -0700 (PDT)
In-Reply-To: <20080612192817.24916.52065.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Page cache accesses are serialised using page locks, whereas attribute
updates are serialised using inode->i_lock.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/dir.c |    8 +-------
 1 files changed, 1 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index fd8e799..2be85da 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1482,13 +1482,9 @@ static int nfs_symlink(struct inode *dir, struct dentry *dentry, const char *sym
 	attr.ia_mode = S_IFLNK | S_IRWXUGO;
 	attr.ia_valid = ATTR_MODE;
 
-	lock_kernel();
-
 	page = alloc_page(GFP_HIGHUSER);
-	if (!page) {
-		unlock_kernel();
+	if (!page)
 		return -ENOMEM;
-	}
 
 	kaddr = kmap_atomic(page, KM_USER0);
 	memcpy(kaddr, symname, pathlen);
@@ -1503,7 +1499,6 @@ static int nfs_symlink(struct inode *dir, struct dentry *dentry, const char *sym
 			dentry->d_name.name, symname, error);
 		d_drop(dentry);
 		__free_page(page);
-		unlock_kernel();
 		return error;
 	}
 
@@ -1521,7 +1516,6 @@ static int nfs_symlink(struct inode *dir, struct dentry *dentry, const char *sym
 	} else
 		__free_page(page);
 
-	unlock_kernel();
 	return 0;
 }
 

