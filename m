Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:49039 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752941AbdKIHuy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 9 Nov 2017 02:50:54 -0500
From: NeilBrown <neilb@suse.com>
To: Ian Kent <ikent@redhat.com>, Latchesar Ionkov <lucho@ionkov.net>,
        Jeff Layton <jlayton@redhat.com>,
        Eric Van Hensbergen <ericvh@gmail.com>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Ron Minnich <rminnich@sandia.gov>,
        Trond Myklebust <trondmy@primarydata.com>
Date: Thu, 09 Nov 2017 18:20:24 +1100
Subject: [PATCH 1/3] VFS/nfs/9p: revise meaning of d_weak_invalidate.
Cc: linux-nfs@vger.kernel.org, autofs@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        v9fs-developer@lists.sourceforge.net,
        Linus Torvalds <torvalds@linux-foundation.org>
Message-ID: <151021202419.22743.15031921770111876146.stgit@noble>
In-Reply-To: <151021179901.22743.15252956909042161062.stgit@noble>
References: <151021179901.22743.15252956909042161062.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

d_weak_invalidate() is called when a path lookup ends with
something other than a simple name.
This happen when it:
  - ends "." or "..",
  - ends at a mountpoint (including "/"), or
  - ends at a procfs symlink.

In these cases, revalidating the name of the dentry is inappropriate
as the name wasn't used.  The comments suggest it is necessary to
revalidate the inode, but this is not the case.  Whatever operation
is called on the final dentry has the opportunity to revalidate it,
and will do so - certainly both nfs_getattr and v9fs_vfs_getattr do.

The one case where d_weak_revalidate() *is* needed is for an open()
when d_revalidate() performs some handling of LOOKUP_OPEN.  The same
handling should be performed for d_weak_revalidate().  NFS is the only
filesystem which handles LOOKUP_OPEN, but it doesn't do the handling
in d_weak_revalidate().

A consequence of this is that we do not get proper close-to-open semantics
of paths that do not end with a simple name.
This can easily be confirmed by changing directory to a non-root NFS directory
and running "echo *" while watching network traffic.
CTO semantics requires the file attributes to be revalidated on each open,
but that doesn't happen.

d_weak_revalidate can use the same implementation as d_invalidate by
ensuring that implementation does nothing when LOOKUP_JUMPED is set
(implying d_weak_revalidate was called) and LOOKUP_OPEN is clear (implying
the inodes isn't being opened).

This patch:
  - removes d_weak_invalidate() from 9p as 9p doesn't handle LOOKUP_OPEN.
  - discards nfs_weak_revalidate,
  - uses nfs_revalidate for d_weak_revalidate, ensuring to avoid the
    unnecessary lookup when LOOKUP_JUMPED is set (but still handling
    LOOKUP_OPEN correctly),
  - defines d_weak_revalidate for nfsv4 as well (this omission first lead
    me to examine d_weak_revalidate more closely),
  - removes special revalidation of the root directory in nfs_opendir()
    as this is no longer needed,
  - updates some documentation.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 Documentation/filesystems/porting |    5 +++
 Documentation/filesystems/vfs.txt |   11 ++++---
 fs/9p/vfs_dentry.c                |    1 -
 fs/nfs/dir.c                      |   60 ++++++-------------------------------
 4 files changed, 21 insertions(+), 56 deletions(-)

diff --git a/Documentation/filesystems/porting b/Documentation/filesystems/porting
index 93e0a2404532..f455757ff1c6 100644
--- a/Documentation/filesystems/porting
+++ b/Documentation/filesystems/porting
@@ -606,3 +606,8 @@ in your dentry operations instead.
 	dentry separately, and it now has request_mask and query_flags arguments
 	to specify the fields and sync type requested by statx.  Filesystems not
 	supporting any statx-specific features may ignore the new arguments.
+--
+[recommended]
+	->d_weak_revalidate should perform the same handling of LOOKUP_OPEN as
+	->d_revalidate.  If LOOKUP_OPEN is not set, d_weak_revalidate need not
+	do anything.
diff --git a/Documentation/filesystems/vfs.txt b/Documentation/filesystems/vfs.txt
index 5fd325df59e2..c2025e226b29 100644
--- a/Documentation/filesystems/vfs.txt
+++ b/Documentation/filesystems/vfs.txt
@@ -1015,14 +1015,15 @@ struct dentry_operations {
 	doing a lookup in the parent directory. This includes "/", "." and "..",
 	as well as procfs-style symlinks and mountpoint traversal.
 
-	In this case, we are less concerned with whether the dentry is still
-	fully correct, but rather that the inode is still valid. As with
-	d_revalidate, most local filesystems will set this to NULL since their
-	dcache entries are always valid.
+	Filesystems only need this if they handle LOOKUP_OPEN in
+	d_revalidate, in which case the same handling should be applied
+	in d_weak_revalidate.  When LOOKUP_OPEN is not set,
+	d_weak_revalidate can safely be a no-op.
 
 	This function has the same return code semantics as d_revalidate.
 
-	d_weak_revalidate is only called after leaving rcu-walk mode.
+	d_weak_revalidate is only called after leaving rcu-walk mode,
+	so LOOKUP_RCU is never set.
 
   d_hash: called when the VFS adds a dentry to the hash table. The first
 	dentry passed to d_hash is the parent directory that the name is
diff --git a/fs/9p/vfs_dentry.c b/fs/9p/vfs_dentry.c
index bd456c668d39..99eaf3c6d44c 100644
--- a/fs/9p/vfs_dentry.c
+++ b/fs/9p/vfs_dentry.c
@@ -111,7 +111,6 @@ static int v9fs_lookup_revalidate(struct dentry *dentry, unsigned int flags)
 
 const struct dentry_operations v9fs_cached_dentry_operations = {
 	.d_revalidate = v9fs_lookup_revalidate,
-	.d_weak_revalidate = v9fs_lookup_revalidate,
 	.d_delete = v9fs_cached_dentry_delete,
 	.d_release = v9fs_dentry_release,
 };
diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 5ceaeb1f6fb6..fc349577526f 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -118,13 +118,6 @@ nfs_opendir(struct inode *inode, struct file *filp)
 		goto out;
 	}
 	filp->private_data = ctx;
-	if (filp->f_path.dentry == filp->f_path.mnt->mnt_root) {
-		/* This is a mountpoint, so d_revalidate will never
-		 * have been called, so we need to refresh the
-		 * inode (for close-open consistency) ourselves.
-		 */
-		__nfs_revalidate_inode(NFS_SERVER(inode), inode);
-	}
 out:
 	put_rpccred(cred);
 	return res;
@@ -972,17 +965,19 @@ EXPORT_SYMBOL_GPL(nfs_force_lookup_revalidate);
  * If rcu_walk prevents us from performing a full check, return 0.
  */
 static int nfs_check_verifier(struct inode *dir, struct dentry *dentry,
-			      int rcu_walk)
+			      unsigned int flags)
 {
 	if (IS_ROOT(dentry))
 		return 1;
+	if (flags & LOOKUP_JUMPED)
+		return 1;
 	if (NFS_SERVER(dir)->flags & NFS_MOUNT_LOOKUP_CACHE_NONE)
 		return 0;
 	if (!nfs_verify_change_attribute(dir, dentry->d_time))
 		return 0;
 	/* Revalidate nfsi->cache_change_attribute before we declare a match */
 	if (nfs_mapping_need_revalidate_inode(dir)) {
-		if (rcu_walk)
+		if (flags & LOOKUP_RCU)
 			return 0;
 		if (__nfs_revalidate_inode(NFS_SERVER(dir), dir) < 0)
 			return 0;
@@ -1056,7 +1051,7 @@ int nfs_neg_need_reval(struct inode *dir, struct dentry *dentry,
 		return 0;
 	if (NFS_SERVER(dir)->flags & NFS_MOUNT_LOOKUP_CACHE_NONEG)
 		return 1;
-	return !nfs_check_verifier(dir, dentry, flags & LOOKUP_RCU);
+	return !nfs_check_verifier(dir, dentry, flags);
 }
 
 /*
@@ -1114,7 +1109,7 @@ static int nfs_lookup_revalidate(struct dentry *dentry, unsigned int flags)
 
 	/* Force a full look up iff the parent directory has changed */
 	if (!nfs_is_exclusive_create(dir, flags) &&
-	    nfs_check_verifier(dir, dentry, flags & LOOKUP_RCU)) {
+	    nfs_check_verifier(dir, dentry, flags)) {
 		error = nfs_lookup_verify_inode(inode, flags);
 		if (error) {
 			if (flags & LOOKUP_RCU)
@@ -1129,6 +1124,8 @@ static int nfs_lookup_revalidate(struct dentry *dentry, unsigned int flags)
 
 	if (flags & LOOKUP_RCU)
 		return -ECHILD;
+	if (flags & LOOKUP_JUMPED)
+		return 1;
 
 	if (NFS_STALE(inode))
 		goto out_bad;
@@ -1210,44 +1207,6 @@ static int nfs_lookup_revalidate(struct dentry *dentry, unsigned int flags)
 	return error;
 }
 
-/*
- * A weaker form of d_revalidate for revalidating just the d_inode(dentry)
- * when we don't really care about the dentry name. This is called when a
- * pathwalk ends on a dentry that was not found via a normal lookup in the
- * parent dir (e.g.: ".", "..", procfs symlinks or mountpoint traversals).
- *
- * In this situation, we just want to verify that the inode itself is OK
- * since the dentry might have changed on the server.
- */
-static int nfs_weak_revalidate(struct dentry *dentry, unsigned int flags)
-{
-	struct inode *inode = d_inode(dentry);
-	int error = 0;
-
-	/*
-	 * I believe we can only get a negative dentry here in the case of a
-	 * procfs-style symlink. Just assume it's correct for now, but we may
-	 * eventually need to do something more here.
-	 */
-	if (!inode) {
-		dfprintk(LOOKUPCACHE, "%s: %pd2 has negative inode\n",
-				__func__, dentry);
-		return 1;
-	}
-
-	if (is_bad_inode(inode)) {
-		dfprintk(LOOKUPCACHE, "%s: %pd2 has dud inode\n",
-				__func__, dentry);
-		return 0;
-	}
-
-	if (nfs_mapping_need_revalidate_inode(inode))
-		error = __nfs_revalidate_inode(NFS_SERVER(inode), inode);
-	dfprintk(LOOKUPCACHE, "NFS: %s: inode %lu is %s\n",
-			__func__, inode->i_ino, error ? "invalid" : "valid");
-	return !error;
-}
-
 /*
  * This is called from dput() when d_count is going to 0.
  */
@@ -1314,7 +1273,7 @@ static void nfs_d_release(struct dentry *dentry)
 
 const struct dentry_operations nfs_dentry_operations = {
 	.d_revalidate	= nfs_lookup_revalidate,
-	.d_weak_revalidate	= nfs_weak_revalidate,
+	.d_weak_revalidate	= nfs_lookup_revalidate,
 	.d_delete	= nfs_dentry_delete,
 	.d_iput		= nfs_dentry_iput,
 	.d_automount	= nfs_d_automount,
@@ -1393,6 +1352,7 @@ static int nfs4_lookup_revalidate(struct dentry *, unsigned int);
 
 const struct dentry_operations nfs4_dentry_operations = {
 	.d_revalidate	= nfs4_lookup_revalidate,
+	.d_weak_revalidate	= nfs4_lookup_revalidate,
 	.d_delete	= nfs_dentry_delete,
 	.d_iput		= nfs_dentry_iput,
 	.d_automount	= nfs_d_automount,


