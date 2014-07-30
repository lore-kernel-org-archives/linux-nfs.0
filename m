Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f45.google.com ([209.85.216.45]:35698 "EHLO
	mail-qa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752191AbaG3Bey (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Jul 2014 21:34:54 -0400
Received: by mail-qa0-f45.google.com with SMTP id cm18so577347qab.32
        for <linux-nfs@vger.kernel.org>; Tue, 29 Jul 2014 18:34:53 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@infradead.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH v3 03/38] nfsd: Add a struct nfs4_file field to struct nfs4_stid
Date: Tue, 29 Jul 2014 21:34:08 -0400
Message-Id: <1406684083-19736-4-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1406684083-19736-1-git-send-email-jlayton@primarydata.com>
References: <1406684083-19736-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

All stateids are associated with a nfs4_file. Let's consolidate.
Start by replacing delegation->dl_file with the dl_stid.sc_file

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfsd/nfs4callback.c |  2 +-
 fs/nfsd/nfs4state.c    | 21 ++++++++++-----------
 fs/nfsd/state.h        |  2 +-
 3 files changed, 12 insertions(+), 13 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 8574c708cf8c..e0be57b0f79b 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -337,7 +337,7 @@ static void encode_cb_recall4args(struct xdr_stream *xdr,
 	p = xdr_reserve_space(xdr, 4);
 	*p++ = xdr_zero;			/* truncate */
 
-	encode_nfs_fh4(xdr, &dp->dl_file->fi_fhandle);
+	encode_nfs_fh4(xdr, &dp->dl_stid.sc_file->fi_fhandle);
 
 	hdr->nops++;
 }
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 60ab22b6e099..d6b0ef4e90fe 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -515,10 +515,6 @@ static struct nfs4_ol_stateid * nfs4_alloc_stateid(struct nfs4_client *clp)
 
 static void nfs4_free_deleg(struct nfs4_stid *stid)
 {
-	struct nfs4_delegation *dp = delegstateid(stid);
-
-	if (dp->dl_file)
-		put_nfs4_file(dp->dl_file);
 	kmem_cache_free(deleg_slab, stid);
 	atomic_long_dec(&num_delegations);
 }
@@ -636,12 +632,15 @@ out_dec:
 void
 nfs4_put_stid(struct nfs4_stid *s)
 {
+	struct nfs4_file *fp = s->sc_file;
 	struct nfs4_client *clp = s->sc_client;
 
 	if (!atomic_dec_and_test(&s->sc_count))
 		return;
 	idr_remove(&clp->cl_stateids, s->sc_stateid.si_opaque.so_id);
 	s->sc_free(s);
+	if (fp)
+		put_nfs4_file(fp);
 }
 
 static void nfs4_put_deleg_lease(struct nfs4_file *fp)
@@ -677,7 +676,7 @@ hash_delegation_locked(struct nfs4_delegation *dp, struct nfs4_file *fp)
 static void
 unhash_delegation_locked(struct nfs4_delegation *dp)
 {
-	struct nfs4_file *fp = dp->dl_file;
+	struct nfs4_file *fp = dp->dl_stid.sc_file;
 
 	lockdep_assert_held(&state_lock);
 
@@ -3097,10 +3096,10 @@ nfs4_share_conflict(struct svc_fh *current_fh, unsigned int deny_type)
 
 void nfsd4_prepare_cb_recall(struct nfs4_delegation *dp)
 {
-	struct nfs4_client *clp = dp->dl_stid.sc_client;
-	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
+	struct nfsd_net *nn = net_generic(dp->dl_stid.sc_client->net,
+					  nfsd_net_id);
 
-	block_delegations(&dp->dl_file->fi_fhandle);
+	block_delegations(&dp->dl_stid.sc_file->fi_fhandle);
 
 	/*
 	 * We can't do this in nfsd_break_deleg_cb because it is
@@ -3508,7 +3507,7 @@ static struct file_lock *nfs4_alloc_init_lease(struct nfs4_file *fp, int flag)
 
 static int nfs4_setlease(struct nfs4_delegation *dp)
 {
-	struct nfs4_file *fp = dp->dl_file;
+	struct nfs4_file *fp = dp->dl_stid.sc_file;
 	struct file_lock *fl;
 	struct file *filp;
 	int status = 0;
@@ -3573,7 +3572,7 @@ nfs4_set_delegation(struct nfs4_client *clp, struct svc_fh *fh,
 	get_nfs4_file(fp);
 	spin_lock(&state_lock);
 	spin_lock(&fp->fi_lock);
-	dp->dl_file = fp;
+	dp->dl_stid.sc_file = fp;
 	if (!fp->fi_lease) {
 		spin_unlock(&fp->fi_lock);
 		spin_unlock(&state_lock);
@@ -4167,7 +4166,7 @@ nfs4_preprocess_stateid_op(struct net *net, struct nfsd4_compound_state *cstate,
 		if (status)
 			goto out;
 		if (filpp) {
-			file = dp->dl_file->fi_deleg_file;
+			file = dp->dl_stid.sc_file->fi_deleg_file;
 			if (!file) {
 				WARN_ON_ONCE(1);
 				status = nfserr_serverfault;
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 32c466265ac1..c856601c15f6 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -85,6 +85,7 @@ struct nfs4_stid {
 	unsigned char sc_type;
 	stateid_t sc_stateid;
 	struct nfs4_client *sc_client;
+	struct nfs4_file *sc_file;
 	void (*sc_free)(struct nfs4_stid *);
 };
 
@@ -93,7 +94,6 @@ struct nfs4_delegation {
 	struct list_head	dl_perfile;
 	struct list_head	dl_perclnt;
 	struct list_head	dl_recall_lru;  /* delegation recalled */
-	struct nfs4_file	*dl_file;
 	u32			dl_type;
 	time_t			dl_time;
 /* For recall: */
-- 
1.9.3

