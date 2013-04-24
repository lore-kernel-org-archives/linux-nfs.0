Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:52355 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755395Ab3DXP0c (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Apr 2013 11:26:32 -0400
Date: Wed, 24 Apr 2013 11:26:31 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Yan Burman <yanb@mellanox.com>
Cc: Wendy Cheng <s.wendy.cheng@gmail.com>,
        "Atchley, Scott" <atchleyes@ornl.gov>,
        Tom Tucker <tom@opengridcomputing.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: NFS over RDMA benchmark
Message-ID: <20130424152631.GC20275@fieldses.org>
References: <0EE9A1CDC8D6434DB00095CD7DB873462CF96C65@MTLDAG01.mtl.com>
 <CABgxfbF7c9ktSoMSPV21JU76V5J4iwbJQ257S91Y3z36WJbJVA@mail.gmail.com>
 <62745258-4F3B-4C05-BFFD-03EA604576E4@ornl.gov>
 <CABgxfbGxhnKj2n0Z-w87rZ6fwCssO31G009gwej957gv1p8PQQ@mail.gmail.com>
 <0EE9A1CDC8D6434DB00095CD7DB873462CF9715B@MTLDAG01.mtl.com>
 <20130423210607.GJ3676@fieldses.org>
 <0EE9A1CDC8D6434DB00095CD7DB873462CF988C9@MTLDAG01.mtl.com>
 <20130424150540.GB20275@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130424150540.GB20275@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 24, 2013 at 11:05:40AM -0400, J. Bruce Fields wrote:
> On Wed, Apr 24, 2013 at 12:35:03PM +0000, Yan Burman wrote:
> > 
> > 
> > > -----Original Message-----
> > > From: J. Bruce Fields [mailto:bfields@fieldses.org]
> > > Sent: Wednesday, April 24, 2013 00:06
> > > To: Yan Burman
> > > Cc: Wendy Cheng; Atchley, Scott; Tom Tucker; linux-rdma@vger.kernel.org;
> > > linux-nfs@vger.kernel.org; Or Gerlitz
> > > Subject: Re: NFS over RDMA benchmark
> > > 
> > > On Thu, Apr 18, 2013 at 12:47:09PM +0000, Yan Burman wrote:
> > > >
> > > >
> > > > > -----Original Message-----
> > > > > From: Wendy Cheng [mailto:s.wendy.cheng@gmail.com]
> > > > > Sent: Wednesday, April 17, 2013 21:06
> > > > > To: Atchley, Scott
> > > > > Cc: Yan Burman; J. Bruce Fields; Tom Tucker;
> > > > > linux-rdma@vger.kernel.org; linux-nfs@vger.kernel.org
> > > > > Subject: Re: NFS over RDMA benchmark
> > > > >
> > > > > On Wed, Apr 17, 2013 at 10:32 AM, Atchley, Scott
> > > > > <atchleyes@ornl.gov>
> > > > > wrote:
> > > > > > On Apr 17, 2013, at 1:15 PM, Wendy Cheng <s.wendy.cheng@gmail.com>
> > > > > wrote:
> > > > > >
> > > > > >> On Wed, Apr 17, 2013 at 7:36 AM, Yan Burman <yanb@mellanox.com>
> > > > > wrote:
> > > > > >>> Hi.
> > > > > >>>
> > > > > >>> I've been trying to do some benchmarks for NFS over RDMA and I
> > > > > >>> seem to
> > > > > only get about half of the bandwidth that the HW can give me.
> > > > > >>> My setup consists of 2 servers each with 16 cores, 32Gb of
> > > > > >>> memory, and
> > > > > Mellanox ConnectX3 QDR card over PCI-e gen3.
> > > > > >>> These servers are connected to a QDR IB switch. The backing
> > > > > >>> storage on
> > > > > the server is tmpfs mounted with noatime.
> > > > > >>> I am running kernel 3.5.7.
> > > > > >>>
> > > > > >>> When running ib_send_bw, I get 4.3-4.5 GB/sec for block sizes 4-512K.
> > > > > >>> When I run fio over rdma mounted nfs, I get 260-2200MB/sec for
> > > > > >>> the
> > > > > same block sizes (4-512K). running over IPoIB-CM, I get 200-980MB/sec.
> > > > > >
> > > > > > Yan,
> > > > > >
> > > > > > Are you trying to optimize single client performance or server
> > > > > > performance
> > > > > with multiple clients?
> > > > > >
> > > >
> > > > I am trying to get maximum performance from a single server - I used 2
> > > processes in fio test - more than 2 did not show any performance boost.
> > > > I tried running fio from 2 different PCs on 2 different files, but the sum of
> > > the two is more or less the same as running from single client PC.
> > > >
> > > > What I did see is that server is sweating a lot more than the clients and
> > > more than that, it has 1 core (CPU5) in 100% softirq tasklet:
> > > > cat /proc/softirqs
> > > 
> > > Would any profiling help figure out which code it's spending time in?
> > > (E.g. something simple as "perf top" might have useful output.)
> > > 
> > 
> > 
> > Perf top for the CPU with high tasklet count gives:
> > 
> >              samples  pcnt         RIP        function                    DSO
> >              _______ _____ ________________ ___________________________ ___________________________________________________________________
> > 
> >              2787.00 24.1% ffffffff81062a00 mutex_spin_on_owner         /root/vmlinux
> 
> I guess that means lots of contention on some mutex?  If only we knew
> which one.... perf should also be able to collect stack statistics, I
> forget how.

Googling around....  I think we want:

	perf record -a --call-graph
	(give it a chance to collect some samples, then ^C)
	perf report --call-graph --stdio

--b.

> 
> --b.
> 
> >               978.00  8.4% ffffffff810297f0 clflush_cache_range         /root/vmlinux
> >               445.00  3.8% ffffffff812ea440 __domain_mapping            /root/vmlinux
> >               441.00  3.8% 0000000000018c30 svc_recv                    /lib/modules/3.5.7-dbg/kernel/net/sunrpc/sunrpc.ko
> >               344.00  3.0% ffffffff813a1bc0 _raw_spin_lock_bh           /root/vmlinux
> >               333.00  2.9% ffffffff813a19e0 _raw_spin_lock_irqsave      /root/vmlinux
> >               288.00  2.5% ffffffff813a07d0 __schedule                  /root/vmlinux
> >               249.00  2.1% ffffffff811a87e0 rb_prev                     /root/vmlinux
> >               242.00  2.1% ffffffff813a19b0 _raw_spin_lock              /root/vmlinux
> >               184.00  1.6% 0000000000002e90 svc_rdma_sendto             /lib/modules/3.5.7-dbg/kernel/net/sunrpc/xprtrdma/svcrdma.ko
> >               177.00  1.5% ffffffff810ac820 get_page_from_freelist      /root/vmlinux
> >               174.00  1.5% ffffffff812e6da0 alloc_iova                  /root/vmlinux
> >               165.00  1.4% ffffffff810b1390 put_page                    /root/vmlinux
> >               148.00  1.3% 0000000000014760 sunrpc_cache_lookup         /lib/modules/3.5.7-dbg/kernel/net/sunrpc/sunrpc.ko
> >               128.00  1.1% 0000000000017f20 svc_xprt_enqueue            /lib/modules/3.5.7-dbg/kernel/net/sunrpc/sunrpc.ko
> >               126.00  1.1% ffffffff8139f820 __mutex_lock_slowpath       /root/vmlinux
> >               108.00  0.9% ffffffff811a81d0 rb_insert_color             /root/vmlinux
> >               107.00  0.9% 0000000000004690 svc_rdma_recvfrom           /lib/modules/3.5.7-dbg/kernel/net/sunrpc/xprtrdma/svcrdma.ko
> >               102.00  0.9% 0000000000002640 send_reply                  /lib/modules/3.5.7-dbg/kernel/net/sunrpc/xprtrdma/svcrdma.ko
> >                99.00  0.9% ffffffff810e6490 kmem_cache_alloc            /root/vmlinux
> >                96.00  0.8% ffffffff810e5840 __slab_alloc                /root/vmlinux
> >                91.00  0.8% 0000000000006d30 mlx4_ib_post_send           /lib/modules/3.5.7-dbg/kernel/drivers/infiniband/hw/mlx4/mlx4_ib.ko
> >                88.00  0.8% 0000000000000dd0 svc_rdma_get_context        /lib/modules/3.5.7-dbg/kernel/net/sunrpc/xprtrdma/svcrdma.ko
> >                86.00  0.7% ffffffff813a1a10 _raw_spin_lock_irq          /root/vmlinux
> >                86.00  0.7% 0000000000001530 svc_rdma_send               /lib/modules/3.5.7-dbg/kernel/net/sunrpc/xprtrdma/svcrdma.ko
> >                85.00  0.7% ffffffff81060a80 prepare_creds               /root/vmlinux
> >                83.00  0.7% ffffffff810a5790 find_get_pages_contig       /root/vmlinux
> >                79.00  0.7% ffffffff810e4620 __slab_free                 /root/vmlinux
> >                79.00  0.7% ffffffff813a1a40 _raw_spin_unlock_irqrestore /root/vmlinux
> >                77.00  0.7% ffffffff81065610 finish_task_switch          /root/vmlinux
> >                76.00  0.7% ffffffff812e9270 pfn_to_dma_pte              /root/vmlinux
> >                75.00  0.6% ffffffff810976d0 __call_rcu                  /root/vmlinux
> >                73.00  0.6% ffffffff811a2fa0 _atomic_dec_and_lock        /root/vmlinux
> >                73.00  0.6% 00000000000002e0 svc_rdma_has_wspace         /lib/modules/3.5.7-dbg/kernel/net/sunrpc/xprtrdma/svcrdma.ko
> >                67.00  0.6% ffffffff813a1a70 _raw_read_lock              /root/vmlinux
> >                65.00  0.6% 000000000000f590 svcauth_unix_set_client     /lib/modules/3.5.7-dbg/kernel/net/sunrpc/sunrpc.ko
> >                63.00  0.5% 00000000000180e0 svc_reserve                 /lib/modules/3.5.7-dbg/kernel/net/sunrpc/sunrpc.ko
> >                60.00  0.5% 00000000000064d0 stamp_send_wqe              /lib/modules/3.5.7-dbg/kernel/drivers/infiniband/hw/mlx4/mlx4_ib.ko
> >                57.00  0.5% ffffffff810ac110 free_hot_cold_page          /root/vmlinux
> >                57.00  0.5% ffffffff811ae540 memcpy                      /root/vmlinux
> >                56.00  0.5% ffffffff810ad1a0 __alloc_pages_nodemask      /root/vmlinux
> >                55.00  0.5% ffffffff81118200 splice_to_pipe              /root/vmlinux
> >                53.00  0.5% ffffffff810e3bc0 get_partial_node            /root/vmlinux
> >                49.00  0.4% ffffffff812eb840 __intel_map_single          /root/vmlinux
> > 
> > 
> > > --b.
> > > 
> > > >                     CPU0       CPU1       CPU2       CPU3       CPU4       CPU5       CPU6
> > > CPU7       CPU8       CPU9       CPU10      CPU11      CPU12      CPU13      CPU14
> > > CPU15
> > > >           HI:          0          0          0          0          0          0          0          0          0
> > > 0          0          0          0          0          0          0
> > > >        TIMER:     418767      46596      43515      44547      50099      34815
> > > 40634      40337      39551      93442      73733      42631      42509      41592
> > > 40351      61793
> > > >       NET_TX:      28719        309       1421       1294       1730       1243        832
> > > 937         11         44         41         20         26         19         15         29
> > > >       NET_RX:     612070         19         22         21          6        235          3          2
> > > 9          6         17         16         20         13         16         10
> > > >        BLOCK:       5941          0          0          0          0          0          0          0
> > > 519        259       1238        272        253        174        215       2618
> > > > BLOCK_IOPOLL:          0          0          0          0          0          0          0          0
> > > 0          0          0          0          0          0          0          0
> > > >      TASKLET:         28          1          1          1          1    1540653          1          1
> > > 29          1          1          1          1          1          1          2
> > > >        SCHED:     364965      26547      16807      18403      22919       8678
> > > 14358      14091      16981      64903      47141      18517      19179      18036
> > > 17037      38261
> > > >      HRTIMER:         13          0          1          1          0          0          0          0
> > > 0          0          0          0          1          1          0          1
> > > >          RCU:     945823     841546     715281     892762     823564      42663
> > > 863063     841622     333577     389013     393501     239103     221524     258159
> > > 313426     234030
