From: NeilBrown <neilb@suse.de>
Subject: [PATCH 7/9] nfsd: factor out hash functions for export caches.
Date: Wed, 03 Feb 2010 17:31:31 +1100
Message-ID: <20100203063131.12945.38791.stgit@notabene.brown>
References: <20100203060657.12945.27293.stgit@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:49551 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756173Ab0BCGjo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Feb 2010 01:39:44 -0500
In-Reply-To: <20100203060657.12945.27293.stgit-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Both the _lookup and the _update functions for these two caches
independently calculate the hash of the key.
So factor out that code for improved reuse.

Signed-off-by: NeilBrown <neilb@suse.de>
---
 fs/nfsd/export.c |   40 +++++++++++++++++++++++-----------------
 1 files changed, 23 insertions(+), 17 deletions(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index c487810..cb8766c 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -258,10 +258,9 @@ static struct cache_detail svc_expkey_cache = {
 	.alloc		= expkey_alloc,
 };
 
-static struct svc_expkey *
-svc_expkey_lookup(struct svc_expkey *item)
+static int
+svc_expkey_hash(struct svc_expkey *item)
 {
-	struct cache_head *ch;
 	int hash = item->ek_fsidtype;
 	char * cp = (char*)item->ek_fsid;
 	int len = key_len(item->ek_fsidtype);
@@ -269,6 +268,14 @@ svc_expkey_lookup(struct svc_expkey *item)
 	hash ^= hash_mem(cp, len, EXPKEY_HASHBITS);
 	hash ^= hash_ptr(item->ek_client, EXPKEY_HASHBITS);
 	hash &= EXPKEY_HASHMASK;
+	return hash;
+}
+
+static struct svc_expkey *
+svc_expkey_lookup(struct svc_expkey *item)
+{
+	struct cache_head *ch;
+	int hash = svc_expkey_hash(item);
 
 	ch = sunrpc_cache_lookup(&svc_expkey_cache, &item->h,
 				 hash);
@@ -282,13 +289,7 @@ static struct svc_expkey *
 svc_expkey_update(struct svc_expkey *new, struct svc_expkey *old)
 {
 	struct cache_head *ch;
-	int hash = new->ek_fsidtype;
-	char * cp = (char*)new->ek_fsid;
-	int len = key_len(new->ek_fsidtype);
-
-	hash ^= hash_mem(cp, len, EXPKEY_HASHBITS);
-	hash ^= hash_ptr(new->ek_client, EXPKEY_HASHBITS);
-	hash &= EXPKEY_HASHMASK;
+	int hash = svc_expkey_hash(new);
 
 	ch = sunrpc_cache_update(&svc_expkey_cache, &new->h,
 				 &old->h, hash);
@@ -737,14 +738,22 @@ struct cache_detail svc_export_cache = {
 	.alloc		= svc_export_alloc,
 };
 
-static struct svc_export *
-svc_export_lookup(struct svc_export *exp)
+static int
+svc_export_hash(struct svc_export *exp)
 {
-	struct cache_head *ch;
 	int hash;
+
 	hash = hash_ptr(exp->ex_client, EXPORT_HASHBITS);
 	hash ^= hash_ptr(exp->ex_path.dentry, EXPORT_HASHBITS);
 	hash ^= hash_ptr(exp->ex_path.mnt, EXPORT_HASHBITS);
+	return hash;
+}
+
+static struct svc_export *
+svc_export_lookup(struct svc_export *exp)
+{
+	struct cache_head *ch;
+	int hash = svc_export_hash(exp);
 
 	ch = sunrpc_cache_lookup(&svc_export_cache, &exp->h,
 				 hash);
@@ -758,10 +767,7 @@ static struct svc_export *
 svc_export_update(struct svc_export *new, struct svc_export *old)
 {
 	struct cache_head *ch;
-	int hash;
-	hash = hash_ptr(old->ex_client, EXPORT_HASHBITS);
-	hash ^= hash_ptr(old->ex_path.dentry, EXPORT_HASHBITS);
-	hash ^= hash_ptr(old->ex_path.mnt, EXPORT_HASHBITS);
+	int hash = svc_export_hash(old);
 
 	ch = sunrpc_cache_update(&svc_export_cache, &new->h,
 				 &old->h,


