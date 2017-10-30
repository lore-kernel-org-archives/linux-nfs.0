Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:35170 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752636AbdJ3S3f (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 30 Oct 2017 14:29:35 -0400
From: Jeff Layton <jlayton@kernel.org>
To: Vasily Averin <vvs@virtuozzo.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: [PATCH] grace: only add lock_manager to grace_list if it's not already there
Date: Mon, 30 Oct 2017 14:29:32 -0400
Message-Id: <20171030182932.3282-1-jlayton@kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Jeff Layton <jlayton@redhat.com>

Vasily reported:

If we start nfsd from another net namespace lockd_up_net() calls
set_grace_period() that adds lockd_manager into per-netns list.
Then we stop nfsd server.
If lockd have another users it will not be destroyed and lock_manager
will not be removed from list.
If lockd had no other users then lockd kernel thread will be stopped,
but "remove" lock_manager strongly from init_net.

When nfsd in net namespace will started again we get "list_add double
add" error.

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

Make it safe to call locks_start_grace multiple times on the same
lock_manager. If it's already on the global grace_list, then don't try
to add it again.

With this change, we also need to ensure that the nfsd4 lock manager
initializes the list before we call locks_start_grace. While we're at
it, move the rest of the nfsd_net initialization into
nfs4_state_create_net. I see no reason to have it spread over two
functions like it is today.

Reported-by: Vasily Averin <vvs@virtuozzo.com>
Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
Vasily, would this patch fix the panic you're seeing? We may still
need to do something saner here, but this seems like it should at
least prevent a double list_add.

 fs/nfs_common/grace.c | 3 ++-
 fs/nfsd/nfs4state.c   | 7 ++++---
 2 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/fs/nfs_common/grace.c b/fs/nfs_common/grace.c
index 420d3a0ab258..874ff25e12ac 100644
--- a/fs/nfs_common/grace.c
+++ b/fs/nfs_common/grace.c
@@ -30,7 +30,8 @@ locks_start_grace(struct net *net, struct lock_manager *lm)
 	struct list_head *grace_list = net_generic(net, grace_net_id);
 
 	spin_lock(&grace_lock);
-	list_add(&lm->list, grace_list);
+	if (list_empty(&lm->list))
+		list_add(&lm->list, grace_list);
 	spin_unlock(&grace_lock);
 }
 EXPORT_SYMBOL_GPL(locks_start_grace);
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 0c04f81aa63b..4aa78bd6f0bb 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -6944,6 +6944,10 @@ static int nfs4_state_create_net(struct net *net)
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
@@ -7001,9 +7005,6 @@ nfs4_state_start_net(struct net *net)
 	ret = nfs4_state_create_net(net);
 	if (ret)
 		return ret;
-	nn->boot_time = get_seconds();
-	nn->grace_ended = false;
-	nn->nfsd4_manager.block_opens = true;
 	locks_start_grace(net, &nn->nfsd4_manager);
 	nfsd4_client_tracking_init(net);
 	printk(KERN_INFO "NFSD: starting %ld-second grace period (net %p)\n",
-- 
2.13.6

