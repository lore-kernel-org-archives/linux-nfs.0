Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it1-f194.google.com ([209.85.166.194]:37831 "EHLO
        mail-it1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728619AbeJEV10 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Oct 2018 17:27:26 -0400
Received: by mail-it1-f194.google.com with SMTP id e74-v6so2980325ita.2
        for <linux-nfs@vger.kernel.org>; Fri, 05 Oct 2018 07:28:29 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: J Bruce Fields <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] NFS: Fix up a typo in nfs_dns_ent_put
Date: Fri,  5 Oct 2018 10:27:20 -0400
Message-Id: <20181005142720.25280-1-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

call_rcu() needs to take a first argument of type (struct rcu_head *).

Fixes: fd497f1e40d9 ("NFS: Lockless DNS lookups")
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
- Apologies for the screwup

 fs/nfs/dns_resolve.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/dns_resolve.c b/fs/nfs/dns_resolve.c
index e93a5dc07c8c..a7d3df85736d 100644
--- a/fs/nfs/dns_resolve.c
+++ b/fs/nfs/dns_resolve.c
@@ -116,7 +116,7 @@ static void nfs_dns_ent_put(struct kref *ref)
 	struct nfs_dns_ent *item;
 
 	item = container_of(ref, struct nfs_dns_ent, h.ref);
-	call_rcu(item, nfs_dns_ent_free_rcu);
+	call_rcu(&item->rcu_head, nfs_dns_ent_free_rcu);
 }
 
 static struct cache_head *nfs_dns_ent_alloc(void)
-- 
2.17.1
