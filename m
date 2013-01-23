Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.candelatech.com ([208.74.158.172]:52825 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751819Ab3AWCco (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Jan 2013 21:32:44 -0500
Message-ID: <50FF4BC9.1060206@candelatech.com>
Date: Tue, 22 Jan 2013 18:32:41 -0800
From: Ben Greear <greearb@candelatech.com>
MIME-Version: 1.0
To: Eric Dumazet <eric.dumazet@gmail.com>
CC: netdev <netdev@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: 3.7.3+:  Bad paging request in ip_rcv_finish while running NFS
 traffic.
References: <50FDADF4.3060601@candelatech.com>  <50FDDE35.7070806@candelatech.com>  <1358829606.3464.3151.camel@edumazet-glaptop>  <50FE2A57.3040804@candelatech.com>  <50FEC796.5090404@candelatech.com>  <1358875020.3464.4006.camel@edumazet-glaptop> <1358875607.3464.4020.camel@edumazet-glaptop> <50FF102F.2050008@candelatech.com>
In-Reply-To: <50FF102F.2050008@candelatech.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 01/22/2013 02:18 PM, Ben Greear wrote:
> On 01/22/2013 09:26 AM, Eric Dumazet wrote:
>> On Tue, 2013-01-22 at 09:17 -0800, Eric Dumazet wrote:
>>> On Tue, 2013-01-22 at 09:08 -0800, Ben Greear wrote:
>>>
>>>> Unfortunately, I hit it again this morning after the first restart of
>>>> my application (which bounces all 3000 interfaces).  Memory poisoning
>>>> was disabled.
>>>
>>> Is your NFS traffic using TCP or UDP ?
>>>
>>
>> Oh well, it seems macvlan.c has to skb_drop_dst(skb) before giving skb
>> to netif_rx()
>
> I just saw another crash.  It had run 2 user-space restarts and
> 2 reboots, but on the third reboot, it crashed coming up.  It seemed
> to last longer this time, but that could just be luck as it's never
> been super easy to reproduce this quickly.

I added a patch to set dst->input and dst->output to 0xdeadbeef before
freeing the memory.  (The warn-on below did NOT hit)

@@ -452,6 +452,9 @@ static inline int dst_output(struct sk_buff *skb)
  /* Input packet from network to transport.  */
  static inline int dst_input(struct sk_buff *skb)
  {
+       if (WARN_ON(((unsigned long)(skb_dst(skb))) < 4000)) {
+               printk("Bad skb_dst: %lu\n", skb->_skb_refdst);
+       }
         return skb_dst(skb)->input(skb);
  }

diff --git a/net/core/dst.c b/net/core/dst.c
index ee6153e..234b168 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -245,6 +245,7 @@ again:
                 dst->ops->destroy(dst);
         if (dst->dev)
                 dev_put(dst->dev);
+       dst->input = dst->output = 0xdeadbeef;
         kmem_cache_free(dst->ops->kmem_cachep, dst);

         dst = child;

Looks like we do indeed access freed memory, based on this crash I saw on
the next reboot:

[root@lf1011-12060006 ~]# BUG: unable to handle kernel paging request at 00000000deadbeef
IP: [<00000000deadbeef>] 0xdeadbeee
PGD 0
Oops: 0010 [#1] PREEMPT SMP
Modules linked in: macvlan pktgen lockd sunrpc uinput iTCO_wdt iTCO_vendor_support gpio_ich coretemp hwmon kvm_intel kvm microcode pcspkr i2c_i801 lpc_ich 
e1000e i7core_edac ioatdma edac_core igb ptp pps_core dca ipv6 mgag200 i2c_algo_bit drm_kms_helper ttm drm i2c_core
CPU 8
Pid: 59, comm: ksoftirqd/8 Tainted: G         C O 3.7.3+ #46 Iron Systems Inc. EE2610R/X8ST3
RIP: 0010:[<00000000deadbeef>]  [<00000000deadbeef>] 0xdeadbeee
RSP: 0018:ffff88040d7d7bc0  EFLAGS: 00010286
RAX: ffff8803d97fc900 RBX: ffff8803d4d30d00 RCX: 0000000000000028
RDX: ffffffff81aafcb0 RSI: ffffffff81a2a500 RDI: ffff8803d4d30d00
RBP: ffff88040d7d7be8 R08: ffffffff814a8812 R09: ffff88040d7d7bb0
R10: ffff8803c9dfd8fc R11: ffff88040d7d7c48 R12: ffff8803c9dfd8fc
R13: ffff8803d4d30d00 R14: ffff88040d3f8000 R15: 0000000000000000
FS:  0000000000000000(0000) GS:ffff88041fd00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 00000000deadbeef CR3: 0000000001a0b000 CR4: 00000000000007e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process ksoftirqd/8 (pid: 59, threadinfo ffff88040d7d6000, task ffff88040d7e1f50)
Stack:
  ffffffff814a8b02 ffff8803d4d30d00 ffffffff814a8812 ffff8803d4d30d00
  ffff88040d3f8000 ffff88040d7d7c18 ffffffff814a8eb5 0000000080000000
  ffffffff81472e61 ffff8803d4d30d00 ffff88040d3f8000 ffff88040d7d7c48
Call Trace:
  [<ffffffff814a8b02>] ? ip_rcv_finish+0x2f0/0x308
  [<ffffffff814a8812>] ? skb_dst+0x5a/0x5a
  [<ffffffff814a8eb5>] NF_HOOK.clone.1+0x4c/0x54
  [<ffffffff81472e61>] ? dev_seq_stop+0xb/0xb
  [<ffffffff814a9142>] ip_rcv+0x237/0x269
  [<ffffffff81473def>] __netif_receive_skb+0x487/0x530
  [<ffffffff81473f91>] process_backlog+0xf9/0x1da
  [<ffffffff8147639a>] net_rx_action+0xad/0x218
  [<ffffffff8108d50a>] __do_softirq+0x9c/0x161
  [<ffffffff8108d5f2>] run_ksoftirqd+0x23/0x42
  [<ffffffff810a7ebe>] smpboot_thread_fn+0x253/0x259
  [<ffffffff810a7c6b>] ? test_ti_thread_flag.clone.0+0x11/0x11
  [<ffffffff810a0a6d>] kthread+0xc2/0xca
  [<ffffffff810a09ab>] ? __init_kthread_worker+0x56/0x56
  [<ffffffff81537b7c>] ret_from_fork+0x7c/0xb0
  [<ffffffff810a09ab>] ? __init_kthread_worker+0x56/0x56
Code:  Bad RIP value.
RIP  [<00000000deadbeef>] 0xdeadbeee
  RSP <ffff88040d7d7bc0>
CR2: 00000000deadbeef
---[ end trace eed854e70ff0a575 ]---
Kernel panic - not syncing: Fatal excepti

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

