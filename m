Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:57152 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750941AbdEHWRs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 8 May 2017 18:17:48 -0400
Date: Mon, 8 May 2017 18:17:47 -0400
To: linux-nfs@vger.kernel.org
Subject: [PATCH] lockd: fix lockd shutdown race
Message-ID: <20170508221747.GA6289@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

As reported by David Jeffery: "a signal was sent to lockd while lockd
was shutting down from a request to stop nfs.  The signal causes lockd
to call restart_grace() which puts the lockd_net structure on the grace
list.  If this signal is received at the wrong time, it will occur after
lockd_down_net() has called locks_end_grace() but before
lockd_down_net() stops the lockd thread.  This leads to lockd putting
the lockd_net structure back on the grace list, then exiting without
anything removing it from the list."

So, perform the final locks_end_grace() from the the lockd thread; this
ensures it's serialized with respect to restart_grace().

Reported-by: David Jeffery <djeffery@redhat.com>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/lockd/svc.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index e7c8b9c76e48..5d481e8a1b5d 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -132,6 +132,8 @@ lockd(void *vrqstp)
 {
 	int		err = 0;
 	struct svc_rqst *rqstp = vrqstp;
+	struct net *net = &init_net;
+	struct lockd_net *ln = net_generic(net, lockd_net_id);
 
 	/* try_to_freeze() is called from svc_recv() */
 	set_freezable();
@@ -176,6 +178,8 @@ lockd(void *vrqstp)
 	if (nlmsvc_ops)
 		nlmsvc_invalidate_all();
 	nlm_shutdown_hosts();
+	cancel_delayed_work_sync(&ln->grace_period_end);
+	locks_end_grace(&ln->lockd_manager);
 	return 0;
 }
 
@@ -270,8 +274,6 @@ static void lockd_down_net(struct svc_serv *serv, struct net *net)
 	if (ln->nlmsvc_users) {
 		if (--ln->nlmsvc_users == 0) {
 			nlm_shutdown_hosts_net(net);
-			cancel_delayed_work_sync(&ln->grace_period_end);
-			locks_end_grace(&ln->lockd_manager);
 			svc_shutdown_net(serv, net);
 			dprintk("lockd_down_net: per-net data destroyed; net=%p\n", net);
 		}
-- 
2.9.3

