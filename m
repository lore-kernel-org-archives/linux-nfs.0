Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:47446 "EHLO relay.sw.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751290AbdKCSzn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 3 Nov 2017 14:55:43 -0400
From: Vasily Averin <vvs@virtuozzo.com>
Subject: [PATCH v2] lockd: added cleanup checks in exit_net hook
To: linux-nfs@vger.kernel.org,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>
Message-ID: <05af9114-e36b-996e-1822-9d7da06e0140@virtuozzo.com>
Date: Fri, 3 Nov 2017 21:55:40 +0300
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Patch generates warnings if exit_net hook detects that 
structures initialized in init_net hook are still in use. 

[ 9313.047796] NFSD: starting 90-second grace period (net ffff880e307fe240)
[ 9317.257203] nfsd: last server has exited, flushing export cache
[ 9320.059256] net ffff880e307fe240 exit: lockd_manager.list is not empty
[ 9320.060434] WARNING: CPU: 5 PID: 1556 at fs/lockd/svc.c:682 lockd_exit_net+0x5c/0x90 [lockd]
...
[ 9320.077346] net ffff880e307fe240 exit: grace_period_end was not canceled
[ 9320.078494] WARNING: CPU: 5 PID: 1556 at fs/lockd/svc.c:686 lockd_exit_net+0x88/0x90 [lockd]

v2: net pointer was added to output
Signed-off-by: Vasily Averin <vvs@virtuozzo.com>
---
 fs/lockd/svc.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index 809cbcc..2f28850 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -690,6 +690,14 @@ static int lockd_init_net(struct net *net)
 
 static void lockd_exit_net(struct net *net)
 {
+	struct lockd_net *ln = net_generic(net, lockd_net_id);
+
+	WARN(!list_empty(&ln->lockd_manager.list),
+	     "net %p exit: lockd_manager.list is not empty\n", net);
+	WARN(!list_empty(&ln->nsm_handles),
+	     "net %p exit: nsm_handles list is not empty\n", net);
+	WARN(delayed_work_pending(&ln->grace_period_end),
+	     "net %p exit: grace_period_end was not canceled\n", net);
 }
 
 static struct pernet_operations lockd_net_ops = {
-- 
2.7.4

