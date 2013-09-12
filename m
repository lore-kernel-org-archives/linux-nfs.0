Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:38787 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752502Ab3ILDQJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Sep 2013 23:16:09 -0400
Date: Wed, 11 Sep 2013 23:16:08 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, jlayton@redhat.com,
        Dave Chinner <david@fromorbit.com>
Subject: [PATCH 02/13--revised] vfs: don't use PARENT/CHILD lock classes for
 non-directories
Message-ID: <20130912031608.GD1462@fieldses.org>
References: <1378929799-1110-1-git-send-email-bfields@redhat.com>
 <1378929799-1110-3-git-send-email-bfields@redhat.com>
 <20130912031430.GC1462@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130912031430.GC1462@fieldses.org>
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

> Argh, apologies!  Revising this patch at one point I forgot to fix up
> one line, and I somehow overlooked the resulting lockdep warning till
> just now.

So the revised patch looks like this.


diff --git a/fs/inode.c b/fs/inode.c
index 20750b0..a8a8ded 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -990,16 +990,16 @@ void lock_two_nondirectories(struct inode *inode1, struct inode *inode2)
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

