Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:59442 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753938Ab3D1Omw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 28 Apr 2013 10:42:52 -0400
Date: Sun, 28 Apr 2013 10:42:48 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Yan Burman <yanb@mellanox.com>
Cc: Wendy Cheng <s.wendy.cheng@gmail.com>,
        "Atchley, Scott" <atchleyes@ornl.gov>,
        Tom Tucker <tom@opengridcomputing.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: NFS over RDMA benchmark
Message-ID: <20130428144248.GA2037@fieldses.org>
References: <0EE9A1CDC8D6434DB00095CD7DB873462CF96C65@MTLDAG01.mtl.com>
 <CABgxfbF7c9ktSoMSPV21JU76V5J4iwbJQ257S91Y3z36WJbJVA@mail.gmail.com>
 <62745258-4F3B-4C05-BFFD-03EA604576E4@ornl.gov>
 <CABgxfbGxhnKj2n0Z-w87rZ6fwCssO31G009gwej957gv1p8PQQ@mail.gmail.com>
 <0EE9A1CDC8D6434DB00095CD7DB873462CF9715B@MTLDAG01.mtl.com>
 <20130423210607.GJ3676@fieldses.org>
 <0EE9A1CDC8D6434DB00095CD7DB873462CF988C9@MTLDAG01.mtl.com>
 <20130424150540.GB20275@fieldses.org>
 <20130424152631.GC20275@fieldses.org>
 <0EE9A1CDC8D6434DB00095CD7DB873462CF9A820@MTLDAG01.mtl.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <0EE9A1CDC8D6434DB00095CD7DB873462CF9A820@MTLDAG01.mtl.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Apr 28, 2013 at 06:28:16AM +0000, Yan Burman wrote:
> > > > > > > >> On Wed, Apr 17, 2013 at 7:36 AM, Yan Burman
> > > > > > > >> <yanb@mellanox.com>
> > > > > > > >>> I've been trying to do some benchmarks for NFS over RDMA
> > > > > > > >>> and I seem to
> > > > > > > only get about half of the bandwidth that the HW can give me.
> > > > > > > >>> My setup consists of 2 servers each with 16 cores, 32Gb of
> > > > > > > >>> memory, and
> > > > > > > Mellanox ConnectX3 QDR card over PCI-e gen3.
> > > > > > > >>> These servers are connected to a QDR IB switch. The
> > > > > > > >>> backing storage on
> > > > > > > the server is tmpfs mounted with noatime.
> > > > > > > >>> I am running kernel 3.5.7.
> > > > > > > >>>
> > > > > > > >>> When running ib_send_bw, I get 4.3-4.5 GB/sec for block sizes 4-
> > 512K.
> > > > > > > >>> When I run fio over rdma mounted nfs, I get 260-2200MB/sec
> > > > > > > >>> for the
> > > > > > > same block sizes (4-512K). running over IPoIB-CM, I get 200-
> > 980MB/sec.
...
> > > > > > I am trying to get maximum performance from a single server - I
> > > > > > used 2
> > > > > processes in fio test - more than 2 did not show any performance boost.
> > > > > > I tried running fio from 2 different PCs on 2 different files,
> > > > > > but the sum of
> > > > > the two is more or less the same as running from single client PC.
> > > > > >
> > > > > > What I did see is that server is sweating a lot more than the
> > > > > > clients and
> > > > > more than that, it has 1 core (CPU5) in 100% softirq tasklet:
> > > > > > cat /proc/softirqs
...
> > > > Perf top for the CPU with high tasklet count gives:
> > > >
> > > >              samples  pcnt         RIP        function                    DSO
...
> > > >              2787.00 24.1% ffffffff81062a00 mutex_spin_on_owner
> > /root/vmlinux
...
> > Googling around....  I think we want:
> > 
> > 	perf record -a --call-graph
> > 	(give it a chance to collect some samples, then ^C)
> > 	perf report --call-graph --stdio
> > 
> 
> Sorry it took me a while to get perf to show the call trace (did not enable frame pointers in kernel and struggled with perf options...), but what I get is:
>     36.18%          nfsd  [kernel.kallsyms]   [k] mutex_spin_on_owner
>                     |
>                     --- mutex_spin_on_owner
>                        |
>                        |--99.99%-- __mutex_lock_slowpath
>                        |          mutex_lock
>                        |          |
>                        |          |--85.30%-- generic_file_aio_write

That's the inode i_mutex.

>                        |          |          do_sync_readv_writev
>                        |          |          do_readv_writev
>                        |          |          vfs_writev
>                        |          |          nfsd_vfs_write
>                        |          |          nfsd_write
>                        |          |          nfsd3_proc_write
>                        |          |          nfsd_dispatch
>                        |          |          svc_process_common
>                        |          |          svc_process
>                        |          |          nfsd
>                        |          |          kthread
>                        |          |          kernel_thread_helper
>                        |          |
>                        |           --14.70%-- svc_send

That's the xpt_mutex (ensuring rpc replies aren't interleaved).

>                        |                     svc_process
>                        |                     nfsd
>                        |                     kthread
>                        |                     kernel_thread_helper
>                         --0.01%-- [...]
> 
>      9.63%          nfsd  [kernel.kallsyms]   [k] _raw_spin_lock_irqsave
>                     |
>                     --- _raw_spin_lock_irqsave
>                        |
>                        |--43.97%-- alloc_iova

And that (and __free_iova below) looks like iova_rbtree_lock.

--b.

>                        |          intel_alloc_iova
>                        |          __intel_map_single
>                        |          intel_map_page
>                        |          |
>                        |          |--60.47%-- svc_rdma_sendto
>                        |          |          svc_send
>                        |          |          svc_process
>                        |          |          nfsd
>                        |          |          kthread
>                        |          |          kernel_thread_helper
>                        |          |
>                        |          |--30.10%-- rdma_read_xdr
>                        |          |          svc_rdma_recvfrom
>                        |          |          svc_recv
>                        |          |          nfsd
>                        |          |          kthread
>                        |          |          kernel_thread_helper
>                        |          |
>                        |          |--6.69%-- svc_rdma_post_recv
>                        |          |          send_reply
>                        |          |          svc_rdma_sendto
>                        |          |          svc_send
>                        |          |          svc_process
>                        |          |          nfsd
>                        |          |          kthread
>                        |          |          kernel_thread_helper
>                        |          |
>                        |           --2.74%-- send_reply
>                        |                     svc_rdma_sendto
>                        |                     svc_send
>                        |                     svc_process
>                        |                     nfsd
>                        |                     kthread
>                        |                     kernel_thread_helper
>                        |
>                        |--37.52%-- __free_iova
>                        |          flush_unmaps
>                        |          add_unmap
>                        |          intel_unmap_page
>                        |          |
>                        |          |--97.18%-- svc_rdma_put_frmr
>                        |          |          sq_cq_reap
>                        |          |          dto_tasklet_func
>                        |          |          tasklet_action
>                        |          |          __do_softirq
>                        |          |          call_softirq
>                        |          |          do_softirq
>                        |          |          |
>                        |          |          |--97.40%-- irq_exit
>                        |          |          |          |
>                        |          |          |          |--99.85%-- do_IRQ
>                        |          |          |          |          ret_from_intr
>                        |          |          |          |          |
>                        |          |          |          |          |--40.74%-- generic_file_buffered_write
>                        |          |          |          |          |          __generic_file_aio_write
>                        |          |          |          |          |          generic_file_aio_write
>                        |          |          |          |          |          do_sync_readv_writev
>                        |          |          |          |          |          do_readv_writev
>                        |          |          |          |          |          vfs_writev
>                        |          |          |          |          |          nfsd_vfs_write
>                        |          |          |          |          |          nfsd_write
>                        |          |          |          |          |          nfsd3_proc_write
>                        |          |          |          |          |          nfsd_dispatch
>                        |          |          |          |          |          svc_process_common
>                        |          |          |          |          |          svc_process
>                        |          |          |          |          |          nfsd
>                        |          |          |          |          |          kthread
>                        |          |          |          |          |          kernel_thread_helper
>                        |          |          |          |          |
>                        |          |          |          |          |--25.21%-- __mutex_lock_slowpath
>                        |          |          |          |          |          mutex_lock
>                        |          |          |          |          |          |
>                        |          |          |          |          |          |--94.84%-- generic_file_aio_write
>                        |          |          |          |          |          |          do_sync_readv_writev
>                        |          |          |          |          |          |          do_readv_writev
>                        |          |          |          |          |          |          vfs_writev
>                        |          |          |          |          |          |          nfsd_vfs_write
>                        |          |          |          |          |          |          nfsd_write
>                        |          |          |          |          |          |          nfsd3_proc_write
>                        |          |          |          |          |          |          nfsd_dispatch
>                        |          |          |          |          |          |          svc_process_common
>                        |          |          |          |          |          |          svc_process
>                        |          |          |          |          |          |          nfsd
>                        |          |          |          |          |          |          kthread
>                        |          |          |          |          |          |          kernel_thread_helper
>                        |          |          |          |          |          |
> 
> The entire trace is almost 1MB, so send me an off-list message if you want it.
> 
> Yan
> 
