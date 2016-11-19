Return-Path: <trondmy@gmail.com>
Sender: Trond Myklebust <trondmy@gmail.com>
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Benjamin Coddington <bcodding@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 3/3] NFS: Replace nfs_force_use_readdirplus() with nfs_advise_use_readdirplus()
Date: Sat, 19 Nov 2016 11:54:57 -0500
Message-Id: <1479574497-38268-4-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1479574497-38268-3-git-send-email-trond.myklebust@primarydata.com>
References: <1479574497-38268-1-git-send-email-trond.myklebust@primarydata.com>
 <1479574497-38268-2-git-send-email-trond.myklebust@primarydata.com>
 <1479574497-38268-3-git-send-email-trond.myklebust@primarydata.com>
List-ID: <linux-nfs.vger.kernel.org>

Now that the two functions are the same, just merge them.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com
---
 fs/nfs/dir.c      | 14 --------------
 fs/nfs/inode.c    |  2 +-
 fs/nfs/internal.h |  2 +-
 3 files changed, 2 insertions(+), 16 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 5befd382be7d..5ee9666fa8b4 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -462,7 +462,6 @@ bool nfs_use_readdirplus(struct inode *dir, struct dir_context *ctx)
  * and calling nfs_advise_use_readdirplus, then forcing a
  * cache flush.
  */
-static
 void nfs_advise_use_readdirplus(struct inode *dir)
 {
 	struct nfs_inode *nfsi = NFS_I(dir);
@@ -474,19 +473,6 @@ void nfs_advise_use_readdirplus(struct inode *dir)
 	}
 }
 
-/*
- * This function is mainly for use by nfs_getattr().
- *
- * If this is an 'ls -l', we want to force use of readdirplus.
- * Do this by checking if there is an active file descriptor
- * and calling nfs_advise_use_readdirplus, then forcing a
- * cache flush.
- */
-void nfs_force_use_readdirplus(struct inode *dir)
-{
-	nfs_advise_use_readdirplus(dir);
-}
-
 static
 void nfs_prime_dcache(struct dentry *parent, struct nfs_entry *entry)
 {
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 3575e3408bd7..02453d76bfea 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -639,7 +639,7 @@ static void nfs_request_parent_use_readdirplus(struct dentry *dentry)
 	struct dentry *parent;
 
 	parent = dget_parent(dentry);
-	nfs_force_use_readdirplus(d_inode(parent));
+	nfs_advise_use_readdirplus(d_inode(parent));
 	dput(parent);
 }
 
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 80bcc0befb07..f625a7b2ef14 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -346,7 +346,7 @@ extern struct nfs_client *nfs_init_client(struct nfs_client *clp,
 			   const struct nfs_client_initdata *);
 
 /* dir.c */
-extern void nfs_force_use_readdirplus(struct inode *dir);
+extern void nfs_advise_use_readdirplus(struct inode *dir);
 extern unsigned long nfs_access_cache_count(struct shrinker *shrink,
 					    struct shrink_control *sc);
 extern unsigned long nfs_access_cache_scan(struct shrinker *shrink,
-- 
2.7.4
