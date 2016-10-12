Return-Path: <neilb@suse.de>
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Jeff Layton <jlayton@redhat.com>
Date: Wed, 12 Oct 2016 13:39:18 +1100
Subject: [PATCH 5/5] NFS: discard nfs_lockowner structure.
Cc: Benjamin Coddington <bcodding@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-ID: <147623995866.19592.11206967676133825339.stgit@noble>
In-Reply-To: <147623977637.19592.12766016823334433969.stgit@noble>
References: <147623977637.19592.12766016823334433969.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
List-ID: <linux-nfs.vger.kernel.org>

It now has only one field and is only used in one structure.
So replaced it in that structure by the field it contains.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 fs/nfs/inode.c         |    4 ++--
 fs/nfs/nfs4state.c     |    2 +-
 fs/nfs/pagelist.c      |    2 +-
 fs/nfs/write.c         |    2 +-
 include/linux/nfs_fs.h |    6 +-----
 5 files changed, 6 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 863c25d99a9b..dd64113908dd 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -702,7 +702,7 @@ EXPORT_SYMBOL_GPL(nfs_getattr);
 static void nfs_init_lock_context(struct nfs_lock_context *l_ctx)
 {
 	atomic_set(&l_ctx->count, 1);
-	l_ctx->lockowner.l_owner = current->files;
+	l_ctx->lockowner = current->files;
 	INIT_LIST_HEAD(&l_ctx->list);
 	atomic_set(&l_ctx->io_count, 0);
 }
@@ -713,7 +713,7 @@ static struct nfs_lock_context *__nfs_find_lock_context(struct nfs_open_context
 	struct nfs_lock_context *pos = head;
 
 	do {
-		if (pos->lockowner.l_owner != current->files)
+		if (pos->lockowner != current->files)
 			continue;
 		atomic_inc(&pos->count);
 		return pos;
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index fbef37fd5704..4763db88c1d4 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -958,7 +958,7 @@ static int nfs4_copy_lock_stateid(nfs4_stateid *dst,
 		fl_owner = current->files;
 		fl_flock_owner = 0;
 	} else {
-		fl_owner = l_ctx->lockowner.l_owner;
+		fl_owner = l_ctx->lockowner;
 		fl_flock_owner = l_ctx->open_context->flock_owner;
 	}
 	spin_lock(&state->state_lock);
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 161f8b13bbaa..6e629b856a00 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -867,7 +867,7 @@ static void nfs_pageio_cleanup_mirroring(struct nfs_pageio_descriptor *pgio)
 static bool nfs_match_lock_context(const struct nfs_lock_context *l1,
 		const struct nfs_lock_context *l2)
 {
-	return l1->lockowner.l_owner == l2->lockowner.l_owner;
+	return l1->lockowner == l2->lockowner;
 }
 
 /**
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 4d5897e6d6cb..6e761f3f4cbf 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1151,7 +1151,7 @@ int nfs_flush_incompatible(struct file *file, struct page *page)
 		if (l_ctx && flctx &&
 		    !(list_empty_careful(&flctx->flc_posix) &&
 		      list_empty_careful(&flctx->flc_flock))) {
-			do_flush |= l_ctx->lockowner.l_owner != current->files;
+			do_flush |= l_ctx->lockowner != current->files;
 		}
 		nfs_release_request(req);
 		if (!do_flush)
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index c90bf92d2b09..d3efb97db6db 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -55,15 +55,11 @@ struct nfs_access_entry {
 	struct rcu_head		rcu_head;
 };
 
-struct nfs_lockowner {
-	fl_owner_t l_owner;
-};
-
 struct nfs_lock_context {
 	atomic_t count;
 	struct list_head list;
 	struct nfs_open_context *open_context;
-	struct nfs_lockowner lockowner;
+	fl_owner_t lockowner;
 	atomic_t io_count;
 };
 
