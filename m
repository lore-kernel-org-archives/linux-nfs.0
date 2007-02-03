From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 1/14] locks: always unlock on close
Date: Sat,  3 Feb 2007 00:33:57 -0500
Message-ID: <46341.954303398$1170483729@news.gmane.org>
Cc: nfs@lists.sourceforge.net, Marc Eshel <eshel@almaden.ibm.com>
To: linux-fsdevel@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: 11704806552464-git-send-email-
References: 11704806552464-git-send-email-
Message-Id: <ad8373acbb12f165b625f6065bc0ca86f3982b7f.1170479265.git.bfields@citi.umich.edu>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

From: Marc Eshel <eshel@almaden.ibm.com> - unquoted

Currently locks_remove_posix has a shortcut which returns without doing
anything if it doesn't see anything on the inode's lock list.

That may be the wrong thing to do if a filesystem (such as a network or cluster
filesystem) wants to bookkeep locks on its own.

A filesystem should still be able to keep track of locally held locks (such as
all the locks held by one local process), but the occasional kmalloc() failure,
for example, could get the two sets of data structures out of sync, and it
seems best to allow the filesystem to be authoritative.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/locks.c |    8 --------
 1 files changed, 0 insertions(+), 8 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index 52a8100..4390a95 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -1917,14 +1917,6 @@ void locks_remove_posix(struct file *filp, fl_owner_t owner)
 {
 	struct file_lock lock;
 
-	/*
-	 * If there are no locks held on this file, we don't need to call
-	 * posix_lock_file().  Another process could be setting a lock on this
-	 * file at the same time, but we wouldn't remove that lock anyway.
-	 */
-	if (!filp->f_path.dentry->d_inode->i_flock)
-		return;
-
 	lock.fl_type = F_UNLCK;
 	lock.fl_flags = FL_POSIX | FL_CLOSE;
 	lock.fl_start = 0;
-- 
1.5.0.rc1.g72fe

