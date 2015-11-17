Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f54.google.com ([209.85.192.54]:36050 "EHLO
	mail-qg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753434AbbKQLx2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Nov 2015 06:53:28 -0500
Received: by qgad10 with SMTP id d10so3408166qga.3
        for <linux-nfs@vger.kernel.org>; Tue, 17 Nov 2015 03:53:27 -0800 (PST)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org, trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Eric Paris <eparis@parisplace.org>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel@vger.kernel.org
Subject: [PATCH v1 09/38] fsnotify: add a srcu barrier for fsnotify
Date: Tue, 17 Nov 2015 06:52:31 -0500
Message-Id: <1447761180-4250-10-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1447761180-4250-1-git-send-email-jeff.layton@primarydata.com>
References: <1447761180-4250-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

For nfsd, we'll need to be able to ensure that all fsnotify_mark
callbacks have run before we can tear down the nfsd_file_mark_cache.
That's simple now that we're using call_srcu directly. Just use
srcu_barrier to ensure that all the callbacks have completed.

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/notify/mark.c                 | 7 +++++++
 include/linux/fsnotify_backend.h | 2 ++
 2 files changed, 9 insertions(+)

diff --git a/fs/notify/mark.c b/fs/notify/mark.c
index 00e7072d3c95..6b6b99447348 100644
--- a/fs/notify/mark.c
+++ b/fs/notify/mark.c
@@ -204,6 +204,13 @@ void fsnotify_free_mark(struct fsnotify_mark *mark)
 		group->ops->freeing_mark(mark, group);
 }
 
+void
+fsnotify_srcu_barrier(void)
+{
+	srcu_barrier(&fsnotify_mark_srcu);
+}
+EXPORT_SYMBOL_GPL(fsnotify_srcu_barrier);
+
 void fsnotify_destroy_mark(struct fsnotify_mark *mark,
 			   struct fsnotify_group *group)
 {
diff --git a/include/linux/fsnotify_backend.h b/include/linux/fsnotify_backend.h
index 1c582747b410..b211eda20842 100644
--- a/include/linux/fsnotify_backend.h
+++ b/include/linux/fsnotify_backend.h
@@ -360,6 +360,8 @@ extern void fsnotify_destroy_mark(struct fsnotify_mark *mark,
 extern void fsnotify_detach_mark(struct fsnotify_mark *mark);
 /* free mark */
 extern void fsnotify_free_mark(struct fsnotify_mark *mark);
+/* wait for all in-flight fsnotify srcu callbacks to run */
+extern void fsnotify_srcu_barrier(void);
 /* run all the marks in a group, and clear all of the vfsmount marks */
 extern void fsnotify_clear_vfsmount_marks_by_group(struct fsnotify_group *group);
 /* run all the marks in a group, and clear all of the inode marks */
-- 
2.4.3

