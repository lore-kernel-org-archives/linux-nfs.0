Return-Path: <SRS0=4jnv=OM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D6273C64EB4
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 00:33:54 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 923D620834
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 00:33:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 923D620834
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726106AbeLCAdx (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 2 Dec 2018 19:33:53 -0500
Received: from mx2.suse.de ([195.135.220.15]:41364 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1725785AbeLCAdx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 2 Dec 2018 19:33:53 -0500
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay1.suse.de (unknown [195.135.220.254])
        by mx1.suse.de (Postfix) with ESMTP id B4531AC9C;
        Mon,  3 Dec 2018 00:33:45 +0000 (UTC)
From:   NeilBrown <neilb@suse.com>
To:     "J. Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        Jeff Layton <jlayton@kernel.org>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Date:   Mon, 03 Dec 2018 11:30:30 +1100
Subject: [PATCH 17/23] NFS: change access cache to use 'struct cred'.
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-kernel@vger.kernel.org
Message-ID: <154379703081.28598.13989277908387689067.stgit@noble>
In-Reply-To: <154379689752.28598.6750646657534626618.stgit@noble>
References: <154379689752.28598.6750646657534626618.stgit@noble>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

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
index 71b2e390becf..4dc61b6f74e8 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -2139,7 +2139,7 @@ MODULE_PARM_DESC(nfs_access_max_cachesize, "NFS access maximum total cache lengt
 
 static void nfs_access_free_entry(struct nfs_access_entry *entry)
 {
-	put_rpccred(entry->cred);
+	put_cred(entry->cred);
 	kfree_rcu(entry, rcu_head);
 	smp_mb__before_atomic();
 	atomic_long_dec(&nfs_access_nr_entries);
@@ -2265,17 +2265,18 @@ void nfs_access_zap_cache(struct inode *inode)
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
@@ -2283,7 +2284,7 @@ static struct nfs_access_entry *nfs_access_search_rbtree(struct inode *inode, st
 	return NULL;
 }
 
-static int nfs_access_get_cached(struct inode *inode, struct rpc_cred *cred, struct nfs_access_entry *res, bool may_block)
+static int nfs_access_get_cached(struct inode *inode, const struct cred *cred, struct nfs_access_entry *res, bool may_block)
 {
 	struct nfs_inode *nfsi = NFS_I(inode);
 	struct nfs_access_entry *cache;
@@ -2326,7 +2327,7 @@ static int nfs_access_get_cached(struct inode *inode, struct rpc_cred *cred, str
 	return -ENOENT;
 }
 
-static int nfs_access_get_cached_rcu(struct inode *inode, struct rpc_cred *cred, struct nfs_access_entry *res)
+static int nfs_access_get_cached_rcu(struct inode *inode, const struct cred *cred, struct nfs_access_entry *res)
 {
 	/* Only check the most recently returned cache entry,
 	 * but do it without locking.
@@ -2363,15 +2364,17 @@ static void nfs_access_add_rbtree(struct inode *inode, struct nfs_access_entry *
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
@@ -2395,7 +2398,7 @@ void nfs_access_add_cache(struct inode *inode, struct nfs_access_entry *set)
 	if (cache == NULL)
 		return;
 	RB_CLEAR_NODE(&cache->rb_node);
-	cache->cred = get_rpccred(set->cred);
+	cache->cred = get_cred(set->cred);
 	cache->mask = set->mask;
 
 	/* The above field assignments must be visible
@@ -2459,7 +2462,7 @@ void nfs_access_set_mask(struct nfs_access_entry *entry, u32 access_result)
 }
 EXPORT_SYMBOL_GPL(nfs_access_set_mask);
 
-static int nfs_do_access(struct inode *inode, struct rpc_cred *cred, int mask)
+static int nfs_do_access(struct inode *inode, const struct cred *cred, int mask)
 {
 	struct nfs_access_entry cache;
 	bool may_block = (mask & MAY_NOT_BLOCK) == 0;
@@ -2523,7 +2526,7 @@ static int nfs_open_permission_mask(int openflags)
 	return mask;
 }
 
-int nfs_may_open(struct inode *inode, struct rpc_cred *cred, int openflags)
+int nfs_may_open(struct inode *inode, const struct cred *cred, int openflags)
 {
 	return nfs_do_access(inode, cred, nfs_open_permission_mask(openflags));
 }
@@ -2548,7 +2551,7 @@ static int nfs_execute_ok(struct inode *inode, int mask)
 
 int nfs_permission(struct inode *inode, int mask)
 {
-	struct rpc_cred *cred;
+	const struct cred *cred = current_cred();
 	int res = 0;
 
 	nfs_inc_stats(inode, NFSIOS_VFSACCESS);
@@ -2582,20 +2585,11 @@ int nfs_permission(struct inode *inode, int mask)
 
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
index 71bc16225b98..f7174f3a9575 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -195,15 +195,20 @@ static int nfs3_proc_access(struct inode *inode, struct nfs_access_entry *entry)
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
@@ -214,6 +219,8 @@ static int nfs3_proc_access(struct inode *inode, struct nfs_access_entry *entry)
 		nfs_access_set_mask(entry, res.access);
 	nfs_free_fattr(res.fattr);
 out:
+	if (msg.rpc_cred)
+		put_rpccred(msg.rpc_cred);
 	dprintk("NFS reply access: %d\n", status);
 	return status;
 }
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index cafa155a053e..bf97331c02d3 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1772,7 +1772,7 @@ static struct nfs4_state *nfs4_try_open_cached(struct nfs4_opendata *opendata)
 		rcu_read_unlock();
 		nfs_release_seqid(opendata->o_arg.seqid);
 		if (!opendata->is_recover) {
-			ret = nfs_may_open(state->inode, state->owner->so_cred, open_mode);
+			ret = nfs_may_open(state->inode, state->owner->so_cred->cr_cred, open_mode);
 			if (ret != 0)
 				goto out;
 		}
@@ -2511,7 +2511,7 @@ static int nfs4_opendata_access(struct rpc_cred *cred,
 	} else if ((fmode & FMODE_READ) && !opendata->file_created)
 		mask = NFS4_ACCESS_READ;
 
-	cache.cred = cred;
+	cache.cred = cred->cr_cred;
 	nfs_access_set_mask(&cache, opendata->o_res.access_result);
 	nfs_access_add_cache(state->inode, &cache);
 
@@ -4188,18 +4188,25 @@ static int _nfs4_proc_access(struct inode *inode, struct nfs_access_entry *entry
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
 	if (!nfs4_have_delegation(inode, FMODE_READ)) {
 		res.fattr = nfs_alloc_fattr();
-		if (res.fattr == NULL)
+		if (res.fattr == NULL) {
+			put_rpccred(msg.rpc_cred);
 			return -ENOMEM;
+		}
 		args.bitmask = server->cache_consistency_bitmask;
 	}
 
@@ -4210,6 +4217,7 @@ static int _nfs4_proc_access(struct inode *inode, struct nfs_access_entry *entry
 			nfs_refresh_inode(inode, res.fattr);
 	}
 	nfs_free_fattr(res.fattr);
+	put_rpccred(msg.rpc_cred);
 	return status;
 }
 
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index ecf22c0034d5..7d2064bd421f 100644
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
@@ -491,7 +491,7 @@ extern const struct dentry_operations nfs_dentry_operations;
 extern void nfs_force_lookup_revalidate(struct inode *dir);
 extern int nfs_instantiate(struct dentry *dentry, struct nfs_fh *fh,
 			struct nfs_fattr *fattr, struct nfs4_label *label);
-extern int nfs_may_open(struct inode *inode, struct rpc_cred *cred, int openflags);
+extern int nfs_may_open(struct inode *inode, const struct cred *cred, int openflags);
 extern void nfs_access_zap_cache(struct inode *inode);
 
 /*


