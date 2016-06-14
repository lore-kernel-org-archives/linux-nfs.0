Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:36269 "EHLO
	mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932319AbcFNTFn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Jun 2016 15:05:43 -0400
Received: by mail-it0-f66.google.com with SMTP id h190so412773ith.3
        for <linux-nfs@vger.kernel.org>; Tue, 14 Jun 2016 12:05:43 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 06/12] NFS: Don't hold the inode lock across fsync()
Date: Tue, 14 Jun 2016 15:05:09 -0400
Message-Id: <1465931115-30784-6-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1465931115-30784-5-git-send-email-trond.myklebust@primarydata.com>
References: <1465931115-30784-1-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-2-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-3-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-4-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-5-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commits are no longer required to be serialised.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/file.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 29d7477a62e8..249262b6bcbe 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -277,11 +277,9 @@ nfs_file_fsync(struct file *file, loff_t start, loff_t end, int datasync)
 		ret = filemap_write_and_wait_range(inode->i_mapping, start, end);
 		if (ret != 0)
 			break;
-		inode_lock(inode);
 		ret = nfs_file_fsync_commit(file, start, end, datasync);
 		if (!ret)
 			ret = pnfs_sync_inode(inode, !!datasync);
-		inode_unlock(inode);
 		/*
 		 * If nfs_file_fsync_commit detected a server reboot, then
 		 * resend all dirty pages that might have been covered by
-- 
2.5.5

