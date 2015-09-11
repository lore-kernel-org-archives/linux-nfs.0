Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f172.google.com ([209.85.160.172]:34846 "EHLO
	mail-yk0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751696AbbIKKy5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Sep 2015 06:54:57 -0400
Received: by ykdu9 with SMTP id u9so87603041ykd.2
        for <linux-nfs@vger.kernel.org>; Fri, 11 Sep 2015 03:54:56 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Eric Paris <eparis@redhat.com>
Subject: [PATCH v4 04/16] fsnotify: export several symbols
Date: Fri, 11 Sep 2015 06:54:30 -0400
Message-Id: <1441968882-7851-5-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1441968882-7851-1-git-send-email-jeff.layton@primarydata.com>
References: <1441968882-7851-1-git-send-email-jeff.layton@primarydata.com>
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
 fs/notify/group.c | 2 ++
 fs/notify/mark.c  | 3 +++
 2 files changed, 5 insertions(+)

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
diff --git a/fs/notify/mark.c b/fs/notify/mark.c
index 3e594ce41010..0dedd692d032 100644
--- a/fs/notify/mark.c
+++ b/fs/notify/mark.c
@@ -184,6 +184,7 @@ void fsnotify_destroy_mark(struct fsnotify_mark *mark,
 	fsnotify_destroy_mark_locked(mark, group);
 	mutex_unlock(&group->mark_mutex);
 }
+EXPORT_SYMBOL_GPL(fsnotify_destroy_mark);
 
 /*
  * Destroy all marks in the given list. The marks must be already detached from
@@ -371,6 +372,7 @@ int fsnotify_add_mark(struct fsnotify_mark *mark, struct fsnotify_group *group,
 	mutex_unlock(&group->mark_mutex);
 	return ret;
 }
+EXPORT_SYMBOL_GPL(fsnotify_add_mark);
 
 /*
  * Given a list of marks, find the mark associated with given group. If found
@@ -440,6 +442,7 @@ void fsnotify_init_mark(struct fsnotify_mark *mark,
 	atomic_set(&mark->refcnt, 1);
 	mark->free_mark = free_mark;
 }
+EXPORT_SYMBOL_GPL(fsnotify_init_mark);
 
 static int fsnotify_mark_destroy(void *ignored)
 {
-- 
2.4.3

