Return-Path: linux-kernel-owner@vger.kernel.org
From: Koshy George <koshygp@gmail.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Koshy George <koshygp@gmail.com>
Subject: [PATCH] NFS: nfs4_fs.h: Fix for checkpatch warnings
Date: Sat, 27 Dec 2014 04:30:57 -0700
Message-Id: <1419679857-16626-1-git-send-email-koshygp@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch fix checkpatch warning for nfs4_fs.h

fs/nfs/nfs4_fs.h:134: ERROR: "foo *	bar" should be "foo *bar"
fs/nfs/nfs4_fs.h:416: ERROR: "foo * bar" should be "foo *bar"

Signed-off-by: Koshy George <koshygp@gmail.com>
[Being first patch, need some assistance]
---
 fs/nfs/nfs4_fs.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index a081787..ae336c7 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -131,7 +131,7 @@ enum {
 
 struct nfs4_lock_state {
 	struct list_head	ls_locks;	/* Other lock stateids */
-	struct nfs4_state *	ls_state;	/* Pointer to open state */
+	struct nfs4_state	*ls_state;	/* Pointer to open state */
 #define NFS_LOCK_INITIALIZED 0
 #define NFS_LOCK_LOST        1
 	unsigned long		ls_flags;
@@ -413,7 +413,7 @@ static inline void nfs4_schedule_session_recovery(struct nfs4_session *session,
 extern struct nfs4_state_owner *nfs4_get_state_owner(struct nfs_server *, struct rpc_cred *, gfp_t);
 extern void nfs4_put_state_owner(struct nfs4_state_owner *);
 extern void nfs4_purge_state_owners(struct nfs_server *);
-extern struct nfs4_state * nfs4_get_open_state(struct inode *, struct nfs4_state_owner *);
+extern struct nfs4_state *nfs4_get_open_state(struct inode *, struct nfs4_state_owner *);
 extern void nfs4_put_open_state(struct nfs4_state *);
 extern void nfs4_close_state(struct nfs4_state *, fmode_t);
 extern void nfs4_close_sync(struct nfs4_state *, fmode_t);
-- 
1.9.1

