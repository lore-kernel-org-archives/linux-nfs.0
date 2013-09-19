Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:39101 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752072Ab3ISUuj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 Sep 2013 16:50:39 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        jlayton@redhat.com, Dave Chinner <david@fromorbit.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 02/13] vfs: don't use PARENT/CHILD lock classes for non-directories
Date: Thu, 19 Sep 2013 16:50:26 -0400
Message-Id: <1379623837-30798-3-git-send-email-bfields@redhat.com>
In-Reply-To: <1379623837-30798-1-git-send-email-bfields@redhat.com>
References: <1379623837-30798-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Reserve I_MUTEX_PARENT and I_MUTEX_CHILD for locking of actual
directories.

(Also I_MUTEX_QUOTA isn't really a meaningful name for this locking
class any more; fixed in a later patch.)

Acked-by: Jeff Layton <jlayton@redhat.com>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/inode.c |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/fs/inode.c b/fs/inode.c
index 9271c48..04d0e2d 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -959,16 +959,16 @@ void lock_two_nondirectories(struct inode *inode1, struct inode *inode2)
 {
 	WARN_ON_ONCE(S_ISDIR(inode1->i_mode));
 	if (inode1 == inode2 || !inode2) {
-		mutex_lock_nested(&inode1->i_mutex, I_MUTEX_PARENT);
+		mutex_lock(&inode1->i_mutex);
 		return;
 	}
 	WARN_ON_ONCE(S_ISDIR(inode2->i_mode));
 	if (inode1 < inode2) {
-		mutex_lock_nested(&inode1->i_mutex, I_MUTEX_PARENT);
-		mutex_lock_nested(&inode2->i_mutex, I_MUTEX_CHILD);
+		mutex_lock(&inode1->i_mutex);
+		mutex_lock_nested(&inode2->i_mutex, I_MUTEX_QUOTA);
 	} else {
-		mutex_lock_nested(&inode2->i_mutex, I_MUTEX_PARENT);
-		mutex_lock_nested(&inode1->i_mutex, I_MUTEX_CHILD);
+		mutex_lock(&inode2->i_mutex);
+		mutex_lock_nested(&inode1->i_mutex, I_MUTEX_QUOTA);
 	}
 }
 EXPORT_SYMBOL(lock_two_nondirectories);
-- 
1.7.9.5

