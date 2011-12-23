Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:34253 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753304Ab1LWATW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Dec 2011 19:19:22 -0500
Date: Thu, 22 Dec 2011 19:19:21 -0500
To: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: [PATCH] locks: fix null dereference on lease-break failure path
Message-ID: <20111223001921.GA8875@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Commit 778fc546f749c588aa2f6cd50215d2715c374252 "locks: fix tracking of
inprogress lease breaks" introduced a null dereference on failure to
allocate memory.

This means an open (without O_NONBLOCK set) on a file with a lease
applied (generally only done when Samba or nfsd (with v4) is running)
could crash if a kmalloc() fails.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/locks.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

Eh, supposedly I'm on vacation till the end of the year, but I just
noticed this.... I'll send it in for 3.2 soon if nobody notices a
problem (and if I don't miss the release).

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
-- 
1.7.7.4

