Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:53084 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759378Ab2IEUzc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Sep 2012 16:55:32 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Jan Kara <jack@suse.cz>, Steven Whitehouse <swhiteho@redhat.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [RFC PATCH 01/13] gfs2: Get rid of I_MUTEX_QUOTA usage
Date: Wed,  5 Sep 2012 16:55:11 -0400
Message-Id: <1346878524-10585-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1346878524-10585-1-git-send-email-bfields@redhat.com>
References: <1346878524-10585-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Jan Kara <jack@suse.cz>

GFS2 uses i_mutex on its system quota inode to synchronize writes to
quota file. Since this is an internal inode to GFS2 (not part of directory
hiearchy or visible by user) we are safe to define locking rules for it. So
let's just get it its own locking class to make it clear.

CC: Steven Whitehouse <swhiteho@redhat.com>
Signed-off-by: Jan Kara <jack@suse.cz>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/gfs2/ops_fstype.c |    8 ++++++++
 fs/gfs2/quota.c      |    2 +-
 2 files changed, 9 insertions(+), 1 deletion(-)

diff --git a/fs/gfs2/ops_fstype.c b/fs/gfs2/ops_fstype.c
index e5af9dc..e443966 100644
--- a/fs/gfs2/ops_fstype.c
+++ b/fs/gfs2/ops_fstype.c
@@ -19,6 +19,7 @@
 #include <linux/mount.h>
 #include <linux/gfs2_ondisk.h>
 #include <linux/quotaops.h>
+#include <linux/lockdep.h>
 
 #include "gfs2.h"
 #include "incore.h"
@@ -766,6 +767,7 @@ fail:
 	return error;
 }
 
+static struct lock_class_key gfs2_quota_imutex_key;
 
 static int init_inodes(struct gfs2_sbd *sdp, int undo)
 {
@@ -803,6 +805,12 @@ static int init_inodes(struct gfs2_sbd *sdp, int undo)
 		fs_err(sdp, "can't get quota file inode: %d\n", error);
 		goto fail_rindex;
 	}
+	/*
+	 * i_mutex on quota files is special. Since this inode is hidden system
+	 * file, we are safe to define locking ourselves.
+	 */
+	lockdep_set_class(&sdp->sd_quota_inode->i_mutex,
+			  &gfs2_quota_imutex_key);
 
 	error = gfs2_rindex_update(sdp);
 	if (error)
diff --git a/fs/gfs2/quota.c b/fs/gfs2/quota.c
index a3bde91..3d9c989 100644
--- a/fs/gfs2/quota.c
+++ b/fs/gfs2/quota.c
@@ -781,7 +781,7 @@ static int do_sync(unsigned int num_qd, struct gfs2_quota_data **qda)
 		return -ENOMEM;
 
 	sort(qda, num_qd, sizeof(struct gfs2_quota_data *), sort_qd, NULL);
-	mutex_lock_nested(&ip->i_inode.i_mutex, I_MUTEX_QUOTA);
+	mutex_lock(&ip->i_inode.i_mutex);
 	for (qx = 0; qx < num_qd; qx++) {
 		error = gfs2_glock_nq_init(qda[qx]->qd_gl, LM_ST_EXCLUSIVE,
 					   GL_NOCACHE, &ghs[qx]);
-- 
1.7.9.5

