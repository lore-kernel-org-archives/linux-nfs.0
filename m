Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f53.google.com ([209.85.192.53]:52178 "EHLO
	mail-qg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752518AbaGUPDE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jul 2014 11:03:04 -0400
Received: by mail-qg0-f53.google.com with SMTP id q107so5498987qgd.12
        for <linux-nfs@vger.kernel.org>; Mon, 21 Jul 2014 08:03:03 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@infradead.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH 03/40] nfsd: Add a struct nfs4_file field to struct nfs4_stid
Date: Mon, 21 Jul 2014 11:02:15 -0400
Message-Id: <1405954972-28904-4-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1405954972-28904-1-git-send-email-jlayton@primarydata.com>
References: <1405954972-28904-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

All stateids are associated with a nfs4_file. Let's consolidate.
Start by replacing delegation->dl_file with the dl_stid.sc_file

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 16 ++++++++--------
 fs/nfsd/state.h     |  2 +-
 2 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 76d28be3ef41..55cb95154731 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -615,6 +615,8 @@ static void remove_stid(struct nfs4_stid *s)
 
 static void nfs4_free_stid(struct kmem_cache *slab, struct nfs4_stid *s)
 {
+	if (s->sc_file)
+		put_nfs4_file(s->sc_file);
 	kmem_cache_free(slab, s);
 }
 
@@ -622,8 +624,6 @@ void
 nfs4_put_delegation(struct nfs4_delegation *dp)
 {
 	if (atomic_dec_and_test(&dp->dl_stid.sc_count)) {
-		if (dp->dl_file)
-			put_nfs4_file(dp->dl_file);
 		remove_stid(&dp->dl_stid);
 		nfs4_free_stid(deleg_slab, &dp->dl_stid);
 		atomic_long_dec(&num_delegations);
@@ -663,7 +663,7 @@ hash_delegation_locked(struct nfs4_delegation *dp, struct nfs4_file *fp)
 static void
 unhash_delegation_locked(struct nfs4_delegation *dp)
 {
-	struct nfs4_file *fp = dp->dl_file;
+	struct nfs4_file *fp = dp->dl_stid.sc_file;
 
 	lockdep_assert_held(&state_lock);
 
@@ -3100,8 +3100,8 @@ nfs4_share_conflict(struct svc_fh *current_fh, unsigned int deny_type)
 
 void nfsd4_prepare_cb_recall(struct nfs4_delegation *dp)
 {
-	struct nfs4_client *clp = dp->dl_stid.sc_client;
-	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
+	struct nfsd_net *nn = net_generic(dp->dl_stid.sc_client->net,
+					  nfsd_net_id);
 
 	block_delegations(&dp->dl_fh);
 
@@ -3511,7 +3511,7 @@ static struct file_lock *nfs4_alloc_init_lease(struct nfs4_file *fp, int flag)
 
 static int nfs4_setlease(struct nfs4_delegation *dp)
 {
-	struct nfs4_file *fp = dp->dl_file;
+	struct nfs4_file *fp = dp->dl_stid.sc_file;
 	struct file_lock *fl;
 	struct file *filp;
 	int status = 0;
@@ -3575,7 +3575,7 @@ nfs4_set_delegation(struct nfs4_client *clp, struct svc_fh *fh,
 	get_nfs4_file(fp);
 	spin_lock(&state_lock);
 	spin_lock(&fp->fi_lock);
-	dp->dl_file = fp;
+	dp->dl_stid.sc_file = fp;
 	if (!fp->fi_lease) {
 		spin_unlock(&fp->fi_lock);
 		spin_unlock(&state_lock);
@@ -4170,7 +4170,7 @@ nfs4_preprocess_stateid_op(struct net *net, struct nfsd4_compound_state *cstate,
 		if (status)
 			goto out;
 		if (filpp) {
-			file = dp->dl_file->fi_deleg_file;
+			file = dp->dl_stid.sc_file->fi_deleg_file;
 			if (!file) {
 				WARN_ON_ONCE(1);
 				status = nfserr_serverfault;
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index e68a9ae30fd7..b14bb7407448 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -85,6 +85,7 @@ struct nfs4_stid {
 	unsigned char sc_type;
 	stateid_t sc_stateid;
 	struct nfs4_client *sc_client;
+	struct nfs4_file *sc_file;
 };
 
 struct nfs4_delegation {
@@ -92,7 +93,6 @@ struct nfs4_delegation {
 	struct list_head	dl_perfile;
 	struct list_head	dl_perclnt;
 	struct list_head	dl_recall_lru;  /* delegation recalled */
-	struct nfs4_file	*dl_file;
 	u32			dl_type;
 	time_t			dl_time;
 /* For recall: */
-- 
1.9.3

