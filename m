Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:49098 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932701Ab2KNPTi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Nov 2012 10:19:38 -0500
Subject: [PATCH v2 14/15] nfsd: pass nfsd_net instead of net to grace enders
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, devel@openvz.org, Trond.Myklebust@netapp.com,
        linux-kernel@vger.kernel.org, jlayton@redhat.com
Date: Wed, 14 Nov 2012 18:22:12 +0300
Message-ID: <20121114152212.4708.35689.stgit@localhost.localdomain>
In-Reply-To: <20121114152018.4708.63125.stgit@localhost.localdomain>
References: <20121114152018.4708.63125.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Passing net context looks as overkill.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
---
 fs/nfsd/nfs4recover.c |   14 ++++++--------
 fs/nfsd/nfs4state.c   |    8 +++-----
 fs/nfsd/state.h       |    2 +-
 3 files changed, 10 insertions(+), 14 deletions(-)

diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
index 376692a..b657b62 100644
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
@@ -391,10 +391,9 @@ purge_old(struct dentry *parent, struct dentry *child, struct nfsd_net *nn)
 }
 
 static void
-nfsd4_recdir_purge_old(struct net *net, time_t boot_time)
+nfsd4_recdir_purge_old(struct nfsd_net *nn, time_t boot_time)
 {
 	int status;
-	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 
 	in_grace = false;
 	if (!rec_file)
@@ -1017,11 +1016,10 @@ nfsd4_cld_check(struct nfs4_client *clp)
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
@@ -1241,7 +1239,7 @@ nfsd4_umh_cltrack_check(struct nfs4_client *clp)
 }
 
 static void
-nfsd4_umh_cltrack_grace_done(struct net __attribute__((unused)) *net,
+nfsd4_umh_cltrack_grace_done(struct nfsd_net __attribute__((unused)) *nn,
 				time_t boot_time)
 {
 	char *legacy;
@@ -1343,10 +1341,10 @@ nfsd4_client_record_check(struct nfs4_client *clp)
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
index 6927031..07f10fb 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3157,17 +3157,15 @@ out:
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
@@ -3192,7 +3190,7 @@ nfs4_laundromat(void)
 	nfs4_lock_state();
 
 	dprintk("NFSD: laundromat service - starting\n");
-	nfsd4_end_grace(&init_net);
+	nfsd4_end_grace(nn);
 	INIT_LIST_HEAD(&reaplist);
 	spin_lock(&client_lock);
 	list_for_each_safe(pos, next, &nn->client_lru) {
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index bfe0106..2deb6a8 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -495,5 +495,5 @@ extern void nfsd4_client_tracking_exit(struct net *net);
 extern void nfsd4_client_record_create(struct nfs4_client *clp);
 extern void nfsd4_client_record_remove(struct nfs4_client *clp);
 extern int nfsd4_client_record_check(struct nfs4_client *clp);
-extern void nfsd4_record_grace_done(struct net *net, time_t boot_time);
+extern void nfsd4_record_grace_done(struct nfsd_net *nn, time_t boot_time);
 #endif   /* NFSD4_STATE_H */

