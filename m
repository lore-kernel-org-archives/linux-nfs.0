Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f41.google.com ([209.85.220.41]:39123 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751409AbaHDKbF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Aug 2014 06:31:05 -0400
Received: by mail-pa0-f41.google.com with SMTP id rd3so9808399pab.0
        for <linux-nfs@vger.kernel.org>; Mon, 04 Aug 2014 03:31:05 -0700 (PDT)
Message-ID: <53DF60DA.9000100@gmail.com>
Date: Mon, 04 Aug 2014 18:30:50 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        kinglongmee@gmail.com
Subject: [PATCH] SUNRPC: Change WARN_ON to printk for error message
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When testing nfs4.0 lock, I get WARN_ON message as below,
[  278.733391] ------------[ cut here ]------------
[  278.734496] WARNING: CPU: 0 PID: 263 at /root/linux-nfs/net/sunrpc/sched.c:692 rpc_exit_task+0x85/0x90 [sunrpc]()
[  278.736771] Modules linked in: nfsv4(OE) nfs(OE) nfsd(E) bnep bluetooth ip6t_rpfilter ip6t_REJECT xt_conntrack cfg80211 rfkill ebtable_nat ebtable_broute bridge stp llc ebtable_filter ebtables ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_security ip6table_raw ip6table_filter ip6_tables iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle iptable_security iptable_raw btrfs ppdev xfs microcode xor serio_raw libcrc32c pcspkr raid6_pq e1000 parport_pc parport i2c_piix4 i2c_core auth_rpcgss nfs_acl lockd sunrpc(OE) ata_generic pata_acpi [last unloaded: nfsd]
[  278.751462] CPU: 0 PID: 263 Comm: kworker/0:4 Tainted: G           OE 3.16.0-rc2+ #28
[  278.753364] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[  278.755710] Workqueue: rpciod rpc_async_schedule [sunrpc]
[  278.757112]  0000000000000000 00000000f6173352 ffff880072e5fd30 ffffffff816eacfa
[  278.758811]  0000000000000000 ffff880072e5fd68 ffffffff8108bf3d ffff88005997f180
[  278.760527]  ffff88003ae44830 ffffffffa001a860 ffffffffa001a860 0000000000000000
[  278.762271] Call Trace:
[  278.762802]  [<ffffffff816eacfa>] dump_stack+0x45/0x56
[  278.763906]  [<ffffffff8108bf3d>] warn_slowpath_common+0x7d/0xa0
[  278.765419]  [<ffffffffa001a860>] ? rpc_destroy_wait_queue+0x20/0x20 [sunrpc]
[  278.767243]  [<ffffffffa001a860>] ? rpc_destroy_wait_queue+0x20/0x20 [sunrpc]
[  278.768758]  [<ffffffff8108c06a>] warn_slowpath_null+0x1a/0x20
[  278.770080]  [<ffffffffa001a8e5>] rpc_exit_task+0x85/0x90 [sunrpc]
[  278.771439]  [<ffffffffa001b204>] __rpc_execute+0x94/0x420 [sunrpc]
[  278.772829]  [<ffffffffa001b5b6>] rpc_async_schedule+0x26/0x30 [sunrpc]
[  278.774276]  [<ffffffff810a7f95>] process_one_work+0x175/0x430
[  278.775573]  [<ffffffff810a866d>] worker_thread+0x11d/0x530
[  278.776824]  [<ffffffff810a8550>] ? rescuer_thread+0x300/0x300
[  278.778069]  [<ffffffff810aee18>] kthread+0xd8/0xf0
[  278.779114]  [<ffffffff810aed40>] ? insert_kthread_work+0x40/0x40
[  278.780448]  [<ffffffff816f22bc>] ret_from_fork+0x7c/0xb0
[  278.781621]  [<ffffffff810aed40>] ? insert_kthread_work+0x40/0x40
[  278.782972] ---[ end trace 3350394592832e42 ]---

task1:
  --> call_decode
    --> rpc_exit_task (-10011)
      --> nfs4_release_lockowner_done
        --> rpc_restart_call_prepare
            task->tk_action = call_start;
task2:
      --> rpc_shutdown_client
        --> rpc_killall_tasks
            rovr->tk_flags |= RPC_TASK_KILLED; (set task1 to KILLED)
task1:
    --> rpc_exit_task
        WARN_ON(RPC_ASSASSINATED(task));

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 net/sunrpc/sched.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index c0365c1..ed0f8e5 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -689,7 +689,9 @@ void rpc_exit_task(struct rpc_task *task)
 	if (task->tk_ops->rpc_call_done != NULL) {
 		task->tk_ops->rpc_call_done(task, task->tk_calldata);
 		if (task->tk_action != NULL) {
-			WARN_ON(RPC_ASSASSINATED(task));
+			if (RPC_ASSASSINATED(task))
+				printk(KERN_ERR "RPC: dead task tried to"
+					" walk away.\n");
 			/* Always release the RPC slot and buffer memory */
 			xprt_release(task);
 			rpc_reset_task_statistics(task);
-- 
1.9.3

