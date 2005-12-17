From: Chris Penney <penney@msu.edu>
Subject: NFS related page allocation failures
Date: Fri, 16 Dec 2005 20:25:27 -0500
Message-ID: <111aefd0512161725sa5b5333n96c129a41ed41ca8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----=_Part_19388_5742211.1134782727081"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EnQpG-0005mA-3U
	for nfs@lists.sourceforge.net; Fri, 16 Dec 2005 17:25:30 -0800
Received: from zproxy.gmail.com ([64.233.162.198])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EnQpE-0006Ad-Ml
	for nfs@lists.sourceforge.net; Fri, 16 Dec 2005 17:25:30 -0800
Received: by zproxy.gmail.com with SMTP id z3so755311nzf
        for <nfs@lists.sourceforge.net>; Fri, 16 Dec 2005 17:25:27 -0800 (PST)
To: nfs@lists.sourceforge.net
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

------=_Part_19388_5742211.1134782727081
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

I have a 2 CPU P4 box w/ HT enabled and 2GB RAM that is a heavy load NFS
server in a HPC environment (it's an IBM x345 system).  It's connected to
4TB of SAN space using dual HBAs.  Today, I had two instaces of page
allocation failures (see info below).  The box has been up for some time
with no issues (never seen this before).

Is there any tuning I can do to fix this?  I've changed min_free_pages to
32MB (from defauly of ~3MB) and I read somewhere that giving kswapd a littl=
e
higher priority can help (I reniced it to -5) though there's a lot of stuff
on the Internet that's wrong ;).

   Chris


> uname -a
Linux nicfs3 2.6.11.5 #1 SMP Thu Mar 24 15:31:56 EST 2005 i686 i686 i386
GNU/Linux

> cat /proc/net/rpc/nfsd
rc 1213 1141688715 607511169
fh 26082 0 0 0 0
io 738654092 2667724944
th 128 1816606 50023.114 10443.992 4106.448 1796.765 1662.135 936.520
578.055 519.936 800.976 2746.497
ra 256 94366366 538753 87285 44256 4504 2646 2402 1743 1797 1192 406827
net 1749208674 47457 1749218587 16041
rpc 1748565371 1295 1295 0 0
proc2 18 4967 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
proc3 22 42524 410845991 13072619 17044551 34409120 22976 95453790
1122463558 2912160 9926 5840 1 2567900 13767 131245 95 120245 457922 137035
7715 65401 48803973

Intel(R) PRO/1000 Network Driver - version 5.6.10.1-k2-NAPI
Copyright (c) 1999-2004 Intel Corporation.
ACPI: PCI interrupt 0000:06:08.0[A] -> GSI 29 (level, low) -> IRQ 29
usb 1-1: new full speed USB device using ohci_hcd and address 2
e1000: eth0: e1000_probe: Intel(R) PRO/1000 Network Connection
ACPI: PCI interrupt 0000:06:08.1[B] -> GSI 30 (level, low) -> IRQ 30
e1000: eth1: e1000_probe: Intel(R) PRO/1000 Network Connection

# ifconfig eth0
eth0      Link encap:Ethernet  HWaddr 00:0D:60:1A:DC:B2
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:426339601 errors:359167 dropped:359167 overruns:57615
frame:0
          TX packets:3062378244 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:9693358 (9.2 Mb)  TX bytes:2162860348 (2062.6 Mb)
          Base address:0x2700 Memory:ebfe0000-ec000000

# ethtool -S eth0
NIC statistics:
     rx_packets: 424323852
     tx_packets: 3061266959
     rx_bytes: 1290078523
     tx_bytes: 2068709781
     rx_errors: 359167
     tx_errors: 0
     rx_dropped: 301552
     tx_dropped: 0
     multicast: 50788
     collisions: 0
     rx_length_errors: 0
     rx_over_errors: 0
     rx_crc_errors: 0
     rx_frame_errors: 0
     rx_fifo_errors: 57615
     rx_missed_errors: 57615
     tx_aborted_errors: 0
     tx_carrier_errors: 0
     tx_fifo_errors: 0
     tx_heartbeat_errors: 0
     tx_window_errors: 0
     tx_abort_late_coll: 0
     tx_deferred_ok: 0
     tx_single_coll_ok: 0
     tx_multi_coll_ok: 0
     rx_long_length_errors: 0
     rx_short_length_errors: 0
     rx_align_errors: 0
     tx_tcp_seg_good: 92070751
     tx_tcp_seg_failed: 0
     rx_flow_control_xon: 0
     rx_flow_control_xoff: 0
     tx_flow_control_xon: 0
     tx_flow_control_xoff: 0
     rx_long_byte_count: 37221476665659
     rx_csum_offload_good: 26192288465
     rx_csum_offload_errors: 1

# ethtool -k eth0
Offload parameters for eth0:
rx-checksumming: on
tx-checksumming: on
scatter-gather: on
tcp segmentation offload: on

# ethtool -g eth0
Ring parameters for eth0:
Pre-set maximums:
RX:             4096
RX Mini:        0
RX Jumbo:       0
TX:             4096
Current hardware settings:
RX:             256
RX Mini:        0
RX Jumbo:       0
TX:             256

Relevant parts of dmesg:

swapper: page allocation failure. order:0, mode:0x20
 [<c0144793>] __alloc_pages+0x333/0x3b0
 [<c0147342>] kmem_getpages+0x32/0xa0
 [<c014809e>] cache_grow+0xbe/0x180
 [<c01482cd>] cache_alloc_refill+0x16d/0x240
 [<c014869c>] __kmalloc+0x6c/0x80
 [<c0419780>] init_chipset_sis5513+0x240/0x470
 [<c02b4820>] alloc_skb+0x40/0xf0
 [<f8b0f900>] e1000_alloc_rx_buffers+0x40/0xf0 [e1000]
 [<f8b0f690>] e1000_clean_rx_irq+0x280/0x4b0 [e1000]
 [<c02b4b8d>] __kfree_skb+0xad/0x160
 [<c02ea8b6>] tcp_transmit_skb+0x426/0x750
 [<f8b0f11e>] e1000_clean+0x4e/0x110 [e1000]
 [<c02bb0a1>] net_rx_action+0xb1/0x110
 [<c01253e2>] __do_softirq+0x62/0xe0
 [<c012548d>] do_softirq+0x2d/0x40
 [<c01062db>] do_IRQ+0x3b/0x70
 [<c01049f2>] common_interrupt+0x1a/0x20
 [<c0102053>] default_idle+0x23/0x30
 [<c01020ee>] cpu_idle+0x4e/0x60
 [<c03f696a>] start_kernel+0x19a/0x220
 [<c03f6360>] unknown_bootoption+0x0/0x1e0
klogd: page allocation failure. order:0, mode:0x20
 [<c0144793>] __alloc_pages+0x333/0x3b0
 [<c0147342>] kmem_getpages+0x32/0xa0
 [<c014809e>] cache_grow+0xbe/0x180
 [<c01482cd>] cache_alloc_refill+0x16d/0x240
 [<c014869c>] __kmalloc+0x6c/0x80
 [<c0419580>] init_chipset_sis5513+0x40/0x470
 [<c02b4820>] alloc_skb+0x40/0xf0
 [<f8b0f900>] e1000_alloc_rx_buffers+0x40/0xf0 [e1000]
 [<f8b0f690>] e1000_clean_rx_irq+0x280/0x4b0 [e1000]
 [<c02ea8b6>] tcp_transmit_skb+0x426/0x750
 [<c0419680>] init_chipset_sis5513+0x140/0x470
 [<f8b0f11e>] e1000_clean+0x4e/0x110 [e1000]
 [<c02bb0a1>] net_rx_action+0xb1/0x110
 [<c01253e2>] __do_softirq+0x62/0xe0
 [<c012548d>] do_softirq+0x2d/0x40
 [<c0104a80>] apic_timer_interrupt+0x1c/0x24
klogd: page allocation failure. order:0, mode:0x20
 [<c0144793>] __alloc_pages+0x333/0x3b0
 [<c0147342>] kmem_getpages+0x32/0xa0
 [<c014809e>] cache_grow+0xbe/0x180
 [<c01482cd>] cache_alloc_refill+0x16d/0x240
 [<c014869c>] __kmalloc+0x6c/0x80
 [<c0419680>] init_chipset_sis5513+0x140/0x470
 [<c02b4820>] alloc_skb+0x40/0xf0
 [<f8b0f900>] e1000_alloc_rx_buffers+0x40/0xf0 [e1000]
 [<f8b0f690>] e1000_clean_rx_irq+0x280/0x4b0 [e1000]
 [<c02b4b8d>] __kfree_skb+0xad/0x160
 [<c0419680>] init_chipset_sis5513+0x140/0x470
 [<f8b0f11e>] e1000_clean+0x4e/0x110 [e1000]
 [<c02bb0a1>] net_rx_action+0xb1/0x110
 [<c01253e2>] __do_softirq+0x62/0xe0
 [<c012548d>] do_softirq+0x2d/0x40
 [<c01062db>] do_IRQ+0x3b/0x70
 [<c011c077>] __wake_up_common+0x37/0x70
 [<c01049f2>] common_interrupt+0x1a/0x20
 [<c0336eb5>] _spin_unlock_irqrestore+0x5/0x10
 [<c02b405c>] sock_def_readable+0x6c/0xa0
 [<c0419580>] init_chipset_sis5513+0x40/0x470
 [<c0316c49>] unix_dgram_sendmsg+0x4b9/0x510
 [<c0147342>] kmem_getpages+0x32/0xa0
 [<c02b0df5>] sock_aio_write+0x135/0x150
 [<c015ee22>] do_sync_write+0xb2/0x100
 [<f8b0f900>] e1000_alloc_rx_buffers+0x40/0xf0 [e1000]
 [<c02ea8b6>] tcp_transmit_skb+0x426/0x750
 [<c0419680>] init_chipset_sis5513+0x140/0x470
 [<c0134b60>] autoremove_wake_function+0x0/0x50
 [<c015ef9d>] vfs_write+0x12d/0x130
 [<c015f051>] sys_write+0x41/0x70
 [<c010402d>] sysenter_past_esp+0x52/0x75
swapper: page allocation failure. order:0, mode:0x20
 [<c0144793>] __alloc_pages+0x333/0x3b0
 [<c0147342>] kmem_getpages+0x32/0xa0
 [<c014809e>] cache_grow+0xbe/0x180
 [<c01482cd>] cache_alloc_refill+0x16d/0x240
 [<c014869c>] __kmalloc+0x6c/0x80
 [<c02b4820>] alloc_skb+0x40/0xf0
 [<f8b0f900>] e1000_alloc_rx_buffers+0x40/0xf0 [e1000]
 [<f8b0f690>] e1000_clean_rx_irq+0x280/0x4b0 [e1000]
 [<c02b4b8d>] __kfree_skb+0xad/0x160
 [<c02ea8b6>] tcp_transmit_skb+0x426/0x750
 [<f8b0f11e>] e1000_clean+0x4e/0x110 [e1000]
 [<c02bb0a1>] net_rx_action+0xb1/0x110
 [<c01253e2>] __do_softirq+0x62/0xe0
 [<c012548d>] do_softirq+0x2d/0x40
 [<c01062db>] do_IRQ+0x3b/0x70
 [<c01049f2>] common_interrupt+0x1a/0x20
 [<c0102053>] default_idle+0x23/0x30
 [<c01020ee>] cpu_idle+0x4e/0x60
 [<c03f696a>] start_kernel+0x19a/0x220
 [<c03f6360>] unknown_bootoption+0x0/0x1e0
swapper: page allocation failure. order:0, mode:0x20
 [<c0144793>] __alloc_pages+0x333/0x3b0
 [<c0147342>] kmem_getpages+0x32/0xa0
 [<c014809e>] cache_grow+0xbe/0x180
 [<c01482cd>] cache_alloc_refill+0x16d/0x240
 [<c014869c>] __kmalloc+0x6c/0x80
 [<c02b4820>] alloc_skb+0x40/0xf0
 [<f8b0f900>] e1000_alloc_rx_buffers+0x40/0xf0 [e1000]
 [<f8b0f690>] e1000_clean_rx_irq+0x280/0x4b0 [e1000]
 [<c02b4b8d>] __kfree_skb+0xad/0x160
 [<c02ea8b6>] tcp_transmit_skb+0x426/0x750
 [<f8b0f11e>] e1000_clean+0x4e/0x110 [e1000]
 [<c02bb0a1>] net_rx_action+0xb1/0x110
 [<c01253e2>] __do_softirq+0x62/0xe0
 [<c012548d>] do_softirq+0x2d/0x40
 [<c01062db>] do_IRQ+0x3b/0x70
 [<c01049f2>] common_interrupt+0x1a/0x20
 [<c0102053>] default_idle+0x23/0x30
 [<c01020ee>] cpu_idle+0x4e/0x60
 [<c03f696a>] start_kernel+0x19a/0x220
 [<c03f6360>] unknown_bootoption+0x0/0x1e0
swapper: page allocation failure. order:0, mode:0x20
 [<c0144793>] __alloc_pages+0x333/0x3b0
 [<c0147342>] kmem_getpages+0x32/0xa0
 [<c014809e>] cache_grow+0xbe/0x180
 [<c01482cd>] cache_alloc_refill+0x16d/0x240
 [<c014869c>] __kmalloc+0x6c/0x80
 [<c02b4820>] alloc_skb+0x40/0xf0
 [<f8b0f900>] e1000_alloc_rx_buffers+0x40/0xf0 [e1000]
 [<f8b0f690>] e1000_clean_rx_irq+0x280/0x4b0 [e1000]
 [<c02b4b8d>] __kfree_skb+0xad/0x160
 [<c02ea8b6>] tcp_transmit_skb+0x426/0x750
 [<f8b0f11e>] e1000_clean+0x4e/0x110 [e1000]
 [<c02bb0a1>] net_rx_action+0xb1/0x110
 [<c01253e2>] __do_softirq+0x62/0xe0
 [<c012548d>] do_softirq+0x2d/0x40
 [<c01062db>] do_IRQ+0x3b/0x70
 [<c01049f2>] common_interrupt+0x1a/0x20
 [<c0102053>] default_idle+0x23/0x30
 [<c01020ee>] cpu_idle+0x4e/0x60
 [<c03f696a>] start_kernel+0x19a/0x220
 [<c03f6360>] unknown_bootoption+0x0/0x1e0
swapper: page allocation failure. order:0, mode:0x20
 [<c0144793>] __alloc_pages+0x333/0x3b0
 [<c0147342>] kmem_getpages+0x32/0xa0
 [<c014809e>] cache_grow+0xbe/0x180
 [<c01482cd>] cache_alloc_refill+0x16d/0x240
 [<c014869c>] __kmalloc+0x6c/0x80
 [<c02b4820>] alloc_skb+0x40/0xf0
 [<f8b0f900>] e1000_alloc_rx_buffers+0x40/0xf0 [e1000]
 [<f8b0f690>] e1000_clean_rx_irq+0x280/0x4b0 [e1000]
 [<c02b4b8d>] __kfree_skb+0xad/0x160
 [<c02ea8b6>] tcp_transmit_skb+0x426/0x750
 [<f8b0f11e>] e1000_clean+0x4e/0x110 [e1000]
 [<c02bb0a1>] net_rx_action+0xb1/0x110
 [<c01253e2>] __do_softirq+0x62/0xe0
 [<c012548d>] do_softirq+0x2d/0x40
 [<c01062db>] do_IRQ+0x3b/0x70
 [<c01049f2>] common_interrupt+0x1a/0x20
 [<c0102053>] default_idle+0x23/0x30
 [<c01020ee>] cpu_idle+0x4e/0x60
 [<c03f696a>] start_kernel+0x19a/0x220
 [<c03f6360>] unknown_bootoption+0x0/0x1e0
swapper: page allocation failure. order:0, mode:0x20
 [<c0144793>] __alloc_pages+0x333/0x3b0
 [<c0147342>] kmem_getpages+0x32/0xa0
 [<c014809e>] cache_grow+0xbe/0x180
 [<c01482cd>] cache_alloc_refill+0x16d/0x240
 [<c014869c>] __kmalloc+0x6c/0x80
 [<c02b4820>] alloc_skb+0x40/0xf0
 [<f8b0f900>] e1000_alloc_rx_buffers+0x40/0xf0 [e1000]
 [<f8b0f690>] e1000_clean_rx_irq+0x280/0x4b0 [e1000]
 [<c02b4b8d>] __kfree_skb+0xad/0x160
 [<c02ea8b6>] tcp_transmit_skb+0x426/0x750
 [<f8b0f11e>] e1000_clean+0x4e/0x110 [e1000]
 [<c02bb0a1>] net_rx_action+0xb1/0x110
 [<c01253e2>] __do_softirq+0x62/0xe0
 [<c012548d>] do_softirq+0x2d/0x40
 [<c01062db>] do_IRQ+0x3b/0x70
 [<c01049f2>] common_interrupt+0x1a/0x20
 [<c0102053>] default_idle+0x23/0x30
 [<c01020ee>] cpu_idle+0x4e/0x60
 [<c03f696a>] start_kernel+0x19a/0x220
 [<c03f6360>] unknown_bootoption+0x0/0x1e0
swapper: page allocation failure. order:0, mode:0x20
 [<c0144793>] __alloc_pages+0x333/0x3b0
 [<c0147342>] kmem_getpages+0x32/0xa0
 [<c014809e>] cache_grow+0xbe/0x180
 [<c01482cd>] cache_alloc_refill+0x16d/0x240
 [<c014869c>] __kmalloc+0x6c/0x80
 [<c02b4820>] alloc_skb+0x40/0xf0
 [<f8b0f900>] e1000_alloc_rx_buffers+0x40/0xf0 [e1000]
 [<f8b0f690>] e1000_clean_rx_irq+0x280/0x4b0 [e1000]
 [<c02b4b8d>] __kfree_skb+0xad/0x160
 [<c02ea8b6>] tcp_transmit_skb+0x426/0x750
 [<f8b0f11e>] e1000_clean+0x4e/0x110 [e1000]
 [<c02bb0a1>] net_rx_action+0xb1/0x110
 [<c01253e2>] __do_softirq+0x62/0xe0
 [<c012548d>] do_softirq+0x2d/0x40
 [<c01062db>] do_IRQ+0x3b/0x70
 [<c01049f2>] common_interrupt+0x1a/0x20
 [<c0102053>] default_idle+0x23/0x30
 [<c01020ee>] cpu_idle+0x4e/0x60
 [<c03f696a>] start_kernel+0x19a/0x220
 [<c03f6360>] unknown_bootoption+0x0/0x1e0
swapper: page allocation failure. order:0, mode:0x20
 [<c0144793>] __alloc_pages+0x333/0x3b0
 [<c0147342>] kmem_getpages+0x32/0xa0
 [<c014809e>] cache_grow+0xbe/0x180
 [<c01482cd>] cache_alloc_refill+0x16d/0x240
 [<c014869c>] __kmalloc+0x6c/0x80
 [<c02b4820>] alloc_skb+0x40/0xf0
 [<f8b0f900>] e1000_alloc_rx_buffers+0x40/0xf0 [e1000]
 [<f8b0f690>] e1000_clean_rx_irq+0x280/0x4b0 [e1000]
 [<c02b4b8d>] __kfree_skb+0xad/0x160
 [<c02ea8b6>] tcp_transmit_skb+0x426/0x750
 [<f8b0f11e>] e1000_clean+0x4e/0x110 [e1000]
 [<c02bb0a1>] net_rx_action+0xb1/0x110
 [<c01253e2>] __do_softirq+0x62/0xe0
 [<c012548d>] do_softirq+0x2d/0x40
 [<c01062db>] do_IRQ+0x3b/0x70
 [<c01049f2>] common_interrupt+0x1a/0x20
 [<c0102053>] default_idle+0x23/0x30
 [<c01020ee>] cpu_idle+0x4e/0x60
 [<c03f696a>] start_kernel+0x19a/0x220
 [<c03f6360>] unknown_bootoption+0x0/0x1e0
printk: 130 messages suppressed.
nfsd: page allocation failure. order:1, mode:0x20
 [<c0144793>] __alloc_pages+0x333/0x3b0
 [<c0147342>] kmem_getpages+0x32/0xa0
 [<c014809e>] cache_grow+0xbe/0x180
 [<c01482cd>] cache_alloc_refill+0x16d/0x240
 [<c014869c>] __kmalloc+0x6c/0x80
 [<c02b4820>] alloc_skb+0x40/0xf0
 [<c02e80d2>] tcp_collapse+0x152/0x370
 [<c02e83f7>] tcp_prune_queue+0x87/0x1e0
 [<c02e79f3>] tcp_data_queue+0x573/0xb00
 [<c02e6312>] tcp_ack+0xd2/0x5d0
 [<c02e8df6>] tcp_rcv_established+0x2e6/0x7f0
 [<c02f1960>] tcp_v4_do_rcv+0xf0/0x110
 [<c02f21c1>] tcp_v4_rcv+0x841/0x920
 [<c02d9d5a>] ip_queue_xmit+0x30a/0x4f0
 [<c02d62d6>] ip_local_deliver+0x96/0x260
 [<c02d68c8>] ip_rcv+0x428/0x500
 [<c02baeac>] netif_receive_skb+0x27c/0x2a0
 [<f8b0f4be>] e1000_clean_rx_irq+0xae/0x4b0 [e1000]
 [<c02b4b8d>] __kfree_skb+0xad/0x160
 [<f8b0f11e>] e1000_clean+0x4e/0x110 [e1000]
 [<c02bb0a1>] net_rx_action+0xb1/0x110
 [<c01253e2>] __do_softirq+0x62/0xe0
 [<c012548d>] do_softirq+0x2d/0x40
 [<c01062db>] do_IRQ+0x3b/0x70
 [<c01049f2>] common_interrupt+0x1a/0x20
 [<f8a670f0>] xtSearch+0x240/0x650 [jfs]
 [<f8a68b58>] xtExtend+0x58/0x660 [jfs]
 [<c0162f40>] nobh_commit_write+0x30/0x80
 [<c013fb8d>] unlock_page+0x1d/0x30
 [<f8a7c4fa>] __write_metapage+0x6a/0xb0 [jfs]
 [<c01430b1>] mempool_free+0x81/0xa0
 [<f8a71470>] dbAlloc+0x3c0/0x4b0 [jfs]
 [<f8a7bd2f>] extBalloc+0x20f/0x230 [jfs]
 [<c0181ac8>] __mark_inode_dirty+0xd8/0x1e0
 [<c0168864>] inode_add_bytes+0x24/0xa0
 [<f8a7b954>] extAlloc+0x434/0x460 [jfs]
 [<f8a6316c>] jfs_get_blocks+0x27c/0x340 [jfs]
 [<c02d96aa>] ip_finish_output+0xda/0x270
 [<f8a63250>] jfs_get_block+0x20/0x30 [jfs]
 [<c0162c1c>] nobh_prepare_write+0xec/0x3e0
 [<c0144271>] buffered_rmqueue+0xf1/0x210
 [<c0177446>] d_alloc_anon+0x26/0x110
 [<c0144525>] __alloc_pages+0xc5/0x3b0
 [<c013f9f6>] add_to_page_cache+0xb6/0xe0
 [<c01418b7>] generic_file_buffered_write+0x1b7/0x5e0
 [<f8a63230>] jfs_get_block+0x0/0x30 [jfs]
 [<c02ea8b6>] tcp_transmit_skb+0x426/0x750
 [<c01799ee>] inode_update_time+0x9e/0xc0
 [<c0142013>] __generic_file_aio_write_nolock+0x333/0x590
 [<c02b0af1>] sock_recvmsg+0x131/0x170
 [<c011a95d>] finish_task_switch+0x3d/0x90
 [<c0335608>] schedule+0x378/0xbb0
 [<c011a5df>] try_to_wake_up+0x24f/0x280
 [<c01423a5>] __generic_file_write_nolock+0x85/0xb0
 [<c03350fe>] __down+0xce/0xe0
 [<c011c030>] default_wake_function+0x0/0x10
 [<c0134b60>] autoremove_wake_function+0x0/0x50
 [<c0142560>] generic_file_write+0x0/0xd0
 [<c0335233>] __down_failed+0x7/0xc
 [<c0142560>] generic_file_write+0x0/0xd0
 [<c0142716>] generic_file_writev+0x36/0xc0
 [<c020282a>] __copy_from_user_ll+0x5a/0x80
 [<c01426e0>] generic_file_writev+0x0/0xc0
 [<c0142560>] generic_file_write+0x0/0xd0
 [<c015f40b>] do_readv_writev+0x23b/0x250
 [<f8a39950>] export_decode_fh+0x0/0xa5 [exportfs]
 [<c0142560>] generic_file_write+0x0/0xd0
 [<c01253e2>] __do_softirq+0x62/0xe0
 [<f8a62a67>] jfs_open+0x17/0xa0 [jfs]
 [<c015e008>] dentry_open+0xe8/0x200
 [<c015f4b9>] vfs_writev+0x49/0x50
 [<f8af545c>] nfsd_write+0xfc/0x340 [nfsd]
 [<c0323045>] ip_map_lookup+0x305/0x360
 [<c03232ca>] svcauth_unix_set_client+0xba/0xd0
 [<f8afc424>] nfsd3_proc_write+0xc4/0x140 [nfsd]
 [<f8afe150>] nfs3svc_decode_writeargs+0x0/0x180 [nfsd]
 [<f8af1696>] nfsd_dispatch+0x136/0x200 [nfsd]
 [<c0322587>] svc_authenticate+0x87/0xe0
 [<c031fae9>] svc_process+0x409/0x620
 [<c01049f2>] common_interrupt+0x1a/0x20
 [<f8af13d6>] nfsd+0x196/0x320 [nfsd]
 [<f8af1240>] nfsd+0x0/0x320 [nfsd]
 [<c0102345>] kernel_thread_helper+0x5/0x10
printk: 18 messages suppressed.
nfsd: page allocation failure. order:0, mode:0x20
 [<c0144793>] __alloc_pages+0x333/0x3b0
 [<c0147342>] kmem_getpages+0x32/0xa0
 [<c014809e>] cache_grow+0xbe/0x180
 [<c01482cd>] cache_alloc_refill+0x16d/0x240
 [<c01485c4>] kmem_cache_alloc+0x44/0x50
 [<c02b4803>] alloc_skb+0x23/0xf0
 [<f8b0f900>] e1000_alloc_rx_buffers+0x40/0xf0 [e1000]
 [<f8b0f690>] e1000_clean_rx_irq+0x280/0x4b0 [e1000]
 [<c0119fc3>] recalc_task_prio+0xd3/0x140
 [<f8b0f11e>] e1000_clean+0x4e/0x110 [e1000]
 [<c02bb0a1>] net_rx_action+0xb1/0x110
 [<c01253e2>] __do_softirq+0x62/0xe0
 [<c012548d>] do_softirq+0x2d/0x40
 [<c01062db>] do_IRQ+0x3b/0x70
 [<c01049f2>] common_interrupt+0x1a/0x20
 [<c018eba6>] dnotify_parent+0x46/0xa0
 [<c01426e0>] generic_file_writev+0x0/0xc0
 [<c015f3b8>] do_readv_writev+0x1e8/0x250
 [<f8a39950>] export_decode_fh+0x0/0xa5 [exportfs]
 [<c0142560>] generic_file_write+0x0/0xd0
 [<f8a62a67>] jfs_open+0x17/0xa0 [jfs]
 [<c015e008>] dentry_open+0xe8/0x200
 [<c015f4b9>] vfs_writev+0x49/0x50
 [<f8af545c>] nfsd_write+0xfc/0x340 [nfsd]
 [<c0323045>] ip_map_lookup+0x305/0x360
 [<c03232ca>] svcauth_unix_set_client+0xba/0xd0
 [<f8afc424>] nfsd3_proc_write+0xc4/0x140 [nfsd]
 [<f8afe150>] nfs3svc_decode_writeargs+0x0/0x180 [nfsd]
 [<f8af1696>] nfsd_dispatch+0x136/0x200 [nfsd]
 [<c0322587>] svc_authenticate+0x87/0xe0
 [<c031fae9>] svc_process+0x409/0x620
 [<c01049f2>] common_interrupt+0x1a/0x20
 [<f8af13d6>] nfsd+0x196/0x320 [nfsd]
 [<f8af1240>] nfsd+0x0/0x320 [nfsd]
 [<c0102345>] kernel_thread_helper+0x5/0x10

------=_Part_19388_5742211.1134782727081
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

I have a 2 CPU P4 box w/ HT enabled and 2GB RAM that is a heavy load NFS se=
rver in a HPC environment (it's an IBM x345 system).&nbsp; It's connected t=
o 4TB of SAN space using dual HBAs.&nbsp; Today, I had two instaces of page=
 allocation failures (see info below).&nbsp; The box has been up for some t=
ime with no issues (never seen this before).
<br><br>Is there any tuning I can do to fix this?&nbsp; I've changed min_fr=
ee_pages to 32MB (from defauly of ~3MB) and I read somewhere that giving ks=
wapd a little higher priority can help (I reniced it to -5) though there's =
a lot of stuff on the Internet that's wrong ;).
<br><br>&nbsp;&nbsp; Chris<br><br><br>&gt; uname -a<br>Linux nicfs3 <a href=
=3D"http://2.6.11.5">2.6.11.5</a> #1 SMP Thu Mar 24 15:31:56 EST 2005 i686 =
i686 i386 GNU/Linux<br><br>&gt; cat /proc/net/rpc/nfsd<br>rc 1213 114168871=
5 607511169
<br>fh 26082 0 0 0 0<br>io 738654092 2667724944<br>th 128 1816606 50023.114=
 10443.992 4106.448 1796.765 1662.135 936.520 578.055 519.936 800.976 2746.=
497<br>ra 256 94366366 538753 87285 44256 4504 2646 2402 1743 1797 1192 406=
827
<br>net 1749208674 47457 1749218587 16041<br>rpc 1748565371 1295 1295 0 0<b=
r>proc2 18 4967 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0<br>proc3 22 42524 4108459=
91 13072619 17044551 34409120 22976 95453790 1122463558 2912160 9926 5840 1=
 2567900 13767 131245 95 120245 457922 137035 7715 65401 48803973
<br><br>Intel(R) PRO/1000 Network Driver - version 5.6.10.1-k2-NAPI<br>Copy=
right (c) 1999-2004 Intel Corporation.<br>ACPI: PCI interrupt 0000:06:08.0[=
A] -&gt; GSI 29 (level, low) -&gt; IRQ 29<br>usb 1-1: new full speed USB de=
vice using ohci_hcd and address 2
<br>e1000: eth0: e1000_probe: Intel(R) PRO/1000 Network Connection<br>ACPI:=
 PCI interrupt 0000:06:08.1[B] -&gt; GSI 30 (level, low) -&gt; IRQ 30<br>e1=
000: eth1: e1000_probe: Intel(R) PRO/1000 Network Connection<br><br># ifcon=
fig eth0
<br>eth0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Link encap:Ethernet&nbsp; HWaddr 00:=
0D:60:1A:DC:B2<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; UP=
 BROADCAST RUNNING MULTICAST&nbsp; MTU:1500&nbsp; Metric:1<br>&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; RX packets:426339601 errors:35916=
7 dropped:359167 overruns:57615 frame:0<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp; TX packets:3062378244 errors:0 dropped:0 overruns:0 =
carrier:0
<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; collisions:0 txq=
ueuelen:1000<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; RX b=
ytes:9693358 (9.2 Mb)&nbsp; TX bytes:2162860348 (2062.6 Mb)<br>&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Base address:0x2700 Memory:ebfe0=
000-ec000000<br><br># ethtool -S eth0<br>NIC statistics:<br>&nbsp;&nbsp;&nb=
sp;&nbsp; rx_packets: 424323852
<br>&nbsp;&nbsp;&nbsp;&nbsp; tx_packets: 3061266959<br>&nbsp;&nbsp;&nbsp;&n=
bsp; rx_bytes: 1290078523<br>&nbsp;&nbsp;&nbsp;&nbsp; tx_bytes: 2068709781<=
br>&nbsp;&nbsp;&nbsp;&nbsp; rx_errors: 359167<br>&nbsp;&nbsp;&nbsp;&nbsp; t=
x_errors: 0<br>&nbsp;&nbsp;&nbsp;&nbsp; rx_dropped: 301552<br>&nbsp;&nbsp;&=
nbsp;&nbsp; tx_dropped: 0<br>&nbsp;&nbsp;&nbsp;&nbsp; multicast: 50788<br>&=
nbsp;&nbsp;&nbsp;&nbsp; collisions: 0
<br>&nbsp;&nbsp;&nbsp;&nbsp; rx_length_errors: 0<br>&nbsp;&nbsp;&nbsp;&nbsp=
; rx_over_errors: 0<br>&nbsp;&nbsp;&nbsp;&nbsp; rx_crc_errors: 0<br>&nbsp;&=
nbsp;&nbsp;&nbsp; rx_frame_errors: 0<br>&nbsp;&nbsp;&nbsp;&nbsp; rx_fifo_er=
rors: 57615<br>&nbsp;&nbsp;&nbsp;&nbsp; rx_missed_errors: 57615<br>&nbsp;&n=
bsp;&nbsp;&nbsp; tx_aborted_errors: 0<br>&nbsp;&nbsp;&nbsp;&nbsp; tx_carrie=
r_errors: 0
<br>&nbsp;&nbsp;&nbsp;&nbsp; tx_fifo_errors: 0<br>&nbsp;&nbsp;&nbsp;&nbsp; =
tx_heartbeat_errors: 0<br>&nbsp;&nbsp;&nbsp;&nbsp; tx_window_errors: 0<br>&=
nbsp;&nbsp;&nbsp;&nbsp; tx_abort_late_coll: 0<br>&nbsp;&nbsp;&nbsp;&nbsp; t=
x_deferred_ok: 0<br>&nbsp;&nbsp;&nbsp;&nbsp; tx_single_coll_ok: 0<br>&nbsp;=
&nbsp;&nbsp;&nbsp; tx_multi_coll_ok: 0<br>&nbsp;&nbsp;&nbsp;&nbsp; rx_long_=
length_errors: 0
<br>&nbsp;&nbsp;&nbsp;&nbsp; rx_short_length_errors: 0<br>&nbsp;&nbsp;&nbsp=
;&nbsp; rx_align_errors: 0<br>&nbsp;&nbsp;&nbsp;&nbsp; tx_tcp_seg_good: 920=
70751<br>&nbsp;&nbsp;&nbsp;&nbsp; tx_tcp_seg_failed: 0<br>&nbsp;&nbsp;&nbsp=
;&nbsp; rx_flow_control_xon: 0<br>&nbsp;&nbsp;&nbsp;&nbsp; rx_flow_control_=
xoff: 0<br>&nbsp;&nbsp;&nbsp;&nbsp; tx_flow_control_xon: 0<br>
&nbsp;&nbsp;&nbsp;&nbsp; tx_flow_control_xoff: 0<br>&nbsp;&nbsp;&nbsp;&nbsp=
; rx_long_byte_count: 37221476665659<br>&nbsp;&nbsp;&nbsp;&nbsp; rx_csum_of=
fload_good: 26192288465<br>&nbsp;&nbsp;&nbsp;&nbsp; rx_csum_offload_errors:=
 1<br><br># ethtool -k eth0<br>Offload parameters for eth0:<br>rx-checksumm=
ing: on
<br>tx-checksumming: on<br>scatter-gather: on<br>tcp segmentation offload: =
on<br><br># ethtool -g eth0<br>
Ring parameters for eth0:<br>
Pre-set maximums:<br>
RX:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
 4096<br>
RX Mini:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0<br>
RX Jumbo:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0<br>
TX:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
 4096<br>
Current hardware settings:<br>
RX:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
 256<br>
RX Mini:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0<br>
RX Jumbo:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0<br>
TX:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
 256<br>
<br>Relevant parts of dmesg:<br><br>swapper: page allocation failure. order=
:0, mode:0x20<br>&nbsp;[&lt;c0144793&gt;] __alloc_pages+0x333/0x3b0<br>&nbs=
p;[&lt;c0147342&gt;] kmem_getpages+0x32/0xa0<br>&nbsp;[&lt;c014809e&gt;] ca=
che_grow+0xbe/0x180
<br>&nbsp;[&lt;c01482cd&gt;] cache_alloc_refill+0x16d/0x240<br>&nbsp;[&lt;c=
014869c&gt;] __kmalloc+0x6c/0x80<br>&nbsp;[&lt;c0419780&gt;] init_chipset_s=
is5513+0x240/0x470<br>&nbsp;[&lt;c02b4820&gt;] alloc_skb+0x40/0xf0<br>&nbsp=
;[&lt;f8b0f900&gt;] e1000_alloc_rx_buffers+0x40/0xf0 [e1000]
<br>&nbsp;[&lt;f8b0f690&gt;] e1000_clean_rx_irq+0x280/0x4b0 [e1000]<br>&nbs=
p;[&lt;c02b4b8d&gt;] __kfree_skb+0xad/0x160<br>&nbsp;[&lt;c02ea8b6&gt;] tcp=
_transmit_skb+0x426/0x750<br>&nbsp;[&lt;f8b0f11e&gt;] e1000_clean+0x4e/0x11=
0 [e1000]<br>&nbsp;[&lt;c02bb0a1&gt;] net_rx_action+0xb1/0x110
<br>&nbsp;[&lt;c01253e2&gt;] __do_softirq+0x62/0xe0<br>&nbsp;[&lt;c012548d&=
gt;] do_softirq+0x2d/0x40<br>&nbsp;[&lt;c01062db&gt;] do_IRQ+0x3b/0x70<br>&=
nbsp;[&lt;c01049f2&gt;] common_interrupt+0x1a/0x20<br>&nbsp;[&lt;c0102053&g=
t;] default_idle+0x23/0x30
<br>&nbsp;[&lt;c01020ee&gt;] cpu_idle+0x4e/0x60<br>&nbsp;[&lt;c03f696a&gt;]=
 start_kernel+0x19a/0x220<br>&nbsp;[&lt;c03f6360&gt;] unknown_bootoption+0x=
0/0x1e0<br>klogd: page allocation failure. order:0, mode:0x20<br>&nbsp;[&lt=
;c0144793&gt;] __alloc_pages+0x333/0x3b0
<br>&nbsp;[&lt;c0147342&gt;] kmem_getpages+0x32/0xa0<br>&nbsp;[&lt;c014809e=
&gt;] cache_grow+0xbe/0x180<br>&nbsp;[&lt;c01482cd&gt;] cache_alloc_refill+=
0x16d/0x240<br>&nbsp;[&lt;c014869c&gt;] __kmalloc+0x6c/0x80<br>&nbsp;[&lt;c=
0419580&gt;] init_chipset_sis5513+0x40/0x470
<br>&nbsp;[&lt;c02b4820&gt;] alloc_skb+0x40/0xf0<br>&nbsp;[&lt;f8b0f900&gt;=
] e1000_alloc_rx_buffers+0x40/0xf0 [e1000]<br>&nbsp;[&lt;f8b0f690&gt;] e100=
0_clean_rx_irq+0x280/0x4b0 [e1000]<br>&nbsp;[&lt;c02ea8b6&gt;] tcp_transmit=
_skb+0x426/0x750
<br>&nbsp;[&lt;c0419680&gt;] init_chipset_sis5513+0x140/0x470<br>&nbsp;[&lt=
;f8b0f11e&gt;] e1000_clean+0x4e/0x110 [e1000]<br>&nbsp;[&lt;c02bb0a1&gt;] n=
et_rx_action+0xb1/0x110<br>&nbsp;[&lt;c01253e2&gt;] __do_softirq+0x62/0xe0<=
br>&nbsp;[&lt;c012548d&gt;] do_softirq+0x2d/0x40
<br>&nbsp;[&lt;c0104a80&gt;] apic_timer_interrupt+0x1c/0x24<br>klogd: page =
allocation failure. order:0, mode:0x20<br>&nbsp;[&lt;c0144793&gt;] __alloc_=
pages+0x333/0x3b0<br>&nbsp;[&lt;c0147342&gt;] kmem_getpages+0x32/0xa0<br>&n=
bsp;[&lt;c014809e&gt;] cache_grow+0xbe/0x180
<br>&nbsp;[&lt;c01482cd&gt;] cache_alloc_refill+0x16d/0x240<br>&nbsp;[&lt;c=
014869c&gt;] __kmalloc+0x6c/0x80<br>&nbsp;[&lt;c0419680&gt;] init_chipset_s=
is5513+0x140/0x470<br>&nbsp;[&lt;c02b4820&gt;] alloc_skb+0x40/0xf0<br>&nbsp=
;[&lt;f8b0f900&gt;] e1000_alloc_rx_buffers+0x40/0xf0 [e1000]
<br>&nbsp;[&lt;f8b0f690&gt;] e1000_clean_rx_irq+0x280/0x4b0 [e1000]<br>&nbs=
p;[&lt;c02b4b8d&gt;] __kfree_skb+0xad/0x160<br>&nbsp;[&lt;c0419680&gt;] ini=
t_chipset_sis5513+0x140/0x470<br>&nbsp;[&lt;f8b0f11e&gt;] e1000_clean+0x4e/=
0x110 [e1000]<br>
&nbsp;[&lt;c02bb0a1&gt;] net_rx_action+0xb1/0x110<br>&nbsp;[&lt;c01253e2&gt=
;] __do_softirq+0x62/0xe0<br>&nbsp;[&lt;c012548d&gt;] do_softirq+0x2d/0x40<=
br>&nbsp;[&lt;c01062db&gt;] do_IRQ+0x3b/0x70<br>&nbsp;[&lt;c011c077&gt;] __=
wake_up_common+0x37/0x70
<br>&nbsp;[&lt;c01049f2&gt;] common_interrupt+0x1a/0x20<br>&nbsp;[&lt;c0336=
eb5&gt;] _spin_unlock_irqrestore+0x5/0x10<br>&nbsp;[&lt;c02b405c&gt;] sock_=
def_readable+0x6c/0xa0<br>&nbsp;[&lt;c0419580&gt;] init_chipset_sis5513+0x4=
0/0x470<br>&nbsp;[&lt;c0316c49&gt;] unix_dgram_sendmsg+0x4b9/0x510
<br>&nbsp;[&lt;c0147342&gt;] kmem_getpages+0x32/0xa0<br>&nbsp;[&lt;c02b0df5=
&gt;] sock_aio_write+0x135/0x150<br>&nbsp;[&lt;c015ee22&gt;] do_sync_write+=
0xb2/0x100<br>&nbsp;[&lt;f8b0f900&gt;] e1000_alloc_rx_buffers+0x40/0xf0 [e1=
000]<br>&nbsp;[&lt;c02ea8b6&gt;] tcp_transmit_skb+0x426/0x750
<br>&nbsp;[&lt;c0419680&gt;] init_chipset_sis5513+0x140/0x470<br>&nbsp;[&lt=
;c0134b60&gt;] autoremove_wake_function+0x0/0x50<br>&nbsp;[&lt;c015ef9d&gt;=
] vfs_write+0x12d/0x130<br>&nbsp;[&lt;c015f051&gt;] sys_write+0x41/0x70<br>=
&nbsp;[&lt;c010402d&gt;] sysenter_past_esp+0x52/0x75
<br>swapper: page allocation failure. order:0, mode:0x20<br>&nbsp;[&lt;c014=
4793&gt;] __alloc_pages+0x333/0x3b0<br>&nbsp;[&lt;c0147342&gt;] kmem_getpag=
es+0x32/0xa0<br>&nbsp;[&lt;c014809e&gt;] cache_grow+0xbe/0x180<br>&nbsp;[&l=
t;c01482cd&gt;] cache_alloc_refill+0x16d/0x240
<br>&nbsp;[&lt;c014869c&gt;] __kmalloc+0x6c/0x80<br>&nbsp;[&lt;c02b4820&gt;=
] alloc_skb+0x40/0xf0<br>&nbsp;[&lt;f8b0f900&gt;] e1000_alloc_rx_buffers+0x=
40/0xf0 [e1000]<br>&nbsp;[&lt;f8b0f690&gt;] e1000_clean_rx_irq+0x280/0x4b0 =
[e1000]<br>&nbsp;[&lt;c02b4b8d&gt;] __kfree_skb+0xad/0x160
<br>&nbsp;[&lt;c02ea8b6&gt;] tcp_transmit_skb+0x426/0x750<br>&nbsp;[&lt;f8b=
0f11e&gt;] e1000_clean+0x4e/0x110 [e1000]<br>&nbsp;[&lt;c02bb0a1&gt;] net_r=
x_action+0xb1/0x110<br>&nbsp;[&lt;c01253e2&gt;] __do_softirq+0x62/0xe0<br>&=
nbsp;[&lt;c012548d&gt;] do_softirq+0x2d/0x40
<br>&nbsp;[&lt;c01062db&gt;] do_IRQ+0x3b/0x70<br>&nbsp;[&lt;c01049f2&gt;] c=
ommon_interrupt+0x1a/0x20<br>&nbsp;[&lt;c0102053&gt;] default_idle+0x23/0x3=
0<br>&nbsp;[&lt;c01020ee&gt;] cpu_idle+0x4e/0x60<br>&nbsp;[&lt;c03f696a&gt;=
] start_kernel+0x19a/0x220
<br>&nbsp;[&lt;c03f6360&gt;] unknown_bootoption+0x0/0x1e0<br>swapper: page =
allocation failure. order:0, mode:0x20<br>&nbsp;[&lt;c0144793&gt;] __alloc_=
pages+0x333/0x3b0<br>&nbsp;[&lt;c0147342&gt;] kmem_getpages+0x32/0xa0<br>&n=
bsp;[&lt;c014809e&gt;] cache_grow+0xbe/0x180
<br>&nbsp;[&lt;c01482cd&gt;] cache_alloc_refill+0x16d/0x240<br>&nbsp;[&lt;c=
014869c&gt;] __kmalloc+0x6c/0x80<br>&nbsp;[&lt;c02b4820&gt;] alloc_skb+0x40=
/0xf0<br>&nbsp;[&lt;f8b0f900&gt;] e1000_alloc_rx_buffers+0x40/0xf0 [e1000]<=
br>&nbsp;[&lt;f8b0f690&gt;] e1000_clean_rx_irq+0x280/0x4b0 [e1000]
<br>&nbsp;[&lt;c02b4b8d&gt;] __kfree_skb+0xad/0x160<br>&nbsp;[&lt;c02ea8b6&=
gt;] tcp_transmit_skb+0x426/0x750<br>&nbsp;[&lt;f8b0f11e&gt;] e1000_clean+0=
x4e/0x110 [e1000]<br>&nbsp;[&lt;c02bb0a1&gt;] net_rx_action+0xb1/0x110<br>&=
nbsp;[&lt;c01253e2&gt;] __do_softirq+0x62/0xe0
<br>&nbsp;[&lt;c012548d&gt;] do_softirq+0x2d/0x40<br>&nbsp;[&lt;c01062db&gt=
;] do_IRQ+0x3b/0x70<br>&nbsp;[&lt;c01049f2&gt;] common_interrupt+0x1a/0x20<=
br>&nbsp;[&lt;c0102053&gt;] default_idle+0x23/0x30<br>&nbsp;[&lt;c01020ee&g=
t;] cpu_idle+0x4e/0x60
<br>&nbsp;[&lt;c03f696a&gt;] start_kernel+0x19a/0x220<br>&nbsp;[&lt;c03f636=
0&gt;] unknown_bootoption+0x0/0x1e0<br>swapper: page allocation failure. or=
der:0, mode:0x20<br>&nbsp;[&lt;c0144793&gt;] __alloc_pages+0x333/0x3b0<br>&=
nbsp;[&lt;c0147342&gt;] kmem_getpages+0x32/0xa0
<br>&nbsp;[&lt;c014809e&gt;] cache_grow+0xbe/0x180<br>&nbsp;[&lt;c01482cd&g=
t;] cache_alloc_refill+0x16d/0x240<br>&nbsp;[&lt;c014869c&gt;] __kmalloc+0x=
6c/0x80<br>&nbsp;[&lt;c02b4820&gt;] alloc_skb+0x40/0xf0<br>&nbsp;[&lt;f8b0f=
900&gt;] e1000_alloc_rx_buffers+0x40/0xf0 [e1000]
<br>&nbsp;[&lt;f8b0f690&gt;] e1000_clean_rx_irq+0x280/0x4b0 [e1000]<br>&nbs=
p;[&lt;c02b4b8d&gt;] __kfree_skb+0xad/0x160<br>&nbsp;[&lt;c02ea8b6&gt;] tcp=
_transmit_skb+0x426/0x750<br>&nbsp;[&lt;f8b0f11e&gt;] e1000_clean+0x4e/0x11=
0 [e1000]<br>&nbsp;[&lt;c02bb0a1&gt;] net_rx_action+0xb1/0x110
<br>&nbsp;[&lt;c01253e2&gt;] __do_softirq+0x62/0xe0<br>&nbsp;[&lt;c012548d&=
gt;] do_softirq+0x2d/0x40<br>&nbsp;[&lt;c01062db&gt;] do_IRQ+0x3b/0x70<br>&=
nbsp;[&lt;c01049f2&gt;] common_interrupt+0x1a/0x20<br>&nbsp;[&lt;c0102053&g=
t;] default_idle+0x23/0x30
<br>&nbsp;[&lt;c01020ee&gt;] cpu_idle+0x4e/0x60<br>&nbsp;[&lt;c03f696a&gt;]=
 start_kernel+0x19a/0x220<br>&nbsp;[&lt;c03f6360&gt;] unknown_bootoption+0x=
0/0x1e0<br>swapper: page allocation failure. order:0, mode:0x20<br>&nbsp;[&=
lt;c0144793&gt;] __alloc_pages+0x333/0x3b0
<br>&nbsp;[&lt;c0147342&gt;] kmem_getpages+0x32/0xa0<br>&nbsp;[&lt;c014809e=
&gt;] cache_grow+0xbe/0x180<br>&nbsp;[&lt;c01482cd&gt;] cache_alloc_refill+=
0x16d/0x240<br>&nbsp;[&lt;c014869c&gt;] __kmalloc+0x6c/0x80<br>&nbsp;[&lt;c=
02b4820&gt;] alloc_skb+0x40/0xf0
<br>&nbsp;[&lt;f8b0f900&gt;] e1000_alloc_rx_buffers+0x40/0xf0 [e1000]<br>&n=
bsp;[&lt;f8b0f690&gt;] e1000_clean_rx_irq+0x280/0x4b0 [e1000]<br>&nbsp;[&lt=
;c02b4b8d&gt;] __kfree_skb+0xad/0x160<br>&nbsp;[&lt;c02ea8b6&gt;] tcp_trans=
mit_skb+0x426/0x750
<br>&nbsp;[&lt;f8b0f11e&gt;] e1000_clean+0x4e/0x110 [e1000]<br>&nbsp;[&lt;c=
02bb0a1&gt;] net_rx_action+0xb1/0x110<br>&nbsp;[&lt;c01253e2&gt;] __do_soft=
irq+0x62/0xe0<br>&nbsp;[&lt;c012548d&gt;] do_softirq+0x2d/0x40<br>&nbsp;[&l=
t;c01062db&gt;] do_IRQ+0x3b/0x70
<br>&nbsp;[&lt;c01049f2&gt;] common_interrupt+0x1a/0x20<br>&nbsp;[&lt;c0102=
053&gt;] default_idle+0x23/0x30<br>&nbsp;[&lt;c01020ee&gt;] cpu_idle+0x4e/0=
x60<br>&nbsp;[&lt;c03f696a&gt;] start_kernel+0x19a/0x220<br>&nbsp;[&lt;c03f=
6360&gt;] unknown_bootoption+0x0/0x1e0
<br>swapper: page allocation failure. order:0, mode:0x20<br>&nbsp;[&lt;c014=
4793&gt;] __alloc_pages+0x333/0x3b0<br>&nbsp;[&lt;c0147342&gt;] kmem_getpag=
es+0x32/0xa0<br>&nbsp;[&lt;c014809e&gt;] cache_grow+0xbe/0x180<br>&nbsp;[&l=
t;c01482cd&gt;] cache_alloc_refill+0x16d/0x240
<br>&nbsp;[&lt;c014869c&gt;] __kmalloc+0x6c/0x80<br>&nbsp;[&lt;c02b4820&gt;=
] alloc_skb+0x40/0xf0<br>&nbsp;[&lt;f8b0f900&gt;] e1000_alloc_rx_buffers+0x=
40/0xf0 [e1000]<br>&nbsp;[&lt;f8b0f690&gt;] e1000_clean_rx_irq+0x280/0x4b0 =
[e1000]<br>&nbsp;[&lt;c02b4b8d&gt;] __kfree_skb+0xad/0x160
<br>&nbsp;[&lt;c02ea8b6&gt;] tcp_transmit_skb+0x426/0x750<br>&nbsp;[&lt;f8b=
0f11e&gt;] e1000_clean+0x4e/0x110 [e1000]<br>&nbsp;[&lt;c02bb0a1&gt;] net_r=
x_action+0xb1/0x110<br>&nbsp;[&lt;c01253e2&gt;] __do_softirq+0x62/0xe0<br>&=
nbsp;[&lt;c012548d&gt;] do_softirq+0x2d/0x40
<br>&nbsp;[&lt;c01062db&gt;] do_IRQ+0x3b/0x70<br>&nbsp;[&lt;c01049f2&gt;] c=
ommon_interrupt+0x1a/0x20<br>&nbsp;[&lt;c0102053&gt;] default_idle+0x23/0x3=
0<br>&nbsp;[&lt;c01020ee&gt;] cpu_idle+0x4e/0x60<br>&nbsp;[&lt;c03f696a&gt;=
] start_kernel+0x19a/0x220
<br>&nbsp;[&lt;c03f6360&gt;] unknown_bootoption+0x0/0x1e0<br>swapper: page =
allocation failure. order:0, mode:0x20<br>&nbsp;[&lt;c0144793&gt;] __alloc_=
pages+0x333/0x3b0<br>&nbsp;[&lt;c0147342&gt;] kmem_getpages+0x32/0xa0<br>&n=
bsp;[&lt;c014809e&gt;] cache_grow+0xbe/0x180
<br>&nbsp;[&lt;c01482cd&gt;] cache_alloc_refill+0x16d/0x240<br>&nbsp;[&lt;c=
014869c&gt;] __kmalloc+0x6c/0x80<br>&nbsp;[&lt;c02b4820&gt;] alloc_skb+0x40=
/0xf0<br>&nbsp;[&lt;f8b0f900&gt;] e1000_alloc_rx_buffers+0x40/0xf0 [e1000]<=
br>&nbsp;[&lt;f8b0f690&gt;] e1000_clean_rx_irq+0x280/0x4b0 [e1000]
<br>&nbsp;[&lt;c02b4b8d&gt;] __kfree_skb+0xad/0x160<br>&nbsp;[&lt;c02ea8b6&=
gt;] tcp_transmit_skb+0x426/0x750<br>&nbsp;[&lt;f8b0f11e&gt;] e1000_clean+0=
x4e/0x110 [e1000]<br>&nbsp;[&lt;c02bb0a1&gt;] net_rx_action+0xb1/0x110<br>&=
nbsp;[&lt;c01253e2&gt;] __do_softirq+0x62/0xe0
<br>&nbsp;[&lt;c012548d&gt;] do_softirq+0x2d/0x40<br>&nbsp;[&lt;c01062db&gt=
;] do_IRQ+0x3b/0x70<br>&nbsp;[&lt;c01049f2&gt;] common_interrupt+0x1a/0x20<=
br>&nbsp;[&lt;c0102053&gt;] default_idle+0x23/0x30<br>&nbsp;[&lt;c01020ee&g=
t;] cpu_idle+0x4e/0x60
<br>&nbsp;[&lt;c03f696a&gt;] start_kernel+0x19a/0x220<br>&nbsp;[&lt;c03f636=
0&gt;] unknown_bootoption+0x0/0x1e0<br>swapper: page allocation failure. or=
der:0, mode:0x20<br>&nbsp;[&lt;c0144793&gt;] __alloc_pages+0x333/0x3b0<br>&=
nbsp;[&lt;c0147342&gt;] kmem_getpages+0x32/0xa0
<br>&nbsp;[&lt;c014809e&gt;] cache_grow+0xbe/0x180<br>&nbsp;[&lt;c01482cd&g=
t;] cache_alloc_refill+0x16d/0x240<br>&nbsp;[&lt;c014869c&gt;] __kmalloc+0x=
6c/0x80<br>&nbsp;[&lt;c02b4820&gt;] alloc_skb+0x40/0xf0<br>&nbsp;[&lt;f8b0f=
900&gt;] e1000_alloc_rx_buffers+0x40/0xf0 [e1000]
<br>&nbsp;[&lt;f8b0f690&gt;] e1000_clean_rx_irq+0x280/0x4b0 [e1000]<br>&nbs=
p;[&lt;c02b4b8d&gt;] __kfree_skb+0xad/0x160<br>&nbsp;[&lt;c02ea8b6&gt;] tcp=
_transmit_skb+0x426/0x750<br>&nbsp;[&lt;f8b0f11e&gt;] e1000_clean+0x4e/0x11=
0 [e1000]<br>&nbsp;[&lt;c02bb0a1&gt;] net_rx_action+0xb1/0x110
<br>&nbsp;[&lt;c01253e2&gt;] __do_softirq+0x62/0xe0<br>&nbsp;[&lt;c012548d&=
gt;] do_softirq+0x2d/0x40<br>&nbsp;[&lt;c01062db&gt;] do_IRQ+0x3b/0x70<br>&=
nbsp;[&lt;c01049f2&gt;] common_interrupt+0x1a/0x20<br>&nbsp;[&lt;c0102053&g=
t;] default_idle+0x23/0x30
<br>&nbsp;[&lt;c01020ee&gt;] cpu_idle+0x4e/0x60<br>&nbsp;[&lt;c03f696a&gt;]=
 start_kernel+0x19a/0x220<br>&nbsp;[&lt;c03f6360&gt;] unknown_bootoption+0x=
0/0x1e0<br>printk: 130 messages suppressed.<br>nfsd: page allocation failur=
e. order:1, mode:0x20
<br>&nbsp;[&lt;c0144793&gt;] __alloc_pages+0x333/0x3b0<br>&nbsp;[&lt;c01473=
42&gt;] kmem_getpages+0x32/0xa0<br>&nbsp;[&lt;c014809e&gt;] cache_grow+0xbe=
/0x180<br>&nbsp;[&lt;c01482cd&gt;] cache_alloc_refill+0x16d/0x240<br>&nbsp;=
[&lt;c014869c&gt;] __kmalloc+0x6c/0x80
<br>&nbsp;[&lt;c02b4820&gt;] alloc_skb+0x40/0xf0<br>&nbsp;[&lt;c02e80d2&gt;=
] tcp_collapse+0x152/0x370<br>&nbsp;[&lt;c02e83f7&gt;] tcp_prune_queue+0x87=
/0x1e0<br>&nbsp;[&lt;c02e79f3&gt;] tcp_data_queue+0x573/0xb00<br>&nbsp;[&lt=
;c02e6312&gt;] tcp_ack+0xd2/0x5d0
<br>&nbsp;[&lt;c02e8df6&gt;] tcp_rcv_established+0x2e6/0x7f0<br>&nbsp;[&lt;=
c02f1960&gt;] tcp_v4_do_rcv+0xf0/0x110<br>&nbsp;[&lt;c02f21c1&gt;] tcp_v4_r=
cv+0x841/0x920<br>&nbsp;[&lt;c02d9d5a&gt;] ip_queue_xmit+0x30a/0x4f0<br>&nb=
sp;[&lt;c02d62d6&gt;] ip_local_deliver+0x96/0x260
<br>&nbsp;[&lt;c02d68c8&gt;] ip_rcv+0x428/0x500<br>&nbsp;[&lt;c02baeac&gt;]=
 netif_receive_skb+0x27c/0x2a0<br>&nbsp;[&lt;f8b0f4be&gt;] e1000_clean_rx_i=
rq+0xae/0x4b0 [e1000]<br>&nbsp;[&lt;c02b4b8d&gt;] __kfree_skb+0xad/0x160<br=
>&nbsp;[&lt;f8b0f11e&gt;] e1000_clean+0x4e/0x110 [e1000]
<br>&nbsp;[&lt;c02bb0a1&gt;] net_rx_action+0xb1/0x110<br>&nbsp;[&lt;c01253e=
2&gt;] __do_softirq+0x62/0xe0<br>&nbsp;[&lt;c012548d&gt;] do_softirq+0x2d/0=
x40<br>&nbsp;[&lt;c01062db&gt;] do_IRQ+0x3b/0x70<br>&nbsp;[&lt;c01049f2&gt;=
] common_interrupt+0x1a/0x20
<br>&nbsp;[&lt;f8a670f0&gt;] xtSearch+0x240/0x650 [jfs]<br>&nbsp;[&lt;f8a68=
b58&gt;] xtExtend+0x58/0x660 [jfs]<br>&nbsp;[&lt;c0162f40&gt;] nobh_commit_=
write+0x30/0x80<br>&nbsp;[&lt;c013fb8d&gt;] unlock_page+0x1d/0x30<br>&nbsp;=
[&lt;f8a7c4fa&gt;] __write_metapage+0x6a/0xb0 [jfs]
<br>&nbsp;[&lt;c01430b1&gt;] mempool_free+0x81/0xa0<br>&nbsp;[&lt;f8a71470&=
gt;] dbAlloc+0x3c0/0x4b0 [jfs]<br>&nbsp;[&lt;f8a7bd2f&gt;] extBalloc+0x20f/=
0x230 [jfs]<br>&nbsp;[&lt;c0181ac8&gt;] __mark_inode_dirty+0xd8/0x1e0<br>&n=
bsp;[&lt;c0168864&gt;] inode_add_bytes+0x24/0xa0
<br>&nbsp;[&lt;f8a7b954&gt;] extAlloc+0x434/0x460 [jfs]<br>&nbsp;[&lt;f8a63=
16c&gt;] jfs_get_blocks+0x27c/0x340 [jfs]<br>&nbsp;[&lt;c02d96aa&gt;] ip_fi=
nish_output+0xda/0x270<br>&nbsp;[&lt;f8a63250&gt;] jfs_get_block+0x20/0x30 =
[jfs]<br>&nbsp;[&lt;c0162c1c&gt;] nobh_prepare_write+0xec/0x3e0
<br>&nbsp;[&lt;c0144271&gt;] buffered_rmqueue+0xf1/0x210<br>&nbsp;[&lt;c017=
7446&gt;] d_alloc_anon+0x26/0x110<br>&nbsp;[&lt;c0144525&gt;] __alloc_pages=
+0xc5/0x3b0<br>&nbsp;[&lt;c013f9f6&gt;] add_to_page_cache+0xb6/0xe0<br>&nbs=
p;[&lt;c01418b7&gt;] generic_file_buffered_write+0x1b7/0x5e0
<br>&nbsp;[&lt;f8a63230&gt;] jfs_get_block+0x0/0x30 [jfs]<br>&nbsp;[&lt;c02=
ea8b6&gt;] tcp_transmit_skb+0x426/0x750<br>&nbsp;[&lt;c01799ee&gt;] inode_u=
pdate_time+0x9e/0xc0<br>&nbsp;[&lt;c0142013&gt;] __generic_file_aio_write_n=
olock+0x333/0x590
<br>&nbsp;[&lt;c02b0af1&gt;] sock_recvmsg+0x131/0x170<br>&nbsp;[&lt;c011a95=
d&gt;] finish_task_switch+0x3d/0x90<br>&nbsp;[&lt;c0335608&gt;] schedule+0x=
378/0xbb0<br>&nbsp;[&lt;c011a5df&gt;] try_to_wake_up+0x24f/0x280<br>&nbsp;[=
&lt;c01423a5&gt;] __generic_file_write_nolock+0x85/0xb0
<br>&nbsp;[&lt;c03350fe&gt;] __down+0xce/0xe0<br>&nbsp;[&lt;c011c030&gt;] d=
efault_wake_function+0x0/0x10<br>&nbsp;[&lt;c0134b60&gt;] autoremove_wake_f=
unction+0x0/0x50<br>&nbsp;[&lt;c0142560&gt;] generic_file_write+0x0/0xd0<br=
>&nbsp;[&lt;c0335233&gt;] __down_failed+0x7/0xc
<br>&nbsp;[&lt;c0142560&gt;] generic_file_write+0x0/0xd0<br>&nbsp;[&lt;c014=
2716&gt;] generic_file_writev+0x36/0xc0<br>&nbsp;[&lt;c020282a&gt;] __copy_=
from_user_ll+0x5a/0x80<br>&nbsp;[&lt;c01426e0&gt;] generic_file_writev+0x0/=
0xc0<br>&nbsp;[&lt;c0142560&gt;] generic_file_write+0x0/0xd0
<br>&nbsp;[&lt;c015f40b&gt;] do_readv_writev+0x23b/0x250<br>&nbsp;[&lt;f8a3=
9950&gt;] export_decode_fh+0x0/0xa5 [exportfs]<br>&nbsp;[&lt;c0142560&gt;] =
generic_file_write+0x0/0xd0<br>&nbsp;[&lt;c01253e2&gt;] __do_softirq+0x62/0=
xe0<br>&nbsp;[&lt;f8a62a67&gt;] jfs_open+0x17/0xa0 [jfs]
<br>&nbsp;[&lt;c015e008&gt;] dentry_open+0xe8/0x200<br>&nbsp;[&lt;c015f4b9&=
gt;] vfs_writev+0x49/0x50<br>&nbsp;[&lt;f8af545c&gt;] nfsd_write+0xfc/0x340=
 [nfsd]<br>&nbsp;[&lt;c0323045&gt;] ip_map_lookup+0x305/0x360<br>&nbsp;[&lt=
;c03232ca&gt;] svcauth_unix_set_client+0xba/0xd0
<br>&nbsp;[&lt;f8afc424&gt;] nfsd3_proc_write+0xc4/0x140 [nfsd]<br>&nbsp;[&=
lt;f8afe150&gt;] nfs3svc_decode_writeargs+0x0/0x180 [nfsd]<br>&nbsp;[&lt;f8=
af1696&gt;] nfsd_dispatch+0x136/0x200 [nfsd]<br>&nbsp;[&lt;c0322587&gt;] sv=
c_authenticate+0x87/0xe0
<br>&nbsp;[&lt;c031fae9&gt;] svc_process+0x409/0x620<br>&nbsp;[&lt;c01049f2=
&gt;] common_interrupt+0x1a/0x20<br>&nbsp;[&lt;f8af13d6&gt;] nfsd+0x196/0x3=
20 [nfsd]<br>&nbsp;[&lt;f8af1240&gt;] nfsd+0x0/0x320 [nfsd]<br>&nbsp;[&lt;c=
0102345&gt;] kernel_thread_helper+0x5/0x10
<br>printk: 18 messages suppressed.<br>nfsd: page allocation failure. order=
:0, mode:0x20<br>&nbsp;[&lt;c0144793&gt;] __alloc_pages+0x333/0x3b0<br>&nbs=
p;[&lt;c0147342&gt;] kmem_getpages+0x32/0xa0<br>&nbsp;[&lt;c014809e&gt;] ca=
che_grow+0xbe/0x180
<br>&nbsp;[&lt;c01482cd&gt;] cache_alloc_refill+0x16d/0x240<br>&nbsp;[&lt;c=
01485c4&gt;] kmem_cache_alloc+0x44/0x50<br>&nbsp;[&lt;c02b4803&gt;] alloc_s=
kb+0x23/0xf0<br>&nbsp;[&lt;f8b0f900&gt;] e1000_alloc_rx_buffers+0x40/0xf0 [=
e1000]<br>&nbsp;[&lt;f8b0f690&gt;] e1000_clean_rx_irq+0x280/0x4b0 [e1000]
<br>&nbsp;[&lt;c0119fc3&gt;] recalc_task_prio+0xd3/0x140<br>&nbsp;[&lt;f8b0=
f11e&gt;] e1000_clean+0x4e/0x110 [e1000]<br>&nbsp;[&lt;c02bb0a1&gt;] net_rx=
_action+0xb1/0x110<br>&nbsp;[&lt;c01253e2&gt;] __do_softirq+0x62/0xe0<br>&n=
bsp;[&lt;c012548d&gt;] do_softirq+0x2d/0x40
<br>&nbsp;[&lt;c01062db&gt;] do_IRQ+0x3b/0x70<br>&nbsp;[&lt;c01049f2&gt;] c=
ommon_interrupt+0x1a/0x20<br>&nbsp;[&lt;c018eba6&gt;] dnotify_parent+0x46/0=
xa0<br>&nbsp;[&lt;c01426e0&gt;] generic_file_writev+0x0/0xc0<br>&nbsp;[&lt;=
c015f3b8&gt;] do_readv_writev+0x1e8/0x250
<br>&nbsp;[&lt;f8a39950&gt;] export_decode_fh+0x0/0xa5 [exportfs]<br>&nbsp;=
[&lt;c0142560&gt;] generic_file_write+0x0/0xd0<br>&nbsp;[&lt;f8a62a67&gt;] =
jfs_open+0x17/0xa0 [jfs]<br>&nbsp;[&lt;c015e008&gt;] dentry_open+0xe8/0x200=
<br>&nbsp;[&lt;c015f4b9&gt;] vfs_writev+0x49/0x50
<br>&nbsp;[&lt;f8af545c&gt;] nfsd_write+0xfc/0x340 [nfsd]<br>&nbsp;[&lt;c03=
23045&gt;] ip_map_lookup+0x305/0x360<br>&nbsp;[&lt;c03232ca&gt;] svcauth_un=
ix_set_client+0xba/0xd0<br>&nbsp;[&lt;f8afc424&gt;] nfsd3_proc_write+0xc4/0=
x140 [nfsd]<br>&nbsp;[&lt;f8afe150&gt;] nfs3svc_decode_writeargs+0x0/0x180 =
[nfsd]
<br>&nbsp;[&lt;f8af1696&gt;] nfsd_dispatch+0x136/0x200 [nfsd]<br>&nbsp;[&lt=
;c0322587&gt;] svc_authenticate+0x87/0xe0<br>&nbsp;[&lt;c031fae9&gt;] svc_p=
rocess+0x409/0x620<br>&nbsp;[&lt;c01049f2&gt;] common_interrupt+0x1a/0x20<b=
r>&nbsp;[&lt;f8af13d6&gt;] nfsd+0x196/0x320 [nfsd]
<br>&nbsp;[&lt;f8af1240&gt;] nfsd+0x0/0x320 [nfsd]<br>&nbsp;[&lt;c0102345&g=
t;] kernel_thread_helper+0x5/0x10<br><br>

------=_Part_19388_5742211.1134782727081--


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
