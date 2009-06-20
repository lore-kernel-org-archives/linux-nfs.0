From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH attempt=3 1/5] VFS: Uninline the function put_mnt_ns()
Date: Sat, 20 Jun 2009 15:33:45 -0400
Message-ID: <20090620193345.14142.28003.stgit@heimdal.trondhjem.org>
References: <20090620193344.14142.22774.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
To: Al Viro <viro@ZenIV.linux.org.uk>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Christoph Hellwig <hch@infradead.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:60581 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751337AbZFTTgy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 20 Jun 2009 15:36:54 -0400
In-Reply-To: <20090620193344.14142.22774.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In order to allow modules to use it without having to export vfsmount_lock.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/namespace.c                |    8 ++++++--
 include/linux/mnt_namespace.h |    9 +--------
 2 files changed, 7 insertions(+), 10 deletions(-)


diff --git a/fs/namespace.c b/fs/namespace.c
index 2dd333b..2465c05 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -2246,10 +2246,14 @@ void __init mnt_init(void)
 	init_mount_tree();
 }
 
-void __put_mnt_ns(struct mnt_namespace *ns)
+void put_mnt_ns(struct mnt_namespace *ns)
 {
-	struct vfsmount *root = ns->root;
+	struct vfsmount *root;
 	LIST_HEAD(umount_list);
+	
+	if (!atomic_dec_and_lock(&ns->count, &vfsmount_lock))
+		return;
+	root = ns->root;
 	ns->root = NULL;
 	spin_unlock(&vfsmount_lock);
 	down_write(&namespace_sem);
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

