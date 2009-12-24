From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] improve the performance of large sequential write NFS
	workloads
Date: Thu, 24 Dec 2009 09:21:01 +0800
Message-ID: <20091224012101.GA8486@localhost>
References: <1261015420.1947.54.camel@serenity> <1261037877.27920.36.camel@laptop> <20091219122033.GA11360@localhost> <1261232747.1947.194.camel@serenity> <20091222015907.GA6223@localhost> <1261500113.13028.78.camel@serenity>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter Zijlstra <peterz@infradead.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
	"jens.axboe" <jens.axboe@oracle.com>,
	Peter Staubach <staubach@redhat.com>, Jan Kara <jack@suse.cz>,
	Arjan van de Ven <arjan@infradead.org>,
	Ingo Molnar <mingo@elte.hu>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
To: Steve Rago <sar@nec-labs.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <1261500113.13028.78.camel@serenity>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Dec 23, 2009 at 12:41:53AM +0800, Steve Rago wrote:
> 
> On Tue, 2009-12-22 at 09:59 +0800, Wu Fengguang wrote:
> > Steve,
> > 
> > On Sat, Dec 19, 2009 at 10:25:47PM +0800, Steve Rago wrote:
> > > 
> > > On Sat, 2009-12-19 at 20:20 +0800, Wu Fengguang wrote:
> > > > 
> > > > On Thu, Dec 17, 2009 at 04:17:57PM +0800, Peter Zijlstra wrote:
> > > > > On Wed, 2009-12-16 at 21:03 -0500, Steve Rago wrote:
> > > > > > Eager Writeback for NFS Clients
> > > > > > -------------------------------
> > > > > > Prevent applications that write large sequential streams of data (like backup, for example)
> > > > > > from entering into a memory pressure state, which degrades performance by falling back to
> > > > > > synchronous operations (both synchronous writes and additional commits).
> > > > 
> > > > What exactly is the "memory pressure state" condition?  What's the
> > > > code to do the "synchronous writes and additional commits" and maybe
> > > > how they are triggered?
> > > 
> > > Memory pressure occurs when most of the client pages have been dirtied
> > > by an application (think backup server writing multi-gigabyte files that
> > > exceed the size of main memory).  The system works harder to be able to
> > > free dirty pages so that they can be reused.  For a local file system,
> > > this means writing the pages to disk.  For NFS, however, the writes
> > > leave the pages in an "unstable" state until the server responds to a
> > > commit request.  Generally speaking, commit processing is far more
> > > expensive than write processing on the server; both are done with the
> > > inode locked, but since the commit takes so long, all writes are
> > > blocked, which stalls the pipeline.
> > 
> > Let me try reiterate the problem with code, please correct me if I'm
> > wrong.
> > 
> > 1) normal fs sets I_DIRTY_DATASYNC when extending i_size, however NFS
> >    will set the flag for any pages written -- why this trick? To
> >    guarantee the call of nfs_commit_inode()? Which unfortunately turns

> >    almost every server side NFS write into sync writes..

Ah sorry for the typo, here I mean: the commits by pdflush turn most
server side NFS _writeback_ into sync ones(ie, datawrite+datawait,
with WB_SYNC_ALL).

Just to clarify it:
        write     = from user buffer to page cache
        writeback = from page cache to disk

> Not really.  The commit needs to be sent, but the writes are still
> asynchronous.  It's just that the pages can't be recycled until they
> are on stable storage.

Right.

> > 
> >  writeback_single_inode:
> >     do_writepages
> >       nfs_writepages
> >         nfs_writepage ----[short time later]---> nfs_writeback_release*
> >                                                    nfs_mark_request_commit
> >                                                      __mark_inode_dirty(I_DIRTY_DATASYNC);
> >                                     
> >     if (I_DIRTY_SYNC || I_DIRTY_DATASYNC)  <---- so this will be true for most time
> >       write_inode
> >         nfs_write_inode
> >           nfs_commit_inode
> > 
> > 
> > 2) NFS commit stops pipeline because it sleep&wait inside i_mutex,
> >    which blocks all other NFSDs trying to write/writeback the inode.
> > 
> >    nfsd_sync:
> >      take i_mutex
> >        filemap_fdatawrite
> >        filemap_fdatawait
> >      drop i_mutex
> >      
> >    If filemap_fdatawait() can be moved out of i_mutex (or just remove
> >    the lock), we solve the root problem:
> > 
> >    nfsd_sync:
> >      [take i_mutex]
> >        filemap_fdatawrite  => can also be blocked, but less a problem
> >      [drop i_mutex]
> >        filemap_fdatawait
> >  
> >    Maybe it's a dumb question, but what's the purpose of i_mutex here?
> >    For correctness or to prevent livelock? I can imagine some livelock
> >    problem here (current implementation can easily wait for extra
> >    pages), however not too hard to fix.
> 
> Commits and writes on the same inode need to be serialized for
> consistency (write can change the data and metadata; commit [fsync]
> needs to provide guarantees that the written data are stable). The
> performance problem arises because NFS writes are fast (they generally
> just deposit data into the server's page cache), but commits can take a

Right. 

> long time, especially if there is a lot of cached data to flush to
> stable storage.

"a lot of cached data to flush" is not likely with pdflush, since it
roughly send one COMMIT per 4MB WRITEs. So in average each COMMIT
syncs 4MB at the server side.

Your patch adds another pre-pdlush async write logic, which greatly
reduced the number of COMMITs by pdflush. Can this be the major factor
of the performance gain?

Jan has been proposing to change the pdflush logic from

        loop over dirty files {
                writeback 4MB
                write_inode
        }
to
        loop over dirty files {
                writeback all its dirty pages
                write_inode
        }

This should also be able to reduce the COMMIT numbers. I wonder if
this (more general) approach can achieve the same performance gain.

> > The proposed patch essentially takes two actions in nfs_file_write()
> > - to start writeback when the per-file nr_dirty goes high
> >   without committing
> > - to throttle dirtying when the per-file nr_writeback goes high
> >   I guess this effectively prevents pdflush from kicking in with
> >   its bad committing behavior
> > 
> > In general it's reasonable to keep NFS per-file nr_dirty low, however
> > questionable to do per-file nr_writeback throttling. This does not
> > work well with the global limits - eg. when there are many dirty
> > files, the summed-up nr_writeback will still grow out of control.
> 
> Not with the eager writeback patch.  The nr_writeback for NFS is limited
> by the woutstanding tunable parameter multiplied by the number of active
> NFS files being written.

Ah yes - _active_ files. That makes it less likely, but still possible.
Imagine the summed-up nr_dirty exceeds global limit, and pdflush wakes
up. It will cycle through all dirty files and make them all in active
NFS write..  It's only a possibility though - NFS writes are fast in
normal.

> > And it's more likely to impact user visible responsiveness than
> > a global limit. But my opinion can be biased -- me have a patch to
> > do global NFS nr_writeback limit ;)
> 
> What affects user-visible responsiveness is avoiding long delays and
> avoiding delays that vary widely.  Whether the limit is global or
> per-file is less important (but I'd be happy to be convinced otherwise).

For example, one solution is to have max_global_writeback and another
is to have max_file_writeback. Then their default values may be

        max_file_writeback = max_global_writeback / 10

Obviously the smaller max_global_writeback is more likely to block
users when active write files < 10, which is the common case.

Or, in this fake workload (spike writes from time to time),

        for i in `seq 1 100`
        do
                cp 10MB-$i /nfs/
                sleep 1s
        done

When you have 5MB max_file_writeback, the copies will be bumpy, while
the max_global_writeback will never kick in..

Note that there is another difference: your per-file nr_writeback
throttles _dirtying_ process, while my per-NFS-mount nr_writeback
throttles pdflush (then indirectly throttles application).

Thanks,
Fengguang
