From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH attempt=2 2/5] VFS: Add VFS helper functions for setting up
 private namespaces
Date: Thu, 18 Jun 2009 14:57:31 -0700
Message-ID: <20090618215731.27808.16968.stgit@heimdal.trondhjem.org>
References: <20090618215731.27808.82272.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
To: Al Viro <viro@ZenIV.linux.org.uk>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Christoph Hellwig <hch@infradead.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20090618215731.27808.82272.stgit@heimdal.trondhjem.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The purpose of this patch is to improve the remote mount path lookup
support for distributed filesystems such as the NFSv4 client.

When given a mount command of the form "mount server:/foo/bar /mnt", the
NFSv4 client is required to look up the filehandle for "server:/", and
then look up each component of the remote mount path "foo/bar" in order
to find the directory that is actually going to be mounted on /mnt.
Following that remote mount path may involve following symlinks,
crossing server-side mount points and even following referrals to
filesystem volumes on other servers.

Since the standard VFS path lookup code already supports walking paths
that contain all these features (using in-kernel automounts for
following referrals) we would like to be able to reuse that rather than
duplicate the full path traversal functionality in the NFSv4 client code.

This patch therefore defines a VFS helper function create_mnt_ns(), that
sets up a temporary filesystem namespace and attaches a root filesystem to
it.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/namespace.c                |   46 +++++++++++++++++++++++++++++++++--------
 include/linux/mnt_namespace.h |    1 +
 2 files changed, 38 insertions(+), 9 deletions(-)


diff --git a/fs/namespace.c b/fs/namespace.c
index 1d4f2d8..fb52edb 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -1937,6 +1937,21 @@ dput_out:
 	return retval;
 }
 
+static struct mnt_namespace *alloc_mnt_ns(void)
+{
+	struct mnt_namespace *new_ns;
+
+	new_ns = kmalloc(sizeof(struct mnt_namespace), GFP_KERNEL);
+	if (!new_ns)
+		return ERR_PTR(-ENOMEM);
+	atomic_set(&new_ns->count, 1);
+	new_ns->root = NULL;
+	INIT_LIST_HEAD(&new_ns->list);
+	init_waitqueue_head(&new_ns->poll);
+	new_ns->event = 0;
+	return new_ns;
+}
+
 /*
  * Allocate a new namespace structure and populate it with contents
  * copied from the namespace of the passed in task structure.
@@ -1948,14 +1963,9 @@ static struct mnt_namespace *dup_mnt_ns(struct mnt_namespace *mnt_ns,
 	struct vfsmount *rootmnt = NULL, *pwdmnt = NULL;
 	struct vfsmount *p, *q;
 
-	new_ns = kmalloc(sizeof(struct mnt_namespace), GFP_KERNEL);
-	if (!new_ns)
-		return ERR_PTR(-ENOMEM);
-
-	atomic_set(&new_ns->count, 1);
-	INIT_LIST_HEAD(&new_ns->list);
-	init_waitqueue_head(&new_ns->poll);
-	new_ns->event = 0;
+	new_ns = alloc_mnt_ns();
+	if (IS_ERR(new_ns))
+		return new_ns;
 
 	down_write(&namespace_sem);
 	/* First pass: copy the tree topology */
@@ -2019,6 +2029,24 @@ struct mnt_namespace *copy_mnt_ns(unsigned long flags, struct mnt_namespace *ns,
 	return new_ns;
 }
 
+/**
+ * create_mnt_ns - creates a private namespace and adds a root filesystem
+ * @mnt: pointer to the new root filesystem mountpoint
+ */
+struct mnt_namespace *create_mnt_ns(struct vfsmount *mnt)
+{
+	struct mnt_namespace *new_ns;
+
+	new_ns = alloc_mnt_ns();
+	if (!IS_ERR(new_ns)) {
+		mnt->mnt_ns = new_ns;
+		new_ns->root = mnt;
+		list_add(&new_ns->list, &new_ns->root->mnt_list);
+	}
+	return new_ns;
+}
+EXPORT_SYMBOL(create_mnt_ns);
+
 SYSCALL_DEFINE5(mount, char __user *, dev_name, char __user *, dir_name,
 		char __user *, type, unsigned long, flags, void __user *, data)
 {
@@ -2267,4 +2295,4 @@ void put_mnt_ns(struct mnt_namespace *ns)
 		/* releases vfsmount_lock */
 		__put_mnt_ns(ns);
 }
-
+EXPORT_SYMBOL(put_mnt_ns);
diff --git a/include/linux/mnt_namespace.h b/include/linux/mnt_namespace.h
index 299d11a..3beb259 100644
--- a/include/linux/mnt_namespace.h
+++ b/include/linux/mnt_namespace.h
@@ -24,6 +24,7 @@ struct proc_mounts {
 
 struct fs_struct;
 
+extern struct mnt_namespace *create_mnt_ns(struct vfsmount *mnt);
 extern struct mnt_namespace *copy_mnt_ns(unsigned long, struct mnt_namespace *,
 		struct fs_struct *);
 extern void put_mnt_ns(struct mnt_namespace *ns);

