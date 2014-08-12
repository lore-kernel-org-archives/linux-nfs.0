Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f43.google.com ([209.85.192.43]:46376 "EHLO
	mail-qg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753126AbaHLOsW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Aug 2014 10:48:22 -0400
Received: by mail-qg0-f43.google.com with SMTP id a108so9783129qge.30
        for <linux-nfs@vger.kernel.org>; Tue, 12 Aug 2014 07:48:21 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: linux-fsdevel@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: [PATCH 2/5] locks: don't reuse file_lock in __posix_lock_file
Date: Tue, 12 Aug 2014 10:48:10 -0400
Message-Id: <1407854893-2698-3-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1407854893-2698-1-git-send-email-jlayton@primarydata.com>
References: <1407854893-2698-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently in the case where a new file lock completely replaces the old
one, we end up overwriting the existing lock with the new info. This
means that we have to call fl_release_private inside i_lock. Change the
code to instead copy the info to new_fl, insert that lock into the
correct spot and then delete the old lock. In a later patch, we'll defer
the freeing of the old lock until after the i_lock has been dropped.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/locks.c | 25 ++++++++++++++-----------
 1 file changed, 14 insertions(+), 11 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index 2c2d4f5022a7..7dd4defb4d8d 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -1022,18 +1022,21 @@ static int __posix_lock_file(struct inode *inode, struct file_lock *request, str
 					locks_delete_lock(before);
 					continue;
 				}
-				/* Replace the old lock with the new one.
-				 * Wake up anybody waiting for the old one,
-				 * as the change in lock type might satisfy
-				 * their needs.
+				/*
+				 * Replace the old lock with new_fl, and
+				 * remove the old one. It's safe to do the
+				 * insert here since we know that we won't be
+				 * using new_fl later, and that the lock is
+				 * just replacing an existing lock.
 				 */
-				locks_wake_up_blocks(fl);
-				fl->fl_start = request->fl_start;
-				fl->fl_end = request->fl_end;
-				fl->fl_type = request->fl_type;
-				locks_release_private(fl);
-				locks_copy_private(fl, request);
-				request = fl;
+				error = -ENOLCK;
+				if (!new_fl)
+					goto out;
+				locks_copy_lock(new_fl, request);
+				request = new_fl;
+				new_fl = NULL;
+				locks_delete_lock(before);
+				locks_insert_lock(before, request);
 				added = true;
 			}
 		}
-- 
1.9.3

