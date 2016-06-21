Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:35563 "EHLO
	mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751099AbcFUVfX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Jun 2016 17:35:23 -0400
Received: by mail-io0-f193.google.com with SMTP id u25so3727214iou.2
        for <linux-nfs@vger.kernel.org>; Tue, 21 Jun 2016 14:35:22 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 06/12] NFS: Don't hold the inode lock across fsync()
Date: Tue, 21 Jun 2016 17:34:47 -0400
Message-Id: <1466544893-12058-6-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1466544893-12058-5-git-send-email-trond.myklebust@primarydata.com>
References: <1466544893-12058-1-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-2-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-3-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-4-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-5-git-send-email-trond.myklebust@primarydata.com>
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

