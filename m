From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 29/51] nfsd: BUG_ON_UNLOCKED_STATE
Date: Mon, 10 Nov 2008 22:50:36 +0200
Message-ID: <1226350236-11187-1-git-send-email-bhalevy@panasas.com>
References: <491895A0.3040809@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: " J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:44792 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751774AbYKJUut (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:50:49 -0500
In-Reply-To: <491895A0.3040809@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Make sure fi_hash is always traversed and manipulated under the state lock.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4state.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 1a9d121..7fe074a 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -100,6 +100,8 @@ static struct kmem_cache *file_slab = NULL;
 static struct kmem_cache *stateid_slab = NULL;
 static struct kmem_cache *deleg_slab = NULL;
 
+#define BUG_ON_UNLOCKED_STATE() BUG_ON(mutex_trylock(&client_mutex))
+
 void
 nfs4_lock_state(void)
 {
@@ -149,6 +151,7 @@ free_nfs4_file(struct kref *kref)
 static inline void
 put_nfs4_file(struct nfs4_file *fi)
 {
+	BUG_ON_UNLOCKED_STATE();
 	kref_put(&fi->fi_ref, free_nfs4_file);
 }
 
@@ -554,6 +557,8 @@ expire_client(struct nfs4_client *clp)
 	dprintk("NFSD: expire_client cl_count %d\n",
 	                    atomic_read(&clp->cl_count));
 
+	BUG_ON_UNLOCKED_STATE();
+
 	INIT_LIST_HEAD(&reaplist);
 	spin_lock(&recall_lock);
 	while (!list_empty(&clp->cl_delegations)) {
@@ -1625,6 +1630,7 @@ find_openstateowner_str(unsigned int hashval, struct nfsd4_open *open)
 {
 	struct nfs4_stateowner *so = NULL;
 
+	BUG_ON_UNLOCKED_STATE();
 	list_for_each_entry(so, &ownerstr_hashtbl[hashval], so_strhash) {
 		if (same_owner_str(so, &open->op_owner, &open->op_clientid))
 			return so;
@@ -1639,6 +1645,7 @@ find_file(struct inode *ino)
 	unsigned int hashval = file_hashval(ino);
 	struct nfs4_file *fp;
 
+	BUG_ON_UNLOCKED_STATE();
 	list_for_each_entry(fp, &file_hashtbl[hashval], fi_hash) {
 		if (fp->fi_inode == ino) {
 			get_nfs4_file(fp);
-- 
1.6.0.2

