Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f42.google.com ([209.85.192.42]:33350 "EHLO
	mail-qg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752982AbbJTReE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Oct 2015 13:34:04 -0400
Received: by qgeo38 with SMTP id o38so21854817qge.0
        for <linux-nfs@vger.kernel.org>; Tue, 20 Oct 2015 10:34:03 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Al Viro <viro@ZenIV.linux.org.uk>, Eric Paris <eparis@redhat.com>
Subject: [PATCH v6 06/19] fsnotify: export several symbols
Date: Tue, 20 Oct 2015 13:33:39 -0400
Message-Id: <1445362432-18869-7-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1445362432-18869-1-git-send-email-jeff.layton@primarydata.com>
References: <1445362432-18869-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

With nfsd's new open-file caching infrastructure, we need a way to know
when unlinks occur so it can close files that it may be holding open.
fsnotify fits the bill nicely, but the symbols aren't currently exported
to modules. Export some of its symbols so nfsd can use this
infrastructure.

Cc: Eric Paris <eparis@redhat.com>
Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/notify/group.c      | 2 ++
 fs/notify/inode_mark.c | 1 +
 fs/notify/mark.c       | 4 ++++
 3 files changed, 7 insertions(+)

diff --git a/fs/notify/group.c b/fs/notify/group.c
index d16b62cb2854..295d08800126 100644
--- a/fs/notify/group.c
+++ b/fs/notify/group.c
@@ -81,6 +81,7 @@ void fsnotify_put_group(struct fsnotify_group *group)
 	if (atomic_dec_and_test(&group->refcnt))
 		fsnotify_final_destroy_group(group);
 }
+EXPORT_SYMBOL_GPL(fsnotify_put_group);
 
 /*
  * Create a new fsnotify_group and hold a reference for the group returned.
@@ -109,6 +110,7 @@ struct fsnotify_group *fsnotify_alloc_group(const struct fsnotify_ops *ops)
 
 	return group;
 }
+EXPORT_SYMBOL_GPL(fsnotify_alloc_group);
 
 int fsnotify_fasync(int fd, struct file *file, int on)
 {
diff --git a/fs/notify/inode_mark.c b/fs/notify/inode_mark.c
index e785fd954c30..76e608b8894c 100644
--- a/fs/notify/inode_mark.c
+++ b/fs/notify/inode_mark.c
@@ -87,6 +87,7 @@ struct fsnotify_mark *fsnotify_find_inode_mark(struct fsnotify_group *group,
 
 	return mark;
 }
+EXPORT_SYMBOL_GPL(fsnotify_find_inode_mark);
 
 /*
  * If we are setting a mark mask on an inode mark we should pin the inode
diff --git a/fs/notify/mark.c b/fs/notify/mark.c
index fc0df4442f7b..c2bd670d4704 100644
--- a/fs/notify/mark.c
+++ b/fs/notify/mark.c
@@ -109,6 +109,7 @@ void fsnotify_put_mark(struct fsnotify_mark *mark)
 		mark->free_mark(mark);
 	}
 }
+EXPORT_SYMBOL_GPL(fsnotify_put_mark);
 
 /* Calculate mask of events for a list of marks */
 u32 fsnotify_recalc_mask(struct hlist_head *head)
@@ -208,6 +209,7 @@ void fsnotify_destroy_mark(struct fsnotify_mark *mark,
 	mutex_unlock(&group->mark_mutex);
 	fsnotify_free_mark(mark);
 }
+EXPORT_SYMBOL_GPL(fsnotify_destroy_mark);
 
 void fsnotify_destroy_marks(struct hlist_head *head, spinlock_t *lock)
 {
@@ -402,6 +404,7 @@ int fsnotify_add_mark(struct fsnotify_mark *mark, struct fsnotify_group *group,
 	mutex_unlock(&group->mark_mutex);
 	return ret;
 }
+EXPORT_SYMBOL_GPL(fsnotify_add_mark);
 
 /*
  * Given a list of marks, find the mark associated with given group. If found
@@ -492,6 +495,7 @@ void fsnotify_init_mark(struct fsnotify_mark *mark,
 	atomic_set(&mark->refcnt, 1);
 	mark->free_mark = free_mark;
 }
+EXPORT_SYMBOL_GPL(fsnotify_init_mark);
 
 static int fsnotify_mark_destroy(void *ignored)
 {
-- 
2.4.3

