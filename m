Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f41.google.com ([209.85.192.41]:43907 "EHLO
	mail-qg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752993AbaIDMjR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Sep 2014 08:39:17 -0400
Received: by mail-qg0-f41.google.com with SMTP id i50so10022510qgf.14
        for <linux-nfs@vger.kernel.org>; Thu, 04 Sep 2014 05:39:16 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: linux-fsdevel@vger.kernel.org
Cc: linux-nfs@vger.kernel.org, Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-kernel@vger.kernel.org
Subject: [PATCH v2 13/17] locks: remove i_have_this_lease check from __break_lease
Date: Thu,  4 Sep 2014 08:38:39 -0400
Message-Id: <1409834323-7171-14-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1409834323-7171-1-git-send-email-jlayton@primarydata.com>
References: <1409834323-7171-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I think that the intent of this code was to ensure that a process won't
deadlock if it has one fd open with a lease on it and then breaks that
lease by opening another fd. In that case it'll treat the __break_lease
call as if it were non-blocking.

This seems wrong -- the process could (for instance) be multithreaded
and managing different fds via different threads. I also don't see any
mention of this limitation in the (somewhat sketchy) documentation.

Remove the check and the non-blocking behavior when i_have_this_lease
is true.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/locks.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index dc2e9e18f32d..011812490c92 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -1370,7 +1370,6 @@ int __break_lease(struct inode *inode, unsigned int mode, unsigned int type)
 	struct file_lock *new_fl, *flock;
 	struct file_lock *fl;
 	unsigned long break_time;
-	int i_have_this_lease = 0;
 	bool lease_conflict = false;
 	int want_write = (mode & O_ACCMODE) != O_RDONLY;
 	LIST_HEAD(dispose);
@@ -1391,8 +1390,7 @@ int __break_lease(struct inode *inode, unsigned int mode, unsigned int type)
 	for (fl = flock; fl && IS_LEASE(fl); fl = fl->fl_next) {
 		if (leases_conflict(fl, new_fl)) {
 			lease_conflict = true;
-			if (fl->fl_owner == current->files)
-				i_have_this_lease = 1;
+			break;
 		}
 	}
 	if (!lease_conflict)
@@ -1422,7 +1420,7 @@ int __break_lease(struct inode *inode, unsigned int mode, unsigned int type)
 		fl->fl_lmops->lm_break(fl);
 	}
 
-	if (i_have_this_lease || (mode & O_NONBLOCK)) {
+	if (mode & O_NONBLOCK) {
 		trace_break_lease_noblock(inode, new_fl);
 		error = -EWOULDBLOCK;
 		goto out;
-- 
1.9.3

