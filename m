Return-Path: linux-nfs-owner@vger.kernel.org
Received: from g1t0027.austin.hp.com ([15.216.28.34]:20982 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965613Ab3GCUWC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Jul 2013 16:22:02 -0400
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
Subject: [PATCH v3 19/25] nfs: Change how dentry's d_lock and d_count fields are accessed
Date: Wed,  3 Jul 2013 16:21:49 -0400
Message-Id: <1372882909-23141-1-git-send-email-Waiman.Long@hp.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>, Jeff Layton <jlayton@redhat.com>,
        Miklos Szeredi <mszeredi@suse.cz>, Ingo Molnar <mingo@redhat.com>,
        Thomas Gleixner <tglx@linutronix.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Because of the changes made in dcache.h header file, files that use
the d_lock and d_count fields of the dentry structure need to be
changed accordingly.  All the d_lock's spin_lock() and spin_unlock()
calls are replaced by the corresponding d_lock() and d_unlock() calls.
References to d_count are replaced by the d_ret_count() calls.
There is no change in logic and everything should just work.

Signed-off-by: Waiman Long <Waiman.Long@hp.com>
---
 fs/nfs/dir.c       |   14 +++++++-------
 fs/nfs/getroot.c   |    8 ++++----
 fs/nfs/namespace.c |   16 ++++++++--------
 fs/nfs/unlink.c    |   22 +++++++++++-----------
 4 files changed, 30 insertions(+), 30 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index e093e73..7b9710f 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1175,7 +1175,7 @@ static int nfs_weak_revalidate(struct dentry *dentry, unsigned int flags)
 }
 
 /*
- * This is called from dput() when d_count is going to 0.
+ * This is called from dput() when d_ret_count() is going to 0.
  */
 static int nfs_dentry_delete(const struct dentry *dentry)
 {
@@ -1720,9 +1720,9 @@ int nfs_unlink(struct inode *dir, struct dentry *dentry)
 	dfprintk(VFS, "NFS: unlink(%s/%ld, %s)\n", dir->i_sb->s_id,
 		dir->i_ino, dentry->d_name.name);
 
-	spin_lock(&dentry->d_lock);
-	if (dentry->d_count > 1) {
-		spin_unlock(&dentry->d_lock);
+	d_lock(dentry);
+	if (d_ret_count(dentry) > 1) {
+		d_unlock(dentry);
 		/* Start asynchronous writeout of the inode */
 		write_inode_now(dentry->d_inode, 0);
 		error = nfs_sillyrename(dir, dentry);
@@ -1732,7 +1732,7 @@ int nfs_unlink(struct inode *dir, struct dentry *dentry)
 		__d_drop(dentry);
 		need_rehash = 1;
 	}
-	spin_unlock(&dentry->d_lock);
+	d_unlock(dentry);
 	error = nfs_safe_remove(dentry);
 	if (!error || error == -ENOENT) {
 		nfs_set_verifier(dentry, nfs_save_change_attribute(dir));
@@ -1870,7 +1870,7 @@ int nfs_rename(struct inode *old_dir, struct dentry *old_dentry,
 	dfprintk(VFS, "NFS: rename(%s/%s -> %s/%s, ct=%d)\n",
 		 old_dentry->d_parent->d_name.name, old_dentry->d_name.name,
 		 new_dentry->d_parent->d_name.name, new_dentry->d_name.name,
-		 new_dentry->d_count);
+		 d_ret_count(new_dentry));
 
 	/*
 	 * For non-directories, check whether the target is busy and if so,
@@ -1888,7 +1888,7 @@ int nfs_rename(struct inode *old_dir, struct dentry *old_dentry,
 			rehash = new_dentry;
 		}
 
-		if (new_dentry->d_count > 2) {
+		if (d_ret_count(new_dentry) > 2) {
 			int err;
 
 			/* copy the target dentry's name */
diff --git a/fs/nfs/getroot.c b/fs/nfs/getroot.c
index 44efaa8..ffb21a7 100644
--- a/fs/nfs/getroot.c
+++ b/fs/nfs/getroot.c
@@ -57,9 +57,9 @@ static int nfs_superblock_set_dummy_root(struct super_block *sb, struct inode *i
 		 * Oops, since the test for IS_ROOT() will fail.
 		 */
 		spin_lock(&sb->s_root->d_inode->i_lock);
-		spin_lock(&sb->s_root->d_lock);
+		d_lock(sb->s_root);
 		hlist_del_init(&sb->s_root->d_alias);
-		spin_unlock(&sb->s_root->d_lock);
+		d_unlock(sb->s_root);
 		spin_unlock(&sb->s_root->d_inode->i_lock);
 	}
 	return 0;
@@ -119,12 +119,12 @@ struct dentry *nfs_get_root(struct super_block *sb, struct nfs_fh *mntfh,
 	}
 
 	security_d_instantiate(ret, inode);
-	spin_lock(&ret->d_lock);
+	d_lock(ret);
 	if (IS_ROOT(ret) && !(ret->d_flags & DCACHE_NFSFS_RENAMED)) {
 		ret->d_fsdata = name;
 		name = NULL;
 	}
-	spin_unlock(&ret->d_lock);
+	d_unlock(ret);
 out:
 	kfree(name);
 	nfs_free_fattr(fsinfo.fattr);
diff --git a/fs/nfs/namespace.c b/fs/nfs/namespace.c
index fc8dc20..c930a51 100644
--- a/fs/nfs/namespace.c
+++ b/fs/nfs/namespace.c
@@ -63,7 +63,7 @@ rename_retry:
 	seq = read_seqbegin(&rename_lock);
 	rcu_read_lock();
 	while (1) {
-		spin_lock(&dentry->d_lock);
+		d_lock(dentry);
 		if (IS_ROOT(dentry))
 			break;
 		namelen = dentry->d_name.len;
@@ -73,17 +73,17 @@ rename_retry:
 		end -= namelen;
 		memcpy(end, dentry->d_name.name, namelen);
 		*--end = '/';
-		spin_unlock(&dentry->d_lock);
+		d_unlock(dentry);
 		dentry = dentry->d_parent;
 	}
 	if (read_seqretry(&rename_lock, seq)) {
-		spin_unlock(&dentry->d_lock);
+		d_unlock(dentry);
 		rcu_read_unlock();
 		goto rename_retry;
 	}
 	if ((flags & NFS_PATH_CANONICAL) && *end != '/') {
 		if (--buflen < 0) {
-			spin_unlock(&dentry->d_lock);
+			d_unlock(dentry);
 			rcu_read_unlock();
 			goto Elong;
 		}
@@ -92,7 +92,7 @@ rename_retry:
 	*p = end;
 	base = dentry->d_fsdata;
 	if (!base) {
-		spin_unlock(&dentry->d_lock);
+		d_unlock(dentry);
 		rcu_read_unlock();
 		WARN_ON(1);
 		return end;
@@ -105,17 +105,17 @@ rename_retry:
 	}
 	buflen -= namelen;
 	if (buflen < 0) {
-		spin_unlock(&dentry->d_lock);
+		d_unlock(dentry);
 		rcu_read_unlock();
 		goto Elong;
 	}
 	end -= namelen;
 	memcpy(end, base, namelen);
-	spin_unlock(&dentry->d_lock);
+	d_unlock(dentry);
 	rcu_read_unlock();
 	return end;
 Elong_unlock:
-	spin_unlock(&dentry->d_lock);
+	d_unlock(dentry);
 	rcu_read_unlock();
 	if (read_seqretry(&rename_lock, seq))
 		goto rename_retry;
diff --git a/fs/nfs/unlink.c b/fs/nfs/unlink.c
index 1f1f38f..10643f8 100644
--- a/fs/nfs/unlink.c
+++ b/fs/nfs/unlink.c
@@ -138,7 +138,7 @@ static int nfs_do_call_unlink(struct dentry *parent, struct inode *dir, struct n
 		 */
 		nfs_free_dname(data);
 		ret = nfs_copy_dname(alias, data);
-		spin_lock(&alias->d_lock);
+		d_lock(alias);
 		if (ret == 0 && alias->d_inode != NULL &&
 		    !(alias->d_flags & DCACHE_NFSFS_RENAMED)) {
 			devname_garbage = alias->d_fsdata;
@@ -147,7 +147,7 @@ static int nfs_do_call_unlink(struct dentry *parent, struct inode *dir, struct n
 			ret = 1;
 		} else
 			ret = 0;
-		spin_unlock(&alias->d_lock);
+		d_unlock(alias);
 		nfs_dec_sillycount(dir);
 		dput(alias);
 		/*
@@ -256,13 +256,13 @@ nfs_async_unlink(struct inode *dir, struct dentry *dentry)
 	data->res.dir_attr = &data->dir_attr;
 
 	status = -EBUSY;
-	spin_lock(&dentry->d_lock);
+	d_lock(dentry);
 	if (dentry->d_flags & DCACHE_NFSFS_RENAMED)
 		goto out_unlock;
 	dentry->d_flags |= DCACHE_NFSFS_RENAMED;
 	devname_garbage = dentry->d_fsdata;
 	dentry->d_fsdata = data;
-	spin_unlock(&dentry->d_lock);
+	d_unlock(dentry);
 	/*
 	 * If we'd displaced old cached devname, free it.  At that
 	 * point dentry is definitely not a root, so we won't need
@@ -271,7 +271,7 @@ nfs_async_unlink(struct inode *dir, struct dentry *dentry)
 	kfree(devname_garbage);
 	return 0;
 out_unlock:
-	spin_unlock(&dentry->d_lock);
+	d_unlock(dentry);
 	put_rpccred(data->cred);
 out_free:
 	kfree(data);
@@ -293,13 +293,13 @@ nfs_complete_unlink(struct dentry *dentry, struct inode *inode)
 {
 	struct nfs_unlinkdata	*data = NULL;
 
-	spin_lock(&dentry->d_lock);
+	d_lock(dentry);
 	if (dentry->d_flags & DCACHE_NFSFS_RENAMED) {
 		dentry->d_flags &= ~DCACHE_NFSFS_RENAMED;
 		data = dentry->d_fsdata;
 		dentry->d_fsdata = NULL;
 	}
-	spin_unlock(&dentry->d_lock);
+	d_unlock(dentry);
 
 	if (data != NULL && (NFS_STALE(inode) || !nfs_call_unlink(dentry, data)))
 		nfs_free_unlinkdata(data);
@@ -309,17 +309,17 @@ nfs_complete_unlink(struct dentry *dentry, struct inode *inode)
 static void
 nfs_cancel_async_unlink(struct dentry *dentry)
 {
-	spin_lock(&dentry->d_lock);
+	d_lock(dentry);
 	if (dentry->d_flags & DCACHE_NFSFS_RENAMED) {
 		struct nfs_unlinkdata *data = dentry->d_fsdata;
 
 		dentry->d_flags &= ~DCACHE_NFSFS_RENAMED;
 		dentry->d_fsdata = NULL;
-		spin_unlock(&dentry->d_lock);
+		d_unlock(dentry);
 		nfs_free_unlinkdata(data);
 		return;
 	}
-	spin_unlock(&dentry->d_lock);
+	d_unlock(dentry);
 }
 
 /**
@@ -479,7 +479,7 @@ nfs_sillyrename(struct inode *dir, struct dentry *dentry)
 
 	dfprintk(VFS, "NFS: silly-rename(%s/%s, ct=%d)\n",
 		dentry->d_parent->d_name.name, dentry->d_name.name,
-		dentry->d_count);
+		d_ret_count(dentry));
 	nfs_inc_stats(dir, NFSIOS_SILLYRENAME);
 
 	/*
-- 
1.7.1

