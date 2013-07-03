Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:39214 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933193Ab3GCUMp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Jul 2013 16:12:45 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 02/12] vfs: don't use PARENT/CHILD lock classes for non-directories
Date: Wed,  3 Jul 2013 16:12:26 -0400
Message-Id: <1372882356-14168-3-git-send-email-bfields@redhat.com>
In-Reply-To: <1372882356-14168-1-git-send-email-bfields@redhat.com>
References: <1372882356-14168-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Reserve I_MUTEX_PARENT and I_MUTEX_CHILD for locking of actual
directories.

(Also I_MUTEX_QUOTA isn't really a meaningful name for this locking
class any more; fixed in a later patch.)

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/inode.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/inode.c b/fs/inode.c
index b8afbc7..942451b 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -987,11 +987,11 @@ EXPORT_SYMBOL(unlock_new_inode);
 void lock_two_nondirectories(struct inode *inode1, struct inode *inode2)
 {
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

