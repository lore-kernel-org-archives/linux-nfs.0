Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f43.google.com ([209.85.192.43]:60133 "EHLO
	mail-qg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751353AbaHWOla (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 23 Aug 2014 10:41:30 -0400
Received: by mail-qg0-f43.google.com with SMTP id a108so11409223qge.2
        for <linux-nfs@vger.kernel.org>; Sat, 23 Aug 2014 07:41:29 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: linux-fsdevel@vger.kernel.org
Cc: bfields@fieldses.org, hch@infradead.org, cluster-devel@redhat.com,
        linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: [PATCH 01/10] locks: close potential race in lease_get_mtime
Date: Sat, 23 Aug 2014 10:41:09 -0400
Message-Id: <1408804878-1331-2-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1408804878-1331-1-git-send-email-jlayton@primarydata.com>
References: <1408804878-1331-1-git-send-email-jlayton@primarydata.com>
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
---
 fs/locks.c | 14 ++++++++++++--
 1 file changed, 12 insertions(+), 2 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index d7e15a256f8f..58ce8897f2e4 100644
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

