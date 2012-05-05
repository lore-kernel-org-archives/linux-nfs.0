Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:2664 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757574Ab2EERYs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 5 May 2012 13:24:48 -0400
Subject: [PATCH RFC 11/13] LockD: manage grace list per network namespace
To: bfields@fieldses.org, Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, devel@openvz.org
Date: Sat, 05 May 2012 21:22:51 +0400
Message-ID: <20120505172251.11559.24422.stgit@localhost.localdomain>
In-Reply-To: <20120505170722.11559.74503.stgit@localhost.localdomain>
References: <20120505170722.11559.74503.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
---
 fs/lockd/grace.c |   14 +++++++++++---
 fs/lockd/netns.h |    1 +
 fs/lockd/svc.c   |    1 +
 3 files changed, 13 insertions(+), 3 deletions(-)

diff --git a/fs/lockd/grace.c b/fs/lockd/grace.c
index 183cc1f..8dbaff7 100644
--- a/fs/lockd/grace.c
+++ b/fs/lockd/grace.c
@@ -4,8 +4,10 @@
 
 #include <linux/module.h>
 #include <linux/lockd/bind.h>
+#include <net/net_namespace.h>
+
+#include "netns.h"
 
-static LIST_HEAD(grace_list);
 static DEFINE_SPINLOCK(grace_lock);
 
 /**
@@ -21,8 +23,11 @@ static DEFINE_SPINLOCK(grace_lock);
  */
 void locks_start_grace(struct lock_manager *lm)
 {
+	struct net *net = &init_net;
+	struct lockd_net *ln = net_generic(net, lockd_net_id);
+
 	spin_lock(&grace_lock);
-	list_add(&lm->list, &grace_list);
+	list_add(&lm->list, &ln->grace_list);
 	spin_unlock(&grace_lock);
 }
 EXPORT_SYMBOL_GPL(locks_start_grace);
@@ -54,6 +59,9 @@ EXPORT_SYMBOL_GPL(locks_end_grace);
  */
 int locks_in_grace(void)
 {
-	return !list_empty(&grace_list);
+	struct net *net = &init_net;
+	struct lockd_net *ln = net_generic(net, lockd_net_id);
+
+	return !list_empty(&ln->grace_list);
 }
 EXPORT_SYMBOL_GPL(locks_in_grace);
diff --git a/fs/lockd/netns.h b/fs/lockd/netns.h
index e78650c..4eee248 100644
--- a/fs/lockd/netns.h
+++ b/fs/lockd/netns.h
@@ -11,6 +11,7 @@ struct lockd_net {
 
 	struct delayed_work grace_period_end;
 	struct lock_manager lockd_manager;
+	struct list_head grace_list;
 };
 
 extern int lockd_net_id;
diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index a9c436b..834dfe2 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -596,6 +596,7 @@ static int lockd_init_net(struct net *net)
 	struct lockd_net *ln = net_generic(net, lockd_net_id);
 
 	INIT_DELAYED_WORK(&ln->grace_period_end, grace_ender);
+	INIT_LIST_HEAD(&ln->grace_list);
 	return 0;
 }
 

