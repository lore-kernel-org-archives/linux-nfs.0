Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:57932 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757310Ab1FUTB0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Jun 2011 15:01:26 -0400
From: greearb@candelatech.com
To: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Ben Greear <greearb@candelatech.com>
Subject: [PATCH] nfs:  Fix xpt_ready list corruption.
Date: Tue, 21 Jun 2011 12:01:17 -0700
Message-Id: <1308682877-27490-1-git-send-email-greearb@candelatech.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Ben Greear <greearb@candelatech.com>

I see repeatable nfs server crashes in 2.6.39.1 and 3.0.0-rc3+.
I have not yet tested older builds.

The problem appears to be corrupted xpt_ready list entries:

WARNING: at /home/greearb/git/linux-2.6.linus/lib/list_debug.c:30 __list_add+0x68/0x80()
Hardware name: X7DBU
list_add corruption. prev->next should be next (ffff880222777e38), but was 6b6b6b6b6b6b6b6b. (prev=ffff88021cb8d190).
Modules linked in: xt_addrtype xt_TPROXY nf_tproxy_core xt_socket nf_defrag_ipv6 xt_set ip_set nfnetlink xt_connlimit macvlan pktgen fuse iscsi_tcp libiscsi_tcp libiscsi scsi_transport_iscsi ip6table_filter ip6_tables ebtable_nat ebtables stp llc nfsd nfs lockd fscache auth_rpcgss nfs_acl sunrpc ipv6 kvm uinput i5k_amb i5000_edac iTCO_wdt iTCO_vendor_support i2c_i801 ioatdma pcspkr edac_core e1000e shpchp microcode dca floppy radeon ttm drm_kms_helper drm hwmon i2c_algo_bit i2c_core [last unloaded: xt_connmark]
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

The test case is:

Create 300 mounts to the server (unique clients), have 150 writing,
150 reading at steady state.  We have each reader/writer going at
about 50kbps, 2k read/write size.

Then, repeatedly:
/etc/init.d/nfs restart
on the server.

We normally see crash within 2-5 restarts.  With this patch,
I did 20 successful restarts.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---

NOTE:  This needs review by someone who understands this
code better.  The code I re-added was first removed in around 2006
it seems.  Maybe the race is hard to hit in most cases, or maybe
something exacerbated it recently and that should be fixed instead
of the patch below.

:100644 100644 ab86b79... 178716f... M	net/sunrpc/svc_xprt.c
 net/sunrpc/svc_xprt.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index ab86b79..178716f 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -901,6 +901,7 @@ void svc_delete_xprt(struct svc_xprt *xprt)
 	spin_lock_bh(&serv->sv_lock);
 	if (!test_and_set_bit(XPT_DETACHED, &xprt->xpt_flags))
 		list_del_init(&xprt->xpt_list);
+	list_del_init(&xprt->xpt_ready);
 	/*
 	 * We used to delete the transport from whichever list
 	 * it's sk_xprt.xpt_ready node was on, but we don't actually
-- 
1.7.3.4

