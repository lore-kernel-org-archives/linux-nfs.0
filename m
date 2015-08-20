Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f181.google.com ([209.85.160.181]:35747 "EHLO
	mail-yk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751761AbbHTLRb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Aug 2015 07:17:31 -0400
Received: by ykbi184 with SMTP id i184so33652279ykb.2
        for <linux-nfs@vger.kernel.org>; Thu, 20 Aug 2015 04:17:31 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@lst.de, kinglongmee@gmail.com
Subject: [PATCH v3 04/20] nfsd: add a LRU list for nfsd_files
Date: Thu, 20 Aug 2015 07:17:04 -0400
Message-Id: <1440069440-27454-5-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1440069440-27454-1-git-send-email-jeff.layton@primarydata.com>
References: <1440069440-27454-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfsd/filecache.c | 41 +++++++++++++++++++++++++++++------------
 fs/nfsd/filecache.h |  2 +-
 2 files changed, 30 insertions(+), 13 deletions(-)

diff --git a/fs/nfsd/filecache.c b/fs/nfsd/filecache.c
index 5bb56fa9002f..63b24419c674 100644
--- a/fs/nfsd/filecache.c
+++ b/fs/nfsd/filecache.c
@@ -9,6 +9,7 @@
 #include <linux/hash.h>
 #include <linux/file.h>
 #include <linux/sched.h>
+#include <linux/list_lru.h>
 
 #include "vfs.h"
 #include "nfsd.h"
@@ -30,6 +31,7 @@ struct nfsd_fcache_bucket {
 };
 
 static struct nfsd_fcache_bucket	*nfsd_file_hashtbl;
+static struct list_lru			nfsd_file_lru;
 
 static struct nfsd_file *
 nfsd_file_alloc(struct inode *inode, unsigned int may, unsigned int hashval)
@@ -40,7 +42,7 @@ nfsd_file_alloc(struct inode *inode, unsigned int may, unsigned int hashval)
 	nf = kzalloc(sizeof(*nf), GFP_KERNEL);
 	if (nf) {
 		INIT_HLIST_NODE(&nf->nf_node);
-		INIT_LIST_HEAD(&nf->nf_dispose);
+		INIT_LIST_HEAD(&nf->nf_lru);
 		nf->nf_inode = inode;
 		nf->nf_hashval = hashval;
 		atomic_set(&nf->nf_ref, 1);
@@ -65,6 +67,7 @@ nfsd_file_unhash(struct nfsd_file *nf)
 	if (test_bit(NFSD_FILE_HASHED, &nf->nf_flags)) {
 		clear_bit(NFSD_FILE_HASHED, &nf->nf_flags);
 		hlist_del_rcu(&nf->nf_node);
+		list_lru_del(&nfsd_file_lru, &nf->nf_lru);
 		return true;
 	}
 	return false;
@@ -80,12 +83,14 @@ nfsd_file_unhash_and_release_locked(struct nfsd_file *nf, struct list_head *disp
 	if (!atomic_dec_and_test(&nf->nf_ref))
 		return;
 
-	list_add(&nf->nf_dispose, dispose);
+	list_add(&nf->nf_lru, dispose);
 }
 
 void
 nfsd_file_put(struct nfsd_file *nf)
 {
+	list_lru_rotate(&nfsd_file_lru, &nf->nf_lru);
+
 	if (!atomic_dec_and_test(&nf->nf_ref))
 		return;
 
@@ -107,8 +112,8 @@ nfsd_file_dispose_list(struct list_head *dispose)
 	struct nfsd_file *nf;
 
 	while(!list_empty(dispose)) {
-		nf = list_first_entry(dispose, struct nfsd_file, nf_dispose);
-		list_del(&nf->nf_dispose);
+		nf = list_first_entry(dispose, struct nfsd_file, nf_lru);
+		list_del(&nf->nf_lru);
 		nfsd_file_put_final(nf);
 	}
 }
@@ -116,25 +121,35 @@ nfsd_file_dispose_list(struct list_head *dispose)
 int
 nfsd_file_cache_init(void)
 {
-	unsigned int i;
+	int		ret = -ENOMEM;
+	unsigned int	i;
 
 	if (nfsd_file_hashtbl)
 		return 0;
 
 	nfsd_file_hashtbl = kcalloc(NFSD_FILE_HASH_SIZE,
 				sizeof(*nfsd_file_hashtbl), GFP_KERNEL);
-	if (!nfsd_file_hashtbl)
-		goto out_nomem;
+	if (!nfsd_file_hashtbl) {
+		pr_err("nfsd: unable to allocate nfsd_file_hashtbl\n");
+		goto out_err;
+	}
+
+	ret = list_lru_init(&nfsd_file_lru);
+	if (ret) {
+		pr_err("nfsd: failed to init nfsd_file_lru: %d\n", ret);
+		goto out_err;
+	}
 
 	for (i = 0; i < NFSD_FILE_HASH_SIZE; i++) {
 		INIT_HLIST_HEAD(&nfsd_file_hashtbl[i].nfb_head);
 		spin_lock_init(&nfsd_file_hashtbl[i].nfb_lock);
 	}
-
-	return 0;
-out_nomem:
-	printk(KERN_ERR "nfsd: failed to init nfsd file cache\n");
-	return -ENOMEM;
+out:
+	return ret;
+out_err:
+	kfree(nfsd_file_hashtbl);
+	nfsd_file_hashtbl = NULL;
+	goto out;
 }
 
 void
@@ -154,6 +169,7 @@ nfsd_file_cache_shutdown(void)
 		spin_unlock(&nfsd_file_hashtbl[i].nfb_lock);
 		nfsd_file_dispose_list(&dispose);
 	}
+	list_lru_destroy(&nfsd_file_lru);
 	kfree(nfsd_file_hashtbl);
 	nfsd_file_hashtbl = NULL;
 }
@@ -219,6 +235,7 @@ retry:
 		atomic_inc(&new->nf_ref);
 		__set_bit(NFSD_FILE_HASHED, &new->nf_flags);
 		__set_bit(NFSD_FILE_PENDING, &new->nf_flags);
+		list_lru_add(&nfsd_file_lru, &new->nf_lru);
 		hlist_add_head_rcu(&new->nf_node,
 				&nfsd_file_hashtbl[hashval].nfb_head);
 		spin_unlock(&nfsd_file_hashtbl[hashval].nfb_lock);
diff --git a/fs/nfsd/filecache.h b/fs/nfsd/filecache.h
index b0f500353ed4..e7da463446dd 100644
--- a/fs/nfsd/filecache.h
+++ b/fs/nfsd/filecache.h
@@ -8,7 +8,7 @@
  */
 struct nfsd_file {
 	struct hlist_node	nf_node;
-	struct list_head	nf_dispose;
+	struct list_head	nf_lru;
 	struct rcu_head		nf_rcu;
 	struct file		*nf_file;
 #define NFSD_FILE_HASHED	(0)
-- 
2.4.3

