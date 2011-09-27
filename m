Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from peace.netnation.com ([204.174.223.2]:53674 "EHLO
	peace.netnation.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752740Ab1I0Ajd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 26 Sep 2011 20:39:33 -0400
Date: Mon, 26 Sep 2011 17:39:31 -0700
From: Simon Kirby <sim@hostway.ca>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: NFS client growing system CPU
Message-ID: <20110927003931.GB12106@hostway.ca>
References: <20101208212505.GA18192@hostway.ca> <1291845189.3067.31.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1291845189.3067.31.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hello!

Following up on "System CPU increasing on idle 2.6.36", this issue is
still happening even on 3.1-rc7. So, since it has been 9 months since I
reported this, I figured I'd bisect this issue. The first bisection ended
in an IPMI regression that looked like the problem, so I had to start
again. Eventually, I got commit b80c3cb628f0ebc241b02e38dd028969fb8026a2
which made it into 2.6.34-rc4.

With this commit, system CPU keeps rising as the log crunch box runs
(reads log files via NFS and spews out HTML files into NFS-mounted report
directories). When it finishes the daily run, the system time stays
non-zero and continues to be higher and higher after each run, until the
box never completes a run within a day due to all of the wasted cycles.

I previously posted a munin CPU graph picture here:

http://0x.ca/sim/ref/2.6.36/cpu_logcrunch_nfs.png

Here is the most recent graph of me bisecting, roughly one day at a time:

http://0x.ca/sim/ref/2.6.34/cpu.png

Running a kernel built on this commit, I can actually make the problem
stop by just typing "sync". CPU then goes down to 0 and everything is
fine. Future kernel versions, such as 2.6.36, do not change with just a
"sync", but "sync;echo 3 > /proc/sys/vm/drop_caches;sync" _does_ stop
the system CPU usage. I can bisect this change, too, if that would help.

Here is the commit:

commit b80c3cb628f0ebc241b02e38dd028969fb8026a2
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Apr 9 19:07:07 2010 -0400

    NFS: Ensure that writeback_single_inode() calls write_inode() when syncing
    
    Since writeback_single_inode() checks the inode->i_state flags _before_ it
    flushes out the data, we need to ensure that the I_DIRTY_DATASYNC flag is
    already set. Otherwise we risk not seeing a call to write_inode(), which
    again means that we break fsync() et al...
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 53ff70e..7f40ea3 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -421,6 +421,7 @@ static void
 nfs_mark_request_dirty(struct nfs_page *req)
 {
 	__set_page_dirty_nobuffers(req->wb_page);
+	__mark_inode_dirty(req->wb_page->mapping->host, I_DIRTY_DATASYNC);
 }
 
 #if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
@@ -660,6 +661,7 @@ static int nfs_writepage_setup(struct nfs_open_context *ctx, struct page *page,
 	req = nfs_setup_write_request(ctx, page, offset, count);
 	if (IS_ERR(req))
 		return PTR_ERR(req);
+	nfs_mark_request_dirty(req);
 	/* Update file length */
 	nfs_grow_file(page, offset, count);
 	nfs_mark_uptodate(page, req->wb_pgbase, req->wb_bytes);
@@ -739,8 +741,6 @@ int nfs_updatepage(struct file *file, struct page *page,
 	status = nfs_writepage_setup(ctx, page, offset, count);
 	if (status < 0)
 		nfs_set_pageerror(page);
-	else
-		__set_page_dirty_nobuffers(page);
 
 	dprintk("NFS:       nfs_updatepage returns %d (isize %lld)\n",
 			status, (long long)i_size_read(inode));

With the build before this commit, the system time stays low always and
returns to 0% after every daily run.

Simon-

On Wed, Dec 08, 2010 at 04:53:09PM -0500, Trond Myklebust wrote:

> On Wed, 2010-12-08 at 13:25 -0800, Simon Kirby wrote:
> > Possibly related to the flush-processes-taking-CPU issues I saw
> > previously, I thought this was interesting.  I found a log-crunching box
> > that does all of its work via NFS and spends most of the day sleeping. 
> > It has been using a linearly-increasing amount of system time during the
> > time where is sleeping.  munin graph:
> > 
> > http://0x.ca/sim/ref/2.6.36/cpu_logcrunch_nfs.png
> > 
> > top shows:
> > 
> >   PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND
> >  4767 root      20   0     0    0    0 S   16  0.0   2413:29 flush-0:69
> > 22385 root      20   0     0    0    0 S   10  0.0   1320:23 flush-0:70
> > (rest idle)
> > 
> > perf top shows:
> > 
> > -------------------------------------------------------------------------------------------
> >    PerfTop:     252 irqs/sec  kernel:97.2%  exact:  0.0% [1000Hz cycles],  (all, 2 CPUs)
> > -------------------------------------------------------------------------------------------
> > 
> >      samples  pcnt function                        DSO
> >      _______ _____ _______________________________ ___________
> > 
> >       912.00 21.2% _raw_spin_lock                  [kernel]
> >       592.00 13.8% nfs_writepages                  [kernel]
> >       474.00 11.0% queue_io                        [kernel]
> >       428.00 10.0% writeback_single_inode          [kernel]
> >       379.00  8.8% writeback_sb_inodes             [kernel]
> >       237.00  5.5% bit_waitqueue                   [kernel]
> >       184.00  4.3% do_writepages                   [kernel]
> >       169.00  3.9% __iget                          [kernel]
> >       132.00  3.1% redirty_tail                    [kernel]
> >        85.00  2.0% iput                            [kernel]
> >        72.00  1.7% _atomic_dec_and_lock            [kernel]
> >        67.00  1.6% write_cache_pages               [kernel]
> >        63.00  1.5% port_inb                        [ipmi_si]
> >        62.00  1.4% __mark_inode_dirty              [kernel]
> >        48.00  1.1% __wake_up_bit                   [kernel]
> >        32.00  0.7% nfs_write_inode                 [kernel]
> >        26.00  0.6% native_read_tsc                 [kernel]
> >        25.00  0.6% radix_tree_gang_lookup_tag_slot [kernel]
> >        25.00  0.6% schedule                        [kernel]
> >        24.00  0.6% wake_up_bit                     [kernel]
> >        20.00  0.5% apic_timer_interrupt            [kernel]
> >        19.00  0.4% ia32_syscall                    [kernel]
> >        16.00  0.4% find_get_pages_tag              [kernel]
> >        15.00  0.3% _raw_spin_lock_irqsave          [kernel]
> >        15.00  0.3% load_balance                    [kernel]
> >        13.00  0.3% ktime_get                       [kernel]
> >        12.00  0.3% shrink_icache_memory            [kernel]
> >        11.00  0.3% semop                           libc-2.7.so
> > 	9.00  0.2% nfs_pageio_doio                 [kernel]
> > 	8.00  0.2% dso__find_symbol                perf
> > 	8.00  0.2% down_read                       [kernel]
> > 	7.00  0.2% __switch_to                     [kernel]
> > 	7.00  0.2% __phys_addr                     [kernel]
> > 	7.00  0.2% nfs_pageio_init                 [kernel]
> > 	7.00  0.2% pagevec_lookup_tag              [kernel]
> > 	7.00  0.2% _cond_resched                   [kernel]
> > 	7.00  0.2% up_read                         [kernel]
> > 	6.00  0.1% sched_clock_local               [kernel]
> > 	5.00  0.1% rb_erase                        [kernel]
> > 	5.00  0.1% page_fault                      [kernel]
> > 
> > "tcpdump -i any -n port 2049" and "nfsstat" shows this work does not actually result
> > in any NFS packets.
> > 
> > Known 2.6.36 issue?  This did not occur on 2.6.35.4, according to the
> > munin graphs.  I'll try 2.6.37-rc an see if it changes.
> 
> Possibly a side effect of the fs/fs-writeback.c changes in 2.6.36? You
> do appear to be hitting a lot of spinlock contention, but I suspect that
> a lot of it is coming from writeback_sb_inodes, writeback_single_inode
> and queue_io, all of which seem unnaturally high on your stats above.
> 
> I don't see how you can be seeing no traffic on the wire. You are
> certainly hitting some page writeout (0.2% nfs_pageio_doio).
> 
> Cheers
>   Trond
> -- 
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
