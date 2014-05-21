Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:39407 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752139AbaEUOnD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 May 2014 10:43:03 -0400
Date: Wed, 21 May 2014 07:43:03 -0700
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd: remove nfsd4_free_slab
Message-ID: <20140521144303.GA30815@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

No need for a kmem_cache_destroy wrapper in nfsd, just do proper
goto based unwinding.

Signed-off-by: Christoph Hellwig <hch@lst.de>

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index fac2683..59698ec 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -83,11 +83,11 @@ static DEFINE_MUTEX(client_mutex);
  */
 static DEFINE_SPINLOCK(recall_lock);
 
-static struct kmem_cache *openowner_slab = NULL;
-static struct kmem_cache *lockowner_slab = NULL;
-static struct kmem_cache *file_slab = NULL;
-static struct kmem_cache *stateid_slab = NULL;
-static struct kmem_cache *deleg_slab = NULL;
+static struct kmem_cache *openowner_slab;
+static struct kmem_cache *lockowner_slab;
+static struct kmem_cache *file_slab;
+static struct kmem_cache *stateid_slab;
+static struct kmem_cache *deleg_slab;
 
 void
 nfs4_lock_state(void)
@@ -2516,23 +2516,14 @@ static void nfsd4_init_file(struct nfs4_file *fp, struct inode *ino)
 	spin_unlock(&recall_lock);
 }
 
-static void
-nfsd4_free_slab(struct kmem_cache **slab)
-{
-	if (*slab == NULL)
-		return;
-	kmem_cache_destroy(*slab);
-	*slab = NULL;
-}
-
 void
 nfsd4_free_slabs(void)
 {
-	nfsd4_free_slab(&openowner_slab);
-	nfsd4_free_slab(&lockowner_slab);
-	nfsd4_free_slab(&file_slab);
-	nfsd4_free_slab(&stateid_slab);
-	nfsd4_free_slab(&deleg_slab);
+	kmem_cache_destroy(openowner_slab);
+	kmem_cache_destroy(lockowner_slab);
+	kmem_cache_destroy(file_slab);
+	kmem_cache_destroy(stateid_slab);
+	kmem_cache_destroy(deleg_slab);
 }
 
 int
@@ -2541,26 +2532,34 @@ nfsd4_init_slabs(void)
 	openowner_slab = kmem_cache_create("nfsd4_openowners",
 			sizeof(struct nfs4_openowner), 0, 0, NULL);
 	if (openowner_slab == NULL)
-		goto out_nomem;
+		goto out;
 	lockowner_slab = kmem_cache_create("nfsd4_lockowners",
 			sizeof(struct nfs4_lockowner), 0, 0, NULL);
 	if (lockowner_slab == NULL)
-		goto out_nomem;
+		goto out_free_openowner_slab;
 	file_slab = kmem_cache_create("nfsd4_files",
 			sizeof(struct nfs4_file), 0, 0, NULL);
 	if (file_slab == NULL)
-		goto out_nomem;
+		goto out_free_lockowner_slab;
 	stateid_slab = kmem_cache_create("nfsd4_stateids",
 			sizeof(struct nfs4_ol_stateid), 0, 0, NULL);
 	if (stateid_slab == NULL)
-		goto out_nomem;
+		goto out_free_file_slab;
 	deleg_slab = kmem_cache_create("nfsd4_delegations",
 			sizeof(struct nfs4_delegation), 0, 0, NULL);
 	if (deleg_slab == NULL)
-		goto out_nomem;
+		goto out_free_stateid_slab;
 	return 0;
-out_nomem:
-	nfsd4_free_slabs();
+
+out_free_stateid_slab:
+	kmem_cache_destroy(stateid_slab);
+out_free_file_slab:
+	kmem_cache_destroy(file_slab);
+out_free_lockowner_slab:
+	kmem_cache_destroy(lockowner_slab);
+out_free_openowner_slab:
+	kmem_cache_destroy(openowner_slab);
+out:
 	dprintk("nfsd4: out of memory while initializing nfsv4\n");
 	return -ENOMEM;
 }
