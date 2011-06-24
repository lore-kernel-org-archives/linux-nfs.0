Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:57969 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754210Ab1FXP3F (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Jun 2011 11:29:05 -0400
Received: from [192.168.100.195] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id p5OFT4tG027926
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Fri, 24 Jun 2011 08:29:04 -0700
Message-ID: <4E04AD40.2070404@candelatech.com>
Date: Fri, 24 Jun 2011 08:29:04 -0700
From: Ben Greear <greearb@candelatech.com>
To: linux-nfs@vger.kernel.org
Subject: Re: Use-after-free in hacked 2.6.38.8 kernel.
References: <4E03BE46.2040405@candelatech.com>
In-Reply-To: <4E03BE46.2040405@candelatech.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 06/23/2011 03:29 PM, Ben Greear wrote:
> 2.6.38.8 kernel, with our NFS bind-source-IP patches and some other
> stuff, including a tainting module (though that module isn't
> active in this test).

And, another one.  Different place this time though:


[root@simech2 ~]# general protection fault: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
last sysfs file: /sys/devices/virtual/bdi/0:51/uevent
CPU 0
Modules linked in:
=============================================================================
BUG kmalloc-64: Poison overwritten
-----------------------------------------------------------------------------

INFO: 0xffff880097422de4-0xffff880097422de5. First byte 0x1 instead of 0x6b
INFO: Allocated in rpcb_getport_async+0x39c/0x5a5 [sunrpc] age=22 cpu=1 pid=23678
INFO: Freed in rpcb_map_release+0x3f/0x44 [sunrpc] age=20 cpu=0 pid=18587
INFO: Slab 0xffffea0002116770 objects=30 used=7 fp=0xffff880097422dd0 flags=0x200000000000c1
INFO: Object 0xffff880097422dd0 @offset=3536 fp=0xffff8800974224c8

Bytes b4 0xffff880097422dc0:  ae db 4e 00 01 00 00 00 5a 5a 5a 5a 5a 5a 5a 5a ®ÛN.....ZZZZZZZZ
   Object 0xffff880097422dd0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff880097422de0:  6b 6b 6b 6b 01 08 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkk..kkkkkkkkkk
   Object 0xffff880097422df0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff880097422e00:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5 kkkkkkkkkkkkkkk¥
  Redzone 0xffff880097422e10:  bb bb bb bb bb bb bb bb                         »»»»»»»»
  Padding 0xffff880097422e50:  5a 5a 5a 5a 5a 5a 5a 5a                         ZZZZZZZZ
Pid: 2259, comm: gnuserver Tainted: P            2.6.38.8+ #9
Call Trace:
  [<ffffffff81100aee>] ? print_trailer+0x12e/0x137
  [<ffffffff81100fb7>] ? check_bytes_and_report+0xb9/0xfd
  [<ffffffff81129cbb>] ? alloc_fdtable+0xb2/0xda
  [<ffffffff811010b0>] ? check_object+0xb5/0x192
  [<ffffffff81129c6b>] ? alloc_fdtable+0x62/0xda
  [<ffffffff811014d1>] ? alloc_debug_processing+0x79/0xf2
  [<ffffffff81102bff>] ? __slab_alloc+0x337/0x375
  [<ffffffff81129c6b>] ? alloc_fdtable+0x62/0xda
  [<ffffffff81129d92>] ? dup_fd+0xaf/0x35b
  [<ffffffff81129c6b>] ? alloc_fdtable+0x62/0xda
  [<ffffffff81103d87>] ? kmem_cache_alloc_trace+0x76/0xef
  [<ffffffff81129c6b>] ? alloc_fdtable+0x62/0xda
  [<ffffffff81129e61>] ? dup_fd+0x17e/0x35b
  [<ffffffff8104957b>] ? copy_process+0x714/0x12a5
  [<ffffffff8105a25f>] ? sigprocmask+0x2f/0xc6
  [<ffffffff8104a217>] ? do_fork+0x10b/0x2ed
  [<ffffffff810e143d>] ? might_fault+0x63/0xb3
  [<ffffffff8111c993>] ? path_put+0x1d/0x22
  [<ffffffff81011fed>] ? sys_clone+0x23/0x25
  [<ffffffff8100ae33>] ? stub_clone+0x13/0x20
  [<ffffffff8100aa92>] ? system_call_fastpath+0x16/0x1b
FIX kmalloc-64: Restoring 0xffff880097422de4-0xffff880097422de5=0x6b

IX kmalloc-64: Marking all objects used
  xt_TPROXY nf_tproxy_core xt_socket nf_defrag_ipv6 xt_connlimit 8021q garp macvlan pktgen iscsi_tcp libiscsi_tcp libiscsi scsi_transport_iscsi fuse 
ip6table_filter ip6_tables ebtable_nat ebtables stp llc nfs lockd fscache nfs_acl auth_rpcgss sunrpc ipv6 kvm_intel kvm uinput i5k_amb i5000_edac iTCO_wdt 
ioatdma i2c_i801 shpchp iTCO_vendor_support edac_core pcspkr serio_raw e1000e microcode dca floppy radeon ttm drm_kms_helper drm hwmon i2c_algo_bit i2c_core 
[last unloaded: ipt_addrtype]

Pid: 18587, comm: kworker/0:1 Tainted: P            2.6.38.8+ #9 Supermicro X7DBU/X7DBU
RIP: 0010:[<ffffffffa0294f5b>]  [<ffffffffa0294f5b>] rpcb_getport_done+0x47/0xab [sunrpc]
RSP: 0018:ffff8800c7133d20  EFLAGS: 00010246
RAX: ffffffffa0294f14 RBX: 0000000000000000 RCX: 0000000000000088
RDX: ffff880097422dd0 RSI: 000000006b6b0801 RDI: ffff880124668c80
RBP: ffff8800c7133d40 R08: ffff880097422dd0 R09: 0000000000000000
R10: ffff8800c7133d20 R11: ffff8800c7133c40 R12: ffff880097422dd0
R13: 6b6b6b6b6b6b6b6b R14: ffff880124668c80 R15: ffffffffa028db26
FS:  0000000000000000(0000) GS:ffff8800cfc00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000000002666940 CR3: 00000000a73b6000 CR4: 00000000000006f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process kworker/0:1 (pid: 18587, threadinfo ffff8800c7132000, task ffff8800c4fea0a0)
Stack:
  ffff880124668c80 ffff880124668cf0 0000000000000001 0000000000000000
  ffff8800c7133d60 ffffffffa028d520 0000000000000000 ffff880124668c80
  ffff8800c7133db0 ffffffffa028d911 ffff8800ca597080 0000000000000000
Call Trace:
  [<ffffffffa028d520>] rpc_exit_task+0x27/0x55 [sunrpc]
  [<ffffffffa028d911>] __rpc_execute+0x78/0x24b [sunrpc]
  [<ffffffffa028db26>] ? rpc_async_schedule+0x0/0x12 [sunrpc]
  [<ffffffffa028db36>] rpc_async_schedule+0x10/0x12 [sunrpc]
  [<ffffffff81061613>] process_one_work+0x259/0x41b
  [<ffffffff8106153b>] ? process_one_work+0x181/0x41b
  [<ffffffff81063a51>] worker_thread+0x133/0x217
  [<ffffffff8106391e>] ? worker_thread+0x0/0x217
  [<ffffffff81066fc0>] kthread+0x7d/0x85
  [<ffffffff8100b924>] kernel_thread_helper+0x4/0x10
  [<ffffffff81463098>] ? restore_args+0x0/0x30
  [<ffffffff81066f43>] ? kthread+0x0/0x85
  [<ffffffff8100b920>] ? kernel_thread_helper+0x0/0x10
Code: fb 74 05 83 fb a3 75 0e 41 ff 85 f4 05 00 00 bb a3 ff ff ff eb 04 85 db 79 0e 49 8b 45 08 31 f6 4c 89 ef ff 50 20 eb 32 8b 76 14 <49> 8b 45 08 66 85 f6 75 
0f 31 f6 4c 89 ef bb f3 ff ff ff ff 50
RIP  [<ffffffffa0294f5b>] rpcb_getport_done+0x47/0xab [sunrpc]
  RSP <ffff8800c7133d20>
---[ end trace 56d19572836bccfa ]---

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

