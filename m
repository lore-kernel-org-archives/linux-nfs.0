Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from netnation.com ([204.174.223.2]:53200 "EHLO peace.netnation.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754280Ab0LNXir (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 Dec 2010 18:38:47 -0500
Date: Tue, 14 Dec 2010 15:38:43 -0800
From: Simon Kirby <sim@hostway.ca>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: System CPU increasing on idle 2.6.36
Message-ID: <20101214233843.GB836@hostway.ca>
References: <20101208212505.GA18192@hostway.ca> <1291845189.3067.31.camel@heimdal.trondhjem.org> <20101208223622.GA3796@hostway.ca> <1291869437.2821.6.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1291869437.2821.6.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Dec 08, 2010 at 11:37:17PM -0500, Trond Myklebust wrote:

> On Wed, 2010-12-08 at 14:36 -0800, Simon Kirby wrote:
> > On Wed, Dec 08, 2010 at 04:53:09PM -0500, Trond Myklebust wrote:
> >
> > > Possibly a side effect of the fs/fs-writeback.c changes in 2.6.36? You
> > > do appear to be hitting a lot of spinlock contention, but I suspect that
> > > a lot of it is coming from writeback_sb_inodes, writeback_single_inode
> > > and queue_io, all of which seem unnaturally high on your stats above.
> > >
> > > I don't see how you can be seeing no traffic on the wire. You are
> > > certainly hitting some page writeout (0.2% nfs_pageio_doio).
> >
> > It really seems to not be doing anything.  I ran nfsstat -Zcv for 5
> > minutes, and the only non-zero counters are rpc calls and authrefrsh,
> > even though perf top shows similar profiles the whole time.
>
> That sounds like a bug in nfsstat, then. As I said, your trace results
> definitely indicate that you are doing page writeout. I'd cross check
> using wireshark...

I know it's weird, but it really isn't writing anything.  Confirmed with
tcpdump and tshark.  Maybe it writes a single thing after a lot of
trying, or something.

2.6.36.1 is also doing the same thing when completely idle, after
finishing a bunch of log crunching.  I'm just about to try
2.6.37-rc5-git3 on there plus your NFS fixes (which Linus seems to have
half-merged and uploaded as -git3 but not pushed to his public git) and
your NFSv4 UID patch, which I will be testing shortly.  If it works, this
should show if the same flush issue exists there or not.

Also, I just saw something similar in from 2.6.37-rc4-git1 plus your leak
fixes (this ver of top's %sys cpu is broken, ignore):

top - 16:54:44 up 8 days, 16:04,  1 user,  load average: 40.11, 43.36, 24.71
Tasks: 490 total,  28 running, 461 sleeping,   0 stopped,   1 zombie
Cpu(s): 17.8%us,  6.9%sy,  0.0%ni, 60.2%id, 13.1%wa,  0.0%hi,  2.0%si,  0.0%st
Mem:   4051256k total,  1717004k used,  2334252k free,    17112k buffers
Swap:   979960k total,   268756k used,   711204k free,   362940k cached

  PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND
 2221 root      20   0     0    0    0 R   16  0.0   4:37.71 flush-0:65
10557 root      20   0     0    0    0 R   16  0.0   2:54.90 flush-0:46
 7240 root      20   0     0    0    0 R   15  0.0   7:46.64 flush-0:31
 8682 root      20   0     0    0    0 R   15  0.0   3:04.89 flush-0:34
13915 root      20   0     0    0    0 R   15  0.0   4:37.43 flush-0:27
17778 root      20   0     0    0    0 R   15  0.0   4:53.57 flush-0:83
19281 root      20   0     0    0    0 R   15  0.0   3:59.55 flush-0:56
19484 root      20   0     0    0    0 R   15  0.0  17:12.80 flush-0:77
19693 root      20   0     0    0    0 R   15  0.0   6:16.20 flush-0:71
25272 root      20   0     0    0    0 R   15  0.0   3:47.70 flush-0:68
 5494 root      20   0     0    0    0 R   13  0.0  28:23.03 flush-0:75
 7095 root      20   0     0    0    0 R   13  0.0   1:55.52 flush-0:42
10298 root      20   0     0    0    0 R   13  0.0   3:39.00 flush-0:61
13900 root      20   0     0    0    0 R   13  0.0   8:38.14 flush-0:80
14389 root      20   0     0    0    0 R   13  0.0   4:52.59 flush-0:81
16412 root      20   0     0    0    0 R   13  0.0   2:52.46 flush-0:33
17225 root      20   0     0    0    0 R   13  0.0   4:01.92 flush-0:78
20985 root      20   0     0    0    0 R   13  0.0   3:09.37 flush-0:29
24424 root      20   0     0    0    0 R   13  0.0   2:01.69 flush-0:20
25273 root      20   0     0    0    0 R   13  0.0   4:08.11 flush-0:70
25560 root      20   0     0    0    0 R   13  0.0   3:40.00 flush-0:69
27578 root      20   0     0    0    0 R   13  0.0   6:17.51 flush-0:57
25270 root      20   0     0    0    0 R   12  0.0   5:15.30 flush-0:26
25392 root      20   0     0    0    0 R   12  0.0   2:39.36 flush-0:82
27488 root      20   0     0    0    0 R   12  0.0   3:35.94 flush-0:76
31283 root      20   0     0    0    0 R   12  0.0   2:58.57 flush-0:18
28461 root      20   0 29556 2404 1544 R    4  0.1   0:00.04 top
 6426 root      20   0     0    0    0 S    1  0.0   1:57.74 flush-0:73
14639 root      20   0     0    0    0 S    1  0.0   2:41.38 flush-0:58
20081 root      20   0     0    0    0 S    1  0.0   1:51.78 flush-0:60
24845 root      20   0     0    0    0 S    1  0.0   2:55.30 flush-0:32
    1 root      20   0 10364  332  328 S    0  0.0   0:10.35 init

   PerfTop:    3886 irqs/sec  kernel:98.8%  exact:  0.0% [1000Hz cycles],  (all, 4 CPUs)
----------------------------------------------------------------------------------------

             samples  pcnt function                        DSO
             _______ _____ _______________________________ __________________________

            17772.00 80.6% _raw_spin_lock                  [kernel.kallsyms]
              770.00  3.5% nfs_writepages                  [kernel.kallsyms]
              530.00  2.4% writeback_sb_inodes             [kernel.kallsyms]
              463.00  2.1% writeback_single_inode          [kernel.kallsyms]
              364.00  1.7% queue_io                        [kernel.kallsyms]
              283.00  1.3% nfs_write_inode                 [kernel.kallsyms]
              210.00  1.0% bit_waitqueue                   [kernel.kallsyms]
              185.00  0.8% redirty_tail                    [kernel.kallsyms]
              182.00  0.8% do_writepages                   [kernel.kallsyms]
              155.00  0.7% __iget                          [kernel.kallsyms]
              129.00  0.6% iput                            [kernel.kallsyms]
              122.00  0.6% __mark_inode_dirty              [kernel.kallsyms]
              102.00  0.5% write_cache_pages               [kernel.kallsyms]
               89.00  0.4% file_softmagic                  /usr/lib/libmagic.so.1.0.0
               67.00  0.3% _atomic_dec_and_lock            [kernel.kallsyms]
               53.00  0.2% is_bad_inode                    [kernel.kallsyms]
               48.00  0.2% page_fault                      [kernel.kallsyms]
               44.00  0.2% __wake_up_bit                   [kernel.kallsyms]
               32.00  0.1% find_get_pages_tag              [kernel.kallsyms]
               25.00  0.1% wake_up_bit                     [kernel.kallsyms]
               17.00  0.1% copy_page_c                     [kernel.kallsyms]
               17.00  0.1% clear_page_c                    [kernel.kallsyms]
               13.00  0.1% radix_tree_gang_lookup_tag_slot [kernel.kallsyms]
               12.00  0.1% ktime_get                       [kernel.kallsyms]
               12.00  0.1% symbol_filter                   /usr/local/bin/perf
               12.00  0.1% pagevec_lookup_tag              [kernel.kallsyms]
               11.00  0.0% mapping_tagged                  [kernel.kallsyms]
               10.00  0.0% do_page_fault                   [kernel.kallsyms]
               10.00  0.0% unmap_vmas                      [kernel.kallsyms]
                9.00  0.0% find_get_page                   [kernel.kallsyms]
                9.00  0.0% dso__load_sym                   /usr/local/bin/perf
                9.00  0.0% __phys_addr                     [kernel.kallsyms]
                8.00  0.0% nfs_pageio_init                 [kernel.kallsyms]
                8.00  0.0% __d_lookup                      [kernel.kallsyms]
                8.00  0.0% filemap_fault                   [kernel.kallsyms]
                7.00  0.0% sched_clock_local               [kernel.kallsyms]
                7.00  0.0% memset                          /lib/libc-2.7.so
                7.00  0.0% number                          [kernel.kallsyms]
                6.00  0.0% handle_mm_fault                 [kernel.kallsyms]
                6.00  0.0% symbols__insert                 /usr/local/bin/perf
                6.00  0.0% radix_tree_tagged               [kernel.kallsyms]
                5.00  0.0% perf_event_task_tick            [kernel.kallsyms]
                5.00  0.0% native_write_msr_safe           [kernel.kallsyms]
                5.00  0.0% kfree                           [kernel.kallsyms]
                5.00  0.0% __switch_to                     [kernel.kallsyms]
                5.00  0.0% strlen                          /lib/libc-2.7.so
                5.00  0.0% _cond_resched                   [kernel.kallsyms]
                5.00  0.0% format_decode                   [kernel.kallsyms]
                5.00  0.0% nfs_pageio_doio                 [kernel.kallsyms]

# cat /proc/5494/stack
[<ffffffff81052025>] __cond_resched+0x25/0x40
[<ffffffff81135459>] writeback_sb_inodes+0xb9/0x140
[<ffffffff81135efc>] writeback_inodes_wb+0xcc/0x140
[<ffffffff8113629b>] wb_writeback+0x32b/0x370
[<ffffffff811363b4>] wb_do_writeback+0xd4/0x1d0
[<ffffffff8113658b>] bdi_writeback_thread+0xdb/0x240
[<ffffffff81075046>] kthread+0x96/0xb0
[<ffffffff8100bca4>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

# vmstat 1
procs -----------memory---------- ---swap-- -----io---- -system-- ----cpu----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa
24  0 256484 2346524  26168 385584    0    1    33    26    5   14 18  9 60 13
25  0 256320 2346528  26168 385676    4    0   156     0 2041 2900  2 98  0  0
24  0 256144 2348916  26168 385968   32    0   172     8 2030 2879  3 97  0  0
24  0 255984 2349260  26168 386136    8    0   156     4 2080 2970  1 99  0  0
24  0 255360 2351216  26176 386168  128    0   272    44 2082 2942  0 100  0  0
25  0 255152 2351352  26184 386248   52    0   196    44 2071 3030  2 98  0  0
23  0 254880 2353400  26192 386660  144    0   296    84 2249 2960  3 97  0  0
23  0 254660 2354028  26192 386756   40    0   200     8 2060 3114  1 100  0  0

Gradually, the flush processes go back to sleeping, and then everything
works again, as if nothing happened.  This is in contrast to what we
are seeing on the log crunching server, where system time just keeps
increasing forever with each log cruching run.  These two cases may or
may not be the same problem.

See longer vmstat, nfsstat output, etc. here:

http://0x.ca/sim/ref/2.6.37-rc4-git1_flushy_nfs/

Simon-
