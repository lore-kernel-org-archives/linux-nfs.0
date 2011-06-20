Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:58233 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755405Ab1FTSBf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Jun 2011 14:01:35 -0400
Received: from [192.168.100.195] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id p5KI1YQb018828
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Mon, 20 Jun 2011 11:01:34 -0700
Message-ID: <4DFF8AFE.10900@candelatech.com>
Date: Mon, 20 Jun 2011 11:01:34 -0700
From: Ben Greear <greearb@candelatech.com>
To: linux-nfs@vger.kernel.org
Subject: Kernel panic in 2.6.38.8 plus nfs-binding patches.
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

We have a test case that creates 300 mounts (150 reading, 150 writing).
We stop/start the NFS services on the nfs server every 5
minutes or so.  Every 15 minutes or so the NFS readers/writers are
stopped, mounts are unmounted, remounted, and nfs readers/writers started
again.

This kernel is using the nfs-source-ip-binding patches I posted
a week or two ago.

This ran about 13 hours before creating the following panic.

I'd be grateful for any hints on how to debug this further.


Jun 18 11:08:35 localhost kernel: nfs: server 10.1.1.1 OK
Jun 18 11:08:35 localhost kernel: nfs: server 10.1.1.1 OK
general protection fault: 0000 [#1] PREEMPT SMP
last sysfs file: /sys/devices/virtual/net/eth2#149/flags
CPU 2
Modules linked in: 8021q garp xt_TPROXY nf_tproxy_core xt_socket nf_defrag_ipv6 xt_connlimit macvlan wanlink(P) fuse ip6table_filter ip6_tables pktgen 
ebtable_nat ebtables iscsi_tcp libiscsi_tcp libiscsi scsi_transport_iscsi stp llc w83793 w83627hf hwmon_vid coretemp ipmi_msghandler nfs lockd fscache nfs_acl 
auth_rpcgss sunrpc ipv6 kvm_intel kvm uinput iTCO_wdt iTCO_vendor_support i5k_amb ioatdma i5000_edac i2c_i801 edac_core pcspkr serio_raw e1000e dca shpchp 
microcode floppy radeon ttm drm_kms_helper drm hwmon i2c_algo_bit i2c_core [last unloaded: ipt_addrtype]

Pid: 11584, comm: kworker/2:0 Tainted: P            2.6.38.8+ #17 Supermicro X7DBU/X7DBU
Jun 18 11:14:39 RIP: 0010:[<ffffffffa024f5f1>]  [<ffffffffa024f5f1>] rpcb_getport_done+0x65/0xab [sunrpc]
RSP: 0000:ffff8800af587d80  EFLAGS: 00010202
localhost kernelRAX: dead4eadffffffff RBX: 0000000000000000 RCX: 0000000000000088
RDX: ffff8800af587ce0 RSI: 0000000000000801 RDI: ffff8800c64e7700
: general protecRBP: ffff8800af587da0 R08: ffff8800c64e7600 R09: ffff8800af587e20
R10: ffff8800cfc8f640 R11: ffff8800cfc93c90 R12: ffff8800c64e7600
tion fault: 0000R13: ffff8800c64e7700 R14: ffff8800bef29700 R15: 0000000000000000
FS:  0000000000000000(0000) GS:ffff8800cfc80000(0000) knlGS:0000000000000000
  [#1] PREEMPT SMCS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000000000b14de0 CR3: 00000000b256e000 CR4: 00000000000006e0
P
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process kworker/2:0 (pid: 11584, threadinfo ffff8800af586000, task ffff880020462c40)
Stack:
  ffff8800bef29700 ffff8800bef29770 0000000000000001 0000000000000000
  ffff8800af587dc0 ffffffffa02480c2 0000000000000000 ffff8800bef29700
  ffff8800af587e10 ffffffffa02486aa ffff8800af587df0 ffffffff8103fde4
Call Trace:
  [<ffffffffa02480c2>] rpc_exit_task+0x27/0x55 [sunrpc]
  [<ffffffffa02486aa>] __rpc_execute+0x78/0x24b [sunrpc]
  [<ffffffff8103fde4>] ? get_parent_ip+0x11/0x42
  [<ffffffffa02488be>] ? rpc_async_schedule+0x0/0x12 [sunrpc]
  [<ffffffffa02488ce>] rpc_async_schedule+0x10/0x12 [sunrpc]
  [<ffffffff810571c9>] process_one_work+0x1ac/0x28a
  [<ffffffff810591a3>] worker_thread+0x136/0x255
  [<ffffffff8105906d>] ? worker_thread+0x0/0x255
  [<ffffffff8105c3bf>] kthread+0x7d/0x85
  [<ffffffff8100b8e4>] kernel_thread_helper+0x4/0x10
  [<ffffffff8105c342>] ? kthread+0x0/0x85
  [<ffffffff8100b8e0>] ? kernel_thread_helper+0x0/0x10
Code: 31 f6 4c 89 ef ff 50 20 eb 32 8b 76 14 49 8b 45 08 66 85 f6 75 0f 31 f6 4c 89 ef bb f3 ff ff ff ff 50 20 eb 17 0f b7 f6 4c 89 ef <ff> 50 20 f0 41 0f ba ad 
a8 04 00 00 04 19 c0 31 db f6 05 6f 32
RIP  [<ffffffffa024f5f1>] rpcb_getport_done+0x65/0xab [sunrpc]
  RSP <ffff8800af587d80>
---[ end trace 17a74221efb85e47 ]---



Reading symbols from /home/greearb/kernel/2.6/linux-2.6.38.x64-sym/net/sunrpc/sunrpc.ko...done.
(gdb) l *(rpcb_getport_done+0x65)
0xe615 is in rpcb_getport_done (/home/greearb/git/linux-2.6.dev.38.y/net/sunrpc/rpcb_clnt.c:700).
695			/* Requested RPC service wasn't registered on remote host */
696			xprt->ops->set_port(xprt, 0);
697			status = -EACCES;
698		} else {
699			/* Succeeded */
700			xprt->ops->set_port(xprt, map->r_port);
701			xprt_set_bound(xprt);
702			status = 0;
703		}
704	
(gdb)



BUG: unable to handle kernel paging request at fffffffffffffff8
IP: [<ffffffff8105bff0>] kthread_data+0xb/0x11
PGD 1805067 PUD 1806067 PMD 0
Oops: 0000 [#2] PREEMPT SMP
last sysfs file: /sys/devices/virtual/net/eth2#148/flags
CPU 2
Modules linked in: 8021q garp xt_TPROXY nf_tproxy_core xt_socket nf_defrag_ipv6 xt_connlimit macvlan wanlink(P) fuse ip6table_filter ip6_tables pktgen 
ebtable_nat ebtables iscsi_tcp libiscsi_tcp libiscsi scsi_transport_iscsi stp llc w83793 w83627hf hwmon_vid coretemp ipmi_msghandler nfs lockd fscache nfs_acl 
auth_rpcgss sunrpc ipv6 kvm_intel kvm uinput iTCO_wdt iTCO_vendor_support i5k_amb ioatdma i5000_edac i2c_i801 edac_core pcspkr serio_raw e1000e dca shpchp 
microcode floppy radeon ttm drm_kms_helper drm hwmon i2c_algo_bit i2c_core [last unloaded: ipt_addrtype]

Pid: 11584, comm: kworker/2:0 Tainted: P      D     2.6.38.8+ #17 Supermicro X7DBU/X7DBU
RIP: 0010:[<ffffffff8105bff0>]  [<ffffffff8105bff0>] kthread_data+0xb/0x11
RSP: 0000:ffff8800af587ad8  EFLAGS: 00010096
RAX: 0000000000000000 RBX: 0000000000000002 RCX: ffff8800af587fd8
RDX: ffff880020462c40 RSI: 0000000000000002 RDI: ffff880020462c40
RBP: ffff8800af587ad8 R08: ffff8800af587ac8 R09: ffff880127670000
R10: ffff8800af587bb8 R11: ffff8800af587af8 R12: ffff880020463110
R13: 0000000000000002 R14: ffff880127670000 R15: 0000000000000001
FS:  0000000000000000(0000) GS:ffff8800cfc80000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: fffffffffffffff8 CR3: 00000000b5e09000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process kworker/2:0 (pid: 11584, threadinfo ffff8800af586000, task ffff880020462c40)
Stack:
  ffff8800af587af8 ffffffff81058c7c ffff8800cfc93280 ffff8800cfc93280
  ffff8800af587bb8 ffffffff81411649 ffff8800af587b48 ffffffff811cb437
  ffff880020462c40 ffff8800af587fd8 ffff880020462f00 ffff880020462ef8
Call Trace:
  [<ffffffff81058c7c>] wq_worker_sleeping+0x10/0x8a
  [<ffffffff81411649>] schedule+0x167/0x5b4
  [<ffffffff811cb437>] ? put_io_context+0x57/0x60
  [<ffffffff8103fde4>] ? get_parent_ip+0x11/0x42
  [<ffffffff810493e9>] do_exit+0x70d/0x71c
  [<ffffffff81045a1c>] ? kmsg_dump+0xe5/0xf4
  [<ffffffff81414805>] oops_end+0xb9/0xc1
  [<ffffffff8100e105>] die+0x55/0x5e
  [<ffffffff81414442>] do_general_protection+0x130/0x138
  [<ffffffff81413c95>] general_protection+0x25/0x30
  [<ffffffffa024f5f1>] ? rpcb_getport_done+0x65/0xab [sunrpc]
  [<ffffffffa02480c2>] rpc_exit_task+0x27/0x55 [sunrpc]
  [<ffffffffa02486aa>] __rpc_execute+0x78/0x24b [sunrpc]
  [<ffffffff8103fde4>] ? get_parent_ip+0x11/0x42
  [<ffffffffa02488be>] ? rpc_async_schedule+0x0/0x12 [sunrpc]
  [<ffffffffa02488ce>] rpc_async_schedule+0x10/0x12 [sunrpc]
  [<ffffffff810571c9>] process_one_work+0x1ac/0x28a
  [<ffffffff810591a3>] worker_thread+0x136/0x255
  [<ffffffff8105906d>] ? worker_thread+0x0/0x255
  [<ffffffff8105c3bf>] kthread+0x7d/0x85
  [<ffffffff8100b8e4>] kernel_thread_helper+0x4/0x10
  [<ffffffff8105c342>] ? kthread+0x0/0x85
  [<ffffffff8100b8e0>] ? kernel_thread_helper+0x0/0x10
Code: 62 fe ff ff 90 90 90 55 65 48 8b 04 25 40 cc 00 00 48 8b 80 68 02 00 00 48 89 e5 8b 40 f0 c9 c3 48 8b 87 68 02 00 00 55 48 89 e5 <48> 8b 40 f8 c9 c3 55 48 
83 c7 50 48 89 e5 e8 d8 c1 fd ff c9 c3
RIP  [<ffffffff8105bff0>] kthread_data+0xb/0x11
  RSP <ffff8800af587ad8>
CR2: fffffffffffffff8
---[ end trace 17a74221efb85e48 ]---
Fixing recursive fault but reboot is needed!

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

