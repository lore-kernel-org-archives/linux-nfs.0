Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59686 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751088AbcLOOsE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 15 Dec 2016 09:48:04 -0500
From: Benjamin Coddington <bcodding@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Jeff Layton <jlayton@poochiereds.net>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] NFS: nfs_rename() handle -ERESTARTSYS dentry left behind
Date: Thu, 15 Dec 2016 09:48:02 -0500
Message-Id: <11625082826baa811b3ad5b87e1e6e712c6e582d.1481813137.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

An interrupted rename will leave the old dentry behind if the rename
succeeds.  Fix this by forcing a lookup the next time through
->d_revalidate.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/nfs/dir.c | 14 ++++++++++++--
 1 file changed, 12 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 5f1af4cd1a33..5d409616f77e 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -2100,14 +2100,24 @@ int nfs_rename(struct inode *old_dir, struct dentry *old_dentry,
 		d_rehash(rehash);
 	trace_nfs_rename_exit(old_dir, old_dentry,
 			new_dir, new_dentry, error);
-	if (!error) {
+
+	switch (error) {
+	case 0:
 		if (new_inode != NULL)
 			nfs_drop_nlink(new_inode);
 		d_move(old_dentry, new_dentry);
 		nfs_set_verifier(new_dentry,
 					nfs_save_change_attribute(new_dir));
-	} else if (error == -ENOENT)
+		break;
+	case -ENOENT:
 		nfs_dentry_handle_enoent(old_dentry);
+		break;
+	case -ERESTARTSYS:
+		/* The result of the rename is unknown. Play it safe by
+		 * forcing a new lookup */
+		nfs_force_lookup_revalidate(old_dir);
+		nfs_force_lookup_revalidate(new_dir);
+	}
 
 	/* new dentry created? */
 	if (dentry)
-- 
2.9.3

