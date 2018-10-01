Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it1-f195.google.com ([209.85.166.195]:37266 "EHLO
        mail-it1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1729489AbeJAVUe (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Oct 2018 17:20:34 -0400
Received: by mail-it1-f195.google.com with SMTP id m9-v6so11757022ita.2
        for <linux-nfs@vger.kernel.org>; Mon, 01 Oct 2018 07:42:26 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: "J . Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 07/15] knfsd: Lockless lookup of NFSv4 identities.
Date: Mon,  1 Oct 2018 10:41:49 -0400
Message-Id: <20181001144157.3515-8-trond.myklebust@hammerspace.com>
In-Reply-To: <20181001144157.3515-7-trond.myklebust@hammerspace.com>
References: <20181001144157.3515-1-trond.myklebust@hammerspace.com>
 <20181001144157.3515-2-trond.myklebust@hammerspace.com>
 <20181001144157.3515-3-trond.myklebust@hammerspace.com>
 <20181001144157.3515-4-trond.myklebust@hammerspace.com>
 <20181001144157.3515-5-trond.myklebust@hammerspace.com>
 <20181001144157.3515-6-trond.myklebust@hammerspace.com>
 <20181001144157.3515-7-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Enable RCU protected lookups of the NFSv4 idmap.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfsd/nfs4idmap.c | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/nfs4idmap.c b/fs/nfsd/nfs4idmap.c
index a5bb76593ce7..bf137fec33ff 100644
--- a/fs/nfsd/nfs4idmap.c
+++ b/fs/nfsd/nfs4idmap.c
@@ -65,6 +65,7 @@ struct ent {
 	u32               id;
 	char              name[IDMAP_NAMESZ];
 	char              authname[IDMAP_NAMESZ];
+	struct rcu_head	  rcu_head;
 };
 
 /* Common entry handling */
@@ -89,7 +90,7 @@ static void
 ent_put(struct kref *ref)
 {
 	struct ent *map = container_of(ref, struct ent, h.ref);
-	kfree(map);
+	kfree_rcu(map, rcu_head);
 }
 
 static struct cache_head *
@@ -264,8 +265,8 @@ idtoname_parse(struct cache_detail *cd, char *buf, int buflen)
 static struct ent *
 idtoname_lookup(struct cache_detail *cd, struct ent *item)
 {
-	struct cache_head *ch = sunrpc_cache_lookup(cd, &item->h,
-						    idtoname_hash(item));
+	struct cache_head *ch = sunrpc_cache_lookup_rcu(cd, &item->h,
+							idtoname_hash(item));
 	if (ch)
 		return container_of(ch, struct ent, h);
 	else
@@ -422,8 +423,8 @@ nametoid_parse(struct cache_detail *cd, char *buf, int buflen)
 static struct ent *
 nametoid_lookup(struct cache_detail *cd, struct ent *item)
 {
-	struct cache_head *ch = sunrpc_cache_lookup(cd, &item->h,
-						    nametoid_hash(item));
+	struct cache_head *ch = sunrpc_cache_lookup_rcu(cd, &item->h,
+							nametoid_hash(item));
 	if (ch)
 		return container_of(ch, struct ent, h);
 	else
-- 
2.17.1
