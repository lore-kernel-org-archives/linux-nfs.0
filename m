Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:14535 "EHLO relay.sw.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752793AbdKFNqI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 6 Nov 2017 08:46:08 -0500
From: Vasily Averin <vvs@virtuozzo.com>
Subject: [PATCH] nfsd: use nfs->ns.inum as net ID
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Cc: Jeff Layton <jlayton@poochiereds.net>,
        "J. Bruce Fields" <bfields@fieldses.org>
Message-ID: <0ae4cdbb-46e1-1795-152f-0c3048ba2529@virtuozzo.com>
Date: Mon, 6 Nov 2017 16:46:04 +0300
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Publishing of net pointer is not safe,
let's use nfs->ns.inum instead

Signed-off-by: Vasily Averin <vvs@virtuozzo.com>
---
 fs/nfsd/nfs4state.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 0c04f81..e0bb0c6 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -7006,8 +7006,8 @@ nfs4_state_start_net(struct net *net)
 	nn->nfsd4_manager.block_opens = true;
 	locks_start_grace(net, &nn->nfsd4_manager);
 	nfsd4_client_tracking_init(net);
-	printk(KERN_INFO "NFSD: starting %ld-second grace period (net %p)\n",
-	       nn->nfsd4_grace, net);
+	printk(KERN_INFO "NFSD: starting %ld-second grace period (net %x)\n",
+	       nn->nfsd4_grace, net->ns.inum);
 	queue_delayed_work(laundry_wq, &nn->laundromat_work, nn->nfsd4_grace * HZ);
 	return 0;
 }
-- 
2.7.4

