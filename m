Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:20576 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758378Ab2C1PKA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Mar 2012 11:10:00 -0400
Subject: [PATCH 8/8] nfsd: pass pointer to expkey cache down to stack wherever
 possible.
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, devel@openvz.org
Date: Wed, 28 Mar 2012 19:09:50 +0400
Message-ID: <20120328150950.2646.70232.stgit@localhost6.localdomain6>
In-Reply-To: <20120328150152.2646.33607.stgit@localhost6.localdomain6>
References: <20120328150152.2646.33607.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This cache will be per-net soon. And it's easier to get the pointer to desired
per-net instance only once and then pass it down instead of discovering it in
every place were required.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 fs/nfsd/export.c |   32 ++++++++++++++++----------------
 1 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index c237b0a..429b2f5 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -71,9 +71,9 @@ static int expkey_upcall(struct cache_detail *cd, struct cache_head *h)
 	return sunrpc_cache_pipe_upcall(cd, h, expkey_request);
 }
 
-static struct svc_expkey *svc_expkey_update(struct svc_expkey *new, struct svc_expkey *old);
-static struct svc_expkey *svc_expkey_lookup(struct svc_expkey *);
-static struct cache_detail svc_expkey_cache;
+static struct svc_expkey *svc_expkey_update(struct cache_detail *cd, struct svc_expkey *new,
+					    struct svc_expkey *old);
+static struct svc_expkey *svc_expkey_lookup(struct cache_detail *cd, struct svc_expkey *);
 
 static int expkey_parse(struct cache_detail *cd, char *mesg, int mlen)
 {
@@ -131,7 +131,7 @@ static int expkey_parse(struct cache_detail *cd, char *mesg, int mlen)
 	key.ek_fsidtype = fsidtype;
 	memcpy(key.ek_fsid, buf, len);
 
-	ek = svc_expkey_lookup(&key);
+	ek = svc_expkey_lookup(cd, &key);
 	err = -ENOMEM;
 	if (!ek)
 		goto out;
@@ -145,7 +145,7 @@ static int expkey_parse(struct cache_detail *cd, char *mesg, int mlen)
 	err = 0;
 	if (len == 0) {
 		set_bit(CACHE_NEGATIVE, &key.h.flags);
-		ek = svc_expkey_update(&key, ek);
+		ek = svc_expkey_update(cd, &key, ek);
 		if (!ek)
 			err = -ENOMEM;
 	} else {
@@ -155,7 +155,7 @@ static int expkey_parse(struct cache_detail *cd, char *mesg, int mlen)
 
 		dprintk("Found the path %s\n", buf);
 
-		ek = svc_expkey_update(&key, ek);
+		ek = svc_expkey_update(cd, &key, ek);
 		if (!ek)
 			err = -ENOMEM;
 		path_put(&key.ek_path);
@@ -268,13 +268,12 @@ svc_expkey_hash(struct svc_expkey *item)
 }
 
 static struct svc_expkey *
-svc_expkey_lookup(struct svc_expkey *item)
+svc_expkey_lookup(struct cache_detail *cd, struct svc_expkey *item)
 {
 	struct cache_head *ch;
 	int hash = svc_expkey_hash(item);
 
-	ch = sunrpc_cache_lookup(&svc_expkey_cache, &item->h,
-				 hash);
+	ch = sunrpc_cache_lookup(cd, &item->h, hash);
 	if (ch)
 		return container_of(ch, struct svc_expkey, h);
 	else
@@ -282,13 +281,13 @@ svc_expkey_lookup(struct svc_expkey *item)
 }
 
 static struct svc_expkey *
-svc_expkey_update(struct svc_expkey *new, struct svc_expkey *old)
+svc_expkey_update(struct cache_detail *cd, struct svc_expkey *new,
+		  struct svc_expkey *old)
 {
 	struct cache_head *ch;
 	int hash = svc_expkey_hash(new);
 
-	ch = sunrpc_cache_update(&svc_expkey_cache, &new->h,
-				 &old->h, hash);
+	ch = sunrpc_cache_update(cd, &new->h, &old->h, hash);
 	if (ch)
 		return container_of(ch, struct svc_expkey, h);
 	else
@@ -763,7 +762,8 @@ svc_export_update(struct svc_export *new, struct svc_export *old)
 
 
 static struct svc_expkey *
-exp_find_key(svc_client *clp, int fsid_type, u32 *fsidv, struct cache_req *reqp)
+exp_find_key(struct cache_detail *cd, svc_client *clp, int fsid_type,
+	     u32 *fsidv, struct cache_req *reqp)
 {
 	struct svc_expkey key, *ek;
 	int err;
@@ -775,10 +775,10 @@ exp_find_key(svc_client *clp, int fsid_type, u32 *fsidv, struct cache_req *reqp)
 	key.ek_fsidtype = fsid_type;
 	memcpy(key.ek_fsid, fsidv, key_len(fsid_type));
 
-	ek = svc_expkey_lookup(&key);
+	ek = svc_expkey_lookup(cd, &key);
 	if (ek == NULL)
 		return ERR_PTR(-ENOMEM);
-	err = cache_check(&svc_expkey_cache, &ek->h, reqp);
+	err = cache_check(cd, &ek->h, reqp);
 	if (err)
 		return ERR_PTR(err);
 	return ek;
@@ -883,7 +883,7 @@ static struct svc_export *exp_find(struct cache_detail *cd,
 				   u32 *fsidv, struct cache_req *reqp)
 {
 	struct svc_export *exp;
-	struct svc_expkey *ek = exp_find_key(clp, fsid_type, fsidv, reqp);
+	struct svc_expkey *ek = exp_find_key(&svc_expkey_cache, clp, fsid_type, fsidv, reqp);
 	if (IS_ERR(ek))
 		return ERR_CAST(ek);
 

