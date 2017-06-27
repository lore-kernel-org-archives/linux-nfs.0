Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from scorn.kernelslacker.org ([45.56.101.199]:58754 "EHLO
        scorn.kernelslacker.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751716AbdF0SAv (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 27 Jun 2017 14:00:51 -0400
Date: Tue, 27 Jun 2017 14:00:45 -0400
From: Dave Jones <davej@codemonkey.org.uk>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs@vger.kernel.org,
        Linux Kernel <linux-kernel@vger.kernel.org>
Subject: 4.12rc7 oops in nfs4_exchange_id_done
Message-ID: <20170627180045.haj3szprsx2vzf6g@codemonkey.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NFS: Registering the id_resolver key type
Key type id_resolver registered
Key type id_legacy registered
NFS: nfs4_discover_server_trunking unhandled error -512. Exiting with error EIO
NFS: nfs4_discover_server_trunking unhandled error -512. Exiting with error EIO
Oops: 0000 [#1] SMP
CPU: 1 PID: 140 Comm: kworker/1:2 Not tainted 4.12.0-rc7-think+ #1 
Workqueue: rpciod rpc_async_schedule [sunrpc]
task: ffff8804ffeb9c00 task.stack: ffffc9000062c000
RIP: 0010:nfs4_exchange_id_done+0x22e/0x5b0 [nfsv4]
RSP: 0018:ffffc9000062fd40 EFLAGS: 00010246
RAX: ffffc90000d83948 RBX: ffff8804ef00f240 RCX: 0000000000000002
RDX: 0000000000000001 RSI: 00000000ffffffff RDI: 0000000000000000
RBP: ffffc9000062fd78 R08: ffff8804ef6c0b28 R09: 380c70ed00000000
R10: ffffc9000062fdb0 R11: ffff8804ffeb9c00 R12: 0000000000000000
R13: ffffffffa0021620 R14: ffff8804ef0f39c8 R15: ffff8804f88453d8
FS:  0000000000000000(0000) GS:ffff88050a000000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: ffffc90000d83948 CR3: 0000000502fff000 CR4: 00000000001406e0
Call Trace:
 ? rpc_destroy_wait_queue+0x20/0x20 [sunrpc]
 ? rpc_destroy_wait_queue+0x20/0x20 [sunrpc]
 ? rpc_destroy_wait_queue+0x20/0x20 [sunrpc]
 rpc_exit_task+0x2e/0x80 [sunrpc]
 __rpc_execute+0xb4/0x5b0 [sunrpc]
 ? process_one_work+0x1c2/0x680
 rpc_async_schedule+0x12/0x20 [sunrpc]
 process_one_work+0x24d/0x680
 worker_thread+0x4e/0x3b0
 kthread+0x117/0x150
 ? process_one_work+0x680/0x680
 ? kthread_create_on_node+0x70/0x70
 ret_from_fork+0x27/0x40
Code: b0 03 00 00 e8 84 3d f8 e0 49 c7 87 b0 03 00 00 00 00 00 00 49 8b 46 18 49 89 87 b0 03 00 00 49 c7 46 18 00 00 00 00 49 8b 46 58 <48> 8b 00 49 89 87 20 01 00 00 e9 23 fe ff ff 48 83 c6 04 48 83 
RIP: nfs4_exchange_id_done+0x22e/0x5b0 [nfsv4] RSP: ffffc9000062fd40
CR2: ffffc90000d83948
NMI watchdog: BUG: soft lockup - CPU#2 stuck for 23s! [systemd:1]
irq event stamp: 9668834
hardirqs last  enabled at (9668833): [<ffffffff81a318dd>] restore_regs_and_iret+0x0/0x1d
hardirqs last disabled at (9668834): [<ffffffff81a28610>] __schedule+0xd0/0x9b0
softirqs last  enabled at (9668832): [<ffffffff81a35735>] __do_softirq+0x3a5/0x4d3
softirqs last disabled at (9668709): [<ffffffff8108c6e3>] irq_exit+0xc3/0xd0
CPU: 2 PID: 1 Comm: systemd Tainted: G      D         4.12.0-rc7-think+ #1 
task: ffff880506240040 task.stack: ffffc90000010000
RIP: 0010:smp_call_function_single+0xd4/0x100
RSP: 0018:ffffc90000013c68 EFLAGS: 00000202
  ORIG_RAX: ffffffffffffff10
RAX: 0000000000000000 RBX: 0000000000000002 RCX: 0000000000000830
RDX: 0000000000000001 RSI: 00000000000000fb RDI: 0000000400000000
RBP: ffffc90000013c90 R08: fffffffffffffff8 R09: 0000000000000006
R10: ffffc90000013d00 R11: 0000000000000000 R12: 0000000000000001
R13: ffff8804f1a93be8 R14: 0000000000000002 R15: ffffc90000013cf8
FS:  00007fb976424940(0000) GS:ffff88050a200000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 000055d89342ed90 CR3: 0000000502fff000 CR4: 00000000001406e0
Call Trace:
 ? do_flush_tlb_all+0xd0/0xd0
 smp_call_function_many+0x211/0x260
 ? do_flush_tlb_all+0xd0/0xd0
 native_flush_tlb_others+0x77/0x280
 ? vma_gap_callbacks_rotate+0x1e/0x30
 flush_tlb_mm_range+0x9e/0x250
 copy_process.part.42+0x11ea/0x1dd0
 _do_fork+0xeb/0x710
 ? vtime_account_user+0x73/0x90
 SyS_clone+0x19/0x20
 do_syscall_64+0x66/0x190
 entry_SYSCALL64_slow_path+0x25/0x25
RIP: 0033:0x7fb9749ea34b
RSP: 002b:00007ffddd8807f0 EFLAGS: 00000246
  ORIG_RAX: 0000000000000038
RAX: ffffffffffffffda RBX: 00007ffddd8807f0 RCX: 00007fb9749ea34b
RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000001200011
RBP: 00007ffddd880840 R08: 00007fb976424940 R09: 000055d8931a27d7
R10: 00007fb976424c10 R11: 0000000000000246 R12: 0000000000000000
R13: 0000000000000020 R14: 0000000000000000 R15: 0000000000000000
Code: 6d ee 7e 48 8b 4d f8 65 48 33 0c 25 28 00 00 00 75 3d c9 c3 48 89 d1 48 89 f2 48 8d 75 d8 e8 24 fe ff ff 8b 55 f0 83 e2 01 74 0a <f3> 90 8b 55 f0 83 e2 01 75 f6 eb c5 8b 05 62 25 08 02 85 c0 75 

