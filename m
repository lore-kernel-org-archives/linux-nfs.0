Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:26782 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758079Ab2C1PJf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Mar 2012 11:09:35 -0400
Subject: [PATCH 5/8] nfsd: pass svc_export_cache pointer as private data to
 "exports" seq file ops
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, devel@openvz.org
Date: Wed, 28 Mar 2012 19:09:29 +0400
Message-ID: <20120328150929.2646.59343.stgit@localhost6.localdomain6>
In-Reply-To: <20120328150152.2646.33607.stgit@localhost6.localdomain6>
References: <20120328150152.2646.33607.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Global svc_export_cache cache is going to be replaced with per-net instance. So
prepare the ground for it.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 fs/nfsd/export.c |   18 +++++++++++-------
 fs/nfsd/nfsctl.c |   11 ++++++++++-
 2 files changed, 21 insertions(+), 8 deletions(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index c20a405..1495320 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -1029,13 +1029,14 @@ exp_pseudoroot(struct svc_rqst *rqstp, struct svc_fh *fhp)
 /* Iterator */
 
 static void *e_start(struct seq_file *m, loff_t *pos)
-	__acquires(svc_export_cache.hash_lock)
+	__acquires(((struct cache_detail *)m->private)->hash_lock)
 {
 	loff_t n = *pos;
 	unsigned hash, export;
 	struct cache_head *ch;
-	
-	read_lock(&svc_export_cache.hash_lock);
+	struct cache_detail *cd = m->private;
+
+	read_lock(&cd->hash_lock);
 	if (!n--)
 		return SEQ_START_TOKEN;
 	hash = n >> 32;
@@ -1082,9 +1083,11 @@ static void *e_next(struct seq_file *m, void *p, loff_t *pos)
 }
 
 static void e_stop(struct seq_file *m, void *p)
-	__releases(svc_export_cache.hash_lock)
+	__releases(((struct cache_detail *)m->private)->hash_lock)
 {
-	read_unlock(&svc_export_cache.hash_lock);
+	struct cache_detail *cd = m->private;
+
+	read_unlock(&cd->hash_lock);
 }
 
 static struct flags {
@@ -1195,6 +1198,7 @@ static int e_show(struct seq_file *m, void *p)
 {
 	struct cache_head *cp = p;
 	struct svc_export *exp = container_of(cp, struct svc_export, h);
+	struct cache_detail *cd = m->private;
 
 	if (p == SEQ_START_TOKEN) {
 		seq_puts(m, "# Version 1.1\n");
@@ -1203,10 +1207,10 @@ static int e_show(struct seq_file *m, void *p)
 	}
 
 	cache_get(&exp->h);
-	if (cache_check(&svc_export_cache, &exp->h, NULL))
+	if (cache_check(cd, &exp->h, NULL))
 		return 0;
 	exp_put(exp);
-	return svc_export_show(m, &svc_export_cache, cp);
+	return svc_export_show(m, cd, cp);
 }
 
 const struct seq_operations nfs_exports_op = {
diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index dee6c1b..9bc6f8c 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -127,7 +127,16 @@ static const struct file_operations transaction_ops = {
 
 static int exports_open(struct inode *inode, struct file *file)
 {
-	return seq_open(file, &nfs_exports_op);
+	int err;
+	struct seq_file *seq;
+
+	err = seq_open(file, &nfs_exports_op);
+	if (err)
+		return err;
+
+	seq = file->private_data;
+	seq->private = &svc_export_cache;
+	return 0;
 }
 
 static const struct file_operations exports_operations = {

