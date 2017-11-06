Return-Path: <trondmy@gmail.com>
Sender: Trond Myklebust <trondmy@gmail.com>
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Benjamin Coddington <bcodding@redhat.com>,
	Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v8 04/11] NFS: Fix a typo in nfs_rename()
Date: Mon,  6 Nov 2017 15:28:04 -0500
Message-Id: <20171106202811.70202-5-trond.myklebust@primarydata.com>
In-Reply-To: <20171106202811.70202-4-trond.myklebust@primarydata.com>
References: <20171106202811.70202-1-trond.myklebust@primarydata.com>
 <20171106202811.70202-2-trond.myklebust@primarydata.com>
 <20171106202811.70202-3-trond.myklebust@primarydata.com>
 <20171106202811.70202-4-trond.myklebust@primarydata.com>
MIME-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

On successful rename, the "old_dentry" is retained and is attached to
the "new_dir", so we need to call nfs_set_verifier() accordingly.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/dir.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 5ceaeb1f6fb6..9dda2e0ef85e 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -2064,7 +2064,7 @@ int nfs_rename(struct inode *old_dir, struct dentry *old_dentry,
 		 * should mark the directories for revalidation.
 		 */
 		d_move(old_dentry, new_dentry);
-		nfs_set_verifier(new_dentry,
+		nfs_set_verifier(old_dentry,
 					nfs_save_change_attribute(new_dir));
 	} else if (error == -ENOENT)
 		nfs_dentry_handle_enoent(old_dentry);
-- 
2.13.6
