Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:25565 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755255Ab2JOVcf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Oct 2012 17:32:35 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 08/13] NFS: Remove BUG_ON()s in the fs/nfs/inode.c
Date: Mon, 15 Oct 2012 17:31:02 -0400
Message-Id: <1350336667-18770-10-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1350336667-18770-9-git-send-email-Trond.Myklebust@netapp.com>
References: <1350336667-18770-1-git-send-email-Trond.Myklebust@netapp.com>
 <1350336667-18770-2-git-send-email-Trond.Myklebust@netapp.com>
 <1350336667-18770-3-git-send-email-Trond.Myklebust@netapp.com>
 <1350336667-18770-4-git-send-email-Trond.Myklebust@netapp.com>
 <1350336667-18770-5-git-send-email-Trond.Myklebust@netapp.com>
 <1350336667-18770-6-git-send-email-Trond.Myklebust@netapp.com>
 <1350336667-18770-7-git-send-email-Trond.Myklebust@netapp.com>
 <1350336667-18770-8-git-send-email-Trond.Myklebust@netapp.com>
 <1350336667-18770-9-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/inode.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 5c7325c..3967be2 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -112,8 +112,8 @@ void nfs_clear_inode(struct inode *inode)
 	/*
 	 * The following should never happen...
 	 */
-	BUG_ON(nfs_have_writebacks(inode));
-	BUG_ON(!list_empty(&NFS_I(inode)->open_files));
+	WARN_ON_ONCE(nfs_have_writebacks(inode));
+	WARN_ON_ONCE(!list_empty(&NFS_I(inode)->open_files));
 	nfs_zap_acl_cache(inode);
 	nfs_access_zap_cache(inode);
 	nfs_fscache_release_inode_cookie(inode);
-- 
1.7.11.7

