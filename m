Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:44484 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965547AbbD1MB5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Apr 2015 08:01:57 -0400
From: Christoph Hellwig <hch@lst.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jeff Layton <jlayton@primarydata.com>,
        Sachin Bhamare <sachin.bhamare@primarydata.com>,
        linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] nfsd: add a slab cache for odstate structures
Date: Tue, 28 Apr 2015 14:00:48 +0200
Message-Id: <1430222449-3921-2-git-send-email-hch@lst.de>
In-Reply-To: <1430222449-3921-1-git-send-email-hch@lst.de>
References: <1430222449-3921-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfsd/nfs4state.c | 14 +++++++++++---
 1 file changed, 11 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 09c7056..f417362 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -94,6 +94,7 @@ static struct kmem_cache *lockowner_slab;
 static struct kmem_cache *file_slab;
 static struct kmem_cache *stateid_slab;
 static struct kmem_cache *deleg_slab;
+static struct kmem_cache *odstate_slab;
 
 static void free_session(struct nfsd4_session *);
 
@@ -482,7 +483,7 @@ alloc_clnt_odstate(struct nfs4_client *clp)
 {
 	struct nfs4_clnt_odstate *co;
 
-	co = kzalloc(sizeof(struct nfs4_clnt_odstate), GFP_KERNEL);
+	co = kmem_cache_zalloc(odstate_slab, GFP_KERNEL);
 	if (co) {
 		co->co_client = clp;
 		atomic_set(&co->co_odcount, 1);
@@ -522,7 +523,7 @@ put_clnt_odstate(struct nfs4_clnt_odstate *co)
 		spin_unlock(&fp->fi_lock);
 
 		nfsd4_return_all_file_layouts(co->co_client, fp);
-		kfree(co);
+		kmem_cache_free(odstate_slab, co);
 	}
 }
 
@@ -3163,6 +3164,7 @@ static void nfsd4_init_file(struct knfsd_fh *fh, unsigned int hashval,
 void
 nfsd4_free_slabs(void)
 {
+	kmem_cache_destroy(odstate_slab);
 	kmem_cache_destroy(openowner_slab);
 	kmem_cache_destroy(lockowner_slab);
 	kmem_cache_destroy(file_slab);
@@ -3193,8 +3195,14 @@ nfsd4_init_slabs(void)
 			sizeof(struct nfs4_delegation), 0, 0, NULL);
 	if (deleg_slab == NULL)
 		goto out_free_stateid_slab;
+	odstate_slab = kmem_cache_create("nfsd4_odstate",
+			sizeof(struct nfs4_clnt_odstate), 0, 0, NULL);
+	if (odstate_slab == NULL)
+		goto out_free_deleg_slab;
 	return 0;
 
+out_free_deleg_slab:
+	kmem_cache_destroy(deleg_slab);
 out_free_stateid_slab:
 	kmem_cache_destroy(stateid_slab);
 out_free_file_slab:
@@ -4233,7 +4241,7 @@ void nfsd4_cleanup_open_state(struct nfsd4_compound_state *cstate,
 	if (open->op_stp)
 		nfs4_put_stid(&open->op_stp->st_stid);
 	if (open->op_odstate)
-		kfree(open->op_odstate);
+		kmem_cache_free(odstate_slab, open->op_odstate);
 }
 
 __be32
-- 
1.9.1

