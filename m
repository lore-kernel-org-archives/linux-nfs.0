Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:41354 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751454AbeCPNrY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 16 Mar 2018 09:47:24 -0400
From: Jeff Layton <jlayton@kernel.org>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd: move nfs4_client allocation to dedicated slabcache
Date: Fri, 16 Mar 2018 09:47:22 -0400
Message-Id: <20180316134722.25949-1-jlayton@kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Jeff Layton <jlayton@redhat.com>

On x86_64, it's 1152 bytes, so we can avoid wasting 896 bytes each.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfs4state.c | 18 +++++++++++++-----
 1 file changed, 13 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 0c1eff2be2e8..ff41845500ca 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -98,6 +98,7 @@ enum nfsd4_st_mutex_lock_subclass {
  */
 static DECLARE_WAIT_QUEUE_HEAD(close_wq);
 
+static struct kmem_cache *client_slab;
 static struct kmem_cache *openowner_slab;
 static struct kmem_cache *lockowner_slab;
 static struct kmem_cache *file_slab;
@@ -1794,7 +1795,7 @@ static struct nfs4_client *alloc_client(struct xdr_netobj name)
 	struct nfs4_client *clp;
 	int i;
 
-	clp = kzalloc(sizeof(struct nfs4_client), GFP_KERNEL);
+	clp = kmem_cache_zalloc(client_slab, GFP_KERNEL);
 	if (clp == NULL)
 		return NULL;
 	clp->cl_name.data = kmemdup(name.data, name.len, GFP_KERNEL);
@@ -1825,7 +1826,7 @@ static struct nfs4_client *alloc_client(struct xdr_netobj name)
 err_no_hashtbl:
 	kfree(clp->cl_name.data);
 err_no_name:
-	kfree(clp);
+	kmem_cache_free(client_slab, clp);
 	return NULL;
 }
 
@@ -1845,7 +1846,7 @@ free_client(struct nfs4_client *clp)
 	kfree(clp->cl_ownerstr_hashtbl);
 	kfree(clp->cl_name.data);
 	idr_destroy(&clp->cl_stateids);
-	kfree(clp);
+	kmem_cache_free(client_slab, clp);
 }
 
 /* must be called under the client_lock */
@@ -3471,21 +3472,26 @@ static void nfsd4_init_file(struct knfsd_fh *fh, unsigned int hashval,
 void
 nfsd4_free_slabs(void)
 {
-	kmem_cache_destroy(odstate_slab);
+	kmem_cache_destroy(client_slab);
 	kmem_cache_destroy(openowner_slab);
 	kmem_cache_destroy(lockowner_slab);
 	kmem_cache_destroy(file_slab);
 	kmem_cache_destroy(stateid_slab);
 	kmem_cache_destroy(deleg_slab);
+	kmem_cache_destroy(odstate_slab);
 }
 
 int
 nfsd4_init_slabs(void)
 {
+	client_slab = kmem_cache_create("nfsd4_clients",
+			sizeof(struct nfs4_client), 0, 0, NULL);
+	if (client_slab == NULL)
+		goto out;
 	openowner_slab = kmem_cache_create("nfsd4_openowners",
 			sizeof(struct nfs4_openowner), 0, 0, NULL);
 	if (openowner_slab == NULL)
-		goto out;
+		goto out_free_client_slab;
 	lockowner_slab = kmem_cache_create("nfsd4_lockowners",
 			sizeof(struct nfs4_lockowner), 0, 0, NULL);
 	if (lockowner_slab == NULL)
@@ -3518,6 +3524,8 @@ nfsd4_init_slabs(void)
 	kmem_cache_destroy(lockowner_slab);
 out_free_openowner_slab:
 	kmem_cache_destroy(openowner_slab);
+out_free_client_slab:
+	kmem_cache_destroy(client_slab);
 out:
 	dprintk("nfsd4: out of memory while initializing nfsv4\n");
 	return -ENOMEM;
-- 
2.14.3

