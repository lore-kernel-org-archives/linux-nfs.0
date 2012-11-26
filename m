Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:24897 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755166Ab2KZMT4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Nov 2012 07:19:56 -0500
Subject: [PATCH 3/5] nfsd: cleanup NFSd state shutdown a bit
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, Trond.Myklebust@netapp.com,
        linux-kernel@vger.kernel.org, devel@openvz.org
Date: Mon, 26 Nov 2012 15:22:08 +0300
Message-ID: <20121126122208.955.49674.stgit@localhost.localdomain>
In-Reply-To: <20121126121907.955.25349.stgit@localhost.localdomain>
References: <20121126121907.955.25349.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch renames __nfs4_state_shutdown_net() into nfs4_state_shutdown_net(),
__nfs4_state_shutdown() into nfs4_state_shutdown_net() and moves all network
related shutdown operations to nfs4_state_shutdown_net().

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
---
 fs/nfsd/nfs4state.c |   19 +++++++++----------
 1 files changed, 9 insertions(+), 10 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 149f7b1..edff2cc 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4825,7 +4825,7 @@ err:
 }
 
 static void
-__nfs4_state_shutdown_net(struct net *net)
+nfs4_state_destroy_net(struct net *net)
 {
 	int i;
 	struct nfs4_client *clp = NULL;
@@ -4853,6 +4853,7 @@ __nfs4_state_shutdown_net(struct net *net)
 	kfree(nn->ownerstr_hashtbl);
 	kfree(nn->unconf_id_hashtbl);
 	kfree(nn->conf_id_hashtbl);
+	put_net(net);
 }
 
 /* initialization to perform when the nfsd service is started: */
@@ -4902,19 +4903,20 @@ out_free_laundry:
 	destroy_workqueue(laundry_wq);
 out_recovery:
 	nfsd4_client_tracking_exit(net);
-	__nfs4_state_shutdown_net(net);
-	put_net(net);
+	nfs4_state_destroy_net(net);
 	return ret;
 }
 
 /* should be called with the state lock held */
 static void
-__nfs4_state_shutdown(struct net *net)
+nfs4_state_shutdown_net(struct net *net)
 {
 	struct nfs4_delegation *dp = NULL;
 	struct list_head *pos, *next, reaplist;
+	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 
-	__nfs4_state_shutdown_net(net);
+	cancel_delayed_work_sync(&nn->laundromat_work);
+	locks_end_grace(&nn->nfsd4_manager);
 
 	INIT_LIST_HEAD(&reaplist);
 	spin_lock(&recall_lock);
@@ -4931,19 +4933,16 @@ __nfs4_state_shutdown(struct net *net)
 	}
 
 	nfsd4_client_tracking_exit(net);
-	put_net(net);
+	nfs4_state_destroy_net(net);
 }
 
 void
 nfs4_state_shutdown(void)
 {
 	struct net *net = &init_net;
-	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 
-	cancel_delayed_work_sync(&nn->laundromat_work);
+	nfs4_state_shutdown_net(net);
 	destroy_workqueue(laundry_wq);
-	locks_end_grace(&nn->nfsd4_manager);
-	__nfs4_state_shutdown(net);
 	nfsd4_destroy_callback_queue();
 }
 

