Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:23824 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754046Ab2KMPq6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 Nov 2012 10:46:58 -0500
Subject: [PATCH 14/15] nfsd: pass nfsd_net instead of net to grace enders
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, devel@openvz.org, Trond.Myklebust@netapp.com,
        linux-kernel@vger.kernel.org, jlayton@redhat.com
Date: Tue, 13 Nov 2012 18:49:29 +0300
Message-ID: <20121113154929.12577.57975.stgit@localhost.localdomain>
In-Reply-To: <20121113154722.12577.57671.stgit@localhost.localdomain>
References: <20121113154722.12577.57671.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Passing net context looks as overkill.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
---
 fs/nfsd/nfs4recover.c |   12 +++++-------
 fs/nfsd/nfs4state.c   |    8 +++-----
 fs/nfsd/state.h       |    2 +-
 3 files changed, 9 insertions(+), 13 deletions(-)

diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
index ac79dd7..4e0f67a 100644
--- a/fs/nfsd/nfs4recover.c
+++ b/fs/nfsd/nfs4recover.c
@@ -58,7 +58,7 @@ struct nfsd4_client_tracking_ops {
 	void (*create)(struct nfs4_client *);
 	void (*remove)(struct nfs4_client *);
 	int (*check)(struct nfs4_client *);
-	void (*grace_done)(struct net *, time_t);
+	void (*grace_done)(struct nfsd_net *, time_t);
 };
 
 /* Globals */
@@ -332,10 +332,9 @@ purge_old(struct dentry *parent, struct dentry *child, struct nfsd_net *nn)
 }
 
 static void
-nfsd4_recdir_purge_old(struct net *net, time_t boot_time)
+nfsd4_recdir_purge_old(struct nfsd_net *nn, time_t boot_time)
 {
 	int status;
-	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 
 	if (!rec_file)
 		return;
@@ -930,11 +929,10 @@ nfsd4_cld_check(struct nfs4_client *clp)
 }
 
 static void
-nfsd4_cld_grace_done(struct net *net, time_t boot_time)
+nfsd4_cld_grace_done(struct nfsd_net *nn, time_t boot_time)
 {
 	int ret;
 	struct cld_upcall *cup;
-	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 	struct cld_net *cn = nn->cld_net;
 
 	cup = alloc_cld_upcall(cn);
@@ -1023,10 +1021,10 @@ nfsd4_client_record_check(struct nfs4_client *clp)
 }
 
 void
-nfsd4_record_grace_done(struct net *net, time_t boot_time)
+nfsd4_record_grace_done(struct nfsd_net *nn, time_t boot_time)
 {
 	if (client_tracking_ops)
-		client_tracking_ops->grace_done(net, boot_time);
+		client_tracking_ops->grace_done(nn, boot_time);
 }
 
 static int
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 1382ef0..4756176 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3138,17 +3138,15 @@ out:
 }
 
 static void
-nfsd4_end_grace(struct net *net)
+nfsd4_end_grace(struct nfsd_net *nn)
 {
-	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
-
 	/* do nothing if grace period already ended */
 	if (nn->grace_ended)
 		return;
 
 	dprintk("NFSD: end of grace period\n");
 	nn->grace_ended = true;
-	nfsd4_record_grace_done(net, nn->boot_time);
+	nfsd4_record_grace_done(nn, nn->boot_time);
 	locks_end_grace(&nn->nfsd4_manager);
 	/*
 	 * Now that every NFSv4 client has had the chance to recover and
@@ -3173,7 +3171,7 @@ nfs4_laundromat(void)
 	nfs4_lock_state();
 
 	dprintk("NFSD: laundromat service - starting\n");
-	nfsd4_end_grace(&init_net);
+	nfsd4_end_grace(nn);
 	INIT_LIST_HEAD(&reaplist);
 	spin_lock(&client_lock);
 	list_for_each_safe(pos, next, &nn->client_lru) {
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 739b851..e1f55a6 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -493,5 +493,5 @@ extern void nfsd4_client_tracking_exit(struct net *net);
 extern void nfsd4_client_record_create(struct nfs4_client *clp);
 extern void nfsd4_client_record_remove(struct nfs4_client *clp);
 extern int nfsd4_client_record_check(struct nfs4_client *clp);
-extern void nfsd4_record_grace_done(struct net *net, time_t boot_time);
+extern void nfsd4_record_grace_done(struct nfsd_net *nn, time_t boot_time);
 #endif   /* NFSD4_STATE_H */

