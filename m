Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:51257 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933957Ab3JOUkA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Oct 2013 16:40:00 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-fsdevel@vger.kernel.org
Cc: Christoph Hellwig <hch@infradead.org>, Al Viro <viro@ZenIV.linux.org.uk>,
        linux-nfs@vger.kernel.org, "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 4/5] exportfs: slight reorganization of reconnect loop
Date: Tue, 15 Oct 2013 16:39:32 -0400
Message-Id: <1381869574-10662-5-git-send-email-bfields@redhat.com>
In-Reply-To: <1381869574-10662-1-git-send-email-bfields@redhat.com>
References: <1381869574-10662-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Just cleanup, no change in functionality

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/exportfs/expfs.c |   22 +++++++++++++---------
 1 file changed, 13 insertions(+), 9 deletions(-)

diff --git a/fs/exportfs/expfs.c b/fs/exportfs/expfs.c
index 24fb763..afa7c9c 100644
--- a/fs/exportfs/expfs.c
+++ b/fs/exportfs/expfs.c
@@ -208,19 +208,23 @@ reconnect_path(struct vfsmount *mnt, struct dentry *target_dir, char *nbuf)
 			/* must have found a connected parent - great */
 			clear_disconnected(target_dir);
 			noprogress = 0;
-		} else if (dentry == mnt->mnt_sb->s_root) {
+			dput(dentry);
+			continue;
+		}
+		if (dentry == mnt->mnt_sb->s_root) {
 			printk(KERN_ERR "export: Eeek filesystem root is not connected, impossible\n");
 			clear_disconnected(target_dir);
 			noprogress = 0;
-		} else {
-			/*
-			 * We have hit the top of a disconnected path, try to
-			 * find parent and connect.
-			 */
-			err = reconnect_one(mnt, dentry, nbuf, &noprogress);
-			if (err)
-				return err;
+			dput(dentry);
+			continue;
 		}
+		/*
+		 * We have hit the top of a disconnected path, try to
+		 * find parent and connect.
+		 */
+		err = reconnect_one(mnt, dentry, nbuf, &noprogress);
+		if (err)
+			return err;
 		dput(dentry);
 	}
 
-- 
1.7.9.5

