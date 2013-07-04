Return-Path: linux-nfs-owner@vger.kernel.org
Received: from g6t0185.atlanta.hp.com ([15.193.32.62]:37558 "EHLO
	g6t0185.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933576Ab3GDDep (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Jul 2013 23:34:45 -0400
From: Waiman Long <Waiman.Long@hp.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org,
        Waiman Long <Waiman.Long@hp.com>, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>,
        Steven Rostedt <rostedt@goodmis.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        Andi Kleen <andi@firstfloor.org>,
        "Chandramouleeswaran, Aswin" <aswin@hp.com>,
        "Norton, Scott J" <scott.norton@hp.com>
Subject: [PATCH v4 10/12] nfs: rename d_count field of dentry to d_refcount
Date: Wed,  3 Jul 2013 23:34:29 -0400
Message-Id: <1372908869-33512-1-git-send-email-Waiman.Long@hp.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>, Jeff Layton <jlayton@redhat.com>,
        Miklos Szeredi <mszeredi@suse.cz>, Ingo Molnar <mingo@redhat.com>,
        Thomas Gleixner <tglx@linutronix.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Because of the d_count name change made in dcache.h, all references
to d_count have to be changed to d_refcount.  There is no change in
logic and everything should just work.

Signed-off-by: Waiman Long <Waiman.Long@hp.com>
---
 fs/nfs/dir.c    |    8 ++++----
 fs/nfs/unlink.c |    2 +-
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index e093e73..9051c18 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1175,7 +1175,7 @@ static int nfs_weak_revalidate(struct dentry *dentry, unsigned int flags)
 }
 
 /*
- * This is called from dput() when d_count is going to 0.
+ * This is called from dput() when d_refcount is going to 0.
  */
 static int nfs_dentry_delete(const struct dentry *dentry)
 {
@@ -1721,7 +1721,7 @@ int nfs_unlink(struct inode *dir, struct dentry *dentry)
 		dir->i_ino, dentry->d_name.name);
 
 	spin_lock(&dentry->d_lock);
-	if (dentry->d_count > 1) {
+	if (dentry->d_refcount > 1) {
 		spin_unlock(&dentry->d_lock);
 		/* Start asynchronous writeout of the inode */
 		write_inode_now(dentry->d_inode, 0);
@@ -1870,7 +1870,7 @@ int nfs_rename(struct inode *old_dir, struct dentry *old_dentry,
 	dfprintk(VFS, "NFS: rename(%s/%s -> %s/%s, ct=%d)\n",
 		 old_dentry->d_parent->d_name.name, old_dentry->d_name.name,
 		 new_dentry->d_parent->d_name.name, new_dentry->d_name.name,
-		 new_dentry->d_count);
+		 new_dentry->d_refcount);
 
 	/*
 	 * For non-directories, check whether the target is busy and if so,
@@ -1888,7 +1888,7 @@ int nfs_rename(struct inode *old_dir, struct dentry *old_dentry,
 			rehash = new_dentry;
 		}
 
-		if (new_dentry->d_count > 2) {
+		if (new_dentry->d_refcount > 2) {
 			int err;
 
 			/* copy the target dentry's name */
diff --git a/fs/nfs/unlink.c b/fs/nfs/unlink.c
index 1f1f38f..34e9fc5 100644
--- a/fs/nfs/unlink.c
+++ b/fs/nfs/unlink.c
@@ -479,7 +479,7 @@ nfs_sillyrename(struct inode *dir, struct dentry *dentry)
 
 	dfprintk(VFS, "NFS: silly-rename(%s/%s, ct=%d)\n",
 		dentry->d_parent->d_name.name, dentry->d_name.name,
-		dentry->d_count);
+		dentry->d_refcount);
 	nfs_inc_stats(dir, NFSIOS_SILLYRENAME);
 
 	/*
-- 
1.7.1

