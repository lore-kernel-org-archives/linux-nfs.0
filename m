Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:40131 "EHLO relay.sw.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751894AbdJ3Oy4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 30 Oct 2017 10:54:56 -0400
From: Vasily Averin <vvs@virtuozzo.com>
Subject: [PATCH] lockd: fix lockd shutdown race with signal
To: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Jeff Layton <jlayton@poochiereds.net>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        David Jeffery <djeffery@redhat.com>
Message-ID: <f26c81c0-68c0-375d-10b7-dc3e9fd64863@virtuozzo.com>
Date: Mon, 30 Oct 2017 17:54:46 +0300
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit efda760fe95ea ("lockd: fix lockd shutdown race") is incorrect,
it removes grace 
 a) for init_net only
 b) only on stop of lockd kernel thread

If we start nfsd from another net namespace lockd_up_net() calls 
set_grace_period() that adds lockd_manager into per-netns list.
Then we stop nfsd server.
If lockd have another users it will not be destroyed and lock_manager
will not be removed from list.
If lockd had no other users then lockd kernel thread will be stopped,
but "remove" lock_manager strongly from init_net.

When nfsd in net namespace will started again we get "list_add double add" error.

Reproducer:
- do not start nfsd on host
- create new net namespace
  # unshare -n -m ; mount -t nfsd nfsd /proc/fs/nfsd
- start nfsd from newly created net namespace
  # echo 1 > /proc/fs/nfsd/threads
- stop and restart it again 
  # echo 0 > /proc/fs/nfsd/thread
  # echo 1 > /proc/fs/nfsd/thread

Result: "list_add double add" in set_grace_period()

[  414.644407] NFSD: attempt to initialize umh client tracking in a container ignored.
[  414.644533] NFSD: attempt to initialize legacy client tracking in a container ignored.
[  414.644562] NFSD: Unable to initialize client recovery tracking! (-22)
[  414.644585] NFSD: starting 90-second grace period (net ffff8df8f0243140)  <<< 1st start
[  423.788079] nfsd: last server has exited, flushing export cache           <<< stop
[  426.735772] list_add double add: new=ffff8df8f1db1310, prev=ffff8df93cac9348, next=ffff8df8f1db1310.
[  426.735833] ------------[ cut here ]------------ <<< 2nd start
[  426.735855] kernel BUG at lib/list_debug.c:31!
[  426.735876] invalid opcode: 0000 [#1] SMP
[  426.736011] CPU: 5 PID: 1423 Comm: bash Not tainted 4.14.0-rc6+ #2
[  426.736011] Hardware name: Virtuozzo KVM, BIOS 1.9.1-5.3.2.vz7.7 04/01/2014
[  426.736011] task: ffff8df8f2278040 task.stack: ffffa70b40ce4000
[  426.736011] RIP: 0010:__list_add_valid+0x66/0x70
[  426.736011] RSP: 0018:ffffa70b40ce7ce8 EFLAGS: 00010282
[  426.736011] RAX: 0000000000000058 RBX: ffff8df8f1db1310 RCX: 0000000000000000
[  426.736011] RDX: 0000000000000000 RSI: ffff8df93fd4e138 RDI: ffff8df93fd4e138
[  426.736011] RBP: ffffa70b40ce7ce8 R08: 00000000000002ba R09: 0000000000000000
[  426.736011] R10: 0000000000000010 R11: 00000000ffffffff R12: ffff8df93cac9348
[  426.736011] R13: ffff8df8f1db1310 R14: ffff8df8f0243140 R15: 0000000000000000
[  426.736011] FS:  00007f8c9389db40(0000) GS:ffff8df93fd40000(0000) knlGS:0000000000000000
[  426.736011] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  426.736011] CR2: 00007f8c936848d0 CR3: 000000007ca88003 CR4: 00000000001606e0
[  426.736011] Call Trace:
[  426.736011]  locks_start_grace+0x40/0x70 [grace]
[  426.736011]  set_grace_period+0x44/0x90 [lockd]
[  426.736011]  lockd_up+0x2b2/0x350 [lockd]
[  426.736011]  nfsd_svc+0x256/0x2b0 [nfsd]
[  426.736011]  ? write_pool_threads+0x2b0/0x2b0 [nfsd]
[  426.736011]  write_threads+0x80/0xe0 [nfsd]
[  426.736011]  ? simple_transaction_get+0xb5/0xd0
[  426.736011]  nfsctl_transaction_write+0x48/0x80 [nfsd]
[  426.736011]  __vfs_write+0x37/0x170
[  426.736011]  ? selinux_file_permission+0x105/0x120
[  426.736011]  ? security_file_permission+0x3b/0xc0
[  426.736011]  vfs_write+0xb1/0x1a0
[  426.736011]  SyS_write+0x55/0xc0

Before commit efda760fe95ea "lockd: fix lockd shutdown race" lock_manager
was removed from correct net namespace.

This patch reverts efda760fe95ea "lockd: fix lockd shutdown race"
and introduces stop_grace() function that is called in all rollback
cases and correctly removes lock_manager.

The patch still resolves the problem fixed by reverted patch:
now final final locks_end_grace() is called not before
but after stop of lockd kernel thread.

Fixes commit efda760fe95e ("lockd: fix lockd shutdown race")

Signed-off-by: Vasily Averin <vvs@virtuozzo.com>
---
 fs/lockd/svc.c | 20 +++++++++++++++-----
 1 file changed, 15 insertions(+), 5 deletions(-)

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index c1573860..d14e0f9 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -127,6 +127,16 @@ static void restart_grace(void)
 	}
 }
 
+static void stop_grace(struct net *net)
+{
+	struct lockd_net *ln = net_generic(net, lockd_net_id);
+
+	if (ln->nlmsvc_users == 0) {
+		cancel_delayed_work_sync(&ln->grace_period_end);
+		locks_end_grace(&ln->lockd_manager);
+	}
+}
+
 /*
  * This is the lockd kernel thread
  */
@@ -135,8 +145,6 @@ lockd(void *vrqstp)
 {
 	int		err = 0;
 	struct svc_rqst *rqstp = vrqstp;
-	struct net *net = &init_net;
-	struct lockd_net *ln = net_generic(net, lockd_net_id);
 
 	/* try_to_freeze() is called from svc_recv() */
 	set_freezable();
@@ -181,8 +189,6 @@ lockd(void *vrqstp)
 	if (nlmsvc_ops)
 		nlmsvc_invalidate_all();
 	nlm_shutdown_hosts();
-	cancel_delayed_work_sync(&ln->grace_period_end);
-	locks_end_grace(&ln->lockd_manager);
 	return 0;
 }
 
@@ -480,6 +486,7 @@ int lockd_up(struct net *net)
 	error = lockd_start_svc(serv);
 	if (error < 0) {
 		lockd_down_net(serv, net);
+		stop_grace(net);
 		goto err_put;
 	}
 	nlmsvc_users++;
@@ -504,8 +511,10 @@ lockd_down(struct net *net)
 	mutex_lock(&nlmsvc_mutex);
 	lockd_down_net(nlmsvc_rqst->rq_server, net);
 	if (nlmsvc_users) {
-		if (--nlmsvc_users)
+		if (--nlmsvc_users) {
+			stop_grace(net);
 			goto out;
+		}
 	} else {
 		printk(KERN_ERR "lockd_down: no users! task=%p\n",
 			nlmsvc_task);
@@ -517,6 +526,7 @@ lockd_down(struct net *net)
 		BUG();
 	}
 	kthread_stop(nlmsvc_task);
+	stop_grace(net);
 	dprintk("lockd_down: service stopped\n");
 	lockd_svc_exit_thread();
 	dprintk("lockd_down: service destroyed\n");
-- 
2.7.4

