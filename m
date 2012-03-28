Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:1070 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753507Ab2C1PJP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Mar 2012 11:09:15 -0400
Subject: [PATCH 2/8] nfsd: add link to owner cache detail to svc_export
 structure
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, devel@openvz.org
Date: Wed, 28 Mar 2012 19:09:08 +0400
Message-ID: <20120328150908.2646.72841.stgit@localhost6.localdomain6>
In-Reply-To: <20120328150152.2646.33607.stgit@localhost6.localdomain6>
References: <20120328150152.2646.33607.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Without info about owner cache datail it won't be able to find out, which
per-net cache detail have to be.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 fs/nfsd/export.c            |   10 +++++-----
 include/linux/nfsd/export.h |    1 +
 2 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index 71c5ce3..99ea4c0 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -525,6 +525,7 @@ static int svc_export_parse(struct cache_detail *cd, char *mesg, int mlen)
 		goto out1;
 
 	exp.ex_client = dom;
+	exp.cd = cd;
 
 	/* expiry */
 	err = -EINVAL;
@@ -672,6 +673,7 @@ static void svc_export_init(struct cache_head *cnew, struct cache_head *citem)
 	new->ex_fslocs.locations = NULL;
 	new->ex_fslocs.locations_count = 0;
 	new->ex_fslocs.migrated = 0;
+	new->cd = item->cd;
 }
 
 static void export_update(struct cache_head *cnew, struct cache_head *citem)
@@ -739,8 +741,7 @@ svc_export_lookup(struct svc_export *exp)
 	struct cache_head *ch;
 	int hash = svc_export_hash(exp);
 
-	ch = sunrpc_cache_lookup(&svc_export_cache, &exp->h,
-				 hash);
+	ch = sunrpc_cache_lookup(exp->cd, &exp->h, hash);
 	if (ch)
 		return container_of(ch, struct svc_export, h);
 	else
@@ -753,9 +754,7 @@ svc_export_update(struct svc_export *new, struct svc_export *old)
 	struct cache_head *ch;
 	int hash = svc_export_hash(old);
 
-	ch = sunrpc_cache_update(&svc_export_cache, &new->h,
-				 &old->h,
-				 hash);
+	ch = sunrpc_cache_update(old->cd, &new->h, &old->h, hash);
 	if (ch)
 		return container_of(ch, struct svc_export, h);
 	else
@@ -797,6 +796,7 @@ static svc_export *exp_get_by_name(svc_client *clp, const struct path *path,
 
 	key.ex_client = clp;
 	key.ex_path = *path;
+	key.cd = &svc_export_cache;
 
 	exp = svc_export_lookup(&key);
 	if (exp == NULL)
diff --git a/include/linux/nfsd/export.h b/include/linux/nfsd/export.h
index f85308e..6445529 100644
--- a/include/linux/nfsd/export.h
+++ b/include/linux/nfsd/export.h
@@ -103,6 +103,7 @@ struct svc_export {
 	struct nfsd4_fs_locations ex_fslocs;
 	int			ex_nflavors;
 	struct exp_flavor_info	ex_flavors[MAX_SECINFO_LIST];
+	struct cache_detail	*cd;
 };
 
 /* an "export key" (expkey) maps a filehandlefragement to an

