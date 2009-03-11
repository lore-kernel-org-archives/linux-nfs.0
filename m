From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH 12/14] nfsd4: remove use of mutex for file_hashtable
Date: Tue, 10 Mar 2009 20:27:00 -0400
Message-ID: <1236731222-3294-13-git-send-email-bfields@fieldses.org>
References: <1236731222-3294-1-git-send-email-bfields@fieldses.org>
 <1236731222-3294-2-git-send-email-bfields@fieldses.org>
 <1236731222-3294-3-git-send-email-bfields@fieldses.org>
 <1236731222-3294-4-git-send-email-bfields@fieldses.org>
 <1236731222-3294-5-git-send-email-bfields@fieldses.org>
 <1236731222-3294-6-git-send-email-bfields@fieldses.org>
 <1236731222-3294-7-git-send-email-bfields@fieldses.org>
 <1236731222-3294-8-git-send-email-bfields@fieldses.org>
 <1236731222-3294-9-git-send-email-bfields@fieldses.org>
 <1236731222-3294-10-git-send-email-bfields@fieldses.org>
 <1236731222-3294-11-git-send-email-bfields@fieldses.org>
 <1236731222-3294-12-git-send-email-bfields@fieldses.org>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>,
	Alexandros Batsakis <batsakis@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:44059 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752488AbZCKA1F (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Mar 2009 20:27:05 -0400
In-Reply-To: <1236731222-3294-12-git-send-email-bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: J. Bruce Fields <bfields@citi.umich.edu>

As part of reducing the scope of the client_mutex, and in order to
remove the need for mutexes from the callback code (so that callbacks
can be done as asynchronous rpc calls), move manipulations of the
file_hashtable under the recall_lock.

Update the relevant comments while we're here.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Cc: Alexandros Batsakis <batsakis@netapp.com>
---
 fs/nfsd/nfs4callback.c |    2 --
 fs/nfsd/nfs4state.c    |   29 +++++++++++++++++------------
 2 files changed, 17 insertions(+), 14 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 3fd7136..5dcd38e 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -491,8 +491,6 @@ out_put_cred:
 	 * or deleg_return.
 	 */
 	put_nfs4_client(clp);
-	nfs4_lock_state();
 	nfs4_put_delegation(dp);
-	nfs4_unlock_state();
 	return;
 }
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 56e81f9..2f4cb9a 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -78,14 +78,18 @@ static struct nfs4_delegation * find_delegation_stateid(struct inode *ino, state
 static char user_recovery_dirname[PATH_MAX] = "/var/lib/nfs/v4recovery";
 static void nfs4_set_recdir(char *recdir);
 
-/* Locking:
- *
- * client_mutex:
- * 	protects clientid_hashtbl[], clientstr_hashtbl[],
- * 	unconfstr_hashtbl[], uncofid_hashtbl[].
- */
+/* Locking: */
+
+/* Currently used for almost all code touching nfsv4 state: */
 static DEFINE_MUTEX(client_mutex);
 
+/*
+ * Currently used for the del_recall_lru and file hash table.  In an
+ * effort to decrease the scope of the client_mutex, this spinlock may
+ * eventually cover more:
+ */
+static DEFINE_SPINLOCK(recall_lock);
+
 static struct kmem_cache *stateowner_slab = NULL;
 static struct kmem_cache *file_slab = NULL;
 static struct kmem_cache *stateid_slab = NULL;
@@ -116,19 +120,15 @@ opaque_hashval(const void *ptr, int nbytes)
 	return x;
 }
 
-/*
- * Delegation state
- */
-
-/* recall_lock protects the del_recall_lru */
-static DEFINE_SPINLOCK(recall_lock);
 static struct list_head del_recall_lru;
 
 static void
 free_nfs4_file(struct kref *kref)
 {
 	struct nfs4_file *fp = container_of(kref, struct nfs4_file, fi_ref);
+	spin_lock(&recall_lock);
 	list_del(&fp->fi_hash);
+	spin_unlock(&recall_lock);
 	iput(fp->fi_inode);
 	kmem_cache_free(file_slab, fp);
 }
@@ -1004,7 +1004,9 @@ alloc_init_file(struct inode *ino)
 		INIT_LIST_HEAD(&fp->fi_hash);
 		INIT_LIST_HEAD(&fp->fi_stateids);
 		INIT_LIST_HEAD(&fp->fi_delegations);
+		spin_lock(&recall_lock);
 		list_add(&fp->fi_hash, &file_hashtbl[hashval]);
+		spin_unlock(&recall_lock);
 		fp->fi_inode = igrab(ino);
 		fp->fi_id = current_fileid++;
 		fp->fi_had_conflict = false;
@@ -1177,12 +1179,15 @@ find_file(struct inode *ino)
 	unsigned int hashval = file_hashval(ino);
 	struct nfs4_file *fp;
 
+	spin_lock(&recall_lock);
 	list_for_each_entry(fp, &file_hashtbl[hashval], fi_hash) {
 		if (fp->fi_inode == ino) {
+			spin_unlock(&recall_lock);
 			get_nfs4_file(fp);
 			return fp;
 		}
 	}
+	spin_unlock(&recall_lock);
 	return NULL;
 }
 
-- 
1.6.0.4

