Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:54679 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752994Ab3LMRcS convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Dec 2013 12:32:18 -0500
From: Weston Andros Adamson <dros@netapp.com>
To: linux-nfs list <linux-nfs@vger.kernel.org>
Subject: Recently introduced hang on reboot with auth_gss
Date: Fri, 13 Dec 2013 17:32:17 +0000
Message-ID: <9852CC37-D035-4645-ACB7-8E0B902AF3F8@netapp.com>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit c297c8b99b07f496ff69a719cfb8e8fe852832ed (SUNRPC: do not fail gss proc NULL calls with EACCES) introduces a hang on reboot if there are any mounts that use AUTH_GSS.

Due to recent changes, this can even happen when mounting sec=sys, because the non-fsid specific operations use KRB5 if possible.

To reproduce:

1) mount a server with sec=krb5 (or sec=sys if you know krb5 will work for nfs_client ops)
2) reboot
3) notice hang (output below)


I can see why it’s hanging - the reboot forced unmount is happening after gssd is killed, so the upcall will never succeed…. Any ideas on how this should be fixed?  Should we timeout after a certain number of tries? Should we detect that gssd isn’t running anymore (if this is even possible)?

-dros


BUG: soft lockup - CPU#0 stuck for 22s! [kworker/0:1:27]
Modules linked in: rpcsec_gss_krb5 nfsv4 nfs fscache crc32c_intel ppdev i2c_piix4 aesni_intel aes_x86_64 glue_helper lrw gf128mul serio_raw ablk_helper cryptd i2c_core e1000 parport_pc parport shpchp nfsd auth_rpcgss oid_registry exportfs nfs_acl lockd sunrpc autofs4 mptspi scsi_transport_spi mptscsih mptbase ata_generic floppy
irq event stamp: 279178
hardirqs last  enabled at (279177): [<ffffffff814a925c>] restore_args+0x0/0x30
hardirqs last disabled at (279178): [<ffffffff814b0a6a>] apic_timer_interrupt+0x6a/0x80
softirqs last  enabled at (279176): [<ffffffff8103f583>] __do_softirq+0x1df/0x276
softirqs last disabled at (279171): [<ffffffff8103f852>] irq_exit+0x53/0x9a
CPU: 0 PID: 27 Comm: kworker/0:1 Not tainted 3.13.0-rc3-branch-dros_testing+ #1
Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
Workqueue: rpciod rpc_async_schedule [sunrpc]
task: ffff88007b87a130 ti: ffff88007ad08000 task.ti: ffff88007ad08000
RIP: 0010:[<ffffffffa00a562d>]  [<ffffffffa00a562d>] rpcauth_refreshcred+0x17/0x15f [sunrpc]
RSP: 0018:ffff88007ad09c88  EFLAGS: 00000286
RAX: ffffffffa02ba650 RBX: ffffffff81073f47 RCX: 0000000000000007
RDX: 0000000000000007 RSI: ffff88007a885d70 RDI: ffff88007a158b40
RBP: ffff88007ad09ce8 R08: ffff88007a5ce9f8 R09: ffffffffa00993d7
R10: ffff88007a5ce7b0 R11: ffff88007a158b40 R12: ffffffffa009943d
R13: 0000000000000a81 R14: ffff88007a158bb0 R15: ffffffff814a925c
FS:  0000000000000000(0000) GS:ffff88007f200000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007f2d03056000 CR3: 0000000001a0b000 CR4: 00000000001407f0
Stack:
 ffffffffa009943d ffff88007a5ce9f8 0000000000000000 0000000000000007
 0000000000000007 ffff88007a885d70 ffff88007a158b40 ffffffffffffff10
 ffff88007a158b40 0000000000000000 ffff88007a158bb0 0000000000000a81
Call Trace:
 [<ffffffffa009943d>] ? call_refresh+0x66/0x66 [sunrpc]
 [<ffffffffa0099438>] call_refresh+0x61/0x66 [sunrpc]
 [<ffffffffa00a403b>] __rpc_execute+0xf1/0x362 [sunrpc]
 [<ffffffff81073f47>] ? trace_hardirqs_on_caller+0x145/0x1a1
 [<ffffffffa00a42d3>] rpc_async_schedule+0x27/0x32 [sunrpc]
 [<ffffffff81052974>] process_one_work+0x211/0x3a5
 [<ffffffff810528d5>] ? process_one_work+0x172/0x3a5
 [<ffffffff81052eeb>] worker_thread+0x134/0x202
 [<ffffffff81052db7>] ? rescuer_thread+0x280/0x280
 [<ffffffff81052db7>] ? rescuer_thread+0x280/0x280
 [<ffffffff810584a0>] kthread+0xc9/0xd1
 [<ffffffff810583d7>] ? __kthread_parkme+0x61/0x61
 [<ffffffff814afd6c>] ret_from_fork+0x7c/0xb0
 [<ffffffff810583d7>] ? __kthread_parkme+0x61/0x61
Code: 89 c2 41 ff d6 48 83 c4 58 5b 41 5c 41 5d 41 5e 41 5f 5d c3 0f 1f 44 00 00 55 48 89 e5 41 56 41 55 41 54 53 48 89 fb 48 83 ec 40 <4c> 8b 6f 20 4d 8b a5 90 00 00 00 4d 85 e4 0f 85 e4 00 00 00 8b