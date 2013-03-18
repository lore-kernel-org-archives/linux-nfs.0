Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-oa0-f45.google.com ([209.85.219.45]:60309 "EHLO
	mail-oa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753202Ab3CROtM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Mar 2013 10:49:12 -0400
Received: by mail-oa0-f45.google.com with SMTP id o6so5735490oag.32
        for <linux-nfs@vger.kernel.org>; Mon, 18 Mar 2013 07:49:12 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd: only unhash DRC entries that are in the hashtable
Date: Mon, 18 Mar 2013 10:49:07 -0400
Message-Id: <1363618147-24676-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It's not safe to call hlist_del() on a newly initialized hlist_node.
That leads to a NULL pointer dereference. Only do that if the entry
is hashed.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfscache.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index f5ad28e..ca05f6d 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -102,7 +102,8 @@ nfsd_reply_cache_free_locked(struct svc_cacherep *rp)
 {
 	if (rp->c_type == RC_REPLBUFF)
 		kfree(rp->c_replvec.iov_base);
-	hlist_del(&rp->c_hash);
+	if (!hlist_unhashed(&rp->c_hash))
+		hlist_del(&rp->c_hash);
 	list_del(&rp->c_lru);
 	--num_drc_entries;
 	kmem_cache_free(drc_slab, rp);
-- 
1.7.11.7

