Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:38878 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757400Ab1FQQyw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 Jun 2011 12:54:52 -0400
Date: Fri, 17 Jun 2011 12:54:51 -0400
To: larith <larith@go2.pl>
Cc: linux-nfs@vger.kernel.org
Subject: Re: rpc-srv/tcp: nfsd: got error -104 when sending 140 bytes -
 shutting down socket
Message-ID: <20110617165451.GB23399@fieldses.org>
References: <67100fe7.28c0fd91.4dfb22f0.e5a90@go2.pl>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <67100fe7.28c0fd91.4dfb22f0.e5a90@go2.pl>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Jun 17, 2011 at 11:48:32AM +0200, larith wrote:
> I have problem with nfs-kernel-server 1.1.2-6lenny2 on system Debian lenny. My kernel 2.6.26-bpo.1-xen-amd64 panic. NFS working on drbd 8.0.14-2+lenny1
> 
> [553662.371435] rpc-srv/tcp: nfsd: got error -104 when sending 140 bytes - shutting down socket

-104 is -ECONNRESET.

> [553662.371919] rpc-srv/tcp: nfsd: got error -32 when sending 8620 bytes - shutting down socket

And -32 is EPIPE.

> [553662.375095] rpc-srv/tcp: nfsd: got error -104 when sending 240 bytes - shutting down socket

Without looking into it carefully I would have guessed that means the
client shut down the connection, but I don't know--that 

> [578802.236483] kswapd0: page allocation failure. order:0, mode:0x20

Hm.  An order 0 page allocation should be rare.  Looks like 0x20 is
__GFP_HIGH == GFP_ATOMIC?

Beats me....--b.

> [578802.236505] Pid: 118, comm: kswapd0 Not tainted 2.6.26-bpo.1-xen-amd64 #1
> [578802.236511]
> [578802.236512] Call Trace:
> [578802.236518]  <IRQ>  [<ffffffff80269dc6>] __alloc_pages_internal+0x399/0x3b2
> [578802.236548]  [<ffffffff80287bb1>] cache_alloc_refill+0x2ad/0x564
> [578802.236556]  [<ffffffff80287f05>] __kmalloc+0x9d/0xf8
> [578802.236564]  [<ffffffff803c2c07>] __alloc_skb+0x56/0x11c
> [578802.236572]  [<ffffffff803fb86d>] tcp_send_ack+0x28/0xca
> [578802.236579]  [<ffffffff803fa770>] tcp_rcv_established+0x842/0x8d2
> [578802.236587]  [<ffffffff80400208>] tcp_v4_do_rcv+0x2bd/0x492
> [578802.236600]  [<ffffffff803e1c2c>] nf_iterate+0x41/0x7d
> [578802.236607]  [<ffffffff80229f63>] check_preempt_wakeup+0xbd/0xe9
> [578802.236614]  [<ffffffff803ee587>] __inet_lookup_established+0xf1/0x192
> [578802.236622]  [<ffffffff8040237a>] tcp_v4_rcv+0x69b/0x701
> [578802.236629]  [<ffffffff803e7523>] ip_local_deliver_finish+0x120/0x1dd
> [578802.236636]  [<ffffffff803e73e0>] ip_rcv_finish+0x300/0x323
> [578802.236644]  [<ffffffff803911b6>] netif_poll+0x9c8/0xc1a
> [578802.236652]  [<ffffffff802fee41>] elv_next_request+0x1f0/0x200
> [578802.236662]  [<ffffffff803c99c5>] net_rx_action+0xd9/0x24c
> [578802.236670]  [<ffffffff80231f30>] __do_softirq+0x77/0x103
> [578802.236677]  [<ffffffff8020c13c>] call_softirq+0x1c/0x28
> [578802.236684]  [<ffffffff8020e0a0>] do_softirq+0x55/0xbb
> [578802.236690]  [<ffffffff8020e183>] do_IRQ+0x7d/0x9a
> [578802.236704]  [<ffffffff8037ec44>] evtchn_do_upcall+0x13c/0x1fb
> [578802.236711]  [<ffffffff8020bbde>] do_hypervisor_callback+0x1e/0x30
> [578802.236716]  <EOI>  [<ffffffff8037df12>] force_evtchn_callback+0xa/0xb
> [578802.236768]  [<ffffffffa0227e7f>] :xfs:xfs_finish_reclaim+0x187/0x195
> [578802.236801]  [<ffffffffa023482a>] :xfs:xfs_fs_clear_inode+0xe2/0x103
> [578802.236810]  [<ffffffff8029dcc4>] clear_inode+0xad/0x104
> [578802.236816]  [<ffffffff8029e412>] dispose_list+0x56/0x132
> [578802.236823]  [<ffffffff8029e6fe>] shrink_icache_memory+0x210/0x23f
> [578802.236831]  [<ffffffff8026eabe>] shrink_slab+0xe2/0x15a
> [578802.236837]  [<ffffffff8026f248>] kswapd+0x325/0x4ac
> [578802.236845]  [<ffffffff8026d657>] isolate_pages_global+0x0/0x2f
> [578802.236853]  [<ffffffff8023fa2d>] autoremove_wake_function+0x0/0x2e
> [578802.236860]  [<ffffffff8022178f>] __wake_up_common+0x41/0x74
> [578802.236868]  [<ffffffff8026ef23>] kswapd+0x0/0x4ac
> [578802.236874]  [<ffffffff8023f8ff>] kthread+0x47/0x74
> [578802.236881]  [<ffffffff80228580>] schedule_tail+0x27/0x5c
> [578802.236887]  [<ffffffff8020be28>] child_rip+0xa/0x12
> [578802.236895]  [<ffffffff8023f8b8>] kthread+0x0/0x74
> [578802.236900]  [<ffffffff8020be1e>] child_rip+0x0/0x12
> 
> 
> is some known bug ?
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
