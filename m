From: Suresh Jayaraman <sjayaraman@suse.de>
Subject: Re: nfsd page allocation failure on server with lots of memory
Date: Fri, 18 Apr 2008 12:12:45 +0530
Message-ID: <480842E5.3090209@suse.de>
References: <200804172149.42246.ulrich.gemkow@ikr.uni-stuttgart.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
To: Ulrich Gemkow <ulrich.gemkow@ikr.uni-stuttgart.de>,
	linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from victor.provo.novell.com ([137.65.250.26]:40155 "EHLO
	victor.provo.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752868AbYDRGgz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Apr 2008 02:36:55 -0400
In-Reply-To: <200804172149.42246.ulrich.gemkow@ikr.uni-stuttgart.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ulrich Gemkow wrote:
> Hello,
> 
> we have several error messages of nfsd on our fileserver which has 4 GB
> RAM and has only a medium load (see below). The kernel is
> vanilla 2.6.24.4.

These are in general scary warning messages that occurs when there is a 
memory pressure and can be ignored most of the time. There is a 
discussion going on LKML whether to ignore these message or not.

I would like to quote an LWN article[1] to provide further insight:

"In general, the kernel's memory allocator does not like to fail. So, 
when kernel code requests memory, the memory management code will work 
hard to satisfy the request. If this work involves pushing other pages 
out to swap or removing data from the page cache, so be it. A big 
exception happens, though, when an atomic allocation (using the 
GFP_ATOMIC flag) is requested. Code requesting atomic allocations is 
generally not in a position where it can wait around for a lot of memory 
housecleaning work; in particular, such code cannot sleep. So if the 
memory manager is unable to satisfy an atomic allocation with the memory 
it has in hand, it has no choice except to fail the request."


> Is there an explanation of these errors? The server seems to work
> after these error messages.
> 

In this case e1000_alloc_rx_buffers() calls __netdev_alloc_skb() with 
GFP_ATOMIC and that explains the error message.


[1] - http://lwn.net/Articles/276731/

HTH,

> ====================
> Apr 15 10:42:53 netsrv1 kernel: nfsd: page allocation failure. order:0, mode:0x20
> Apr 15 10:42:53 netsrv1 kernel: Pid: 2474, comm: nfsd Not tainted 2.6.24-p2 #14
> Apr 15 10:42:53 netsrv1 kernel:  [<c0147605>] __alloc_pages+0x306/0x34c
> Apr 15 10:42:53 netsrv1 kernel:  [<c015d961>] cache_alloc_refill+0x2de/0x4ff
> Apr 15 10:42:53 netsrv1 kernel:  [<c015dc2b>] __kmalloc+0xa9/0xad
> Apr 15 10:42:53 netsrv1 kernel:  [<c03a89ab>] __alloc_skb+0x47/0xf6
> Apr 15 10:42:53 netsrv1 kernel:  [<c03a9515>] __netdev_alloc_skb+0x1c/0x37
> Apr 15 10:42:53 netsrv1 kernel:  [<c02b0176>] e1000_alloc_rx_buffers+0x176/0x37e
> Apr 15 10:42:53 netsrv1 kernel:  [<c01357d8>] getnstimeofday+0x2b/0xc3
> Apr 15 10:42:53 netsrv1 kernel:  [<c02b0b97>] e1000_clean_rx_irq+0x2a3/0x4bb
> Apr 15 10:42:53 netsrv1 kernel:  [<c02af343>] e1000_intr+0x61/0x121
> Apr 15 10:42:53 netsrv1 kernel:  [<c013fb39>] handle_IRQ_event+0x25/0x4a
> Apr 15 10:42:53 netsrv1 kernel:  [<c0140f20>] handle_fasteoi_irq+0x5f/0xb4
> Apr 15 10:42:53 netsrv1 kernel:  [<c0104fe7>] do_IRQ+0x3b/0x74
> Apr 15 10:42:53 netsrv1 kernel:  [<c01031f7>] common_interrupt+0x23/0x28
> Apr 15 10:42:53 netsrv1 kernel:  [<c0124482>] local_bh_enable_ip+0xe/0x44
> Apr 15 10:42:53 netsrv1 kernel:  [<c03fc0bf>] ipt_do_table+0x1f9/0x4be
> Apr 15 10:42:53 netsrv1 kernel:  [<c04022fe>] packet_rcv+0x2f/0x378
> Apr 15 10:42:53 netsrv1 kernel:  [<c03fc408>] ipt_local_hook+0x0/0x6f
> Apr 15 10:42:53 netsrv1 kernel:  [<c03bdaa6>] nf_iterate+0x56/0x7a
> Apr 15 10:42:53 netsrv1 kernel:  [<c03bdb3f>] nf_hook_slow+0x4d/0xbe
> Apr 15 10:42:53 netsrv1 kernel:  [<c03cde10>] dst_output+0x0/0x7
> Apr 15 10:42:53 netsrv1 kernel:  [<c03d0506>] ip_queue_xmit+0x27c/0x3ae
> Apr 15 10:42:53 netsrv1 kernel:  [<c03cde10>] dst_output+0x0/0x7
> Apr 15 10:42:53 netsrv1 kernel:  [<c03e519c>] tcp_v4_send_check+0x3b/0xc8
> Apr 15 10:42:53 netsrv1 kernel:  [<c03dfc41>] tcp_transmit_skb+0x3a8/0x730
> Apr 15 10:42:53 netsrv1 kernel:  [<c03a89ab>] __alloc_skb+0x47/0xf6
> Apr 15 10:42:53 netsrv1 kernel:  [<c03e012f>] tcp_send_ack+0xb6/0xf5
> Apr 15 10:42:53 netsrv1 kernel:  [<c03deddf>] tcp_rcv_established+0x3d8/0x719
> Apr 15 10:42:53 netsrv1 kernel:  [<c03e4890>] tcp_v4_do_rcv+0x94/0x359
> Apr 15 10:42:53 netsrv1 kernel:  [<c03fc3f3>] ipt_hook+0x0/0x15
> Apr 15 10:42:53 netsrv1 kernel:  [<c03fa175>] ipv4_conntrack_help+0x0/0x73
> Apr 15 10:42:53 netsrv1 kernel:  [<c03e6caf>] tcp_v4_rcv+0x75a/0x82b
> Apr 15 10:42:53 netsrv1 kernel:  [<c03cbc88>] ip_rcv+0x0/0x264
> Apr 15 10:42:53 netsrv1 kernel:  [<c03cbaf2>] ip_local_deliver_finish+0xc8/0x16b
> Apr 15 10:42:53 netsrv1 kernel:  [<c03cb7e8>] ip_rcv_finish+0xe8/0x32a
> Apr 15 10:42:53 netsrv1 kernel:  [<c03cbe6b>] ip_rcv+0x1e3/0x264
> Apr 15 10:42:53 netsrv1 kernel:  [<c03cb700>] ip_rcv_finish+0x0/0x32a
> Apr 15 10:42:53 netsrv1 kernel:  [<c03cbc88>] ip_rcv+0x0/0x264
> Apr 15 10:42:53 netsrv1 kernel:  [<c03ad11a>] netif_receive_skb+0x207/0x283
> Apr 15 10:42:53 netsrv1 kernel:  [<c04022cf>] packet_rcv+0x0/0x378
> Apr 15 10:42:53 netsrv1 kernel:  [<c03acf17>] netif_receive_skb+0x4/0x283
> Apr 15 10:42:53 netsrv1 kernel:  [<c04022cf>] packet_rcv+0x0/0x378
> Apr 15 10:42:53 netsrv1 kernel:  [<c03af619>] process_backlog+0x63/0xc4
> Apr 15 10:42:53 netsrv1 kernel:  [<c03af0b0>] net_rx_action+0x78/0x138
> Apr 15 10:42:53 netsrv1 kernel:  [<c03af3f8>] net_tx_action+0x43/0xe0
> Apr 15 10:42:53 netsrv1 kernel:  [<c0124282>] __do_softirq+0x72/0xdf
> Apr 15 10:42:53 netsrv1 kernel:  [<c0124326>] do_softirq+0x37/0x39
> Apr 15 10:42:53 netsrv1 kernel:  [<c01244b6>] local_bh_enable_ip+0x42/0x44
> Apr 15 10:42:53 netsrv1 kernel:  [<c04155b0>] svc_tcp_recvfrom+0x1ef/0x8fa
> Apr 15 10:42:53 netsrv1 kernel:  [<c01198e0>] update_curr+0x61/0xe5
> Apr 15 10:42:53 netsrv1 kernel:  [<c041f212>] schedule+0x1d0/0x669
> Apr 15 10:42:53 netsrv1 kernel:  [<c0127ae4>] try_to_del_timer_sync+0x47/0x4f
> Apr 15 10:42:53 netsrv1 kernel:  [<c0127afa>] del_timer_sync+0xe/0x15
> Apr 15 10:42:53 netsrv1 kernel:  [<c041f7ca>] schedule_timeout+0x4b/0xa1
> Apr 15 10:42:53 netsrv1 kernel:  [<c0414dde>] svc_recv+0x200/0x3f4
> Apr 15 10:42:53 netsrv1 kernel:  [<c011b1fb>] default_wake_function+0x0/0x8
> Apr 15 10:42:53 netsrv1 kernel:  [<c01e1223>] nfsd+0xc2/0x29f
> Apr 15 10:42:53 netsrv1 kernel:  [<c01e1161>] nfsd+0x0/0x29f
> Apr 15 10:42:53 netsrv1 kernel:  [<c0103437>] kernel_thread_helper+0x7/0x10
> Apr 15 10:42:53 netsrv1 kernel:  =======================

-- 
Suresh Jayaraman
