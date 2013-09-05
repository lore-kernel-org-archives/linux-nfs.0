Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:40827 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752662Ab3IEQaa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Sep 2013 12:30:30 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        jlayton@redhat.com, Dave Chinner <david@fromorbit.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 02/12] vfs: don't use PARENT/CHILD lock classes for non-directories
Date: Thu,  5 Sep 2013 12:30:08 -0400
Message-Id: <1378398620-23018-5-git-send-email-bfields@redhat.com>
In-Reply-To: <1378398620-23018-1-git-send-email-bfields@redhat.com>
References: <1378398620-23018-1-git-send-email-bfields@redhat.com>
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
 fs/inode.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/inode.c b/fs/inode.c
index 57d273e..f642102 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -995,11 +995,11 @@ void lock_two_nondirectories(struct inode *inode1, struct inode *inode2)
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

