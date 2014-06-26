Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f180.google.com ([209.85.216.180]:35428 "EHLO
	mail-qc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750832AbaFZTOA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jun 2014 15:14:00 -0400
Received: by mail-qc0-f180.google.com with SMTP id r5so3540655qcx.39
        for <linux-nfs@vger.kernel.org>; Thu, 26 Jun 2014 12:13:59 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 009/117] nfsd: wait to initialize work struct just prior to using it
Date: Thu, 26 Jun 2014 15:11:49 -0400
Message-Id: <1403810017-16062-10-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
References: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There's a fair chance we won't ever need this work struct, so we might
as well delay initializing it until just before we're going to use it.
In a later patch, we'll need to intialize the work with a different
function for delegation callbacks. By delaying this, we avoid having
to do it twice.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4callback.c | 10 +++++-----
 fs/nfsd/nfs4state.c    |  2 --
 fs/nfsd/state.h        |  1 -
 3 files changed, 5 insertions(+), 8 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 2c73cae9899d..00cb9b7a75f6 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -43,6 +43,7 @@
 #define NFSDDBG_FACILITY                NFSDDBG_PROC
 
 static void nfsd4_mark_cb_fault(struct nfs4_client *, int reason);
+static void nfsd4_do_callback_rpc(struct work_struct *w);
 
 #define NFSPROC4_CB_NULL 0
 #define NFSPROC4_CB_COMPOUND 1
@@ -763,6 +764,8 @@ static void do_probe_callback(struct nfs4_client *clp)
 
 	cb->cb_ops = &nfsd4_cb_probe_ops;
 
+	INIT_WORK(&cb->cb_work, nfsd4_do_callback_rpc);
+
 	run_nfsd4_cb(cb);
 }
 
@@ -1031,11 +1034,6 @@ static void nfsd4_do_callback_rpc(struct work_struct *w)
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
@@ -1053,5 +1051,7 @@ void nfsd4_cb_recall(struct nfs4_delegation *dp)
 	INIT_LIST_HEAD(&cb->cb_per_client);
 	cb->cb_done = true;
 
+	INIT_WORK(&cb->cb_work, nfsd4_do_callback_rpc);
+
 	run_nfsd4_cb(&dp->dl_recall);
 }
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 29788fd0da24..b49b46b0ce23 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -466,7 +466,6 @@ alloc_init_deleg(struct nfs4_client *clp, struct nfs4_ol_stateid *stp, struct sv
 	fh_copy_shallow(&dp->dl_fh, &current_fh->fh_handle);
 	dp->dl_time = 0;
 	atomic_set(&dp->dl_count, 1);
-	nfsd4_init_callback(&dp->dl_recall);
 	return dp;
 }
 
@@ -1472,7 +1471,6 @@ static struct nfs4_client *create_client(struct xdr_netobj name,
 		spin_unlock(&nn->client_lock);
 		return NULL;
 	}
-	nfsd4_init_callback(&clp->cl_cb_null);
 	clp->cl_time = get_seconds();
 	clear_bit(0, &clp->cl_cb_slot_busy);
 	copy_verf(clp, verf);
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 374c66283ac5..9447f86f2778 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -464,7 +464,6 @@ extern struct nfs4_client_reclaim *nfsd4_find_reclaim_client(const char *recdir,
 							struct nfsd_net *nn);
 extern __be32 nfs4_check_open_reclaim(clientid_t *clid, bool sessions, struct nfsd_net *nn);
 extern int set_callback_cred(void);
-extern void nfsd4_init_callback(struct nfsd4_callback *);
 extern void nfsd4_probe_callback(struct nfs4_client *clp);
 extern void nfsd4_probe_callback_sync(struct nfs4_client *clp);
 extern void nfsd4_change_callback(struct nfs4_client *clp, struct nfs4_cb_conn *);
-- 
1.9.3

