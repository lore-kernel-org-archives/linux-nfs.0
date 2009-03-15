From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [patch 2/3] knfsd: avoid overloading the CPU scheduler with
	enormous load averages
Date: Sun, 15 Mar 2009 17:21:12 -0400
Message-ID: <20090315212112.GB27568@fieldses.org>
References: <20090113102633.719563000@sgi.com> <20090113102653.664553000@sgi.com> <20090211231033.GK27686@fieldses.org> <499CFB6B.1010902@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS ML <linux-nfs@vger.kernel.org>
To: Greg Banks <gnb@sgi.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:58979 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753564AbZCOVVN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 15 Mar 2009 17:21:13 -0400
In-Reply-To: <499CFB6B.1010902@sgi.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 19, 2009 at 05:25:47PM +1100, Greg Banks wrote:
> J. Bruce Fields wrote:
> > On Tue, Jan 13, 2009 at 09:26:35PM +1100, Greg Banks wrote:
> >   
> >> [...] Under a high call-rate
> >> low service-time workload, the result is that almost every nfsd is
> >> runnable, but only a handful are actually able to run.  This situation
> >> causes two significant problems:
> >>
> >> 1. The CPU scheduler takes over 10% of each CPU, which is robbing
> >>    the nfsd threads of valuable CPU time.
> >>
> >> 2. At a high enough load, the nfsd threads starve userspace threads
> >>    of CPU time, to the point where daemons like portmap and rpc.mountd
> >>    do not schedule for tens of seconds at a time.  Clients attempting
> >>    to mount an NFS filesystem timeout at the very first step (opening
> >>    a TCP connection to portmap) because portmap cannot wake up from
> >>    select() and call accept() in time.
> >>
> >> Disclaimer: these effects were observed on a SLES9 kernel, modern
> >> kernels' schedulers may behave more gracefully.
> >>     
> >
> > Yes, googling for "SLES9 kernel"...   Was that really 2.6.5 based?
> >
> > The scheduler's been through at least one complete rewrite since then,
> > so the obvious question is whether it's wise to apply something that may
> > turn out to have been very specific to an old version of the scheduler.
> >
> > It's a simple enough patch, but without any suggestion for how to retest
> > on a more recent kernel, I'm uneasy.
> >
> >   
> 
> Ok, fair enough.  I retested using my local GIT tree, which is cloned
> from yours and was last git-pull'd a couple of days ago.  The test load
> was the same as in my 2005 tests (multiple userspace threads each
> simulating an rsync directory traversal from a 2.4 client, i.e. almost
> entirely ACCESS calls with some READDIRs and GETATTRs, running as fast
> as the server will respond).  This was run on much newer hardware (and a
> different architecture as well: a quad-core Xeon) so the results are not
> directly comparable with my 2005 tests.  However the effect with and
> without the patch can be clearly seen, with otherwise identical hardware
> software and load (I added a sysctl to enable and disable the effect of
> the patch at runtime).
> 
> A quick summary: the 2.6.29-rc4 CPU scheduler is not magically better
> than the 2.6.5 one and NFS can still benefit from reducing load on it.
> 
> Here's a table of measured call rates and steady-state 1-minute load
> averages, before and after the patch, versus number of client load
> threads.   The server was configured with 128 nfsds in the thread pool
> which was under load.  In all cases except the the single CPU in the
> thread pool was 100% busy (I've elided the 8-thread results where that
> wasn't the case).
> 
> #threads    before                  after
>             call/sec    loadavg     call/sec    loadavg
> --------    --------    -------     --------    -------
> 16          57353       10.98       74965        6.11
> 24          57787       19.56       79397       13.58
> 32          57921       26.00       80746       21.35
> 40          57936       35.32       81629       31.73
> 48          57930       43.84       81775       42.64
> 56          57467       51.05       81411       52.39
> 64          57595       57.93       81543       64.61
> 
> 
> As you can see, the patch improves NFS throughput for this load by up
> to  40%, which is a surprisingly large improvement.  I suspect it's a
> larger improvement because my 2005 tests had multiple CPUs serving NFS
> traffic, and the improvements due to this patch were drowned in various
> SMP effects which are absent from this test.
> 
> Also surprising is that the patch improves the reported load average
> number only at higher numbers of client threads; at low client thread
> counts the load average is unchanged or even slightly higher.  The patch
> didn't have that effect back in 2005, so I'm confused by that
> behaviour.  Perhaps the difference is due to changes in the scheduler or
> the accounting that measures load averages?
> 
> Profiling at 16 client threads, 32 server threads shows differences in
> the CPU usage in the CPU scheduler itself, with some ACPI effects too. 
> The platform I ran on in 2005 did not support ACPI, so that's new to
> me.  Nevertheless it makes a difference.  Here are the top samples from
> a couple of 30-second flat profiles.
> 
> Before:
> 
> samples  %        image name               app name                 symbol name
> 3013      4.9327  processor.ko             processor                acpi_idle_enter_simple  <---
> 2583      4.2287  sunrpc.ko                sunrpc                   svc_recv
> 1273      2.0841  e1000e.ko                e1000e                   e1000_irq_enable
> 1235      2.0219  sunrpc.ko                sunrpc                   svc_process
> 1070      1.7517  e1000e.ko                e1000e                   e1000_intr_msi
> 966       1.5815  e1000e.ko                e1000e                   e1000_xmit_frame
> 884       1.4472  sunrpc.ko                sunrpc                   svc_xprt_enqueue
> 861       1.4096  e1000e.ko                e1000e                   e1000_clean_rx_irq
> 774       1.2671  xfs.ko                   xfs                      xfs_iget
> 772       1.2639  vmlinux-2.6.29-rc4-gnb   vmlinux-2.6.29-rc4-gnb   schedule                <---
> 726       1.1886  vmlinux-2.6.29-rc4-gnb   vmlinux-2.6.29-rc4-gnb   sched_clock             <---
> 693       1.1345  vmlinux-2.6.29-rc4-gnb   vmlinux-2.6.29-rc4-gnb   read_hpet               <---
> 680       1.1133  sunrpc.ko                sunrpc                   cache_check
> 671       1.0985  vmlinux-2.6.29-rc4-gnb   vmlinux-2.6.29-rc4-gnb   tcp_sendpage
> 641       1.0494  sunrpc.ko                sunrpc                   sunrpc_cache_lookup
> 
> Total % cpu from ACPI & scheduler: 8.5%
> 
> After:
> 
> samples  %        image name               app name                 symbol name
> 5145      5.2163  sunrpc.ko                sunrpc                   svc_recv
> 2908      2.9483  processor.ko             processor                acpi_idle_enter_simple  <---
> 2731      2.7688  sunrpc.ko                sunrpc                   svc_process
> 2092      2.1210  e1000e.ko                e1000e                   e1000_clean_rx_irq
> 1988      2.0155  e1000e.ko                e1000e                   e1000_xmit_frame
> 1863      1.8888  e1000e.ko                e1000e                   e1000_irq_enable
> 1606      1.6282  xfs.ko                   xfs                      xfs_iget
> 1514      1.5350  sunrpc.ko                sunrpc                   cache_check
> 1389      1.4082  vmlinux-2.6.29-rc4-gnb   vmlinux-2.6.29-rc4-gnb   tcp_recvmsg
> 1383      1.4022  vmlinux-2.6.29-rc4-gnb   vmlinux-2.6.29-rc4-gnb   tcp_sendpage
> 1310      1.3281  sunrpc.ko                sunrpc                   svc_xprt_enqueue
> 1177      1.1933  sunrpc.ko                sunrpc                   sunrpc_cache_lookup
> 1142      1.1578  vmlinux-2.6.29-rc4-gnb   vmlinux-2.6.29-rc4-gnb   get_page_from_freelist
> 1135      1.1507  sunrpc.ko                sunrpc                   svc_tcp_recvfrom
> 1126      1.1416  vmlinux-2.6.29-rc4-gnb   vmlinux-2.6.29-rc4-gnb   tcp_transmit_skb
> 1040      1.0544  e1000e.ko                e1000e                   e1000_intr_msi
> 1033      1.0473  vmlinux-2.6.29-rc4-gnb   vmlinux-2.6.29-rc4-gnb   tcp_ack
> 1030      1.0443  vmlinux-2.6.29-rc4-gnb   vmlinux-2.6.29-rc4-gnb   kref_get
> 1000      1.0138  nfsd.ko                  nfsd                     fh_verify
> 
> Total % cpu from ACPI & scheduler: 2.9%
> 
> 
> Does that make you less uneasy?

Yes, thanks!

Queued up for 2.6.30, barring objections.  But perhaps we should pass on
the patch and your results to people who know the scheduler better and
see if they can explain e.g. the loadavg numbers.

--b.
