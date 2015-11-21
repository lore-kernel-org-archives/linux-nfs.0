Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail3-relais-sop.national.inria.fr ([192.134.164.104]:38810
	"EHLO mail3-relais-sop.national.inria.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751622AbbKUWJ3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 21 Nov 2015 17:09:29 -0500
From: Julia Lawall <Julia.Lawall@lip6.fr>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: kernel-janitors@vger.kernel.org, Jeff Layton <jlayton@poochiereds.net>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH] nfsd: constify nfsd4_callback_ops structure
Date: Sat, 21 Nov 2015 22:57:39 +0100
Message-Id: <1448143059-3523-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The nfsd4_callback_ops structure is never modified, so declare it as const.

Done with the help of Coccinelle.

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
 fs/nfsd/nfs4callback.c |    2 +-
 fs/nfsd/nfs4layouts.c  |    4 ++--
 fs/nfsd/nfs4state.c    |    4 ++--
 fs/nfsd/state.h        |    4 ++--
 4 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index e7f50c4..081709c 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -1143,7 +1143,7 @@ nfsd4_run_cb_work(struct work_struct *work)
 }
 
 void nfsd4_init_cb(struct nfsd4_callback *cb, struct nfs4_client *clp,
-		struct nfsd4_callback_ops *ops, enum nfsd4_cb_op op)
+		const struct nfsd4_callback_ops *ops, enum nfsd4_cb_op op)
 {
 	cb->cb_clp = clp;
 	cb->cb_msg.rpc_proc = &nfs4_cb_procedures[op];
diff --git a/fs/nfsd/nfs4layouts.c b/fs/nfsd/nfs4layouts.c
index 9ffef06..fec49fe 100644
--- a/fs/nfsd/nfs4layouts.c
+++ b/fs/nfsd/nfs4layouts.c
@@ -22,7 +22,7 @@ struct nfs4_layout {
 static struct kmem_cache *nfs4_layout_cache;
 static struct kmem_cache *nfs4_layout_stateid_cache;
 
-static struct nfsd4_callback_ops nfsd4_cb_layout_ops;
+static const struct nfsd4_callback_ops nfsd4_cb_layout_ops;
 static const struct lock_manager_operations nfsd4_layouts_lm_ops;
 
 const struct nfsd4_layout_ops *nfsd4_layout_ops[LAYOUT_TYPE_MAX] =  {
@@ -665,7 +665,7 @@ nfsd4_cb_layout_release(struct nfsd4_callback *cb)
 	nfs4_put_stid(&ls->ls_stid);
 }
 
-static struct nfsd4_callback_ops nfsd4_cb_layout_ops = {
+static const struct nfsd4_callback_ops nfsd4_cb_layout_ops = {
 	.prepare	= nfsd4_cb_layout_prepare,
 	.done		= nfsd4_cb_layout_done,
 	.release	= nfsd4_cb_layout_release,
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 6b800b5..0d30a36 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -98,7 +98,7 @@ static struct kmem_cache *odstate_slab;
 
 static void free_session(struct nfsd4_session *);
 
-static struct nfsd4_callback_ops nfsd4_cb_recall_ops;
+static const struct nfsd4_callback_ops nfsd4_cb_recall_ops;
 
 static bool is_session_dead(struct nfsd4_session *ses)
 {
@@ -3648,7 +3648,7 @@ static void nfsd4_cb_recall_release(struct nfsd4_callback *cb)
 	nfs4_put_stid(&dp->dl_stid);
 }
 
-static struct nfsd4_callback_ops nfsd4_cb_recall_ops = {
+static const struct nfsd4_callback_ops nfsd4_cb_recall_ops = {
 	.prepare	= nfsd4_cb_recall_prepare,
 	.done		= nfsd4_cb_recall_done,
 	.release	= nfsd4_cb_recall_release,
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 77fdf4d..5e2ba19 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -65,7 +65,7 @@ struct nfsd4_callback {
 	struct nfs4_client *cb_clp;
 	u32 cb_minorversion;
 	struct rpc_message cb_msg;
-	struct nfsd4_callback_ops *cb_ops;
+	const struct nfsd4_callback_ops *cb_ops;
 	struct work_struct cb_work;
 	int cb_seq_status;
 	int cb_status;
@@ -599,7 +599,7 @@ extern void nfsd4_probe_callback(struct nfs4_client *clp);
 extern void nfsd4_probe_callback_sync(struct nfs4_client *clp);
 extern void nfsd4_change_callback(struct nfs4_client *clp, struct nfs4_cb_conn *);
 extern void nfsd4_init_cb(struct nfsd4_callback *cb, struct nfs4_client *clp,
-		struct nfsd4_callback_ops *ops, enum nfsd4_cb_op op);
+		const struct nfsd4_callback_ops *ops, enum nfsd4_cb_op op);
 extern void nfsd4_run_cb(struct nfsd4_callback *cb);
 extern int nfsd4_create_callback_queue(void);
 extern void nfsd4_destroy_callback_queue(void);

