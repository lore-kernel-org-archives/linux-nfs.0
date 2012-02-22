Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:13646 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754801Ab2BVSoy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Feb 2012 13:44:54 -0500
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: [PATCH] SUNRPC: fix use-after-free of rpc pipes
Date: Wed, 22 Feb 2012 13:44:26 -0500
Message-Id: <1329936266-16940-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This needs to be looked at closely by someone more familiar with the
pipe code.

It fixes an issue with the current nfs_for_next branch which causes a
chain of oopses on umount every time if sufficient CONFIG_* debug
options are set.

A git-bisect shows that the problem was introduced by
commit c239d83b  SUNRPC: split SUNPRC PipeFS dentry and private pipe data creation

A typical oops starts with:

general protection fault: 0000 [#1] SMP DEBUG_PAGEALLOC
CPU 0
Modules linked in: nfs_layout_nfsv41_files nfs auth_rpcgss nfs_acl lockd ppdev parport_pc parport e1000 i2c_piix4 shpchp i2c_core sunrpc autofs4 mptspi mptscsih mptbase scsi_transport_spi floppy [last unloaded: scsi_wait_scan]

Pid: 834, comm: rpc.idmapd Not tainted 3.3.0-rc2-kitchensink+ #51 VMware, Inc. VMware Virtual Platform/440BX Desktop
Reference Platform
RIP: 0010:[<ffffffff81079979>]  [<ffffffff81079979>] __lock_acquire+0xd8/0xdd2
RSP: 0018:ffff8800367bfcb8  EFLAGS: 00010002
RAX: 6b6b6b6b6b6b6b6b RBX: ffff88003bb8a0b0 RCX: 0000000000000000
RDX: 0000000000000000 RSI: 0000000000000000 RDI: ffff88002ca779c0
RBP: ffff8800367bfd88 R08: 0000000000000002 R09: 0000000000000001
R10: 0000000000000000 R11: ffff88002ca779c0 R12: 0000000000000286
R13: ffff88002ca779c0 R14: 0000000000000002 R15: 0000000000000000
FS:  00007f7ff3dab700(0000) GS:ffff88003fa00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007f5305ae1000 CR3: 000000003ae4e000 CR4: 00000000000406f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process rpc.idmapd (pid: 834, threadinfo ffff8800367be000, task ffff88003bb8a0b0)
Stack:
0000000000000000 ffffffff81235f78 ffff8800367bfd08 ffffffff810788c4
ffff8800367bfd18 ffff880000000000 ffff880000000000 ffffffff00000000
00000000000001df ffff880000000001 ffff88003bb8a730 ffffffff81a24730
Call Trace:
[<ffffffff81235f78>] ? debug_object_activate+0x57/0x13b
[<ffffffff810788c4>] ? mark_lock+0x2d/0x233
[<ffffffff81079c40>] ? __lock_acquire+0x39f/0xdd2
[<ffffffff810788c4>] ? mark_lock+0x2d/0x233
[<ffffffff8107a775>] lock_acquire+0x102/0x12f
[<ffffffff8104f3a5>] ? remove_wait_queue+0x1d/0x3e
[<ffffffff81434d53>] ? __mutex_lock_common+0x37b/0x3af
[<ffffffff81436cb6>] _raw_spin_lock_irqsave+0x58/0x6a
[<ffffffff8104f3a5>] ? remove_wait_queue+0x1d/0x3e
[<ffffffff8111f4b2>] ? file_free_rcu+0x35/0x35
[<ffffffff8104f3a5>] remove_wait_queue+0x1d/0x3e
[<ffffffff81153739>] ep_unregister_pollwait+0x30/0x51
[<ffffffff8115379b>] ep_remove+0x25/0x9f
[<ffffffff81154cc4>] sys_epoll_ctl+0x58b/0x6cb
[<ffffffff8143e415>] ? sysret_check+0x22/0x5d
[<ffffffff8109a75a>] ? __audit_syscall_entry+0x121/0x14d [<ffffffff8123084e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[<ffffffff8143e3e9>] system_call_fastpath+0x16/0x1b
Code: 8d 58 ff ff ff 44 89 8d 48 ff ff ff 4c 89 ef e8 f6 fa ff ff 48 8b 8d 58 ff ff ff 48 85 c0 44 8b 8d 48 ff ff ff
0f 84 99 0c 00 00 <3e> ff 80 98 01 00 00 8b 93 78 06 00 00 83 3d 87 83 b8 00 00 89
RIP  [<ffffffff81079979>] __lock_acquire+0xd8/0xdd2 RSP <ffff8800367bfcb8>
---[ end trace ffe7d1c1af2c62f6 ]---
BUG: sleeping function called from invalid context at /home/iisaman/projects/pnfs-file/src/linux-pnfs/kernel/rwsem.c
:21
in_atomic(): 1, irqs_disabled(): 1, pid: 834, name: rpc.idmapd
INFO: lockdep is turned off.
irq event stamp: 4308
hardirqs last  enabled at (4307): [<ffffffff81434d53>] __mutex_lock_common+0x37b/0x3af
hardirqs last disabled at (4308): [<ffffffff81436c87>] _raw_spin_lock_irqsave+0x29/0x6a
softirqs last  enabled at (3992): [<ffffffff810378e3>] __do_softirq+0x1e6/0x205
softirqs last disabled at (3783): [<ffffffff8143f92c>] call_softirq+0x1c/0x30
Pid: 834, comm: rpc.idmapd Tainted: G      D      3.3.0-rc2-kitchensink+ #51
Call Trace:
[<ffffffff81059bb7>] __might_sleep+0x107/0x10c
[<ffffffff81435499>] down_read+0x24/0x61
[<ffffffff810433e5>] exit_signals+0x26/0x12c
[<ffffffff81053fdc>] ? blocking_notifier_call_chain+0x14/0x16
[<ffffffff81034e53>] do_exit+0x118/0x7d9
[<ffffffff81031cda>] ? kmsg_dump+0x126/0x144
[<ffffffff81031c3c>] ? kmsg_dump+0x88/0x144
[<ffffffff81438422>] oops_end+0xc0/0xc8
[<ffffffff81004d96>] die+0x5a/0x63
[<ffffffff81438272>] do_general_protection+0x12a/0x132
[<ffffffff81437764>] ? restore_args+0x30/0x30
[<ffffffff81437915>] general_protection+0x25/0x30
[<ffffffff81079979>] ? __lock_acquire+0xd8/0xdd2
[<ffffffff81235f78>] ? debug_object_activate+0x57/0x13b
[<ffffffff810788c4>] ? mark_lock+0x2d/0x233
[<ffffffff81079c40>] ? __lock_acquire+0x39f/0xdd2
[<ffffffff810788c4>] ? mark_lock+0x2d/0x233
[<ffffffff8107a775>] lock_acquire+0x102/0x12f
[<ffffffff8104f3a5>] ? remove_wait_queue+0x1d/0x3e
[<ffffffff81434d53>] ? __mutex_lock_common+0x37b/0x3af
[<ffffffff81436cb6>] _raw_spin_lock_irqsave+0x58/0x6a
[<ffffffff8104f3a5>] ? remove_wait_queue+0x1d/0x3e
[<ffffffff8111f4b2>] ? file_free_rcu+0x35/0x35
[<ffffffff8104f3a5>] remove_wait_queue+0x1d/0x3e
[<ffffffff81153739>] ep_unregister_pollwait+0x30/0x51
[<ffffffff8115379b>] ep_remove+0x25/0x9f
[<ffffffff81154cc4>] sys_epoll_ctl+0x58b/0x6cb
[<ffffffff8143e415>] ? sysret_check+0x22/0x5d
[<ffffffff8109a75a>] ? __audit_syscall_entry+0x121/0x14d
[<ffffffff8123084e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[<ffffffff8143e3e9>] system_call_fastpath+0x16/0x1b
note: rpc.idmapd[834] exited with preempt_count 1
BUG: scheduling while atomic: rpc.idmapd/834/0x10000002
INFO: lockdep is turned off.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/blocklayout/blocklayout.c |    1 -
 fs/nfs/idmap.c                   |    1 -
 net/sunrpc/auth_gss/auth_gss.c   |    2 --
 net/sunrpc/rpc_pipe.c            |    1 +
 4 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 783ebd5..26fcbd1 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -1134,7 +1134,6 @@ static void nfs4blocklayout_net_exit(struct net *net)
 	struct nfs_net *nn = net_generic(net, nfs_net_id);
 
 	nfs4blocklayout_unregister_net(net, nn->bl_device_pipe);
-	rpc_destroy_pipe_data(nn->bl_device_pipe);
 	nn->bl_device_pipe = NULL;
 }
 
diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
index b5c6d8e..384fbed 100644
--- a/fs/nfs/idmap.c
+++ b/fs/nfs/idmap.c
@@ -508,7 +508,6 @@ nfs_idmap_delete(struct nfs_client *clp)
 	if (!idmap)
 		return;
 	nfs_idmap_unregister(clp, idmap->idmap_pipe);
-	rpc_destroy_pipe_data(idmap->idmap_pipe);
 	clp->cl_idmap = NULL;
 	idmap_free_hashtable(&idmap->idmap_user_hash);
 	idmap_free_hashtable(&idmap->idmap_group_hash);
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index cb2e564..6be27ec 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -908,8 +908,6 @@ static void
 gss_free(struct gss_auth *gss_auth)
 {
 	gss_pipes_dentries_destroy_net(gss_auth->client, &gss_auth->rpc_auth);
-	rpc_destroy_pipe_data(gss_auth->pipe[0]);
-	rpc_destroy_pipe_data(gss_auth->pipe[1]);
 	gss_mech_put(gss_auth->mech);
 
 	kfree(gss_auth);
diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index 6873c9b..1f58c92 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -191,6 +191,7 @@ static void
 rpc_i_callback(struct rcu_head *head)
 {
 	struct inode *inode = container_of(head, struct inode, i_rcu);
+	rpc_destroy_pipe_data(RPC_I(inode)->pipe);
 	kmem_cache_free(rpc_inode_cachep, RPC_I(inode));
 }
 
-- 
1.7.2.1

