From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] improve the performance of large sequential write NFS
	workloads
Date: Tue, 22 Dec 2009 09:59:07 +0800
Message-ID: <20091222015907.GA6223@localhost>
References: <1261015420.1947.54.camel@serenity> <1261037877.27920.36.camel@laptop> <20091219122033.GA11360@localhost> <1261232747.1947.194.camel@serenity>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter Zijlstra <peterz@infradead.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
	"jens.axboe" <jens.axboe@oracle.com>,
	Peter Staubach <staubach@redhat.com>, Jan Kara <jack@suse.cz>,
	Arjan van de Ven <arjan@infradead.org>,
	Ingo Molnar <mingo@elte.hu>, linux-fsdevel@vger.kernel.org
To: Steve Rago <sar@nec-labs.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <1261232747.1947.194.camel@serenity>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Steve,

On Sat, Dec 19, 2009 at 10:25:47PM +0800, Steve Rago wrote:
> 
> On Sat, 2009-12-19 at 20:20 +0800, Wu Fengguang wrote:
> > 
> > On Thu, Dec 17, 2009 at 04:17:57PM +0800, Peter Zijlstra wrote:
> > > On Wed, 2009-12-16 at 21:03 -0500, Steve Rago wrote:
> > > > Eager Writeback for NFS Clients
> > > > -------------------------------
> > > > Prevent applications that write large sequential streams of data (like backup, for example)
> > > > from entering into a memory pressure state, which degrades performance by falling back to
> > > > synchronous operations (both synchronous writes and additional commits).
> > 
> > What exactly is the "memory pressure state" condition?  What's the
> > code to do the "synchronous writes and additional commits" and maybe
> > how they are triggered?
> 
> Memory pressure occurs when most of the client pages have been dirtied
> by an application (think backup server writing multi-gigabyte files that
> exceed the size of main memory).  The system works harder to be able to
> free dirty pages so that they can be reused.  For a local file system,
> this means writing the pages to disk.  For NFS, however, the writes
> leave the pages in an "unstable" state until the server responds to a
> commit request.  Generally speaking, commit processing is far more
> expensive than write processing on the server; both are done with the
> inode locked, but since the commit takes so long, all writes are
> blocked, which stalls the pipeline.

Let me try reiterate the problem with code, please correct me if I'm
wrong.

1) normal fs sets I_DIRTY_DATASYNC when extending i_size, however NFS
   will set the flag for any pages written -- why this trick? To
   guarantee the call of nfs_commit_inode()? Which unfortunately turns
   almost every server side NFS write into sync writes..

 writeback_single_inode:
    do_writepages
      nfs_writepages
        nfs_writepage ----[short time later]---> nfs_writeback_release*
                                                   nfs_mark_request_commit
                                                     __mark_inode_dirty(I_DIRTY_DATASYNC);
                                    
    if (I_DIRTY_SYNC || I_DIRTY_DATASYNC)  <---- so this will be true for most time
      write_inode
        nfs_write_inode
          nfs_commit_inode


2) NFS commit stops pipeline because it sleep&wait inside i_mutex,
   which blocks all other NFSDs trying to write/writeback the inode.

   nfsd_sync:
     take i_mutex
       filemap_fdatawrite
       filemap_fdatawait
     drop i_mutex
     
   If filemap_fdatawait() can be moved out of i_mutex (or just remove
   the lock), we solve the root problem:

   nfsd_sync:
     [take i_mutex]
       filemap_fdatawrite  => can also be blocked, but less a problem
     [drop i_mutex]
       filemap_fdatawait
 
   Maybe it's a dumb question, but what's the purpose of i_mutex here?
   For correctness or to prevent livelock? I can imagine some livelock
   problem here (current implementation can easily wait for extra
   pages), however not too hard to fix.


The proposed patch essentially takes two actions in nfs_file_write()
- to start writeback when the per-file nr_dirty goes high
  without committing
- to throttle dirtying when the per-file nr_writeback goes high
  I guess this effectively prevents pdflush from kicking in with
  its bad committing behavior

In general it's reasonable to keep NFS per-file nr_dirty low, however
questionable to do per-file nr_writeback throttling. This does not
work well with the global limits - eg. when there are many dirty
files, the summed-up nr_writeback will still grow out of control.
And it's more likely to impact user visible responsiveness than
a global limit. But my opinion can be biased -- me have a patch to
do global NFS nr_writeback limit ;)

Thanks,
Fengguang
