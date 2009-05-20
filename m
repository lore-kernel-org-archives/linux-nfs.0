From: "Weathers, Norman R." <Norman.R.Weathers-496aOtIFJR1B+Kdf37RAV9BPR1lH4CV8@public.gmane.org>
Subject: RE: Possible NFS failure with late kernel versions
Date: Wed, 20 May 2009 13:37:52 -0500
Message-ID: <0122F800A3B64C449565A9E8C297701005E6DE4D@hoexmb9.conoco.net>
References: <0122F800A3B64C449565A9E8C297701005E6DE4B@hoexmb9.conoco.net> <1242838935.24471.20.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <linux-nfs@vger.kernel.org>, <netdev@vger.kernel.org>
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mailman2.ppco.com ([138.32.41.14]:38250 "EHLO mailman2.ppco.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755305AbZETSiA convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 May 2009 14:38:00 -0400
In-Reply-To: <1242838935.24471.20.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

 

> -----Original Message-----
> From: Trond Myklebust [mailto:trond.myklebust@fys.uio.no] 
> Sent: Wednesday, May 20, 2009 12:02 PM
> To: Weathers, Norman R.
> Cc: linux-nfs@vger.kernel.org; netdev@vger.kernel.org
> Subject: Re: Possible NFS failure with late kernel versions
> 
> On Wed, 2009-05-20 at 11:50 -0500, Weathers, Norman R. wrote:
> > Hello, list.
> > 
> > I have run across some weird failures as of late.  The 
> following is a
> > kernel bug output from one kernel (2.6.27.24):
> > 
> > ------------[ cut here ]------------
> > WARNING: at kernel/softirq.c:136 local_bh_enable_ip+0xb5/0xf0()
> > Modules linked in: nfsd lockd nfs_acl exportfs autofs4 sunrpc
> > scsi_dh_emc ip6t_REJECT nf_conntrack_ipv6 ip6table_filter ip6_tables
> > ipv6 xfs uinput iTCO_wdt iTCO_vendor_support ipmi_si iw_nes qla2xxx
> > ipmi_msghandler bnx2 serio_raw pcspkr joydev ib_core 
> i5000_edac hpwdt
> > scsi_transport_fc hpilo edac_core scsi_tgt libcrc32c dm_round_robin
> > dm_multipath shpchp cciss [last unloaded: freq_table]
> > Pid: 3094, comm: nfsd Not tainted 2.6.27.24 #1
> > 
> > Call Trace:
> >  [<ffffffff81043b9f>] warn_on_slowpath+0x5f/0x90
> >  [<ffffffff81049ebc>] ? local_bh_enable_ip+0x8c/0xf0
> >  [<ffffffff813b9760>] ? _read_unlock_bh+0x10/0x20
> >  [<ffffffff81384914>] ? ipt_do_table+0x1d4/0x550
> >  [<ffffffff81337036>] ? nf_conntrack_in+0x236/0x5d0
> >  [<ffffffff8133747a>] ? destroy_conntrack+0xaa/0x110
> >  [<ffffffff81049ee5>] local_bh_enable_ip+0xb5/0xf0
> >  [<ffffffff813b977f>] _spin_unlock_bh+0xf/0x20
> >  [<ffffffff8133747a>] destroy_conntrack+0xaa/0x110
> >  [<ffffffff813344e2>] nf_conntrack_destroy+0x12/0x20
> >  [<ffffffff8130bc65>] skb_release_all+0xc5/0x100
> >  [<ffffffff8130b541>] __kfree_skb+0x11/0xa0
> >  [<ffffffff8130b5e7>] kfree_skb+0x17/0x40
> >  [<ffffffffa010eed8>] nes_nic_send+0x408/0x4b0 [iw_nes]
> >  [<ffffffff81319fac>] ? neigh_resolve_output+0x10c/0x2d0
> >  [<ffffffffa010f089>] nes_netdev_start_xmit+0x109/0xa60 [iw_nes]
> >  [<ffffffff81337579>] ? __nf_ct_refresh_acct+0x99/0x190
> >  [<ffffffff8133add2>] ? tcp_packet+0xa42/0xeb0
> >  [<ffffffff81348ff4>] ? ip_queue_xmit+0x1e4/0x3b0
> >  [<ffffffff81384914>] ? ipt_do_table+0x1d4/0x550
> >  [<ffffffff81049ebc>] ? local_bh_enable_ip+0x8c/0xf0
> >  [<ffffffff813b9760>] ? _read_unlock_bh+0x10/0x20
> >  [<ffffffff81384914>] ? ipt_do_table+0x1d4/0x550
> >  [<ffffffff81337036>] ? nf_conntrack_in+0x236/0x5d0
> >  [<ffffffff81313f5d>] dev_hard_start_xmit+0x21d/0x2a0
> >  [<ffffffff81328b4e>] __qdisc_run+0x1ee/0x230
> >  [<ffffffff813160a8>] dev_queue_xmit+0x2f8/0x580
> >  [<ffffffff81319fac>] neigh_resolve_output+0x10c/0x2d0
> >  [<ffffffff8134983c>] ip_finish_output+0x1cc/0x2f0
> >  [<ffffffff813499c5>] ip_output+0x65/0xb0
> >  [<ffffffff81348780>] ip_local_out+0x20/0x30
> >  [<ffffffff81348ff4>] ip_queue_xmit+0x1e4/0x3b0
> >  [<ffffffff8135cbcb>] tcp_transmit_skb+0x4eb/0x760
> >  [<ffffffff8135cfe7>] tcp_send_ack+0xd7/0x110
> >  [<ffffffff81355e3c>] __tcp_ack_snd_check+0x5c/0xc0
> >  [<ffffffff8135add9>] tcp_rcv_established+0x6e9/0x9e0
> >  [<ffffffff81363330>] tcp_v4_do_rcv+0x2c0/0x410
> >  [<ffffffff81307aec>] ? lock_sock_nested+0xbc/0xd0
> >  [<ffffffff813079c5>] release_sock+0x65/0xd0
> >  [<ffffffff81350bd1>] tcp_ioctl+0xc1/0x190
> >  [<ffffffff81371547>] inet_ioctl+0x27/0xc0
> >  [<ffffffff81303cba>] kernel_sock_ioctl+0x3a/0x60
> >  [<ffffffffa025882d>] svc_tcp_recvfrom+0x11d/0x450 [sunrpc]
> >  [<ffffffffa02627b0>] svc_recv+0x560/0x850 [sunrpc]
> >  [<ffffffff8103bcf0>] ? default_wake_function+0x0/0x10
> >  [<ffffffffa02a69ad>] nfsd+0xdd/0x2d0 [nfsd]
> >  [<ffffffffa02a68d0>] ? nfsd+0x0/0x2d0 [nfsd]
> >  [<ffffffffa02a68d0>] ? nfsd+0x0/0x2d0 [nfsd]
> >  [<ffffffff8105aa69>] kthread+0x49/0x90
> >  [<ffffffff8100d5b9>] child_rip+0xa/0x11
> >  [<ffffffff8100cbfc>] ? restore_args+0x0/0x30
> >  [<ffffffff8105aa20>] ? kthread+0x0/0x90
> >  [<ffffffff8100d5af>] ? child_rip+0x0/0x11
> > 
> > ---[ end trace 7decf549249f3f2a ]---
> > 
> > I have used 2.6.28.10 and 2.6.29 and they all have this 
> same bug.  The
> > end result is that under heavy load, these servers crash 
> within a few
> > minutes of emitting this trace.
> > 
> > Hardware:  HP Proliant Server, Dual 3.0 GHz Intel CPUs, 16 
> GB memory.
> > Storage:    Qlogic QLA2xxx 4 Gb fibre card to EMC CX3-80 (Multipath)
> > Network:    Intel / NetEffect 10 Gb iWarp NE20 (fibre)
> > OS:           Fedora 10
> > Clients:      CentOS 5.2 10 Gb nodes / 10 Gb switches, so a 
> very fast
> > network.
> > 
> > Any assistance would be greatly appreciated.
> > 
> > If need be, I can restart the server under the different 
> kernels and see
> > if I can get the error from those as well.
> 
> Your trace shows that this is happening down in the murky 
> depths of the
> netfilter code, so to me it looks more like a networking issue rather
> than a NFS bug.
> 
> Ccing the linux networking list...
> 
> Cheers
>   Trond
> 
> 

Trond, I have disabled the netfilter code, and since have had another
crash (Actually, on this kernel version I disabled the netfilter code
completely within the kernel config).  Here are the two strack traces
that I got.


Pre Oops time (happened about 2 or 3 minutes before the kernel Oopsed)

ksoftirqd/3: page allocation failure. order:0, mode:0x4020          
Pid: 13, comm: ksoftirqd/3 Not tainted 2.6.29.1 #2                  
Call Trace:                                                         
 <IRQ>  [<ffffffff810bd5be>] __alloc_pages_internal+0x3fe/0x510     
 [<ffffffff810e8018>] alloc_pages_current+0xa8/0x100                
 [<ffffffff810edd48>] new_slab+0x308/0x340                          
 [<ffffffff810f0374>] __slab_alloc+0x184/0x490                      
 [<ffffffff81355e88>] ? dev_alloc_skb+0x18/0x30                     
 [<ffffffff810f15b3>] __kmalloc_node_track_caller+0xb3/0x150        
 [<ffffffff81355e88>] ? dev_alloc_skb+0x18/0x30                     
 [<ffffffff81355b67>] __alloc_skb+0x77/0x150                        
 [<ffffffff81355e88>] dev_alloc_skb+0x18/0x30                       
 [<ffffffffa00ece2e>] nes_replenish_nic_rq+0xee/0x2e0 [iw_nes]      
 [<ffffffff810308b0>] ? swiotlb_map_single_phys+0x0/0x20            
 [<ffffffffa00eda80>] nes_nic_ce_handler+0x560/0x830 [iw_nes]       
 [<ffffffffa00f3f99>] nes_netdev_poll+0x59/0xd0 [iw_nes]            
 [<ffffffff8135c606>] net_rx_action+0x116/0x1e0                     
 [<ffffffff8105afc4>] __do_softirq+0xa4/0x190                       
 [<ffffffff81013bcc>] call_softirq+0x1c/0x30                        
 <EOI>  [<ffffffff81015125>] do_softirq+0x95/0xe0                   
 [<ffffffff8105a77f>] ksoftirqd+0x8f/0x140                          
 [<ffffffff8105a6f0>] ? ksoftirqd+0x0/0x140                         
 [<ffffffff8106c7f9>] kthread+0x49/0x90                             
 [<ffffffff81013aca>] child_rip+0xa/0x20                            
 [<ffffffff810133e7>] ? restore_args+0x0/0x30                       
 [<ffffffff8106c7b0>] ? kthread+0x0/0x90                            
 [<ffffffff81013ac0>] ? child_rip+0x0/0x20                          
Mem-Info:                                                           
Node 0 DMA per-cpu:                                                 
CPU    0: hi:    0, btch:   1 usd:   0                              
CPU    1: hi:    0, btch:   1 usd:   0                              
CPU    2: hi:    0, btch:   1 usd:   0                              
CPU    3: hi:    0, btch:   1 usd:   0                              
Node 0 DMA32 per-cpu:                                               
CPU    0: hi:  186, btch:  31 usd: 162                              
CPU    1: hi:  186, btch:  31 usd: 157                              
CPU    2: hi:  186, btch:  31 usd: 165                              
CPU    3: hi:  186, btch:  31 usd:  24                              
Node 0 Normal per-cpu:                                              
CPU    0: hi:  186, btch:  31 usd: 162                              
CPU    1: hi:  186, btch:  31 usd: 156                              
CPU    2: hi:  186, btch:  31 usd: 141                              
CPU    3: hi:  186, btch:  31 usd:  30                              
Active_anon:5787 active_file:4121 inactive_anon:609                 
 inactive_file:3859133 unevictable:949 dirty:72066 writeback:420127
unstable:0
 free:19448 slab:188121 mapped:3788 pagetables:1243 bounce:0

Node 0 DMA free:7752kB min:16kB low:20kB high:24kB active_anon:0kB
inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB
present:5928kB pages_scanned:0 all_unreclaimable? no

lowmem_reserve[]: 0 3254 16132 16132

Node 0 DMA32 free:55268kB min:10080kB low:12600kB high:15120kB
active_anon:16kB inactive_anon:4kB active_file:20kB
inactive_file:2876596kB unevictable:0kB present:3332668kB
pages_scanned:0 all_unreclaimable? no

lowmem_reserve[]: 0 0 12877 12877

Node 0 Normal free:14772kB min:39896kB low:49868kB high:59844kB
active_anon:23132kB inactive_anon:2432kB active_file:16464kB
inactive_file:12559936kB unevictable:3796kB present:13186556kB
pages_scanned:0 all_unreclaimable? no                     
lowmem_reserve[]: 0 0 0 0

Node 0 DMA: 6*4kB 2*8kB 4*16kB 3*32kB 4*64kB 3*128kB 5*256kB 3*512kB
0*1024kB 0*2048kB 1*4096kB = 7752kB

Node 0 DMA32: 149*4kB 80*8kB 151*16kB 90*32kB 43*64kB 68*128kB 14*256kB
12*512kB 3*1024kB 2*2048kB 5*4096kB = 55364kB

Node 0 Normal: 642*4kB 78*8kB 2*16kB 1*32kB 0*64kB 0*128kB 29*256kB
6*512kB 1*1024kB 0*2048kB 0*4096kB = 14776kB

3864020 total pagecache pages

0 pages in swap cache

Swap cache stats: add 0, delete 0, find 0/0

Free swap  = 8193140kB

Total swap = 8193140kB

4194303 pages RAM

77144 pages reserved

3872144 pages shared

233650 pages non-shared 






At Oops time:

                                                          
[root@hoepld27 ~]# invalid opcode: 0000 [#1] SMP

last sysfs file:
/sys/devices/pci0000:00/0000:00:1c.1/0000:04:00.0/0000:05:00.0/irq

CPU 1

Modules linked in: nfsd nfs lockd nfs_acl autofs4 sunrpc scsi_dh_emc
ipv6 xfs exportfs uinput qla2xxx iw_nes i5000_edac edac_core iTCO_wdt
scsi_transport_fc serio_raw iTCO_vendor_support bnx2 ib_core hpwdt
pcspkr ipmi_si i5k_amb joydev hpilo hwmon ipmi_msghandler scsi_tgt
crc32c libcrc32c dm_round_robin dm_multipath shpchp cciss [last
unloaded: freq_table]

Pid: 3667, comm: nfsd Tainted: G        W  2.6.29.1 #2 ProLiant DL380 G5
RIP: 0010:[<ffffffff810106ee>]  [<ffffffff810106ee>]
__switch_to+0x25e/0x4d0
RSP: 0018:ffff880429585d20  EFLAGS: 00010002
RAX: 00000000ffffffff RBX: ffff88042b54dfe0 RCX: 0000000000000018
RDX: 00000000ffffffff RSI: 0000000000000001 RDI: 0000000000000000
RBP: ffff880429585d60 R08: 00000000001a530a R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000000 R12: ffff88042b54db80
R13: ffff88042404c4a0 R14: 0000000000000000 R15: 0000000000000001
FS:  0000000000000000(0000) GS:ffff88042d2c4600(0000)
knlGS:0000000000000000
CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
CR2: 00007f05491e3000 CR3: 0000000424c6c000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process nfsd (pid: 3667, threadinfo ffff88041ed80000, task
ffff88042404c4a0)
Stack:
 ffff88042404c900 00000000ffffffff ffff880028051500 ffff880028053980
 0000000000000000 ffff88042a88c780 0000000000000001 0000000000000001
 ffff88042b54db80 ffffffff813f88dd ffff880429585e70 0000000000000046
Call Trace:
Code: 6c 48 83 c4 18 4c 89 e8 5b 41 5c 41 5d 41 5e 41 5f c9 c3 66 2e 0f
1f 84 00 00 00 00 00 b8 ff ff ff ff 49 8b bd f8 04 00 00 89 c2 <48> 0f
ae 27 e9 0e ff ff ff66 0f 1f 84 00 00 00 00 00 80 7a 02
RIP  [<ffffffff810106ee>] __switch_to+0x25e/0x4d0
 RSP <ffff880429585d20>
---[ end trace c3ba62a02de151b3 ]---

The only reason I sent this back to you is that one of the processes
mentioned above was nfsd, but it looks like from the pre kernel crash
that there is something happening at the network / possibly NetEffect
driver level.

Any other ideas?

Thanks,

Norman Weathers
