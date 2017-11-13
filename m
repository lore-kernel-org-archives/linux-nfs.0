Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:25763 "EHLO relay.sw.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751432AbdKMEZu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 12 Nov 2017 23:25:50 -0500
From: Vasily Averin <vvs@virtuozzo.com>
Subject: [PATCH] lockd: fix "list_add double add" caused by legacy signal
 interface
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@kernel.org>, linux-nfs@vger.kernel.org
References: <20171109154444.GG8773@fieldses.org>
Message-ID: <75f4472c-b9e2-6353-3af0-c4939ecfca41@virtuozzo.com>
Date: Mon, 13 Nov 2017 07:25:40 +0300
MIME-Version: 1.0
In-Reply-To: <20171109154444.GG8773@fieldses.org>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

restart_grace() uses hardcoded init_net.
It can cause to "list_add double add" in following scenario:

1) nfsd and lockd was started in several net namespaces
2) nfsd in init_net was stopped (lockd was not stopped because
 it have users from another net namespaces)
3) lockd got signal, called restart_grace() -> set_grace_period()
 and enabled lock_manager in hardcoded init_net.
4) nfsd in init_net is started again,
 its lockd_up() calls set_grace_period() and tries to add
 lock_manager into init_net 2nd time.

Jeff Layton suggest:
"Make it safe to call locks_start_grace multiple times on the same
lock_manager. If it's already on the global grace_list, then don't try
to add it again.

With this change, we also need to ensure that the nfsd4 lock manager
initializes the list before we call locks_start_grace. While we're at
it, move the rest of the nfsd_net initialization into
nfs4_state_create_net. I see no reason to have it spread over two
functions like it is today."

Suggested patch was updated to generate warning in described situation.

Suggested-by: Jeff Layton <jlayton@redhat.com>
Signed-off-by: Vasily Averin <vvs@virtuozzo.com>
---
 fs/nfs_common/grace.c | 6 +++++-
 fs/nfsd/nfs4state.c   | 7 ++++---
 2 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/fs/nfs_common/grace.c b/fs/nfs_common/grace.c
index bd3e2d3..5be08f0 100644
--- a/fs/nfs_common/grace.c
+++ b/fs/nfs_common/grace.c
@@ -30,7 +30,11 @@ locks_start_grace(struct net *net, struct lock_manager *lm)
 	struct list_head *grace_list = net_generic(net, grace_net_id);
 
 	spin_lock(&grace_lock);
-	list_add(&lm->list, grace_list);
+	if (list_empty(&lm->list))
+		list_add(&lm->list, grace_list);
+	else
+		WARN(1, "double list_add attempt detected in net %x %s\n",
+		     net->ns.inum, (net == &init_net) ? "(init_net)" : "");
 	spin_unlock(&grace_lock);
 }
 EXPORT_SYMBOL_GPL(locks_start_grace);
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 7345143..b29b5a1 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -7103,6 +7103,10 @@ static int nfs4_state_create_net(struct net *net)
 		INIT_LIST_HEAD(&nn->sessionid_hashtbl[i]);
 	nn->conf_name_tree = RB_ROOT;
 	nn->unconf_name_tree = RB_ROOT;
+	nn->boot_time = get_seconds();
+	nn->grace_ended = false;
+	nn->nfsd4_manager.block_opens = true;
+	INIT_LIST_HEAD(&nn->nfsd4_manager.list);
 	INIT_LIST_HEAD(&nn->client_lru);
 	INIT_LIST_HEAD(&nn->close_lru);
 	INIT_LIST_HEAD(&nn->del_recall_lru);
@@ -7160,9 +7164,6 @@ nfs4_state_start_net(struct net *net)
 	ret = nfs4_state_create_net(net);
 	if (ret)
 		return ret;
-	nn->boot_time = get_seconds();
-	nn->grace_ended = false;
-	nn->nfsd4_manager.block_opens = true;
 	locks_start_grace(net, &nn->nfsd4_manager);
 	nfsd4_client_tracking_init(net);
 	printk(KERN_INFO "NFSD: starting %ld-second grace period (net %x)\n",
-- 
2.7.4

