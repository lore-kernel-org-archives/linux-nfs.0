Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:3807 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755166Ab2KZMUA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Nov 2012 07:20:00 -0500
Subject: [PATCH 4/5] nfsd: cleanup NFSd state start a bit
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, Trond.Myklebust@netapp.com,
        linux-kernel@vger.kernel.org, devel@openvz.org
Date: Mon, 26 Nov 2012 15:22:13 +0300
Message-ID: <20121126122213.955.78067.stgit@localhost.localdomain>
In-Reply-To: <20121126121907.955.25349.stgit@localhost.localdomain>
References: <20121126121907.955.25349.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch renames nfs4_state_start_net() into nfs4_state_create_net(), where
get_net() now performed.
Also it introduces new nfs4_state_start_net(), which is now responsible for
state creation and initializing all per-net data and which is now called from
nfs4_state_start().

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
---
 fs/nfsd/nfs4state.c |   59 ++++++++++++++++++++++++++++++---------------------
 1 files changed, 35 insertions(+), 24 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index edff2cc..72df721 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4766,7 +4766,7 @@ set_max_delegations(void)
 	max_delegations = nr_free_buffer_pages() >> (20 - 2 - PAGE_SHIFT);
 }
 
-static int nfs4_state_start_net(struct net *net)
+static int nfs4_state_create_net(struct net *net)
 {
 	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 	int i;
@@ -4809,6 +4809,7 @@ static int nfs4_state_start_net(struct net *net)
 	spin_lock_init(&nn->client_lock);
 
 	INIT_DELAYED_WORK(&nn->laundromat_work, laundromat_main);
+	get_net(net);
 
 	return 0;
 
@@ -4856,37 +4857,35 @@ nfs4_state_destroy_net(struct net *net)
 	put_net(net);
 }
 
-/* initialization to perform when the nfsd service is started: */
-
-int
-nfs4_state_start(void)
+static int
+nfs4_state_start_net(struct net *net)
 {
-	struct net *net = &init_net;
 	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 	int ret;
 
-	/*
-	 * FIXME: For now, we hang most of the pernet global stuff off of
-	 * init_net until nfsd is fully containerized. Eventually, we'll
-	 * need to pass a net pointer into this function, take a reference
-	 * to that instead and then do most of the rest of this on a per-net
-	 * basis.
-	 */
-	get_net(net);
-	ret = nfs4_state_start_net(net);
+	ret = nfs4_state_create_net(net);
 	if (ret)
 		return ret;
 	nfsd4_client_tracking_init(net);
 	nn->boot_time = get_seconds();
 	locks_start_grace(net, &nn->nfsd4_manager);
 	nn->grace_ended = false;
-	printk(KERN_INFO "NFSD: starting %ld-second grace period\n",
-	       nfsd4_grace);
+	printk(KERN_INFO "NFSD: starting %ld-second grace period (net %p)\n",
+	       nfsd4_grace, net);
+	queue_delayed_work(laundry_wq, &nn->laundromat_work, nfsd4_grace * HZ);
+	return 0;
+}
+
+/* initialization to perform when the nfsd service is started: */
+
+int
+nfs4_state_start(void)
+{
+	int ret;
+
 	ret = set_callback_cred();
-	if (ret) {
-		ret = -ENOMEM;
-		goto out_recovery;
-	}
+	if (ret)
+		return -ENOMEM;
 	laundry_wq = create_singlethread_workqueue("nfsd4");
 	if (laundry_wq == NULL) {
 		ret = -ENOMEM;
@@ -4896,14 +4895,26 @@ nfs4_state_start(void)
 	if (ret)
 		goto out_free_laundry;
 
-	queue_delayed_work(laundry_wq, &nn->laundromat_work, nfsd4_grace * HZ);
 	set_max_delegations();
+
+	/*
+	 * FIXME: For now, we hang most of the pernet global stuff off of
+	 * init_net until nfsd is fully containerized. Eventually, we'll
+	 * need to pass a net pointer into this function, take a reference
+	 * to that instead and then do most of the rest of this on a per-net
+	 * basis.
+	 */
+	ret = nfs4_state_start_net(&init_net);
+	if (ret)
+		goto out_free_callback;
+
 	return 0;
+
+out_free_callback:
+	nfsd4_destroy_callback_queue();
 out_free_laundry:
 	destroy_workqueue(laundry_wq);
 out_recovery:
-	nfsd4_client_tracking_exit(net);
-	nfs4_state_destroy_net(net);
 	return ret;
 }
 

