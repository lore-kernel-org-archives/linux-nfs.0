Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:48600 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752288Ab1IZWjp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Sep 2011 18:39:45 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 1/4] nfsd4: move client * to nfs4_stateid, add init_stid helper
Date: Mon, 26 Sep 2011 18:39:37 -0400
Message-Id: <1317076780-22309-1-git-send-email-bfields@redhat.com>
In-Reply-To: <20110926223722.GB22140@fieldses.org>
References: <20110926223722.GB22140@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

This will be convenient.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4callback.c |    8 ++++----
 fs/nfsd/nfs4state.c    |   48 ++++++++++++++++++++++++++----------------------
 fs/nfsd/state.h        |    2 +-
 3 files changed, 31 insertions(+), 27 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 93b5e40..de018ec 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -787,7 +787,7 @@ static void nfsd4_cb_prepare(struct rpc_task *task, void *calldata)
 {
 	struct nfsd4_callback *cb = calldata;
 	struct nfs4_delegation *dp = container_of(cb, struct nfs4_delegation, dl_recall);
-	struct nfs4_client *clp = dp->dl_client;
+	struct nfs4_client *clp = dp->dl_stid.sc_client;
 	u32 minorversion = clp->cl_minorversion;
 
 	cb->cb_minorversion = minorversion;
@@ -809,7 +809,7 @@ static void nfsd4_cb_done(struct rpc_task *task, void *calldata)
 {
 	struct nfsd4_callback *cb = calldata;
 	struct nfs4_delegation *dp = container_of(cb, struct nfs4_delegation, dl_recall);
-	struct nfs4_client *clp = dp->dl_client;
+	struct nfs4_client *clp = dp->dl_stid.sc_client;
 
 	dprintk("%s: minorversion=%d\n", __func__,
 		clp->cl_minorversion);
@@ -832,7 +832,7 @@ static void nfsd4_cb_recall_done(struct rpc_task *task, void *calldata)
 {
 	struct nfsd4_callback *cb = calldata;
 	struct nfs4_delegation *dp = container_of(cb, struct nfs4_delegation, dl_recall);
-	struct nfs4_client *clp = dp->dl_client;
+	struct nfs4_client *clp = dp->dl_stid.sc_client;
 	struct rpc_clnt *current_rpc_client = clp->cl_cb_client;
 
 	nfsd4_cb_done(task, calldata);
@@ -1006,7 +1006,7 @@ void nfsd4_do_callback_rpc(struct work_struct *w)
 void nfsd4_cb_recall(struct nfs4_delegation *dp)
 {
 	struct nfsd4_callback *cb = &dp->dl_recall;
-	struct nfs4_client *clp = dp->dl_client;
+	struct nfs4_client *clp = dp->dl_stid.sc_client;
 
 	dp->dl_retries = 1;
 	cb->cb_op = dp;
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index edcced1..cb36c9a 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -224,6 +224,19 @@ static inline void hash_stid(struct nfs4_stid *stid)
 	list_add(&stid->sc_hash, &stateid_hashtbl[hashval]);
 }
 
+static void init_stid(struct nfs4_stid *stid, struct nfs4_client *cl, unsigned char type)
+{
+	stateid_t *s = &stid->sc_stateid;
+
+	stid->sc_type = type;
+	stid->sc_client = cl;
+	s->si_opaque.so_clid = cl->cl_clientid;
+	s->si_opaque.so_id = current_stateid++;
+	/* Will be incremented before return to client: */
+	s->si_generation = 0;
+	hash_stid(stid);
+}
+
 static struct nfs4_delegation *
 alloc_init_deleg(struct nfs4_client *clp, struct nfs4_ol_stateid *stp, struct svc_fh *current_fh, u32 type)
 {
@@ -245,19 +258,20 @@ alloc_init_deleg(struct nfs4_client *clp, struct nfs4_ol_stateid *stp, struct sv
 	dp = kmem_cache_alloc(deleg_slab, GFP_KERNEL);
 	if (dp == NULL)
 		return dp;
+	init_stid(&dp->dl_stid, clp, NFS4_DELEG_STID);
+	/*
+	 * delegation seqid's are never incremented.  The 4.1 special
+	 * meaning of seqid 0 isn't really meaningful, really, but let's
+	 * avoid 0 anyway just for consistency and use 1:
+	 */
+	dp->dl_stid.sc_stateid.si_generation = 1;
 	num_delegations++;
 	INIT_LIST_HEAD(&dp->dl_perfile);
 	INIT_LIST_HEAD(&dp->dl_perclnt);
 	INIT_LIST_HEAD(&dp->dl_recall_lru);
-	dp->dl_client = clp;
 	get_nfs4_file(fp);
 	dp->dl_file = fp;
 	dp->dl_type = type;
-	dp->dl_stid.sc_type = NFS4_DELEG_STID;
-	dp->dl_stid.sc_stateid.si_opaque.so_clid = clp->cl_clientid;
-	dp->dl_stid.sc_stateid.si_opaque.so_id = current_stateid++;
-	dp->dl_stid.sc_stateid.si_generation = 1;
-	hash_stid(&dp->dl_stid);
 	fh_copy_shallow(&dp->dl_fh, &current_fh->fh_handle);
 	dp->dl_time = 0;
 	atomic_set(&dp->dl_count, 1);
@@ -2333,18 +2347,13 @@ init_open_stateid(struct nfs4_ol_stateid *stp, struct nfs4_file *fp, struct nfsd
 	struct nfs4_openowner *oo = open->op_openowner;
 	struct nfs4_client *clp = oo->oo_owner.so_client;
 
+	init_stid(&stp->st_stid, clp, NFS4_OPEN_STID);
 	INIT_LIST_HEAD(&stp->st_lockowners);
 	list_add(&stp->st_perstateowner, &oo->oo_owner.so_stateids);
 	list_add(&stp->st_perfile, &fp->fi_stateids);
-	stp->st_stid.sc_type = NFS4_OPEN_STID;
 	stp->st_stateowner = &oo->oo_owner;
 	get_nfs4_file(fp);
 	stp->st_file = fp;
-	stp->st_stid.sc_stateid.si_opaque.so_clid = clp->cl_clientid;
-	stp->st_stid.sc_stateid.si_opaque.so_id = current_stateid++;
-	/* note will be incremented before first return to client: */
-	stp->st_stid.sc_stateid.si_generation = 0;
-	hash_stid(&stp->st_stid);
 	stp->st_access_bmap = 0;
 	stp->st_deny_bmap = 0;
 	__set_bit(open->op_share_access & ~NFS4_SHARE_WANT_MASK,
@@ -2792,7 +2801,7 @@ static int nfs4_setlease(struct nfs4_delegation *dp, int flag)
 	if (!fl)
 		return -ENOMEM;
 	fl->fl_file = find_readable_file(fp);
-	list_add(&dp->dl_perclnt, &dp->dl_client->cl_delegations);
+	list_add(&dp->dl_perclnt, &dp->dl_stid.sc_client->cl_delegations);
 	status = vfs_setlease(fl->fl_file, fl->fl_type, &fl);
 	if (status) {
 		list_del_init(&dp->dl_perclnt);
@@ -2821,7 +2830,7 @@ static int nfs4_set_delegation(struct nfs4_delegation *dp, int flag)
 	atomic_inc(&fp->fi_delegees);
 	list_add(&dp->dl_perfile, &fp->fi_delegations);
 	spin_unlock(&recall_lock);
-	list_add(&dp->dl_perclnt, &dp->dl_client->cl_delegations);
+	list_add(&dp->dl_perclnt, &dp->dl_stid.sc_client->cl_delegations);
 	return 0;
 }
 
@@ -3295,7 +3304,7 @@ nfs4_preprocess_stateid_op(struct nfsd4_compound_state *cstate,
 		status = nfs4_check_delegmode(dp, flags);
 		if (status)
 			goto out;
-		renew_client(dp->dl_client);
+		renew_client(dp->dl_stid.sc_client);
 		if (filpp) {
 			*filpp = dp->dl_file->fi_deleg_file;
 			BUG_ON(!*filpp);
@@ -3665,7 +3674,7 @@ nfsd4_delegreturn(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	status = check_stateid_generation(stateid, &dp->dl_stid.sc_stateid, nfsd4_has_session(cstate));
 	if (status)
 		goto out;
-	renew_client(dp->dl_client);
+	renew_client(dp->dl_stid.sc_client);
 
 	unhash_delegation(dp);
 out:
@@ -3819,17 +3828,12 @@ alloc_init_lock_stateid(struct nfs4_lockowner *lo, struct nfs4_file *fp, struct
 	stp = nfs4_alloc_stateid();
 	if (stp == NULL)
 		goto out;
+	init_stid(&stp->st_stid, clp, NFS4_LOCK_STID);
 	list_add(&stp->st_perfile, &fp->fi_stateids);
 	list_add(&stp->st_perstateowner, &lo->lo_owner.so_stateids);
 	stp->st_stateowner = &lo->lo_owner;
-	stp->st_stid.sc_type = NFS4_LOCK_STID;
 	get_nfs4_file(fp);
 	stp->st_file = fp;
-	stp->st_stid.sc_stateid.si_opaque.so_clid = clp->cl_clientid;
-	stp->st_stid.sc_stateid.si_opaque.so_id = current_stateid++;
-	/* note will be incremented before first return to client: */
-	stp->st_stid.sc_stateid.si_generation = 0;
-	hash_stid(&stp->st_stid);
 	stp->st_access_bmap = 0;
 	stp->st_deny_bmap = open_stp->st_deny_bmap;
 	stp->st_openstp = open_stp;
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index da68bf6..70062b7 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -81,6 +81,7 @@ struct nfs4_stid {
 	unsigned char sc_type;
 	struct list_head sc_hash;
 	stateid_t sc_stateid;
+	struct nfs4_client *sc_client;
 };
 
 struct nfs4_delegation {
@@ -88,7 +89,6 @@ struct nfs4_delegation {
 	struct list_head	dl_perclnt;
 	struct list_head	dl_recall_lru;  /* delegation recalled */
 	atomic_t		dl_count;       /* ref count */
-	struct nfs4_client	*dl_client;
 	struct nfs4_file	*dl_file;
 	u32			dl_type;
 	time_t			dl_time;
-- 
1.7.4.1

