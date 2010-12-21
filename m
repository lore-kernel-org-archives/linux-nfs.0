From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: lock warning in pnfs-all
Date: Tue, 21 Dec 2010 13:35:03 -0500
Message-ID: <20101221183503.GB19349@fieldses.org>
References: <20101221134556.GA4408@fieldses.org>
 <176F3D53-A9D3-45D6-85B2-A7478AC3A6F7@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Benny Halevy <bhalevy@panasas.com>, linux-nfs@vger.kernel.org
To: Andy Adamson <andros@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:36212 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752678Ab0LUSfG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Dec 2010 13:35:06 -0500
In-Reply-To: <176F3D53-A9D3-45D6-85B2-A7478AC3A6F7@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Dec 21, 2010 at 01:34:01PM -0500, Andy Adamson wrote:
> Hi Bruce
> 
> My latest patch set fixes this - nfs4_set_callback_session was using spin_lock instead of spin_lock_bh.

OK, thanks.--b.

> 
> -->Andy
> 
> On Dec 21, 2010, at 8:45 AM, J. Bruce Fields wrote:
> 
> > Tests otherwise complete fine.  This may also be in upstream, I haven't
> > checked.
> > 
> > --b.
> > 
> > Dec 21 04:17:33 plink2 kernel: =================================
> > Dec 21 04:17:33 plink2 kernel: [ INFO: inconsistent lock state ]
> > Dec 21 04:17:33 plink2 kernel: 2.6.37-rc5-pnfs-00434-g89c4ccf #2000
> > Dec 21 04:17:33 plink2 kernel: ---------------------------------
> > Dec 21 04:17:33 plink2 kernel: inconsistent {IN-SOFTIRQ-W} -> {SOFTIRQ-ON-W} usage.
> > Dec 21 04:17:33 plink2 kernel: 192.168.122.101/7686 [HC0[0]:SC0[0]:HE1:SE1] takes:
> > Dec 21 04:17:33 plink2 kernel: (&(&serv->sv_cb_lock)->rlock){+.?...}, at: [<ffffffff8125adb1>] nfs4_set_callback_sessionid+0xb1/0x190
> > Dec 21 04:17:33 plink2 kernel: {IN-SOFTIRQ-W} state was registered at:
> > Dec 21 04:17:33 plink2 kernel:  [<ffffffff8106de76>] __lock_acquire+0xba6/0x1c20
> > Dec 21 04:17:33 plink2 kernel:  [<ffffffff8106ef82>] lock_acquire+0x92/0x180
> > Dec 21 04:17:33 plink2 kernel:  [<ffffffff819d2cfb>] _raw_spin_lock+0x3b/0x50
> > Dec 21 04:17:33 plink2 kernel:  [<ffffffff8196d280>] xs_tcp_data_recv+0x650/0xba0
> > Dec 21 04:17:33 plink2 kernel:  [<ffffffff818e4396>] tcp_read_sock+0x116/0x240
> > Dec 21 04:17:33 plink2 kernel:  [<ffffffff8196c8e2>] xs_tcp_data_ready+0x72/0xb0
> > Dec 21 04:17:33 plink2 kernel:  [<ffffffff818eb37f>] tcp_data_queue+0x8cf/0xe80
> > Dec 21 04:17:33 plink2 kernel:  [<ffffffff818ee766>] tcp_rcv_established+0xf6/0x6b0
> > Dec 21 04:17:33 plink2 kernel:  [<ffffffff818f5d9d>] tcp_v4_do_rcv+0xcd/0x250
> > Dec 21 04:17:33 plink2 kernel:  [<ffffffff818f679e>] tcp_v4_rcv+0x87e/0xae0
> > Dec 21 04:17:33 plink2 kernel:  [<ffffffff818d51e9>] ip_local_deliver_finish+0xa9/0x270
> > Dec 21 04:17:33 plink2 kernel:  [<ffffffff818d5448>] ip_local_deliver+0x98/0xa0
> > Dec 21 04:17:33 plink2 kernel:  [<ffffffff818d4b48>] ip_rcv_finish+0x128/0x450
> > Dec 21 04:17:33 plink2 kernel:  [<ffffffff818d5075>] ip_rcv+0x205/0x2d0
> > Dec 21 04:17:33 plink2 kernel:  [<ffffffff818a5ee2>] __netif_receive_skb+0x2e2/0x3d0
> > Dec 21 04:17:33 plink2 kernel:  [<ffffffff818a6176>] netif_receive_skb+0x46/0x50
> > Dec 21 04:17:33 plink2 kernel:  [<ffffffff8176f755>] virtnet_poll+0x535/0x6b0
> > Dec 21 04:17:33 plink2 kernel:  [<ffffffff818a64f5>] net_rx_action+0xc5/0x260
> > Dec 21 04:17:33 plink2 kernel:  [<ffffffff81040ee4>] __do_softirq+0xe4/0x280
> > Dec 21 04:17:33 plink2 kernel:  [<ffffffff810032ea>] call_softirq+0x1a/0x50
> > Dec 21 04:17:33 plink2 kernel:  [<ffffffff8100440d>] do_softirq+0x8d/0xc0
> > Dec 21 04:17:33 plink2 kernel:  [<ffffffff81040185>] irq_exit+0x55/0x70
> > Dec 21 04:17:33 plink2 kernel:  [<ffffffff819da8f3>] do_IRQ+0x63/0xd0
> > Dec 21 04:17:33 plink2 kernel:  [<ffffffff819d3cd3>] ret_from_intr+0x0/0xe
> > Dec 21 04:17:33 plink2 kernel:  [<ffffffff8100176b>] cpu_idle+0x6b/0x120
> > Dec 21 04:17:33 plink2 kernel:  [<ffffffff819bcaaf>] rest_init+0xcf/0xe0
> > Dec 21 04:17:33 plink2 kernel:  [<ffffffff81ed6c08>] start_kernel+0x358/0x363
> > Dec 21 04:17:33 plink2 kernel:  [<ffffffff81ed6321>] x86_64_start_reservations+0x131/0x135
> > Dec 21 04:17:33 plink2 kernel:  [<ffffffff81ed6417>] x86_64_start_kernel+0xf2/0xf9
> > Dec 21 04:17:33 plink2 kernel: irq event stamp: 187
> > Dec 21 04:17:33 plink2 kernel: hardirqs last  enabled at (187): [<ffffffff810e5585>] kmem_cache_alloc_notrace+0x125/0x1b0
> > Dec 21 04:17:33 plink2 kernel: hardirqs last disabled at (186): [<ffffffff810e54e7>] kmem_cache_alloc_notrace+0x87/0x1b0
> > Dec 21 04:17:33 plink2 kernel: softirqs last  enabled at (176): [<ffffffff8196e713>] rpc_wake_up_next+0x103/0x1e0
> > Dec 21 04:17:33 plink2 kernel: softirqs last disabled at (174): [<ffffffff819d2fd6>] _raw_spin_lock_bh+0x16/0x50
> > Dec 21 04:17:33 plink2 kernel:
> > Dec 21 04:17:33 plink2 kernel: other info that might help us debug this:
> > Dec 21 04:17:33 plink2 kernel: no locks held by 192.168.122.101/7686.
> > Dec 21 04:17:33 plink2 kernel:
> > Dec 21 04:17:33 plink2 kernel: stack backtrace:
> > Dec 21 04:17:33 plink2 kernel: Pid: 7686, comm: 192.168.122.101 Not tainted 2.6.37-rc5-pnfs-00434-g89c4ccf #2000
> > Dec 21 04:17:33 plink2 kernel: Call Trace:
> > Dec 21 04:17:33 plink2 kernel: [<ffffffff8106b2d2>] print_usage_bug+0x182/0x1d0
> > Dec 21 04:17:33 plink2 kernel: [<ffffffff8106b73b>] mark_lock+0x41b/0x630
> > Dec 21 04:17:33 plink2 kernel: [<ffffffff8106deec>] __lock_acquire+0xc1c/0x1c20
> > Dec 21 04:17:33 plink2 kernel: [<ffffffff810b2107>] ? mempool_free_slab+0x17/0x20
> > Dec 21 04:17:33 plink2 kernel: [<ffffffff810b21bd>] ? mempool_free+0x8d/0xa0
> > Dec 21 04:17:33 plink2 kernel: [<ffffffff8196d8b0>] ? rpc_free_task+0x50/0x80
> > Dec 21 04:17:33 plink2 kernel: [<ffffffff8106ef82>] lock_acquire+0x92/0x180
> > Dec 21 04:17:33 plink2 kernel: [<ffffffff8125adb1>] ? nfs4_set_callback_sessionid+0xb1/0x190
> > Dec 21 04:17:33 plink2 kernel: [<ffffffff8125ad6c>] ? nfs4_set_callback_sessionid+0x6c/0x190
> > Dec 21 04:17:33 plink2 kernel: [<ffffffff810314d1>] ? get_parent_ip+0x11/0x50
> > Dec 21 04:17:33 plink2 kernel: [<ffffffff819d2cfb>] _raw_spin_lock+0x3b/0x50
> > Dec 21 04:17:33 plink2 kernel: [<ffffffff8125adb1>] ? nfs4_set_callback_sessionid+0xb1/0x190
> > Dec 21 04:17:33 plink2 kernel: [<ffffffff8125adb1>] nfs4_set_callback_sessionid+0xb1/0x190
> > Dec 21 04:17:33 plink2 kernel: [<ffffffff8124a78f>] ? nfs4_proc_create_session+0x15f/0x210
> > Dec 21 04:17:33 plink2 kernel: [<ffffffff81257c37>] nfs41_init_clientid+0x67/0xf0
> > Dec 21 04:17:33 plink2 kernel: [<ffffffff8125731d>] nfs4_run_state_manager+0x27d/0x5a0
> > Dec 21 04:17:33 plink2 kernel: [<ffffffff812570a0>] ? nfs4_run_state_manager+0x0/0x5a0
> > Dec 21 04:17:33 plink2 kernel: [<ffffffff8105ab56>] kthread+0x96/0xa0
> > Dec 21 04:17:33 plink2 kernel: [<ffffffff810031f4>] kernel_thread_helper+0x4/0x10
> > Dec 21 04:17:33 plink2 kernel: [<ffffffff81033221>] ? finish_task_switch.clone.3+0x81/0xe0
> > Dec 21 04:17:33 plink2 kernel: [<ffffffff819d3d7e>] ? restore_args+0x0/0x30
> > Dec 21 04:17:33 plink2 kernel: [<ffffffff8105aac0>] ? kthread+0x0/0xa0
> > Dec 21 04:17:33 plink2 kernel: [<ffffffff810031f0>] ? kernel_thread_helper+0x0/0x10
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
