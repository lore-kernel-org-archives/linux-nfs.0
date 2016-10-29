Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:25566 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932255AbcJ2QVI (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 29 Oct 2016 12:21:08 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Content-Type: text/plain; charset=us-ascii
Subject: svc_xprt_put is no longer BH-safe
Date: Sat, 29 Oct 2016 12:21:03 -0400
Message-Id: <1934654A-78D7-4180-A0AA-4B144254BFC2@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce-

I hit this lockdep splat this morning

Oct 29 11:38:25 klimt kernel: =================================
Oct 29 11:38:25 klimt kernel: [ INFO: inconsistent lock state ]
Oct 29 11:38:25 klimt kernel: 4.9.0-rc2-00003-g114ddae #9 Not tainted
Oct 29 11:38:25 klimt kernel: ---------------------------------
Oct 29 11:38:25 klimt kernel: inconsistent {SOFTIRQ-ON-W} -> {IN-SOFTIRQ-W} usage.
Oct 29 11:38:25 klimt kernel: swapper/6/0 [HC0[0]:SC1[1]:HE1:SE0] takes:
Oct 29 11:38:25 klimt kernel: (
Oct 29 11:38:25 klimt kernel: &(&xps->xps_lock)->rlock
Oct 29 11:38:25 klimt kernel: ){+.?...}
Oct 29 11:38:25 klimt kernel: , at: 
Oct 29 11:38:25 klimt kernel: [<ffffffffa0488056>] xprt_switch_free+0x26/0xb0 [sunrpc]
Oct 29 11:38:25 klimt kernel: {SOFTIRQ-ON-W} state was registered at:
Oct 29 11:38:25 klimt kernel:  
Oct 29 11:38:25 klimt kernel: [<ffffffff810e2483>] __lock_acquire+0x343/0x1670
Oct 29 11:38:25 klimt kernel:  
Oct 29 11:38:25 klimt kernel: [<ffffffff810e3c97>] lock_acquire+0x197/0x1f0
Oct 29 11:38:25 klimt kernel:  
Oct 29 11:38:25 klimt kernel: [<ffffffff8174cbf8>] _raw_spin_lock+0x38/0x50
Oct 29 11:38:25 klimt kernel:  
Oct 29 11:38:25 klimt kernel: [<ffffffffa0488056>] xprt_switch_free+0x26/0xb0 [sunrpc]
Oct 29 11:38:25 klimt kernel:  
Oct 29 11:38:25 klimt kernel: [<ffffffffa0488242>] xprt_switch_put+0x22/0x30 [sunrpc]
Oct 29 11:38:25 klimt kernel:  
Oct 29 11:38:25 klimt kernel: [<ffffffffa048492d>] svc_xprt_free+0x5d/0x80 [sunrpc]
Oct 29 11:38:25 klimt kernel:  
Oct 29 11:38:25 klimt kernel: [<ffffffffa048554a>] svc_xprt_release+0x12a/0x140 [sunrpc]
Oct 29 11:38:25 klimt kernel:  
Oct 29 11:38:25 klimt kernel: [<ffffffffa0487242>] svc_recv+0xcb2/0xed0 [sunrpc]
Oct 29 11:38:25 klimt kernel:  
Oct 29 11:38:25 klimt kernel: [<ffffffffa04d57b8>] nfsd+0xe8/0x160 [nfsd]
Oct 29 11:38:25 klimt kernel:  
Oct 29 11:38:25 klimt kernel: [<ffffffff810b267b>] kthread+0x10b/0x120
Oct 29 11:38:25 klimt kernel:  
Oct 29 11:38:25 klimt kernel: [<ffffffff8174d8ba>] ret_from_fork+0x2a/0x40
Oct 29 11:38:25 klimt kernel: irq event stamp: 483745258
Oct 29 11:38:25 klimt kernel: hardirqs last  enabled at (483745258): 
Oct 29 11:38:25 klimt kernel: [<ffffffff81093a45>] __local_bh_enable_ip+0x95/0xd0
Oct 29 11:38:25 klimt kernel: hardirqs last disabled at (483745257): 
Oct 29 11:38:25 klimt kernel: [<ffffffff81093a05>] __local_bh_enable_ip+0x55/0xd0
Oct 29 11:38:25 klimt kernel: softirqs last  enabled at (483744848): 
Oct 29 11:38:25 klimt kernel: [<ffffffff81092a52>] _local_bh_enable+0x42/0x50
Oct 29 11:38:25 klimt kernel: softirqs last disabled at (483744849): 
Oct 29 11:38:25 klimt kernel: [<ffffffff81093b4b>] irq_exit+0x5b/0xf0
Oct 29 11:38:25 klimt kernel: #012other info that might help us debug this:
Oct 29 11:38:25 klimt kernel: Possible unsafe locking scenario:
Oct 29 11:38:25 klimt kernel:       CPU0
Oct 29 11:38:25 klimt kernel:       ----
Oct 29 11:38:25 klimt kernel:  lock(
Oct 29 11:38:25 klimt kernel: &(&xps->xps_lock)->rlock
Oct 29 11:38:25 klimt kernel: );
Oct 29 11:38:25 klimt kernel:  <Interrupt>
Oct 29 11:38:25 klimt kernel:    lock(
Oct 29 11:38:25 klimt kernel: &(&xps->xps_lock)->rlock
Oct 29 11:38:25 klimt kernel: );
Oct 29 11:38:25 klimt kernel: #012 *** DEADLOCK ***
Oct 29 11:38:25 klimt kernel: no locks held by swapper/6/0.
Oct 29 11:38:25 klimt kernel: #012stack backtrace:
Oct 29 11:38:25 klimt kernel: CPU: 6 PID: 0 Comm: swapper/6 Not tainted 4.9.0-rc2-00003-g114ddae #9
Oct 29 11:38:25 klimt kernel: Hardware name: Supermicro Super Server/X10SRL-F, BIOS 1.0c 09/09/2015
Oct 29 11:38:25 klimt kernel: ffff88087bd83be8 ffffffff81392e51 ffff880857008040 ffffffff827e2500
Oct 29 11:38:25 klimt kernel: ffff88087bd83c38 ffffffff811b3e76 0000000000000001 0000000000000001
Oct 29 11:38:25 klimt kernel: 0000000000000000 0000000000000006 ffff880857008040 ffffffff810e1060
Oct 29 11:38:25 klimt kernel: Call Trace:
Oct 29 11:38:25 klimt kernel: <IRQ> 
Oct 29 11:38:25 klimt kernel: [<ffffffff81392e51>] dump_stack+0x85/0xc4
Oct 29 11:38:25 klimt kernel: [<ffffffff811b3e76>] print_usage_bug+0x1eb/0x1fc
Oct 29 11:38:25 klimt kernel: [<ffffffff810e1060>] ? print_irq_inversion_bug+0x200/0x200
Oct 29 11:38:25 klimt kernel: [<ffffffff810e1a65>] mark_lock+0x175/0x290
Oct 29 11:38:25 klimt kernel: [<ffffffff810e23cf>] __lock_acquire+0x28f/0x1670
Oct 29 11:38:25 klimt kernel: [<ffffffff810e3c97>] lock_acquire+0x197/0x1f0
Oct 29 11:38:25 klimt kernel: [<ffffffffa0488056>] ? xprt_switch_free+0x26/0xb0 [sunrpc]
Oct 29 11:38:25 klimt kernel: [<ffffffff8174cbf8>] _raw_spin_lock+0x38/0x50
Oct 29 11:38:25 klimt kernel: [<ffffffffa0488056>] ? xprt_switch_free+0x26/0xb0 [sunrpc]
Oct 29 11:38:25 klimt kernel: [<ffffffffa0488056>] xprt_switch_free+0x26/0xb0 [sunrpc]
Oct 29 11:38:25 klimt kernel: [<ffffffffa0488242>] xprt_switch_put+0x22/0x30 [sunrpc]
Oct 29 11:38:25 klimt kernel: [<ffffffffa048492d>] svc_xprt_free+0x5d/0x80 [sunrpc]
Oct 29 11:38:25 klimt kernel: [<ffffffffa048501d>] svc_xprt_put+0x1d/0x20 [sunrpc]
Oct 29 11:38:25 klimt kernel: [<ffffffffa05753db>] svc_rdma_wc_receive+0xcb/0xe0 [rpcrdma]
Oct 29 11:38:25 klimt kernel: [<ffffffffa0240d55>] __ib_process_cq+0x35/0xc0 [ib_core]
Oct 29 11:38:25 klimt kernel: [<ffffffffa0240ed2>] ib_poll_handler+0x22/0x60 [ib_core]
Oct 29 11:38:25 klimt kernel: [<ffffffff813c8bb5>] irq_poll_softirq+0x85/0x100
Oct 29 11:38:25 klimt kernel: [<ffffffff817507a9>] __do_softirq+0x1f9/0x425
Oct 29 11:38:25 klimt kernel: [<ffffffff81093b4b>] irq_exit+0x5b/0xf0
Oct 29 11:38:25 klimt kernel: [<ffffffff817502df>] do_IRQ+0xef/0x110
Oct 29 11:38:25 klimt kernel: [<ffffffff8174e016>] common_interrupt+0x96/0x96
Oct 29 11:38:25 klimt kernel: <EOI> 
Oct 29 11:38:25 klimt kernel: [<ffffffff815b996c>] ? cpuidle_enter_state+0x22c/0x300
Oct 29 11:38:25 klimt kernel: [<ffffffff815b9a77>] cpuidle_enter+0x17/0x20
Oct 29 11:38:25 klimt kernel: [<ffffffff810dbe7d>] call_cpuidle+0x3d/0x50
Oct 29 11:38:25 klimt kernel: [<ffffffff810dc13e>] cpu_startup_entry+0x19e/0x240
Oct 29 11:38:25 klimt kernel: [<ffffffff81059590>] start_secondary+0x160/0x1a0


In commit 39a9beab5acb83176e8b9a4f0778749a09341f1f ('rpc: share one xps between
all backchannels') you added:

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index f5572e3..4f01f63 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -136,6 +136,8 @@ static void svc_xprt_free(struct kref *kref)
        /* See comment on corresponding get in xs_setup_bc_tcp(): */
        if (xprt->xpt_bc_xprt)
                xprt_put(xprt->xpt_bc_xprt);
+       if (xprt->xpt_bc_xps)
+               xprt_switch_put(xprt->xpt_bc_xps);
        xprt->xpt_ops->xpo_free(xprt);
        module_put(owner);
 }

svc_xprt_free() is invoked by svc_xprt_put(). svc_xprt_put() is called
from svc_rdma in soft IRQ context (eg. svc_rdma_wc_receive).

However, xprt_switch_put() takes a spin lock (xps_lock) which is locked
everywhere without disabling BHs.

It looks to me like 39a9beab5acb makes svc_xprt_put() no longer BH-safe?
Not sure if svc_xprt_put() was intended to be BH-safe beforehand.

Maybe xprt_switch_put() could be invoked in ->xpo_free, but that seems
like a temporary solution.


--
Chuck Lever



