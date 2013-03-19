Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:19812 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754760Ab3CSNHx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 Mar 2013 09:07:53 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 08/11] NFSv4: Clean up nfs4_opendata_alloc in preparation for NFSv4.1 open modes
Date: Tue, 19 Mar 2013 09:07:40 -0400
Message-Id: <1363698463-3681-8-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1363698463-3681-7-git-send-email-Trond.Myklebust@netapp.com>
References: <1363698463-3681-1-git-send-email-Trond.Myklebust@netapp.com>
 <1363698463-3681-2-git-send-email-Trond.Myklebust@netapp.com>
 <1363698463-3681-3-git-send-email-Trond.Myklebust@netapp.com>
 <1363698463-3681-4-git-send-email-Trond.Myklebust@netapp.com>
 <1363698463-3681-5-git-send-email-Trond.Myklebust@netapp.com>
 <1363698463-3681-6-git-send-email-Trond.Myklebust@netapp.com>
 <1363698463-3681-7-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c | 38 +++++++++++++++++++++++++++-----------
 1 file changed, 27 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index c5cc4a8..712eb70 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -782,6 +782,7 @@ static void nfs4_init_opendata_res(struct nfs4_opendata *p)
 static struct nfs4_opendata *nfs4_opendata_alloc(struct dentry *dentry,
 		struct nfs4_state_owner *sp, fmode_t fmode, int flags,
 		const struct iattr *attrs,
+		enum open_claim_type4 claim,
 		gfp_t gfp_mask)
 {
 	struct dentry *parent = dget_parent(dentry);
@@ -800,7 +801,6 @@ static struct nfs4_opendata *nfs4_opendata_alloc(struct dentry *dentry,
 	p->dir = parent;
 	p->owner = sp;
 	atomic_inc(&sp->so_count);
-	p->o_arg.fh = NFS_FH(dir);
 	p->o_arg.open_flags = flags;
 	p->o_arg.fmode = fmode & (FMODE_READ|FMODE_WRITE);
 	/* don't put an ACCESS op in OPEN compound if O_EXCL, because ACCESS
@@ -818,7 +818,19 @@ static struct nfs4_opendata *nfs4_opendata_alloc(struct dentry *dentry,
 	p->o_arg.server = server;
 	p->o_arg.bitmask = server->attr_bitmask;
 	p->o_arg.open_bitmap = &nfs4_fattr_bitmap[0];
-	p->o_arg.claim = NFS4_OPEN_CLAIM_NULL;
+	p->o_arg.claim = claim;
+	switch (claim) {
+	case NFS4_OPEN_CLAIM_NULL:
+	case NFS4_OPEN_CLAIM_DELEGATE_CUR:
+	case NFS4_OPEN_CLAIM_DELEGATE_PREV:
+		p->o_arg.fh = NFS_FH(dir);
+		break;
+	case NFS4_OPEN_CLAIM_PREVIOUS:
+	case NFS4_OPEN_CLAIM_FH:
+	case NFS4_OPEN_CLAIM_DELEG_CUR_FH:
+	case NFS4_OPEN_CLAIM_DELEG_PREV_FH:
+		p->o_arg.fh = NFS_FH(dentry->d_inode);
+	}
 	if (attrs != NULL && attrs->ia_valid != 0) {
 		__be32 verf[2];
 
@@ -1200,11 +1212,13 @@ static struct nfs_open_context *nfs4_state_find_open_context(struct nfs4_state *
 	return ERR_PTR(-ENOENT);
 }
 
-static struct nfs4_opendata *nfs4_open_recoverdata_alloc(struct nfs_open_context *ctx, struct nfs4_state *state)
+static struct nfs4_opendata *nfs4_open_recoverdata_alloc(struct nfs_open_context *ctx,
+		struct nfs4_state *state, enum open_claim_type4 claim)
 {
 	struct nfs4_opendata *opendata;
 
-	opendata = nfs4_opendata_alloc(ctx->dentry, state->owner, 0, 0, NULL, GFP_NOFS);
+	opendata = nfs4_opendata_alloc(ctx->dentry, state->owner, 0, 0,
+			NULL, claim, GFP_NOFS);
 	if (opendata == NULL)
 		return ERR_PTR(-ENOMEM);
 	opendata->state = state;
@@ -1290,11 +1304,10 @@ static int _nfs4_do_open_reclaim(struct nfs_open_context *ctx, struct nfs4_state
 	fmode_t delegation_type = 0;
 	int status;
 
-	opendata = nfs4_open_recoverdata_alloc(ctx, state);
+	opendata = nfs4_open_recoverdata_alloc(ctx, state,
+			NFS4_OPEN_CLAIM_PREVIOUS);
 	if (IS_ERR(opendata))
 		return PTR_ERR(opendata);
-	opendata->o_arg.claim = NFS4_OPEN_CLAIM_PREVIOUS;
-	opendata->o_arg.fh = NFS_FH(state->inode);
 	rcu_read_lock();
 	delegation = rcu_dereference(NFS_I(state->inode)->delegation);
 	if (delegation != NULL && test_bit(NFS_DELEGATION_NEED_RECLAIM, &delegation->flags) != 0)
@@ -1338,10 +1351,10 @@ static int _nfs4_open_delegation_recall(struct nfs_open_context *ctx, struct nfs
 	struct nfs4_opendata *opendata;
 	int ret;
 
-	opendata = nfs4_open_recoverdata_alloc(ctx, state);
+	opendata = nfs4_open_recoverdata_alloc(ctx, state,
+			NFS4_OPEN_CLAIM_DELEGATE_CUR);
 	if (IS_ERR(opendata))
 		return PTR_ERR(opendata);
-	opendata->o_arg.claim = NFS4_OPEN_CLAIM_DELEGATE_CUR;
 	nfs4_stateid_copy(&opendata->o_arg.u.delegation, stateid);
 	ret = nfs4_open_recover(opendata, state);
 	nfs4_opendata_put(opendata);
@@ -1727,7 +1740,8 @@ static int _nfs4_open_expired(struct nfs_open_context *ctx, struct nfs4_state *s
 	struct nfs4_opendata *opendata;
 	int ret;
 
-	opendata = nfs4_open_recoverdata_alloc(ctx, state);
+	opendata = nfs4_open_recoverdata_alloc(ctx, state,
+			NFS4_OPEN_CLAIM_NULL);
 	if (IS_ERR(opendata))
 		return PTR_ERR(opendata);
 	ret = nfs4_open_recover(opendata, state);
@@ -1927,7 +1941,9 @@ static int _nfs4_do_open(struct inode *dir,
 	if (dentry->d_inode != NULL)
 		nfs4_return_incompatible_delegation(dentry->d_inode, fmode);
 	status = -ENOMEM;
-	opendata = nfs4_opendata_alloc(dentry, sp, fmode, flags, sattr, GFP_KERNEL);
+	opendata = nfs4_opendata_alloc(dentry, sp, fmode, flags, sattr,
+			NFS4_OPEN_CLAIM_NULL,
+			GFP_KERNEL);
 	if (opendata == NULL)
 		goto err_put_state_owner;
 
-- 
1.8.1.4

