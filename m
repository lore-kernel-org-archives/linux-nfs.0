Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:2052 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755357Ab2KZMUE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Nov 2012 07:20:04 -0500
Subject: [PATCH 5/5] nfsd: call state init and shutdown twice
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, Trond.Myklebust@netapp.com,
        linux-kernel@vger.kernel.org, devel@openvz.org
Date: Mon, 26 Nov 2012 15:22:18 +0300
Message-ID: <20121126122218.955.65863.stgit@localhost.localdomain>
In-Reply-To: <20121126121907.955.25349.stgit@localhost.localdomain>
References: <20121126121907.955.25349.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Split NFSv4 state init and shutdown into two different calls: per-net one and
generic one.
Per-net cwinit/shutdown pair have to be called for any namespace, generic pair
- only once on NSFd kthreads start and shutdown respectively.

Refresh of diff-nfsd-call-state-init-twice
---
 fs/nfsd/nfs4state.c |   30 ++++++++++++------------------
 fs/nfsd/nfsd.h      |    4 ++++
 fs/nfsd/nfssvc.c    |   15 +++++++++++++--
 3 files changed, 29 insertions(+), 20 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 72df721..93c7882 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4857,12 +4857,22 @@ nfs4_state_destroy_net(struct net *net)
 	put_net(net);
 }
 
-static int
+int
 nfs4_state_start_net(struct net *net)
 {
 	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 	int ret;
 
+	/*
+	 * FIXME: For now, we hang most of the pernet global stuff off of
+	 * init_net until nfsd is fully containerized. Eventually, we'll
+	 * need to pass a net pointer into this function, take a reference
+	 * to that instead and then do most of the rest of this on a per-net
+	 * basis.
+	 */
+	if (net != &init_net)
+		return -EINVAL;
+
 	ret = nfs4_state_create_net(net);
 	if (ret)
 		return ret;
@@ -4897,21 +4907,8 @@ nfs4_state_start(void)
 
 	set_max_delegations();
 
-	/*
-	 * FIXME: For now, we hang most of the pernet global stuff off of
-	 * init_net until nfsd is fully containerized. Eventually, we'll
-	 * need to pass a net pointer into this function, take a reference
-	 * to that instead and then do most of the rest of this on a per-net
-	 * basis.
-	 */
-	ret = nfs4_state_start_net(&init_net);
-	if (ret)
-		goto out_free_callback;
-
 	return 0;
 
-out_free_callback:
-	nfsd4_destroy_callback_queue();
 out_free_laundry:
 	destroy_workqueue(laundry_wq);
 out_recovery:
@@ -4919,7 +4916,7 @@ out_recovery:
 }
 
 /* should be called with the state lock held */
-static void
+void
 nfs4_state_shutdown_net(struct net *net)
 {
 	struct nfs4_delegation *dp = NULL;
@@ -4950,9 +4947,6 @@ nfs4_state_shutdown_net(struct net *net)
 void
 nfs4_state_shutdown(void)
 {
-	struct net *net = &init_net;
-
-	nfs4_state_shutdown_net(net);
 	destroy_workqueue(laundry_wq);
 	nfsd4_destroy_callback_queue();
 }
diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index 80d5ce4..d7b210b 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -121,7 +121,9 @@ void nfs4_state_init(void);
 int nfsd4_init_slabs(void);
 void nfsd4_free_slabs(void);
 int nfs4_state_start(void);
+int nfs4_state_start_net(struct net *net);
 void nfs4_state_shutdown(void);
+void nfs4_state_shutdown_net(struct net *net);
 void nfs4_reset_lease(time_t leasetime);
 int nfs4_reset_recoverydir(char *recdir);
 char * nfs4_recoverydir(void);
@@ -130,7 +132,9 @@ static inline void nfs4_state_init(void) { }
 static inline int nfsd4_init_slabs(void) { return 0; }
 static inline void nfsd4_free_slabs(void) { }
 static inline int nfs4_state_start(void) { return 0; }
+static inline int nfs4_state_start_net(struct net *net) { return 0; }
 static inline void nfs4_state_shutdown(void) { }
+static inline void nfs4_state_shutdown_net(struct net *net) { }
 static inline void nfs4_reset_lease(time_t leasetime) { }
 static inline int nfs4_reset_recoverydir(char *recdir) { return 0; }
 static inline char * nfs4_recoverydir(void) {return NULL; }
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 2013aa0..6dffa74 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -207,6 +207,7 @@ static bool nfsd_up = false;
 static int nfsd_startup(int nrservs)
 {
 	int ret;
+	struct net *net = &init_net;
 
 	if (nfsd_up)
 		return 0;
@@ -221,14 +222,21 @@ static int nfsd_startup(int nrservs)
 	ret = nfsd_init_socks();
 	if (ret)
 		goto out_racache;
-	ret = lockd_up(&init_net);
+	ret = lockd_up(net);
 	if (ret)
 		goto out_racache;
 	ret = nfs4_state_start();
 	if (ret)
 		goto out_lockd;
+
+	ret = nfs4_state_start_net(net);
+	if (ret)
+		goto out_net_state;
+
 	nfsd_up = true;
 	return 0;
+out_net_state:
+	nfs4_state_shutdown();
 out_lockd:
 	lockd_down(&init_net);
 out_racache:
@@ -238,6 +246,8 @@ out_racache:
 
 static void nfsd_shutdown(void)
 {
+	struct net *net = &init_net;
+
 	/*
 	 * write_ports can create the server without actually starting
 	 * any threads--if we get shut down before any threads are
@@ -246,8 +256,9 @@ static void nfsd_shutdown(void)
 	 */
 	if (!nfsd_up)
 		return;
+	nfs4_state_shutdown_net(net);
 	nfs4_state_shutdown();
-	lockd_down(&init_net);
+	lockd_down(net);
 	nfsd_racache_shutdown();
 	nfsd_up = false;
 }

