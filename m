Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:46659 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755932Ab1FTWmh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Jun 2011 18:42:37 -0400
Message-ID: <4DFFCCDC.2070106@candelatech.com>
Date: Mon, 20 Jun 2011 15:42:36 -0700
From: Ben Greear <greearb@candelatech.com>
To: linux-nfs@vger.kernel.org,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Subject: NFS crash in un-modified 3.0.0-rc3+, list corruption.
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

This machine is acting as a server.  It is from linux-2.6, pulled
today:

commit de505e709ffb09a7382ca8e0d8c7dbb171ba5830

We are hitting it with 200 clients reading and writing, mounting and un-mounting.
This bug is fairly reproducible (twice today).

Large amounts of debugging options are enabled.


NFSD: Using /var/lib/nfs/v4recovery as the NFSv4 state recovery directory
NFSD: starting 90-second grace period
------------[ cut here ]------------
WARNING: at /home/greearb/git/linux-2.6.linus/lib/list_debug.c:30 __list_add+0x68/0x80()
Hardware name: X7DBU
list_add corruption. prev->next should be next (ffff880222777e38), but was 6b6b6b6b6b6b6b6b. (prev=ffff88021cb8d190).
Modules linked in: xt_addrtype xt_TPROXY nf_tproxy_core xt_socket nf_defrag_ipv6 xt_set ip_set nfnetlink xt_connlimit macvlan pktgen fuse iscsi_tcp libiscsi_tcp 
libiscsi scsi_transport_iscsi ip6table_filter ip6_tables ebtable_nat ebtables stp llc nfsd nfs lockd fscache auth_rpcgss nfs_acl sunrpc ipv6 kvm uinput i5k_amb 
i5000_edac iTCO_wdt iTCO_vendor_support i2c_i801 ioatdma pcspkr edac_core e1000e shpchp microcode dca floppy radeon ttm drm_kms_helper drm hwmon i2c_algo_bit 
i2c_core [last unloaded: xt_connmark]
Pid: 3347, comm: nfsd Not tainted 3.0.0-rc3+ #1
Call Trace:
  <IRQ>  [<ffffffff81049f72>] warn_slowpath_common+0x80/0x98
  [<ffffffff8104a01e>] warn_slowpath_fmt+0x41/0x43
  [<ffffffff81232ea4>] __list_add+0x68/0x80
  [<ffffffffa029958a>] ? svc_xprt_enqueue+0x91/0x1c0 [sunrpc]
  [<ffffffffa029969b>] svc_xprt_enqueue+0x1a2/0x1c0 [sunrpc]
  [<ffffffff8140e170>] ? tcp_rcv_state_process+0x89e/0x8de
  [<ffffffffa028f2b4>] svc_tcp_listen_data_ready+0x4c/0x8c [sunrpc]
  [<ffffffff81416b3c>] tcp_child_process+0x61/0x109
  [<ffffffff814150c1>] tcp_v4_do_rcv+0x2bf/0x33c
  [<ffffffff81415f20>] ? tcp_v4_rcv+0x2f3/0x7a2
  [<ffffffff814160e4>] tcp_v4_rcv+0x4b7/0x7a2
  [<ffffffff813f8502>] ? ip_local_deliver_finish+0x46/0x246
  [<ffffffff813f866d>] ip_local_deliver_finish+0x1b1/0x246
  [<ffffffff813f8502>] ? ip_local_deliver_finish+0x46/0x246
  [<ffffffff813f84bc>] ? xfrm4_policy_check.clone.0+0x5c/0x5c
  [<ffffffff813f874e>] NF_HOOK.clone.1+0x4c/0x53
  [<ffffffff813f879e>] ip_local_deliver+0x49/0x4d
  [<ffffffff813f82db>] ip_rcv_finish+0x330/0x35a
  [<ffffffff813f7fab>] ? skb_dst+0x41/0x41
  [<ffffffff813f874e>] NF_HOOK.clone.1+0x4c/0x53
  [<ffffffff813f89d2>] ip_rcv+0x230/0x25e
  [<ffffffff813bfed7>] __netif_receive_skb+0x502/0x561
  [<ffffffff813c5356>] netif_receive_skb+0x7c/0x83
  [<ffffffff813baadb>] ? __netdev_alloc_skb+0x1d/0x3a
  [<ffffffff813c5381>] napi_skb_finish+0x24/0x3b
  [<ffffffff813c5b60>] napi_gro_receive+0x2a/0x2f
  [<ffffffffa01bb92f>] e1000_receive_skb+0x50/0x5b [e1000e]
  [<ffffffffa01bdbb1>] e1000_clean_rx_irq+0x1fb/0x28d [e1000e]
  [<ffffffffa01be067>] e1000_clean+0x75/0x23b [e1000e]
  [<ffffffff813c560a>] net_rx_action+0xc6/0x235
  [<ffffffff810507fa>] __do_softirq+0x117/0x280
  [<ffffffff810754aa>] ? tick_dev_program_event+0x37/0xf8
  [<ffffffff8106a879>] ? hrtimer_interrupt+0x12e/0x1c0
  [<ffffffff81485d1c>] call_softirq+0x1c/0x30
  [<ffffffff8100bbfe>] do_softirq+0x46/0x9e
  [<ffffffff810500b3>] irq_exit+0x4e/0xba
  [<ffffffff81023291>] smp_apic_timer_interrupt+0x85/0x93
  [<ffffffffa0299a6e>] ? svc_delete_xprt+0x90/0xf4 [sunrpc]
  [<ffffffff814854d3>] apic_timer_interrupt+0x13/0x20
  <EOI>  [<ffffffff81050025>] ? _local_bh_enable_ip+0xc6/0xec
  [<ffffffff81050054>] local_bh_enable_ip+0x9/0xb
  [<ffffffff8147e643>] _raw_spin_unlock_bh+0x39/0x3e
  [<ffffffffa0299a6e>] svc_delete_xprt+0x90/0xf4 [sunrpc]
  [<ffffffffa0299af7>] svc_close_all+0x25/0x3e [sunrpc]
  [<ffffffffa028e194>] svc_destroy+0x77/0x136 [sunrpc]
  [<ffffffffa028e2eb>] svc_exit_thread+0x98/0xa1 [sunrpc]
  [<ffffffffa0364836>] ? nfsd_svc+0x183/0x183 [nfsd]
  [<ffffffffa036495a>] nfsd+0x124/0x13e [nfsd]
  [<ffffffff81066e10>] kthread+0x7d/0x85
  [<ffffffff81485c24>] kernel_thread_helper+0x4/0x10
  [<ffffffff8147ee18>] ? retint_restore_args+0x13/0x13
  [<ffffffff81066d93>] ? __init_kthread_worker+0x56/0x56
  [<ffffffff81485c20>] ? gs_change+0x13/0x13
---[ end trace 6a1345b5521d6905 ]---
=============================================================================
BUG kmalloc-4096: Poison overwritten
-----------------------------------------------------------------------------

INFO: 0xffff88021cb8d190-0xffff88021cb8d197. First byte 0x48 instead of 0x6b
INFO: Allocated in seq_read+0xc1/0x368 age=7 cpu=6 pid=5924
INFO: Freed in seq_release+0x18/0x26 age=7 cpu=6 pid=5924
INFO: Slab 0xffffea00076485c0 objects=7 used=0 fp=0xffff88021cb8a090 flags=0x40000000004080
INFO: Object 0xffff88021cb8d168 @offset=20840 fp=0xffff88021cb88000

Bytes b4 0xffff88021cb8d158:  79 76 6e 00 01 00 00 00 5a 5a 5a 5a 5a 5a 5a 5a yvn.....ZZZZZZZZ
   Object 0xffff88021cb8d168:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d178:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d188:  6b 6b 6b 6b 6b 6b 6b 6b 48 41 7f 0f 02 88 ff ff kkkkkkkkHA....ÿÿ
   Object 0xffff88021cb8d198:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d1a8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d1b8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d1c8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d1d8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d1e8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d1f8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d208:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d218:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d228:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d238:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d248:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d258:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d268:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d278:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d288:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d298:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d2a8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d2b8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d2c8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d2d8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d2e8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d2f8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d308:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d318:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d328:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d338:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d348:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d358:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d368:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d378:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d388:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d398:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d3a8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d3b8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d3c8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d3d8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d3e8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d3f8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d408:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d418:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d428:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d438:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d448:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d458:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d468:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d478:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d488:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d498:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d4a8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d4b8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d4c8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d4d8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d4e8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d4f8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d508:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d518:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d528:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d538:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d548:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d558:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d568:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d578:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d588:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d598:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d5a8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d5b8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d5c8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d5d8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d5e8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d5f8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d608:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d618:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d628:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d638:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d648:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d658:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d668:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d678:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d688:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d698:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d6a8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d6b8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d6c8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d6d8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d6e8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d6f8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d708:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d718:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d728:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d738:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d748:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d758:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d768:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d778:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d788:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d798:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d7a8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d7b8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d7c8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d7d8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d7e8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d7f8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d808:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d818:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d828:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d838:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d848:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d858:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d868:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d878:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d888:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d898:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d8a8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d8b8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d8c8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d8d8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d8e8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d8f8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d908:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d918:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d928:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d938:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d948:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d958:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d968:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d978:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d988:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d998:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d9a8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d9b8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d9c8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d9d8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d9e8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8d9f8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8da08:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8da18:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8da28:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8da38:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8da48:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8da58:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8da68:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8da78:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8da88:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8da98:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8daa8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8dab8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8dac8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8dad8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8dae8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8daf8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8db08:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8db18:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8db28:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8db38:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8db48:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8db58:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8db68:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8db78:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8db88:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8db98:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8dba8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8dbb8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8dbc8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8dbd8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8dbe8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8dbf8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8dc08:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8dc18:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8dc28:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8dc38:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8dc48:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8dc58:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8dc68:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8dc78:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8dc88:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8dc98:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8dca8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8dcb8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8dcc8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8dcd8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8dce8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8dcf8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8dd08:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8dd18:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8dd28:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8dd38:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8dd48:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8dd58:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8dd68:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8dd78:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8dd88:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8dd98:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8dda8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8ddb8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8ddc8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8ddd8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8dde8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8ddf8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8de08:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8de18:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8de28:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8de38:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8de48:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8de58:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8de68:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8de78:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8de88:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8de98:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8dea8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8deb8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8dec8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8ded8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8dee8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8def8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8df08:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8df18:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8df28:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8df38:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8df48:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8df58:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8df68:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8df78:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8df88:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8df98:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8dfa8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8dfb8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8dfc8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8dfd8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8dfe8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8dff8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8e008:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8e018:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8e028:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8e038:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8e048:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8e058:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8e068:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8e078:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8e088:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8e098:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8e0a8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8e0b8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8e0c8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8e0d8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8e0e8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8e0f8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8e108:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8e118:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8e128:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8e138:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8e148:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
   Object 0xffff88021cb8e158:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5 kkkkkkkkkkkkkkk¥
  Redzone 0xffff88021cb8e168:  bb bb bb bb bb bb bb bb                         »»»»»»»»
  Padding 0xffff88021cb8e1a8:  5a 5a 5a 5a 5a 5a 5a 5a                         ZZZZZZZZ
Pid: 3347, comm: nfsd Tainted: G        W   3.0.0-rc3+ #1
Call Trace:
  [<ffffffff811054f4>] print_trailer+0x12e/0x137
  [<ffffffff811059dd>] check_bytes_and_report+0xb9/0xfd
  [<ffffffff81105ad6>] check_object+0xb5/0x192
  [<ffffffff81105c49>] __free_slab+0x96/0x13a
  [<ffffffff81105d2e>] discard_slab+0x41/0x43
  [<ffffffff8110728b>] __slab_free+0x143/0x150
  [<ffffffffa028edf1>] ? svc_sock_free+0x4d/0x51 [sunrpc]
  [<ffffffffa028edf1>] ? svc_sock_free+0x4d/0x51 [sunrpc]
  [<ffffffff81107cbb>] kfree+0x107/0x13a
  [<ffffffffa028edf1>] svc_sock_free+0x4d/0x51 [sunrpc]
  [<ffffffffa029a799>] svc_xprt_free+0x60/0x70 [sunrpc]
  [<ffffffffa029a739>] ? svc_recv+0x7fc/0x7fc [sunrpc]
  [<ffffffff812265da>] kref_put+0x43/0x4d
  [<ffffffffa02999dc>] svc_xprt_put+0x14/0x16 [sunrpc]
  [<ffffffffa0299ac9>] svc_delete_xprt+0xeb/0xf4 [sunrpc]
  [<ffffffffa0299af7>] svc_close_all+0x25/0x3e [sunrpc]
  [<ffffffffa028e194>] svc_destroy+0x77/0x136 [sunrpc]
  [<ffffffffa028e2eb>] svc_exit_thread+0x98/0xa1 [sunrpc]
  [<ffffffffa0364836>] ? nfsd_svc+0x183/0x183 [nfsd]
  [<ffffffffa036495a>] nfsd+0x124/0x13e [nfsd]
  [<ffffffff81066e10>] kthread+0x7d/0x85
  [<ffffffff81485c24>] kernel_thread_helper+0x4/0x10
  [<ffffffff8147ee18>] ? retint_restore_args+0x13/0x13
  [<ffffffff81066d93>] ? __init_kthread_worker+0x56/0x56
  [<ffffffff81485c20>] ? gs_change+0x13/0x13
FIX kmalloc-4096: Restoring 0xffff88021cb8d190-0xffff88021cb8d197=0x6b

------------[ cut here ]------------
WARNING: at /home/greearb/git/linux-2.6.linus/lib/list_debug.c:30 __list_add+0x68/0x80()
Hardware name: X7DBU
list_add corruption. prev->next should be next (ffff880222777e38), but was 6b6b6b6b6b6b6b6b. (prev=ffff88021cbb1070).
Modules linked in: xt_addrtype xt_TPROXY nf_tproxy_core xt_socket nf_defrag_ipv6 xt_set ip_set nfnetlink xt_connlimit macvlan pktgen fuse iscsi_tcp libiscsi_tcp 
libiscsi scsi_transport_iscsi ip6table_filter ip6_tables ebtable_nat ebtables stp llc nfsd nfs lockd fscache auth_rpcgss nfs_acl sunrpc ipv6 kvm uinput i5k_amb 
i5000_edac iTCO_wdt iTCO_vendor_support i2c_i801 ioatdma pcspkr edac_core e1000e shpchp microcode dca floppy radeon ttm drm_kms_helper drm hwmon i2c_algo_bit 
i2c_core [last unloaded: xt_connmark]
Pid: 3347, comm: nfsd Tainted: G        W   3.0.0-rc3+ #1
Call Trace:
  <IRQ>  [<ffffffff81049f72>] warn_slowpath_common+0x80/0x98
  [<ffffffff8104a01e>] warn_slowpath_fmt+0x41/0x43
  [<ffffffff81232ea4>] __list_add+0x68/0x80
  [<ffffffffa029958a>] ? svc_xprt_enqueue+0x91/0x1c0 [sunrpc]
  [<ffffffffa029969b>] svc_xprt_enqueue+0x1a2/0x1c0 [sunrpc]
  [<ffffffffa028f1a7>] svc_tcp_data_ready+0x54/0x7f [sunrpc]
  [<ffffffff8140a677>] tcp_data_queue+0x491/0xa3d
  [<ffffffff813ffc7e>] ? inet_unhash+0xab/0xab
  [<ffffffff81078c85>] ? mark_lock+0x2d/0x22d
  [<ffffffff8140d875>] tcp_rcv_established+0x641/0x69e
  [<ffffffff81414f97>] tcp_v4_do_rcv+0x195/0x33c
  [<ffffffff8147e154>] ? _raw_spin_lock_nested+0x42/0x49
  [<ffffffff81415f20>] ? tcp_v4_rcv+0x2f3/0x7a2
  [<ffffffff814160e4>] tcp_v4_rcv+0x4b7/0x7a2
  [<ffffffff813f8502>] ? ip_local_deliver_finish+0x46/0x246
  [<ffffffff813f866d>] ip_local_deliver_finish+0x1b1/0x246
  [<ffffffff813f8502>] ? ip_local_deliver_finish+0x46/0x246
  [<ffffffff813f84bc>] ? xfrm4_policy_check.clone.0+0x5c/0x5c
  [<ffffffff813f874e>] NF_HOOK.clone.1+0x4c/0x53
  [<ffffffff813f879e>] ip_local_deliver+0x49/0x4d
  [<ffffffff813f82db>] ip_rcv_finish+0x330/0x35a
  [<ffffffff813f7fab>] ? skb_dst+0x41/0x41
  [<ffffffff813f874e>] NF_HOOK.clone.1+0x4c/0x53
  [<ffffffff813f89d2>] ip_rcv+0x230/0x25e
  [<ffffffff813bfed7>] __netif_receive_skb+0x502/0x561
  [<ffffffff813c5356>] netif_receive_skb+0x7c/0x83
  [<ffffffff8107a2a7>] ? __lock_acquire+0x39f/0xdd5
  [<ffffffff813c5381>] napi_skb_finish+0x24/0x3b
  [<ffffffff813c5b60>] napi_gro_receive+0x2a/0x2f
  [<ffffffffa01bb92f>] e1000_receive_skb+0x50/0x5b [e1000e]
  [<ffffffffa01bdbb1>] e1000_clean_rx_irq+0x1fb/0x28d [e1000e]
  [<ffffffffa01be067>] e1000_clean+0x75/0x23b [e1000e]
  [<ffffffff813c560a>] net_rx_action+0xc6/0x235
  [<ffffffff810507fa>] __do_softirq+0x117/0x280
  [<ffffffff81485d1c>] call_softirq+0x1c/0x30
  [<ffffffff8100bbfe>] do_softirq+0x46/0x9e
  [<ffffffff810500b3>] irq_exit+0x4e/0xba
  [<ffffffff8100b563>] do_IRQ+0x97/0xae
  [<ffffffff8147ed53>] common_interrupt+0x13/0x13
  <EOI>  [<ffffffff81111119>] ? mem_cgroup_bad_page_check+0x2/0x34
  [<ffffffff810cf2fa>] ? free_pages_prepare+0xcf/0x1b2
  [<ffffffff810cf3fa>] __free_pages_ok+0x1d/0xd9
  [<ffffffff810cf6ca>] __free_pages+0x2a/0x2c
  [<ffffffff81105cde>] __free_slab+0x12b/0x13a
  [<ffffffff81105d2e>] discard_slab+0x41/0x43
  [<ffffffff8110728b>] __slab_free+0x143/0x150
  [<ffffffffa028edf1>] ? svc_sock_free+0x4d/0x51 [sunrpc]
  [<ffffffffa028edf1>] ? svc_sock_free+0x4d/0x51 [sunrpc]
  [<ffffffff81107cbb>] kfree+0x107/0x13a
  [<ffffffffa028edf1>] svc_sock_free+0x4d/0x51 [sunrpc]
  [<ffffffffa029a799>] svc_xprt_free+0x60/0x70 [sunrpc]
  [<ffffffffa029a739>] ? svc_recv+0x7fc/0x7fc [sunrpc]
  [<ffffffff812265da>] kref_put+0x43/0x4d
  [<ffffffffa02999dc>] svc_xprt_put+0x14/0x16 [sunrpc]
  [<ffffffffa0299ac9>] svc_delete_xprt+0xeb/0xf4 [sunrpc]
  [<ffffffffa0299af7>] svc_close_all+0x25/0x3e [sunrpc]
  [<ffffffffa028e194>] svc_destroy+0x77/0x136 [sunrpc]
  [<ffffffffa028e2eb>] svc_exit_thread+0x98/0xa1 [sunrpc]
  [<ffffffffa0364836>] ? nfsd_svc+0x183/0x183 [nfsd]
  [<ffffffffa036495a>] nfsd+0x124/0x13e [nfsd]
  [<ffffffff81066e10>] kthread+0x7d/0x85
  [<ffffffff81485c24>] kernel_thread_helper+0x4/0x10
  [<ffffffff8147ee18>] ? retint_restore_args+0x13/0x13
  [<ffffffff81066d93>] ? __init_kthread_worker+0x56/0x56
  [<ffffffff81485c20>] ? gs_change+0x13/0x13
---[ end trace 6a1345b5521d6906 ]---
nfsd: last server has exited, flushing export cache

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

