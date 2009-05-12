From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH] NFS: Fix the notifications when renaming onto an existing
 file
Date: Tue, 12 May 2009 18:24:20 -0400
Message-ID: <20090512222420.6972.25308.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: stable@kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754836AbZELW0h@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NFS appears to be returning an unnecessary "delete" notification when
we're doing an atomic rename. See

  http://bugzilla.gnome.org/show_bug.cgi?id=575684

The fix is to get rid of the redundant call to d_delete().

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
Please apply to 2.6.27 - 2.6.29 stable series...


 fs/nfs/dir.c |    9 ++++-----
 1 files changed, 4 insertions(+), 5 deletions(-)


diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 672368f..3b2f697 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1624,8 +1624,7 @@ static int nfs_rename(struct inode *old_dir, struct dentry *old_dentry,
 		} else if (atomic_read(&new_dentry->d_count) > 1)
 			/* dentry still busy? */
 			goto out;
-	} else
-		nfs_drop_nlink(new_inode);
+	}
 
 go_ahead:
 	/*
@@ -1638,10 +1637,8 @@ go_ahead:
 	}
 	nfs_inode_return_delegation(old_inode);
 
-	if (new_inode != NULL) {
+	if (new_inode != NULL)
 		nfs_inode_return_delegation(new_inode);
-		d_delete(new_dentry);
-	}
 
 	error = NFS_PROTO(old_dir)->rename(old_dir, &old_dentry->d_name,
 					   new_dir, &new_dentry->d_name);
@@ -1650,6 +1647,8 @@ out:
 	if (rehash)
 		d_rehash(rehash);
 	if (!error) {
+		if (new_inode != NULL)
+			nfs_drop_nlink(new_inode);
 		d_move(old_dentry, new_dentry);
 		nfs_set_verifier(new_dentry,
 					nfs_save_change_attribute(new_dir));
