From: Steve Rago <sar@nec-labs.com>
Subject: Re: [PATCH] improve the performance of large sequential write NFS
	workloads
Date: Sat, 19 Dec 2009 09:25:47 -0500
Message-ID: <1261232747.1947.194.camel@serenity>
References: <1261015420.1947.54.camel@serenity>
	 <1261037877.27920.36.camel@laptop>  <20091219122033.GA11360@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Peter Zijlstra <peterz@infradead.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
	"jens.axboe" <jens.axboe@oracle.com>,
	Peter Staubach <staubach@redhat.com>
To: Wu Fengguang <fengguang.wu@intel.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752463AbZLSOZz@vger.kernel.org>
In-Reply-To: <20091219122033.GA11360@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Sat, 2009-12-19 at 20:20 +0800, Wu Fengguang wrote:
> Hi Steve,
> 
> // I should really read the NFS code, but maybe you can help us better
> // understand the problem :)
> 
> On Thu, Dec 17, 2009 at 04:17:57PM +0800, Peter Zijlstra wrote:
> > On Wed, 2009-12-16 at 21:03 -0500, Steve Rago wrote:
> > > Eager Writeback for NFS Clients
> > > -------------------------------
> > > Prevent applications that write large sequential streams of data (like backup, for example)
> > > from entering into a memory pressure state, which degrades performance by falling back to
> > > synchronous operations (both synchronous writes and additional commits).
> 
> What exactly is the "memory pressure state" condition?  What's the
> code to do the "synchronous writes and additional commits" and maybe
> how they are triggered?

Memory pressure occurs when most of the client pages have been dirtied
by an application (think backup server writing multi-gigabyte files that
exceed the size of main memory).  The system works harder to be able to
free dirty pages so that they can be reused.  For a local file system,
this means writing the pages to disk.  For NFS, however, the writes
leave the pages in an "unstable" state until the server responds to a
commit request.  Generally speaking, commit processing is far more
expensive than write processing on the server; both are done with the
inode locked, but since the commit takes so long, all writes are
blocked, which stalls the pipeline.

Flushing is generated from the flush kernel threads (nee pdflush) and
from the applications themselves (balance_dirty_pages), as well as
periodic sync (kupdate style).  This is roughly controlled by adjusting
dirty_ratio and dirty_background_ratio (along with
dirty_expire_centisecs and dirty_writeback_centisecs).

In addition, when the client system *really* needs a page deep down in
the page allocator, it can generate a synchronous write request of
individual pages.  This is just about as expensive as a commit, roughly
speaking, again stalling the pipeline.

> 
> > > This is accomplished by preventing the client application from
> > > dirtying pages faster than they can be written to the server:
> > > clients write pages eagerly instead of lazily.
> 
> We already have the balance_dirty_pages() based global throttling.
> So what makes the performance difference in your proposed "per-inode" throttling?
> balance_dirty_pages() does have much larger threshold than yours. 

I originally spent several months playing with the balance_dirty_pages
algorithm.  The main drawback is that it affects more than the inodes
that the caller is writing and that the control of what to do is too
coarse.  My final changes (which worked well for 1Gb connections) were
more heuristic than the changes in the patch -- I basically had to come
up with alternate ways to write pages without generating commits on
inodes.  Doing this was distasteful, as I was adjusting generic system
behavior for an NFS-only problem.  Then a colleague found Peter
Staubach's patch, which worked just as well in less code, and isolated
the change to the NFS component, which is where it belongs.

> 
> > > The eager writeback is controlled by a sysctl: fs.nfs.nfs_max_woutstanding set to 0 disables
> > > the feature.  Otherwise it contains the maximum number of outstanding NFS writes that can be
> > > in flight for a given file.  This is used to block the application from dirtying more pages
> > > until the writes are complete.
> 
> What if we do heuristic write-behind for sequential NFS writes?

Part of the patch does implement a heuristic write-behind.  See where
nfs_wb_eager() is called.

> 
> Another related proposal from Peter Staubach is to start async writeback
> (without the throttle in your proposal) when one inode have enough pages
> dirtied:
> 
>         Another approach that I suggested was to keep track of the
>         number of pages which are dirty on a per-inode basis.  When
>         enough pages are dirty to fill an over the wire transfer,
>         then schedule an asynchronous write to transmit that data to
>         the server.  This ties in with support to ensure that the
>         server/network is not completely overwhelmed by the client
>         by flow controlling the writing application to better match
>         the bandwidth and latencies of the network and server.
>         With this support, the NFS client tends not to fill memory
>         with dirty pages and thus, does not depend upon the other
>         parts of the system to flush these pages.
> 
> Can the above alternatives fix the same problem? (or perhaps, is the
> per-inode throttling really necessary?)

This alternative *is contained in* the patch (as this is mostly Peter's
code anyway; all I've done is the analysis and porting). The throttling
is necessary to prevent the client from continuing to fill all of its
memory with dirty pages, which it can always do faster than it can write
pages to the server.

> 
> > > This patch is based heavily (okay, almost entirely) on a prior patch by Peter Staubach.  For
> > > the original patch, see http://article.gmane.org/gmane.linux.nfs/24323.
> > >
> > > The patch below applies to linux-2.6.32-rc7, but it should apply cleanly to vanilla linux-2.6.32.
> > >
> > > Performance data and tuning notes can be found on my web site (http://www.nec-labs.com/~sar).
> > > With iozone, I see about 50% improvement for large sequential write workloads over a 1Gb Ethernet.
> > > With an in-house micro-benchmark, I see 80% improvement for large, single-stream, sequential
> > > workloads (where "large" is defined to be greater than the memory size on the client).
> 
> These are impressive numbers. I wonder what would be the minimal patch
> (just hacking it to fast, without all the aux bits)? Is it this chunk
> to call nfs_wb_eager()?

The first half is the same as before, with different indentation.  The
last half is indeed the heuristic to call nfs_wb_eager() to invoke
asynchronous write-behind.

With these changes, the number of NFS commit messages drops from a few
thousands to tens when writing a 32GB file over NFS.  This is mainly
because the server is writing dirty pages from its cache in the
background, so when a commit comes along, it has less work to do (as
opposed to writing all of the pages on demand and then waiting for the
commit).

I have a second set of changes, which I have not yet submitted, that
removes these commits, but it extends the protocol (in a
backward-compatible way), which will probably be a harder sell.

Steve

> 
> > > @@ -623,10 +635,21 @@ static ssize_t nfs_file_write(struct kio
> > >       nfs_add_stats(inode, NFSIOS_NORMALWRITTENBYTES, count);
> > >       result = generic_file_aio_write(iocb, iov, nr_segs, pos);
> > >       /* Return error values for O_SYNC and IS_SYNC() */
> > > -     if (result >= 0 && nfs_need_sync_write(iocb->ki_filp, inode)) {
> > > -             int err = nfs_do_fsync(nfs_file_open_context(iocb->ki_filp), inode);
> > > -             if (err < 0)
> > > -                     result = err;
> > > +     if (result >= 0) {
> > > +             if (nfs_need_sync_write(iocb->ki_filp, inode)) {
> > > +                     int err;
> > > +
> > > +                     err = nfs_do_fsync(nfs_file_open_context(iocb->ki_filp),
> > > +                                        inode);
> > > +                     if (err < 0)
> > > +                             result = err;
> > > +             } else if (nfs_max_woutstanding != 0 &&
> > > +                  nfs_is_seqwrite(inode, pos) &&
> > > +                  atomic_read(&nfsi->ndirty) >= NFS_SERVER(inode)->wpages) {
> > > +                     nfs_wb_eager(inode);
> > > +             }
> > > +             if (result > 0)
> > > +                     nfsi->wrpos = pos + result;
> > >       }
> 
> Thanks,
> Fengguang
> 
