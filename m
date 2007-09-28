From: "Chakri n" <chakriin5@gmail.com>
Subject: Re: A unresponsive file system can hang all I/O in the system on linux-2.6.23-rc6 (dirty_thresh problem?)
Date: Fri, 28 Sep 2007 14:36:40 -0700
Message-ID: <92cbf19b0709281436i41247863t6cbc919c33e972a3@mail.gmail.com>
References: <92cbf19b0709272332s25684643odaade0e98cb3a1f4@mail.gmail.com>
	 <20070927235034.ae7bd73d.akpm@linux-foundation.org>
	 <1190998853.6702.17.camel@heimdal.trondhjem.org>
	 <20070928114930.2c201324.akpm@linux-foundation.org>
	 <1191006971.6702.25.camel@heimdal.trondhjem.org>
	 <20070928122628.965137f2.akpm@linux-foundation.org>
	 <1191009148.6702.46.camel@heimdal.trondhjem.org>
	 <20070928131012.4a03c53e.akpm@linux-foundation.org>
	 <1191011538.6702.59.camel@heimdal.trondhjem.org>
	 <20070928134326.e3bb63b1.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Trond Myklebust" <trond.myklebust@fys.uio.no>,
	linux-pm@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	nfs@lists.sourceforge.net, a.p.zijlstra@chello.nl
To: "Andrew Morton" <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757415AbXI1Vgx@vger.kernel.org>
In-Reply-To: <20070928134326.e3bb63b1.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Here is a the snapshot of vmstats when the problem happened. I believe
this could help a little.

crash> kmem -V
       NR_FREE_PAGES: 680853
         NR_INACTIVE: 95380
           NR_ACTIVE: 26891
       NR_ANON_PAGES: 2507
      NR_FILE_MAPPED: 1832
       NR_FILE_PAGES: 119779
       NR_FILE_DIRTY: 0
        NR_WRITEBACK: 18272
 NR_SLAB_RECLAIMABLE: 1305
NR_SLAB_UNRECLAIMABLE: 2085
        NR_PAGETABLE: 123
     NR_UNSTABLE_NFS: 0
           NR_BOUNCE: 0
     NR_VMSCAN_WRITE: 0

In my testing, I always saw the processes are waiting in
balance_dirty_pages_ratelimited(), never in throttle_vm_writeout()
path.

But this could be because I have about 4Gig of memory in the system
and plenty of mem is still available around.

I will rerun the test limiting memory to 1024MB and lets see if it
takes in any different path.

Thanks
--Chakri


On 9/28/07, Andrew Morton <akpm@linux-foundation.org> wrote:
> On Fri, 28 Sep 2007 16:32:18 -0400
> Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
>
> > On Fri, 2007-09-28 at 13:10 -0700, Andrew Morton wrote:
> > > On Fri, 28 Sep 2007 15:52:28 -0400
> > > Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> > >
> > > > On Fri, 2007-09-28 at 12:26 -0700, Andrew Morton wrote:
> > > > > On Fri, 28 Sep 2007 15:16:11 -0400 Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> > > > > > Looking back, they were getting caught up in
> > > > > > balance_dirty_pages_ratelimited() and friends. See the attached
> > > > > > example...
> > > > >
> > > > > that one is nfs-on-loopback, which is a special case, isn't it?
> > > >
> > > > I'm not sure that the hang that is illustrated here is so special. It is
> > > > an example of a bog-standard ext3 write, that ends up calling the NFS
> > > > client, which is hanging. The fact that it happens to be hanging on the
> > > > nfsd process is more or less irrelevant here: the same thing could
> > > > happen to any other process in the case where we have an NFS server that
> > > > is down.
> > >
> > > hm, so ext3 got stuck in nfs via __alloc_pages direct reclaim?
> > >
> > > We should be able to fix that by marking the backing device as
> > > write-congested.  That'll have small race windows, but it should be a 99.9%
> > > fix?
> >
> > No. The problem would rather appear to be that we're doing
> > per-backing_dev writeback (if I read sync_sb_inodes() correctly), but
> > we're measuring variables which are global to the VM. The backing device
> > that we are selecting may not be writing out any dirty pages, in which
> > case, we're just spinning in balance_dirty_pages_ratelimited().
>
> OK, so it's unrelated to page reclaim.
>
> > Should we therefore perhaps be looking at adding per-backing_dev stats
> > too?
>
> That's what mm-per-device-dirty-threshold.patch and friends are doing.
> Whether it works adequately is not really known at this time.
> Unfortunately kernel developers don't test -mm much.
>
