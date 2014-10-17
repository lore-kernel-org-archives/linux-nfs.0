Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f48.google.com ([209.85.216.48]:34531 "EHLO
	mail-qa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751035AbaJQKVX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Oct 2014 06:21:23 -0400
Received: by mail-qa0-f48.google.com with SMTP id dc16so277944qab.7
        for <linux-nfs@vger.kernel.org>; Fri, 17 Oct 2014 03:21:22 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd: convert nfs4_file searches to use RCU
Date: Fri, 17 Oct 2014 06:21:15 -0400
Message-Id: <1413541275-3884-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The global state_lock protects the file_hashtbl, and that has the
potential to be a scalability bottleneck.

Address this by making the file_hashtbl use RCU. Add a rcu_head to the
nfs4_file and use that when freeing ones that have been hashed.

Convert find_file to use a lockless lookup. Convert find_or_add_file to
attempt a lockless lookup first, and then fall back to doing the
"normal" locked search and insert if that fails to find anything.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 36 +++++++++++++++++++++++++++---------
 fs/nfsd/state.h     |  1 +
 2 files changed, 28 insertions(+), 9 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index e9c3afe4b5d3..9bd3bcfee3c2 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -280,15 +280,22 @@ static void nfsd4_free_file(struct nfs4_file *f)
 	kmem_cache_free(file_slab, f);
 }
 
+static void nfsd4_free_file_rcu(struct rcu_head *rcu)
+{
+	struct nfs4_file *fp = container_of(rcu, struct nfs4_file, fi_rcu);
+
+	nfsd4_free_file(fp);
+}
+
 static inline void
 put_nfs4_file(struct nfs4_file *fi)
 {
 	might_lock(&state_lock);
 
 	if (atomic_dec_and_lock(&fi->fi_ref, &state_lock)) {
-		hlist_del(&fi->fi_hash);
+		hlist_del_rcu(&fi->fi_hash);
 		spin_unlock(&state_lock);
-		nfsd4_free_file(fi);
+		call_rcu(&fi->fi_rcu, nfsd4_free_file_rcu);
 	}
 }
 
@@ -3073,7 +3080,7 @@ static void nfsd4_init_file(struct nfs4_file *fp, struct knfsd_fh *fh)
 	fp->fi_share_deny = 0;
 	memset(fp->fi_fds, 0, sizeof(fp->fi_fds));
 	memset(fp->fi_access, 0, sizeof(fp->fi_access));
-	hlist_add_head(&fp->fi_hash, &file_hashtbl[hashval]);
+	hlist_add_head_rcu(&fp->fi_hash, &file_hashtbl[hashval]);
 }
 
 void
@@ -3313,12 +3320,19 @@ find_file_locked(struct knfsd_fh *fh)
 static struct nfs4_file *
 find_file(struct knfsd_fh *fh)
 {
-	struct nfs4_file *fp;
+	struct nfs4_file *fp, *ret = NULL;
+	unsigned int hashval = file_hashval(fh);
 
-	spin_lock(&state_lock);
-	fp = find_file_locked(fh);
-	spin_unlock(&state_lock);
-	return fp;
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(fp, &file_hashtbl[hashval], fi_hash) {
+		if (nfsd_fh_match(&fp->fi_fhandle, fh)) {
+			if (atomic_inc_not_zero(&fp->fi_ref))
+				ret = fp;
+			break;
+		}
+	}
+	rcu_read_unlock();
+	return ret;
 }
 
 static struct nfs4_file *
@@ -3326,9 +3340,13 @@ find_or_add_file(struct nfs4_file *new, struct knfsd_fh *fh)
 {
 	struct nfs4_file *fp;
 
+	fp = find_file(fh);
+	if (fp)
+		return fp;
+
 	spin_lock(&state_lock);
 	fp = find_file_locked(fh);
-	if (fp == NULL) {
+	if (likely(fp == NULL)) {
 		nfsd4_init_file(new, fh);
 		fp = new;
 	}
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 8e85e07efce6..530470a35ecd 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -490,6 +490,7 @@ struct nfs4_file {
 	atomic_t		fi_access[2];
 	u32			fi_share_deny;
 	struct file		*fi_deleg_file;
+	struct rcu_head		fi_rcu;
 	atomic_t		fi_delegees;
 	struct knfsd_fh		fi_fhandle;
 	bool			fi_had_conflict;
-- 
1.9.3

