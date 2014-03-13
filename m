Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f169.google.com ([209.85.216.169]:38774 "EHLO
	mail-qc0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754983AbaCMTYR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 13 Mar 2014 15:24:17 -0400
Received: by mail-qc0-f169.google.com with SMTP id i17so1775689qcy.0
        for <linux-nfs@vger.kernel.org>; Thu, 13 Mar 2014 12:24:16 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfs: emit a fsnotify_nameremove call in sillyrename codepath
Date: Thu, 13 Mar 2014 15:24:11 -0400
Message-Id: <1394738651-26783-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If a file is sillyrenamed, then the generic vfs_unlink code will skip
emitting fsnotify events for it.

This patch has the sillyrename code do that instead.

In truth this is a little bit odd since we aren't actually removing the
dentry per-se, but renaming it. Still, this is probably the right thing
to do since it's what userland apps expect to see when an unlink()
occurs or some file is renamed on top of the dentry.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/dir.c    | 1 +
 fs/nfs/unlink.c | 2 ++
 2 files changed, 3 insertions(+)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 4a48fe4b84b6..591aec9b1719 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -37,6 +37,7 @@
 #include <linux/sched.h>
 #include <linux/kmemleak.h>
 #include <linux/xattr.h>
+#include <linux/fsnotify.h>
 
 #include "delegation.h"
 #include "iostat.h"
diff --git a/fs/nfs/unlink.c b/fs/nfs/unlink.c
index 11d78944de79..547ed0cd59db 100644
--- a/fs/nfs/unlink.c
+++ b/fs/nfs/unlink.c
@@ -355,6 +355,8 @@ static void nfs_async_rename_done(struct rpc_task *task, void *calldata)
 
 	if (task->tk_status != 0)
 		nfs_cancel_async_unlink(old_dentry);
+	else if (old_dentry->d_flags & DCACHE_NFSFS_RENAMED)
+		fsnotify_nameremove(old_dentry, S_ISDIR(old_dentry->d_inode->i_mode));
 }
 
 /**
-- 
1.8.5.3

