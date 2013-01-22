Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.candelatech.com ([208.74.158.172]:50445 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751561Ab3AVWS0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Jan 2013 17:18:26 -0500
Message-ID: <50FF102F.2050008@candelatech.com>
Date: Tue, 22 Jan 2013 14:18:23 -0800
From: Ben Greear <greearb@candelatech.com>
MIME-Version: 1.0
To: Eric Dumazet <eric.dumazet@gmail.com>
CC: netdev <netdev@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: 3.7.3+:  Bad paging request in ip_rcv_finish while running NFS
 traffic.
References: <50FDADF4.3060601@candelatech.com>  <50FDDE35.7070806@candelatech.com>  <1358829606.3464.3151.camel@edumazet-glaptop>  <50FE2A57.3040804@candelatech.com>  <50FEC796.5090404@candelatech.com>  <1358875020.3464.4006.camel@edumazet-glaptop> <1358875607.3464.4020.camel@edumazet-glaptop>
In-Reply-To: <1358875607.3464.4020.camel@edumazet-glaptop>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 01/22/2013 09:26 AM, Eric Dumazet wrote:
> On Tue, 2013-01-22 at 09:17 -0800, Eric Dumazet wrote:
>> On Tue, 2013-01-22 at 09:08 -0800, Ben Greear wrote:
>>
>>> Unfortunately, I hit it again this morning after the first restart of
>>> my application (which bounces all 3000 interfaces).  Memory poisoning
>>> was disabled.
>>
>> Is your NFS traffic using TCP or UDP ?
>>
>
> Oh well, it seems macvlan.c has to skb_drop_dst(skb) before giving skb
> to netif_rx()

I just saw another crash.  It had run 2 user-space restarts and
2 reboots, but on the third reboot, it crashed coming up.  It seemed
to last longer this time, but that could just be luck as it's never
been super easy to reproduce this quickly.

For completeness, here is the diff I was using:

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 68a43fe..eb55c88 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -111,9 +111,16 @@ static int macvlan_broadcast_one(struct sk_buff *skb,
                                  const struct ethhdr *eth, bool local)
  {
         struct net_device *dev = vlan->dev;
+
         if (!skb)
                 return NET_RX_DROP;

+       if (!(dev->flags & IFF_UP)) {
+               kfree_skb(skb);
+               return NET_RX_DROP;
+       }
+
+       skb_dst_drop(skb);
         if (local)
                 return vlan->forward(dev, skb);

@@ -220,6 +227,7 @@ static rx_handler_result_t macvlan_handle_frame(struct sk_buff **pskb)
         if (!skb)
                 goto out;

+       skb_dst_drop(skb);
         skb->dev = dev;
         skb->pkt_type = PACKET_HOST;


BUG: unable to handle kernel NULL pointer dereference at           (null)
IP: [<          (null)>]           (null)
PGD 0
Oops: 0010 [#1] PREEMPT SMP
Modules linked in: nf_nat_ipv4 nf_nat nfsv4 auth_rpcgss nfs fscache 8021q garp stp llc macvlan pktgen lockd sunrpc uinput iTCO_wdt iTCO_vendor_support gpio_ich 
coretemp hwmon kvm_intel kvm microcode pcspkr i2c_i801 lpc_ich e1000e igb ptp ioatdma i7core_edac pps_core dca edac_core ipv6 mgag200 i2c_algo_bit 
drm_kms_helper ttm drm i2c_core [last unloaded: iptable_nat]
CPU 5
Pid: 40, comm: rcuc/5 Tainted: G         C   3.7.3+ #43 Iron Systems Inc. EE2610R/X8ST3
RIP: 0010:[<0000000000000000>]  [<          (null)>]           (null)
RSP: 0018:ffff88041fca3da0  EFLAGS: 00010282
RAX: ffff88030ae8bc80 RBX: ffff880198694500 RCX: 0000000000000028
RDX: ffffffff81aafcb0 RSI: ffffffff81a2a500 RDI: ffff880198694500
RBP: ffff88041fca3dc8 R08: ffffffff814a87fa R09: ffff88041fca3d90
R10: ffff8803dc45b8fc R11: ffff88041fca3e28 R12: ffff8803dc45b8fc
R13: ffff880198694500 R14: ffff88040d3f8000 R15: 0000000000000000
FS:  0000000000000000(0000) GS:ffff88041fca0000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000000000000000 CR3: 0000000001a0b000 CR4: 00000000000007e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process rcuc/5 (pid: 40, threadinfo ffff88040d73c000, task ffff88040d723ea0)
Stack:
  ffffffff814a8ab3 ffff880198694500 ffffffff814a87fa ffff880198694500
  ffff88040d3f8000 ffff88041fca3df8 ffffffff814a8e66 0000000080000000
  ffffffff81472e61 ffff880198694500 ffff88040d3f8000 ffff88041fca3e28
Call Trace:
  <IRQ>
  [<ffffffff814a8ab3>] ? ip_rcv_finish+0x2b9/0x2d1
  [<ffffffff814a87fa>] ? skb_dst+0x5a/0x5a
  [<ffffffff814a8e66>] NF_HOOK.clone.1+0x4c/0x54
  [<ffffffff81472e61>] ? dev_seq_stop+0xb/0xb
  [<ffffffff814a90f3>] ip_rcv+0x237/0x268
  [<ffffffff81473def>] __netif_receive_skb+0x487/0x530
  [<ffffffff81473f91>] process_backlog+0xf9/0x1da
  [<ffffffff8147639a>] net_rx_action+0xad/0x218
  [<ffffffff8108d50a>] __do_softirq+0x9c/0x161
  [<ffffffff81538ddc>] call_softirq+0x1c/0x30
  <EOI>
  [<ffffffff8100bd21>] do_softirq+0x41/0x7e
  [<ffffffff8108d68b>] _local_bh_enable_ip+0x7a/0x9f
  [<ffffffff8108d6c8>] local_bh_enable+0xd/0x11
  [<ffffffff810f3661>] rcu_cpu_kthread+0xe6/0x11f
  [<ffffffff810a7ebe>] smpboot_thread_fn+0x253/0x259
  [<ffffffff810a7c6b>] ? test_ti_thread_flag.clone.0+0x11/0x11
  [<ffffffff810a0a6d>] kthread+0xc2/0xca
  [<ffffffff810a09ab>] ? __init_kthread_worker+0x56/0x56
  [<ffffffff81537afc>] ret_from_fork+0x7c/0xb0
  [<ffffffff810a09ab>] ? __init_kthread_worker+0x56/0x56
Code:  Bad RIP value.
RIP  [<          (null)>]           (null)
  RSP <ffff88041fca3da0>
CR2: 0000000000000000


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

