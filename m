Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:17921 "EHLO relay.sw.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752591AbdKFNX2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 6 Nov 2017 08:23:28 -0500
From: Vasily Averin <vvs@virtuozzo.com>
Subject: [PATCH v3 02/21] lockd: added cleanup checks in exit_net hook
To: netdev@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
References: <4fdc4264-e338-6ee8-a662-7d98b45733a1@virtuozzo.com>
Message-ID: <a43dae6a-2f3f-cd72-3384-f22b28494eb0@virtuozzo.com>
Date: Mon, 6 Nov 2017 16:23:24 +0300
MIME-Version: 1.0
In-Reply-To: <4fdc4264-e338-6ee8-a662-7d98b45733a1@virtuozzo.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Vasily Averin <vvs@virtuozzo.com>
---
 fs/lockd/svc.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index 809cbcc..2a48558 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -690,6 +690,17 @@ static int lockd_init_net(struct net *net)
 
 static void lockd_exit_net(struct net *net)
 {
+	struct lockd_net *ln = net_generic(net, lockd_net_id);
+
+	WARN_ONCE(!list_empty(&ln->lockd_manager.list),
+		  "net %x %s: lockd_manager.list is not empty\n",
+		  net->ns.inum, __func__);
+	WARN_ONCE(!list_empty(&ln->nsm_handles),
+		  "net %x %s: nsm_handles list is not empty\n",
+		  net->ns.inum, __func__);
+	WARN_ONCE(delayed_work_pending(&ln->grace_period_end),
+		  "net %x %s: grace_period_end was not cancelled\n",
+		  net->ns.inum, __func__);
 }
 
 static struct pernet_operations lockd_net_ops = {
-- 
2.7.4

