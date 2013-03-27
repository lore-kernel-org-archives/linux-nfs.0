Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ob0-f170.google.com ([209.85.214.170]:53263 "EHLO
	mail-ob0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752937Ab3C0NSX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Mar 2013 09:18:23 -0400
Received: by mail-ob0-f170.google.com with SMTP id wc20so8164057obb.15
        for <linux-nfs@vger.kernel.org>; Wed, 27 Mar 2013 06:18:22 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, tj@kernel.org,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Subject: [PATCH v1 4/6] nfsd: convert nfs4_alloc_stid to use idr_alloc_cyclic
Date: Wed, 27 Mar 2013 09:18:06 -0400
Message-Id: <1364390288-30968-5-git-send-email-jlayton@redhat.com>
In-Reply-To: <1364390288-30968-1-git-send-email-jlayton@redhat.com>
References: <1364390288-30968-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@redhat.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
---
 fs/nfsd/nfs4state.c | 9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 2e27430..2efb034 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -234,7 +234,6 @@ static struct nfs4_stid *nfs4_alloc_stid(struct nfs4_client *cl, struct
 kmem_cache *slab)
 {
 	struct idr *stateids = &cl->cl_stateids;
-	static int min_stateid = 0;
 	struct nfs4_stid *stid;
 	int new_id;
 
@@ -242,7 +241,7 @@ kmem_cache *slab)
 	if (!stid)
 		return NULL;
 
-	new_id = idr_alloc(stateids, stid, min_stateid, 0, GFP_KERNEL);
+	new_id = idr_alloc_cyclic(stateids, stid, 0, 0, GFP_KERNEL);
 	if (new_id < 0)
 		goto out_free;
 	stid->sc_client = cl;
@@ -261,10 +260,6 @@ kmem_cache *slab)
 	 * amount of time until an id is reused, by ensuring they always
 	 * "increase" (mod INT_MAX):
 	 */
-
-	min_stateid = new_id+1;
-	if (min_stateid == INT_MAX)
-		min_stateid = 0;
 	return stid;
 out_free:
 	kfree(stid);
@@ -1287,7 +1282,7 @@ static struct nfs4_client *create_client(struct xdr_netobj name,
 		spin_unlock(&nn->client_lock);
 		return NULL;
 	}
-	idr_init(&clp->cl_stateids);
+	idr_init_cyclic(&clp->cl_stateids, 0);
 	atomic_set(&clp->cl_refcount, 0);
 	clp->cl_cb_state = NFSD4_CB_UNKNOWN;
 	INIT_LIST_HEAD(&clp->cl_idhash);
-- 
1.7.11.7

