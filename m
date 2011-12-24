Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:40861 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751819Ab1LXVuP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 24 Dec 2011 16:50:15 -0500
Date: Sat, 24 Dec 2011 16:50:12 -0500
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: file locking fix for 3.2
Message-ID: <20111224215012.GA23495@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please pull the following change from the for-3.2 branch at:

	git://linux-nfs.org/~bfields/linux.git for-3.2

One small 3.2 regression in the file-locking code.  Seems like an
unlikely bug (null dereference on kmalloc failure), but the fix is a
one-liner.

--b.

J. Bruce Fields (1):
      locks: fix null dereference on lease-break failure path

 fs/locks.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

commit b67e18a8e3425725cc17cc7633bccb06fb3c9eda
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Mon Dec 19 17:57:11 2011 -0500

    locks: fix null dereference on lease-break failure path
    
    Commit 778fc546f749c588aa2f6cd50215d2715c374252 "locks: fix tracking of
    inprogress lease breaks" introduced a null dereference on failure to
    allocate memory.
    
    This means an open (without O_NONBLOCK set) on a file with a lease
    applied (generally only done when Samba or nfsd (with v4) is running)
    could crash if a kmalloc() fails.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/locks.c b/fs/locks.c
index 3b0d05d..96a487a 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -1214,8 +1214,8 @@ int __break_lease(struct inode *inode, unsigned int mode)
 	if ((flock == NULL) || !IS_LEASE(flock))
 		goto out;
 
-	if (!locks_conflict(flock, new_fl))
-		goto out;
+	if (flock->fl_type == F_RDLCK && !want_write)
+		goto out; /* no conflict */
 
 	for (fl = flock; fl && IS_LEASE(fl); fl = fl->fl_next)
 		if (fl->fl_owner == current->files)
