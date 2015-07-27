Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:33929 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754071AbbG0DJU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 26 Jul 2015 23:09:20 -0400
Message-ID: <55B5A0D6.8040908@gmail.com>
Date: Mon, 27 Jul 2015 11:09:10 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Al Viro <viro@zeniv.linux.org.uk>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org, NeilBrown <neilb@suse.de>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        kinglongmee@gmail.com
Subject: [PATCH 5/9 v8] sunrpc: Store cache_detail in seq_file's private directly
References: <55B5A012.1030006@gmail.com>
In-Reply-To: <55B5A012.1030006@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Cleanup.

Just store cache_detail in seq_file's private,
an allocated handle is redundant.

v8, same as v6.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 net/sunrpc/cache.c | 28 +++++++++++++---------------
 1 file changed, 13 insertions(+), 15 deletions(-)

diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 2928aff..edec603 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -1270,18 +1270,13 @@ EXPORT_SYMBOL_GPL(qword_get);
  * get a header, then pass each real item in the cache
  */
 
-struct handle {
-	struct cache_detail *cd;
-};
-
 static void *c_start(struct seq_file *m, loff_t *pos)
 	__acquires(cd->hash_lock)
 {
 	loff_t n = *pos;
 	unsigned int hash, entry;
 	struct cache_head *ch;
-	struct cache_detail *cd = ((struct handle*)m->private)->cd;
-
+	struct cache_detail *cd = m->private;
 
 	read_lock(&cd->hash_lock);
 	if (!n--)
@@ -1308,7 +1303,7 @@ static void *c_next(struct seq_file *m, void *p, loff_t *pos)
 {
 	struct cache_head *ch = p;
 	int hash = (*pos >> 32);
-	struct cache_detail *cd = ((struct handle*)m->private)->cd;
+	struct cache_detail *cd = m->private;
 
 	if (p == SEQ_START_TOKEN)
 		hash = 0;
@@ -1334,14 +1329,14 @@ static void *c_next(struct seq_file *m, void *p, loff_t *pos)
 static void c_stop(struct seq_file *m, void *p)
 	__releases(cd->hash_lock)
 {
-	struct cache_detail *cd = ((struct handle*)m->private)->cd;
+	struct cache_detail *cd = m->private;
 	read_unlock(&cd->hash_lock);
 }
 
 static int c_show(struct seq_file *m, void *p)
 {
 	struct cache_head *cp = p;
-	struct cache_detail *cd = ((struct handle*)m->private)->cd;
+	struct cache_detail *cd = m->private;
 
 	if (p == SEQ_START_TOKEN)
 		return cd->cache_show(m, cd, NULL);
@@ -1373,24 +1368,27 @@ static const struct seq_operations cache_content_op = {
 static int content_open(struct inode *inode, struct file *file,
 			struct cache_detail *cd)
 {
-	struct handle *han;
+	struct seq_file *seq;
+	int err;
 
 	if (!cd || !try_module_get(cd->owner))
 		return -EACCES;
-	han = __seq_open_private(file, &cache_content_op, sizeof(*han));
-	if (han == NULL) {
+
+	err = seq_open(file, &cache_content_op);
+	if (err) {
 		module_put(cd->owner);
-		return -ENOMEM;
+		return err;
 	}
 
-	han->cd = cd;
+	seq = file->private_data;
+	seq->private = cd;
 	return 0;
 }
 
 static int content_release(struct inode *inode, struct file *file,
 		struct cache_detail *cd)
 {
-	int ret = seq_release_private(inode, file);
+	int ret = seq_release(inode, file);
 	module_put(cd->owner);
 	return ret;
 }
-- 
2.4.3

