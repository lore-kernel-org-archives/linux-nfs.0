Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f41.google.com ([209.85.216.41]:40182 "EHLO
	mail-qa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754795AbaHNNwr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Aug 2014 09:52:47 -0400
Received: by mail-qa0-f41.google.com with SMTP id j7so979151qaq.0
        for <linux-nfs@vger.kernel.org>; Thu, 14 Aug 2014 06:52:47 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: Joe Perches <joe@perches.com>
Cc: Christine Caulfield <ccaulfie@redhat.com>,
        David Teigland <teigland@redhat.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, cluster-devel@redhat.com,
        linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, Kinglong Mee <kinglongmee@gmail.com>
Subject: [PATCH] locks: Remove unused conf argument from lm_grant
Date: Thu, 14 Aug 2014 09:52:40 -0400
Message-Id: <1408024360-5177-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Joe Perches <joe@perches.com>

This argument is always NULL so don't pass it around.

Signed-off-by: Joe Perches <joe@perches.com>
Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/dlm/plock.c     |  8 ++++----
 fs/lockd/svclock.c | 12 +++---------
 include/linux/fs.h |  2 +-
 3 files changed, 8 insertions(+), 14 deletions(-)

diff --git a/fs/dlm/plock.c b/fs/dlm/plock.c
index f704458ea5f5..e0ab3a93eeff 100644
--- a/fs/dlm/plock.c
+++ b/fs/dlm/plock.c
@@ -30,7 +30,7 @@ struct plock_op {
 
 struct plock_xop {
 	struct plock_op xop;
-	void *callback;
+	int (*callback)(struct file_lock *fl, int result);
 	void *fl;
 	void *file;
 	struct file_lock flc;
@@ -190,7 +190,7 @@ static int dlm_plock_callback(struct plock_op *op)
 	struct file *file;
 	struct file_lock *fl;
 	struct file_lock *flc;
-	int (*notify)(void *, void *, int) = NULL;
+	int (*notify)(struct file_lock *fl, int result) = NULL;
 	struct plock_xop *xop = (struct plock_xop *)op;
 	int rv = 0;
 
@@ -209,7 +209,7 @@ static int dlm_plock_callback(struct plock_op *op)
 	notify = xop->callback;
 
 	if (op->info.rv) {
-		notify(fl, NULL, op->info.rv);
+		notify(fl, op->info.rv);
 		goto out;
 	}
 
@@ -228,7 +228,7 @@ static int dlm_plock_callback(struct plock_op *op)
 			  (unsigned long long)op->info.number, file, fl);
 	}
 
-	rv = notify(fl, NULL, 0);
+	rv = notify(fl, 0);
 	if (rv) {
 		/* XXX: We need to cancel the fs lock here: */
 		log_print("dlm_plock_callback: lock granted after lock request "
diff --git a/fs/lockd/svclock.c b/fs/lockd/svclock.c
index ab798a88ec1d..2a6170133c1d 100644
--- a/fs/lockd/svclock.c
+++ b/fs/lockd/svclock.c
@@ -667,22 +667,16 @@ nlmsvc_cancel_blocked(struct net *net, struct nlm_file *file, struct nlm_lock *l
  * deferred rpc for GETLK and SETLK.
  */
 static void
-nlmsvc_update_deferred_block(struct nlm_block *block, struct file_lock *conf,
-			     int result)
+nlmsvc_update_deferred_block(struct nlm_block *block, int result)
 {
 	block->b_flags |= B_GOT_CALLBACK;
 	if (result == 0)
 		block->b_granted = 1;
 	else
 		block->b_flags |= B_TIMED_OUT;
-	if (conf) {
-		if (block->b_fl)
-			__locks_copy_lock(block->b_fl, conf);
-	}
 }
 
-static int nlmsvc_grant_deferred(struct file_lock *fl, struct file_lock *conf,
-					int result)
+static int nlmsvc_grant_deferred(struct file_lock *fl, int result)
 {
 	struct nlm_block *block;
 	int rc = -ENOENT;
@@ -697,7 +691,7 @@ static int nlmsvc_grant_deferred(struct file_lock *fl, struct file_lock *conf,
 					rc = -ENOLCK;
 					break;
 				}
-				nlmsvc_update_deferred_block(block, conf, result);
+				nlmsvc_update_deferred_block(block, result);
 			} else if (result == 0)
 				block->b_granted = 1;
 
diff --git a/include/linux/fs.h b/include/linux/fs.h
index f0890e4a7c25..6cb1f3d182ee 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -869,7 +869,7 @@ struct lock_manager_operations {
 	int (*lm_compare_owner)(struct file_lock *, struct file_lock *);
 	unsigned long (*lm_owner_key)(struct file_lock *);
 	void (*lm_notify)(struct file_lock *);	/* unblock callback */
-	int (*lm_grant)(struct file_lock *, struct file_lock *, int);
+	int (*lm_grant)(struct file_lock *, int);
 	void (*lm_break)(struct file_lock *);
 	int (*lm_change)(struct file_lock **, int);
 };
-- 
1.9.3

