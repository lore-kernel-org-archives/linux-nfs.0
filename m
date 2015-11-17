Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f170.google.com ([209.85.220.170]:33007 "EHLO
	mail-qk0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753419AbbKQLx0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Nov 2015 06:53:26 -0500
Received: by qkas77 with SMTP id s77so1711918qka.0
        for <linux-nfs@vger.kernel.org>; Tue, 17 Nov 2015 03:53:26 -0800 (PST)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org, trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Eric Paris <eparis@parisplace.org>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel@vger.kernel.org
Subject: [PATCH v1 08/38] fsnotify: destroy marks with call_srcu instead of dedicated thread
Date: Tue, 17 Nov 2015 06:52:30 -0500
Message-Id: <1447761180-4250-9-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1447761180-4250-1-git-send-email-jeff.layton@primarydata.com>
References: <1447761180-4250-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

At the time that this code was originally written, call_srcu didn't
exist, so this thread was required to ensure that we waited for that
SRCU grace period to settle before finally freeing the object.

It does exist now however and we can much more efficiently use call_srcu
to handle this. That also allows us to potentially use srcu_barrier
to ensure that they are all of the callbacks have run before proceeding.
In order to conserve space, we union the rcu_head with the g_list.

This will be necessary for nfsd which will allocate marks from a
dedicated slabcache. We have to be able to ensure that all of the
objects are destroyed before destroying the cache. That's fairly
difficult to ensure with dedicated thread doing the destruction.

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
Reviewed-by: Jan Kara <jack@suse.com>
---
 fs/notify/mark.c                 | 66 +++++++++-------------------------------
 include/linux/fsnotify_backend.h | 10 +++---
 2 files changed, 20 insertions(+), 56 deletions(-)

diff --git a/fs/notify/mark.c b/fs/notify/mark.c
index c2bd670d4704..00e7072d3c95 100644
--- a/fs/notify/mark.c
+++ b/fs/notify/mark.c
@@ -92,9 +92,6 @@
 #include "fsnotify.h"
 
 struct srcu_struct fsnotify_mark_srcu;
-static DEFINE_SPINLOCK(destroy_lock);
-static LIST_HEAD(destroy_list);
-static DECLARE_WAIT_QUEUE_HEAD(destroy_waitq);
 
 void fsnotify_get_mark(struct fsnotify_mark *mark)
 {
@@ -169,10 +166,19 @@ void fsnotify_detach_mark(struct fsnotify_mark *mark)
 	atomic_dec(&group->num_marks);
 }
 
+static void
+fsnotify_mark_free_rcu(struct rcu_head *rcu)
+{
+	struct fsnotify_mark	*mark;
+
+	mark = container_of(rcu, struct fsnotify_mark, g_rcu);
+	fsnotify_put_mark(mark);
+}
+
 /*
- * Free fsnotify mark. The freeing is actually happening from a kthread which
- * first waits for srcu period end. Caller must have a reference to the mark
- * or be protected by fsnotify_mark_srcu.
+ * Free fsnotify mark. The freeing is actually happening from a call_srcu
+ * callback. Caller must have a reference to the mark or be protected by
+ * fsnotify_mark_srcu.
  */
 void fsnotify_free_mark(struct fsnotify_mark *mark)
 {
@@ -187,10 +193,7 @@ void fsnotify_free_mark(struct fsnotify_mark *mark)
 	mark->flags &= ~FSNOTIFY_MARK_FLAG_ALIVE;
 	spin_unlock(&mark->lock);
 
-	spin_lock(&destroy_lock);
-	list_add(&mark->g_list, &destroy_list);
-	spin_unlock(&destroy_lock);
-	wake_up(&destroy_waitq);
+	call_srcu(&fsnotify_mark_srcu, &mark->g_rcu, fsnotify_mark_free_rcu);
 
 	/*
 	 * Some groups like to know that marks are being freed.  This is a
@@ -387,11 +390,7 @@ err:
 
 	spin_unlock(&mark->lock);
 
-	spin_lock(&destroy_lock);
-	list_add(&mark->g_list, &destroy_list);
-	spin_unlock(&destroy_lock);
-	wake_up(&destroy_waitq);
-
+	call_srcu(&fsnotify_mark_srcu, &mark->g_rcu, fsnotify_mark_free_rcu);
 	return ret;
 }
 
@@ -496,40 +495,3 @@ void fsnotify_init_mark(struct fsnotify_mark *mark,
 	mark->free_mark = free_mark;
 }
 EXPORT_SYMBOL_GPL(fsnotify_init_mark);
-
-static int fsnotify_mark_destroy(void *ignored)
-{
-	struct fsnotify_mark *mark, *next;
-	struct list_head private_destroy_list;
-
-	for (;;) {
-		spin_lock(&destroy_lock);
-		/* exchange the list head */
-		list_replace_init(&destroy_list, &private_destroy_list);
-		spin_unlock(&destroy_lock);
-
-		synchronize_srcu(&fsnotify_mark_srcu);
-
-		list_for_each_entry_safe(mark, next, &private_destroy_list, g_list) {
-			list_del_init(&mark->g_list);
-			fsnotify_put_mark(mark);
-		}
-
-		wait_event_interruptible(destroy_waitq, !list_empty(&destroy_list));
-	}
-
-	return 0;
-}
-
-static int __init fsnotify_mark_init(void)
-{
-	struct task_struct *thread;
-
-	thread = kthread_run(fsnotify_mark_destroy, NULL,
-			     "fsnotify_mark");
-	if (IS_ERR(thread))
-		panic("unable to start fsnotify mark destruction thread.");
-
-	return 0;
-}
-device_initcall(fsnotify_mark_init);
diff --git a/include/linux/fsnotify_backend.h b/include/linux/fsnotify_backend.h
index 533c4408529a..1c582747b410 100644
--- a/include/linux/fsnotify_backend.h
+++ b/include/linux/fsnotify_backend.h
@@ -217,10 +217,12 @@ struct fsnotify_mark {
 	/* Group this mark is for. Set on mark creation, stable until last ref
 	 * is dropped */
 	struct fsnotify_group *group;
-	/* List of marks by group->i_fsnotify_marks. Also reused for queueing
-	 * mark into destroy_list when it's waiting for the end of SRCU period
-	 * before it can be freed. [group->mark_mutex] */
-	struct list_head g_list;
+	union {
+		/* List of marks by group->i_fsnotify_marks. [group->mark_mutex] */
+		struct list_head g_list;
+		/* rcu_head for call_srcu-based destructor */
+		struct rcu_head g_rcu;
+	};
 	/* Protects inode / mnt pointers, flags, masks */
 	spinlock_t lock;
 	/* List of marks for inode / vfsmount [obj_lock] */
-- 
2.4.3

