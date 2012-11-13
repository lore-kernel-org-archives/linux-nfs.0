Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:41830 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754046Ab2KMPrJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 Nov 2012 10:47:09 -0500
Subject: [PATCH 15/15] nfsd: make laundromat network namespace aware
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, devel@openvz.org, Trond.Myklebust@netapp.com,
        linux-kernel@vger.kernel.org, jlayton@redhat.com
Date: Tue, 13 Nov 2012 18:49:35 +0300
Message-ID: <20121113154935.12577.97422.stgit@localhost.localdomain>
In-Reply-To: <20121113154722.12577.57671.stgit@localhost.localdomain>
References: <20121113154722.12577.57671.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch moves laundromat_work to nfsd per-net context, thus allowing to run
multiple laundries.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
---
 fs/nfsd/netns.h     |    2 ++
 fs/nfsd/nfs4state.c |   21 +++++++++++++--------
 2 files changed, 15 insertions(+), 8 deletions(-)

diff --git a/fs/nfsd/netns.h b/fs/nfsd/netns.h
index f024fe2..c135277 100644
--- a/fs/nfsd/netns.h
+++ b/fs/nfsd/netns.h
@@ -77,6 +77,8 @@ struct nfsd_net {
 	 */
 	struct list_head client_lru;
 	struct list_head close_lru;
+
+	struct delayed_work laundromat_work;
 };
 
 extern int nfsd_net_id;
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 4756176..bb109ae 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3157,7 +3157,7 @@ nfsd4_end_grace(struct nfsd_net *nn)
 }
 
 static time_t
-nfs4_laundromat(void)
+nfs4_laundromat(struct nfsd_net *nn)
 {
 	struct nfs4_client *clp;
 	struct nfs4_openowner *oo;
@@ -3166,7 +3166,6 @@ nfs4_laundromat(void)
 	time_t cutoff = get_seconds() - nfsd4_lease;
 	time_t t, clientid_val = nfsd4_lease;
 	time_t u, test_val = nfsd4_lease;
-	struct nfsd_net *nn = net_generic(&init_net, nfsd_net_id);
 
 	nfs4_lock_state();
 
@@ -3232,16 +3231,19 @@ nfs4_laundromat(void)
 
 static struct workqueue_struct *laundry_wq;
 static void laundromat_main(struct work_struct *);
-static DECLARE_DELAYED_WORK(laundromat_work, laundromat_main);
 
 static void
-laundromat_main(struct work_struct *not_used)
+laundromat_main(struct work_struct *laundry)
 {
 	time_t t;
+	struct delayed_work *dwork = container_of(laundry, struct delayed_work,
+						  work);
+	struct nfsd_net *nn = container_of(dwork, struct nfsd_net,
+					   laundromat_work);
 
-	t = nfs4_laundromat();
+	t = nfs4_laundromat(nn);
 	dprintk("NFSD: laundromat_main - sleeping for %ld seconds\n", t);
-	queue_delayed_work(laundry_wq, &laundromat_work, t*HZ);
+	queue_delayed_work(laundry_wq, &nn->laundromat_work, t*HZ);
 }
 
 static inline __be32 nfs4_check_fh(struct svc_fh *fhp, struct nfs4_ol_stateid *stp)
@@ -4781,6 +4783,8 @@ static int nfs4_state_start_net(struct net *net)
 	INIT_LIST_HEAD(&nn->client_lru);
 	INIT_LIST_HEAD(&nn->close_lru);
 
+	INIT_DELAYED_WORK(&nn->laundromat_work, laundromat_main);
+
 	return 0;
 
 err_sessionid:
@@ -4864,7 +4868,8 @@ nfs4_state_start(void)
 	ret = nfsd4_create_callback_queue();
 	if (ret)
 		goto out_free_laundry;
-	queue_delayed_work(laundry_wq, &laundromat_work, nfsd4_grace * HZ);
+
+	queue_delayed_work(laundry_wq, &nn->laundromat_work, nfsd4_grace * HZ);
 	set_max_delegations();
 	return 0;
 out_free_laundry:
@@ -4906,7 +4911,7 @@ nfs4_state_shutdown(void)
 	struct net *net = &init_net;
 	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 
-	cancel_delayed_work_sync(&laundromat_work);
+	cancel_delayed_work_sync(&nn->laundromat_work);
 	destroy_workqueue(laundry_wq);
 	locks_end_grace(&nn->nfsd4_manager);
 	nfs4_lock_state();

