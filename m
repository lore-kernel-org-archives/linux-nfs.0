Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.candelatech.com ([208.74.158.172]:58304 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754296Ab3AVRIk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Jan 2013 12:08:40 -0500
Message-ID: <50FEC796.5090404@candelatech.com>
Date: Tue, 22 Jan 2013 09:08:38 -0800
From: Ben Greear <greearb@candelatech.com>
MIME-Version: 1.0
To: Eric Dumazet <eric.dumazet@gmail.com>
CC: netdev <netdev@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: 3.7.3+:  Bad paging request in ip_rcv_finish while running NFS
 traffic.
References: <50FDADF4.3060601@candelatech.com>  <50FDDE35.7070806@candelatech.com> <1358829606.3464.3151.camel@edumazet-glaptop> <50FE2A57.3040804@candelatech.com>
In-Reply-To: <50FE2A57.3040804@candelatech.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 01/21/2013 09:57 PM, Ben Greear wrote:
> On 01/21/2013 08:40 PM, Eric Dumazet wrote:
>> On Mon, 2013-01-21 at 16:32 -0800, Ben Greear wrote:
>>> On 01/21/2013 01:07 PM, Ben Greear wrote:
>>>> I posted about this a few days ago, but this time the patches applied
>>>> are minimal and there are no out-of-tree kernel modules loaded.
>>>
>>> Here's another crash, this time with SLUB memory debugging turned on.
>>>
>>> Seems much harder to hit this way...I've only managed this one.  I
>>> believe the RCX register might be interesting...that 6b is probably
>>> freed memory poisioning.  Maybe skb or skb_dest() is already freed?
>>>
>>> I have added a 'verify_mem_not_deleted(skb)' before the
>>> dst_input line in ip_rcv_finish..but so far, it hasn't
>>> hit the problem...
>>>
>>
>> There is no way skb is freed here.
>>
>> I would say macvlan is at fault here.
>>
>> It probably lacks a proper (dev->flags & IFF_UP) test.
>
> Thanks for the patch.  It's running OK so far, but I'll need to
> do a bunch more testing tomorrow to make sure I'm not just getting
> lucky!
>
> I'll let you know how it goes tomorrow.

Unfortunately, I hit it again this morning after the first restart of
my application (which bounces all 3000 interfaces).  Memory poisoning
was disabled.

(gdb) l *(ip_rcv_finish+0x2b9)
0xffffffff814a8ab3 is in ip_rcv_finish (/home/greearb/git/linux-3.7.dev.y/net/ipv4/ip_input.c:373).
368					skb->len);
369		} else if (rt->rt_type == RTN_BROADCAST)
370			IP_UPD_PO_STATS_BH(dev_net(rt->dst.dev), IPSTATS_MIB_INBCAST,
371					skb->len);
372	
373		return dst_input(skb);
374	
375	drop:
376		kfree_skb(skb);
377		return NET_RX_DROP;
(gdb)

(gdb) l *(skb_dst+0x5a)
0xffffffff814a87fa is in ip_rcv_finish (/home/greearb/git/linux-3.7.dev.y/net/ipv4/ip_input.c:320).
315	
316	int sysctl_ip_early_demux __read_mostly = 1;
317	EXPORT_SYMBOL(sysctl_ip_early_demux);
318	
319	static int ip_rcv_finish(struct sk_buff *skb)
320	{
321		const struct iphdr *iph = ip_hdr(skb);
322		struct rtable *rt;
323	
324		if (sysctl_ip_early_demux && !skb_dst(skb)) {

nfs: server 10.1.0.1 not responding, timed out
nfs: server 10.1.0.1 not responding, timed out
BUG: unable to handle kernel NULL pointer dereference at           (null)
IP: [<          (null)>]           (null)
PGD 0
Oops: 0010 [#1] PREEMPT SMP
Modules linked in: nf_nat_ipv4 nf_nat nfsv4 auth_rpcgss nfs fscache 8021q garp stp llc lockd sunrpc macvlan pktgen uinput coretemp hwmon kvm_intel kvm iTCO_wdt 
iTCO_vendor_support gpio_ich microcode pcspkr i2c_i801 lpc_ich e1000e i7core_edac ioatdma edac_core igb ptp pps_core dca ipv6 mgag200 i2c_algo_bit 
drm_kms_helper ttm drm i2c_core [last unloaded: iptable_nat]
CPU 0
Pid: 9, comm: rcuc/0 Tainted: G         C O 3.7.3+ #43 Iron Systems Inc. EE2610R/X8ST3
RIP: 0010:[<0000000000000000>]  [<          (null)>]           (null)
RSP: 0018:ffff88041fc03da0  EFLAGS: 00010286
RAX: ffff88023045f5c0 RBX: ffff88034491ab00 RCX: 00000000ffff8800
RDX: ffff88025920d4fc RSI: ffffffff81a2a500 RDI: ffff88034491ab00
RBP: ffff88041fc03dc8 R08: ffffffff814a87fa R09: ffff88041fc03d90
R10: ffff88025920d4fc R11: ffff88041fc03e28 R12: ffff88025920d4fc
R13: ffff88041fc18b60 R14: ffff88040d3f8000 R15: 0000000000000000
FS:  0000000000000000(0000) GS:ffff88041fc00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000000000000000 CR3: 0000000001a0b000 CR4: 00000000000007f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process rcuc/0 (pid: 9, threadinfo ffff88040d4e2000, task ffff88040d4e8000)
Stack:
  ffffffff814a8ab3 ffff88034491ab00 ffffffff814a87fa ffff88034491ab00
  ffff88040d3f8000 ffff88041fc03df8 ffffffff814a8e66 0000000080000000
  ffffffff81472e61 ffff88034491ab00 ffff88040d3f8000 ffff88041fc03e28
Call Trace:
  <IRQ>
  [<ffffffff814a8ab3>] ? ip_rcv_finish+0x2b9/0x2d1
  [<ffffffff814a87fa>] ? skb_dst+0x5a/0x5a
  [<ffffffff814a8e66>] NF_HOOK.clone.1+0x4c/0x54
  [<ffffffff81472e61>] ? dev_seq_stop+0xb/0xb
  [<ffffffff814a90f3>] ip_rcv+0x237/0x268
  [<ffffffff81473def>] __netif_receive_skb+0x487/0x530
  [<ffffffff81473f91>] process_backlog+0xf9/0x1da
nfs: server 10.1.8.1 not responding, timed out
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
Code:  Bad RIP value.nfs: server 10.1.0.1 not responding, timed out
nfs: server 10.1.0.1 not responding, timed out

>
> Thanks,
> Ben
>
>
>


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

