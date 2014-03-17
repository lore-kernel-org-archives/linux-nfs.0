Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f44.google.com ([209.85.192.44]:58750 "EHLO
	mail-qg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932608AbaCQLHM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Mar 2014 07:07:12 -0400
Received: by mail-qg0-f44.google.com with SMTP id a108so16159011qge.3
        for <linux-nfs@vger.kernel.org>; Mon, 17 Mar 2014 04:07:12 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 5/5] nfs: emit a fsnotify_nameremove call in sillyrename codepath
Date: Mon, 17 Mar 2014 07:06:58 -0400
Message-Id: <1395054418-14504-6-git-send-email-jlayton@redhat.com>
In-Reply-To: <1395054418-14504-1-git-send-email-jlayton@redhat.com>
References: <1395054418-14504-1-git-send-email-jlayton@redhat.com>
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
 fs/nfs/unlink.c | 15 +++++++++++++--
 1 file changed, 13 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/unlink.c b/fs/nfs/unlink.c
index 818ded7b7b74..de54129336c6 100644
--- a/fs/nfs/unlink.c
+++ b/fs/nfs/unlink.c
@@ -14,6 +14,7 @@
 #include <linux/sched.h>
 #include <linux/wait.h>
 #include <linux/namei.h>
+#include <linux/fsnotify.h>
 
 #include "internal.h"
 #include "nfs4_fs.h"
@@ -465,8 +466,18 @@ nfs_async_rename(struct inode *old_dir, struct inode *new_dir,
 static void
 nfs_complete_sillyrename(struct rpc_task *task, struct nfs_renamedata *data)
 {
-	if (task->tk_status != 0)
-		nfs_cancel_async_unlink(data->old_dentry);
+	struct dentry *dentry = data->old_dentry;
+
+	if (task->tk_status != 0) {
+		nfs_cancel_async_unlink(dentry);
+		return;
+	}
+
+	/*
+	 * vfs_unlink and the like do not issue this when a file is
+	 * sillyrenamed, so do it here.
+	 */
+	fsnotify_nameremove(dentry, 0);
 }
 
 #define SILLYNAME_PREFIX ".nfs"
-- 
1.8.5.3

