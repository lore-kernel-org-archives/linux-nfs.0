Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-oa0-f41.google.com ([209.85.219.41]:46101 "EHLO
	mail-oa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754287Ab3C0T3s (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Mar 2013 15:29:48 -0400
Received: by mail-oa0-f41.google.com with SMTP id f4so6765009oah.0
        for <linux-nfs@vger.kernel.org>; Wed, 27 Mar 2013 12:29:47 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, tj@kernel.org,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Subject: [PATCH v2 4/6] nfsd: convert nfs4_alloc_stid to use idr_alloc_cyclic
Date: Wed, 27 Mar 2013 15:29:36 -0400
Message-Id: <1364412578-7462-5-git-send-email-jlayton@redhat.com>
In-Reply-To: <1364412578-7462-1-git-send-email-jlayton@redhat.com>
References: <1364412578-7462-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@redhat.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
---
 fs/nfsd/nfs4state.c | 7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 2e27430..417c848 100644
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
-- 
1.7.11.7

