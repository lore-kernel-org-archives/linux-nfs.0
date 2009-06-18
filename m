From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH attempt=2 1/5] VFS: Uninline the function put_mnt_ns()
Date: Thu, 18 Jun 2009 14:57:31 -0700
Message-ID: <20090618215731.27808.9905.stgit@heimdal.trondhjem.org>
References: <20090618215731.27808.82272.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
To: Al Viro <viro@ZenIV.linux.org.uk>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Christoph Hellwig <hch@infradead.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:51678 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755857AbZFRV6i (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 18 Jun 2009 17:58:38 -0400
In-Reply-To: <20090618215731.27808.82272.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In order to allow modules to use it without having to export vfsmount_lock.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/namespace.c                |   10 +++++++++-
 include/linux/mnt_namespace.h |    9 +--------
 2 files changed, 10 insertions(+), 9 deletions(-)


diff --git a/fs/namespace.c b/fs/namespace.c
index 2dd333b..1d4f2d8 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -2246,7 +2246,7 @@ void __init mnt_init(void)
 	init_mount_tree();
 }
 
-void __put_mnt_ns(struct mnt_namespace *ns)
+static void __put_mnt_ns(struct mnt_namespace *ns)
 {
 	struct vfsmount *root = ns->root;
 	LIST_HEAD(umount_list);
@@ -2260,3 +2260,11 @@ void __put_mnt_ns(struct mnt_namespace *ns)
 	release_mounts(&umount_list);
 	kfree(ns);
 }
+
+void put_mnt_ns(struct mnt_namespace *ns)
+{
+	if (atomic_dec_and_lock(&ns->count, &vfsmount_lock))
+		/* releases vfsmount_lock */
+		__put_mnt_ns(ns);
+}
+
diff --git a/include/linux/mnt_namespace.h b/include/linux/mnt_namespace.h
index 3a05929..299d11a 100644
--- a/include/linux/mnt_namespace.h
+++ b/include/linux/mnt_namespace.h
@@ -26,14 +26,7 @@ struct fs_struct;
 
 extern struct mnt_namespace *copy_mnt_ns(unsigned long, struct mnt_namespace *,
 		struct fs_struct *);
-extern void __put_mnt_ns(struct mnt_namespace *ns);
-
-static inline void put_mnt_ns(struct mnt_namespace *ns)
-{
-	if (atomic_dec_and_lock(&ns->count, &vfsmount_lock))
-		/* releases vfsmount_lock */
-		__put_mnt_ns(ns);
-}
+extern void put_mnt_ns(struct mnt_namespace *ns);
 
 static inline void exit_mnt_ns(struct task_struct *p)
 {

