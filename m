Return-Path: <trondmy@gmail.com>
Sender: Trond Myklebust <trondmy@gmail.com>
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Benjamin Coddington <bcodding@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 3/3] NFS: Allow getattr to also report readdirplus cache hits
Date: Fri,  2 Dec 2016 09:21:35 -0500
Message-Id: <20161202142135.11515-4-trond.myklebust@primarydata.com>
In-Reply-To: <20161202142135.11515-3-trond.myklebust@primarydata.com>
References: <20161202142135.11515-1-trond.myklebust@primarydata.com>
 <20161202142135.11515-2-trond.myklebust@primarydata.com>
 <20161202142135.11515-3-trond.myklebust@primarydata.com>
List-ID: <linux-nfs.vger.kernel.org>

If the use called stat() on an 'ls -l' workload, and the attribute
cache was successfully revalidate by READDIRPLUS, then we want to
report that back so that the readdir code continues to use
readdirplus.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/dir.c      |  1 -
 fs/nfs/inode.c    | 21 +++++++++++++++++----
 fs/nfs/internal.h |  1 +
 3 files changed, 18 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 22835150579a..f5702457c052 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -459,7 +459,6 @@ bool nfs_use_readdirplus(struct inode *dir, struct dir_context *ctx)
  * use of readdirplus to accelerate any future lookups in the same
  * directory.
  */
-static
 void nfs_advise_use_readdirplus(struct inode *dir)
 {
 	struct nfs_inode *nfsi = NFS_I(dir);
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index d79e0bac836e..75f5a9cb2e66 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -634,15 +634,28 @@ void nfs_setattr_update_inode(struct inode *inode, struct iattr *attr,
 }
 EXPORT_SYMBOL_GPL(nfs_setattr_update_inode);
 
-static void nfs_request_parent_use_readdirplus(struct dentry *dentry)
+static void nfs_readdirplus_parent_cache_miss(struct dentry *dentry)
 {
 	struct dentry *parent;
 
+	if (!nfs_server_capable(d_inode(dentry), NFS_CAP_READDIRPLUS))
+		return;
 	parent = dget_parent(dentry);
 	nfs_force_use_readdirplus(d_inode(parent));
 	dput(parent);
 }
 
+static void nfs_readdirplus_parent_cache_hit(struct dentry *dentry)
+{
+	struct dentry *parent;
+
+	if (!nfs_server_capable(d_inode(dentry), NFS_CAP_READDIRPLUS))
+		return;
+	parent = dget_parent(dentry);
+	nfs_advise_use_readdirplus(d_inode(parent));
+	dput(parent);
+}
+
 static bool nfs_need_revalidate_inode(struct inode *inode)
 {
 	if (NFS_I(inode)->cache_validity &
@@ -683,10 +696,10 @@ int nfs_getattr(struct vfsmount *mnt, struct dentry *dentry, struct kstat *stat)
 	if (need_atime || nfs_need_revalidate_inode(inode)) {
 		struct nfs_server *server = NFS_SERVER(inode);
 
-		if (server->caps & NFS_CAP_READDIRPLUS)
-			nfs_request_parent_use_readdirplus(dentry);
+		nfs_readdirplus_parent_cache_miss(dentry);
 		err = __nfs_revalidate_inode(server, inode);
-	}
+	} else
+		nfs_readdirplus_parent_cache_hit(dentry);
 	if (!err) {
 		generic_fillattr(inode, stat);
 		stat->ino = nfs_compat_user_ino64(NFS_FILEID(inode));
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 4622d5f18e35..6b79c2ca9b9a 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -344,6 +344,7 @@ extern struct nfs_client *nfs_init_client(struct nfs_client *clp,
 			   const struct nfs_client_initdata *);
 
 /* dir.c */
+extern void nfs_advise_use_readdirplus(struct inode *dir);
 extern void nfs_force_use_readdirplus(struct inode *dir);
 extern unsigned long nfs_access_cache_count(struct shrinker *shrink,
 					    struct shrink_control *sc);
-- 
2.9.3
