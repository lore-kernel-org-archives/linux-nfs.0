From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] improve the performance of large sequential write NFS
	workloads
Date: Sat, 19 Dec 2009 20:20:33 +0800
Message-ID: <20091219122033.GA11360@localhost>
References: <1261015420.1947.54.camel@serenity> <1261037877.27920.36.camel@laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve Rago <sar-a+KepyhlMvJWk0Htik3J/w@public.gmane.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
	"jens.axboe" <jens.axboe@oracle.com>,
	Peter Staubach <staubach@redhat.com>
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:4779 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751851AbZLSMXK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 19 Dec 2009 07:23:10 -0500
In-Reply-To: <1261037877.27920.36.camel@laptop>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Steve,

// I should really read the NFS code, but maybe you can help us better
// understand the problem :)

On Thu, Dec 17, 2009 at 04:17:57PM +0800, Peter Zijlstra wrote:
> On Wed, 2009-12-16 at 21:03 -0500, Steve Rago wrote:
> > Eager Writeback for NFS Clients
> > -------------------------------
> > Prevent applications that write large sequential streams of data (like backup, for example)
> > from entering into a memory pressure state, which degrades performance by falling back to
> > synchronous operations (both synchronous writes and additional commits).

What exactly is the "memory pressure state" condition?  What's the
code to do the "synchronous writes and additional commits" and maybe
how they are triggered?

> > This is accomplished by preventing the client application from
> > dirtying pages faster than they can be written to the server:
> > clients write pages eagerly instead of lazily.

We already have the balance_dirty_pages() based global throttling.
So what makes the performance difference in your proposed "per-inode" throttling?
balance_dirty_pages() does have much larger threshold than yours. 

> > The eager writeback is controlled by a sysctl: fs.nfs.nfs_max_woutstanding set to 0 disables
> > the feature.  Otherwise it contains the maximum number of outstanding NFS writes that can be
> > in flight for a given file.  This is used to block the application from dirtying more pages
> > until the writes are complete.

What if we do heuristic write-behind for sequential NFS writes?

Another related proposal from Peter Staubach is to start async writeback
(without the throttle in your proposal) when one inode have enough pages
dirtied:

        Another approach that I suggested was to keep track of the
        number of pages which are dirty on a per-inode basis.  When
        enough pages are dirty to fill an over the wire transfer,
        then schedule an asynchronous write to transmit that data to
        the server.  This ties in with support to ensure that the
        server/network is not completely overwhelmed by the client
        by flow controlling the writing application to better match
        the bandwidth and latencies of the network and server.
        With this support, the NFS client tends not to fill memory
        with dirty pages and thus, does not depend upon the other
        parts of the system to flush these pages.

Can the above alternatives fix the same problem? (or perhaps, is the
per-inode throttling really necessary?)

> > This patch is based heavily (okay, almost entirely) on a prior patch by Peter Staubach.  For
> > the original patch, see http://article.gmane.org/gmane.linux.nfs/24323.
> >
> > The patch below applies to linux-2.6.32-rc7, but it should apply cleanly to vanilla linux-2.6.32.
> >
> > Performance data and tuning notes can be found on my web site (http://www.nec-labs.com/~sar).
> > With iozone, I see about 50% improvement for large sequential write workloads over a 1Gb Ethernet.
> > With an in-house micro-benchmark, I see 80% improvement for large, single-stream, sequential
> > workloads (where "large" is defined to be greater than the memory size on the client).

These are impressive numbers. I wonder what would be the minimal patch
(just hacking it to fast, without all the aux bits)? Is it this chunk
to call nfs_wb_eager()?

> > @@ -623,10 +635,21 @@ static ssize_t nfs_file_write(struct kio
> >       nfs_add_stats(inode, NFSIOS_NORMALWRITTENBYTES, count);
> >       result = generic_file_aio_write(iocb, iov, nr_segs, pos);
> >       /* Return error values for O_SYNC and IS_SYNC() */
> > -     if (result >= 0 && nfs_need_sync_write(iocb->ki_filp, inode)) {
> > -             int err = nfs_do_fsync(nfs_file_open_context(iocb->ki_filp), inode);
> > -             if (err < 0)
> > -                     result = err;
> > +     if (result >= 0) {
> > +             if (nfs_need_sync_write(iocb->ki_filp, inode)) {
> > +                     int err;
> > +
> > +                     err = nfs_do_fsync(nfs_file_open_context(iocb->ki_filp),
> > +                                        inode);
> > +                     if (err < 0)
> > +                             result = err;
> > +             } else if (nfs_max_woutstanding != 0 &&
> > +                  nfs_is_seqwrite(inode, pos) &&
> > +                  atomic_read(&nfsi->ndirty) >= NFS_SERVER(inode)->wpages) {
> > +                     nfs_wb_eager(inode);
> > +             }
> > +             if (result > 0)
> > +                     nfsi->wrpos = pos + result;
> >       }

Thanks,
Fengguang

