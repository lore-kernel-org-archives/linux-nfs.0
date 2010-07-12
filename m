Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:16076 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753043Ab0GLWKW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Jul 2010 18:10:22 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 3/3] NFS: nfs_rename() should not have to flush out
 writebacks
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-nfs@vger.kernel.org
Date: Mon, 12 Jul 2010 18:09:33 -0400
Message-ID: <20100712220933.20019.85774.stgit@heimdal.trondhjem.org>
In-Reply-To: <20100712220932.20019.21170.stgit@heimdal.trondhjem.org>
References: <20100712220932.20019.21170.stgit@heimdal.trondhjem.org>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

We don't really support nfs servers that invalidate the file handle after a
rename, so precautions such as flushing out dirty data before renaming the
file are superfluous.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/dir.c |    9 ---------
 1 files changed, 0 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 782b431..067a051 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1652,16 +1652,7 @@ static int nfs_rename(struct inode *old_dir, struct dentry *old_dentry,
 		}
 	}
 
-	/*
-	 * ... prune child dentries and writebacks if needed.
-	 */
-	if (atomic_read(&old_dentry->d_count) > 1) {
-		if (S_ISREG(old_inode->i_mode))
-			nfs_wb_all(old_inode);
-		shrink_dcache_parent(old_dentry);
-	}
 	nfs_inode_return_delegation(old_inode);
-
 	if (new_inode != NULL)
 		nfs_inode_return_delegation(new_inode);
 

