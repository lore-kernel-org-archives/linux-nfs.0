Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:8749 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932497Ab2JCXIr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Oct 2012 19:08:47 -0400
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 1/1] NFS: dont revalidate the inode when using local locks
Date: Wed,  3 Oct 2012 19:08:44 -0400
Message-Id: <1349305724-28173-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This drastically improves performance when using lock-heavy workloads that are amenable to using local locks.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/file.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index a6708e6..fd0155f 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -765,7 +765,7 @@ do_setlk(struct file *filp, int cmd, struct file_lock *fl, int is_local)
 	 * This makes locking act as a cache coherency point.
 	 */
 	nfs_sync_mapping(filp->f_mapping);
-	if (!nfs_have_delegation(inode, FMODE_READ)) {
+	if ((!is_local) && !nfs_have_delegation(inode, FMODE_READ)) {
 		if (is_time_granular(&NFS_SERVER(inode)->time_delta))
 			__nfs_revalidate_inode(NFS_SERVER(inode), inode);
 		else
-- 
1.7.1

