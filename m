Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f42.google.com ([209.85.216.42]:63972 "EHLO
	mail-qa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754800AbaGNNNt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Jul 2014 09:13:49 -0400
Received: by mail-qa0-f42.google.com with SMTP id j15so3274026qaq.29
        for <linux-nfs@vger.kernel.org>; Mon, 14 Jul 2014 06:13:49 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: hch@infradead.org, linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] nfsd: eliminate nfsd4_init_callback
Date: Mon, 14 Jul 2014 09:13:41 -0400
Message-Id: <1405343622-14385-2-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1405343622-14385-1-git-send-email-jlayton@primarydata.com>
References: <1405343622-14385-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It's just an obfuscated INIT_WORK call. Just make the work_func_t a
non-static symbol and use a normal INIT_WORK call.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfsd/nfs4callback.c | 8 ++------
 fs/nfsd/nfs4state.c    | 4 ++--
 fs/nfsd/state.h        | 2 +-
 3 files changed, 5 insertions(+), 9 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 2c73cae9899d..30a71cb46001 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -1011,7 +1011,8 @@ static void nfsd4_process_cb_update(struct nfsd4_callback *cb)
 		run_nfsd4_cb(cb);
 }
 
-static void nfsd4_do_callback_rpc(struct work_struct *w)
+void
+nfsd4_do_callback_rpc(struct work_struct *w)
 {
 	struct nfsd4_callback *cb = container_of(w, struct nfsd4_callback, cb_work);
 	struct nfs4_client *clp = cb->cb_clp;
@@ -1031,11 +1032,6 @@ static void nfsd4_do_callback_rpc(struct work_struct *w)
 			cb->cb_ops, cb);
 }
 
-void nfsd4_init_callback(struct nfsd4_callback *cb)
-{
-	INIT_WORK(&cb->cb_work, nfsd4_do_callback_rpc);
-}
-
 void nfsd4_cb_recall(struct nfs4_delegation *dp)
 {
 	struct nfsd4_callback *cb = &dp->dl_recall;
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 225f98c7d00d..56ea4f12803e 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -592,7 +592,7 @@ alloc_init_deleg(struct nfs4_client *clp, struct nfs4_ol_stateid *stp, struct sv
 	fh_copy_shallow(&dp->dl_fh, &current_fh->fh_handle);
 	dp->dl_time = 0;
 	atomic_set(&dp->dl_count, 1);
-	nfsd4_init_callback(&dp->dl_recall);
+	INIT_WORK(&dp->dl_recall.cb_work, nfsd4_do_callback_rpc);
 	return dp;
 }
 
@@ -1677,7 +1677,7 @@ static struct nfs4_client *create_client(struct xdr_netobj name,
 		spin_unlock(&nn->client_lock);
 		return NULL;
 	}
-	nfsd4_init_callback(&clp->cl_cb_null);
+	INIT_WORK(&clp->cl_cb_null.cb_work, nfsd4_do_callback_rpc);
 	clp->cl_time = get_seconds();
 	clear_bit(0, &clp->cl_cb_slot_busy);
 	copy_verf(clp, verf);
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 015b972da8ba..20857142773f 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -436,7 +436,7 @@ extern struct nfs4_client_reclaim *nfsd4_find_reclaim_client(const char *recdir,
 extern __be32 nfs4_check_open_reclaim(clientid_t *clid,
 		struct nfsd4_compound_state *cstate, struct nfsd_net *nn);
 extern int set_callback_cred(void);
-extern void nfsd4_init_callback(struct nfsd4_callback *);
+void nfsd4_do_callback_rpc(struct work_struct *w);
 extern void nfsd4_probe_callback(struct nfs4_client *clp);
 extern void nfsd4_probe_callback_sync(struct nfs4_client *clp);
 extern void nfsd4_change_callback(struct nfs4_client *clp, struct nfs4_cb_conn *);
-- 
1.9.3

