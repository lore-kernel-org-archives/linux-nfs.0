Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.candelatech.com ([208.74.158.172]:33200 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752271Ab3AUVHA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jan 2013 16:07:00 -0500
Message-ID: <50FDADF4.3060601@candelatech.com>
Date: Mon, 21 Jan 2013 13:07:00 -0800
From: Ben Greear <greearb@candelatech.com>
MIME-Version: 1.0
To: netdev <netdev@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: 3.7.3+:  Bad paging request in ip_rcv_finish while running NFS traffic.
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I posted about this a few days ago, but this time the patches applied
are minimal and there are no out-of-tree kernel modules loaded.

I have to have the NFS patches (see below) for this test case to run
at all.

Test case is 2500 macvlans, each with a file-IO process running
on it doing writing on it's own mountpoint.  This is using NFSv4,
O_DIRECT, and 10k write() calls (and each file is 10k long, so
open/close file operations as well.  Smaller files and write sizes
showed the problem as well.

The bug is most easily hit during my application's restart, where interfaces
are being (re)configured and the file-io processes are being
started.  This includes changes to: IP addrs, routes, ip routing rules,
mount/unmount operations, etc.

I suspect it may be some sort of race between tearing down the IP protocol
and having traffic currently being received on that
interface.  I have not been able to hit this using HTTP traffic,
but perhaps that is just part of the race and not a particular
problem with NFS.

The patches applied on top of 3.7.3 are some NFS crash fixes Trond posted
last Friday and my own patches I just posted to linux-nfs:

http://www.spinics.net/lists/linux-nfs/msg34811.html

If anyone has any suggestions for how to further debug this,
please let me know.

All of the crashes are in the same place, but the value of
the bad address changes...sometimes appears as if NULL were
dereferenced...

<http://www.gnu.org/software/gdb/bugs/>...
Reading symbols from /home/greearb/kernel/2.6/linux-3.7.x64/vmlinux...done.
(gdb) l *(ip_rcv_finish+0x2b7)
0xffffffff8149c783 is in ip_rcv_finish (/home/greearb/git/linux-3.7.dev.y/net/ipv4/ip_input.c:373).
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
(gdb) quit



IPv6: ADDRCONF(NETDEV_CHANGE): eth2#903: link becomes ready
IPv6: ADDRCONF(NETDEV_CHANGE): eth2#923: link becomes ready
IPv6: ADDRCONF(NETDEV_CHANGE): eth2#943: link becomes ready
IPv6: ADDRCONF(NETDEV_CHANGE): eth2#963: link becomes ready
IPv6: ADDRCONF(NETDEV_CHANGE): eth2#983: link becomes ready
kernel tried to execute NX-protected page - exploit attempt? (uid: 0)
BUG: unable to handle kernel paging request at ffff88040d7d8000
IP: [<ffff88040d7d8000>] 0xffff88040d7d7fff
PGD 1a0c063 PUD df78e067 PMD 800000040d6001e3
Oops: 0011 [#1] PREEMPT SMP
Modules linked in: macvlan pktgen lockd sunrpc uinput coretemp hwmon kvm_intel kvm gpio_ich iTCO_wdt iTCO_vendor_support microcode pcspkr lpc_ich i2c_i801 
e1000e ioatdma igb i7core_edac edac_core ptp pps_core dca ipv6 mgag200 i2c_algo_bit drm_kms_helper ttm drm i2c_core
CPU 6
Pid: 47, comm: ksoftirqd/6 Tainted: G         C   3.7.3+ #37 Iron Systems Inc. EE2610R/X8ST3
RIP: 0010:[<ffff88040d7d8000>]  [<ffff88040d7d8000>] 0xffff88040d7d7fff
RSP: 0018:ffff88040d75bc00  EFLAGS: 00010282
RAX: ffff88040435cd80 RBX: ffff8803dd83e300 RCX: ffff8803dd83e300
RDX: 0000000000000000 RSI: 0000000000000002 RDI: ffff8803dd83e300
RBP: ffff88040d75bc28 R08: ffffffff8149c4cc R09: ffff88040d75bbf0
R10: dead000000200200 R11: dead000000100100 R12: ffff8803e10c88fc
R13: ffff8803dd83e300 R14: ffff88040d38e000 R15: 0000000000000000
FS:  0000000000000000(0000) GS:ffff88041fcc0000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: ffff88040d7d8000 CR3: 0000000001a0b000 CR4: 00000000000007e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process ksoftirqd/6 (pid: 47, threadinfo ffff88040d75a000, task ffff88040d751730)
Stack:
  ffffffff8149c783 ffff8803dd83e300 ffffffff8149c4cc ffff8803dd83e300
  ffff88040d38e000 ffff88040d75bc58 ffffffff8149cae8 0000000080000000
  0000000000000001 ffff8803dd83e300 ffff88040d38e000 ffff88040d75bc88
Call Trace:
  [<ffffffff8149c783>] ? ip_rcv_finish+0x2b7/0x2cf
  [<ffffffff8149c4cc>] ? inet_del_protocol+0x37/0x37
  [<ffffffff8149cae8>] NF_HOOK.clone.1+0x4c/0x53
  [<ffffffff8149cd73>] ip_rcv+0x237/0x268
  [<ffffffff81468c46>] __netif_receive_skb+0x487/0x530
  [<ffffffff81468de5>] process_backlog+0xf6/0x1d7
  [<ffffffff8146b19b>] net_rx_action+0xad/0x20c
  [<ffffffff8108d292>] __do_softirq+0x9c/0x161
  [<ffffffff8108d37a>] run_ksoftirqd+0x23/0x42
  [<ffffffff810a6f3b>] smpboot_thread_fn+0x253/0x258
  [<ffffffff810a6ce8>] ? test_ti_thread_flag.clone.0+0x11/0x11
  [<ffffffff8109ff60>] kthread+0xbf/0xc7
  [<ffffffff8109fea1>] ? __init_kthread_worker+0x37/0x37
  [<ffffffff815292bc>] ret_from_fork+0x7c/0xb0
  [<ffffffff8109fea1>] ? __init_kthread_worker+0x37/0x37
Code: 36 a4 36 6a ea 6a ea 6a ea 6a ea e9 81 e9 81 e9 81 e9 81 71 48 71 48 71 48 71 48 ea 50 ea 50 ea 50 ea 50 f7 e4 f7 e4 f7 e4 f7 e4 <22> 22 00 00 ad 4e ad de 
ff ff ff ff 00 00 00 00 ff ff ff ff ff
RIP  [<ffff88040d7d8000>] 0xffff88040d7d7fff
  RSP <ffff88040d75bc00>
CR2: ffff88040d7d8000
---[ end trace 1c131533c1de5e8b ]---

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

