Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f182.google.com ([209.85.216.182]:52089 "EHLO
	mail-qc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753083AbaIDMjR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Sep 2014 08:39:17 -0400
Received: by mail-qc0-f182.google.com with SMTP id m20so10481485qcx.27
        for <linux-nfs@vger.kernel.org>; Thu, 04 Sep 2014 05:39:17 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: linux-fsdevel@vger.kernel.org
Cc: linux-nfs@vger.kernel.org, Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-kernel@vger.kernel.org
Subject: [PATCH v2 03/17] locks: close potential race in lease_get_mtime
Date: Thu,  4 Sep 2014 08:38:29 -0400
Message-Id: <1409834323-7171-4-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1409834323-7171-1-git-send-email-jlayton@primarydata.com>
References: <1409834323-7171-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

lease_get_mtime is called without the i_lock held, so there's no
guarantee about the stability of the list. Between the time when we
assign "flock" and then dereference it to check whether it's a lease
and for write, the lease could be freed.

Ensure that that doesn't occur by taking the i_lock before trying
to check the lease.

Cc: J. Bruce Fields <bfields@fieldses.org>
Signed-off-by: Jeff Layton <jlayton@primarydata.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
---
 fs/locks.c | 14 ++++++++++++--
 1 file changed, 12 insertions(+), 2 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index 18e87f11a25f..4031324e6cca 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -1456,8 +1456,18 @@ EXPORT_SYMBOL(__break_lease);
  */
 void lease_get_mtime(struct inode *inode, struct timespec *time)
 {
-	struct file_lock *flock = inode->i_flock;
-	if (flock && IS_LEASE(flock) && (flock->fl_type == F_WRLCK))
+	bool has_lease = false;
+	struct file_lock *flock;
+
+	if (inode->i_flock) {
+		spin_lock(&inode->i_lock);
+		flock = inode->i_flock;
+		if (flock && IS_LEASE(flock) && (flock->fl_type == F_WRLCK))
+			has_lease = true;
+		spin_unlock(&inode->i_lock);
+	}
+
+	if (has_lease)
 		*time = current_fs_time(inode->i_sb);
 	else
 		*time = inode->i_mtime;
-- 
1.9.3

