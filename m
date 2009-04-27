From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 3/3] readahead: introduce context readahead algorithm
Date: Mon, 27 Apr 2009 12:48:14 +0800
Message-ID: <20090427044814.GA9975@localhost>
References: <20090412071950.166891982@intel.com> <20090412072052.686760755@intel.com> <x49k55mintn.fsf@segfault.boston.devel.redhat.com> <20090415044301.GB9948@localhost> <x49r5ztg5sr.fsf@segfault.boston.devel.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Vladislav Bolkhovitin <vst@vlnb.net>,
	Jens Axboe <jens.axboe@oracle.com>,
	LKML <linux-kernel@vger.kernel.org>, linux-nfs@vger.kernel.org,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	Neil Brown <neilb@suse.de>
To: Jeff Moyer <jmoyer@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754598AbZD0Esr@vger.kernel.org>
In-Reply-To: <x49r5ztg5sr.fsf@segfault.boston.devel.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Jeff,

I did some more NFS readahead tests. Judging from your and mine tests, I can
say that the context readahead is safe for trivial NFS workloads :-) It is
behaving in the expected way, and the overheads, if any, are close enough
to the fluctuating margin.

On Thu, Apr 16, 2009 at 01:55:48AM +0800, Jeff Moyer wrote:
> Hi, Fengguang,
>
> Wu Fengguang <fengguang.wu@intel.com> writes:
>
> >> I tested out your patches.  Below are some basic iozone numbers for a
> >> single NFS client reading a file.  The iozone command line is:
> >>
> >>   iozone -s 2000000 -r 64 -f /mnt/test/testfile -i 1 -w
> >
> > Jeff, thank you very much for the testing out!
> >
> >> The file system is unmounted after each run to flush the cache.  The
> >> numbers below reflect only a single run each.  The file system was also
> >> unmounted on the NFS client after each run.
> >>
> >> KEY
> >> ---
> >> vanilla:	   2.6.30-rc1
> >> readahead:	   2.6.30-rc1 + your 10 readahead patches
> >> context readahead: 2.6.30-rc1 + your 10 readahead patches + the 3
> >> 		   context readahead patches.
> >> nfsd's:		   number of NFSD threads on the server
> >
> > I guess you are applying the readahead patches to the server side?
>
> That's right.
>
> > What's the NFS mount options and client/server side readahead size?
> > The context readahead is pretty sensible to these parameters.
>
> Default options everywhere.

The default options observed in my test platforms:
        - client: CFQ, kernel 2.6.30-rc3 + linux-2.6-block.git for linus
        - server: CFQ, kernel 2.6.30-rc2-next-20090417
is
        - rsize=256k
        - NFS readahead size=3840k (= 256k * 15)
        - sda readahead size=128k

> >> I'll note that the cfq in 2.6.30-rc1 is crippled, and that Jens has a
> >> patch posted that makes the numbers look at least a little better, but
> >> that's immaterial to this discussion, I think.
[snip]
> > Let me transform them into relative numbers:
> >
> >              A     B     C      A..B      A..C
> > cfq-1      43127 42471 42827    -1.5%     -0.7%
> > cfq-2      22354 21913 21882    -2.0%     -2.1%
> > cfq-4      20858 21252 20678    +1.9%     -0.9%
> > cfq-8      21179 20979 21508    -0.9%     +1.6%
> >
> > deadline-1 43732 42801 43040    -2.1%     -1.6%
> > deadline-2 68059 70158 71173    +3.1%     +4.6%
> > deadline-4 76659 82068 82407    +7.1%     +7.5%
> > deadline-8 83231 82406 86583    -1.0%     +4.0%
> >
> > Summaries:
> > 1) the overall numbers are slightly negative for CFQ and looks better
> >    with deadline.
>
> The variance is probably 1-2%.  I'll try to quantify that for you.

I tried to measure the overheads, here is the approach:
- random read(4K) syscalls on a huge sparse file over NFS
- server side readahead size=1M, otherwise all default options

The -0.1%, +0.5% differences in time are close enough to the variance.

                  vanilla    +max_sane_readahead()      +mmap readahead
        run-1     77.01s      77.18                     77.96s
        run-2     77.18s      77.53                     77.76s
        run-3     77.93s      77.57                     77.84s
        run-4     77.76s                                78.16s
        run-5     77.55s                                77.76s
        run-6                                           77.90s
        avg       77.486      77.427                    77.897
        diff%                 -0.1%                     +0.5%

> > Anyway we have the io context problem for CFQ.  And I'm planning to
> > dive into the CFQ code and your patch on that :-)
>
> Jens already reworked the patch and included it in his for-linus branch
> of the block tree.  So, you can start there.  ;-)

Good news. I'm running with it :-)

> > 2) the single thread case performance consistently dropped by 1-2%.
>
> > It seems not related to the behavior changes introduced by the mmap
> > readahead patches and context readahead patches. And looks more like
> > some overheads created by the code reorganization and the patch
> > "readahead: apply max_sane_readahead() limit in ondemand_readahead()"
> > which adds a bit overhead with the call max_sane_readahead().
> >
> > I'll try to root cause it.

Then I go on to test sequential reads on real files over NFS.

Again the differences are small enough.

        vanilla        +mmap&context readahead   diff%
nfsd=1  28.875s        28.770s                   -0.4%
nfsd=8  42.533s        42.255s                   -0.7%

For the single nfsd case, the readahead sequence is perfect and exactly the
same before/after the context readahead patch:

[   60.542986] readahead-initial0(pid=3124(nfsd), dev=08:02(sda2), ino=129(vmlinux-2.6.29), req=0+64, ra=0+128-64, async=0) = 128
[   60.573652] readahead-subsequent(pid=3124(nfsd), dev=08:02(sda2), ino=129(vmlinux-2.6.29), req=64+32, ra=128+256-256, async=1) = 2
56
[   60.590312] readahead-subsequent(pid=3124(nfsd), dev=08:02(sda2), ino=129(vmlinux-2.6.29), req=128+32, ra=384+256-256, async=1) =
256
[   60.652863] readahead-subsequent(pid=3124(nfsd), dev=08:02(sda2), ino=129(vmlinux-2.6.29), req=384+32, ra=640+256-256, async=1) =
256
[   60.713916] readahead-subsequent(pid=3124(nfsd), dev=08:02(sda2), ino=129(vmlinux-2.6.29), req=640+32, ra=896+256-256, async=1) =
256
[   60.776168] readahead-subsequent(pid=3124(nfsd), dev=08:02(sda2), ino=129(vmlinux-2.6.29), req=896+32, ra=1152+256-256, async=1) =
 256
[   60.837423] readahead-subsequent(pid=3124(nfsd), dev=08:02(sda2), ino=129(vmlinux-2.6.29), req=1152+32, ra=1408+256-256, async=1)
= 256
[   60.899360] readahead-subsequent(pid=3124(nfsd), dev=08:02(sda2), ino=129(vmlinux-2.6.29), req=1408+32, ra=1664+256-256, async=1)
= 256


Thanks,
Fengguang
