Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it1-f180.google.com ([209.85.166.180]:51338 "EHLO
        mail-it1-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1729487AbeJAVUd (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Oct 2018 17:20:33 -0400
Received: by mail-it1-f180.google.com with SMTP id 74-v6so11616676itw.1
        for <linux-nfs@vger.kernel.org>; Mon, 01 Oct 2018 07:42:24 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: "J . Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 05/15] knfsd: Allow lockless lookups of the exports
Date: Mon,  1 Oct 2018 10:41:47 -0400
Message-Id: <20181001144157.3515-6-trond.myklebust@hammerspace.com>
In-Reply-To: <20181001144157.3515-5-trond.myklebust@hammerspace.com>
References: <20181001144157.3515-1-trond.myklebust@hammerspace.com>
 <20181001144157.3515-2-trond.myklebust@hammerspace.com>
 <20181001144157.3515-3-trond.myklebust@hammerspace.com>
 <20181001144157.3515-4-trond.myklebust@hammerspace.com>
 <20181001144157.3515-5-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Convert structs svc_expkey and svc_export to allow RCU protected lookups.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfsd/export.c | 14 +++++++-------
 fs/nfsd/export.h |  2 ++
 2 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index a1143f7c2201..802993d8912f 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -46,7 +46,7 @@ static void expkey_put(struct kref *ref)
 	    !test_bit(CACHE_NEGATIVE, &key->h.flags))
 		path_put(&key->ek_path);
 	auth_domain_put(key->ek_client);
-	kfree(key);
+	kfree_rcu(key, ek_rcu);
 }
 
 static void expkey_request(struct cache_detail *cd,
@@ -265,7 +265,7 @@ svc_expkey_lookup(struct cache_detail *cd, struct svc_expkey *item)
 	struct cache_head *ch;
 	int hash = svc_expkey_hash(item);
 
-	ch = sunrpc_cache_lookup(cd, &item->h, hash);
+	ch = sunrpc_cache_lookup_rcu(cd, &item->h, hash);
 	if (ch)
 		return container_of(ch, struct svc_expkey, h);
 	else
@@ -314,7 +314,7 @@ static void svc_export_put(struct kref *ref)
 	auth_domain_put(exp->ex_client);
 	nfsd4_fslocs_free(&exp->ex_fslocs);
 	kfree(exp->ex_uuid);
-	kfree(exp);
+	kfree_rcu(exp, ex_rcu);
 }
 
 static void svc_export_request(struct cache_detail *cd,
@@ -780,7 +780,7 @@ svc_export_lookup(struct svc_export *exp)
 	struct cache_head *ch;
 	int hash = svc_export_hash(exp);
 
-	ch = sunrpc_cache_lookup(exp->cd, &exp->h, hash);
+	ch = sunrpc_cache_lookup_rcu(exp->cd, &exp->h, hash);
 	if (ch)
 		return container_of(ch, struct svc_export, h);
 	else
@@ -1216,9 +1216,9 @@ static int e_show(struct seq_file *m, void *p)
 }
 
 const struct seq_operations nfs_exports_op = {
-	.start	= cache_seq_start,
-	.next	= cache_seq_next,
-	.stop	= cache_seq_stop,
+	.start	= cache_seq_start_rcu,
+	.next	= cache_seq_next_rcu,
+	.stop	= cache_seq_stop_rcu,
 	.show	= e_show,
 };
 
diff --git a/fs/nfsd/export.h b/fs/nfsd/export.h
index c8b74126ddaa..e7daa1f246f0 100644
--- a/fs/nfsd/export.h
+++ b/fs/nfsd/export.h
@@ -61,6 +61,7 @@ struct svc_export {
 	u32			ex_layout_types;
 	struct nfsd4_deviceid_map *ex_devid_map;
 	struct cache_detail	*cd;
+	struct rcu_head		ex_rcu;
 };
 
 /* an "export key" (expkey) maps a filehandlefragement to an
@@ -75,6 +76,7 @@ struct svc_expkey {
 	u32			ek_fsid[6];
 
 	struct path		ek_path;
+	struct rcu_head		ek_rcu;
 };
 
 #define EX_ISSYNC(exp)		(!((exp)->ex_flags & NFSEXP_ASYNC))
-- 
2.17.1
