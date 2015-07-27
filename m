Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:34533 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754730AbbG0DJv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 26 Jul 2015 23:09:51 -0400
Message-ID: <55B5A0F6.1040701@gmail.com>
Date: Mon, 27 Jul 2015 11:09:42 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Al Viro <viro@zeniv.linux.org.uk>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org, NeilBrown <neilb@suse.de>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        kinglongmee@gmail.com
Subject: [PATCH 6/9 v8] sunrpc/nfsd: Remove redundant code by exports seq_operations
 functions
References: <55B5A012.1030006@gmail.com>
In-Reply-To: <55B5A012.1030006@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Nfsd has implement a site of seq_operations functions as sunrpc's cache.
Just exports sunrpc's codes, and remove nfsd's redundant codes.

v8, same as v6

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/export.c             | 73 ++------------------------------------------
 include/linux/sunrpc/cache.h |  5 +++
 net/sunrpc/cache.c           | 15 +++++----
 3 files changed, 17 insertions(+), 76 deletions(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index f79521a..b4d84b5 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -1075,73 +1075,6 @@ exp_pseudoroot(struct svc_rqst *rqstp, struct svc_fh *fhp)
 	return rv;
 }
 
-/* Iterator */
-
-static void *e_start(struct seq_file *m, loff_t *pos)
-	__acquires(((struct cache_detail *)m->private)->hash_lock)
-{
-	loff_t n = *pos;
-	unsigned hash, export;
-	struct cache_head *ch;
-	struct cache_detail *cd = m->private;
-	struct cache_head **export_table = cd->hash_table;
-
-	read_lock(&cd->hash_lock);
-	if (!n--)
-		return SEQ_START_TOKEN;
-	hash = n >> 32;
-	export = n & ((1LL<<32) - 1);
-
-	
-	for (ch=export_table[hash]; ch; ch=ch->next)
-		if (!export--)
-			return ch;
-	n &= ~((1LL<<32) - 1);
-	do {
-		hash++;
-		n += 1LL<<32;
-	} while(hash < EXPORT_HASHMAX && export_table[hash]==NULL);
-	if (hash >= EXPORT_HASHMAX)
-		return NULL;
-	*pos = n+1;
-	return export_table[hash];
-}
-
-static void *e_next(struct seq_file *m, void *p, loff_t *pos)
-{
-	struct cache_head *ch = p;
-	int hash = (*pos >> 32);
-	struct cache_detail *cd = m->private;
-	struct cache_head **export_table = cd->hash_table;
-
-	if (p == SEQ_START_TOKEN)
-		hash = 0;
-	else if (ch->next == NULL) {
-		hash++;
-		*pos += 1LL<<32;
-	} else {
-		++*pos;
-		return ch->next;
-	}
-	*pos &= ~((1LL<<32) - 1);
-	while (hash < EXPORT_HASHMAX && export_table[hash] == NULL) {
-		hash++;
-		*pos += 1LL<<32;
-	}
-	if (hash >= EXPORT_HASHMAX)
-		return NULL;
-	++*pos;
-	return export_table[hash];
-}
-
-static void e_stop(struct seq_file *m, void *p)
-	__releases(((struct cache_detail *)m->private)->hash_lock)
-{
-	struct cache_detail *cd = m->private;
-
-	read_unlock(&cd->hash_lock);
-}
-
 static struct flags {
 	int flag;
 	char *name[2];
@@ -1270,9 +1203,9 @@ static int e_show(struct seq_file *m, void *p)
 }
 
 const struct seq_operations nfs_exports_op = {
-	.start	= e_start,
-	.next	= e_next,
-	.stop	= e_stop,
+	.start	= cache_seq_start,
+	.next	= cache_seq_next,
+	.stop	= cache_seq_stop,
 	.show	= e_show,
 };
 
diff --git a/include/linux/sunrpc/cache.h b/include/linux/sunrpc/cache.h
index 437ddb6..04ee5a2 100644
--- a/include/linux/sunrpc/cache.h
+++ b/include/linux/sunrpc/cache.h
@@ -224,6 +224,11 @@ extern int sunrpc_cache_register_pipefs(struct dentry *parent, const char *,
 					umode_t, struct cache_detail *);
 extern void sunrpc_cache_unregister_pipefs(struct cache_detail *);
 
+/* Must store cache_detail in seq_file->private if using next three functions */
+extern void *cache_seq_start(struct seq_file *file, loff_t *pos);
+extern void *cache_seq_next(struct seq_file *file, void *p, loff_t *pos);
+extern void cache_seq_stop(struct seq_file *file, void *p);
+
 extern void qword_add(char **bpp, int *lp, char *str);
 extern void qword_addhex(char **bpp, int *lp, char *buf, int blen);
 extern int qword_get(char **bpp, char *dest, int bufsize);
diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index edec603..673c2fa 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -1270,7 +1270,7 @@ EXPORT_SYMBOL_GPL(qword_get);
  * get a header, then pass each real item in the cache
  */
 
-static void *c_start(struct seq_file *m, loff_t *pos)
+void *cache_seq_start(struct seq_file *m, loff_t *pos)
 	__acquires(cd->hash_lock)
 {
 	loff_t n = *pos;
@@ -1298,8 +1298,9 @@ static void *c_start(struct seq_file *m, loff_t *pos)
 	*pos = n+1;
 	return cd->hash_table[hash];
 }
+EXPORT_SYMBOL_GPL(cache_seq_start);
 
-static void *c_next(struct seq_file *m, void *p, loff_t *pos)
+void *cache_seq_next(struct seq_file *m, void *p, loff_t *pos)
 {
 	struct cache_head *ch = p;
 	int hash = (*pos >> 32);
@@ -1325,13 +1326,15 @@ static void *c_next(struct seq_file *m, void *p, loff_t *pos)
 	++*pos;
 	return cd->hash_table[hash];
 }
+EXPORT_SYMBOL_GPL(cache_seq_next);
 
-static void c_stop(struct seq_file *m, void *p)
+void cache_seq_stop(struct seq_file *m, void *p)
 	__releases(cd->hash_lock)
 {
 	struct cache_detail *cd = m->private;
 	read_unlock(&cd->hash_lock);
 }
+EXPORT_SYMBOL_GPL(cache_seq_stop);
 
 static int c_show(struct seq_file *m, void *p)
 {
@@ -1359,9 +1362,9 @@ static int c_show(struct seq_file *m, void *p)
 }
 
 static const struct seq_operations cache_content_op = {
-	.start	= c_start,
-	.next	= c_next,
-	.stop	= c_stop,
+	.start	= cache_seq_start,
+	.next	= cache_seq_next,
+	.stop	= cache_seq_stop,
 	.show	= c_show,
 };
 
-- 
2.4.3

