Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cobra.newdream.net ([66.33.216.30]:57319 "EHLO
	cobra.newdream.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753661Ab1EJFK4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 May 2011 01:10:56 -0400
From: Sage Weil <sage@newdream.net>
To: viro@ZenIV.linux.org.uk, hch@lst.de, linux-fsdevel@vger.kernel.org
Cc: Sage Weil <sage@newdream.net>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: [PATCH 14/18] nfs: remove unnecessary dentry_unhash on rmdir/rename_dir
Date: Mon,  9 May 2011 21:43:32 -0700
Message-Id: <1305002616-16782-15-git-send-email-sage@newdream.net>
In-Reply-To: <1305002616-16782-1-git-send-email-sage@newdream.net>
References: <1305002616-16782-1-git-send-email-sage@newdream.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

NFS has no problems with lingering references to unlinked directory
inodes.

CC: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: linux-nfs@vger.kernel.org
Signed-off-by: Sage Weil <sage@newdream.net>
---
 fs/nfs/dir.c |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 87daf79..7237672 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1748,8 +1748,6 @@ static int nfs_rmdir(struct inode *dir, struct dentry *dentry)
 	dfprintk(VFS, "NFS: rmdir(%s/%ld), %s\n",
 			dir->i_sb->s_id, dir->i_ino, dentry->d_name.name);
 
-	dentry_unhash(dentry);
-
 	error = NFS_PROTO(dir)->rmdir(dir, &dentry->d_name);
 	/* Ensure the VFS deletes this inode */
 	if (error == 0 && dentry->d_inode != NULL)
@@ -1959,9 +1957,6 @@ static int nfs_rename(struct inode *old_dir, struct dentry *old_dentry,
 		 new_dentry->d_parent->d_name.name, new_dentry->d_name.name,
 		 new_dentry->d_count);
 
-	if (new_inode && S_ISDIR(new_inode->i_mode))
-		dentry_unhash(new_dentry);
-
 	/*
 	 * For non-directories, check whether the target is busy and if so,
 	 * make a copy of the dentry and then do a silly-rename. If the
-- 
1.7.1

