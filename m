Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.candelatech.com ([208.74.158.172]:57942 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752325Ab3AVAcy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jan 2013 19:32:54 -0500
Message-ID: <50FDDE35.7070806@candelatech.com>
Date: Mon, 21 Jan 2013 16:32:53 -0800
From: Ben Greear <greearb@candelatech.com>
MIME-Version: 1.0
To: netdev <netdev@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: 3.7.3+:  Bad paging request in ip_rcv_finish while running NFS
 traffic.
References: <50FDADF4.3060601@candelatech.com>
In-Reply-To: <50FDADF4.3060601@candelatech.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 01/21/2013 01:07 PM, Ben Greear wrote:
> I posted about this a few days ago, but this time the patches applied
> are minimal and there are no out-of-tree kernel modules loaded.

Here's another crash, this time with SLUB memory debugging turned on.

Seems much harder to hit this way...I've only managed this one.  I
believe the RCX register might be interesting...that 6b is probably
freed memory poisioning.  Maybe skb or skb_dest() is already freed?

I have added a 'verify_mem_not_deleted(skb)' before the
dst_input line in ip_rcv_finish..but so far, it hasn't
hit the problem...


general protection fault: 0000 [#1] PREEMPT SMP
Modules linked in: 8021q garp stp llc nfsv4 auth_rpcgss nfs fscache macvlan pktgen lockd sunrpc iTCO_wdt iTCO_vendor_support gpio_ich coretemp hwmon kvm_intel 
kvm microcode pcspkr i2c_i801 lpc_ich igb e1000e ioatdma ptp i7core_edac pps_core edac_core dca uinput ipv6 mgag200 i2c_algo_bit drm_kms_helper ttm drm i2c_core 
[last unloaded: macvlan]
CPU 2
Pid: 22, comm: rcuc/2 Tainted: G         C O 3.7.3+ #38 Iron Systems Inc. EE2610R/X8ST3
RIP: 0010:[<ffffffff814c196d>]  [<ffffffff814c196d>] ip_rcv_finish+0x334/0x34f
RSP: 0018:ffff88041fc43d98  EFLAGS: 00010282
RAX: ffff880369f67180 RBX: ffff8803e4144fc0 RCX: 000000006b6b6b6b
RDX: ffff8803dd632f64 RSI: ffffffff81a2a580 RDI: ffff8803e4144fc0
RBP: ffff88041fc43db8 R08: ffffffff814c1639 R09: ffffffff814c1639
R10: ffff8803dd632f64 R11: ffff8803dd632f64 R12: ffff8803dd632f64
R13: ffff88041fc58420 R14: ffff88040cfa8000 R15: 0000000000000000
FS:  0000000000000000(0000) GS:ffff88041fc40000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 000000000079e008 CR3: 00000003d5759000 CR4: 00000000000007e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process rcuc/2 (pid: 22, threadinfo ffff88040d7d4000, task ffff88040d7d8000)
Stack:
  ffff8803e4144fc0 ffffffff814c1639 ffff8803e4144fc0 ffff88040cfa8000
  ffff88041fc43de8 ffffffff814c1e61 ffff880480000000 0000000000000246
  ffff8803e4144fc0 ffff88040cfa8000 ffff88041fc43e18 ffffffff814c20ec
Call Trace:
  <IRQ>
  [<ffffffff814c1639>] ? skb_dst+0x41/0x41
  [<ffffffff814c1e61>] NF_HOOK.clone.1+0x4c/0x53
  [<ffffffff814c20ec>] ip_rcv+0x237/0x267
  [<ffffffff814887f0>] __netif_receive_skb+0x537/0x5e0
  [<ffffffff8148895a>] process_backlog+0xc1/0x1b7
  [<ffffffff8148b082>] ? net_rx_action+0x1c4/0x1e2
  [<ffffffff8148af70>] net_rx_action+0xb2/0x1e2
  [<ffffffff8108eeb8>] __do_softirq+0xab/0x17b
  [<ffffffff81557cfc>] call_softirq+0x1c/0x30
  <EOI>
  [<ffffffff8100bd46>] do_softirq+0x46/0x9e
  [<ffffffff810fb709>] ? rcu_cpu_kthread+0xf6/0x12f
  [<ffffffff8108f08d>] _local_bh_enable_ip+0xb3/0xe7
  [<ffffffff8108f0d9>] local_bh_enable+0xd/0x10
  [<ffffffff810fb709>] rcu_cpu_kthread+0xf6/0x12f
  [<ffffffff810aacde>] smpboot_thread_fn+0x253/0x259
  [<ffffffff810aaa8b>] ? test_ti_thread_flag.clone.0+0x11/0x11
  [<ffffffff810a3439>] kthread+0xc2/0xca
  [<ffffffff810a3377>] ? __init_kthread_worker+0x56/0x56
  [<ffffffff815569bc>] ret_from_fork+0x7c/0xb0
  [<ffffffff810a3377>] ? __init_kthread_worker+0x56/0x56
Code: 8b 80 58 04 00 00 48 8b 80 48 01 00 00 65 48 ff 80 c8 00 00 00 8b 53 68 65 48 01 90 e8 00 00 00 48 89 df e8
8e fc ff ff 48 89 df <ff> 50 50 eb 0d 48 89 df e8 2c eb fb ff b8 01 00 00 00 5b 41 5c
RIP  [<ffffffff814c196d>] ip_rcv_finish+0x334/0x34f
  RSP <ffff88041fc43d98>
[drm:mgag200_bo_reserve] *ERROR* reserve failed ffff8803feba9fb0


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

