Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:43805 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752040Ab3B1MJH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 28 Feb 2013 07:09:07 -0500
Subject: [PATCH] nfsd: check client tracker initialization result
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, Trond.Myklebust@netapp.com,
        linux-kernel@vger.kernel.org, devel@openvz.org
Date: Thu, 28 Feb 2013 15:09:59 +0300
Message-ID: <20130228120959.6764.17787.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Function nfsd4_client_tracking_init() can return error.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
---
 fs/nfsd/nfs4state.c |    9 ++++++++-
 1 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index f194f86..fc4b81b 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -69,6 +69,7 @@ static u64 current_sessionid = 1;
 
 /* forward declarations */
 static int check_for_locks(struct nfs4_file *filp, struct nfs4_lockowner *lowner);
+void nfs4_state_shutdown_net(struct net *net);
 
 /* Locking: */
 
@@ -4942,7 +4943,9 @@ nfs4_state_start_net(struct net *net)
 	ret = nfs4_state_create_net(net);
 	if (ret)
 		return ret;
-	nfsd4_client_tracking_init(net);
+	ret = nfsd4_client_tracking_init(net);
+	if (ret)
+		goto out_tracking;
 	nn->boot_time = get_seconds();
 	locks_start_grace(net, &nn->nfsd4_manager);
 	nn->grace_ended = false;
@@ -4950,6 +4953,10 @@ nfs4_state_start_net(struct net *net)
 	       nn->nfsd4_grace, net);
 	queue_delayed_work(laundry_wq, &nn->laundromat_work, nn->nfsd4_grace * HZ);
 	return 0;
+
+out_tracking:
+	nfs4_state_destroy_net(net);
+	return ret;
 }
 
 /* initialization to perform when the nfsd service is started: */

