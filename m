Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:38542 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751012AbeBSFEx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 19 Feb 2018 00:04:53 -0500
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Date: Mon, 19 Feb 2018 16:02:29 +1100
Subject: [PATCH 17/23] NFS: change access cache to use 'struct cred'.
Cc: linux-nfs@vger.kernel.org
Message-ID: <151901654935.17421.9315017384865722111.stgit@noble>
In-Reply-To: <151901634940.17421.7637564368419392071.stgit@noble>
References: <151901634940.17421.7637564368419392071.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Rather than keying the access cache with 'struct rpc_cred',
use 'struct cred'.  Then use cred_fscmp() to compare
credentials rather than comparing the raw pointer.

A benefit of this approach is that in the common case we avoid the
rpc_lookup_cred_nonblock() call which can be slow when the cred cache is large.
This also keeps many fewer items pinned in the rpc cred cache, so the
cred cache is less likely to get large.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 fs/nfs/dir.c           |   44 +++++++++++++++++++-------------------------
 fs/nfs/nfs3proc.c      |    9 ++++++++-
 fs/nfs/nfs4proc.c      |   16 ++++++++++++----
 include/linux/nfs_fs.h |    4 ++--
 4 files changed, 41 insertions(+), 32 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 2f3f86726f5b..cf520079315c 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -2079,7 +2079,7 @@ MODULE_PARM_DESC(nfs_access_max_cachesize, "NFS access maximum total cache lengt
 
 static void nfs_access_free_entry(struct nfs_access_entry *entry)
 {
-	put_rpccred(entry->cred);
+	put_cred(entry->cred);
 	kfree_rcu(entry, rcu_head);
 	smp_mb__before_atomic();
 	atomic_long_dec(&nfs_access_nr_entries);
@@ -2205,17 +2205,18 @@ void nfs_access_zap_cache(struct inode *inode)
 }
 EXPORT_SYMBOL_GPL(nfs_access_zap_cache);
 
-static struct nfs_access_entry *nfs_access_search_rbtree(struct inode *inode, struct rpc_cred *cred)
+static struct nfs_access_entry *nfs_access_search_rbtree(struct inode *inode, const struct cred *cred)
 {
 	struct rb_node *n = NFS_I(inode)->access_cache.rb_node;
-	struct nfs_access_entry *entry;
 
 	while (n != NULL) {
-		entry = rb_entry(n, struct nfs_access_entry, rb_node);
+		struct nfs_access_entry *entry =
+			rb_entry(n, struct nfs_access_entry, rb_node);
+		int cmp = cred_fscmp(cred, entry->cred);
 
-		if (cred < entry->cred)
+		if (cmp < 0)
 			n = n->rb_left;
-		else if (cred > entry->cred)
+		else if (cmp > 0)
 			n = n->rb_right;
 		else
 			return entry;
@@ -2223,7 +2224,7 @@ static struct nfs_access_entry *nfs_access_search_rbtree(struct inode *inode, st
 	return NULL;
 }
 
-static int nfs_access_get_cached(struct inode *inode, struct rpc_cred *cred, struct nfs_access_entry *res, bool may_block)
+static int nfs_access_get_cached(struct inode *inode, const struct cred *cred, struct nfs_access_entry *res, bool may_block)
 {
 	struct nfs_inode *nfsi = NFS_I(inode);
 	struct nfs_access_entry *cache;
@@ -2266,7 +2267,7 @@ static int nfs_access_get_cached(struct inode *inode, struct rpc_cred *cred, str
 	return -ENOENT;
 }
 
-static int nfs_access_get_cached_rcu(struct inode *inode, struct rpc_cred *cred, struct nfs_access_entry *res)
+static int nfs_access_get_cached_rcu(struct inode *inode, const struct cred *cred, struct nfs_access_entry *res)
 {
 	/* Only check the most recently returned cache entry,
 	 * but do it without locking.
@@ -2303,15 +2304,17 @@ static void nfs_access_add_rbtree(struct inode *inode, struct nfs_access_entry *
 	struct rb_node **p = &root_node->rb_node;
 	struct rb_node *parent = NULL;
 	struct nfs_access_entry *entry;
+	int cmp;
 
 	spin_lock(&inode->i_lock);
 	while (*p != NULL) {
 		parent = *p;
 		entry = rb_entry(parent, struct nfs_access_entry, rb_node);
+		cmp = cred_fscmp(set->cred, entry->cred);
 
-		if (set->cred < entry->cred)
+		if (cmp < 0)
 			p = &parent->rb_left;
-		else if (set->cred > entry->cred)
+		else if (cmp > 0)
 			p = &parent->rb_right;
 		else
 			goto found;
@@ -2335,7 +2338,7 @@ void nfs_access_add_cache(struct inode *inode, struct nfs_access_entry *set)
 	if (cache == NULL)
 		return;
 	RB_CLEAR_NODE(&cache->rb_node);
-	cache->cred = get_rpccred(set->cred);
+	cache->cred = get_cred(set->cred);
 	cache->mask = set->mask;
 
 	/* The above field assignments must be visible
@@ -2399,7 +2402,7 @@ void nfs_access_set_mask(struct nfs_access_entry *entry, u32 access_result)
 }
 EXPORT_SYMBOL_GPL(nfs_access_set_mask);
 
-static int nfs_do_access(struct inode *inode, struct rpc_cred *cred, int mask)
+static int nfs_do_access(struct inode *inode, const struct cred *cred, int mask)
 {
 	struct nfs_access_entry cache;
 	bool may_block = (mask & MAY_NOT_BLOCK) == 0;
@@ -2463,7 +2466,7 @@ static int nfs_open_permission_mask(int openflags)
 	return mask;
 }
 
-int nfs_may_open(struct inode *inode, struct rpc_cred *cred, int openflags)
+int nfs_may_open(struct inode *inode, const struct cred *cred, int openflags)
 {
 	return nfs_do_access(inode, cred, nfs_open_permission_mask(openflags));
 }
@@ -2486,7 +2489,7 @@ static int nfs_execute_ok(struct inode *inode, int mask)
 
 int nfs_permission(struct inode *inode, int mask)
 {
-	struct rpc_cred *cred;
+	const struct cred *cred = current_cred();
 	int res = 0;
 
 	nfs_inc_stats(inode, NFSIOS_VFSACCESS);
@@ -2520,20 +2523,11 @@ int nfs_permission(struct inode *inode, int mask)
 
 	/* Always try fast lookups first */
 	rcu_read_lock();
-	cred = rpc_lookup_cred_nonblock();
-	if (!IS_ERR(cred))
-		res = nfs_do_access(inode, cred, mask|MAY_NOT_BLOCK);
-	else
-		res = PTR_ERR(cred);
+	res = nfs_do_access(inode, cred, mask|MAY_NOT_BLOCK);
 	rcu_read_unlock();
 	if (res == -ECHILD && !(mask & MAY_NOT_BLOCK)) {
 		/* Fast lookup failed, try the slow way */
-		cred = rpc_lookup_cred();
-		if (!IS_ERR(cred)) {
-			res = nfs_do_access(inode, cred, mask);
-			put_rpccred(cred);
-		} else
-			res = PTR_ERR(cred);
+		res = nfs_do_access(inode, cred, mask);
 	}
 out:
 	if (!res && (mask & MAY_EXEC))
diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index 49f848fd1f04..682f22946975 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -191,15 +191,20 @@ static int nfs3_proc_access(struct inode *inode, struct nfs_access_entry *entry)
 		.access		= entry->mask,
 	};
 	struct nfs3_accessres	res;
+	struct auth_cred acred = {
+		.cred		= entry->cred,
+	};
 	struct rpc_message msg = {
 		.rpc_proc	= &nfs3_procedures[NFS3PROC_ACCESS],
 		.rpc_argp	= &arg,
 		.rpc_resp	= &res,
-		.rpc_cred	= entry->cred,
+		.rpc_cred	= rpc_lookup_generic_cred(&acred, 0, GFP_NOFS),
 	};
 	int status = -ENOMEM;
 
 	dprintk("NFS call  access\n");
+	if (!msg.rpc_cred)
+		goto out;
 	res.fattr = nfs_alloc_fattr();
 	if (res.fattr == NULL)
 		goto out;
@@ -210,6 +215,8 @@ static int nfs3_proc_access(struct inode *inode, struct nfs_access_entry *entry)
 		nfs_access_set_mask(entry, res.access);
 	nfs_free_fattr(res.fattr);
 out:
+	if (msg.rpc_cred)
+		put_rpccred(msg.rpc_cred);
 	dprintk("NFS reply access: %d\n", status);
 	return status;
 }
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 4028ae78b536..ae8fe42c1206 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1709,7 +1709,7 @@ static struct nfs4_state *nfs4_try_open_cached(struct nfs4_opendata *opendata)
 		rcu_read_unlock();
 		nfs_release_seqid(opendata->o_arg.seqid);
 		if (!opendata->is_recover) {
-			ret = nfs_may_open(state->inode, state->owner->so_cred, open_mode);
+			ret = nfs_may_open(state->inode, state->owner->so_cred->cr_cred, open_mode);
 			if (ret != 0)
 				goto out;
 		}
@@ -2420,7 +2420,7 @@ static int nfs4_opendata_access(struct rpc_cred *cred,
 	} else if ((fmode & FMODE_READ) && !opendata->file_created)
 		mask = NFS4_ACCESS_READ;
 
-	cache.cred = cred;
+	cache.cred = cred->cr_cred;
 	nfs_access_set_mask(&cache, opendata->o_res.access_result);
 	nfs_access_add_cache(state->inode, &cache);
 
@@ -4054,17 +4054,24 @@ static int _nfs4_proc_access(struct inode *inode, struct nfs_access_entry *entry
 	struct nfs4_accessres res = {
 		.server = server,
 	};
+	struct auth_cred acred = {
+		.cred = entry->cred,
+	};
 	struct rpc_message msg = {
 		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_ACCESS],
 		.rpc_argp = &args,
 		.rpc_resp = &res,
-		.rpc_cred = entry->cred,
+		.rpc_cred = rpc_lookup_generic_cred(&acred, 0, GFP_NOFS),
 	};
 	int status = 0;
 
+	if (!msg.rpc_cred)
+		return -ENOMEM;
 	res.fattr = nfs_alloc_fattr();
-	if (res.fattr == NULL)
+	if (res.fattr == NULL) {
+		put_rpccred(msg.rpc_cred);
 		return -ENOMEM;
+	}
 
 	status = nfs4_call_sync(server->client, server, &msg, &args.seq_args, &res.seq_res, 0);
 	if (!status) {
@@ -4072,6 +4079,7 @@ static int _nfs4_proc_access(struct inode *inode, struct nfs_access_entry *entry
 		nfs_refresh_inode(inode, res.fattr);
 	}
 	nfs_free_fattr(res.fattr);
+	put_rpccred(msg.rpc_cred);
 	return status;
 }
 
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index b5a3bea20ca3..0a7e66efe212 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -51,7 +51,7 @@
 struct nfs_access_entry {
 	struct rb_node		rb_node;
 	struct list_head	lru;
-	struct rpc_cred *	cred;
+	const struct cred *	cred;
 	__u32			mask;
 	struct rcu_head		rcu_head;
 };
@@ -467,7 +467,7 @@ extern const struct dentry_operations nfs_dentry_operations;
 extern void nfs_force_lookup_revalidate(struct inode *dir);
 extern int nfs_instantiate(struct dentry *dentry, struct nfs_fh *fh,
 			struct nfs_fattr *fattr, struct nfs4_label *label);
-extern int nfs_may_open(struct inode *inode, struct rpc_cred *cred, int openflags);
+extern int nfs_may_open(struct inode *inode, const struct cred *cred, int openflags);
 extern void nfs_access_zap_cache(struct inode *inode);
 
 /*


