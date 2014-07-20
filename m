Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtprelay0078.hostedemail.com ([216.40.44.78]:47267 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753710AbaGTSYT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 20 Jul 2014 14:24:19 -0400
From: Joe Perches <joe@perches.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@ZenIV.linux.org.uk>, David Teigland <teigland@redhat.com>,
        Jeff Layton <jlayton@poochiereds.net>,
        Christine Caulfield <ccaulfie@redhat.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        cluster-devel@redhat.com, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: [PATCH 9/9] fs: dlm: lockd: Convert int result to unsigned char type
Date: Sun, 20 Jul 2014 11:23:43 -0700
Message-Id: <65b9ba0dba9c79a938267d5bed7ed0a8211e89ed.1405879494.git.joe@perches.com>
In-Reply-To: <cover.1405879494.git.joe@perches.com>
References: <cover.1405879494.git.joe@perches.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

op->info.rv is an s32, but it's only used as a u8.

Signed-off-by: Joe Perches <joe@perches.com>
---
 fs/dlm/plock.c     |  6 +++---
 fs/lockd/svclock.c | 10 +++++-----
 include/linux/fs.h |  2 +-
 3 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/fs/dlm/plock.c b/fs/dlm/plock.c
index 3e0b6fc..267849d 100644
--- a/fs/dlm/plock.c
+++ b/fs/dlm/plock.c
@@ -30,7 +30,7 @@ struct plock_op {
 
 struct plock_xop {
 	struct plock_op xop;
-	int (*callback)(struct file_lock *fl, int result);
+	int (*callback)(struct file_lock *fl, unsigned char type);
 	void *fl;
 	void *file;
 	struct file_lock flc;
@@ -190,7 +190,7 @@ static int dlm_plock_callback(struct plock_op *op)
 	struct file *file;
 	struct file_lock *fl;
 	struct file_lock *flc;
-	int (*notify)(struct file_lock *fl, int result) = NULL;
+	int (*notify)(struct file_lock *fl, unsigned char type) = NULL;
 	struct plock_xop *xop = (struct plock_xop *)op;
 	int rv = 0;
 
@@ -209,7 +209,7 @@ static int dlm_plock_callback(struct plock_op *op)
 	notify = xop->callback;
 
 	if (op->info.rv) {
-		notify(fl, op->info.rv);
+		notify(fl, (unsigned char)op->info.rv);
 		goto out;
 	}
 
diff --git a/fs/lockd/svclock.c b/fs/lockd/svclock.c
index 2a61701..15532b9 100644
--- a/fs/lockd/svclock.c
+++ b/fs/lockd/svclock.c
@@ -667,16 +667,16 @@ nlmsvc_cancel_blocked(struct net *net, struct nlm_file *file, struct nlm_lock *l
  * deferred rpc for GETLK and SETLK.
  */
 static void
-nlmsvc_update_deferred_block(struct nlm_block *block, int result)
+nlmsvc_update_deferred_block(struct nlm_block *block, unsigned char type)
 {
 	block->b_flags |= B_GOT_CALLBACK;
-	if (result == 0)
+	if (type == 0)
 		block->b_granted = 1;
 	else
 		block->b_flags |= B_TIMED_OUT;
 }
 
-static int nlmsvc_grant_deferred(struct file_lock *fl, int result)
+static int nlmsvc_grant_deferred(struct file_lock *fl, unsigned char type)
 {
 	struct nlm_block *block;
 	int rc = -ENOENT;
@@ -691,8 +691,8 @@ static int nlmsvc_grant_deferred(struct file_lock *fl, int result)
 					rc = -ENOLCK;
 					break;
 				}
-				nlmsvc_update_deferred_block(block, result);
-			} else if (result == 0)
+				nlmsvc_update_deferred_block(block, type);
+			} else if (type == 0)
 				block->b_granted = 1;
 
 			nlmsvc_insert_block_locked(block, 0);
diff --git a/include/linux/fs.h b/include/linux/fs.h
index d083a67..7fbce66 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -842,7 +842,7 @@ struct lock_manager_operations {
 	int (*lm_compare_owner)(struct file_lock *fl1, struct file_lock *fl2);
 	unsigned long (*lm_owner_key)(struct file_lock *fl);
 	void (*lm_notify)(struct file_lock *fl);	/* unblock callback */
-	int (*lm_grant)(struct file_lock *fl, int result);
+	int (*lm_grant)(struct file_lock *fl, unsigned char type);
 	void (*lm_break)(struct file_lock *fl);
 	int (*lm_change)(struct file_lock **fl, int type);
 };
-- 
1.8.1.2.459.gbcd45b4.dirty

